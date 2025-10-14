import 'package:flutter/material.dart';
import '../services/nudge_service.dart';
import '../services/account_service.dart';

/// Welcome nudge card that appears on first home screen visit
/// Provides quick actions for account rename and currency change
class WelcomeNudgeCard extends StatefulWidget {
  final VoidCallback? onAccountRename;
  final VoidCallback? onCurrencyChange;
  final VoidCallback? onDismiss;

  const WelcomeNudgeCard({
    super.key,
    this.onAccountRename,
    this.onCurrencyChange,
    this.onDismiss,
  });

  @override
  State<WelcomeNudgeCard> createState() => _WelcomeNudgeCardState();
}

class _WelcomeNudgeCardState extends State<WelcomeNudgeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _markNudgeAsShown();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  void _markNudgeAsShown() async {
    await NudgeService.instance.markNudgeAsShown(NudgeService.welcomeNudge);
  }

  void _handleDismiss() async {
    await NudgeService.instance.dismissNudge(NudgeService.welcomeNudge);

    if (mounted) {
      setState(() {
        _isVisible = false;
      });

      // Call the dismiss callback after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onDismiss?.call();
      });
    }
  }

  void _handleAccountRename() async {
    await NudgeService.instance.markNudgeAsShown(
      NudgeService.accountRenameNudge,
    );
    widget.onAccountRename?.call();
  }

  void _handleCurrencyChange() async {
    await NudgeService.instance.markNudgeAsShown(
      NudgeService.currencyChangeNudge,
    );
    widget.onCurrencyChange?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final accounts = AccountService.instance.activeAccounts;
    final mainAccount = accounts.isNotEmpty ? accounts.first : null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with dismiss button
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.celebration,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '🎉 Welcome to Money Manager!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _handleDismiss,
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Welcome message
                    Text(
                      'We\'ve created a "${mainAccount?.name ?? 'Main Account'}" for you to get started quickly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'You can customize your account name and currency anytime:',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleAccountRename,
                            icon: Icon(
                              Icons.edit,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Rename Account',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleCurrencyChange,
                            icon: Icon(
                              Icons.currency_exchange,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text(
                              'Change Currency',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Dismiss button
                    Center(
                      child: TextButton(
                        onPressed: _handleDismiss,
                        child: Text(
                          'Got it, thanks!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
