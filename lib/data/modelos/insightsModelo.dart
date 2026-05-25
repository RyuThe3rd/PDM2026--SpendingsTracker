import '../../listaDeImports.dart';

class InsightModelo extends Insight {
  InsightModelo({
    required super.tipo,
    required super.textoDoInsight,
    required super.data,
  });

  Map<String, dynamic> toMap() => {
    'tipo': tipo.name,
    'textoDoInsight': textoDoInsight,
    'data': data,
  };

  factory InsightModelo.fromMap(Map<String, dynamic> map) {
    return InsightModelo(
      tipo: TipoDeInsight.values.byName(map['tipo']),
      textoDoInsight: map['textoDoInsight'],
      data: (map['data'] as Timestamp).toDate(),
    );
  }
}
