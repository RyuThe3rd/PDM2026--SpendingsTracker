import '../../listaDeImports.dart';


class AdminModelo extends Admin {
  AdminModelo({
    required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'apelido': apelido,
      'nrDeTelefone': nrDeTelefone,
      'tipo': tipo.name,
    };
  }

  factory AdminModelo.fromMap(Map<String, dynamic> json) {
    return AdminModelo(
      id: json['id'],
      nome: json['nome'],
      apelido: json['apelido'],
      nrDeTelefone: json['nrDeTelefone'],
    );
  }
}
