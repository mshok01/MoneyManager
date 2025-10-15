/// Utility class for currency operations
class CurrencyUtils {
  CurrencyUtils._(); // Private constructor to prevent instantiation

  // Map of currency codes to their symbols
  static const Map<String, String> _currencySymbols = {
    // Major currencies
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CHF': 'CHF',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CNY': '¥',

    // European currencies
    'SEK': 'kr',
    'NOK': 'kr',
    'DKK': 'kr',
    'PLN': 'zł',
    'CZK': 'Kč',
    'HUF': 'Ft',
    'RON': 'lei',
    'BGN': 'лв',
    'HRK': 'kn',
    'ISK': 'kr',
    'TRY': '₺',
    'RUB': '₽',
    'UAH': '₴',

    // Asian currencies
    'INR': '₹',
    'KRW': '₩',
    'SGD': 'S\$',
    'HKD': 'HK\$',
    'TWD': 'NT\$',
    'THB': '฿',
    'MYR': 'RM',
    'IDR': 'Rp',
    'PHP': '₱',
    'VND': '₫',
    'PKR': '₨',
    'BDT': '৳',
    'LKR': '₨',
    'NPR': '₨',
    'MMK': 'K',

    // Middle East & Africa
    'AED': 'د.إ',
    'SAR': '﷼',
    'QAR': '﷼',
    'KWD': 'د.ك',
    'BHD': '.د.ب',
    'OMR': '﷼',
    'JOD': 'د.ا',
    'LBP': '£',
    'ILS': '₪',
    'EGP': '£',
    'ZAR': 'R',
    'NGN': '₦',
    'KES': 'KSh',
    'GHS': '₵',
    'MAD': 'د.م.',
    'TND': 'د.ت',
    'DZD': 'د.ج',
    'ETB': 'Br',
    'UGX': 'USh',
    'TZS': 'TSh',
    'RWF': 'FRw',
    'ZMW': 'ZK',
    'BWP': 'P',
    'NAD': 'N\$',
    'SZL': 'L',
    'LSL': 'L',
    'MUR': '₨',
    'SCR': '₨',

    // Americas
    'BRL': 'R\$',
    'MXN': '\$',
    'ARS': '\$',
    'CLP': '\$',
    'COP': '\$',
    'PEN': 'S/',
    'UYU': '\$U',
    'PYG': '₲',
    'BOB': 'Bs',
    'VES': 'Bs',
    'GYD': 'G\$',
    'SRD': 'Sr\$',
    'TTD': 'TT\$',
    'JMD': 'J\$',
    'BBD': 'Bds\$',
    'BSD': 'B\$',
    'BZD': 'BZ\$',
    'GTQ': 'Q',
    'HNL': 'L',
    'NIO': 'C\$',
    'CRC': '₡',
    'PAB': 'B/.',
    'DOP': 'RD\$',
    'HTG': 'G',
    'CUP': '\$',

    // Other regions
    'IRR': '﷼',
    'AFN': '؋',
    'AMD': '֏',
    'AZN': '₼',
    'GEL': '₾',
    'KZT': '₸',
    'KGS': 'лв',
    'TJS': 'ЅМ',
    'TMT': 'T',
    'UZS': 'лв',
    'MNT': '₮',
    'KPW': '₩',
    'BTC': '₿',
    'ETH': 'Ξ',
  };

  /// Get currency symbol for a given currency code
  /// Returns the currency code if symbol is not found
  static String getCurrencySymbol(String currencyCode) {
    return _currencySymbols[currencyCode.toUpperCase()] ?? currencyCode;
  }

  /// Format amount with currency symbol
  /// Example: formatAmount(100.50, 'INR') returns '₹100.50'
  static String formatAmount(double amount, String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Format amount with currency code
  /// Example: formatAmountWithCode(100.50, 'INR') returns 'INR 100.50'
  static String formatAmountWithCode(double amount, String currencyCode) {
    return '$currencyCode ${amount.toStringAsFixed(2)}';
  }

  /// Check if currency code is valid (has a known symbol)
  static bool isValidCurrencyCode(String currencyCode) {
    return _currencySymbols.containsKey(currencyCode.toUpperCase());
  }

  /// Get all supported currency codes
  static List<String> getSupportedCurrencies() {
    return _currencySymbols.keys.toList();
  }

  /// Get currency display name with symbol
  /// Example: getCurrencyDisplayName('INR', 'Indian Rupee') returns 'Indian Rupee (₹)'
  static String getCurrencyDisplayName(String currencyCode, String currencyName) {
    final symbol = getCurrencySymbol(currencyCode);
    if (symbol == currencyCode) {
      return currencyName; // No symbol found, just return name
    }
    return '$currencyName ($symbol)';
  }
}
