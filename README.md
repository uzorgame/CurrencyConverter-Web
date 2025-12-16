# Currency Converter+ Web

A modern, responsive web application for currency conversion with historical rate charts. This is the web version of the **Currency Converter+** mobile app, providing the same functionality in a browser environment.

🌐 **Live Site:** [https://uzorgame.github.io/CurrencyConverter-Web/](https://uzorgame.github.io/CurrencyConverter-Web/)

## Features

### 💱 Currency Conversion
- Real-time currency conversion between 30+ currencies
- Two-way input fields for seamless conversion
- Swap button to quickly reverse currency pairs
- Live exchange rates from the Frankfurter API
- Visual currency selection with country flags

### 📊 Historical Charts
- Interactive charts showing currency rate variations over time
- Multiple time periods: 1 month, 6 months, 1 year, 3 years, 5 years, and 10 years
- Hover tooltips with detailed rate information
- Smooth animations and transitions
- Responsive chart design for all screen sizes

### 🎨 User Experience
- **Dark/Light Theme**: Toggle between dark (default) and light themes
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Progressive Web App (PWA)**: Installable as a native app with offline support
- **Smooth Animations**: Micro-animations for buttons and interactive elements
- **Modern UI**: Clean, intuitive interface inspired by modern fintech applications

### ⚡ Performance
- **Caching Strategy**: Intelligent caching with TTL for API responses
- **Lazy Loading**: Efficient loading of historical data
- **Service Worker**: Offline functionality and asset caching
- **Optimized Assets**: Efficient flag image loading and caching

## Technology Stack

### Frontend
- **HTML5**: Semantic markup structure
- **CSS3**: Modern styling with CSS variables, animations, and responsive design
- **Vanilla JavaScript**: No frameworks - pure JavaScript for optimal performance
- **Chart.js 4.4.0**: Interactive chart visualization library

### APIs & Services
- **Frankfurter API**: Real-time and historical currency exchange rates
- **FlagCDN**: High-quality country flag images

### PWA Features
- **Service Worker**: Offline caching and background sync
- **Web App Manifest**: App-like installation experience
- **Cache Strategy**: Network-first for HTML/CSS/JS, cache-first for assets

## Architecture

### File Structure
```
├── index.html          # Main HTML structure
├── styles.css          # All styling and themes
├── app.js              # Core application logic
├── manifest.json       # PWA manifest
├── sw.js              # Service Worker for offline support
├── Icon.png           # App icon
└── icons/             # Additional icon assets
```

### Key Components

#### State Management
- `AppState` class: Manages application state with localStorage persistence
- Currency preferences, theme settings, and cached data

#### API Integration
- `CurrencyAPI` class: Handles all API interactions
- `CachedAPI` class: Implements caching with TTL for performance
- Automatic cache invalidation and updates

#### Chart System
- Dynamic chart rendering with Chart.js
- Period-based data fetching
- Responsive chart sizing
- Theme-aware chart colors

## How It Works

1. **Currency Conversion**
   - User enters amount in either currency field
   - Real-time conversion using current exchange rates
   - Automatic recalculation on currency or amount change

2. **Historical Charts**
   - User selects a time period (1M, 6M, 1Y, 3Y, 5Y, 10Y)
   - Application fetches historical rates from Frankfurter API
   - Chart.js renders interactive line chart
   - Hover tooltips show detailed rate information

3. **Caching Strategy**
   - API responses cached with TTL (Time To Live)
   - Service Worker caches static assets for offline access
   - Network-first strategy ensures fresh content
   - Automatic cache versioning for updates

4. **Theme System**
   - CSS variables for dynamic theming
   - Theme preference stored in localStorage
   - Automatic chart color updates on theme change

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Performance Optimizations

- **Throttling**: Mouse and touch events throttled for smooth interactions
- **Virtual Scrolling**: Efficient rendering of large currency lists
- **Lazy Loading**: Historical data loaded on demand
- **Asset Optimization**: Optimized images and efficient caching
- **Code Splitting**: Modular JavaScript architecture

## Privacy & Security

- **No Data Collection**: The app does not collect, store, or track any personal data
- **No Analytics**: No tracking or analytics services
- **HTTPS Only**: All API communication secured via HTTPS
- **Local Storage**: Settings stored locally on user's device
- **No User Accounts**: No registration or login required

## Development

### Local Setup
1. Clone the repository
2. Serve the files using a local web server:
   ```bash
   # Using Python
   python -m http.server 8000
   
   # Using Node.js
   npx http-server
   ```
3. Open `http://localhost:8000` in your browser

### Service Worker
The Service Worker is automatically registered on page load. To test offline functionality:
1. Open DevTools → Application → Service Workers
2. Check "Offline" to simulate offline mode
3. Refresh the page to see cached content

## Deployment

This project is deployed using **GitHub Pages**:
- Repository: [uzorgame/CurrencyConverter-Web](https://github.com/uzorgame/CurrencyConverter-Web)
- Branch: `main`
- Source: Root directory

## Related Projects

- **Currency Converter+ Mobile App**: The original Flutter application
- **UzorGame Website**: [https://uzorgame.github.io/](https://uzorgame.github.io/)

## License

© 2025 UzorGame. Made with precision.

## Credits

- **Exchange Rates API**: [Frankfurter](https://www.frankfurter.app/)
- **Chart Library**: [Chart.js](https://www.chartjs.org/)
- **Flag Images**: [FlagCDN](https://flagcdn.com/)

---

**Made with precision by UzorGame**


