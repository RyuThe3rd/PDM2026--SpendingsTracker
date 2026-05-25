import '../../../listaDeImports.dart';

class TransacoesProvider extends ChangeNotifier {
  InterfaceTransacoes _transacoesRepo;

  late List<Transacoes> _transacoes;

  TransacoesProvider(this._transacoesRepo){
    _transacoes = _transacoesRepo.obterTodas() ?? [];
  }

  InterfaceTransacoes get transacoesRepo => _transacoesRepo;

  List<Transacoes> get transacoes => _transacoes;

  void adicionarTransacao(Transacoes transacao) {
    _transacoes.add(transacao);
    notifyListeners();
  }

  void removerTransacao(int index) {
    _transacoes.removeAt(index);
    notifyListeners();
  }

  void limparTransacoes() {
    _transacoes = [];
    notifyListeners();
  }

  List<Transacoes> transacoesPorPeriodo(DateTime inicio, DateTime fim) {
    return _transacoes
        .where((t) => t.data.isAfter(inicio) && t.data.isBefore(fim))
        .toList();
  }

  List<Transacoes> transacoesDaSemana() {
    final agora = DateTime.now();
    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
    return transacoesPorPeriodo(inicioSemana, agora);
  }

  List<Transacoes> transacoesDoMes() {
    final agora = DateTime.now();
    final inicioMes = DateTime(agora.year, agora.month, 1);
    return transacoesPorPeriodo(inicioMes, agora);
  }
}
