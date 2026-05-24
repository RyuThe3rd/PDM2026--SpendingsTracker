import '../../dominio/entidades/userpremium.dart';
import '../../listaDeImports.dart';

class UserPremiumModelo extends UserPremium {
  UserPremiumModelo({
    required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
    super.premium = true,
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

  factory UserPremiumModelo.fromJson(Map<String, dynamic> json) {
    return UserPremiumModelo(
      id: json['id'],
      nome: json['nome'],
      apelido: json['apelido'],
      nrDeTelefone: json['nrDeTelefone'],
      premium: json['premium'] ?? true,
    );
  }
}
