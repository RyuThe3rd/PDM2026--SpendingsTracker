import '../../dominio/entidades/user.dart';
import '../../listaDeImports.dart';

class UserModelo extends User {
  UserModelo({
    required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
    super.premium = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'apelido': apelido,
      'nrDeTelefone': nrDeTelefone,
      'premium': premium,
      'tipo': tipo.name,
    };
  }

  factory UserModelo.fromJson(Map<String, dynamic> json) {
    return UserModelo(
      id: json['id'],
      nome: json['nome'],
      apelido: json['apelido'],
      nrDeTelefone: json['nrDeTelefone'],
      premium: json['premium'] ?? false,
    );
  }
}
