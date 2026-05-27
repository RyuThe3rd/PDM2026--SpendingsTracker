import '../../listaDeImports.dart';

abstract interface class InterfaceEstatisticas {
  Future<EstatisticaSemanalModelo?> obterSemanaMaisRecente();
  Future<EstatisticaSemanalModelo> criarEstatisticaSemanalVazia(DateTime dataInicio, {String? anteriorId});
  Future<EstatisticaMensalModelo?> obterMesMaisRecente();
  Future<EstatisticaMensalModelo> criarEstatisticaMensalVazia(DateTime dataReferencia, {String? anteriorId});
  Future<Insights> gerarInsightSemanal(EstatisticaSemanalModelo estatistica);
  Future<Insights> gerarInsightMensal(EstatisticaMensalModelo estatistica);
}
