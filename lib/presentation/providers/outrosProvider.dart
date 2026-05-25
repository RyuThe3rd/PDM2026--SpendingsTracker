import 'package:flutter/material.dart';

import '../../../listaDeImports.dart';

class ProviderGlobal extends ChangeNotifier {
  String _login = 'azul'; // 'azul' para Login, 'branco' para Cadastro

  String get login => _login;

  void setLogin(String value) {
    _login = value;
    notifyListeners();
  }

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
