# Coupon Implementation Audit — Customer App (`Car-Wash`)

**Date:** 17 Oct 2026
**Scope:** Flutter customer app only (`/Car-Wash`). Partner app and backend are **not** in this workspace.
**Status:** Read-only review. No code was modified.

> **Baseline:** findings reflect the **current working tree**, not `HEAD`. Several coupon files are untracked/uncommitted (`apply_coupon_controller.dart`, `apply_coupon_view.dart`, `welcome_coupon_model.dart`, `repositories/coupon/`) and others are modified relative to `HEAD` (`coupons_list_model.dart`, `endpoints.dart`, `payment_services.dart`, `book_slot_controller.dart`, `payment_controller.dart`, `coupon_details_controller.dart`, `book_slot_view.dart`, `coupon_details_view.dart`). All line numbers refer to the files on disk as read during this review.

> **Verification rule used in this document:** every endpoint, field name and behaviour listed as "existing" was read directly from Dart source. Anything inferred from the backend, from naming conventions, or from response usage that could not be confirmed is explicitly marked **UNVERIFIED**.

---

## 0. File map of the current coupon feature

| Layer | File | Role |
|---|---|---|
| Endpoints | `lib/app/services/endpoints.dart` (L23–26) | 4 coupon paths |
| Repository | `lib/app/repositories/coupon/coupon_repository.dart` | welcome + list fetch |
| Repository | `lib/app/repositories/auth/book_service/profile_repository.dart` (L18–30) | booking-coupon + list + details |
| Service | `lib/app/services/payment_services.dart` (L23, L43, L78) | sends `coupon_code` with payment create |
| Model | `lib/app/models/welcome_coupon_model.dart` | welcome coupon |
| Model | `lib/app/models/coupons_list_model.dart` | list item |
| Model | `lib/app/models/coupons_model.dart` | post-booking envelope |
| Model | `lib/app/models/coupon_details_model.dart` | details |
| Controller | `lib/app/controllers/booking_flow/apply_coupon_controller.dart` | apply-coupon screen |
| Controller | `lib/app/controllers/booking_flow/book_slot_controller.dart` (L49–51, L591–637) | holds selection + local math |
| Controller | `lib/app/controllers/booking_flow/payment_controller.dart` (L118, L185–215, L295–310) | passes code, handles `payment_required`/`INVALID_COUPON` |
| Controller | `lib/app/controllers/booking_flow/booking_qr_coupon_controller.dart` | post-booking coupon QR |
| Controller | `lib/app/controllers/profile/coupons_list_controller.dart` | "My Coupons" |
| Controller | `lib/app/controllers/profile/coupon_details_controller.dart` | coupon detail / redeem QR |
| View | `lib/app/views/booking_flow/apply_coupon_view.dart` | coupon picker in booking flow |
| View | `lib/app/views/booking_flow/book_slot_view.dart` (L750–975) | price breakdown + coupon row |
| View | `lib/app/views/profile/coupons_list_view.dart` | My Coupons grid |
| View | `lib/app/views/profile/coupon_details_view.dart` | QR + code + expiry |
| View | `lib/app/views/booking_flow/booking_qr_coupon_view.dart` | coupon awarded after booking |
| Routing | `lib/app/routes/app_routes.dart` L23, L30–32; `app_pages.dart` L170–217 | 4 routes |
| Bindings | `apply_coupon_binding.dart`, `booking_qr_coupon_binding.dart`, `my_coupons_binding.dart`, `coupon_details_binding.dart` | GetX wiring |
| Legacy (dead) | `scratch_card_view.dart`, `scratch_card_controller.dart`, `scratch_card_binding.dart` | commented out / unreachable |

---

## 1. The "old hardcoded 100% welcome coupon"

### 1.1 What actually exists today

**There is no hardcoded `100` discount value anywhere in the current Dart code.** A repo-wide search for `100%`, `WELCOME100`, and `100` inside `lib/` returns nothing coupon-related. The welcome coupon is **fully server-driven**:

