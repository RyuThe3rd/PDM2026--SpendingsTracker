import '../../listaDeImports.dart';

class AuthCasosDeUso {

  InterfaceAutenticacao _autenticador;

  AuthCasosDeUso(this._autenticador);

  Future<bool> login(String email, String senha) async {
    return await _autenticador.login(email, senha);
  }

  Future<void> logout() async => await _autenticador.logout();

  Future<bool> registar(Map<String, dynamic> dadosDeRegisto) async {
    return await _autenticador.registar(dadosDeRegisto);
  }

  Future<bool> editarPerfil(Map<String, dynamic> dadosDePerfil) async {
    return await _autenticador.editarPerfil(dadosDePerfil);
  }

  Future<bool> eliminarContaEDados() async {
    return await _autenticador.eliminarContaEDados();
  }

}