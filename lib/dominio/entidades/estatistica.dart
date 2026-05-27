import '../../listaDeImports.dart';

abstract class Estatistica {
  String mes;
  double valorGanho;
  double valorGasto;
  double diferencaComparativa;
  Insights insights;
  final PeriodoEstatistica periodo;
  DateTime criadoEm;

  Estatistica({
    required this.mes,
    required this.valorGanho,
    required this.valorGasto,
    required this.diferencaComparativa,
    required this.insights,
    required this.periodo,
    required this.criadoEm,
  });
}

class EstatisticaSemanal extends Estatistica {
  String weekId; // "2026-W22" 2026-Week 22
  int? semanaCounter; // conta se é semana 1 à 4 de um mês
  String? semanaAnteriorId;
  /// Dados detalhados de cada dia da semana (Segunda, Terça, etc.)
  /// { 'Segunda': { 'inicial': 0, 'levantado': 0, 'depositado': 0, 'final': 0 }, ... }
  Map<String, dynamic>? dadosDiarios;
  late DateTime dataInicio; // data em que a semana começou (Segunda-feira)
  late DateTime dataFim; // data em que a semana terminou (Domingo ou dia atual se em curso)

  EstatisticaSemanal({
    required super.mes,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    required super.criadoEm,
    required this.weekId,
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
  String monthId; // "2026-05"
  final int ano;
  String? mesAnteriorId;
  final List<Map<int, dynamic>> semanasDoMesIds; // map[1] = idDaSemana1
  final Map<String, dynamic> dadosSemanais;
  /// Dados detalhados de cada semana (Semana 1, Semana 2, etc.)
  /// { 'Semana 1': { 'inicial': 0, 'levantado': 0, 'depositado': 0, 'final': 0 }, ... }

  EstatisticaMensal({
    required super.mes,
    required this.ano,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    required super.criadoEm,
    required this.monthId,
    required this.semanasDoMesIds,
    required this.dadosSemanais,
    this.mesAnteriorId,
  }) : super(periodo: PeriodoEstatistica.mensal);
}
