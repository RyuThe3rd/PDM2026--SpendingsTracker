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
  });

  Map<String, dynamic> toMap() {
    return {
      'mes': mes,
      'ano': ano,
      'valorGanho': valorGanho,
      'valorGasto': valorGasto,
      'diferencaComparativa': diferencaComparativa,
      'insight': (insights as InsightsModelo).toMap(),
      'semanasDoMesIds': semanasDoMesIds,
      'mesAnteriorId': mesAnteriorId,
      'dadosSemanais': dadosSemanais,
      'periodo': periodo.name,
    };
  }

  factory EstatisticaMensalModelo.fromMap(Map<String, dynamic> map) {
    return EstatisticaMensalModelo(
      mes: map['mes'],
      ano: map['ano'],
      valorGanho: (map['valorGanho'] as num).toDouble(),
      valorGasto: (map['valorGasto'] as num).toDouble(),
      diferencaComparativa: (map['diferencaComparativa'] as num).toDouble(),
      insights: InsightsModelo.fromMap(map['insight']),
      semanasDoMesIds: List<Map<int,dynamic>>.from(map['semanasDoMesIds']),
      mesAnteriorId: map['mesAnteriorId'],
      dadosSemanais: map['dadosSemanais'],
    );
  }
}