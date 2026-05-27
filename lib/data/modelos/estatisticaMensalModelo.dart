import '../../listaDeImports.dart';

class EstatisticaMensalModelo extends EstatisticaMensal {
  EstatisticaMensalModelo({
    required super.mes,
    required super.ano,
    required super.valorGanho,
    required super.valorGasto,
    required super.diferencaComparativa,
    required super.insights,
    required super.semanasDoMesIds,
    super.mesAnteriorId,
    required super.dadosSemanais,
    required super.criadoEm,
    required super.monthId,
  });

  Map<String, dynamic> toMap() {
    return {
      'mes': mes,
      'ano': ano,
      'valorGanho': valorGanho,
      'valorGasto': valorGasto,
      'diferencaComparativa': diferencaComparativa,
      'insights': (insights as InsightsModelo).toMap(),
      'semanasDoMesIds': semanasDoMesIds,
      'mesAnteriorId': mesAnteriorId,
      'dadosSemanais': dadosSemanais,
      'periodo': periodo.name,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'monthId': monthId,
    };
  }

  factory EstatisticaMensalModelo.fromMap(Map<String, dynamic> map) {
    return EstatisticaMensalModelo(
      mes: map['mes'],
      ano: map['ano'],
      valorGanho: (map['valorGanho'] as num).toDouble(),
      valorGasto: (map['valorGasto'] as num).toDouble(),
      diferencaComparativa: (map['diferencaComparativa'] as num).toDouble(),
      insights: InsightsModelo.fromMap(map['insights']),
      semanasDoMesIds: List<Map<int, dynamic>>.from(map['semanasDoMesIds']),
      mesAnteriorId: map['mesAnteriorId'],
      dadosSemanais: Map<String, dynamic>.from(map['dadosSemanais']),
      criadoEm: (map['criadoEm'] as Timestamp).toDate(),
      monthId: map['monthId'],
    );
  }
}
