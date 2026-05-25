import '../../listaDeImports.dart';

abstract interface class InterfaceTransacoes {
  List<Transacoes> obterTodas();

  Future<void> sincronizarSms() async {}
}
