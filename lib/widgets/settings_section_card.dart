import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A collapsible settings section card that groups related settings items
class SettingsSectionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconBackgroundColor;
  final List<SettingItem> items;
  final bool initiallyExpanded;

  const SettingsSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconBackgroundColor,
    required this.items,
    this.initiallyExpanded = false,
  });

  @override
  State<SettingsSectionCard> createState() => _SettingsSectionCardState();
}

class _SettingsSectionCardState extends State<SettingsSectionCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Column(
        children: [
          // Header - Always visible
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.iconBackgroundColor ??
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconBackgroundColor ??
                          theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Expand/Collapse Icon
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5)
                        .animate(_animationController),
                    child: Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expanded Content
          SizeTransition(
            sizeFactor: _animationController,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  ...List.generate(
                    widget.items.length,
                    (index) {
                      final item = widget.items[index];
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingMd,
                              vertical: AppTheme.spacingSm,
                            ),
                            leading: item.leadingIcon != null
                                ? Icon(
                                    item.leadingIcon,
                                    size: 20,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  )
                                : null,
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 15,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: item.subtitle != null
                                ? Text(
                                    item.subtitle!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  )
                                : null,
                            trailing: item.trailing,
                            onTap: item.onTap,
                          ),
                          if (index < widget.items.length - 1)
                            Divider(
                              height: 1,
                              indent: item.leadingIcon != null ? 56 : 16,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a single item within a settings section
class SettingItem {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;

  SettingItem({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailing,
    this.onTap,
  });
}

