# Currency Converter+ Code Structure

## 📁 Project Organization

This Flutter app has been refactored from a monolithic **2,720-line main.dart** into a clean, modular structure with **35 separate files**.

### Directory Structure

```
lib/
├── main.dart (60 lines) - App entry point
├── app.dart - Main app widget
│
├── constants/          # App-wide constants
│   ├── app_colors.dart      # Color theme
│   ├── app_constants.dart   # App version, languages
│   └── currency_constants.dart  # Currency list and flags
│
├── localization/       # Internationalization
│   ├── app_strings.dart     # Translations (7 languages)
│   └── persisted_language_notifier.dart
│
├── models/             # Data models
│   ├── currency.dart
│   ├── enums.dart           # ActiveField, HistoryInterval, etc.
│   └── historical_rate.dart
│
├── providers/          # State management
│   └── currency_provider.dart
│
├── repositories/       # Business logic layer
│   ├── currency_repository.dart
│   └── historical_rates_repository.dart
│
├── services/           # External services
│   ├── currency_api.dart    # Frankfurter API
│   └── historical_database.dart  # SQLite
│
├── utils/              # Helper functions
│   ├── amount_formatter.dart
│   └── date_formatter.dart
│
├── screens/            # Full-page screens
│   ├── currency_converter_screen.dart (579 lines)
│   ├── currency_picker_page.dart
│   └── privacy_policy_page.dart
│
└── widgets/            # Reusable UI components
    ├── common/
    │   ├── currency_flag.dart   # Flag rendering logic
    │   ├── currency_row.dart
    │   ├── divider_line.dart
    │   └── status_time.dart
    │
    ├── currency_picker/
    │   ├── currency_tile.dart
    │   ├── favorites_header.dart
    │   ├── picker_header.dart
    │   └── search_field.dart
    │
    ├── history_chart/
    │   └── history_chart_bottom_sheet.dart (538 lines)
    │
    ├── keypad/
    │   ├── key_button.dart
    │   └── keypad.dart
    │
    ├── rate_panel/
    │   └── rate_panel.dart
    │
    └── settings/
        ├── about_dialog.dart
        ├── language_selector_sheet.dart
        └── settings_bottom_sheet.dart
```

## 🎯 Benefits of This Structure

### 1. **Maintainability** ✅
   - Each file has a single responsibility
   - Easy to find and modify specific features
   - Clear separation of concerns

### 2. **Readability** ✅
   - Files are small and focused (10-579 lines)
   - Clear naming conventions
   - Logical organization

### 3. **Reusability** ✅
   - Widgets can be easily reused
   - Components are independent
   - Easy to extract for other projects

### 4. **Testability** ✅
   - Each component can be tested in isolation
   - Mock dependencies easily
   - Clear interfaces

### 5. **Scalability** ✅
   - Easy to add new features
   - Team-friendly structure
   - Follows Flutter best practices

## 📊 File Size Comparison

| Metric | Before | After |
|--------|--------|-------|
| Largest file | 2,720 lines | 579 lines |
| main.dart | 2,720 lines | 60 lines |
| Total files | 9 files | 35 files |
| Average file size | ~380 lines | ~98 lines |

## 🚀 Key Components

### **Main Screen** (currency_converter_screen.dart)
- Calculator logic
- Currency conversion
- State management
- Navigation

### **History Chart** (history_chart_bottom_sheet.dart)
- fl_chart integration
- Complex chart rendering
- Date formatting
- Data caching

### **Currency Picker** (currency_picker_page.dart)
- Search functionality
- Favorites system
- Smooth animations

### **Settings & About**
- Language selection
- Privacy policy
- App information

## 🎨 Design Pattern

This app follows **Clean Architecture** principles:

```
Presentation Layer (Screens & Widgets)
        ↓
Business Logic Layer (Providers & Repositories)
        ↓
Data Layer (Services & APIs)
```

## 📝 Notes

- All visual elements and logic remain **EXACTLY** the same
- Zero breaking changes
- Only structural improvements
- Backward compatible
