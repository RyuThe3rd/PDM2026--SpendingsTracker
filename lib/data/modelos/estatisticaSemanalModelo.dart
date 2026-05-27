import '../../listaDeImports.dart';

class EstatisticaSemanalModelo extends EstatisticaSemanal {

  EstatisticaSemanalModelo({
    required super.mes,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights, //agora a classe se chama Insights mas deixa estar
    super.semanaCounter,
    super.semanaAnteriorId,
    super.dadosDiarios,
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
      'dataInicio': dataInicio?.toIso8601String(),
      'dataFim': dataFim?.toIso8601String(),
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
    );
  }
}
