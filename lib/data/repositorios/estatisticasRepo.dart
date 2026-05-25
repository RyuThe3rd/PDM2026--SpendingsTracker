import '../../dominio/contratos/interfaceEstatisticas.dart';
import '../../listaDeImports.dart';

class EstatisticasRepo implements InterfaceEstatisticas {

  FirebaseFirestore? _firestore;

  //tbh isto deveria ser uma interface
  // para podermos mover facilmente de provedor de Insights de AI
  final InsightsTransacoesService _insightsService = InsightsTransacoesService();

  EstatisticasRepo({
    FirebaseFirestore? firestore,
  }):
        _firestore = firestore
            ?? FirebaseFirestore.instance;


  /*atualizar estatistica semanal corrente
  (guardada no firestore)
  se a estatística semanal não existir,
  isso compromete a estatística mensal

  insights depensdem de transações
  se não houverem transações guardadas no firestore
   então não há insights

   essa coleta de um numero limite de transações
    do sms somente quando abrir o app pode não captar o numero
    completo de transações que alguêm (uma empresa) efectua

    então seria bom se houvesse uma coleta passiva de transações para o firestore
    mas isso implica consumo de net e carga (não sei quanto)

    e não sei como é que iria funcionar neste app baseado em login
   */

  Future<Insight> gerarInsightSemanal(EstatisticaSemanalModelo estatistica) async {
    // 1. Precisamos de buscar as transações da semana primeiro
    DateTime? inicio = estatistica.dataInicio; //data inicio é a segunda-feira de cada semana
    DateTime? fim = estatistica.dataFim; //data fim e data corrente serão a mesma variavel

    final snapshot = await _firestore!
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Transações')
        .where("data", isGreaterThanOrEqualTo: inicio)
        .where("data", isLessThanOrEqualTo: fim)
        .get();

    List<Map<String, dynamic>> _transacoes =
    snapshot.docs.map((doc) => doc.data()).toList();

    if (_transacoes.isEmpty) {
      return Insight(
          textoDoInsight: "Sem transações nesta semana.",
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta);
    }

    final insight = await _insightsService.gerarInsight(
      //como lidamos com listas vazias?
      transacoes: _transacoes,
      periodo: PeriodoEstatistica.semanal,
    );

    estatistica.insight = insight!;
    _firestore!.collection('Estatisticas').add(estatistica.toMap());

    return insight;
  }

  Future<Insight> gerarInsightMensal(EstatisticaMensalModelo estatistica) async {

    final query = await _firestore!
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Transações')
        .where("ano", isEqualTo: estatistica.ano)
        .where("mes", isEqualTo: estatistica.mes)
        .get();

   List<Map<String, dynamic>> _transacoes =
    query.docs.map((doc) => doc.data()).toList();

   if (_transacoes.isEmpty) {
      return Insight(
          textoDoInsight: "Sem transações neste mês.",
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta);
    }

    final insight = await _insightsService.gerarInsight(

      transacoes: _transacoes,
      periodo: PeriodoEstatistica.mensal,
    );

    estatistica.insight = insight!;
    _firestore!.collection('Estatisticas').add(estatistica.toMap());

    return insight!;
  }
}