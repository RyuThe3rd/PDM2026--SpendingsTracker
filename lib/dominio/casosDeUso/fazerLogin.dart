

class Fazerlogin {

  InterfaceAutenticacao _autenticador;

  Fazerlogin(this._autenticador);

  Future<bool> login(String email, String senha) async {
    return await _autenticador.login(email, senha);
  }

}