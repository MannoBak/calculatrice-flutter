// Moteur d'évaluation d'expressions arithmétiques simples (+, -, ×, ÷, %)
class ExpressionEngine {
  bool _isOperator(String s) =>
      s == "+" || s == "-" || s == "×" || s == "÷" || s == "%";

  int _precedence(String op) {
    // priorité: % × ÷ (2) > + - (1)
    if (op == "%" || op == "×" || op == "÷") return 2;
    if (op == "+" || op == "-") return 1;
    return 0;
  }

  // Retourne le dernier "chunk" numérique de l'expression (après le dernier opérateur)
  String lastNumberChunk(String expr) {
    if (expr.isEmpty) return "";
    int i = expr.length - 1;
    while (i >= 0) {
      final c = expr[i];
      if (_isOperator(c)) break;
      i--;
    }
    return expr.substring(i + 1);
  }

  // Évalue l'expression et retourne le résultat sous forme de chaîne
  String evaluateToString(String expr) {
    try {
      final tokens = _tokenize(expr);
      final rpn = _toRpn(tokens);
      final value = _evalRpn(rpn);

      if (value.isNaN || value.isInfinite) return "Error";

      // enlever .0 si entier
      final asInt = value.truncateToDouble();
      if ((value - asInt).abs() < 1e-10) return asInt.toInt().toString();

      // limiter les décimales et nettoyer
      return _trimDouble(value, maxDecimals: 10);
    } catch (_) {
      return "Error";
    }
  }

  // Nettoie une représentation en chaîne d'un double en enlevant les zéros inutiles
  String _trimDouble(double v, {int maxDecimals = 10}) {
    final s = v.toStringAsFixed(maxDecimals);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    final buffer = StringBuffer();

    // début ou après opérateur
    bool isUnaryMinusAllowed = true; 

    for (int i = 0; i < expr.length; i++) {
      final c = expr[i];
      if (c == ' ') continue;

      final isDigit = RegExp(r'\d').hasMatch(c);

      if (isDigit || c == '.') {
        buffer.write(c);
        isUnaryMinusAllowed = false;
        continue;
      }

      // opérateur
      if (_isOperator(c)) {
        // "-" unaire (ex: -5+2 ou 7×-3)
        if (c == '-' && isUnaryMinusAllowed) {
          buffer.write(c);
          isUnaryMinusAllowed = false;
          continue;
        }

        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString());
          buffer.clear();
        }

        tokens.add(c);
        isUnaryMinusAllowed = true;
        continue;
      }

      throw FormatException("Invalid char: $c");
    }

    if (buffer.isNotEmpty) tokens.add(buffer.toString());

    // Expression finissant par opérateur -> erreur
    if (tokens.isNotEmpty && _isOperator(tokens.last)) {
      throw FormatException("Ends with operator");
    }

    return tokens;
  }

  List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final ops = <String>[];

    for (final t in tokens) {
      final isNumber = double.tryParse(t) != null;

      if (isNumber) {
        output.add(t);
        continue;
      }

      if (_isOperator(t)) {
        while (ops.isNotEmpty &&
            _isOperator(ops.last) &&
            _precedence(ops.last) >= _precedence(t)) {
          output.add(ops.removeLast());
        }
        ops.add(t);
        continue;
      }

      throw FormatException("Bad token: $t");
    }

    while (ops.isNotEmpty) {
      output.add(ops.removeLast());
    }

    return output;
  }

  // Évalue une expression en notation polonaise inversée (RPN) 
  double _evalRpn(List<String> rpn) {
    final stack = <double>[];

    for (final t in rpn) {
      final num = double.tryParse(t);
      if (num != null) {
        stack.add(num);
        continue;
      }

      if (!_isOperator(t)) throw FormatException("Bad op");
      if (stack.length < 2) throw FormatException("Not enough operands");

      final b = stack.removeLast();
      final a = stack.removeLast();

      double res;
      switch (t) {
        case '+':
          res = a + b;
          break;
        case '-':
          res = a - b;
          break;
        case '×':
          res = a * b;
          break;
        case '÷':
          if (b == 0) return double.nan;
          res = a / b;
          break;
        case '%':
          if (b == 0) return double.nan;
          res = a % b; // modulo
          break;
        default:
          throw FormatException("Unknown op");
      }

      stack.add(res);
    }

    // Résultat final
    if (stack.length != 1) throw FormatException("Bad expression");
    return stack.single;
  }
}
