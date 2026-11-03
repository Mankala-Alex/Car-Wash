## Booking Request Payload

This document lists the fields the customer app sends when creating or updating a booking (appointment).

**Endpoint**: `POST bookings`

**Controller (where payload is built)**: [lib/app/controllers/booking_flow/book_slot_controller.dart](lib/app/controllers/booking_flow/book_slot_controller.dart#L296-L328)

### Create booking — fields sent

- `customer_id` (string) — customer UUID
- `customer_name` (string) — customer's display name
- `vehicle` (string) — selected vehicle identifier or name
- `service_id` (string) — id of the selected service
- `service_name` (string) — name of the selected service
- `slot_id` (integer) — selected slot id
- `scheduled_at` (string) — scheduled datetime in ISO8601 UTC (e.g. `2026-09-23T10:00:00Z`)
- `amount` (number) — service price (double)
- `status` (string) — booking status (e.g. `PENDING`)
- `latitude` (number|null) — location latitude
- `longitude` (number|null) — location longitude
- `formatted_address` (string|null) — address formatted by the picker
- `address` (string|null) — raw address
- `house_number` (string|null)
- `landmark` (string|null)
- `address_label` (string|null) — user label for the address (e.g. `Home`)

### Update booking — fields sent

When editing a booking the controller builds an `updateBody` with:

- `vehicle`, `service_id`, `service_name`, `amount`, `slot_id`, `scheduled_at`

See the update logic in `book_slot_controller.dart` around the update call: [lib/app/controllers/booking_flow/book_slot_controller.dart](lib/app/controllers/booking_flow/book_slot_controller.dart#L262-L280)

### Example create request JSON

```
{
  "customer_id": "uuid-1234",
  "customer_name": "Jane Doe",
  "vehicle": "Toyota-123",
  "service_id": "42",
  "service_name": "Full Wash",
  "slot_id": 123,
  "scheduled_at": "2026-09-23T10:00:00Z",
  "amount": 100.0,
  "status": "PENDING",
  "latitude": 12.345678,
  "longitude": 98.765432,
  "formatted_address": "123 Main St, City",
  "address": "123 Main St",
  "house_number": "12A",
  "landmark": "Near Mall",
  "address_label": "Home"
}
```

If you want, I can add expected types or server response examples to this doc.
