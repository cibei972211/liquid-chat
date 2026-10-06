import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = AppTheme.glassBlur,
    this.opacity = AppTheme.glassOpacity,
    this.padding,
    this.margin,
    this.gradient,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity + 0.1),
                      Colors.white.withOpacity(opacity - 0.05),
                    ],
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: Colors.white.withOpacity(AppTheme.glassBorderOpacity),
                    width: 1.5,
                  ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(4, 4),
                    ),
                  ],
            ),
            child: onTap != null
                ? InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

// 液态玻璃按钮
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isPrimary;
  final double? width;
  final double height;

  const GlassButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppTheme.primaryGradient : null,
          color: isPrimary ? null : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: isPrimary
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppTheme.primaryLight.withOpacity(0.4)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.white : AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 玻璃输入框
class GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const GlassInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_isFocused ? 0.4 : 0.25),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isFocused
              ? AppTheme.primaryLight.withOpacity(0.6)
              : Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: AppTheme.primaryLight.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 15,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(widget.prefixIcon, color: AppTheme.textSecondary, size: 20)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
