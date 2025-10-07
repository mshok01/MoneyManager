import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<IntroPage> _getPages(AppLocalizations l10n) {
    return [
      IntroPage(
        title: l10n.welcomeToMoneyManager,
        description: l10n.welcomeDescription,
        icon: Icons.account_balance_wallet,
        color: Colors.blue,
      ),
      IntroPage(
        title: l10n.trackIncomeExpenses,
        description: l10n.trackIncomeExpensesDescription,
        icon: Icons.trending_up,
        color: Colors.green,
      ),
      IntroPage(
        title: l10n.multipleAccounts,
        description: l10n.multipleAccountsDescription,
        icon: Icons.account_balance,
        color: Colors.orange,
      ),
      IntroPage(
        title: l10n.customCategories,
        description: l10n.customCategoriesDescription,
        icon: Icons.category,
        color: Colors.purple,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // 4 pages total, so index 3 is the last
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishIntro() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only show when not on last page)
            if (_currentPage < pages.length - 1)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: _finishIntro,
                    child: Text(
                      l10n.skip,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

            // Page view with navigation arrows
            Expanded(
              child: Stack(
                children: [
                  PageView(
                    key: const PageStorageKey('intro_pageview'),
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const PageScrollPhysics(),
                    children: [
                      for (int i = 0; i < pages.length; i++)
                        Container(
                          key: ValueKey('page_$i'),
                          child: _buildPage(pages[i]),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom navigation row with arrows and indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left arrow
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _currentPage > 0
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _previousPage,
                              icon: const Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.grey,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : const SizedBox(), // Empty space when no left arrow
                  ),

                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => _buildIndicator(index),
                    ),
                  ),

                  // Right arrow or Continue button
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: _currentPage < pages.length - 1
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _nextPage,
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: pages[_currentPage].color,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: pages[_currentPage].color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _finishIntro,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(IntroPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    // Get the current pages from the build context
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 24.0 : 8.0,
      height: 8.0,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? pages[_currentPage].color
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class IntroPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  IntroPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
