import '../../listaDeImports.dart';


class AuthCasosDeUso {

  InterfaceAutenticacao _autenticador;

  AuthCasosDeUso(this._autenticador);

  Future<bool> login(String email, String senha) async {
    return await _autenticador.login(email, senha);
  }

  Future<void> logout() async => await _autenticador.logout();

  Future<bool> registar(Map<String, dynamic> dadosDeRegisto) async {

    final resposta = await _autenticador.registar(dadosDeRegisto);

    if( resposta != null && resposta is Usuario) return true;

    return false;
  }

  Future<bool> editarPerfil(Map<String, dynamic> dadosDePerfil) async {
    final resposta = await _autenticador.editarPerfil(dadosDePerfil);

    if( resposta != null && resposta is Usuario) return true;

    return false;
  }

  Future<bool> eliminarContaEDados() async {
    return await _autenticador.eliminarContaEDados();
  }

}