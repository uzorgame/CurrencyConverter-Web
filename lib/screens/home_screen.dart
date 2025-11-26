import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/currency_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _snackShown = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<CurrencyProvider>(
          builder: (context, provider, _) {
            _maybeShowCacheBanner(provider);
            if (provider.state == CurrencyState.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.state == CurrencyState.error) {
              return _ErrorState(
                message: provider.errorMessage ?? 'Something went wrong',
                onRetry: () => provider.initialize(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _currencyDropdown(provider, true)),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.swap_vert, size: 28),
                        onPressed: provider.state == CurrencyState.loading
                            ? null
                            : () => provider.swap(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _currencyDropdown(provider, false)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*')),
                    ],
                    onChanged: provider.setAmount,
                  ),
                  const SizedBox(height: 16),
                  _ResultCard(provider: provider),
                  const SizedBox(height: 12),
                  if (provider.lastUpdated != null)
                    Text(
                      'Last updated: ${_formatDate(provider.lastUpdated!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 12),
                  if (provider.usedCache)
                    const Text(
                      'Using cached rates due to network issues.',
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _currencyDropdown(CurrencyProvider provider, bool isFrom) {
    return DropdownButtonFormField<String>(
      value: isFrom ? provider.fromCurrency : provider.toCurrency,
      items: provider.currencies
          .map((c) => DropdownMenuItem<String>(
                value: c,
                child: Text(c),
              ))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        if (isFrom) {
          provider.setFromCurrency(value);
        } else {
          provider.setToCurrency(value);
        }
      },
      decoration: InputDecoration(
        labelText: isFrom ? 'From' : 'To',
      ),
    );
  }

  void _maybeShowCacheBanner(CurrencyProvider provider) {
    if (provider.usedCache && !_snackShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet. Using cached rates'),
          ),
        );
      });
      _snackShown = true;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.provider});

  final CurrencyProvider provider;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E293B),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Converted amount',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              provider.result.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
