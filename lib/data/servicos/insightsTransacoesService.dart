import 'package:http/http.dart' as http;
import '../../listaDeImports.dart';

class InsightsTransacoesService {
  static const String _url =
      'https://deepseek-api-2026-439822594322.africa-south1.run.app/ai';

  Future<Insights?> gerarInsight({
    required List<Map<String, dynamic>> transacoes,
    required PeriodoEstatistica periodo,
  }) async {
    final transacoesDoPeriodo = _filtrarPorPeriodo(
      transacoes: transacoes,
      periodo: periodo,
    );

    if (transacoesDoPeriodo.isEmpty) {
      return Insights(
        data: DateTime.now(),
        dadosDeInsight: {
          TipoDeInsight.Alerta: periodo == PeriodoEstatistica.semanal
              ? 'Não foram encontradas transações desta semana.'
              : 'Não foram encontradas transações deste mês.',
        },
      );
    }

    final resumo = _montarResumo(transacoesDoPeriodo);

    final promptSistema = '''
    Você é um assistente financeiro inteligente de uma aplicação mobile chamada SpendingsTracker.
    A aplicação ajuda o utilizador a entender os seus gastos, melhorar a literacia financeira e receber alertas úteis.
    Responda de forma curta, clara, humana e direta.
    A resposta deve ser apropriada para aparecer num card de insight financeiro.
    
    Estrutura esperada:
    Resumo: ...
    Comportamento: ...
    Alerta: ...
    Dica: ...
    
    Responda no formato de etiquetas xml:
    <Resumo>conteúdo</Resumo>
    <Comportamento>conteúdo</Comportamento>
    <Alerta>conteúdo</Alerta>
    <Dica>conteúdo</Dica>
    
    Não invente valores. Use apenas os dados enviados.
    ''';

    final mensagem = '''
    Analise as transações abaixo e gere insights financeiros ${periodo == PeriodoEstatistica.semanal ? 'semanais' : 'mensais'}.
    $resumo
    ''';

    try {
      final resposta = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mensagem': mensagem,
          'prompt_sistema': promptSistema,
        }),
      );

      if (resposta.statusCode != 200) {
        return Insights(
          data: DateTime.now(),
          dadosDeInsight: {TipoDeInsight.Alerta: "Erro ao gerar insights."},
        );
      }

      final data = jsonDecode(resposta.body);
      if (data['sucesso'] == true && data['response'] != null) {
        return _parseXmlInsights(data['response'].toString());
      }

      return Insights(
        data: DateTime.now(),
        dadosDeInsight: {TipoDeInsight.Alerta: "A IA não retornou dados válidos."},
      );
    } catch (e) {
      return Insights(
        data: DateTime.now(),
        dadosDeInsight: {TipoDeInsight.Alerta: "Erro de conexão com a IA."},
      );
    }
  }

  Insights _parseXmlInsights(String xml) {
    Map<TipoDeInsight, String> insightsMap = {};
    
    for (var tipo in TipoDeInsight.values) {
      final tag = tipo.name; // Resumo, Comportamento, etc.
      final startTag = '<$tag>';
      final endTag = '</$tag>';
      
      if (xml.contains(startTag) && xml.contains(endTag)) {
        final content = xml.split(startTag)[1].split(endTag)[0].trim();
        if (content.isNotEmpty) {
          insightsMap[tipo] = content;
        }
      }
    }

    return Insights(
      data: DateTime.now(),
      dadosDeInsight: insightsMap,
    );
  }

  List<Map<String, dynamic>> _filtrarPorPeriodo({
    required List<Map<String, dynamic>> transacoes,
    required PeriodoEstatistica periodo,
  }) {
    final agora = DateTime.now();
    return transacoes.where((transacao) {
      final data = _converterData(transacao['data']);
      if (data == null) return false;
      if (periodo == PeriodoEstatistica.semanal) {
        final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));
        final inicio = DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day);
        return data.isAfter(inicio) || _mesmoDia(data, inicio);
      }
      return data.year == agora.year && data.month == agora.month;
    }).toList();
  }

  String _montarResumo(List<Map<String, dynamic>> transacoes) {
    final buffer = StringBuffer();
    double total = 0;
    buffer.writeln('Número de transações: ${transacoes.length}');
    for (final transacao in transacoes) {
      final valor = _converterValor(transacao['valor']);
      final data = _converterData(transacao['data']);
      total += valor;
      buffer.writeln('- Data: ${data?.toIso8601String()} | Valor: $valor MT | Msg: ${transacao['corpo']}');
    }
    buffer.writeln('Total movimentado: $total MT');
    return buffer.toString();
  }

  DateTime? _converterData(dynamic data) {
    if (data == null) return null;
    if (data is DateTime) return data;
    if (data is Timestamp) return data.toDate();
    return null;
  }

  double _converterValor(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();
    if (valor is String) return double.tryParse(valor.replaceAll(',', '.')) ?? 0.0;
    return 0.0;
  }

  bool _mesmoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