- `POST`-less, plain `GET coupons/welcome?customer_id=<uuid>` — `coupon_repository.dart` L6–11.
- Rendered as a distinct gradient card (`apply_coupon_view.dart` `_buildWelcomeCouponCard`, L86–172) showing
  `welcome.couponTitle` and `"${welcome.discountPercent}% OFF"`.
- Selected via `ApplyCouponController.applyWelcomeCoupon()` (L82–92) which pops the route with
  `{coupon_code, coupon_title, discount_percent}`.

So the "100% welcome coupon" is a **backend coupon campaign** whose percentage (`discount_percent = 100`) and title come from the database. The Flutter side is percentage-agnostic — it prints whatever integer the API returns.

### 1.2 Where the 100% behaviour surfaces in Flutter

Because a 100% coupon makes the payable amount zero, the app has an explicit branch for it:

`payment_controller.dart` L185–215

```dart
// WELCOME COUPON / ZERO-PAYABLE BOOKING (payment_required = false)
if (response["payment_required"] == false) {
  final booking = response["booking"];
  String? bookingCode; String finalAmount = "0";
  if (booking is Map) {
    bookingCode = booking["booking_code"]?.toString() ?? booking["id"]?.toString();
    finalAmount = booking["amount"]?.toString() ?? "0";
  }
  bookingCode ??= response["booking_reference"]?.toString();
  successToast("booking_confirmed".tr);
  Get.offAllNamed(Routes.confirmationpageview, arguments: {...});
  return;   // ← skips Paymob entirely
}
```

**Meaning (verified):** the client does **not** compute "100% ⇒ skip payment". It trusts the backend flag `payment_required == false`. The 100 %-ness is entirely a server decision.

### 1.3 Historical / legacy decoration (not functional)

- `git show 4bcebe3^:lib/app/views/profile/my_coupons_view.dart` shows the pre-refactor screen: a `GridView` with `itemCount: 4` and **hardcoded titles** `"Scratch & Win"`, `"Cashback Offer"`, `"Refer Bonus"`, `"Free Wash"`. No codes, no percentages, no API. This was pure mock UI.
- `scratch_card_view.dart` is **entirely commented out**; its route is commented out in `app_pages.dart` L175–177. `ScratchCardController` is still registered by `scratch_card_binding.dart` but nothing navigates to it. Dead code.

### 1.4 Is the welcome coupon automatically applied?

**No.** Verified: `applyWelcomeCoupon()` is only ever called from the `onPressed` of the button in `apply_coupon_view.dart` L151. There is no `onInit` auto-selection and no defaulting in `book_slot_controller.dart`. The customer must open the coupon sheet and tap **Apply**. The `coupon_code` is then only transmitted at payment-create time (`book_slot_controller.dart` L373).

---

## 2. Coupon APIs currently called

All four calls are **`GET`**, and all four are made **without an Authorization header** — `requireAuthToken` defaults to `false` in `ApiService.get` (`api_service.dart` L138) and no coupon caller overrides it. Identity is passed as a **query parameter** instead.

| # | Endpoint | Query params | Caller(s) | Response fields parsed |
|---|---|---|---|---|
| 1 | `coupons/welcome` | `customer_id` | `CouponRepository.fetchWelcomeCoupon` → `ApplyCouponController._fetchWelcomeCoupon` | `success`, `data.{coupon_code, status, discount_percent, expires_at, activated_at, used_at, coupon_type, coupon_title, is_expired}` |
| 2 | `coupons/list` | `customer_id` | `CouponRepository.fetchCouponsList` → `ApplyCouponController._fetchCouponsList` (**never invoked, see §3.2**) and `CouponsListController.fetchCoupons` (raw `ApiService.get` with interpolated query string) | `success`, `data[]` of `{coupon_code, status, discount_percent, expires_at, is_expired, coupon_type, coupon_title}` |
| 3 | `coupons/customer` | `booking_code` | `ProfileRepository.getCustomerCoupon` → `BookingQrCouponController.fetchCoupon` | `success`, `data.{coupon_code, status, discount_percent, expires_at, is_expired}` |
| 4 | `coupons/details` | `coupon_code` | `CouponDetailsController.fetchCouponDetails` (raw `ApiService.get`) and `ProfileRepository.apiGetCouponDetails` (defined, **unused**) | `data.{coupon_code, status, discount_percent, expires_at, is_expired}` |

