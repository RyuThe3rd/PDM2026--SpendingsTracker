import 'package:cloud_firestore/cloud_firestore.dart';

import '../servicos/coletarTransacoes.dart';
import '../servicos/insightsTransacoesService.dart';

class TransacoesRepo {
  FirebaseFirestore? _firestore;

  final ColetarTransacoes _coletorSMS = ColetarTransacoes();
  final InsightsTransacoesService _insightsService = InsightsTransacoesService();

  final List<Map<String, dynamic>> _transacoesCache = [];

  TransacoesRepo({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> sincronizarSms() async {
    final novasTransacoes = await _coletorSMS.coletar();

    for (var transacao in novasTransacoes) {
      bool jaExiste = _transacoesCache.any(
            (t) => t['id_sms'] == transacao['id_sms'],
      );

      if (!jaExiste) {
        await adicionarTransacao(transacao);
      }
    }
  }

  Future<void> adicionarTransacao(Map<String, dynamic> transacao) async {
    _transacoesCache.add(transacao);

    await _firestore?.collection('Transações').add({
      ...transacao,
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  List<Map<String, dynamic>> obterTodas() {
    return _transacoesCache;
  }

  Future<String> gerarInsightSemanal() async {
    return await _insightsService.gerarInsight(
      transacoes: _transacoesCache,
      periodo: PeriodoInsight.semanal,
    );
  }

  Future<String> gerarInsightMensal() async {
    return await _insightsService.gerarInsight(
      transacoes: _transacoesCache,
      periodo: PeriodoInsight.mensal,
    );
  }
}