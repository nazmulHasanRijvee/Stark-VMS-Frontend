# Stark VMS — Backend Feature Overview & API Contract Specification

> **Target Audience**: Backend Engineers and AI Agents building the Java / Spring Boot backend for Stark VMS.  
> **Document Purpose**: Definitive technical specification and REST API contract aligning the Spring Boot backend with the Flutter Web frontend. Ensures backend logic, data models, and exposed endpoints strictly match what the frontend supports without scope creep.

---

## 1. System Overview & Architectural Boundaries

**Stark VMS (Vehicle Management System)** is an enterprise fleet management web application. The frontend is built with Flutter Web following Clean Architecture, Riverpod state management, and GoRouter.

### 1.1 Strict Scope Boundaries (Out-of-Scope)
To avoid unnecessary complexity and prevent misalignment between frontend and backend, the following features are **strictly out of scope** for this phase:
- ❌ **No Refresh Token Flow**: The system uses a streamlined **Access-Token-Only** architecture. No refresh token endpoints, storage, or rotation logic.
- ❌ **No GPS / Telemetry / Real-time Tracking**: No live vehicle coordinates, speed monitoring, or IoT device ingestion.
- ❌ **No Driver Assignment / Dispatching**: No driver license validation, work-shift dispatches, or trip planning.
- ❌ **No Maintenance Scheduling / Invoicing / Fuel Logs**: No garage repair orders, parts inventory, or fuel receipts.
- ❌ **No Background Job Workers / Push Notifications**: All interactions are synchronous REST requests.

### 1.2 In-Scope Capabilities
1. **User Authentication & Authorization**: Registration and Login using JWT (Access-Token-only).
2. **Dashboard Summary KPI Metrics**: High-level counts of total, active, in-service, and inactive fleet vehicles.
3. **Vehicle Fleet Management (CRUD)**: List, filter, search, register, view, update, and delete vehicle records with case-insensitive unique registration plate numbers.

---

## 2. Recommended Backend Architecture & Tech Stack

- **Language & Runtime**: Java 17+ or Java 21 (LTS)
- **Framework**: Spring Boot 3.x (`spring-boot-starter-web`, `spring-boot-starter-security`, `spring-boot-starter-data-jpa`, `spring-boot-starter-validation`)
- **Security**: Spring Security 6 with stateless `SessionCreationPolicy.STATELESS` and a custom `JwtAuthenticationFilter`
- **Password Hashing**: `BCryptPasswordEncoder` (strength 10 or 12)
- **Database**: PostgreSQL (Production) or H2 / MySQL (Development)
- **Database Migrations**: Flyway or Liquibase (or Hibernate `ddl-auto: update` for initial development)
- **API Documentation**: SpringDoc OpenAPI / Swagger UI (optional)

---

## 3. Seed Accounts & Mock Data Requirements

### 3.1 Coursework / Demo Seed Account
The backend **must idempotently seed** a default demonstration account on application startup if it does not already exist:
- **Full Name**: `John Doe`
- **Email / Username**: `admin@stark.com`
- **Password**: `password123`
- **Role**: `ROLE_ADMIN`
- **Password Storage**: The backend **must store only a BCrypt hash** of `password123`. Plaintext passwords must never be stored in the database, logged, or returned in responses.
- **Environment Scoping**: This seed account must be scoped to coursework, demo, or development profiles (e.g., `@Profile("!production")` or a configuration flag `app.seed.demo-account=true`) so it can be disabled or removed in production.
- **Security Notice**: This known, shared credential is strictly for grading, demo presentations, and evaluation. It is unsuitable for real company or enterprise data.

### 3.2 Seed Fleet Vehicles (Initial Data)
To ensure the dashboard KPI metrics match the frontend prototype upon initial load, the backend must seed the following 4 vehicles idempotently:

| Vehicle Number (Plate) | Company Name | Vehicle Type | Brand | Model | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `DHAKA METRO GA-12-3456` | Stark Logistics | Sedan | Toyota | Corolla | `Active` |
| `DHAKA METRO CHA-55-9812` | Stark Agro | Microbus / Van | Nissan | Urvan | `In Service` |
| `DHAKA METRO BA-11-2233` | Stark Retail | Sedan | Honda | Civic | `Active` |
| `CHATTOGRAM METRO KHA-22-1100` | Stark Tech | SUV | Mitsubishi | Pajero | `Inactive` |

