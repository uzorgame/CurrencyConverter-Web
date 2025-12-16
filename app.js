// Constants
const API_BASE_URL = 'https://api.frankfurter.dev/v1';
const DEFAULT_FROM_CURRENCY = 'CAD';
const DEFAULT_TO_CURRENCY = 'USD';

// Currency to flag mapping
const CURRENCY_TO_FLAG = {
    'AUD': 'au', 'BGN': 'bg', 'BRL': 'br', 'CAD': 'ca', 'CHF': 'ch',
    'CNY': 'cn', 'CZK': 'cz', 'DKK': 'dk', 'EUR': 'eu', 'GBP': 'gb',
    'HKD': 'hk', 'HUF': 'hu', 'IDR': 'id', 'ILS': 'il', 'INR': 'in',
    'ISK': 'is', 'JPY': 'jp', 'KRW': 'kr', 'MXN': 'mx', 'MYR': 'my',
    'NOK': 'no', 'NZD': 'nz', 'PHP': 'ph', 'PLN': 'pl', 'RON': 'ro',
    'SEK': 'se', 'SGD': 'sg', 'THB': 'th', 'TRY': 'tr', 'USD': 'us',
    'ZAR': 'za'
};

// Default currencies
const DEFAULT_CURRENCIES = [
    { code: 'AUD', name: 'Australian Dollar' },
    { code: 'BGN', name: 'Bulgarian Lev' },
    { code: 'BRL', name: 'Brazilian Real' },
    { code: 'CAD', name: 'Canadian Dollar' },
    { code: 'CHF', name: 'Swiss Franc' },
    { code: 'CNY', name: 'Chinese Renminbi Yuan' },
    { code: 'CZK', name: 'Czech Koruna' },
    { code: 'DKK', name: 'Danish Krone' },
    { code: 'EUR', name: 'Euro' },
    { code: 'GBP', name: 'British Pound' },
    { code: 'HKD', name: 'Hong Kong Dollar' },
    { code: 'HUF', name: 'Hungarian Forint' },
    { code: 'IDR', name: 'Indonesian Rupiah' },
    { code: 'ILS', name: 'Israeli New Sheqel' },
    { code: 'INR', name: 'Indian Rupee' },
    { code: 'ISK', name: 'Icelandic Króna' },
    { code: 'JPY', name: 'Japanese Yen' },
    { code: 'KRW', name: 'South Korean Won' },
    { code: 'MXN', name: 'Mexican Peso' },
    { code: 'MYR', name: 'Malaysia Ringgit' },
    { code: 'NOK', name: 'Norwegian Krone' },
    { code: 'NZD', name: 'New Zealand Dollar' },
    { code: 'PHP', name: 'Philippine Peso' },
    { code: 'PLN', name: 'Polish Złoty' },
    { code: 'RON', name: 'Romanian Leu' },
    { code: 'SEK', name: 'Swedish Krona' },
    { code: 'SGD', name: 'Singapore Dollar' },
    { code: 'THB', name: 'Thai Baht' },
    { code: 'TRY', name: 'Turkish Lira' },
    { code: 'USD', name: 'United States Dollar' },
    { code: 'ZAR', name: 'South African Rand' }
];

