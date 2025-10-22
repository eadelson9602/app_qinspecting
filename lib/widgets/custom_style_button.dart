import 'package:flutter/material.dart';

class CustomStyleButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool isExpanded;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  const CustomStyleButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.isExpanded = false,
    this.width,
    this.padding,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = backgroundColor ?? theme.primaryColor;
    final textColor = foregroundColor ?? Colors.white;
    final buttonPadding = padding ?? const EdgeInsets.symmetric(vertical: 4);
    final textSize = fontSize ?? 12.0;

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textColor,
        padding: buttonPadding,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: textSize + 2),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(fontSize: textSize),
          ),
        ],
      ),
    );

    if (isExpanded) {
      return Expanded(child: button);
    }

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

class CustomStyleButtonRow extends StatelessWidget {
  final List<CustomStyleButton> buttons;
  final double spacing;

  const CustomStyleButtonRow({
    Key? key,
    required this.buttons,
    this.spacing = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons
          .map((button) => [
                Expanded(child: button),
                if (button != buttons.last) SizedBox(width: spacing),
              ])
          .expand((element) => element)
          .toList(),
    );
  }
}

class CustomStyleButtonCard extends StatelessWidget {
  final String title;
  final List<CustomStyleButton> buttons;
  final Color? cardColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomStyleButtonCard({
    Key? key,
    required this.title,
    required this.buttons,
    this.cardColor,
    this.borderColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardBgColor = cardColor ?? primaryColor.withOpacity(0.05);
    final cardBorderColor = borderColor ?? primaryColor.withOpacity(0.2);

    return Container(
      margin: margin ?? const EdgeInsets.all(8),
      padding: padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          CustomStyleButtonRow(buttons: buttons),
        ],
      ),
    );
  }
}
