import 'package:flutter/material.dart';

/// Widget that highlights search terms within text
class HighlightedText extends StatelessWidget {
  final String text;
  final String searchTerm;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final bool caseSensitive;

  const HighlightedText({
    super.key,
    required this.text,
    required this.searchTerm,
    this.style,
    this.highlightStyle,
    this.caseSensitive = false,
  });

  @override
  Widget build(BuildContext context) {
    if (searchTerm.isEmpty) {
      return Text(text, style: style);
    }

    final theme = Theme.of(context);
    final defaultHighlightStyle = highlightStyle ??
        TextStyle(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );

    final textToSearch = caseSensitive ? text : text.toLowerCase();
    final termToSearch = caseSensitive ? searchTerm : searchTerm.toLowerCase();

    if (!textToSearch.contains(termToSearch)) {
      return Text(text, style: style);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int index = textToSearch.indexOf(termToSearch, start);

    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add the highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + searchTerm.length),
        style: style?.merge(defaultHighlightStyle) ?? defaultHighlightStyle,
      ));

      start = index + searchTerm.length;
      index = textToSearch.indexOf(termToSearch, start);
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
