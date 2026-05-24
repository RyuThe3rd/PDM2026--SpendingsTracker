import '../../listaDeImports.dart';


class Admin extends Usuario{
  Admin({required super.id,
    required super.nome,
    required super.apelido,
    required super.nrDeTelefone,
    super.premium = null}){
    //Rui: se for null então é admin

    super.tipo = Tipo.Admin;

  }

}