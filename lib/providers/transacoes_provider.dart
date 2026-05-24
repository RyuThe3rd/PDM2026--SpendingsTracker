import 'package:flutter/material.dart';
import '../models/transacao.dart';

class TransacoesProvider extends ChangeNotifier {
  final List<Transacao> _transacoes = [];

  List<Transacao> get transacoes => _transacoes;

  void adicionarTransacao(Transacao transacao) {
    _transacoes.add(transacao);
    notifyListeners();
  }

  double get totalGastos {
    return _transacoes
        .where((t) => t.tipo == "gasto")
        .fold(0, (soma, t) => soma + t.valor);
  }

  double get totalGanhos {
    return _transacoes
        .where((t) => t.tipo == "ganho")
        .fold(0, (soma, t) => soma + t.valor);
  }
}