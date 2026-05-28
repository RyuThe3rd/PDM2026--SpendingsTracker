//To Do: criar uma variável do tipo currentUser no userProvider
import '../../listaDeImports.dart';

abstract interface class InterfaceAutenticacao {

  Future<bool> login(String email, String senha);

  Future<void> logout();

  //se retornou null então houve uma falha no registo
  Future<Usuario?> registar(Map<String, dynamic> dadosDeRegisto);

  //há de editar atualizar o current user e atualizar por no firestore
  Future<Usuario> editarPerfil(Map<String, dynamic> dadosDePerfil);

  //há de editar atualizar o current user e atualizar por no firestore
  Future<bool> eliminarContaEDados();

  Future<void> eliminarUsuario(String uid) async {}

  Future<void> tornarPremium(String uid);

}
