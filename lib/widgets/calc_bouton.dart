import 'package:flutter/material.dart';

enum ButtonKind { normal, op, utility, equalTall }

class CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final ButtonKind kind;

  /// diamètre du bouton (calculé par l'écran)
  final double size;

  /// espacement autour du bouton (calculé par l'écran)
  final double gap;

  /// override de hauteur (utile pour le bouton "=" vertical)
  final double? heightOverride;

  const CalcButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.size,
    required this.gap,
    this.kind = ButtonKind.normal,
    this.heightOverride,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;

    // 🎨 Couleurs (opérateurs en orange, mais % sera mis en utility côté page)
    switch (kind) {
      case ButtonKind.equalTall:
        bg = Colors.orange;
        fg = Colors.white;
        break;
      case ButtonKind.op:
        bg = Colors.orange;
        fg = Colors.white;
        break;
      case ButtonKind.utility:
        bg = const Color(0xFF4A4A4A);
        fg = Colors.white;
        break;
      case ButtonKind.normal:
      default:
        bg = const Color(0xFF4A4A4A);
        fg = Colors.white;
    }

    final double h = heightOverride ?? size;
    final double fontSize = text.length >= 2 ? size * 0.25 : size * 0.35;

    return Padding(
      padding: EdgeInsets.all(gap / 2),
      child: SizedBox(
        width: size,
        height: h,
        child: Material(
          color: bg,
          shape: kind == ButtonKind.equalTall
              ? const StadiumBorder()
              : const CircleBorder(),
          child: InkWell(
            customBorder: kind == ButtonKind.equalTall
                ? const StadiumBorder()
                : const CircleBorder(),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
