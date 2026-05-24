import 'package:flutter/material.dart';
import '../../data/modelos/userModelos.dart';

class UserProvider extends ChangeNotifier {
  UserModelo? _user;

  UserModelo? get user => _user;

  void setUser(UserModelo user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}