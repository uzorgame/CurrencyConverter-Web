import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/currency.dart';
import '../providers/currency_provider.dart';
import '../widgets/currency_picker/currency_tile.dart';
import '../widgets/currency_picker/favorites_header.dart';
import '../widgets/currency_picker/picker_header.dart';
import '../widgets/currency_picker/search_field.dart';

class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({
    super.key,
    required this.initialCode,
    required this.currencies,
    required this.language,
  });

  final String initialCode;
  final List<Currency> currencies;
  final String language;

  @override
  State<CurrencyPickerPage> createState() => _CurrencyPickerPageState();
}

class _CurrencyPickerPageState extends State<CurrencyPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Currency> _filteredCurrencies;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.of(widget.currencies);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final language = widget.language;
    final favoriteCodes = currencyProvider.favoriteCurrencies.toSet();

    final favoriteCurrencies = _filteredCurrencies
        .where((currency) => favoriteCodes.contains(currency.code))
        .toList();
    final otherCurrencies = _filteredCurrencies
        .where((currency) => !favoriteCodes.contains(currency.code))
        .toList();

    final tiles = <Widget>[
      if (favoriteCurrencies.isNotEmpty) ...[
        FavoritesHeader(language: language),
        const SizedBox(height: 10),
        ..._buildTiles(favoriteCurrencies, currencyProvider),
        if (otherCurrencies.isNotEmpty) const SizedBox(height: 16),
      ],
      ..._buildTiles(otherCurrencies, currencyProvider),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            PickerHeader(
              language: language,
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: SearchField(
                controller: _searchController,
                language: language,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                itemBuilder: (context, index) => tiles[index],
                itemCount: tiles.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = List.of(widget.currencies);
      } else {
        _filteredCurrencies = widget.currencies.where((currency) {
          final name = currency.name.toLowerCase();
          final code = currency.code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  List<Widget> _buildTiles(
    List<Currency> currencies,
    CurrencyProvider provider,
  ) {
    return List.generate(currencies.length, (index) {
      final currency = currencies[index];
      final isFavorite = provider.isFavorite(currency.code);
      return Padding(
        padding: EdgeInsets.only(bottom: index == currencies.length - 1 ? 0 : 10),
        child: CurrencyTile(
          currency: currency,
          isFavorite: isFavorite,
          onTap: () => Navigator.of(context).pop(currency.code),
          onFavoriteToggle: () => provider.toggleFavorite(currency.code),
        ),
      );
    });
  }
}