### 2.1 Write operations

| Endpoint | Method | Purpose | Where |
|---|---|---|---|
| `payment/create` | `POST` (auth token **required**) | Booking + payment init, carries `coupon_code` | `payment_services.dart` L15–60 |
| `payment/status/attempt/{id}` | `GET` (auth) | Poll until `payment_status == "PAID"` | `payment_services.dart` L110+; polled in `payment_webview.dart` L140–215 |
| `payment/status/{bookingId}` | `GET` (auth) | Defined; not used in the coupon path | `payment_services.dart` L86 |

`payment/create` request body (verified field list, `payment_services.dart` L28–48):

`customer_id, customer_name, vehicle, service_id, service_name, slot_id, scheduled_at, amount, latitude, longitude, pincode, formatted_address, address, house_number, landmark, address_label, coupon_code`

`payment/create` response fields read (verified, `payment_controller.dart` L160–245):
`success`, `payment_required`, `booking` (`booking_code` | `id`, `amount`), `booking_reference`, `payment_url`, `payment_attempt_id`.
Error envelope read on 4xx: `error` (string, `"INVALID_COUPON"` handled) and `reason` (string).

> **UNVERIFIED / cannot confirm from this repo:** there is **no** redeem/validate endpoint, no campaign/admin endpoint, no "award coupon" endpoint, no coupon-eligibility endpoint, and no coupon usage/limit field in any Dart model. If the backend has them, the app never calls them. The partner-side redeem API is out of workspace.

### 2.2 Observed backend contract quirks worth flagging

- `coupons/list` is called **twice with different semantics**: once with `?customer_id=` (both coupon controllers) and `ProfileRepository.apiGetcouponslist()` calls it with **no params at all** (dead method). Inconsistent.
- `CouponsListController` builds the URL by string interpolation (`"${EndPoints.apiGetcouponslist}?customer_id=$customerId"`) instead of using `params:`, so a null `customerUuid` becomes the literal `customer_id=null`.
- `CouponData.fromJson` / `CouponDetailsModel.fromJson` call `DateTime.parse(json["expires_at"])` and take `discount_percent` as non-null `int`. A missing/null field throws, which `BookingQrCouponController` catches and turns into the "Coupon unavailable" screen; `CouponDetailsController` turns it into "Coupon not found". `CouponsListModel` is defensive (null-safe) — the three models are inconsistent.

---

## 3. How coupons are displayed, and how discount / service / status / expiry are handled

### 3.1 Customer-facing surfaces

**a) My Coupons** — `views/profile/coupons_list_view.dart` (route `/my_coupons`, entry points: `page4_view.dart` L143–144 and the rewards banner in `page1_view.dart` L732)
- 2-column grid fed by `coupons/list`.
- Card shows only: `discountPercent% OFF` (L122), hardcoded English `"Expires: dd MMM"` (L167), and a button labelled `use_now` / `not_active` driven by `canUse()`.
- `canUse()` = `status == "ACTIVE" && !isExpired` — **duplicated logic**, separate from `CouponsListModel.isActive`.
- Buttons always navigate to coupon details, even when inactive.
- Not localized: `"My Coupons"`, `"Expires: "`, and the banner `"You've got new\nrewards!"` are English literals, even though `l10n` keys exist (`my_coupons`, `youve_got_new_rewards`, `expires_in`).
- No service restriction, no min-spend, no customer-limit, no coupon type/title displayed.

**b) Coupon details / redeem** — `views/profile/coupon_details_view.dart` (route `/coupon_details_view`)
- Loads `coupons/details?coupon_code=`; renders `discountPercent% OFF`, a **QR of the raw coupon code** (`QrImageView(data: c.couponCode)`, L94), tap-to-copy code, `Expires on dd MMM, yyyy`, and a status pill.
- Status pill: `isActive` → green, else orange; `displayStatus` special-cases `"IN_PROGRESS"` → `"PENDING"` (L60–63) — evidence the backend has at least one non-ACTIVE transient state whose meaning is **UNVERIFIED**.
- Bottom text is a hardcoded English literal "Scan this code at the terminal or show it to a cashier…" (L195–198) and duplicates the unused l10n key `redeem_discount_message`.

