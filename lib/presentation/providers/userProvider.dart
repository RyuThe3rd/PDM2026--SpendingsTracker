import '../../../listaDeImports.dart';

class UserProvider extends ChangeNotifier {

  final InterfaceAutenticacao _userRepo;

  UserProvider(this._userRepo);

  Usuario? _usuario;

  Usuario? get usuario => _usuario;

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
