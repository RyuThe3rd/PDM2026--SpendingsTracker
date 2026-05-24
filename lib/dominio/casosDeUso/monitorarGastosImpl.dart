import '../../listaDeImports.dart';
import '../contratos/interfaceTransasoes.dart';

class MonitorarGastosImpl {
  InterfaceTransacoes _transacoes;
  MonitorarGastosImpl(this._transacoes);

  Map<String, dynamic> gastoSemanal(List<Transacoes> transacoes) {
    final agora = DateTime.now();
    final diasDaSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    Map<String, dynamic> resultado = {};

    for (int i = 0; i < 7; i++) {
      final dia = agora.subtract(Duration(days: agora.weekday - 1 - i));
      final transacoesDoDia = transacoes.where((t) =>
          t.data.year == dia.year &&
          t.data.month == dia.month &&
          t.data.day == dia.day).toList();

      double depositado = 0;
      double levantado = 0;

      for (var t in transacoesDoDia) {
        if (t.tipo == TipoTransacao.Deposito) depositado += t.valor;
        if (t.tipo == TipoTransacao.Levantamento) levantado += t.valor;
      }

      resultado[diasDaSemana[i]] = {
        'depositado': depositado,
        'levantado': levantado,
        'final': depositado - levantado,
      };
    }
    return resultado;
  }

  Map<String, dynamic> gastoMensal(List<Transacoes> transacoes) {
    Map<String, dynamic> resultado = {};

    for (int semana = 1; semana <= 4; semana++) {
      final inicio = DateTime(DateTime.now().year, DateTime.now().month, (semana - 1) * 7 + 1);
      final fim = DateTime(DateTime.now().year, DateTime.now().month, semana * 7);

      final transacoesDaSemana = transacoes.where((t) =>
          t.data.isAfter(inicio) && t.data.isBefore(fim)).toList();

      double depositado = 0;
      double levantado = 0;

      for (var t in transacoesDaSemana) {
        if (t.tipo == TipoTransacao.Deposito) depositado += t.valor;
        if (t.tipo == TipoTransacao.Levantamento) levantado += t.valor;
      }

      resultado['Semana $semana'] = {
        'depositado': depositado,
        'levantado': levantado,
        'final': depositado - levantado,
      };
    }
    return resultado;
  }
}