**c) Apply Coupon (inline in booking flow)** — `views/booking_flow/apply_coupon_view.dart` (route `/apply_coupon`, opened from `book_slot_view.dart` L958)
- Renders the welcome coupon as a highlighted card + a section titled `available_coupons`.
- Each list card shows `coupon_title` (fallback `"N% OFF"`) and `valid_till dd MMM`. Tapping **Apply** pops `{coupon_code, coupon_title, discount_percent}`.
- The discount % shown here is the **only** eligibility signal — nothing about which service/vehicle/amount the coupon is valid for.

**d) Post-booking coupon** — `views/booking_flow/booking_qr_coupon_view.dart` (route `/qr_coupon_view`)
- Reached from the success screen: `confirmation_page_view.dart` L135 passes `booking_code`.
- Calls `coupons/customer?booking_code=`, renders `discountPercent% OFF`, raw `status` string as text, QR, code, `valid_till`, and a Done button → dashboard.
- Failure branch is a hardcoded English "Coupon unavailable / Your booking was completed successfully, but the coupon could not be loaded right now." + "Go to Dashboard" (L38–90).

### 3.2 Defect: the non-welcome coupon list is never loaded in the booking flow

`ApplyCouponController.fetchCoupons()` (L23–34) calls **only** `_fetchWelcomeCoupon()`. `_fetchCouponsList()` (L56–81) is defined but **has zero callers**. Because `apply_coupon_view.dart` renders `controller.coupons` and treats `coupons.isEmpty` as a gate, the booking-flow coupon picker effectively shows **only the welcome coupon**. Any campaign coupon the admin creates will not appear there until this method is wired in (and the welcome/`!isWelcome` dedupe filter kept).

### 3.3 Status / expiry handling

| Concern | Where | Behaviour |
|---|---|---|
| Active check | `CouponsListModel.isActive`, `WelcomeCouponModel.isActive`, `CouponDetailsController.isActive`, `BookingQrCouponController.isRedeemable`, `CouponsListController.canUse` | Five independent, copy-pasted implementations of `status == "ACTIVE" && !isExpired`. The backend's `is_expired` flag is the only expiry input besides display text. |
| Local clock expiry | — | Not implemented. The app never compares `expiresAt` to `DateTime.now()`; it trusts `is_expired`. If the flag is stale, an expired coupon still looks usable. |
| `IN_PROGRESS` | `CouponDetailsController.displayStatus` | Mapped to "PENDING" for display only. |
| `WELCOME` type | `CouponsListModel.isWelcome` (`couponType == 'WELCOME'`) | Used only as a dedupe filter (`!c.isWelcome`) when building the list; has no gating meaning. |
| Other coupon types (campaign / reward / referral) | — | **No type model exists.** `coupon_type` is parsed as a free-form `String` and only compared against `'WELCOME'`. |

---

## 4. Is any discount automatically applied during booking or payment?

**Short answer: the discount math is done on the client, and it is sent as an already-discounted `amount`. There is no automatic application, no eligibility validation, and no server-confirmed quote.**

### 4.1 The flow, step by step

1. `book_slot_controller.dart` L49–51 holds the selection:
   `selectedCouponCode`, `selectedCouponTitle`, `selectedCouponDiscountPercent`.
2. `openApplyCoupon()` (L618–632) awaits the picker result and stores the three values. **No re-fetch, no validation** — the values come straight from the picker payload.
3. Price math (`book_slot_controller.dart` L591–612):
   - `servicePrice = double.tryParse(price)`
   - `vatAmount = servicePrice * 0.18` (VAT **hardcoded at 18 %**)
   - `totalAmount = servicePrice + vatAmount`
   - `couponDiscountAmount = totalAmount * percent / 100`
   - `discountedTotal = totalAmount - couponDiscountAmount` (clamped at 0)
