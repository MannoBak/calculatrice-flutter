import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/logique.dart';
import '../widgets/calc_bouton.dart';

// La page principale de la calculatrice
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

// État de la page de la calculatrice
class _CalculatorPageState extends State<CalculatorPage> {
  String _expr = "";
  String _display = "0";
  String _lastExpr = "";

  // Pour l'évaluation des expressions
  final _engine = ExpressionEngine();

  // Vérifie si une chaîne est un opérateur
  bool _isOperator(String s) =>
      s == "+" || s == "-" || s == "×" || s == "÷" || s == "%";

  // Efface toute l'expression et réinitialise l'affichage
  void _clearAll() {
    setState(() {
      _expr = "";
      _lastExpr = "";
      _display = "0";
    });
  }

  // Bascule le signe du dernier nombre dans l'expression
  void _toggleSign() {
    setState(() {
      if (_expr.isEmpty) {
        _expr = "-";
        _display = _expr;
        return;
      }

      // Si le dernier caractère est un opérateur, ajoute un "-"
      final last = _expr.characters.last;

      if (_isOperator(last)) {
        _expr += "-";
        _display = _expr;
        return;
      }

      // Inverse le signe du dernier nombre
      final chunk = _engine.lastNumberChunk(_expr);
      if (chunk.isEmpty) return;

      // position de début du chunk
      final start = _expr.length - chunk.length;

      // Si le chunk commence par '-', supprimer ce signe (retire la négation)
      if (chunk.startsWith("-")) {
        _expr = _expr.substring(0, start) + chunk.substring(1);
      } else {
        // Si un opérateur + ou - précède le chunk, on le bascule (2+5 -> 2-5, 2-5 -> 2+5)
        if (start > 0) {
          final prev = _expr[start - 1];
          if (prev == "+") {
            _expr = _expr.substring(0, start - 1) + "-" + chunk;
            _display = _expr;
            return;
          } else if (prev == "-") {
            _expr = _expr.substring(0, start - 1) + "+" + chunk;
            _display = _expr;
            return;
          }
        }

        // Sinon, insérer un signe négatif uniaire devant le chunk
        _expr = _expr.substring(0, start) + "-" + chunk;
      }

      _display = _expr;
    });
  }

  // Ajoute un jeton (chiffre, opérateur, point) à l'expression
  void _append(String token) {
    setState(() {
      final isDigit = RegExp(r'\d').hasMatch(token);

      // reset après Error : réinitialiser complètement (chiffre, ".", ou opérateur)
      if (_display == "Error") {
        _expr = "";
        _lastExpr = "";
        _display = "0";
        // si c'est un opérateur, on quitte (pas d'ajout après Error)
        if (_isOperator(token)) {
          return;
        }
        // sinon, continuer avec la logique normale pour chiffre ou "."
      }

      // comportement après "=":
      // - si on tape un chiffre ou "." => nouvelle saisie
      // - si on tape un opérateur => on enchaîne l'opération avec le résultat
      if (_lastExpr.isNotEmpty) {
        if (isDigit || token == ".") {
          _expr = "";
          _lastExpr = "";
          _display = "0";
        } else if (_isOperator(token)) {
          // garder `_expr` (contenant le résultat) et retirer le topText
          _lastExpr = "";
          // l'opérateur sera ajouté par la logique ci-dessous
        }
      }

      // logique d'ajout du token si valide
      if (_isOperator(token)) {
        if (_expr.isEmpty) {
          if (token == "-") {
            _expr = "-";
            _display = _expr;
          }
          return;
        }

        if (_isOperator(_expr.characters.last)) {
          _expr = _expr.substring(0, _expr.length - 1) + token;
        } else {
          _expr += token;
        }
      } else if (token == ".") {
        final lastNumber = _engine.lastNumberChunk(_expr);
        if (lastNumber.contains(".")) return;

        if (_expr.isEmpty || _isOperator(_expr.characters.last)) {
          _expr += "0.";
        } else {
          _expr += ".";
        }
      } else {
        if (_expr == "0") _expr = "";
        _expr += token;
      }

      _display = _expr.isEmpty ? "0" : _expr;
    });
  }

  // Évalue l'expression actuelle et met à jour l'affichage
  void _equals() {
    if (_expr.isEmpty) return;

    final res = _engine.evaluateToString(_expr);

    setState(() {
      _lastExpr = "$_expr=";
      _display = res;

      if (res != "Error") {
        _expr = res;
      }
    });
  }

  // Construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    const bg = Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final W = c.maxWidth;
            final H = c.maxHeight;
            final isLandscape = W > H;

            // Limiter la largeur sur très grands écrans (évite l'étirement)
            final maxCalcWidth = isLandscape ? W : math.min(W, 520.0);

            // affichage en haut
            final displayH = (H * (isLandscape ? 0.32 : 0.30)).clamp(
              110.0,
              220.0,
            );
            final topText = (_lastExpr.isNotEmpty ? _lastExpr : _expr);

            final displayFont = (maxCalcWidth * 0.14).clamp(34.0, 60.0);
            final exprFont = (maxCalcWidth * 0.05).clamp(14.0, 22.0);

            // tailles boutons
            const padX = 16.0;
            const padY = 6.0;
            final innerW = maxCalcWidth - 2 * padX;

            final gap = (maxCalcWidth * 0.04).clamp(6.0, 12.0);

            // Helpers pour rows stables (pas spaceBetween)
            Widget hgap() => SizedBox(width: gap);
            Widget vgap() => SizedBox(height: gap);

            Widget rowCentered(List<Widget> children) {
              final spaced = <Widget>[];
              for (int i = 0; i < children.length; i++) {
                spaced.add(children[i]);
                if (i != children.length - 1) spaced.add(hgap());
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: spaced,
              );
            }

