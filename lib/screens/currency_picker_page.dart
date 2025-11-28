part of 'main.dart';

class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({
    required this.initialCode,
    required this.currencies,
    required this.language,
    super.key,
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
        _FavoritesHeader(language: language),
        const SizedBox(height: 10),
        ..._buildTiles(favoriteCurrencies, currencyProvider),
        if (otherCurrencies.isNotEmpty) const SizedBox(height: 16),
      ],
      ..._buildTiles(otherCurrencies, currencyProvider),
    ];

    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _PickerHeader(
              language: language,
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: _SearchField(
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
        child: _CurrencyTile(
          currency: currency,
          isFavorite: isFavorite,
          onTap: () => Navigator.of(context).pop(currency.code),
          onFavoriteToggle: () => provider.toggleFavorite(currency.code),
        ),
      );
    });
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({
    required this.onBack,
    required this.language,
  });

  final VoidCallback onBack;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              AppStrings.of(language, 'currenciesTitle'),
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.language,
  });

  final TextEditingController controller;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: const Color(0xFF3E3E3E),
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: _AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _AppColors.textMain,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          hintText: AppStrings.of(language, 'searchHint'),
          hintStyle: const TextStyle(
            color: Color(0xFF9A9A9A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatefulWidget {
  const _CurrencyTile({
    required this.currency,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  final Currency currency;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  @override
  State<_CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<_CurrencyTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 80),
      opacity: _pressed ? 0.9 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              buildCurrencyFlag(widget.currency.code),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.currency.name,
                  style: const TextStyle(
                    color: _AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                widget.currency.code,
                style: const TextStyle(
                  color: Color(0xFF8F8F8F),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onFavoriteToggle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    widget.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: widget.isFavorite
                        ? const Color(0xFFF6C94C)
                        : const Color(0xFF8F8F8F),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          AppStrings.of(language, 'favorites'),
          style: const TextStyle(
            color: _AppColors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

