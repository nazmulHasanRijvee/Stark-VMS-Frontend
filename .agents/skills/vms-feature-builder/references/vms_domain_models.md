# VMS Domain Models Reference

This document outlines the core entities required for the Vehicle Management System (VMS) domain.

---

## 1. Vehicle (`Vehicle`)
Represents an individual vehicle in the fleet.
- `id`: Unique identifier
- `vin`: Vehicle Identification Number (17-char string)
- `licensePlate`: Registration plate number
- `make`: Manufacturer (e.g. Ford, Toyota, Mercedes)
- `model`: Model name (e.g. Transit, Camry, Sprinter)
- `year`: Manufacturing year
- `vehicleType`: Enum (`sedan`, `suv`, `truck`, `van`, `bus`)
- `status`: Enum (`active`, `maintenance`, `inTrip`, `outOfService`)
- `currentOdometer`: Current mileage in km/miles
- `fuelType`: Enum (`diesel`, `petrol`, `electric`, `hybrid`)
- `batteryOrFuelLevel`: Current percentage (0 - 100)
- `assignedDriverId`: Nullable reference to current driver

---

## 2. Driver (`Driver`)
Represents a certified fleet driver.
- `id`: Unique identifier
- `fullName`: Driver's full name
- `licenseNumber`: Commercial driver's license ID
- `licenseExpiry`: Expiry date
- `phoneNumber`: Contact phone
- `email`: Contact email
- `status`: Enum (`available`, `onTrip`, `offDuty`, `suspended`)
- `rating`: Float rating (1.0 to 5.0)
- `assignedVehicleId`: Nullable reference to currently assigned vehicle

---

## 3. Trip / Dispatch (`DispatchTrip`)
Represents an active or completed trip order.
- `id`: Unique identifier
- `vehicleId`: Assigned vehicle
- `driverId`: Assigned driver
- `origin`: Start location coordinates & address
- `destination`: End location coordinates & address
- `status`: Enum (`scheduled`, `inProgress`, `completed`, `cancelled`)
- `startOdometer`: Mileage when leaving
- `endOdometer`: Mileage upon arrival
- `departureTime`: Timestamp
- `arrivalTime`: Nullable timestamp
- `notes`: Dispatch instructions

---

## 4. Maintenance Record (`MaintenanceRecord`)
Represents vehicle servicing, inspections, and repairs.
- `id`: Unique identifier
- `vehicleId`: Serviced vehicle
- `serviceType`: Enum (`oilChange`, `tireRotation`, `brakeInspection`, `scheduledService`, `repair`)
- `serviceDate`: Date of service
- `odometerAtService`: Mileage at time of service
- `cost`: Total financial cost
- `provider`: Service garage / vendor name
- `status`: Enum (`scheduled`, `inProgress`, `completed`)
- `technicianNotes`: Details of work performed

