import '../../listaDeImports.dart';

class InsightsModelo extends Insights {
  InsightsModelo({
    required super.data,
    super.dadosDeInsight,
  });

  Map<String, dynamic> toMap() => {
    'data': data,
    'dadosDeInsight': dadosDeInsight?.map((key, value) => MapEntry(key.name, value)),
  };

  factory InsightsModelo.fromMap(Map<String, dynamic> map) {
    return InsightsModelo(
      data: (map['data'] as Timestamp).toDate(),
      dadosDeInsight: (map['dadosDeInsight'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(TipoDeInsight.values.byName(key), value.toString()),
      ),
    );
  }
}
