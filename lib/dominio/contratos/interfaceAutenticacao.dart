

//To Do: criar uma variável do tipo currentUser no userProvider
abstract interface class InterfaceAutenticacao {

  Future<bool> login(String email, String senha);

  Future<void> logout();

  Future<bool> registar(Map<String, dynamic> dadosDeRegisto);

  //há de editar atualizar o current user e atualizar por no firestore
  Future<bool> editarPerfil(Map<String, dynamic> dadosDePerfil);

  //há de editar atualizar o current user e atualizar por no firestore
  Future<bool> eliminarContaEDados();


}