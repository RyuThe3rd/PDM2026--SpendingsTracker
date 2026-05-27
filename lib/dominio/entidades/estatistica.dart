import '../../listaDeImports.dart';

abstract class Estatistica {
  String mes;
  double valorGanho;
  double valorGasto;
  double diferencaComparativa;
  Insights insights;
  final PeriodoEstatistica periodo;


  Estatistica({
    required this.mes,
    required this.valorGanho,
    required this.valorGasto,
    required this.diferencaComparativa,
    required this.insights,
    required this.periodo,
  });
}

class EstatisticaSemanal extends Estatistica {
  int? semanaCounter;//conta se é semana 1 à 4 de um mês
  final String? semanaAnteriorId;
  /// Dados detalhados de cada dia da semana (Segunda, Terça, etc.)
  /// { 'Segunda': { 'inicial': 0, 'levantado': 0, 'depositado': 0, 'final': 0 }, ... }
  Map<String, dynamic>? dadosDiarios;
  DateTime? dataInicio; //data em que a semana corrente começou
  DateTime? dataFim;//dia corrente da semana corrente até chegar no domingo

  EstatisticaSemanal({
    required super.mes,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    this.semanaCounter,
    this.dadosDiarios,
    this.semanaAnteriorId,
  }) : super(periodo: PeriodoEstatistica.semanal){

    _calcularSemanaCorrente();

  }

  // Método para calcular as datas da semana atual
  void _calcularSemanaCorrente() {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);

    /* 1. Calcular a Segunda-feira desta semana (Data Início)
      weekday: 1 (Seg) a 7 (Dom).
     Se hoje for segunda (1), subtraímos(subtract) 0.
     Se for terça (2), subtraímos 1.
    */
    dataInicio = hoje.subtract(Duration(days: hoje.weekday - 1));

    // 2. Calcular o fim do dia de hoje (Data Fim / Data Corrente)
    // Usamos o fim do dia atual (23:59:59) para captar todas as transações de hoje
    dataFim = DateTime(agora.year, agora.month, agora.day, 23, 59, 59);

    // Determinar o número da semana no mês
    int semanaCounter = ((agora.day - 1) / 7).floor() + 1;
    if (semanaCounter > 4) semanaCounter = 4;


  }
}

class EstatisticaMensal extends Estatistica {
  final int ano;
  final String? mesAnteriorId;
  final List<Map<int,dynamic>> semanasDoMesIds;
  /// Dados detalhados de cada semana (Semana 1, Semana 2, etc.)
  /// { 'Semana 1': { 'inicial': 0, 'levantado': 0, 'depositado': 0, 'final': 0 }, ... }
  final Map<String, dynamic> dadosSemanais;

  EstatisticaMensal({
    required super.mes,
    required this.ano,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    required this.semanasDoMesIds,
    required this.dadosSemanais,
    this.mesAnteriorId,
  }) : super(periodo: PeriodoEstatistica.mensal);
}
