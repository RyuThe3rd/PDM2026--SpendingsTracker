import '../../dominio/contratos/interfaceEstatisticas.dart';
import '../../listaDeImports.dart';

class EstatisticasRepo implements InterfaceEstatisticas {
  final FirebaseFirestore _firestore;
  final InsightsTransacoesService _insightsService = InsightsTransacoesService();

  EstatisticasRepo({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String getWeekId(DateTime date) {
    final monday = DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
    final weekNum = DateFormat('w').format(monday).padLeft(2, '0');
    return "${monday.year}-W$weekNum";
  }

  String getMonthId(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  @override
  Future<EstatisticaSemanalModelo?> obterSemanaMaisRecente() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Estatisticas')
        .where('periodo', isEqualTo: 'semanal')
        .orderBy('dataInicio', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return EstatisticaSemanalModelo.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<EstatisticaSemanalModelo> criarEstatisticaSemanalVazia(DateTime dataInicio, {String? anteriorId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final agora = DateTime.now();
    
    final inicio = DateTime(dataInicio.year, dataInicio.month, dataInicio.day);
    final domingo = inicio.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    final dataFim = domingo.isAfter(agora) ? agora : domingo;

    final estatistica = EstatisticaSemanalModelo(
      mes: DateFormat('MMMM', 'pt_BR').format(inicio),
      valorGanho: 0,
      valorGasto: 0,
      diferencaComparativa: 0,
      insights: Insights(data: agora, dadosDeInsight: {}),
      criadoEm: agora,
      weekId: getWeekId(inicio),
      semanaAnteriorId: anteriorId,
      semanaCounter: ((inicio.day - 1) / 7).floor() + 1,
      dadosDiarios: {},
    );

    estatistica.dataInicio = inicio;
    estatistica.dataFim = dataFim;

    if (uid != null) {
      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('Estatisticas')
          .doc(estatistica.weekId)
          .set(estatistica.toMap());
    }

    return estatistica;
  }

  Future<void> preencherGapsDeSemanas(DateTime dataUltima, DateTime dataAlvo) async {
    DateTime corrente = dataUltima.add(const Duration(days: 7));
    corrente = DateTime(corrente.year, corrente.month, corrente.day).subtract(Duration(days: corrente.weekday - 1));
    
    final alvoMonday = DateTime(dataAlvo.year, dataAlvo.month, dataAlvo.day).subtract(Duration(days: dataAlvo.weekday - 1));

    String? lastId = getWeekId(dataUltima);

    while (corrente.isBefore(alvoMonday)) {
      final nova = await criarEstatisticaSemanalVazia(corrente, anteriorId: lastId);
      lastId = nova.weekId;
      corrente = corrente.add(const Duration(days: 7));
    }
  }

  @override
  Future<EstatisticaMensalModelo?> obterMesMaisRecente() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Estatisticas')
        .where('periodo', isEqualTo: 'mensal')
        .orderBy('monthId', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return EstatisticaMensalModelo.fromMap(snapshot.docs.first.data());
  }

  @override
  Future<EstatisticaMensalModelo> criarEstatisticaMensalVazia(DateTime dataReferencia, {String? anteriorId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final agora = DateTime.now();

    final estatistica = EstatisticaMensalModelo(
      mes: DateFormat('MMMM', 'pt_BR').format(dataReferencia),
      ano: dataReferencia.year,
      valorGanho: 0,
      valorGasto: 0,
      diferencaComparativa: 0,
      insights: Insights(data: agora, dadosDeInsight: {}),
      criadoEm: agora,
      monthId: getMonthId(dataReferencia),
      semanasDoMesIds: [],
      dadosSemanais: {},
      mesAnteriorId: anteriorId,
    );

    if (uid != null) {
      await _firestore
          .collection('Users')
          .doc(uid)
          .collection('Estatisticas')
          .doc(estatistica.monthId)
          .set(estatistica.toMap());
    }

    return estatistica;
  }

  @override
  Future<Insights> gerarInsightSemanal(EstatisticaSemanalModelo estatistica) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Transações')
        .where("data", isGreaterThanOrEqualTo: estatistica.dataInicio)
        .where("data", isLessThanOrEqualTo: estatistica.dataFim)
        .get();

    List<Map<String, dynamic>> transacoes = snapshot.docs.map((doc) => doc.data()).toList();

    if (transacoes.isEmpty) {
      return Insights(data: DateTime.now(), dadosDeInsight: {TipoDeInsight.Alerta: "Sem transações nesta semana."});
    }

    Insights? resultado;
    if (estatistica.semanaAnteriorId != null) {

      resultado = await _insightsService.insightsDeFluxo(
        idEstatisticaAnterior: estatistica.semanaAnteriorId!,
        transacoes: transacoes,
        periodo: PeriodoEstatistica.semanal,
      );
    } else {
      resultado = await _insightsService.gerarInsight(
        transacoes: transacoes,
        periodo: PeriodoEstatistica.semanal,
      );
    }
    return resultado ?? estatistica.insights;
  }

  @override
  Future<Insights> gerarInsightMensal(EstatisticaMensalModelo estatistica) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final query = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Transações')
        .where("ano", isEqualTo: estatistica.ano)
        .where("mes", isEqualTo: estatistica.mes)
        .get();

    List<Map<String, dynamic>> transacoes = query.docs.map((doc) => doc.data()).toList();

    if (transacoes.isEmpty) {
      return Insights(data: DateTime.now(), dadosDeInsight: {TipoDeInsight.Alerta: "Sem transações neste mês."});
    }

    Insights? resultado;
    if (estatistica.mesAnteriorId != null) {

      resultado = await _insightsService.insightsDeFluxo(
        idEstatisticaAnterior: estatistica.mesAnteriorId!,
        transacoes: transacoes,
        periodo: PeriodoEstatistica.mensal,
      );
    } else {
      resultado = await _insightsService.gerarInsight(
        transacoes: transacoes,
        periodo: PeriodoEstatistica.mensal,
      );
    }
    return resultado ?? estatistica.insights;
  }

  Future<EstatisticaSemanalModelo?> buscarSemanaPorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Estatisticas')
        .doc(id)
        .get();

    if (!snapshot.exists) return null;
    return EstatisticaSemanalModelo.fromMap(snapshot.data()!);
  }

  Future<EstatisticaMensalModelo?> buscarMesPorId(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final snapshot = await _firestore
        .collection('Users')
        .doc(uid)
        .collection('Estatisticas')
        .doc(id)
        .get();

    if (!snapshot.exists) return null;
    return EstatisticaMensalModelo.fromMap(snapshot.data()!);
  }
}
