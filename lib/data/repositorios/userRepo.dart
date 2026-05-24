import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../dominio/contratos/interfaceAutenticacao.dart';

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
  Future<bool> registar(Map<String, dynamic> dadosDeRegisto) async {
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

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> editarPerfil(Map<String, dynamic> dadosDePerfil) async {
    // Lógica para atualizar firestore e depois Firebase Auth
    await _firestore.collection('Users')
        .doc(currentUser!.uid)
        .update(dadosDePerfil);

    //atualiza password mesmo se não tiver realmente mudado
    await _firebaseAuth.currentUser!.updatePassword(dadosDePerfil['senha']);
    return true;
  }

  @override
  Future<bool> eliminarContaEDados() {
    // TODO: implement eliminarContaEDados
    throw UnimplementedError();
  }
}
