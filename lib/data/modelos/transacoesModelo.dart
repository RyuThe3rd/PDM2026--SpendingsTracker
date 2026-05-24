import '../../dominio/entidades/transacoes.dart';

class TransacoesModelo extends Transacoes {
  TransacoesModelo({
    required super.tipo,
    required super.fonte,
    required super.valor,
    required super.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.name,
      'fonte': fonte.name,
      'valor': valor,
      'data': data.toIso8601String(),
    };
  }

  factory TransacoesModelo.fromJson(Map<String, dynamic> json) {
    return TransacoesModelo(
      tipo: TipoTransacao.values.firstWhere((e) => e.name == json['tipo']),
      fonte: FonteTransacao.values.firstWhere((e) => e.name == json['fonte']),
      valor: json['valor'],
      data: DateTime.parse(json['data']),
    );
  }
}
