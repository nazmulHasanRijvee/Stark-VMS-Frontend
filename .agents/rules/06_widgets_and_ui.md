# Rule: Reusable Widgets & Web UI Guidelines

All screens in Stark VMS must prioritize reusable widgets located in `lib/src/presentation/core/widgets/` and adhere to web-first responsive design standards.

## 1. Core Reusable Widgets Inventory

### `AppTextField`
- **Location**: `lib/src/presentation/core/widgets/app_text_field.dart`
- **Features**:
  - Debounced validation (400ms delay to prevent validation spam while typing).
  - Error shake animation via `enableInvalidShake: true`.
  - Password visibility toggle (`obscureText: true`, `enableToggleObscure: true`).
  - Prefix/suffix icons, read-only mode, and `focusNode` integration.
- **Usage**:
  ```dart
  AppTextField(
    controller: _vinController,
    labelText: 'Vehicle VIN',
    hintText: 'Enter 17-digit VIN',
    validator: (val) => val.length != 17 ? 'VIN must be 17 characters' : null,
    enableInvalidShake: true,
  )
  ```

### `AppDropdown<T>`
- **Location**: `lib/src/presentation/core/widgets/app_dropdown.dart`
- **Features**: Powered by `dropdown_button2` with integrated `FormField` validator, labels, and theme styling.
- **Usage**:
  ```dart
  AppDropdown<VehicleStatus>(
    label: 'Status',
    items: VehicleStatus.values,
    value: selectedStatus,
    itemAsString: (status) => status.name.toUpperCase(),
    onChanged: (newStatus) => setState(() => selectedStatus = newStatus),
  )
  ```

### `MultiSelectDropdown`
- **Location**: `lib/src/presentation/core/widgets/multi_select_dropdown.dart`
- **Features**: Checkbox-based multi-item dropdown with comma-separated summaries.
- **Usage**:
  ```dart
  MultiSelectDropdown(
    items: const ['Sedan', 'SUV', 'Truck', 'Van'],
    selectedItems: selectedCategories,
    hint: 'Filter vehicle types',
    onChanged: (items) => setState(() => selectedCategories = items),
  )
  ```

### `CustomToast`
- **Location**: `lib/src/presentation/core/widgets/custom_toast.dart`
- **Features**: Non-blocking toast notifications via `toastification`.
- **Methods**:
  - `CustomToast.showSuccess(context, title: 'Vehicle Created', description: 'Assigned ID #1042')`
  - `CustomToast.showError(context, title: 'Connection Failed', description: 'Could not sync telemetry')`
  - `CustomToast.showInfo(context, title: 'Syncing Data')`
  - `CustomToast.showWarning(context, title: 'Fuel Low Warning')`

### `CustomLoadingIndicator`
- **Location**: `lib/src/presentation/core/widgets/custom_loading_indicator.dart`
- **Features**: Lightweight SpinKit 3-bounce spinner aligned with `context.color.text.tertiary`.

### `CustomNetworkImage`
- **Location**: `lib/src/presentation/core/widgets/custom_network_image.dart`
- **Features**: `CachedNetworkImage` wrapper with loading indicator and error placeholder fallback.

### `EmptyStateWidget`
- **Location**: `lib/src/presentation/core/widgets/empty_state_widget.dart`
- **Features**: Animated empty state with pulsing rings, floating icon, title, subtitle, bouncing dots, and CTA button.
- **Usage**:
  ```dart
  EmptyStateWidget(
    icon: Icons.directions_car_outlined,
    title: 'No vehicles registered',
    subtitle: 'Add your first vehicle to begin tracking fleet telemetry.',
    buttonLabel: 'Register Vehicle',
    onAction: () => context.pushNamed(Routes.vehicleCreate.name),
  )
  ```

---

## 2. Flutter Web UI Principles for Stark VMS

1. **Responsive Breakpoints**:
   - Mobile: `< 600px` (use `context.isTablet` to check `> 600px`).
   - Desktop Web / Dashboard: `> 1024px`.
   - On Desktop Web, prefer a persistent Sidebar Navigation + Top Header + Breadcrumbs + Content Layout.

2. **Data Tables & Density**:
   - For fleet inventories, driver tables, trip logs, and maintenance logs, use structured Paginated Data Tables or custom responsive cards.
   - Column actions should include View Details, Edit, and Status Badges.

3. **Status Badges**:
   - Use `context.radius.pill` with `Container` or `Chip` for vehicle status:
     - `Active` ➡️ `context.color.success` background with low opacity
     - `In Maintenance` ➡️ `context.color.warning`
     - `Out of Service` ➡️ `context.color.error`

