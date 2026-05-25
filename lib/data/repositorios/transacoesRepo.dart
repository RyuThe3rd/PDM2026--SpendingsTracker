
import '../../listaDeImports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../servicos/coletarTransacoes.dart';

class TransacoesRepo implements InterfaceTransacoes {
  FirebaseFirestore? _firestore;
  final ColetarTransacoes _coletorSMS = ColetarTransacoes();
  final List<Map<String, dynamic>> _transacoesCache = [];

  //Rui: vai receber dependência do TransacoesProvider
  TransacoesRepo({
    FirebaseFirestore? firestore,
  }):
  _firestore = firestore
      ?? FirebaseFirestore.instance;


  Future<void> sincronizarSms() async {
  final novasTransacoes = await _coletorSMS.coletar();


    for (var transacao in novasTransacoes) {
      /*Verificar se já não existe no cache
      (pelo id_sms) para evitar duplicados
       */
      bool jaExiste =
      _transacoesCache.any((t) => t['id_sms'] == transacao['id_sms']);

      if (!jaExiste) {
      adicionarTransacao(transacao);
      }
    }
  }

  void adicionarTransacao(Map<String, dynamic> transacao) {
    _transacoesCache.add(transacao);
    _firestore?.collection('Transações').add(transacao);
  }

  List<Transacoes> obterTodas() {
    // Convertemos cada Map da cache para um objeto do tipo Transacoes
    return _transacoesCache.map((map) => TransacoesModelo.fromMap(map)).toList();
  }
}