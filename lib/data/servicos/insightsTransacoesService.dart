import 'package:http/http.dart' as http;
import '../../listaDeImports.dart';


class InsightsTransacoesService {
  static const String _url =
      'https://deepseek-api-2026-439822594322.africa-south1.run.app/ai';

  Future<Insight?> gerarInsight({
    required List<Map<String, dynamic>> transacoes,
    required PeriodoEstatistica periodo,
  }) async {


    final transacoesDoPeriodo = _filtrarPorPeriodo(
      transacoes: transacoes,
      periodo: periodo,
    );

    if (transacoesDoPeriodo.isEmpty) {
      return periodo == PeriodoEstatistica.semanal
          ?
      Insight(
          textoDoInsight: 'Não foram encontradas transações desta semana.',
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta)
          : Insight(
          textoDoInsight: "Não foram encontradas transações deste mês.",
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta);
    }

    final resumo = _montarResumo(transacoesDoPeriodo);

    final promptSistema = '''
    Você é um assistente financeiro inteligente de uma aplicação mobile chamada SpendingsTracker.
    
    A aplicação ajuda o utilizador a entender os seus gastos, melhorar a literacia financeira e receber alertas úteis.
    
    Responda de forma curta, clara, humana e direta.
    
    A resposta deve ser apropriada para aparecer num card de insight financeiro.
    
    Estrutura esperada:
    Resumo:
    Comportamento:
    Alerta:
    Dica:
    
    Não invente valores.
    Use apenas os dados enviados.
    ''';

    final mensagem = '''
    Analise as transações abaixo e gere um insight financeiro ${periodo == PeriodoEstatistica.semanal ? 'semanal' : 'mensal'}.
    
    $resumo
    ''';

    try {
      final resposta = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mensagem': mensagem,
          'prompt_sistema': promptSistema,
        }),
      );

      if (resposta.statusCode != 200) {

        return Insight(
            textoDoInsight: "Houve um erro",
            data: DateTime.now(),
            tipo: TipoDeInsight.Alerta);
      }

      final data = jsonDecode(resposta.body);

      if (data['sucesso'] == true && data['response'] != null) {
        return gerarTipoInsight(data['response'].toString());
      }

      return Insight(
          textoDoInsight: "A IA não conseguiu gerar um insight válido.",
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta);
    } catch (e) {
      return Insight(
          textoDoInsight: "Erro ao conectar com o serviço de IA.",
          data: DateTime.now(),
          tipo: TipoDeInsight.Alerta);

    }
  }

  Insight gerarTipoInsight(String dadosResponse){

    return Insight(
        textoDoInsight: dadosResponse,
        data: DateTime.now(),
        tipo: TipoDeInsight.Alerta);

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

        final inicio = DateTime(
          inicioSemana.year,
          inicioSemana.month,
          inicioSemana.day,
        );

        return data.isAfter(inicio) || _mesmoDia(data, inicio);
      }

      if (periodo == PeriodoEstatistica.mensal) {
        return data.year == agora.year && data.month == agora.month;
      }

      return false;
    }).toList();
  }

  String _montarResumo(List<Map<String, dynamic>> transacoes) {
    final buffer = StringBuffer();

    double total = 0;

    buffer.writeln('Número de transações: ${transacoes.length}');

    for (final transacao in transacoes) {
      final valor = _converterValor(transacao['valor']);
      final data = _converterData(transacao['data']);
      final remetente = transacao['remetente'] ?? 'Desconhecido';
      final corpo = transacao['corpo'] ?? '';

      total += valor;

      buffer.writeln(
        '- Data: ${data?.toIso8601String() ?? 'Sem data'} | '
            'Canal: $remetente | '
            'Valor: $valor MT | '
            'Mensagem: $corpo',
      );
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

    if (valor is String) {
      return double.tryParse(valor.replaceAll(',', '.')) ?? 0.0;
    }

    return 0.0;
  }

  bool _mesmoDia(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}