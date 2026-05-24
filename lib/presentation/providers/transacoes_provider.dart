import 'package:flutter/material.dart';
import '../../data/modelos/transacoesModelo.dart';

class TransacoesProvider extends ChangeNotifier {
  final List<TransacoesModelo> _transacoes = [];

  List<TransacoesModelo> get transacoes => _transacoes;

  void addTransacao(TransacoesModelo t) {
    _transacoes.add(t);
    notifyListeners();
  }

  void removeTransacao(int index) {
    _transacoes.removeAt(index);
    notifyListeners();
  }

  double get totalGastos {
    return _transacoes.fold(0, (sum, item) => sum + item.valor);
  }
}