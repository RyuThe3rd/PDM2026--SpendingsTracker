import 'listaDeImports.dart';

class UserPremium extends User{

  UserPremium({required super.id,
    required super.nome,
    required super.apelido,
    super.premium = true});


}