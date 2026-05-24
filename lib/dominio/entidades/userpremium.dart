import '../../listaDeImports.dart';

class UserPremium extends Usuario{

  UserPremium({required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
    super.premium = true});


}