# Reusable Widget Catalog

This document details the production-ready widgets available in `lib/src/presentation/core/widgets/`.

---

## 1. `AppTextField`
**File**: `lib/src/presentation/core/widgets/app_text_field.dart`

A complete form text field with built-in debounced validation, shake animations, and obscure toggles.

### Properties:
- `controller`: `TextEditingController` (required)
- `validator`: `String? Function(String value)?` (debounced by 400ms automatically)
- `labelText`, `hintText`: Strings
- `prefixIcon`, `suffixIcon`: Optional widgets
- `obscureText`: `bool`
- `enableToggleObscure`: `bool` (renders automatic show/hide eye icon)
- `enableInvalidShake`: `bool` (triggers elastic shake animation when validation fails)
- `keyboardType`, `textInputAction`, `maxLines`, `maxLength`, `enabled`, `readOnly`

### Example:
```dart
AppTextField(
  controller: _passwordController,
  labelText: 'Password',
  hintText: 'Enter account password',
  obscureText: true,
  enableToggleObscure: true,
  enableInvalidShake: true,
  validator: (val) => val.length < 8 ? 'Minimum 8 characters required' : null,
)
```

---

## 2. `AppDropdown<T>`
**File**: `lib/src/presentation/core/widgets/app_dropdown.dart`

A form-ready dropdown widget wrapping `dropdown_button2` with integrated error display and design token styling.

### Properties:
- `items`: `List<T>` (required)
- `value`: `T?` (required)
- `onChanged`: `ValueChanged<T?>` (required)
- `label`: `String?`
- `hint`: `String?`
- `validator`: `String? Function(T?)?`
- `itemAsString`: `String Function(T)?`

### Example:
```dart
AppDropdown<String>(
  label: 'Vehicle Category',
  items: const ['Heavy Truck', 'Light Van', 'Cargo Sedan'],
  value: selectedCategory,
  onChanged: (cat) => setState(() => selectedCategory = cat),
  validator: (val) => val == null ? 'Please select category' : null,
)
```

---

## 3. `MultiSelectDropdown`
**File**: `lib/src/presentation/core/widgets/multi_select_dropdown.dart`

Multi-item selection dropdown with custom checkboxes and comma-separated preview string.

### Properties:
- `items`: `List<String>` (required)
- `selectedItems`: `List<String>` (required)
- `onChanged`: `ValueChanged<List<String>>` (required)
- `hint`: `String` (defaults to "Select")

### Example:
```dart
MultiSelectDropdown(
  items: const ['Diesel', 'Petrol', 'Electric', 'Hybrid'],
  selectedItems: selectedFuelFilters,
  hint: 'Filter fuel types',
  onChanged: (updated) => setState(() => selectedFuelFilters = updated),
)
```

---

## 4. `CustomToast`
**File**: `lib/src/presentation/core/widgets/custom_toast.dart`

Top-center aligned toast notification overlay wrapping `toastification`.

### Methods:
- `CustomToast.showSuccess(BuildContext context, {required String title, String? description})`
- `CustomToast.showError(BuildContext context, {required String title, String? description})`
- `CustomToast.showInfo(BuildContext context, {required String title, String? description})`
- `CustomToast.showWarning(BuildContext context, {required String title, String? description})`

### Example:
```dart
CustomToast.showSuccess(
  context,
  title: 'Vehicle Dispatched',
  description: 'Trip #TR-8091 successfully initiated.',
);
```

---

## 5. `CustomLoadingIndicator`
**File**: `lib/src/presentation/core/widgets/custom_loading_indicator.dart`

Minimalist, theme-colored three-bounce spinner using `flutter_spinkit`.

### Example:
```dart
if (state.isLoading) const CustomLoadingIndicator()
```

---

## 6. `CustomNetworkImage`
**File**: `lib/src/presentation/core/widgets/custom_network_image.dart`

Cached image loader with `CupertinoActivityIndicator` placeholder and fallback icon.

### Properties:
- `imageUrl`: `String` (required)
- `height`: `double` (default 40.0)
- `width`: `double` (default 40.0)
- `radius`: `double` (default 0.0)
- `placeholder`: `Widget?`
- `errorWidget`: `Widget?`

### Example:
```dart
CustomNetworkImage(
  imageUrl: vehicle.photoUrl,
  width: 80,
  height: 60,
  radius: context.radius.md,
)
```

---

## 7. `EmptyStateWidget`
**File**: `lib/src/presentation/core/widgets/empty_state_widget.dart`

An animated illustration container with floating icon, pulsing concentric rings, bouncing dots, and CTA button.

### Key Properties:
- `icon`: `IconData`
- `title`: `String`
- `subtitle`: `String`
- `buttonLabel`: `String`
- `onAction`: `VoidCallback?`
- `showPulsingRings`: `bool`
- `showBouncingDots`: `bool`

### Example:
```dart
EmptyStateWidget(
  icon: Icons.local_shipping_outlined,
  title: 'No Active Dispatches',
  subtitle: 'All vehicles are currently parked in depot.',
  buttonLabel: 'Create Dispatch Order',
  onAction: () => context.go(Routes.createDispatch.path),
)
```

---

## 8. `NotFoundScreen`
**File**: `lib/src/presentation/core/widgets/not_found_screen.dart`

Error fallback screen rendered for unmapped routes by `GoRouter.errorBuilder`. Shows current URI with a button returning to `Routes.homeScreen`.