4. Booking → payment navigation (`book_slot_controller.dart` L352–380) passes **`"amount": discountedTotal`** (L363) *and* `"coupon_code": selectedCouponCode.value` (L373).
5. `payment_controller.dart` L118 forwards `couponCode`; `payment_services.dart` L43 posts both.
6. Backend may reject with `error == "INVALID_COUPON"`; `payment_services.dart` L78–80 rethrows as `__INVALID_COUPON__|<reason>`; `payment_controller.dart` L295–310 maps reason → localized message:

| Backend `reason` | l10n key |
|---|---|
| `ALREADY_USED` | `coupon_already_used` |
| `EXPIRED` | `coupon_expired` |
| `NOT_OWNER` | `coupon_belongs_to_another_account` |
| `NOT_ACTIVE` | `coupon_not_available` |
| anything else | `invalid_coupon_code` |

7. If `payment_required == false` → booking confirmed with no Paymob (§1.2). Otherwise Paymob webview, poll `payment/status/attempt`, on `"PAID"` → `confirmationpageview` → "Done" → `qr_coupon_view`.

### 4.2 Consequences (verified from code)

- **Client-computed amount is the amount charged.** The backend receives `amount = discountedTotal`. Nothing in the app re-verifies that the server agrees with the discount before the user sees the price. Whether the backend recomputes and overrides — **UNVERIFIED**.
- **No eligibility gating whatsoever.** The picker never filters by `service_id`, service category, amount threshold, or vehicle. `book_slot_controller` has `serviceId` in scope but never sends it with the coupon selection; the coupon models have no eligible-service field.
- **No customer limit / usage count** shown or enforced client-side. `used_at` is parsed but never displayed or checked.
- **Delivery fee / VAT treatment is not modelled per coupon** — discount is applied to gross incl. VAT.
- **Removing a coupon** (`removeCoupon()`, L634–638) resets only local state; the already-navigated payment args are rebuilt on next request, so this is safe, but there is no re-quote.
- **No "coupon is not valid for this booking" pre-check** — the customer only discovers it after tapping Pay.
- **No idempotency guard**: tapping Pay twice posts `payment/create` twice with the same coupon code; duplicate handling is left to the backend.

---

## 5. Gap analysis vs. the required admin-configurable campaign flow

Required flow: *admin configures % / eligible services / customer limit / validity → after an eligible booking is COMPLETED and its payment is PAID, backend awards a coupon → customer app displays it → partner app validates and redeems.*

| # | Requirement | Current state | Gap |
|---|---|---|---|
| 1 | Admin configures discount %, eligible services, customer limit, validity | App has no model fields for eligible service(s), customer limit, validity period, or campaign ID | **Missing entirely** in the customer app (and admin UI is out of workspace) |
| 2 | Backend awards coupon after eligible booking is COMPLETED **and** PAID | The only "award" surface is `coupons/customer?booking_code=`, opened from the success screen right after payment polling returns `PAID` | Award trigger location (webhook vs. request-time generation) is **UNVERIFIED**; app never checks booking `COMPLETED` (business completion ≠ payment) before showing the coupon |
| 3 | Customer app displays the awarded coupon | `booking_qr_coupon_view` shows only % + status + code; My Coupons grid shows only % + expiry | No campaign name, no eligible-services text, no limit/remaining uses, no "next booking only" copy, no type badge (WELCOME vs REWARD) |
| 4 | Coupon usable on a future **eligible** booking | Picker lists coupons but (a) list fetch is dead code, (b) no eligibility filter at all | Must fetch eligibility per `service_id`/cart and disable/annotate ineligible coupons |
| 5 | Partner app validates & redeems | Out of workspace | **Cannot verify.** No redeem endpoint is referenced anywhere in the customer app. |
| 6 | Single source of truth for coupon state | 5 duplicated `status == "ACTIVE"` checks; client-side math | Move to one model/one service; treat server response as authoritative |

### 5.1 Additional gaps that will bite during implementation

