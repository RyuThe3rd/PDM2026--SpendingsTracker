import '../../listaDeImports.dart';


class UsuarioModelo extends Usuario {
  UsuarioModelo({
    required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
    super.premium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'apelido': apelido,
      'nrDeTelefone': nrDeTelefone,
      'premium': premium,
      'tipo': tipo.name,
    };
  }

  factory UsuarioModelo.fromMap(Map<String, dynamic> json) {
    return UsuarioModelo(
      id: json['id'],
      nome: json['nome'],
      apelido: json['apelido'],
      nrDeTelefone: json['nrDeTelefone'],
      premium: json['premium'] ?? false,
    );
  }
}
