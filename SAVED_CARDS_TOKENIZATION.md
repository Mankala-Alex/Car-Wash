# Saved Cards (Paymob Tokenization)

How a card saved at checkout is offered again on the next booking.

## Why it did not work before

| Step | Paymob expects | Old code |
| --- | --- | --- |
| 1. Ask to save the card | `save_card: true` on `POST /acceptance/payment_keys` | never sent |
| 2. Receive the token | separate callback `{ type: "TOKEN", obj: { token, masked_pan, ... } }` | `paymentCallback` replied `"Token callback ignored"` |
| 3. Store the token | merchant DB, keyed to the customer | no table, nothing stored |
| 4. Reuse the token | `card_token: "<token>"` on the next payment key | never sent |
| 5. Show it in the app | merchant UI | no UI, no endpoint |

So the "Save Card" checkbox in Paymob's iframe was pure decoration: Paymob
renders it, but nothing in the flow ever enabled or stored tokenization.

A second, quieter bug: `billing_data.email` was hardcoded to `test@test.com`
for every customer. Paymob binds a saved card to the billing email, so even with
steps 1–3 fixed every customer would have shared one token list.

## What the flow is now

Saving a card:

```
App                       Backend                                   Paymob
 |  POST /payment/create
 |  { save_card: true }  ->  billing_data = real customer row
 |                           payment_keys { save_card: true }  ------>  |
 |  <---- payment_url ------                                            |
 |  opens iframe, customer types the card and pays                       |
 |                             <---- callback {type:"TRANSACTION"} ------ |
 |                             <---- callback {type:"TOKEN"} ------------|
 |                           save token -> saved_cards table             |
```

Paying with the saved card again:

```
App                       Backend                                   Paymob
 |  POST /payment/create
 |  { saved_card_id: 7 } ->  token looked up server-side (scoped to the
 |                           customer), payment key created for the order
 |                           POST /acceptance/payments/pay  ---------->  |
 |                             source: {identifier: <token>, subtype: TOKEN}
 |  <-- 3 outcomes ---------                                             |
 |      PAID + booking_id            -> confirmation screen (no iframe)
 |      redirection_url (3-D Secure) -> WebView, then callback + polling
 |      SAVED_CARD_REJECTED (422)    -> seat released, "pay with a new card"
```

**Why not just pass `card_token` to the payment key?** Because Paymob's checkout
iframe ignores it. Verified against the live account: `card_token` and
`card_tokens` are accepted with `201` (no validation, no error) yet the iframe
HTML is byte-identical — 291,353 bytes — with and without them, so the saved
card can never be shown or preselected inside that iframe. The token can only be
charged through `/acceptance/payments/pay`.

### Backend

- `services/savedCardsService.js` — billing data, token parsing, CRUD, scoping.
- `services/paymobService.js`
  - `generatePaymentKey` — accepts `saveCard` and real `billingData`; the
    placeholder billing data is only used when the customer row is missing.
  - `payWithCardToken` — charges a saved token via
    `POST /acceptance/payments/pay`.
- `controllers/paymentController.js`
  - `createPayment` accepts `save_card` and `saved_card_id` (a row id only — the
    token is looked up server-side and scoped to the customer).
  - `paymentCallback` stores the token from `type: "TOKEN"` callbacks (and from
    a transaction object that carries one inline), correlating by order id first
    and billing email second.
  - `chargeSavedCard` settles a token payment: 3-D Secure redirect, instant
    approval (finalised through `finalizeAttemptPayment`, the same helper the
    callback uses), or `SAVED_CARD_REJECTED` with the seat released.
  - `getSavedCards` / `deleteSavedCard` for the list/remove endpoints.
- Migration `migrations/2026_add_saved_cards.sql` → `saved_cards` table plus
  `payment_attempts.saved_card_id`.

Endpoints (customer JWT required):

- `GET /api/payment/cards`
- `DELETE /api/payment/cards/:id`

`POST /api/payment/create` response:

| Case | Response |
| --- | --- |
| New card | `{ success, payment_url, save_card_enabled }` |
| Saved card, 3-D Secure | `{ success, requires_three_ds: true, payment_url, saved_card_applied: true }` |
| Saved card, approved instantly | `{ success, payment_status: "PAID", booking_id, ... }` |
| Saved card refused | `422 { error: "SAVED_CARD_REJECTED", message }` |

### Graceful degradation

If Paymob refuses `save_card` (tokenization not enabled on the integration), the
key is retried without it so the customer can still pay by typing the card; the
app then says the card could not be saved. A refused saved card is never charged
and never leaves the slot blocked — the app switches the customer to "new card".

## Dashboard prerequisites (Paymob)

1. Developers → Payment Integrations → the **card** integration used by
   `PAYMOB_INTEGRATION_ID` must have tokenization / saved cards enabled.
2. The callback URL (`PAYMOB_NOTIFICATION_URL`) must be reachable — the token is
   delivered to that same URL with `type=TOKEN`. A callback that 500s makes
   Paymob retry, but a callback that is unreachable loses the token.
3. If the account exposes a separate "tokenization" integration id, put it in
   `PAYMOB_INTEGRATION_ID`.

## App

- `lib/app/models/payment/saved_card_model.dart`
- `lib/app/services/payment_services.dart` — `fetchSavedCards`,
  `deleteSavedCard`, `createPayment(saveCard:, savedCardId:)`
- `lib/app/controllers/booking_flow/payment_method_controller.dart` — loads the
  cards, preselects the default one, delete + save toggle state
- `lib/app/views/booking_flow/payment_method_view.dart` — saved cards list,
  "Pay with a new card", "Save Card" switch, delete confirmation

## Tests

- `backend/tests/savedCards.test.js` — billing data, token parsing, scoping,
  idempotency, default-card promotion.
- `test/saved_card_model_test.dart` — model parsing and labels.

## Notes / limits

- The token charge skips the iframe, so the merchant-initiated (`payment/pay`)
  permission must be allowed on the live account. It responded correctly for this
  account; a real token either returns the transaction or a 3-D Secure
  redirect.
- 3-D Secure is handled by opening `redirection_url` in the existing WebView with
  `autoCheck: true` (polling starts immediately, 120 s window), because that page
  may never hit a Paymob `post pay` URL.
- Verification done on 2026-10-28 while implementing: `save_card: true` is
  accepted by integration 25685 (so tokenization is enabled), fake tokens are
  refused with `400 "An error occurred while processing the token"` → mapped to
  `SAVED_CARD_REJECTED`.

### The 3-D Secure response trap (cost one wasted attempt)

`POST /acceptance/payments/pay` for a card that needs a challenge returns:

```json
{
  "success": false,
  "pending": true,
  "is_3d_secure": true,
  "use_redirection": true,
  "redirection_url": "https://ksa.paymob.com/api/acceptance/mpgs_secure_callback/get_acs_page?token=…",
  "data.message": "Pending 3DS Authorization"
}
```

Two traps:

1. The field is **`redirection_url`**, not `redirect_url` (which the payment key
   uses). Looking only for `redirect_url` silently produced "declined".
2. `success: false` here does **not** mean the card was declined — it means the
   challenge has not been completed yet. Treating it as a failure marks a live,
   pending authorization as FAILED and releases the seat.

`chargeSavedCard` therefore checks `redirection_url` / `use_redirection` **before**
any success handling, and only reports a decline when Paymob actually declined.