1. `coupons/list` returns **all** coupons for a customer — no pagination/filtering by `active`/`type`, so the UI must filter; today `CouponsListController` does **not** filter, while `ApplyCouponController` filters to `isActive && !isWelcome` (but never runs).
2. `coupons/welcome` is a **dedicated endpoint**. With admin-configurable campaigns, a per-type endpoint per campaign is unscaleable — needs a single `/coupons` collection with a `type` discriminator plus a client-side or query-level type filter.
3. No localization for `coupon_type`, eligible-service names, or "remaining uses" — new l10n keys required in **both** `app_en.dart` and `app_ar.dart`.
4. Hardcoded VAT (`* 0.18`) and hardcoded English strings mean the "price details" block cannot honestly show a campaign-caliber discount breakdown.
5. `coupons/*` calls are **unauthenticated** and identify the customer by a client-supplied `customerUuid` from `SharedPrefsHelper` — a customer could read another's coupons by changing the id. For coupons awarded on payment, these must be token-scoped.

---

## 6. Required changes — file by file

> Nothing below has been implemented. This is the change list implied by §5.

### 6.1 Models

| File | Change |
|---|---|
| `lib/app/models/coupons_list_model.dart` | Add `id`, `campaignId`, `discountType` (PERCENT/AMOUNT), `discountValue`, `minSpend`, `eligibleServiceIds` / `eligibleServiceCategory`, `customerLimit`, `usedCount`/`remainingUses`, `validFrom`, `validUntil`, `type` (`WELCOME`/`REWARD`/`CAMPAIGN`), `awardedFromBookingCode`, `terms`. Make `fromJson` fully null-safe (today it is; keep it that way). |
| `lib/app/models/welcome_coupon_model.dart` | **Retire or merge** into `CouponsListModel`. If kept, add the same campaign fields so the apply screen can render one card type. |
| `lib/app/models/coupons_model.dart` | Null-safe `fromJson` (`expires_at` may be null → currently throws). Reuse the unified model instead of a third envelope. |
| `lib/app/models/coupon_details_model.dart` | Null-safe + add the campaign fields above (eligible services, limit, terms). |
| **New** `lib/app/models/coupon_eligibility_model.dart` | Represents "is this coupon usable for service X / amount Y", returned by the (to-be-confirmed) eligibility API. **Do not create until the backend contract is confirmed.** |
| **New** enum | `CouponStatus { active, inProgress, used, expired, revoked }` + `CouponType` enum, replacing string comparisons. |

### 6.2 Services / repositories

| File | Change |
|---|---|
| `lib/app/services/endpoints.dart` | Consolidate. Add an eligibility/quote endpoint and a awarded-coupons endpoint **only after confirming the real paths**. Keep `coupons/welcome` only if the backend keeps it. |
| `lib/app/repositories/coupon/coupon_repository.dart` | Add `fetchCoupons(customerId, {type, serviceId})` as the single list call; pass params via `params:`; set `requireAuthToken: true`; delete the duplicate in `ProfileRepository`. |
| `lib/app/repositories/auth/book_service/profile_repository.dart` | Remove `apiGetcouponslist` / `apiGetCouponDetails` (unused duplicates). Keep `getCustomerCoupon(bookingCode)` for the award screen, or replace with the unified repository. |
| `lib/app/services/payment_services.dart` | Stop sending a client-computed `amount` as the authoritative price, or send an explicit `expected_amount` + `coupon_code` so the server can reject mismatches. Send `service_id` alongside `coupon_code`. Map the full reason set (`NOT_ELIGIBLE`, `LIMIT_REACHED`, `MIN_SPEND`, `NOT_STARTED`) to l10n. |
| **New** `lib/app/services/coupon_service.dart` | Central place for list / details / eligibility / apply-result validation + a single `isUsable()` rule. |

### 6.3 Controllers

