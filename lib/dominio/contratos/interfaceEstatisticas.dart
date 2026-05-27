import '../../listaDeImports.dart';

abstract interface class InterfaceEstatisticas {
  Future<EstatisticaSemanalModelo?> obterSemanaMaisRecente();
  Future<EstatisticaSemanalModelo> criarEstatisticaSemanalVazia(DateTime dataInicio, {String? anteriorId});
  Future<EstatisticaMensalModelo?> obterMesMaisRecente();
  Future<EstatisticaMensalModelo> criarEstatisticaMensalVazia(DateTime dataReferencia, {String? anteriorId});
  Future<EstatisticaSemanalModelo?> buscarSemanaPorId(String id);
  Future<EstatisticaMensalModelo?> buscarMesPorId(String id);
  Future<Insights> gerarInsightSemanal(EstatisticaSemanalModelo estatistica);
  Future<Insights> gerarInsightMensal(EstatisticaMensalModelo estatistica);

}
