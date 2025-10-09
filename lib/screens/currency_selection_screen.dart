import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import '../l10n/app_localizations.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final bool isFromSettings;
  final String? currentCurrency;

  const CurrencySelectionScreen({
    super.key,
    this.isFromSettings = false,
    this.currentCurrency,
  });

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String? _selectedCurrency;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Comprehensive list of world currencies with their country codes and symbols
  final List<Currency> _currencies = [
    // Major currencies
    Currency('USD', 'US Dollar', 'US', '\$'),
    Currency('EUR', 'Euro', 'EU', '€'),
    Currency('GBP', 'British Pound', 'GB', '£'),
    Currency('JPY', 'Japanese Yen', 'JP', '¥'),
    Currency('CHF', 'Swiss Franc', 'CH', 'CHF'),
    Currency('CAD', 'Canadian Dollar', 'CA', 'C\$'),
    Currency('AUD', 'Australian Dollar', 'AU', 'A\$'),
    Currency('CNY', 'Chinese Yuan', 'CN', '¥'),

    // European currencies
    Currency('SEK', 'Swedish Krona', 'SE', 'kr'),
    Currency('NOK', 'Norwegian Krone', 'NO', 'kr'),
    Currency('DKK', 'Danish Krone', 'DK', 'kr'),
    Currency('PLN', 'Polish Zloty', 'PL', 'zł'),
    Currency('CZK', 'Czech Koruna', 'CZ', 'Kč'),
    Currency('HUF', 'Hungarian Forint', 'HU', 'Ft'),
    Currency('RON', 'Romanian Leu', 'RO', 'lei'),
    Currency('BGN', 'Bulgarian Lev', 'BG', 'лв'),
    Currency('HRK', 'Croatian Kuna', 'HR', 'kn'),
    Currency('ISK', 'Icelandic Krona', 'IS', 'kr'),
    Currency('TRY', 'Turkish Lira', 'TR', '₺'),
    Currency('RUB', 'Russian Ruble', 'RU', '₽'),
    Currency('UAH', 'Ukrainian Hryvnia', 'UA', '₴'),

    // Asian currencies
    Currency('INR', 'Indian Rupee', 'IN', '₹'),
    Currency('KRW', 'South Korean Won', 'KR', '₩'),
    Currency('SGD', 'Singapore Dollar', 'SG', 'S\$'),
    Currency('HKD', 'Hong Kong Dollar', 'HK', 'HK\$'),
    Currency('TWD', 'Taiwan Dollar', 'TW', 'NT\$'),
    Currency('THB', 'Thai Baht', 'TH', '฿'),
    Currency('MYR', 'Malaysian Ringgit', 'MY', 'RM'),
    Currency('IDR', 'Indonesian Rupiah', 'ID', 'Rp'),
    Currency('PHP', 'Philippine Peso', 'PH', '₱'),
    Currency('VND', 'Vietnamese Dong', 'VN', '₫'),
    Currency('PKR', 'Pakistani Rupee', 'PK', '₨'),
    Currency('BDT', 'Bangladeshi Taka', 'BD', '৳'),
    Currency('LKR', 'Sri Lankan Rupee', 'LK', '₨'),
    Currency('NPR', 'Nepalese Rupee', 'NP', '₨'),
    Currency('MMK', 'Myanmar Kyat', 'MM', 'K'),
    Currency('KHR', 'Cambodian Riel', 'KH', '៛'),
    Currency('LAK', 'Lao Kip', 'LA', '₭'),
    Currency('BND', 'Brunei Dollar', 'BN', 'B\$'),

    // Middle East & Africa
    Currency('AED', 'UAE Dirham', 'AE', 'د.إ'),
    Currency('SAR', 'Saudi Riyal', 'SA', '﷼'),
    Currency('QAR', 'Qatari Riyal', 'QA', '﷼'),
    Currency('KWD', 'Kuwaiti Dinar', 'KW', 'د.ك'),
    Currency('BHD', 'Bahraini Dinar', 'BH', '.د.ب'),
    Currency('OMR', 'Omani Rial', 'OM', '﷼'),
    Currency('JOD', 'Jordanian Dinar', 'JO', 'د.ا'),
    Currency('LBP', 'Lebanese Pound', 'LB', '£'),
    Currency('ILS', 'Israeli Shekel', 'IL', '₪'),
    Currency('EGP', 'Egyptian Pound', 'EG', '£'),
    Currency('ZAR', 'South African Rand', 'ZA', 'R'),
    Currency('NGN', 'Nigerian Naira', 'NG', '₦'),
    Currency('KES', 'Kenyan Shilling', 'KE', 'KSh'),
    Currency('GHS', 'Ghanaian Cedi', 'GH', '₵'),
    Currency('MAD', 'Moroccan Dirham', 'MA', 'د.م.'),
    Currency('TND', 'Tunisian Dinar', 'TN', 'د.ت'),
    Currency('DZD', 'Algerian Dinar', 'DZ', 'د.ج'),
    Currency('ETB', 'Ethiopian Birr', 'ET', 'Br'),
    Currency('UGX', 'Ugandan Shilling', 'UG', 'USh'),
    Currency('TZS', 'Tanzanian Shilling', 'TZ', 'TSh'),
    Currency('RWF', 'Rwandan Franc', 'RW', 'FRw'),
    Currency('ZMW', 'Zambian Kwacha', 'ZM', 'ZK'),
    Currency('BWP', 'Botswana Pula', 'BW', 'P'),
    Currency('NAD', 'Namibian Dollar', 'NA', 'N\$'),
    Currency('SZL', 'Swazi Lilangeni', 'SZ', 'L'),
    Currency('LSL', 'Lesotho Loti', 'LS', 'L'),
    Currency('MUR', 'Mauritian Rupee', 'MU', '₨'),
    Currency('SCR', 'Seychellois Rupee', 'SC', '₨'),

    // Americas
    Currency('BRL', 'Brazilian Real', 'BR', 'R\$'),
    Currency('MXN', 'Mexican Peso', 'MX', '\$'),
    Currency('ARS', 'Argentine Peso', 'AR', '\$'),
    Currency('CLP', 'Chilean Peso', 'CL', '\$'),
    Currency('COP', 'Colombian Peso', 'CO', '\$'),
    Currency('PEN', 'Peruvian Sol', 'PE', 'S/'),
    Currency('UYU', 'Uruguayan Peso', 'UY', '\$U'),
    Currency('PYG', 'Paraguayan Guarani', 'PY', '₲'),
    Currency('BOB', 'Bolivian Boliviano', 'BO', 'Bs'),
    Currency('VES', 'Venezuelan Bolívar', 'VE', 'Bs'),
    Currency('GYD', 'Guyanese Dollar', 'GY', 'G\$'),
    Currency('SRD', 'Surinamese Dollar', 'SR', 'Sr\$'),
    Currency('TTD', 'Trinidad Dollar', 'TT', 'TT\$'),
    Currency('JMD', 'Jamaican Dollar', 'JM', 'J\$'),
    Currency('BBD', 'Barbadian Dollar', 'BB', 'Bds\$'),
    Currency('BSD', 'Bahamian Dollar', 'BS', 'B\$'),
    Currency('BZD', 'Belize Dollar', 'BZ', 'BZ\$'),
    Currency('GTQ', 'Guatemalan Quetzal', 'GT', 'Q'),
    Currency('HNL', 'Honduran Lempira', 'HN', 'L'),
    Currency('NIO', 'Nicaraguan Córdoba', 'NI', 'C\$'),
    Currency('CRC', 'Costa Rican Colón', 'CR', '₡'),
    Currency('PAB', 'Panamanian Balboa', 'PA', 'B/.'),
    Currency('DOP', 'Dominican Peso', 'DO', 'RD\$'),
    Currency('HTG', 'Haitian Gourde', 'HT', 'G'),
    Currency('CUP', 'Cuban Peso', 'CU', '\$'),

    // Oceania
    Currency('NZD', 'New Zealand Dollar', 'NZ', 'NZ\$'),
    Currency('FJD', 'Fijian Dollar', 'FJ', 'FJ\$'),
    Currency('TOP', 'Tongan Paʻanga', 'TO', 'T\$'),
    Currency('WST', 'Samoan Tala', 'WS', 'WS\$'),
    Currency('VUV', 'Vanuatu Vatu', 'VU', 'VT'),
    Currency('SBD', 'Solomon Islands Dollar', 'SB', 'SI\$'),
    Currency('PGK', 'Papua New Guinea Kina', 'PG', 'K'),

    // Other regions
    Currency('IRR', 'Iranian Rial', 'IR', '﷼'),
    Currency('AFN', 'Afghan Afghani', 'AF', '؋'),
    Currency('AMD', 'Armenian Dram', 'AM', '֏'),
    Currency('AZN', 'Azerbaijani Manat', 'AZ', '₼'),
    Currency('GEL', 'Georgian Lari', 'GE', '₾'),
    Currency('KZT', 'Kazakhstani Tenge', 'KZ', '₸'),
    Currency('KGS', 'Kyrgyzstani Som', 'KG', 'лв'),
    Currency('TJS', 'Tajikistani Somoni', 'TJ', 'ЅМ'),
    Currency('TMT', 'Turkmenistani Manat', 'TM', 'T'),
    Currency('UZS', 'Uzbekistani Som', 'UZ', 'лв'),
    Currency('MNT', 'Mongolian Tugrik', 'MN', '₮'),
    Currency('KPW', 'North Korean Won', 'KP', '₩'),
    Currency('BTC', 'Bitcoin', 'BTC', '₿'),
    Currency('ETH', 'Ethereum', 'ETH', 'Ξ'),
  ];

  List<Currency> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return _currencies;
    }
    return _currencies.where((currency) {
      return currency.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.countryCode.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _detectAndSetDefaultCurrency();
  }

  void _detectAndSetDefaultCurrency() {
    // If coming from settings with current currency, use that
    if (widget.isFromSettings && widget.currentCurrency != null) {
      setState(() {
        _selectedCurrency = widget.currentCurrency;
      });
      return;
    }

    // Get device locale
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final countryCode = locale.countryCode?.toUpperCase() ?? 'US';

    // Map common country codes to currencies
    final Map<String, String> countryToCurrency = {
      'US': 'USD',
      'CA': 'CAD',
      'GB': 'GBP',
      'AU': 'AUD',
      'NZ': 'NZD',
      'IN': 'INR',
      'JP': 'JPY',
      'KR': 'KRW',
      'CN': 'CNY',
      'SG': 'SGD',
      'TH': 'THB',
      'ZA': 'ZAR',
      'CH': 'CHF',
      'SE': 'SEK',
      'NO': 'NOK',
      'DK': 'DKK',
      'PL': 'PLN',
      'CZ': 'CZK',
      'HU': 'HUF',
      'RU': 'RUB',
      'BR': 'BRL',
      'MX': 'MXN',
      'AED': 'AED',
      'SAR': 'SAR',
      'EGP': 'EGP',
      'NGN': 'NGN',
      'KES': 'KES',
      'GHS': 'GHS',
      'TRY': 'TRY',
      'ARS': 'ARS',
      'CLP': 'CLP',
      'COP': 'COP',
      'PEN': 'PEN',
      'HKD': 'HKD',
      'TWD': 'TWD',
      'MYR': 'MYR',
      'IDR': 'IDR',
      'PHP': 'PHP',
      'VND': 'VND',
      'PKR': 'PKR',
      'BDT': 'BDT',
      'LKR': 'LKR',
      'NPR': 'NPR',
      'ILS': 'ILS',
      'RON': 'RON',
      'BGN': 'BGN',
      'HRK': 'HRK',
      'ISK': 'ISK',
      'UAH': 'UAH',
    };

    // For EU countries, default to EUR
    final euCountries = [
      'DE',
      'FR',
      'IT',
      'ES',
      'NL',
      'BE',
      'AT',
      'PT',
      'IE',
      'FI',
      'GR',
      'LU',
      'SI',
      'SK',
      'EE',
      'LV',
      'LT',
      'CY',
      'MT',
    ];

    String defaultCurrency;
    if (euCountries.contains(countryCode)) {
      defaultCurrency = 'EUR';
    } else {
      defaultCurrency = countryToCurrency[countryCode] ?? 'USD';
    }

    // Set the detected currency as selected
    setState(() {
      _selectedCurrency = defaultCurrency;
    });

    // Scroll to the selected currency after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCurrency();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCurrencySelected(String currencyCode) {
    setState(() {
      _selectedCurrency = currencyCode;
    });
    _scrollToSelectedCurrency();
  }

  void _scrollToSelectedCurrency() {
    if (_selectedCurrency == null) return;

    // Find the index of the selected currency in the filtered list
    final selectedIndex = _filteredCurrencies.indexWhere(
      (currency) => currency.code == _selectedCurrency,
    );

    if (selectedIndex == -1) return;

    // Calculate the scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Get the current constraints to determine grid layout
        final context = this.context;
        final screenWidth = MediaQuery.of(context).size.width;

        // Determine columns based on screen width (same logic as in LayoutBuilder)
        int crossAxisCount;
        if (screenWidth > 1200) {
          crossAxisCount = 4;
        } else if (screenWidth > 800) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        // Calculate which row the selected item is in
        final row = selectedIndex ~/ crossAxisCount;

        // Estimate item height (aspect ratio + spacing)
        final itemWidth =
            (screenWidth - 32 - (crossAxisCount - 1) * 8) /
            crossAxisCount; // 32 for padding, 8 for spacing
        double childAspectRatio;
        if (screenWidth > 1200) {
          childAspectRatio = 3.5;
        } else if (screenWidth > 800) {
          childAspectRatio = 3.0;
        } else if (screenWidth > 600) {
          childAspectRatio = 2.8;
        } else {
          childAspectRatio = 2.6;
        }

        final itemHeight = itemWidth / childAspectRatio;
        final totalItemHeight = itemHeight + 8; // 8 for spacing

        // Calculate scroll position to center the selected item
        final scrollPosition =
            (row * totalItemHeight) - (MediaQuery.of(context).size.height / 4);

        _scrollController.animateTo(
          scrollPosition.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onContinue() {
    if (_selectedCurrency != null) {
      // TODO: Save selected currency to preferences
      if (widget.isFromSettings) {
        // Return to settings with selected currency
        Navigator.of(context).pop(_selectedCurrency);
      } else {
        // Continue to backup account screen
        Navigator.of(context).pushNamed('/backup-account');
      }
    }
  }

  void _onSkip() {
    // Use the auto-detected currency as default
    // TODO: Save detected currency to preferences
    Navigator.of(context).pushNamed('/backup-account');
  }

  void _onSave() {
    if (_selectedCurrency != null) {
      // TODO: Save selected currency to preferences
      Navigator.of(context).pop(_selectedCurrency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chooseCurrency),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: widget.isFromSettings
            ? null
            : [
                TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchCurrency,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });

                  // If search is cleared and there's a selected currency, scroll to it
                  if (value.isEmpty && _selectedCurrency != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToSelectedCurrency();
                    });
                  }
                },
              ),
            ),

            // Currency grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Responsive grid based on screen width
                    int crossAxisCount;
                    double childAspectRatio;

                    if (constraints.maxWidth > 1200) {
                      // Large desktop
                      crossAxisCount = 4;
                      childAspectRatio = 3.5;
                    } else if (constraints.maxWidth > 800) {
                      // Tablet/small desktop
                      crossAxisCount = 3;
                      childAspectRatio = 3.0;
                    } else if (constraints.maxWidth > 600) {
                      // Large mobile/small tablet
                      crossAxisCount = 2;
                      childAspectRatio = 2.8;
                    } else {
                      // Mobile
                      crossAxisCount = 2;
                      childAspectRatio = 2.6;
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _filteredCurrencies.length,
                      itemBuilder: (context, index) {
                        final currency = _filteredCurrencies[index];
                        final isSelected = _selectedCurrency == currency.code;

                        return GestureDetector(
                          onTap: () => _onCurrencySelected(currency.code),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                6.0,
                              ), // Further reduced padding for mobile
                              child: Row(
                                children: [
                                  // Currency info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize
                                          .min, // Added to prevent overflow
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              // Added Flexible to prevent overflow
                                              child: Text(
                                                '${currency.code} ${currency.symbol}',
                                                style: TextStyle(
                                                  fontSize:
                                                      13, // Further reduced for mobile
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ), // Further reduced spacing
                                            Text(
                                              currency.countryCode,
                                              style: TextStyle(
                                                fontSize:
                                                    9, // Further reduced for mobile
                                                fontWeight: FontWeight.w500,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.7,
                                                          )
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 1,
                                        ), // Reduced spacing
                                        Text(
                                          currency.name,
                                          style: TextStyle(
                                            fontSize:
                                                10, // Further reduced for mobile
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                      .withValues(alpha: 0.8)
                                                : Colors.grey.shade700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Selection indicator
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedCurrency != null
                      ? (widget.isFromSettings ? _onSave : _onContinue)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    widget.isFromSettings ? l10n.save : l10n.continueButton,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Currency {
  final String code;
  final String name;
  final String countryCode;
  final String symbol;

  Currency(this.code, this.name, this.countryCode, this.symbol);
}
