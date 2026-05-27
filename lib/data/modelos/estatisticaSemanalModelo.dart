import '../../listaDeImports.dart';

class EstatisticaSemanalModelo extends EstatisticaSemanal {
  EstatisticaSemanalModelo({
    required super.mes,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    super.semanaCounter,
    super.semanaAnteriorId,
    super.dadosDiarios,
    required super.criadoEm,
    required super.weekId,
    required super.dataInicio,
    required super.dataFim,
  });

  Map<String, dynamic> toMap() {
    return {
      'mes': mes,
      'valorGanho': valorGanho,
      'valorGasto': valorGasto,
      'diferencaComparativa': diferencaComparativa,
      'insight': (insights as InsightsModelo).toMap(),
      'semanaCounter': semanaCounter,
      'semanaAnteriorId': semanaAnteriorId,
      'periodo': periodo.name,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'criadoEm': criadoEm,
      'weekId': weekId,
      'dadosDiarios': dadosDiarios,
    };
  }

  factory EstatisticaSemanalModelo.fromMap(Map<String, dynamic> map) {
    return EstatisticaSemanalModelo(
      mes: map['mes'],
      valorGanho: (map['valorGanho'] as num).toDouble(),
      valorGasto: (map['valorGasto'] as num).toDouble(),
      diferencaComparativa: (map['diferencaComparativa'] as num).toDouble(),
      insights: InsightsModelo.fromMap(map['insight']),
      semanaCounter: map['semanaCounter'],
      semanaAnteriorId: map['semanaAnteriorId'],
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
      weekId: map['weekId'],
      dataInicio: (map['dataInicio'] as Timestamp).toDate(),
      dataFim: (map['dataFim'] as Timestamp).toDate(),
      dadosDiarios: map['dadosDiarios'] != null ? Map<String, dynamic>.from(map['dadosDiarios']) : null,
    );
  }
}
