# Currency Converter+

A modern, fast, and reliable currency conversion application built with Flutter.

## Overview

Currency Converter+ is a mobile application that provides real-time currency exchange rates and conversion capabilities. The app features a clean, calculator-style interface with support for multiple languages and historical rate tracking.

## Architecture

### Core Components

#### 1. **State Management**
- Uses `Provider` pattern for state management
- `CurrencyProvider` manages exchange rates, currency lists, and user preferences
- Reactive UI updates through `ChangeNotifier`

#### 2. **Data Layer**

**Currency Repository** (`lib/repositories/currency_repository.dart`):
- Manages exchange rate caching using `SharedPreferences`
- Implements 24-hour cache strategy to minimize API calls
- Handles offline scenarios with cached data fallback
- Stores user preferences (selected currencies, favorites, last amount)

**Historical Rates Repository** (`lib/repositories/historical_rates_repository.dart`):
- Manages historical exchange rate data
- Syncs data in background after app launch for optimal performance
- Stores up to 5 years of historical data in local database

#### 3. **API Integration**

**Currency API** (`lib/services/currency_api.dart`):
- Fetches latest exchange rates from external API
- Retrieves historical rates for chart visualization
- Implements error handling and timeout management
- Supports fetching currency names and metadata

**Key Features:**
- Automatic retry on network failures
- Graceful degradation to cached data
- Efficient batch requests for historical data

#### 4. **Database**

**Historical Database** (`lib/services/historical_database.dart`):
- Uses SQLite (via `sqflite`) for local storage
- Stores historical exchange rates with date indexing
- Optimized queries with indexes on (base, target, date)
- Batch insert operations for performance

**Database Schema:**
```sql
CREATE TABLE historical_rates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT,
  base TEXT,
  target TEXT,
  rate REAL,
  UNIQUE(date, base, target)
);
CREATE INDEX idx_rates_base_target_date ON historical_rates(base, target, date);
```

#### 5. **UI Components**

**Main Screen** (`lib/screens/currency_converter_screen.dart`):
- Calculator-style interface with keypad
- Real-time currency conversion
- Support for basic math operations (+, -, ×, ÷, %)
- Currency picker with search and favorites

**Widgets Structure:**
- `converter/` - Main conversion UI components
- `currency_picker/` - Currency selection interface
- `history/` - Historical rate charts
- `settings/` - Settings and preferences

## Performance Optimizations

### Startup Performance
1. **Non-blocking Initialization**: Historical database sync runs in background after UI loads
2. **Parallel Loading**: Rates and currencies load simultaneously using `Future.wait()`
3. **Caching Strategy**: 24-hour cache prevents unnecessary API calls on app restart
4. **Lazy Loading**: Historical data loads only when needed (chart view)

### Runtime Performance
1. **Efficient State Updates**: Uses `ChangeNotifier` with selective rebuilds
2. **Database Indexing**: Optimized queries with proper indexes
3. **Batch Operations**: Database writes use batch transactions
4. **Memory Management**: Proper disposal of controllers and listeners

### Error Handling
- Graceful fallback to cached data on network errors
- Null-safe operations throughout the codebase
- Try-catch blocks in critical calculation paths
- User-friendly error states without crashes

## Data Flow

### Exchange Rate Updates
1. App checks for cached rates (24-hour validity)
2. If cache expired or missing, fetches from API
3. Updates cache with new rates and timestamp
4. Falls back to cache if API fails

### Historical Data Sync
1. On app launch, identifies needed currency pairs
2. Checks local database for existing data
3. Fetches missing date ranges from API
4. Stores in database for offline access
5. Process runs asynchronously to not block UI

### User Preferences
- Stored in `SharedPreferences` for fast access
- Includes: selected currencies, favorites, last amount, language
- Persisted across app restarts

## Localization

- Supports 7 languages: EN, DE, FR, IT, ES, RU, UK
- Language preference persisted locally
- Automatic detection of device language on first launch
- Some strings (like "Developer's website") remain in English

## Caching Strategy

### Exchange Rates
- **Cache Duration**: 24 hours
- **Storage**: SharedPreferences (key-value pairs)
- **Fallback**: Uses cached data if API unavailable

### Historical Rates
- **Storage**: SQLite database
- **Retention**: Up to 5 years of data
- **Sync**: Background sync for frequently used pairs
- **On-demand**: Loads additional pairs when user views charts

## Dependencies

- `provider` - State management
- `shared_preferences` - Local key-value storage
- `sqflite` - SQLite database
- `http` - API requests
- `url_launcher` - External link handling
- `fl_chart` - Chart visualization
- `circle_flags` - Currency flag icons

## Build & Run

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release
```

## Version

Current version: **1.0.9+9**

## License

Copyright © UzorGame Inc
