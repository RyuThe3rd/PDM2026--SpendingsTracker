import '../../listaDeImports.dart';

class UserRepo implements InterfaceAutenticacao {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _usersCache = [];

  //Rui: vai receber do UserProvider
  UserRepo({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
});
  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<bool> login(String email, String senha) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: senha);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async => await _firebaseAuth.signOut();

  @override
  Future<Usuario?> registar(Map<String, dynamic> dadosDeRegisto) async {
    try {
      //Rui: cria e faz login automaticamente
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: dadosDeRegisto['email'],
        password: dadosDeRegisto['senha'],
      );

      dadosDeRegisto.remove('senha');

      /*Rui: procura Users nesse user id (uid) específico
       e se não existir cria uma coleção e documento
       naquele momento
       */
      await _firestore.collection('Users')
          .doc(currentUser!.uid)
          .set(dadosDeRegisto);

      return UsuarioModelo.fromMap(dadosDeRegisto);
    } catch (e) {
      rethrow;
      return null;
    }
  }

  @override
  Future<Usuario> editarPerfil(Map<String, dynamic> dadosDePerfil) async {
    // Lógica para atualizar firestore e depois Firebase Auth
    await _firestore.collection('Users')
        .doc(currentUser!.uid)
        .update(dadosDePerfil);

    //atualiza password mesmo se não tiver realmente mudado
    if (dadosDePerfil.containsKey('senha')) {
      await _firebaseAuth.currentUser!.updatePassword(dadosDePerfil['senha']);
    }

    return UsuarioModelo.fromMap(dadosDePerfil);
  }

  @override
  Future<bool> eliminarContaEDados() {
    // TODO: implement eliminarContaEDados
    throw UnimplementedError();
  }

  @override
  Future<bool> eliminarUsuario(String uid) async {
    try {
      /*
      Rui: Sobre o Firebase Auth:
      O Firebase não permite que um usuário logado apague o Auth de outro usuário.
      O que fazemos aqui é remover os dados dele.
      */

      await _firestore.collection('Users').doc(uid).delete();
      //No Firestore, apagar um documento pai não apaga as sub-coleções automaticamente.
      await _eliminarDadosRelacionados(uid);

      print("Utilizador $uid e os seus dados foram eliminados com sucesso.");
      return true;
    } catch (e) {
      print("Erro ao eliminar utilizador: $e");
      rethrow;
    }
  }

  Future<void> _eliminarDadosRelacionados(String uid) async {
    var transacoes = await _firestore.collection('Users').doc(uid).collection('Transações').get();
    for (var doc in transacoes.docs) {
      await doc.reference.delete();
    }

    var estatisticas = await _firestore.collection('Users').doc(uid).collection('Estatisticas').get();
    for (var doc in estatisticas.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<bool> tornarPremium(String uid) async {
    try {
      await _firestore.collection('Users').doc(uid).update({
        'premium': true,
        'tipo': Tipo.UsuarioPremium.name,
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
