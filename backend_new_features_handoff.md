# Backend API handoff for Flutter

This document describes the current backend contract for connecting the Flutter Web frontend. The Postman collection beside this file is [Stark VMS API.postman_collection.json](./Stark%20VMS%20API.postman_collection.json).

## Connection and authentication

- Local API base URL: `http://localhost:8080/api/v1`
- Health check: `GET http://localhost:8080/actuator/health`
- Render: use the deployed service URL followed by `/api/v1`.
- All `/api/v1` routes require `Authorization: Bearer <accessToken>`, except public registration and login.
- Login uses `POST /auth/login` with `username` and `password`. The response contains `data.accessToken`, `data.tokenType: "Bearer"`, `data.expiresIn` in seconds, and `data.user`.
- Keep the bearer token on requests to vehicles, drivers, assignments, documents, maintenance, and dashboard endpoints. A missing or invalid token returns HTTP 401.
- Registration is public and creates a `ROLE_USER`. There is no admin-account or role-management API. Current authenticated accounts share fleet access.

All JSON APIs use this envelope:

```json
{
  "success": true,
  "message": "Request completed",
  "data": {}
}
```

Errors use `success: false`, a human-readable `message`, and an ISO timestamp. Validation errors can also include `fieldErrors`.

## Existing vehicle API

Vehicle fields remain `vehicleNumber`, `companyName`, `vehicleType`, `brand`, `model`, and `status`. Vehicle status labels are exactly `Active`, `Inactive`, and `Maintenance`.

- `GET /vehicles`: page vehicles. Query parameters: `search`, `status`, `page` (zero-based), `size` (1–100), `sortBy`, and `sortDirection` (`asc` or `desc`).
- `POST /vehicles`: create a vehicle.
- `GET /vehicles/{vehicleNumber}`: read a vehicle.
- `PUT /vehicles/{vehicleNumber}`: update vehicle data. The path identifies the existing vehicle number; the request body contains the regular vehicle fields.
- `DELETE /vehicles/{vehicleNumber}`: delete a vehicle and its related document objects/metadata. A current assignment is released as part of vehicle deletion.

Vehicle listing has a paged response with `content`, `page`, `size`, `totalElements`, and `totalPages`. Search is case-insensitive across vehicle number, company, type, brand, and model.

Vehicle responses now include this additive nullable field:

```json
"assignedDriver": {
  "id": 12,
  "name": "Rafiqul Islam",
  "phone": "+880 1712-345678"
}
```

When no driver is assigned, `assignedDriver` is `null`. This field is response-only: vehicle create/update requests must not send it and must not use vehicle CRUD to assign or clear a driver.

## Driver API

A driver has `name`, `phone`, `licenseNumber`, `licenseExpiry`, and `status`. Dates are date-only ISO strings (`YYYY-MM-DD`). Status labels are exactly `Active` or `Inactive`. The backend trims names/phone outer whitespace, trims and uppercases license numbers, and enforces normalized license uniqueness.

Example create/update body:

```json
{
  "name": "Rafiqul Islam",
  "phone": "+880 1712-345678",
  "licenseNumber": "DHAKA-M-123456",
  "licenseExpiry": "2028-07-31",
  "status": "Active"
}
```

Routes:

| Method | Path | Behavior |
| --- | --- | --- |
| `POST` | `/drivers` | Create an unassigned driver; returns 201. |
| `GET` | `/drivers/{driverId}` | Get driver details and current vehicle summary. |
| `PUT` | `/drivers/{driverId}` | Replace driver fields; does not change assignment. |
| `DELETE` | `/drivers/{driverId}` | Delete an unassigned driver. |
| `GET` | `/drivers` | Search, filter, sort, and page drivers. |

Driver list query parameters:

- `search`: case-insensitive match across name, phone, license number, and assigned vehicle number.
- `status`: exact `Active` or `Inactive`.
- `page`: zero-based, default 0.
- `size`: default 10, maximum 100.
- `sortBy`: `name`, `licenseExpiry`, `status`, or `createdAt`.
- `sortDirection`: `asc` or `desc`; it requires `sortBy`.

Default order is `createdAt` descending with ID ascending as a stable tie-breaker. Each driver response contains a nullable `assignedVehicle` summary so the Drivers screen can render the vehicle without making a request per row:

```json
"assignedVehicle": {
  "vehicleNumber": "DHAKA METRO GA-12-3456",
  "brand": "Toyota",
  "model": "Corolla"
}
```

If the driver is unassigned, `assignedVehicle` is `null`. There is no `unassignedOnly` query parameter. For assignment choices, request Active drivers and filter candidates where `assignedVehicle == null`; page through results if necessary. A size up to 100 is supported.

## Current driver assignment