**Derived Seed KPI Totals**:
- Total Vehicles: `4`
- Active Vehicles: `2`
- In Service Vehicles: `1`
- Inactive Vehicles: `1`

---

## 4. REST API Contract & Endpoints

All request and response bodies use standard `application/json`.

### 4.1 Global Response Standard Envelope
#### 4.1.1 Success Envelope
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

#### 4.1.2 Error Envelope
When an exception or validation error occurs, the API must return:
```json
{
  "success": false,
  "message": "Detailed error message suitable for frontend display",
  "timestamp": "2026-11-07T14:30:00Z"
}
```

---

### 4.2 Authentication Endpoints

#### 4.2.1 Register New User
- **Endpoint**: `POST /auth/register/` (or `/auth/register`)
- **Authentication**: Public (no token required)
- **Request Body**:
```json
{
  "fullName": "Jane Doe",
  "email": "jane@stark.com",
  "password": "securepassword123"
}
```
- **Validation**:
  - `fullName`: Required, 2-100 characters.
  - `email`: Required, valid email format, unique across users.
  - `password`: Required, minimum 6 characters.
- **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 2,
    "fullName": "Jane Doe",
    "email": "jane@stark.com",
    "role": "ROLE_USER"
  }
}
```
- **Error Responses**:
  - `400 Bad Request`: Validation failure (e.g. invalid email format, short password).
  - `409 Conflict`: Email already registered (`{"success": false, "message": "Email already in use"}`).

---

#### 4.2.2 User Login (Access Token Only)
- **Endpoint**: `POST /auth/login`
- **Authentication**: Public (no token required)
- **Request Body**:
  > **IMPORTANT**: The request body field is named `username` (which holds the user's email address) to match the Flutter client's `AuthenticationRepositoryImpl` and Retrofit interface:
```json
{
  "username": "admin@stark.com",
  "password": "password123"
}
```
- **Success Response (200 OK)**:
  > **Note**: Returns `accessToken` only. Refresh tokens are intentionally omitted.
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbkBzdGFyay5jb20iLCJyb2xlIjoiUk9MRV9BRE1JTiIsImV4cCI6MTc5Mzk5MDAwMH0.signature",
    "tokenType": "Bearer",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "fullName": "John Doe",
      "email": "admin@stark.com",
      "role": "ROLE_ADMIN"
    }
  }
}
```
- **Error Responses**:
  - `401 Unauthorized`: Bad credentials (`{"success": false, "message": "Invalid email or password"}`).

---

### 4.3 Dashboard KPI Metrics Endpoint

#### 4.3.1 Get Dashboard Statistics
- **Endpoint**: `GET /dashboard/stats`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "totalVehicles": 4,
    "activeVehicles": 2,
    "inServiceVehicles": 1,
    "inactiveVehicles": 1
  }
}
```

---

### 4.4 Vehicle Fleet Management Endpoints

#### 4.4.1 List & Filter Vehicles
- **Endpoint**: `GET /vehicles`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Query Parameters**:
  - `search` (optional string): Case-insensitive search matching `vehicleNumber`, `brand`, `model`, or `companyName`.
  - `status` (optional string): Filter by status: `Active`, `In Service`, `Inactive`, or `All`.
  - `page` (optional integer, default `0`): Zero-based page number.
  - `size` (optional integer, default `20`): Page size.
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": [
    {
      "vehicleNumber": "DHAKA METRO GA-12-3456",
      "companyName": "Stark Logistics",
      "vehicleType": "Sedan",
      "brand": "Toyota",
      "model": "Corolla",
      "status": "Active"
    },
    {
      "vehicleNumber": "DHAKA METRO CHA-55-9812",
      "companyName": "Stark Agro",
      "vehicleType": "Microbus / Van",
      "brand": "Nissan",
      "model": "Urvan",
      "status": "In Service"
    }
  ]
}
```

---

#### 4.4.2 Register Vehicle (Create)
- **Endpoint**: `POST /vehicles`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Request Body**:
```json
{
  "vehicleNumber": "DHAKA METRO HA-99-0001",
  "companyName": "Stark Logistics",
  "vehicleType": "Pickup",
  "brand": "Ford",
  "model": "Ranger",
  "status": "Active"
}
```
- **Validation**:
  - `vehicleNumber`: Required, trimmed, converted to uppercase, unique across all vehicles (case-insensitive).
  - `companyName`: Required, non-empty.
  - `vehicleType`: Required (e.g. `Sedan`, `SUV`, `Microbus / Van`, `Pickup`, `Truck`).
  - `brand`: Required.
  - `model`: Required.
  - `status`: Required, one of: `Active`, `In Service`, `Inactive`.
