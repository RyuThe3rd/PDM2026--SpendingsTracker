import 'package:flutter/material.dart';
import '../models/utilizador.dart';

class UserProvider extends ChangeNotifier {
  Utilizador? _utilizador;

  Utilizador? get utilizador => _utilizador;

  bool get isPremium => _utilizador?.premium ?? false;

  void setUtilizador(Utilizador user) {
    _utilizador = user;
    notifyListeners();
  }

  void logout() {
    _utilizador = null;
    notifyListeners();
  }
}