Assignment is one-to-one and represents only the current state. No assignment history is stored.

### Assign or change the vehicle's driver

`PUT /vehicles/{vehicleNumber}/driver`

```json
{
  "driverId": 12
}
```

The response is the updated vehicle, including `assignedDriver`. A vehicle has zero or one current driver; a driver can be assigned to at most one vehicle.

- Only an Active driver can be assigned.
- A driver already assigned to another vehicle cannot be assigned.
- Sending the same driver for the same vehicle again is idempotent.
- Assigning a different driver to a vehicle replaces its current driver atomically; the previous driver becomes unassigned.
- To change a vehicle's driver, the frontend can send the new `driverId` directly. It does not need a separate unassign first.

### Unassign

`DELETE /vehicles/{vehicleNumber}/driver`

Returns HTTP 200 with the standard success envelope. Repeating the request when the vehicle is already unassigned is safe. The released driver becomes available for another vehicle.

An assigned driver cannot be marked Inactive or deleted. Both operations return HTTP 409 until the frontend explicitly unassigns the driver. Do not silently clear the assignment when editing or deleting a driver.

For vehicle numbers with spaces or reserved characters, encode the value as one path segment when constructing the URL (encode exactly once).

## Documents

All document routes are authenticated.

| Method | Path | Behavior |
| --- | --- | --- |
| `POST` | `/vehicles/{vehicleNumber}/documents` | Multipart upload. |
| `GET` | `/vehicles/{vehicleNumber}/documents` | Paged upload history. |
| `GET` | `/vehicles/{vehicleNumber}/documents/{documentId}/download` | Create a short-lived signed download URL. |

Upload uses multipart form-data fields:

- `file`: PDF, JPEG, or PNG, up to 10 MB.
- `documentType`: `Registration`, `Tax Token`, `Insurance`, `Fitness Certificate`, or `Other`.
- `expiryDate`: optional ISO date, for example `2028-07-31`.

Do not manually set a multipart `Content-Type` header in Dio; let the client set its boundary. The upload response includes `id`, `vehicleId`, `documentType`, `filename`, `contentType`, `sizeBytes`, `expiryDate`, `expiryState`, `uploadedAt`, and `latest`. History supports `documentType`, `expiryState`, `page`, and `size`. Expiry states are `EXPIRED`, `EXPIRING_SOON`, `VALID`, and `NO_EXPIRY_DATE`.

Download returns `data.url` and `data.expiresInSeconds`; open the signed URL before it expires. The frontend should request a new URL when the user downloads a file rather than persist one.

Document upload/download needs valid Supabase S3 configuration on the backend. Storage unavailable returns HTTP 503. Vehicle deletion continues to remove stored document objects and their metadata.

## Maintenance and dashboard

- `POST /vehicles/{vehicleNumber}/maintenance`: JSON fields are `maintenanceDate` (`YYYY-MM-DD`), `maintenanceType`, `cost` (non-negative number), `workshop`, and optional `notes`.
- `GET /vehicles/{vehicleNumber}/maintenance?page=0&size=10`: paged maintenance history.
- Adding a maintenance entry does not change the vehicle's status.
- `GET /dashboard/stats`: returns vehicle totals (`totalVehicles`, `activeVehicles`, `inactiveVehicles`, `maintenanceVehicles`), latest document expiry counts/lists, and current-month maintenance totals/recent records.

Use `maintenanceVehicles` in the dashboard model. The former `inServiceVehicles` field/status is no longer part of the contract.

## Status and error handling

| HTTP status | Frontend handling |
| --- | --- |
| 400 | Show field validation or invalid filter/page/sort feedback. |
| 401 | Send the user to sign in or refresh the in-memory login state; there is no refresh-token API. |
| 404 | Show that the requested driver or vehicle no longer exists. |
| 409 | Show an actionable conflict: duplicate license, driver already assigned elsewhere, inactive driver, or assigned driver needs to be unassigned. |
| 503 | Document storage is unavailable; preserve the selected document and let the user retry. |

All logged-in user roles currently share the same API access. The backend does not expose role-specific driver permissions or driver history.

## CORS and local Postman testing

Local default CORS allows `http://localhost:<any-port>` and `http://127.0.0.1:<any-port>`, including common Flutter Web ports 5000 and 6000. Production should set `VMS_CORS_ALLOWED_ORIGINS` to the exact deployed frontend origin. CORS permits browser origins; JWT is still required for protected endpoints.

Import `Stark VMS API.postman_collection.json`, run **Register test user** then **Login test user**, and use the collection's saved bearer token. The document upload request requires selecting a local test file and having Supabase storage configured. Run the Cleanup folder last; it deletes the generated test vehicle and its attached documents.
