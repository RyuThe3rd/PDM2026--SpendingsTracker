import '../../listaDeImports.dart';

class MonitorarGastos {
  final InterfaceTransacoes _transacoesRepo;

  MonitorarGastos(this._transacoesRepo);

  // Calcula o saldo acumulado antes de uma data específica.
  double _calcularSaldoInicial(List<Transacoes> todas, DateTime dataReferencia) {
    double saldo = 0;
    for (var t in todas) {
      if (t.data.isBefore(dataReferencia)) {
        if (t.tipo == TipoTransacao.Deposito) {
          saldo += t.valor;
        } else if (t.tipo == TipoTransacao.Levantamento) {
          saldo -= t.valor;
        }
      }
    }
    return saldo;
  }

  Map<String, dynamic> gastoSemanal() {
    final todas = _transacoesRepo.obterTodas();
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    // Pegamos o domingo anterior como base. Assim, base + 1 dia = Segunda-feira.
    final domingoAnterior = hoje.subtract(Duration(days: hoje.weekday));

    final diasDaSemana = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    Map<String, dynamic> resultado = {};

    for (int i = 1; i <= 7; i++) {
      final diaInicio = domingoAnterior.add(Duration(days: i));
      final diaFim = diaInicio.add(const Duration(days: 1));

      final transacoesDoDia = todas.where((t) =>
      (t.data.isAtSameMomentAs(diaInicio) || t.data.isAfter(diaInicio)) &&
          t.data.isBefore(diaFim)).toList();

      double inicial = _calcularSaldoInicial(todas, diaInicio);
      double depositado = 0;
      double levantado = 0;

      for (var t in transacoesDoDia) {
        if (t.tipo == TipoTransacao.Deposito) {
          depositado += t.valor;
        } else if (t.tipo == TipoTransacao.Levantamento) {
          levantado += t.valor;
        }
      }

      resultado[diasDaSemana[i - 1]] = {
        'inicial': inicial,
        'levantado': levantado,
        'depositado': depositado,
        'final': inicial + depositado - levantado,
      };
    }
    return resultado;
  }

  Map<String, dynamic> gastoMensal() {
    final todas = _transacoesRepo.obterTodas();
    final agora = DateTime.now();
    Map<String, dynamic> resultado = {};

    for (int semana = 1; semana <= 4; semana++) {
      // Início da semana: dia 1, 8, 15 ou 22
      final diaInicioNum = ((semana - 1) * 7) + 1;
      final diaInicio = DateTime(agora.year, agora.month, diaInicioNum);

      // Fim da semana: 7 dias depois ou o início do próximo mês
      DateTime diaFim = diaInicio.add(const Duration(days: 7));
      if (semana == 4) {
        diaFim = DateTime(agora.year, agora.month + 1, 1);
      }

      final transacoesDaSemana = todas.where((t) =>
      (t.data.isAtSameMomentAs(diaInicio) || t.data.isAfter(diaInicio)) &&
          t.data.isBefore(diaFim)).toList();

      double inicial = _calcularSaldoInicial(todas, diaInicio);
      double depositado = 0;
      double levantado = 0;

      for (var t in transacoesDaSemana) {
        if (t.tipo == TipoTransacao.Deposito) {
          depositado += t.valor;
        } else if (t.tipo == TipoTransacao.Levantamento) {
          levantado += t.valor;
        }
      }

      resultado['Semana $semana'] = {
        'inicial': inicial,
        'levantado': levantado,
        'depositado': depositado,
        'final': inicial + depositado - levantado,
      };
    }
    return resultado;
  }
}