// App Strings
const APP_STRINGS = {
    'EN': {
        'appTitle': 'Currency Converter+',
        'settingsTitle': 'Settings',
        'language': 'Language',
        'currenciesTitle': 'Currencies',
        'favorites': 'Favorites',
        'searchHint': 'Search',
        'ok': 'OK',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'DE': {
        'appTitle': 'Währungsrechner+',
        'settingsTitle': 'Einstellungen',
        'language': 'Sprache',
        'currenciesTitle': 'Währungen',
        'favorites': 'Favoriten',
        'searchHint': 'Suche',
        'ok': 'OK',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'FR': {
        'appTitle': 'Convertisseur de devises+',
        'settingsTitle': 'Paramètres',
        'language': 'Langue',
        'currenciesTitle': 'Devises',
        'favorites': 'Favoris',
        'searchHint': 'Recherche',
        'ok': 'OK',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'IT': {
        'appTitle': 'Convertitore di valuta+',
        'settingsTitle': 'Impostazioni',
        'language': 'Lingua',
        'currenciesTitle': 'Valute',
        'favorites': 'Preferiti',
        'searchHint': 'Cerca',
        'ok': 'OK',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'ES': {
        'appTitle': 'Convertidor de divisas+',
        'settingsTitle': 'Configuración',
        'language': 'Idioma',
        'currenciesTitle': 'Monedas',
        'favorites': 'Favoritos',
        'searchHint': 'Buscar',
        'ok': 'OK',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'RU': {
        'appTitle': 'Конвертер валют+',
        'settingsTitle': 'Настройки',
        'language': 'Язык',
        'currenciesTitle': 'Валюты',
        'favorites': 'Избранное',
        'searchHint': 'Поиск',
        'ok': 'ОК',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy',
        'chartNoDataTitle': 'Not enough data to display the chart.',
        'chartNoDataSubtitle': 'Try a different period.'
    },
    'UK': {
        'appTitle': 'Конвертер валют',
        'settingsTitle': 'Налаштування',
        'language': 'Мова',
        'currenciesTitle': 'Валюти',
        'favorites': 'Вибрані',
        'searchHint': 'Пошук',
        'ok': 'ОК',
        'about': 'About',
        'privacyPolicy': 'Privacy Policy',
        'aboutCompany': 'UzorGame',
        'versionLabel': 'Version 1.1.5+15',
        'privacyDeveloper': 'Developer: UzorGame',
        'privacyNoData': 'No Data Collection.\n\nThe app does not collect, store, or track any personal data. We use no ads, no analytics, and require no user accounts.',
        'privacyNetworkUse': 'Network Use (API).\n\nThe app connects to the Frankfurter API to fetch live currency rates. This connection is ephemeral: technical data (such as an IP address) is used only to complete the request and is not retained or logged for user tracking purposes.',
        'privacyLocalStorage': 'Local Storage.\n\nAll application settings and favorite lists are stored exclusively locally on your device. This local data is never backed up or transmitted by us and is deleted upon uninstallation.',
        'privacySecurity': 'Security.\n\nAll communication is secured via HTTPS.',
        'privacyFullDetails': 'For the full version of the Privacy Policy, please visit the official website of the application.',
        'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
        'privacyPolicyButton': 'Privacy Policy'
    }
};

const LANGUAGE_NAMES = {
    'EN': 'English',
    'DE': 'Deutsch',
    'FR': 'Français',
    'IT': 'Italiano',
    'ES': 'Español',
    'RU': 'Русский',
    'UK': 'Українська'
};

// App State
class AppState {
    constructor() {
        this.fromCurrency = DEFAULT_FROM_CURRENCY;
        this.toCurrency = DEFAULT_TO_CURRENCY;
        this.fromAmount = '0';
        this.toAmount = '0';
        this.activeField = 'from'; // 'from' or 'to'
        this.rates = {};
        this.currencies = [];
        this.currencyNames = {};
        this.lastUpdated = null;
        this.language = this.getInitialLanguage();
        this.theme = this.getInitialTheme();
        this.loadState();
        this.applyTheme();
    }

    applyTheme() {
        document.documentElement.setAttribute('data-theme', this.theme);
        localStorage.setItem('theme', this.theme);
    }

    toggleTheme() {
        this.theme = this.theme === 'dark' ? 'light' : 'dark';
        this.applyTheme();
    }

    getInitialLanguage() {
        return 'EN'; // Always English
    }

    getInitialTheme() {
        const saved = localStorage.getItem('theme');
        return saved || 'dark'; // Default to dark
    }

    loadState() {
        const savedFrom = localStorage.getItem('lastFromCurrency');
        const savedTo = localStorage.getItem('lastToCurrency');
        const savedAmount = localStorage.getItem('lastAmount');
        
        if (savedFrom) this.fromCurrency = savedFrom;
        if (savedTo) this.toCurrency = savedTo;
        if (savedAmount) this.fromAmount = savedAmount;
    }

    saveState() {
        localStorage.setItem('lastFromCurrency', this.fromCurrency);
        localStorage.setItem('lastToCurrency', this.toCurrency);
        localStorage.setItem('lastAmount', this.fromAmount);
        // Favorites functionality removed
    }
}

// Currency API
class CurrencyAPI {
    async getLatestRates() {
        try {
            const response = await fetch(`${API_BASE_URL}/latest`);
            if (!response.ok) throw new Error('Failed to fetch rates');
            const data = await response.json();
            const rates = { ...data.rates, [data.base]: 1.0 };
            return { rates, date: new Date(data.date), base: data.base };
        } catch (error) {
            console.error('Error fetching rates:', error);
            throw error;
        }
    }

    async getCurrencies() {
        try {
            const response = await fetch(`${API_BASE_URL}/currencies`);
            if (!response.ok) throw new Error('Failed to fetch currencies');
            return await response.json();
        } catch (error) {
            console.error('Error fetching currencies:', error);
            return {};
        }
    }

    convert(from, to, amount, rates) {
        const fromRate = rates[from];
        const toRate = rates[to];
        if (!fromRate || !toRate || fromRate === 0) return 0;
        return amount * (toRate / fromRate);
    }

    async getHistoricalRates(base, target, days) {
        try {
            const endDate = new Date();
            const startDate = new Date();
            startDate.setDate(startDate.getDate() - days);
            
            const start = this.formatDate(startDate);
            const end = this.formatDate(endDate);
            const url = `${API_BASE_URL}/${start}..${end}?base=${base}&symbols=${target}`;
            
            console.log('Fetching historical rates from:', url);
            console.log('Date range:', { start, end, days });
            
            const response = await fetch(url, {
                method: 'GET',
                headers: {
                    'Accept': 'application/json',
                }
            });
            
            console.log('Response status:', response.status, response.statusText);
            
            if (!response.ok) {
                const errorText = await response.text();
                console.error('API Error:', response.status, errorText);
                throw new Error(`Failed to fetch historical rates: ${response.status} ${response.statusText}`);
            }
            
            const data = await response.json();
            console.log('API Response structure:', {
                hasRates: !!data.rates,
                ratesKeys: data.rates ? Object.keys(data.rates).length : 0,
                sampleRate: data.rates ? Object.keys(data.rates)[0] : null
            });
            
            if (!data.rates || typeof data.rates !== 'object') {
                console.warn('Invalid rates structure in response:', data);
                return [];
            }
            
            const ratesKeys = Object.keys(data.rates);
            if (ratesKeys.length === 0) {
                console.warn('No rates in response');
                return [];
            }
            
            const result = [];
            ratesKeys.forEach(dateString => {
                try {
                    const rateData = data.rates[dateString];
                    if (rateData && typeof rateData === 'object') {
                        const rateValue = rateData[target];
                        if (rateValue != null && rateValue !== undefined) {
                            const date = new Date(dateString);
                            if (isNaN(date.getTime())) {
                                console.warn('Invalid date:', dateString);
                                return;
                            }
                            const rate = parseFloat(rateValue);
                            if (isNaN(rate)) {
                                console.warn('Invalid rate value:', rateValue, 'for date:', dateString);
                                return;
                            }
                            result.push({
                                date: date,
                                rate: rate
                            });
                        } else {
                            console.warn('Rate value is null/undefined for', dateString, 'target:', target);
                        }
                    } else {
                        console.warn('Invalid rate data structure for', dateString, ':', rateData);
                    }
                } catch (e) {
                    console.warn('Error parsing rate for date:', dateString, e);
                }
            });
            
            result.sort((a, b) => a.date.getTime() - b.date.getTime());
            console.log(`Successfully loaded ${result.length} historical rates out of ${ratesKeys.length} dates`);
            
            if (result.length === 0) {
                console.warn('No valid rates extracted from response');
            }
            
            return result;
        } catch (error) {
            console.error('Error fetching historical rates:', error);
            if (error.message.includes('CORS')) {
                console.error('CORS error detected. API might not allow requests from this origin.');
            }
            throw error;
        }
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }
}

// Utility functions
function throttle(func, limit) {
    let inThrottle;
    return function(...args) {
        if (!inThrottle) {
            func.apply(this, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// Formatting functions
function formatAmount(value) {
    if (isNaN(value) || !isFinite(value)) return '0';
    const isNegative = value < 0;
    const absValue = Math.abs(value);
    
    // Always round to 2 decimal places
    const rounded = Math.round(absValue * 100) / 100;
    const fixed = rounded.toFixed(2);
    
    if (absValue < 1000) {
        const trimmed = trimTrailingZeros(fixed);
        return isNegative ? '-' + trimmed : trimmed;
    }
    
    // For large numbers, format integer part with thousand separators
    const parts = fixed.split('.');
    const integerPart = parseFloat(parts[0]);
    const decimalPart = parts[1];
    const formattedInteger = formatInteger(integerPart);
    return isNegative ? '-' + formattedInteger + '.' + decimalPart : formattedInteger + '.' + decimalPart;
}

function formatExchangeRate(rate) {
    if (isNaN(rate) || !isFinite(rate)) return '--';
    if (rate === 0) return '0.00';
    
    const formatted = rate.toFixed(4);
    if (!formatted.includes('.')) return formatted + '.00';
    
    const parts = formatted.split('.');
    let decimalPart = parts[1];
    
    while (decimalPart.length > 2 && decimalPart.endsWith('0')) {
        decimalPart = decimalPart.substring(0, decimalPart.length - 1);
    }
    
    if (decimalPart.length < 2) {
        decimalPart = decimalPart.padEnd(2, '0');
    }
    
    return parts[0] + '.' + decimalPart;
}

function trimTrailingZeros(value) {
    if (!value.includes('.')) return value;
    const parts = value.split('.');
    let decimalPart = parts[1];
    while (decimalPart.endsWith('0')) {
        decimalPart = decimalPart.substring(0, decimalPart.length - 1);
    }
    return decimalPart ? parts[0] + '.' + decimalPart : parts[0];
}

function formatInteger(value) {
    const isNegative = value < 0;
    const digits = Math.abs(value).toString().split('').reverse();
    const buffer = [];
    for (let i = 0; i < digits.length; i++) {
        if (i !== 0 && i % 3 === 0) buffer.push(',');
        buffer.push(digits[i]);
    }
    const formatted = buffer.reverse().join('');
    return isNegative ? '-' + formatted : formatted;
}

function formatDateTime(date) {
    if (!date) return '--';
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

// Flag rendering - using high-quality flags
function getFlagUrl(code) {
    if (code === 'EUR') {
        // EU flag with 12 stars in a circle - high quality SVG
        const svg = `<svg width="160" height="160" viewBox="0 0 160 160" xmlns="http://www.w3.org/2000/svg">
            <rect width="160" height="160" fill="#003399"/>
            <g fill="#FFCC00">
                ${Array.from({length: 12}, (_, i) => {
                    const angle = (i * 30 - 90) * Math.PI / 180;
                    const cx = 80 + 60.8 * Math.cos(angle);
                    const cy = 80 + 60.8 * Math.sin(angle);
                    return `<circle cx="${cx}" cy="${cy}" r="9.6"/>`;
                }).join('')}
            </g>
        </svg>`;
        return 'data:image/svg+xml;base64,' + btoa(svg);
    }
    const flagCode = CURRENCY_TO_FLAG[code];
    if (!flagCode) return null;
    // Using higher quality flags - w160 for better quality, or w80 for balance
    return `https://flagcdn.com/w160/${flagCode}.png`;
}

function renderFlag(element, code) {
    const flagUrl = getFlagUrl(code);
    if (flagUrl) {
        element.style.backgroundImage = `url(${flagUrl})`;
        element.style.backgroundSize = 'cover';
        element.style.backgroundPosition = 'center';
    } else {
        element.style.background = '#555';
        element.style.backgroundImage = 'none';
    }
}

// Main App
class CurrencyConverterApp {
    constructor() {
        this.state = new AppState();
        this.api = new CurrencyAPI();
        this.initializeElements();
        
        // Check if all required elements exist
        if (!this.elements.chartCanvas) {
            console.error('Chart canvas element not found!');
        }
        
        this.attachEventListeners();
        this.loadCurrencies();
        this.loadRates();
        // Set initial input values
        this.elements.fromInput.value = this.state.fromAmount || '0';
        this.elements.toInput.value = this.state.toAmount || '0';
        this.updateUI();
        this.updateThemeIcon(); // Set initial theme icon
        // Load initial chart after a short delay to ensure everything is ready
        setTimeout(() => {
            this.loadChart(this.currentPeriod);
        }, 500);
    }

    initializeElements() {
        this.elements = {
            fromInput: document.getElementById('fromInput'),
            toInput: document.getElementById('toInput'),
            fromCode: document.getElementById('fromCode'),
            toCode: document.getElementById('toCode'),
            fromFlag: document.getElementById('fromFlag'),
            toFlag: document.getElementById('toFlag'),
            fromCurrencySelector: document.getElementById('fromCurrencySelector'),
            toCurrencySelector: document.getElementById('toCurrencySelector'),
            swapBtn: document.getElementById('swapBtn'),
            rateText: document.getElementById('rateText'),
            rateDate: document.getElementById('rateDate'),
            rateInfo: document.getElementById('rateInfo'),
            appTitle: document.getElementById('appTitle'),
            themeToggleBtn: document.getElementById('themeToggleBtn'),
            playStoreBtn: document.getElementById('playStoreBtn'),
            websiteBtn: document.getElementById('websiteBtn'),
            currencyPickerModal: document.getElementById('currencyPickerModal'),
            settingsModal: document.getElementById('settingsModal'),
            privacyModal: document.getElementById('privacyModal'),
            currencyList: document.getElementById('currencyList'),
            currencySearch: document.getElementById('currencySearch'),
            privacyContent: document.getElementById('privacyContent'),
            chartTitle: document.getElementById('chartTitle'),
            chartCanvas: document.getElementById('historyChart'),
            chartLoading: document.getElementById('chartLoading'),
            chartError: document.getElementById('chartError'),
            chartErrorTitle: document.getElementById('chartErrorTitle'),
            chartErrorSubtitle: document.getElementById('chartErrorSubtitle'),
            periodButtons: document.querySelectorAll('.period-btn'),
            // Selection elements removed - only tooltip on hover is used
            chartSelectionOverlay: null,
            chartChangeIndicator: null,
            changeValue: null,
            clearSelectionBtn: null,
            chartStats: null,
            statMin: null,
            statMax: null,
            statAvg: null,
            selectionHandleLeft: null,
            selectionHandleRight: null
        };
        this.chart = null;
        this.currentPeriod = '1y';
        this.historicalCache = {};
        this.cacheTTL = 5 * 60 * 1000; // 5 minutes
        this.currentRates = [];
        this.isSelecting = false;
        this.isDraggingHandle = false;
        this.draggingHandle = null;
        this.selectionStart = null;
        this.selectionEnd = null;
        this.selectionStartIndex = null;
        this.selectionEndIndex = null;
        this.currencyListVirtualized = false;
    }

    attachEventListeners() {
        // Currency selector clicks
        this.elements.fromCurrencySelector.addEventListener('click', () => {
            this.state.activeField = 'from';
            this.openCurrencyPicker();
        });
        this.elements.toCurrencySelector.addEventListener('click', () => {
            this.state.activeField = 'to';
            this.openCurrencyPicker();
        });

        // Input fields
        this.elements.fromInput.addEventListener('input', (e) => {
            this.state.activeField = 'from';
            this.handleInputChange(e.target.value, 'from');
        });
        this.elements.fromInput.addEventListener('focus', () => {
            this.state.activeField = 'from';
        });

        this.elements.toInput.addEventListener('input', (e) => {
            this.state.activeField = 'to';
            this.handleInputChange(e.target.value, 'to');
        });
        this.elements.toInput.addEventListener('focus', () => {
            this.state.activeField = 'to';
        });

        // Swap button
        this.elements.swapBtn.addEventListener('click', () => this.handleSwap());

        // Theme toggle button
        if (this.elements.themeToggleBtn) {
            this.elements.themeToggleBtn.addEventListener('click', () => {
                this.state.toggleTheme();
                this.updateThemeIcon();
                // Update chart colors if chart exists
                if (this.chart) {
                    const bgCard = getComputedStyle(document.documentElement).getPropertyValue('--bg-card').trim() || '#1E1E1E';
                    const textMain = getComputedStyle(document.documentElement).getPropertyValue('--text-main').trim() || '#F9F9F9';
                    const textMuted = getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim() || '#777777';
                    
                    if (this.chart.options.plugins.tooltip) {
                        this.chart.options.plugins.tooltip.backgroundColor = bgCard;
                        this.chart.options.plugins.tooltip.titleColor = textMain;
                        this.chart.options.plugins.tooltip.bodyColor = textMain;
                    }
                    if (this.chart.options.scales && this.chart.options.scales.y && this.chart.options.scales.y.ticks) {
                        this.chart.options.scales.y.ticks.color = textMuted;
                    }
                    if (this.chart.options.scales && this.chart.options.scales.x && this.chart.options.scales.x.ticks) {
                        this.chart.options.scales.x.ticks.color = textMuted;
                    }
                    this.chart.update('none');
                }
            });
        }
        
        // Header buttons - links are handled by HTML href attributes

        // Modal close buttons
        document.getElementById('closePickerBtn').addEventListener('click', () => this.closeModal('currencyPickerModal'));
        document.getElementById('closeSettingsBtn').addEventListener('click', () => this.closeModal('settingsModal'));
        document.getElementById('closePrivacyBtn').addEventListener('click', () => this.closeModal('privacyModal'));

        // Settings items
        document.getElementById('themeItem').addEventListener('click', () => {
            this.state.toggleTheme();
            // Update chart colors if chart exists
            if (this.chart) {
                // Update chart options with new theme colors
                const bgCard = getComputedStyle(document.documentElement).getPropertyValue('--bg-card').trim() || '#1E1E1E';
                const textMain = getComputedStyle(document.documentElement).getPropertyValue('--text-main').trim() || '#F9F9F9';
                const textMuted = getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim() || '#777777';
                
                if (this.chart.options.plugins.tooltip) {
                    this.chart.options.plugins.tooltip.backgroundColor = bgCard;
                    this.chart.options.plugins.tooltip.titleColor = textMain;
                    this.chart.options.plugins.tooltip.bodyColor = textMain;
                }
                if (this.chart.options.scales && this.chart.options.scales.y && this.chart.options.scales.y.ticks) {
                    this.chart.options.scales.y.ticks.color = textMuted;
                }
                if (this.chart.options.scales && this.chart.options.scales.x && this.chart.options.scales.x.ticks) {
                    this.chart.options.scales.x.ticks.color = textMuted;
                }
                this.chart.update('none'); // Update chart without animation
            }
        });
        document.getElementById('privacyItem').addEventListener('click', () => this.openPrivacy());

        // Currency search
        this.elements.currencySearch.addEventListener('input', (e) => this.filterCurrencies(e.target.value));

        // Period buttons
        this.elements.periodButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const period = btn.dataset.period;
                this.selectPeriod(period);
            });
        });

        // Clear selection button - removed (selection functionality disabled)

        // Close modals on backdrop click
        document.querySelectorAll('.modal').forEach(modal => {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    this.closeModal(modal.id);
                }
            });
        });
    }

    async loadRates() {
        try {
            const { rates, date } = await this.api.getLatestRates();
            this.state.rates = rates;
            this.state.lastUpdated = date;
            // Cache rates
            localStorage.setItem('cachedRates', JSON.stringify({
                rates,
                date: date.toISOString()
            }));
            // Recalculate amounts after rates are loaded
            if (this.state.activeField === 'from' || !this.state.activeField) {
                this.recalculateToAmount();
            } else {
                this.recalculateFromAmount();
            }
            this.updateUI();
        } catch (error) {
            console.error('Failed to load rates:', error);
            // Use cached rates if available
            const cached = localStorage.getItem('cachedRates');
            if (cached) {
                try {
                    const data = JSON.parse(cached);
                    this.state.rates = data.rates;
                    this.state.lastUpdated = new Date(data.date);
                    // Recalculate amounts after rates are loaded
                    if (this.state.activeField === 'from' || !this.state.activeField) {
                        this.recalculateToAmount();
                    } else {
                        this.recalculateFromAmount();
                    }
                    this.updateUI();
                } catch (e) {
                    console.error('Failed to load cached rates:', e);
                }
            }
        }
    }

    async loadCurrencies() {
        try {
            const currencyNames = await this.api.getCurrencies();
            this.state.currencyNames = currencyNames;
            this.state.currencies = Object.keys(currencyNames).sort();
        } catch (error) {
            console.error('Failed to load currencies:', error);
            // Use default currencies
            this.state.currencies = DEFAULT_CURRENCIES.map(c => c.code);
            this.state.currencyNames = {};
            DEFAULT_CURRENCIES.forEach(c => {
                this.state.currencyNames[c.code] = c.name;
            });
        }
    }

    computeRate(from, to) {
        if (!this.state.rates || Object.keys(this.state.rates).length === 0) return null;
        const fromRate = this.state.rates[from];
        const toRate = this.state.rates[to];
        if (!fromRate || !toRate || fromRate === 0) return null;
        return toRate / fromRate;
    }

    parseInputValue(value) {
        if (!value || value === '') return 0;
        value = value.replace(/,/g, '');
        if (value.endsWith('.')) {
            value = value.substring(0, value.length - 1);
        }
        const parsed = parseFloat(value);
        return isNaN(parsed) ? 0 : parsed;
    }

    formatInputValue(value) {
        if (value === '' || value === null || value === undefined) return '';
        const num = this.parseInputValue(value);
        if (num === 0 && value !== '0' && !value.includes('.')) return '';
        return formatAmount(num).replace(/,/g, '');
    }

    handleInputChange(value, field) {
        // Allow empty string, numbers, and decimal point
        const sanitized = value.replace(/[^0-9.]/g, '');
        
        // Prevent multiple decimal points
        const parts = sanitized.split('.');
        let cleaned = parts[0];
        if (parts.length > 1) {
            cleaned += '.' + parts.slice(1).join('');
        }
        if (parts.length > 2) {
            cleaned = parts[0] + '.' + parts.slice(1, 2).join('');
        }

        if (field === 'from') {
            this.state.fromAmount = cleaned;
            this.recalculateToAmount();
        } else {
            this.state.toAmount = cleaned;
            this.recalculateFromAmount();
        }
        
        this.state.saveState();
        this.updateUI();
    }

    recalculateToAmount() {
        try {
            const rate = this.computeRate(this.state.fromCurrency, this.state.toCurrency);
            const fromValue = this.parseInputValue(this.state.fromAmount);
            if (!rate || isNaN(rate) || !isFinite(rate)) {
                this.state.toAmount = '0';
            } else {
                const result = fromValue * rate;
                if (isNaN(result) || !isFinite(result)) {
                    this.state.toAmount = '0';
                } else {
                    const newValue = formatAmount(result).replace(/,/g, '');
                    if (this.state.toAmount !== newValue) {
                        this.animateValue(this.elements.toInput);
                    }
                    this.state.toAmount = newValue;
                }
            }
        } catch (e) {
            this.state.toAmount = '0';
        }
    }

    recalculateFromAmount() {
        try {
            const rate = this.computeRate(this.state.fromCurrency, this.state.toCurrency);
            const toValue = this.parseInputValue(this.state.toAmount);
            if (!rate || isNaN(rate) || !isFinite(rate) || rate === 0) {
                this.state.fromAmount = '0';
            } else {
                const result = toValue / rate;
                if (isNaN(result) || !isFinite(result)) {
                    this.state.fromAmount = '0';
                } else {
                    const newValue = formatAmount(result).replace(/,/g, '');
                    if (this.state.fromAmount !== newValue) {
                        this.animateValue(this.elements.fromInput);
                    }
                    this.state.fromAmount = newValue;
                }
            }
        } catch (e) {
            this.state.fromAmount = '0';
        }
    }

    animateValue(element) {
        element.classList.add('animating');
        setTimeout(() => {
            element.classList.remove('animating');
        }, 300);
    }

    handleSwap() {
        const tempCurrency = this.state.fromCurrency;
        this.state.fromCurrency = this.state.toCurrency;
        this.state.toCurrency = tempCurrency;

        const tempAmount = this.state.fromAmount;
        this.state.fromAmount = this.state.toAmount;
        this.state.toAmount = tempAmount;

        // Clear chart cache for new currency pair
        this.historicalCache = {};

        this.state.saveState();
        this.updateUI();
    }

    openCurrencyPicker() {
        this.renderCurrencyList();
        this.openModal('currencyPickerModal');
    }

    openSettings() {
        this.updateSettingsUI();
        this.openModal('settingsModal');
    }

    openPrivacy() {
        this.closeModal('settingsModal');
        this.updatePrivacyUI();
        this.openModal('privacyModal');
    }

    openModal(modalId) {
        document.getElementById(modalId).classList.add('show');
    }

    closeModal(modalId) {
        document.getElementById(modalId).classList.remove('show');
    }

    filterCurrencies(query) {
        this.renderCurrencyList(query.toLowerCase());
    }

    renderCurrencyList(searchQuery = '') {
        const availableCurrencies = this.state.currencies.map(code => ({
            code,
            name: this.state.currencyNames[code] || code
        })).sort((a, b) => a.code.localeCompare(b.code));

        const filtered = searchQuery
            ? availableCurrencies.filter(c => 
                c.name.toLowerCase().includes(searchQuery) || 
                c.code.toLowerCase().includes(searchQuery)
            )
            : availableCurrencies;

        // Virtualization for large lists
        const allCurrencies = filtered;
        const ITEMS_PER_BATCH = 50;
        let html = '';
        
        const currenciesToShow = allCurrencies.slice(0, ITEMS_PER_BATCH);
        currenciesToShow.forEach(currency => {
            html += this.renderCurrencyItem(currency);
        });

        this.elements.currencyList.innerHTML = html;
        
        // Lazy load remaining items if needed
        if (allCurrencies.length > ITEMS_PER_BATCH) {
            this.setupLazyLoading(allCurrencies, ITEMS_PER_BATCH, 0);
        }

        // Attach event listeners
        this.elements.currencyList.querySelectorAll('.currency-item').forEach(item => {
            const code = item.dataset.code;
            item.addEventListener('click', () => {
                this.selectCurrency(code);
            });
        });

        // Favorite button functionality removed
    }

    renderCurrencyItem(currency) {
        const flagUrl = getFlagUrl(currency.code);
        const flagStyle = flagUrl 
            ? `background-image: url(${flagUrl}); background-size: cover; background-position: center;`
            : 'background: #555;';
        
        return `
            <div class="currency-item" data-code="${currency.code}">
                <div class="currency-item-flag" style="${flagStyle}"></div>
                <div class="currency-item-info">
                    <div class="currency-item-code">${currency.code}</div>
                    <div class="currency-item-name">${currency.name}</div>
                </div>
            </div>
        `;
    }

    selectCurrency(code) {
        if (this.state.activeField === 'from') {
            this.state.fromCurrency = code;
            this.recalculateToAmount();
        } else {
            this.state.toCurrency = code;
            this.recalculateFromAmount();
        }
        // Clear chart cache for new currency pair
        this.historicalCache = {};
        this.state.saveState();
        this.updateUI();
        this.closeModal('currencyPickerModal');
    }


    updateSettingsUI() {
        document.getElementById('settingsTitle').textContent = this.getString('settingsTitle');
        document.getElementById('themeLabel').textContent = 'Theme';
        document.getElementById('currentTheme').textContent = this.theme === 'dark' ? 'Dark' : 'Light';
        document.getElementById('privacyLabel').textContent = this.getString('privacyPolicy');
    }

    updateThemeIcon() {
        if (!this.elements.themeToggleBtn) return;
        const sunIcon = this.elements.themeToggleBtn.querySelector('.theme-icon-sun');
        const moonIcon = this.elements.themeToggleBtn.querySelector('.theme-icon-moon');
        
        if (sunIcon && moonIcon) {
            if (this.state.theme === 'dark') {
                sunIcon.style.display = 'block';
                moonIcon.style.display = 'none';
            } else {
                sunIcon.style.display = 'none';
                moonIcon.style.display = 'block';
            }
        }
    }

    updatePrivacyUI() {
        document.getElementById('privacyTitle').textContent = this.getString('privacyPolicy');
        const content = `
            <p><strong>${this.getString('privacyDeveloper')}</strong></p>
            <p>${this.getString('privacyNoData').replace(/\n/g, '<br>')}</p>
            <p>${this.getString('privacyNetworkUse').replace(/\n/g, '<br>')}</p>
            <p>${this.getString('privacyLocalStorage').replace(/\n/g, '<br>')}</p>
            <p>${this.getString('privacySecurity').replace(/\n/g, '<br>')}</p>
            <p>${this.getString('privacyFullDetails')}</p>
        `;
        this.elements.privacyContent.innerHTML = content;
    }

    getString(key) {
        return APP_STRINGS['EN'][key] || key;
    }

    updateUI() {
        // Update input values (only if they don't have focus to avoid cursor jumping)
        if (document.activeElement !== this.elements.fromInput) {
            this.elements.fromInput.value = this.state.fromAmount || '0';
        }
        if (document.activeElement !== this.elements.toInput) {
            this.elements.toInput.value = this.state.toAmount || '0';
        }

        // Update currency codes
        this.elements.fromCode.textContent = this.state.fromCurrency;
        this.elements.toCode.textContent = this.state.toCurrency;

        // Update flags
        renderFlag(this.elements.fromFlag, this.state.fromCurrency);
        renderFlag(this.elements.toFlag, this.state.toCurrency);

        // Update rate text
        const rate = this.computeRate(this.state.fromCurrency, this.state.toCurrency);
        if (!rate) {
            this.elements.rateText.textContent = `1 ${this.state.fromCurrency} = -- ${this.state.toCurrency}`;
        } else {
            this.elements.rateText.textContent = `1 ${this.state.fromCurrency} = ${formatExchangeRate(rate)} ${this.state.toCurrency}`;
        }

        // Update date
        if (this.state.lastUpdated) {
            this.elements.rateDate.textContent = formatDateTime(this.state.lastUpdated);
        } else {
            this.elements.rateDate.textContent = '--';
        }

        // Update title
        if (this.elements.appTitle) {
            this.elements.appTitle.textContent = this.getString('appTitle');
        }
        document.title = this.getString('appTitle');

        // Update search placeholder
        this.elements.currencySearch.placeholder = this.getString('searchHint');

        // Update chart title
        if (this.elements.chartTitle) {
            this.elements.chartTitle.textContent = `${this.state.fromCurrency} → ${this.state.toCurrency}`;
        }

        // Reload chart if currencies changed
        this.loadChart(this.currentPeriod);
    }

    selectPeriod(period) {
        this.currentPeriod = period;
        // Update active button
        this.elements.periodButtons.forEach(btn => {
            if (btn.dataset.period === period) {
                btn.classList.add('active');
            } else {
                btn.classList.remove('active');
            }
        });
        this.loadChart(period);
    }

    getPeriodDays(period) {
        switch (period) {
            case '1m': return 30;
            case '6m': return 180;
            case '1y': return 365;
            case '3y': return 1095;
            case '5y': return 1825;
            case '10y': return 3650;
            default: return 365;
        }
    }

    async loadChart(period) {
        const cacheKey = `${this.state.fromCurrency}-${this.state.toCurrency}-${period}`;
        
        // Show loading
        this.elements.chartLoading.style.display = 'block';
        this.elements.chartError.style.display = 'none';
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }

        try {
            // Check cache with TTL
            const cached = this.historicalCache[cacheKey];
            if (cached && cached.data && cached.timestamp) {
                const age = Date.now() - cached.timestamp;
                if (age < this.cacheTTL) {
                    console.log('Using cached data for', cacheKey);
                    this.renderChart(cached.data);
                    return;
                } else {
                    console.log('Cache expired for', cacheKey);
                    delete this.historicalCache[cacheKey];
                }
            }

            // Lazy load - show loading state immediately, then fetch
            const days = this.getPeriodDays(period);
            console.log(`Loading chart for ${this.state.fromCurrency}/${this.state.toCurrency}, period: ${period}, days: ${days}`);
            
            // Use requestIdleCallback if available for better performance
            const loadData = async () => {
                const rates = await this.api.getHistoricalRates(
                    this.state.fromCurrency,
                    this.state.toCurrency,
                    days
                );

                console.log('Received rates:', rates.length);

                if (rates.length === 0) {
                    console.warn('No rates received');
                    this.elements.chartLoading.style.display = 'none';
                    this.elements.chartError.style.display = 'block';
                    this.elements.chartErrorTitle.textContent = this.getString('chartNoDataTitle');
                    this.elements.chartErrorSubtitle.textContent = this.getString('chartNoDataSubtitle');
                    return;
                }

                // Cache the data with timestamp
                this.historicalCache[cacheKey] = {
                    data: rates,
                    timestamp: Date.now()
                };
                this.renderChart(rates);
            };

            if (window.requestIdleCallback) {
                requestIdleCallback(() => loadData(), { timeout: 1000 });
            } else {
                setTimeout(loadData, 0);
            }
        } catch (error) {
            console.error('Failed to load chart:', error);
            this.elements.chartLoading.style.display = 'none';
            this.elements.chartError.style.display = 'block';
            this.elements.chartErrorTitle.textContent = this.getString('chartNoDataTitle');
            this.elements.chartErrorSubtitle.textContent = this.getString('chartNoDataSubtitle');
        }
    }

    renderChart(rates) {
        console.log('Rendering chart with', rates.length, 'data points');
        
        if (!rates || rates.length === 0) {
            console.error('No data to render');
            this.elements.chartLoading.style.display = 'none';
            this.elements.chartError.style.display = 'block';
            return;
        }

        // Check if Chart.js is loaded
        if (typeof Chart === 'undefined') {
            console.error('Chart.js is not loaded!');
            this.elements.chartLoading.style.display = 'none';
            this.elements.chartError.style.display = 'block';
            this.elements.chartErrorTitle.textContent = 'Chart library not loaded';
            this.elements.chartErrorSubtitle.textContent = 'Please refresh the page';
            return;
        }

        this.elements.chartLoading.style.display = 'none';
        this.elements.chartError.style.display = 'none';
        
        // Store rates for selection calculation
        this.currentRates = rates;

        const labels = rates.map(r => {
            const date = r.date;
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${day}.${month}`;
        });

        const data = rates.map(r => r.rate);
        
        console.log('Chart data prepared:', { labels: labels.length, data: data.length });
        console.log('Sample data:', { firstLabel: labels[0], firstData: data[0], lastLabel: labels[labels.length - 1], lastData: data[data.length - 1] });

        // Calculate min/max with padding
        const minRate = Math.min(...data);
        const maxRate = Math.max(...data);
        const range = maxRate - minRate;
        const padding = Math.max(range * 0.02, 0.0001);
        const minY = minRate - padding;
        const maxY = maxRate + padding;

        const ctx = this.elements.chartCanvas.getContext('2d');
        if (!ctx) {
            console.error('Cannot get canvas context');
            return;
        }

        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }

        // Remove old event listeners
        const canvas = this.elements.chartCanvas;
        const newCanvas = canvas.cloneNode(true);
        canvas.parentNode.replaceChild(newCanvas, canvas);
        this.elements.chartCanvas = newCanvas;

        try {
            this.chart = new Chart(newCanvas.getContext('2d'), {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Rate',
                    data: data,
                    borderColor: '#D68D41',
                    backgroundColor: 'rgba(214, 141, 65, 0.25)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4,
                    pointRadius: 0,
                    pointHoverRadius: 4,
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: getComputedStyle(document.documentElement).getPropertyValue('--bg-card').trim() || '#1E1E1E',
                        padding: 16,
                        titleFont: {
                            size: 14,
                            weight: '700'
                        },
                        bodyFont: {
                            size: 14,
                            weight: '600'
                        },
                        titleColor: getComputedStyle(document.documentElement).getPropertyValue('--text-main').trim() || '#F9F9F9',
                        bodyColor: getComputedStyle(document.documentElement).getPropertyValue('--text-main').trim() || '#F9F9F9',
                        borderColor: '#D68D41',
                        borderWidth: 2,
                        borderRadius: 8,
                        displayColors: false,
                        callbacks: {
                            title: (items) => {
                                const index = items[0].dataIndex;
                                const date = rates[index].date;
                                const day = String(date.getDate()).padStart(2, '0');
                                const month = String(date.getMonth() + 1).padStart(2, '0');
                                const year = date.getFullYear();
                                const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                                const weekday = weekdays[date.getDay()];
                                return `${weekday}, ${day}.${month}.${year}`;
                            },
                            label: (item) => {
                                const index = item.dataIndex;
                                const rate = item.parsed.y;
                                const prevRate = index > 0 ? data[index - 1] : rate;
                                const change = rate - prevRate;
                                const changePercent = index > 0 ? ((change / prevRate) * 100).toFixed(2) : '0.00';
                                const changeSign = change >= 0 ? '+' : '';
                                return [
                                    `Rate: ${rate.toFixed(4)}`,
                                    index > 0 ? `Change: ${changeSign}${changePercent}%` : ''
                                ].filter(Boolean);
                            },
                            afterBody: (items) => {
                                const index = items[0].dataIndex;
                                if (index === 0) return '';
                                const currentRate = data[index];
                                const firstRate = data[0];
                                const totalChange = ((currentRate - firstRate) / firstRate * 100).toFixed(2);
                                const totalChangeSign = totalChange >= 0 ? '+' : '';
                                return `Total: ${totalChangeSign}${totalChange}%`;
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: false,
                        min: minY,
                        max: maxY,
                        ticks: {
                            color: getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim() || '#777777',
                            font: {
                                size: 12,
                                weight: '500'
                            },
                            callback: function(value) {
                                return value.toFixed(2);
                            }
                        },
                        grid: {
                            display: false
                        }
                    },
                    x: {
                        ticks: {
                            color: getComputedStyle(document.documentElement).getPropertyValue('--text-muted').trim() || '#777777',
                            font: {
                                size: 12,
                                weight: '600'
                            },
                            maxRotation: 0,
                            autoSkip: true,
                            maxTicksLimit: 6
                        },
                        grid: {
                            display: false
                        }
                    }
                },
                interaction: {
                    intersect: false,
                    mode: 'index'
                }
            }
        });
        console.log('Chart created successfully');
        
        } catch (error) {
            console.error('Error creating chart:', error);
            this.elements.chartLoading.style.display = 'none';
            this.elements.chartError.style.display = 'block';
            this.elements.chartErrorTitle.textContent = 'Error rendering chart';
            this.elements.chartErrorSubtitle.textContent = error.message || 'Unknown error';
        }
    }

    // Selection functionality removed - only tooltip on hover is used
    setupChartSelection() {
        // Disabled - selection removed per user request
        return;
        // Remove old event listeners if they exist
        if (this._globalMouseMoveHandler) {
            document.removeEventListener('mousemove', this._globalMouseMoveHandler);
        }
        if (this._globalMouseUpHandler) {
            document.removeEventListener('mouseup', this._globalMouseUpHandler);
        }
        if (this._globalTouchMoveHandler) {
            document.removeEventListener('touchmove', this._globalTouchMoveHandler);
        }
        if (this._globalTouchEndHandler) {
            document.removeEventListener('touchend', this._globalTouchEndHandler);
        }
        
        const canvas = this.elements.chartCanvas;
        const container = canvas.parentElement;
        const overlay = this.elements.chartSelectionOverlay;
        const handleLeft = this.elements.selectionHandleLeft;
        const handleRight = this.elements.selectionHandleRight;
        
        let startX = null;
        let currentX = null;
        let dragStartX = null;

        const getChartX = (clientX) => {
            const rect = canvas.getBoundingClientRect();
            return clientX - rect.left;
        };

        const getDataIndex = (canvasX) => {
            if (!this.chart || !this.currentRates.length) return -1;
            const chartArea = this.chart.chartArea;
            if (!chartArea) return -1;
            
            const chartWidth = chartArea.right - chartArea.left;
            const relativeX = canvasX - chartArea.left;
            const ratio = Math.max(0, Math.min(1, relativeX / chartWidth));
            const index = Math.round(ratio * (this.currentRates.length - 1));
            return Math.max(0, Math.min(this.currentRates.length - 1, index));
        };

        const updateSelection = () => {
            if (startX === null || currentX === null || !this.chart || !this.chart.chartArea) {
                // Hide selection if invalid
                overlay.style.display = 'none';
                if (handleLeft) handleLeft.style.display = 'none';
                if (handleRight) handleRight.style.display = 'none';
                this.elements.chartChangeIndicator.style.display = 'none';
                this.elements.chartStats.style.display = 'none';
                return;
            }

            const startIndex = getDataIndex(startX);
            const endIndex = getDataIndex(currentX);
            
            if (startIndex < 0 || endIndex < 0 || startIndex >= this.currentRates.length || endIndex >= this.currentRates.length) {
                // Hide selection if indices are invalid
                overlay.style.display = 'none';
                if (handleLeft) handleLeft.style.display = 'none';
                if (handleRight) handleRight.style.display = 'none';
                this.elements.chartChangeIndicator.style.display = 'none';
                this.elements.chartStats.style.display = 'none';
                return;
            }

            const minIndex = Math.min(startIndex, endIndex);
            const maxIndex = Math.max(startIndex, endIndex);

            this.selectionStartIndex = minIndex;
            this.selectionEndIndex = maxIndex;

            const startRate = this.currentRates[minIndex].rate;
            const endRate = this.currentRates[maxIndex].rate;
            
            const changePercent = ((endRate - startRate) / startRate) * 100;
            
            // Update overlay position relative to chart area
            const chartArea = this.chart.chartArea;
            const containerRect = container.getBoundingClientRect();
            const canvasRect = canvas.getBoundingClientRect();
            
            const leftOffset = canvasRect.left - containerRect.left + chartArea.left;
            const left = Math.min(startX, currentX) - chartArea.left;
            const right = Math.max(startX, currentX) - chartArea.left;
            const width = right - left;
            
            if (width > 0 && left >= 0 && left + width <= chartArea.right - chartArea.left) {
                overlay.style.display = 'block';
                overlay.style.left = `${leftOffset + left}px`;
                overlay.style.width = `${width}px`;
                
                // Update handle positions
                if (handleLeft && handleRight) {
                    handleLeft.style.left = `${leftOffset + left - 2}px`;
                    handleLeft.style.display = 'block';
                    handleRight.style.left = `${leftOffset + right - 2}px`;
                    handleRight.style.display = 'block';
                }
            } else {
                // Hide handles if selection is invalid
                if (handleLeft) handleLeft.style.display = 'none';
                if (handleRight) handleRight.style.display = 'none';
            }

            // Update indicator
            this.elements.chartChangeIndicator.style.display = 'flex';
            const valueElement = this.elements.changeValue;
            valueElement.textContent = `${changePercent >= 0 ? '+' : ''}${changePercent.toFixed(2)}%`;
            valueElement.className = 'change-value ' + (changePercent >= 0 ? 'positive' : 'negative');
            
            // Update stats
            this.updateChartStats(minIndex, maxIndex);
        };

        const getChartXFromTouch = (touch) => {
            const rect = canvas.getBoundingClientRect();
            return touch.clientX - rect.left;
        };

        const handleStart = (x) => {
            const chartArea = this.chart?.chartArea;
            if (!chartArea) return false;
            // x is relative to canvas, chartArea is also relative to canvas
            if (x < chartArea.left || x > chartArea.right) return false;
            
            // Check if clicking on a handle
            if (this.selectionStart !== null && this.selectionEnd !== null) {
                const leftPos = Math.min(this.selectionStart, this.selectionEnd);
                const rightPos = Math.max(this.selectionStart, this.selectionEnd);
                const handleSize = 15;
                
                if (Math.abs(x - leftPos) < handleSize) {
                    this.isDraggingHandle = true;
                    this.draggingHandle = 'left';
                    dragStartX = x;
                    return true;
                } else if (Math.abs(x - rightPos) < handleSize) {
                    this.isDraggingHandle = true;
                    this.draggingHandle = 'right';
                    dragStartX = x;
                    return true;
                }
            }
            
            startX = x;
            currentX = x;
            this.isSelecting = true;
            return true;
        };

        const handleMove = (x) => {
            if (this.isDraggingHandle && this.draggingHandle && this.selectionStart !== null && this.selectionEnd !== null) {
                const chartArea = this.chart.chartArea;
                const deltaX = x - dragStartX;
                
                if (this.draggingHandle === 'left') {
                    const newStartX = Math.min(this.selectionStart, this.selectionEnd) + deltaX;
                    if (newStartX >= chartArea.left && newStartX < Math.max(this.selectionStart, this.selectionEnd)) {
                        startX = newStartX;
                    }
                } else {
                    const newEndX = Math.max(this.selectionStart, this.selectionEnd) + deltaX;
                    if (newEndX <= chartArea.right && newEndX > Math.min(this.selectionStart, this.selectionEnd)) {
                        currentX = newEndX;
                    }
                }
                dragStartX = x;
            } else if (this.isSelecting) {
                currentX = x;
            } else {
                return;
            }
            updateSelection();
        };

        const handleEnd = () => {
            if (this.isSelecting || this.isDraggingHandle) {
                this.selectionStart = startX;
                this.selectionEnd = currentX;
            }
            this.isSelecting = false;
            this.isDraggingHandle = false;
            this.draggingHandle = null;
            dragStartX = null;
        };

        const handleMouseDown = (e) => {
            if (e.button !== 0) return;
            const x = getChartX(e.clientX);
            if (handleStart(x)) {
                updateSelection();
                e.preventDefault();
                e.stopPropagation();
            }
        };

        const handleMouseMoveThrottled = throttle((e) => {
            const x = getChartX(e.clientX);
            handleMove(x);
            e.preventDefault();
        }, 16);
        
        const handleMouseMove = handleMouseMoveThrottled;

        const handleMouseUp = (e) => {
            handleEnd();
        };

        // Touch events
        const handleTouchStart = (e) => {
            if (e.touches.length !== 1) return;
            const x = getChartXFromTouch(e.touches[0]);
            if (handleStart(x)) {
                updateSelection();
                e.preventDefault();
            }
        };

        const handleTouchMoveThrottled = throttle((e) => {
            if (e.touches.length !== 1) return;
            const x = getChartXFromTouch(e.touches[0]);
            handleMove(x);
            e.preventDefault();
        }, 16);
        
        const handleTouchMove = handleTouchMoveThrottled;

        const handleTouchEnd = (e) => {
            handleEnd();
            e.preventDefault();
        };

        const handleMouseLeave = () => {
            if (this.isSelecting || this.isDraggingHandle) {
                handleEnd();
            }
        };
        
        // Double click handler removed (selection disabled)

        canvas.addEventListener('mousedown', handleMouseDown);
        canvas.addEventListener('mousemove', handleMouseMove);
        this._globalMouseUpHandler = handleMouseUp;
        document.addEventListener('mouseup', this._globalMouseUpHandler);
        container.addEventListener('mouseleave', handleMouseLeave);
        
        // Touch events
        canvas.addEventListener('touchstart', handleTouchStart, { passive: false });
        canvas.addEventListener('touchmove', handleTouchMove, { passive: false });
        canvas.addEventListener('touchend', handleTouchEnd, { passive: false });
        
        // Handle dragging for handles
        if (handleLeft) {
            handleLeft.addEventListener('mousedown', (e) => {
                e.stopPropagation();
                this.isDraggingHandle = true;
                this.draggingHandle = 'left';
                dragStartX = getChartX(e.clientX);
                this.selectionStart = startX;
                this.selectionEnd = currentX;
            });
            
            handleLeft.addEventListener('touchstart', (e) => {
                e.stopPropagation();
                this.isDraggingHandle = true;
                this.draggingHandle = 'left';
                dragStartX = getChartXFromTouch(e.touches[0]);
                this.selectionStart = startX;
                this.selectionEnd = currentX;
            });
        }
        
        if (handleRight) {
            handleRight.addEventListener('mousedown', (e) => {
                e.stopPropagation();
                this.isDraggingHandle = true;
                this.draggingHandle = 'right';
                dragStartX = getChartX(e.clientX);
                this.selectionStart = startX;
                this.selectionEnd = currentX;
            });
            
            handleRight.addEventListener('touchstart', (e) => {
                e.stopPropagation();
                this.isDraggingHandle = true;
                this.draggingHandle = 'right';
                dragStartX = getChartXFromTouch(e.touches[0]);
                this.selectionStart = startX;
                this.selectionEnd = currentX;
            });
        }
        
        // Handle touch move for handles
        const handleTouchMoveForHandles = throttle((e) => {
            if (this.isDraggingHandle && e.touches.length === 1) {
                const x = getChartXFromTouch(e.touches[0]);
                handleMove(x);
                e.preventDefault();
            }
        }, 16);
        
        this._globalTouchMoveHandler = handleTouchMoveForHandles;
        document.addEventListener('touchmove', this._globalTouchMoveHandler, { passive: false });
        
        const handleGlobalTouchEnd = (e) => {
            if (this.isDraggingHandle) {
                handleEnd();
            }
        };
        this._globalTouchEndHandler = handleGlobalTouchEnd;
        document.addEventListener('touchend', this._globalTouchEndHandler, { passive: false });
        
        // Global mouse move for handle dragging
        const handleGlobalMouseMove = throttle((e) => {
            if (this.isDraggingHandle) {
                const x = getChartX(e.clientX);
                handleMove(x);
            }
        }, 16);
        
        this._globalMouseMoveHandler = handleGlobalMouseMove;
        document.addEventListener('mousemove', this._globalMouseMoveHandler);
        
        // Prevent context menu on right click
        canvas.addEventListener('contextmenu', (e) => e.preventDefault());
    }

    setupLazyLoading(allCurrencies, startIndex) {
        const ITEMS_PER_BATCH = 50;
        let currentIndex = startIndex;
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting && currentIndex < allCurrencies.length) {
                    const batch = allCurrencies.slice(currentIndex, currentIndex + ITEMS_PER_BATCH);
                    const fragment = document.createDocumentFragment();
                    batch.forEach(currency => {
                        const div = document.createElement('div');
                        div.innerHTML = this.renderCurrencyItem(currency);
                        fragment.appendChild(div.firstElementChild);
                    });
                    this.elements.currencyList.insertBefore(fragment, entry.target);
                    currentIndex += ITEMS_PER_BATCH;
                    if (currentIndex >= allCurrencies.length) {
                        observer.disconnect();
                        entry.target.remove();
                    }
                }
            });
        }, { rootMargin: '100px' });
        
        const sentinel = document.createElement('div');
        sentinel.style.height = '1px';
        this.elements.currencyList.appendChild(sentinel);
        observer.observe(sentinel);
    }

    clearSelection() {
        // Selection functionality removed - this method is kept for compatibility
        if (this.elements.chartSelectionOverlay) {
            this.elements.chartSelectionOverlay.style.display = 'none';
        }
        if (this.elements.chartChangeIndicator) {
            this.elements.chartChangeIndicator.style.display = 'none';
        }
        if (this.elements.chartStats) {
            this.elements.chartStats.style.display = 'none';
        }
        if (this.elements.selectionHandleLeft) {
            this.elements.selectionHandleLeft.style.display = 'none';
        }
        if (this.elements.selectionHandleRight) {
            this.elements.selectionHandleRight.style.display = 'none';
        }
        this.selectionStart = null;
        this.selectionEnd = null;
        this.selectionStartIndex = null;
        this.selectionEndIndex = null;
        this.isSelecting = false;
        this.isDraggingHandle = false;
        this.draggingHandle = null;
    }

    updateChartStats(startIndex, endIndex) {
        if (startIndex === null || endIndex === null || !this.currentRates.length) return;
        
        const minIndex = Math.min(startIndex, endIndex);
        const maxIndex = Math.max(startIndex, endIndex);
        const selectedRates = this.currentRates.slice(minIndex, maxIndex + 1).map(r => r.rate);
        
        const min = Math.min(...selectedRates);
        const max = Math.max(...selectedRates);
        const avg = selectedRates.reduce((a, b) => a + b, 0) / selectedRates.length;
        
        this.elements.statMin.textContent = min.toFixed(4);
        this.elements.statMax.textContent = max.toFixed(4);
        this.elements.statAvg.textContent = avg.toFixed(4);
        this.elements.chartStats.style.display = 'grid';
    }
}

// Register Service Worker
if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/sw.js', { updateViaCache: 'none' })
                .then((registration) => {
                    console.log('ServiceWorker registered:', registration.scope);
                    
                    // Check for updates periodically
                    setInterval(() => {
                        registration.update();
                    }, 60000); // Check every minute
                    
                    // Check for updates on page focus
                    window.addEventListener('focus', () => {
                        registration.update();
                    });
                    
                    // Listen for new service worker
                    registration.addEventListener('updatefound', () => {
                        const newWorker = registration.installing;
                        newWorker.addEventListener('statechange', () => {
                            if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                                // New service worker available, reload page
                                console.log('New service worker available, reloading...');
                                window.location.reload();
                            }
                        });
                    });
                })
                .catch((error) => {
                    console.log('ServiceWorker registration failed:', error);
                });
        }
    });
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    // Check if Chart.js is loaded
    if (typeof Chart === 'undefined') {
        console.error('Chart.js library is not loaded! Please check the CDN link.');
        // Try to load it manually
        const script = document.createElement('script');
        script.src = 'https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js';
        script.onload = () => {
            console.log('Chart.js loaded successfully');
            window.app = new CurrencyConverterApp();
        };
        script.onerror = () => {
            console.error('Failed to load Chart.js from CDN');
            alert('Failed to load chart library. Please check your internet connection.');
        };
        document.head.appendChild(script);
    } else {
        console.log('Chart.js is already loaded');
        window.app = new CurrencyConverterApp();
    }
});

