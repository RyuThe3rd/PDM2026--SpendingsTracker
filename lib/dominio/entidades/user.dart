import '../../listaDeImports.dart';


class Usuario{

  int _id;
  String _nome;
  String _apelido;
  String _nrDeTelefone;

  Tipo _tipo;
  /*Rui: se for admin é a mesma coisa que premium
  */

  bool? _premium;
  /*Rui: se não foi premium
   então todas funcionalidades serão só de user normal
  */

  Usuario({required id,
    required String nome,
    required String apelido,
    required String nrDeTelefone,
    bool? premium = false
  }):
      this._id = id,
        this._nome = nome,
        this._apelido = apelido,
        this._premium = premium,
        this._nrDeTelefone = nrDeTelefone,
        this._tipo = Tipo.Usuario;

  bool get premium => _premium!;

  /*
  Rui: função para saber se o user tem acesso premium
   (pode ser admin ou user premium)
  */
  bool get temAcessoPremium => _premium! || _tipo == Tipo.Admin || _tipo == Tipo.UsuarioPremium;

  set premium(bool value) {
    _premium = value;
  }

  Tipo get tipo => _tipo;

  set tipo(Tipo value) {
    _tipo = value;
  }

  String get apelido => _apelido;

  set apelido(String value) {
    _apelido = value;
  }

  String get nome => _nome;

  set nome(String value) {
    _nome = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  @override
  String toString() {
    return 'User{_id: $_id, _nome: $_nome, _apelido: $_apelido, _tipo: ${_tipo.name}, _premium: $_premium}';
  }


}