- **Success Response (201 Created)**:
```json
{
  "success": true,
  "message": "Vehicle registered successfully",
  "data": {
    "vehicleNumber": "DHAKA METRO HA-99-0001",
    "companyName": "Stark Logistics",
    "vehicleType": "Pickup",
    "brand": "Ford",
    "model": "Ranger",
    "status": "Active"
  }
}
```
- **Error Responses**:
  - `409 Conflict`: When `vehicleNumber` already exists:
    ```json
    {
      "success": false,
      "message": "A vehicle with this registration number already exists."
    }
    ```

---

#### 4.4.3 Get Single Vehicle Details
- **Endpoint**: `GET /vehicles/{vehicleNumber}`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Path Variable**: `vehicleNumber` (URL-encoded plate string)
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "data": {
    "vehicleNumber": "DHAKA METRO GA-12-3456",
    "companyName": "Stark Logistics",
    "vehicleType": "Sedan",
    "brand": "Toyota",
    "model": "Corolla",
    "status": "Active"
  }
}
```
- **Error Response**:
  - `404 Not Found`: If no vehicle matches the given plate number.

---

#### 4.4.4 Update Vehicle
- **Endpoint**: `PUT /vehicles/{vehicleNumber}`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Path Variable**: `vehicleNumber` (current plate number)
- **Request Body**:
```json
{
  "vehicleNumber": "DHAKA METRO GA-12-3456",
  "companyName": "Stark Prime Fleet",
  "vehicleType": "Sedan",
  "brand": "Toyota",
  "model": "Camry",
  "status": "In Service"
}
```
- **Validation**:
  - If `vehicleNumber` is changed in the body, verify the new number is not used by any other vehicle.
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "message": "Vehicle updated successfully",
  "data": {
    "vehicleNumber": "DHAKA METRO GA-12-3456",
    "companyName": "Stark Prime Fleet",
    "vehicleType": "Sedan",
    "brand": "Toyota",
    "model": "Camry",
    "status": "In Service"
  }
}
```

---

#### 4.4.5 Delete Vehicle
- **Endpoint**: `DELETE /vehicles/{vehicleNumber}`
- **Authentication**: Required (`Bearer <accessToken>`)
- **Path Variable**: `vehicleNumber`
- **Success Response (200 OK or 204 No Content)**:
```json
{
  "success": true,
  "message": "Vehicle deleted successfully"
}
```
- **Error Response**:
  - `404 Not Found`: If vehicle does not exist.

---

## 5. Security & Session Flow Specification

### 5.1 Access Token Rules
1. **Stateless JWTs**: Access tokens should have a standard lifespan (e.g. 24 hours).
2. **Authorization Header**: Passed on all protected endpoints as:
   ```http
   Authorization: Bearer <accessToken>
   ```
3. **No Refresh Token Endpoints**: Refresh token endpoints are deliberately omitted from the API contract.
4. **401 Unauthorized Handling**:
   - When an authenticated request returns HTTP `401 Unauthorized`, the Flutter client automatically clears the session and access token, displays a "Session expired. Please log in again." toast notification, and redirects the user to `/login`.
   - The client will not retry or attempt a background refresh.

---

## 6. Frontend to Backend Schema Mapping Reference

| Flutter Entity / Model (`lib/src/domain/entities/vehicle.dart`) | Java Entity Property (`Vehicle.java`) | SQL Column Name | Type / Constraints |
| :--- | :--- | :--- | :--- |
| `vehicle.vehicleNumber` | `vehicleNumber` | `vehicle_number` | `VARCHAR(64)` PRIMARY KEY / UNIQUE |
| `vehicle.company` | `companyName` | `company_name` | `VARCHAR(128)` NOT NULL |
| `vehicle.type` | `vehicleType` | `vehicle_type` | `VARCHAR(64)` NOT NULL |
| `vehicle.brand` | `brand` | `brand` | `VARCHAR(64)` NOT NULL |
| `vehicle.model` | `model` | `model` | `VARCHAR(64)` NOT NULL |
| `vehicle.status` | `status` | `status` | `VARCHAR(32)` NOT NULL (`Active`, `In Service`, `Inactive`) |

