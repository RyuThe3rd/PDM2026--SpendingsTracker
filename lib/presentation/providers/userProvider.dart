import '../../../listaDeImports.dart';

class UserProvider extends ChangeNotifier {

  final InterfaceAutenticacao _userRepo;

  UserProvider(this._userRepo);

  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  criarUsuario(Map<String, dynamic> dadosDePerfil) async {

    /*cria e adiciona na firestore
    com uid do User do currentUser do firebase Auth
     */
    await _userRepo.registar(dadosDePerfil);
    //retorna UsuarioModel as Usuario
    // que depois é passado para o provider
    // e depois consumido na tela de Usuario
    _usuario = usuario;
    notifyListeners();
  }

  editarUsuario(Map<String, dynamic> dadosDePerfil) async {
    await _userRepo.editarPerfil(dadosDePerfil);
    //retorna UsuarioModel as Usuario
    // que depois é passado para o provider
    // e depois consumido na tela de Usuario
    _usuario = usuario;
    notifyListeners();
  }

  removerUsuarioCorrente(Usuario usuario) async {

    /*cria e adiciona na firestore
    com uid do User do currentUser do firebase Auth
     */
    await _userRepo.eliminarContaEDados();
    _usuario = usuario;
    notifyListeners();
  }

  removerUsuarioPorId(String uid) async {
    /*cria e adiciona na firestore
    com uid do User do currentUser do firebase Auth
     */
    await _userRepo.eliminarUsuario(uid);
    notifyListeners();
  }
  set usuario(Usuario value) {
    _usuario = value;
  }

  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  bool get estaLogado => _currentUser != null;
}