| File | Change |
|---|---|
| `apply_coupon_controller.dart` | **Call `_fetchCouponsList()`** (currently dead). Take `serviceId` + subtotal from route arguments and request eligibility. Remove the `welcomeCoupon` special case in favour of a typed list. Return `{coupon_code, coupon_title, discount_value, discount_type}` and let the caller compute. |
| `book_slot_controller.dart` | Do not compute the authoritative total from a % alone. Request a quote (or accept server totals) before showing the price. Replace hardcoded `0.18` VAT with a server/config value. Send `service_id` with the coupon. Handle `discountType == AMOUNT` (flat discount) — currently percentage-only. |
| `payment_controller.dart` | Keep the `payment_required == false` branch but base it on the server response only (already the case). Extend `_couponErrorMessage` for the new reasons. Do not clear the coupon silently on retry. |
| `coupons_list_controller.dart` | Stop using raw `ApiService.get` with a hand-built query. Use the repository, filter/section by status & type, expose `activeCount`, and show campaign meta (eligible services, remaining uses, validity). |
| `coupon_details_controller.dart` | Handle the null-throwing parse. Show terms, eligible services, limit, validity window. Keep copy-to-clipboard. |
| `booking_qr_coupon_controller.dart` | Null-safe parse; show campaign title/type/eligible services; distinguish "not yet awarded" (`404`/`success:false`) from "awarded but not fetched". Handle the `COMPLETED + PAID` gate messaging. |

### 6.4 Views

| File | Change |
|---|---|
| `apply_coupon_view.dart` | Merge welcome + list into a single typed list; add disabled/ineligible state with a reason ("Not valid for this service", "Minimum spend SAR X", "Already used"); localize all strings. |
| `book_slot_view.dart` (L750–975) | Show `discount` and `total_amount` from the server quote; support amount-type discounts; localize. |
| `coupons_list_view.dart` | Show campaign title/type badge, eligible-service line, validity, remaining uses. Localize `"My Coupons"`, `"Expires: "`, `"You've got new rewards!"` (keys already exist). Fix the `GridView` `itemCount`/skeleton mismatch (`itemCount: 4` while loading is fine, but the grid uses `childAspectRatio: 0.8` with 2 highly variable text blocks). |
| `coupon_details_view.dart` | Localize the "scan at terminal" copy (use `redeem_discount_message`); show eligible services + terms; add "Redeemed on" when `used_at`/status = used. |
| `booking_qr_coupon_view.dart` | Localize "Coupon unavailable" / "Go to Dashboard"; render title/type; add "Use on your next booking" copy. |
| `page1_view.dart` L690–745 / `page4_view.dart` L143 | "You've got new rewards" banner currently links to My Coupons regardless of whether any coupon exists. Gate it on an actual active-coupon count. |

### 6.5 Routing / bindings / l10n

- `app_routes.dart` L24 + `app_pages.dart` L175–177: delete the dead `scratchcard` route, `scratch_card_view.dart`, `scratch_card_controller.dart`, `scratch_card_binding.dart` (or explicitly park them under a `legacy/` folder).
- `lib/app/localization/app_en.dart` / `app_ar.dart`: add keys for coupon type, eligibility errors (`coupon_not_eligible_for_service`, `coupon_min_spend`, `coupon_limit_reached`, `coupon_not_started`), "remaining uses", "valid from/until", "awarded after your completed booking", "terms". `discount` currently maps to "Coupon Discount" — fine, but the Arabic `"خصم الكوبون"` should be checked for width in the price row.

### 6.6 Partner-side (out of workspace — cannot plan from code)

The customer app produces **only** a QR containing the raw `coupon_code` string (`QrImageView(data: c.couponCode)` in both `coupon_details_view.dart` L94 and `booking_qr_coupon_view.dart` L137). There is **no signed payload, no HMAC, no nonce, no expiry encoded in the QR**. If the partner app is to validate & redeem offline-safe, either:
- the QR must carry a signed token (backend-issued), **or**
- the partner must call a server validate/redeem endpoint with the code + booking id at redeem time.

Deciding this is a backend/partner contract item — flagged, not chosen here.

---

## 7. Backend contract items that must be confirmed before coding

These were **not** verifiable from this repo. Do not implement against assumptions.