            // ====== PORTRAIT : maquette "standard" ======
            Widget portraitKeyboard(double keyboardH) {
              final innerH = keyboardH - 2 * padY;

              // 4 colonnes -> 3 gaps
              final maxButtonW = (innerW - 3 * gap) / 4;
              // 5 lignes -> 4 gaps
              final maxButtonH = (innerH - 4 * gap) / 5;

              final size = [
                maxButtonW,
                maxButtonH,
              ].reduce((a, b) => a < b ? a : b).clamp(42.0, 92.0);

              final equalHeight = 2 * size + gap;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: padX,
                  vertical: padY,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    rowCentered([
                      CalcButton(
                        text: "C",
                        onTap: _clearAll,
                        kind: ButtonKind.utility,
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "%",
                        onTap: () => _append("%"),
                        kind: ButtonKind.utility,
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "÷",
                        onTap: () => _append("÷"),
                        kind: ButtonKind.op,
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "×",
                        onTap: () => _append("×"),
                        kind: ButtonKind.op,
                        size: size,
                        gap: 0,
                      ),
                    ]),
                    vgap(),
                    rowCentered([
                      CalcButton(
                        text: "7",
                        onTap: () => _append("7"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "8",
                        onTap: () => _append("8"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "9",
                        onTap: () => _append("9"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "−",
                        onTap: () => _append("-"),
                        kind: ButtonKind.op,
                        size: size,
                        gap: 0,
                      ),
                    ]),
                    vgap(),
                    rowCentered([
                      CalcButton(
                        text: "4",
                        onTap: () => _append("4"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "5",
                        onTap: () => _append("5"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "6",
                        onTap: () => _append("6"),
                        size: size,
                        gap: 0,
                      ),
                      CalcButton(
                        text: "+",
                        onTap: () => _append("+"),
                        kind: ButtonKind.op,
                        size: size,
                        gap: 0,
                      ),
                    ]),
                    vgap(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            rowCentered([
                              CalcButton(
                                text: "1",
                                onTap: () => _append("1"),
                                size: size,
                                gap: 0,
                              ),
                              CalcButton(
                                text: "2",
                                onTap: () => _append("2"),
                                size: size,
                                gap: 0,
                              ),
                              CalcButton(
                                text: "3",
                                onTap: () => _append("3"),
                                size: size,
                                gap: 0,
                              ),
                            ]),
                            vgap(),
                            rowCentered([
                              CalcButton(
                                text: "+/-",
                                onTap: _toggleSign,
                                kind: ButtonKind.utility,
                                size: size,
                                gap: 0,
                              ),
                              CalcButton(
                                text: "0",
                                onTap: () => _append("0"),
                                size: size,
                                gap: 0,
                              ),
                              CalcButton(
                                text: ".",
                                onTap: () => _append("."),
                                size: size,
                                gap: 0,
                              ),
                            ]),
                          ],
                        ),
                        hgap(),
                        CalcButton(
                          text: "=",
                          onTap: _equals,
                          kind: ButtonKind.equalTall,
                          size: size,
                          gap: 0,
                          heightOverride: equalHeight,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            // ====== PAYSAGE : layout 2 colonnes (zéro overflow) ======
            Widget landscapeKeyboard(double keyboardH) {
              final innerH = keyboardH - 2 * padY;

              // 5 rangées visibles en paysage
              const rows = 5.0;

              // gauche = 4 colonnes, droite = 1 colonne
              final leftW = (innerW * 0.78);
              final rightW = (innerW * 0.22);

              final maxLeftButtonW = (leftW - 3 * gap) / 4;
              final maxButtonH = (innerH - (rows - 1) * gap) / rows;

              final size = [
                maxLeftButtonW,
                maxButtonH,
              ].reduce((a, b) => a < b ? a : b).clamp(30.0, 64.0);

              final equalHeight = 2 * size + gap;

              Widget placeholder() => SizedBox(width: size, height: size);

              Widget smallButton(
                String t,
                VoidCallback onTap, {
                ButtonKind kind = ButtonKind.normal,
              }) {
                return CalcButton(
                  text: t,
                  onTap: onTap,
                  kind: kind,
                  size: size,
                  gap: 0,
                );
              }

              Widget row4(List<Widget> children) {
                // row de 4 cases exactement
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    children[0],
                    hgap(),
                    children[1],
                    hgap(),
                    children[2],
                    hgap(),
                    children[3],
                  ],
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: padX,
                  vertical: padY,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // LEFT (4 colonnes)
                    SizedBox(
                      width: leftW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          row4([
                            smallButton(
                              "C",
                              _clearAll,
                              kind: ButtonKind.utility,
                            ),
                            smallButton(
                              "%",
                              () => _append("%"),
                              kind: ButtonKind.utility,
                            ),
                            smallButton("7", () => _append("7")),
                            smallButton("8", () => _append("8")),
                          ]),
                          vgap(),
                          row4([
                            smallButton("9", () => _append("9")),
                            smallButton("4", () => _append("4")),
                            smallButton("5", () => _append("5")),
                            smallButton("6", () => _append("6")),
                          ]),
                          vgap(),
                          row4([
                            smallButton("1", () => _append("1")),
                            smallButton("2", () => _append("2")),
                            smallButton("3", () => _append("3")),
                            smallButton(
                              "+/-",
                              _toggleSign,
                              kind: ButtonKind.utility,
                            ),
                          ]),
                          vgap(),
                          row4([
                            smallButton("0", () => _append("0")),
                            smallButton(".", () => _append(".")),
                            placeholder(),
                            placeholder(),
                          ]),
                        ],
                      ),
                    ),

                    hgap(),

                    // RIGHT (opérateurs)
                    SizedBox(
                      width: rightW,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CalcButton(
                            text: "÷",
                            onTap: () => _append("÷"),
                            kind: ButtonKind.op,
                            size: size,
                            gap: 0,
                          ),
                          vgap(),
                          CalcButton(
                            text: "×",
                            onTap: () => _append("×"),
                            kind: ButtonKind.op,
                            size: size,
                            gap: 0,
                          ),
                          vgap(),
                          CalcButton(
                            text: "−",
                            onTap: () => _append("-"),
                            kind: ButtonKind.op,
                            size: size,
                            gap: 0,
                          ),
                          vgap(),
                          CalcButton(
                            text: "+",
                            onTap: () => _append("+"),
                            kind: ButtonKind.op,
                            size: size,
                            gap: 0,
                          ),
                          vgap(),
                          CalcButton(
                            text: "=",
                            onTap: _equals,
                            kind: ButtonKind.equalTall,
                            size: size,
                            gap: 0,
                            heightOverride: equalHeight,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            final keyboardH = H - displayH;

            return Center(
              child: SizedBox(
                width: maxCalcWidth,
                child: Column(
                  children: [
                    // ===== Affichage =====
                    SizedBox(
                      height: displayH,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              topText.isEmpty ? " " : topText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: exprFont.toDouble(),
                                color: Colors.white60,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _display,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: displayFont.toDouble(),
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ===== Clavier =====
                    Expanded(
                      child: isLandscape
                          ? landscapeKeyboard(keyboardH)
                          : portraitKeyboard(keyboardH),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
