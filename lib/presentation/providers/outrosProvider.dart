import 'package:flutter/material.dart';

import '../../../listaDeImports.dart';

class OutrosProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _erro;

  bool get isLoading => _isLoading;
  String? get erro => _erro;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setErro(String? mensagem) {
    _erro = mensagem;
    notifyListeners();
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