1. Does `GET coupons/list` accept filters (`type`, `status`, `service_id`) and does it require auth? What is the exact item schema (does it include eligible services, limits, valid-from)?
2. Is `coupons/welcome` still the award mechanism, or will it be replaced by a campaign object? Should it be retired?
3. What exactly does `coupons/customer?booking_code=` do — generate-on-read, or read a pre-generated award? What does it return when no coupon is awarded (404? `success:false`? empty `data`?) — the controller currently treats **both** non-success and exceptions as the same error screen.
4. Is the award trigger "booking COMPLETED **and** payment PAID"? What status string identifies COMPLETED? The app never reads booking status for coupons today.
5. Is there an eligibility/quote endpoint (service + amount + coupon) or must the client guess? If the client guesses, what happens on mismatch at `payment/create` — which `error`/`reason` codes exist beyond `INVALID_COUPON`?
6. Does `payment/create` recompute the amount server-side, or does it trust the client's `amount`? (Security-relevant: the client sends `discountedTotal`.)
7. Is there a redeem/validate endpoint for the partner app, and does the customer app need a "show redeemed state" refresh after redemption (e.g. polling or pull-to-refresh)?
8. Exact `status` values: `ACTIVE`, `IN_PROGRESS`, `USED`, `EXPIRED`, `REVOKED`? The app maps `IN_PROGRESS` → PENDING for display but has no handling for a `USED`/`REVOKED` badge.
9. Does `discount_percent` remain an integer? Admin-configurable campaigns usually need decimals (`12.5 %`) and flat amounts (`SAR 25`). Current models are `int` percentage only.

---

## 8. Summary (one-screen answer)

| Question | Answer |
|---|---|
| Old hardcoded 100 % welcome coupon | **Not hardcoded in Flutter.** Server-supplied via `GET coupons/welcome`; the 100 % case is handled solely through the `payment_required == false` branch in `payment_controller.dart` L185. Legacy mock UI (`my_coupons_view.dart`) and fully-commented `scratch_card_view.dart` are dead code. |
| Coupon APIs called | `GET coupons/welcome?customer_id`, `GET coupons/list?customer_id`, `GET coupons/customer?booking_code`, `GET coupons/details?coupon_code` — all unauthenticated. Write path: `POST payment/create` (auth) carrying `coupon_code`. |
| Display / eligibility / expiry | Only `discount_percent`, `status`, `expires_at`, `coupon_type`, `coupon_title` are modelled. No eligible service, no customer limit, no min spend. Expiry relies on backend `is_expired`; the local clock is never compared. Five duplicated `status == "ACTIVE"` checks. |
| Auto-applied? | No auto-apply — the customer must tap Apply. But the **discount math is client-side** (`total * percent / 100`, VAT hardcoded 18 %) and the **discounted amount is what gets sent** to `payment/create`. Invalid codes are rejected only at payment time. |
| Changes needed | Unified coupon model with campaign fields; single authenticated repository; fix the dead `_fetchCouponsList()`; server-side quote instead of client math; eligibility-aware picker; localized, type-aware UI on 4 screens; nullable-safe parsing; remove legacy scratch-card/duplicate repository methods; add l10n keys. Partner redeem contract must be defined before any QR/redemption work. |

### Highest-severity findings

1. 🔴 **`ApplyCouponController._fetchCouponsList()` is never called** → admin-created campaign coupons can never be applied in the booking flow (`apply_coupon_controller.dart` L23–34 vs. L56–81).
2. 🔴 **Client computes and sends the payable amount** (`book_slot_controller.dart` L591–612 compute, L363 sends `discountedTotal`) with no server quote — any campaign discount is effectively client-controlled until `payment/create` validates it (**UNVERIFIED** that it does).
3. 🟠 **Coupon endpoints are unauthenticated and keyed by a client-supplied `customer_id`** — cross-account coupon disclosure risk.
4. 🟠 **No eligibility model at all** — no service, amount, limit or validity-window data exists client-side, so the required admin-driven eligibility cannot be enforced or even displayed.
5. 🟡 **Dead/duplicated code**: `scratch_card_*` (unreachable), `ProfileRepository.apiGetcouponslist`/`apiGetCouponDetails` (unused), `coupons_model.dart` envelope duplicating `welcome_coupon_model.dart`, five separate status checks.
