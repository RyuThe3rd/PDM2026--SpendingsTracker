import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

enum PeriodoInsight {
  semanal,
  mensal,
}

class InsightsTransacoesService {
  static const String _url =
      'https://deepseek-api-2026-439822594322.africa-south1.run.app/ai';

  Future<String> gerarInsight({
    required List<Map<String, dynamic>> transacoes,
    required PeriodoInsight periodo,
  }) async {
    if (transacoes.isEmpty) {
      return 'Ainda não existem transações suficientes para gerar insights.';
    }

    final transacoesDoPeriodo = _filtrarPorPeriodo(
      transacoes: transacoes,
      periodo: periodo,
    );

    if (transacoesDoPeriodo.isEmpty) {
      return periodo == PeriodoInsight.semanal
          ? 'Não foram encontradas transações desta semana.'
          : 'Não foram encontradas transações deste mês.';
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
Analise as transações abaixo e gere um insight financeiro ${periodo == PeriodoInsight.semanal ? 'semanal' : 'mensal'}.

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
        return 'Não foi possível gerar o insight neste momento.';
      }

      final data = jsonDecode(resposta.body);

      if (data['sucesso'] == true && data['response'] != null) {
        return data['response'].toString();
      }

      return 'A IA não conseguiu gerar um insight válido.';
    } catch (e) {
      return 'Erro ao conectar com o serviço de IA.';
    }
  }

  List<Map<String, dynamic>> _filtrarPorPeriodo({
    required List<Map<String, dynamic>> transacoes,
    required PeriodoInsight periodo,
  }) {
    final agora = DateTime.now();

    return transacoes.where((transacao) {
      final data = _converterData(transacao['data']);

      if (data == null) return false;

      if (periodo == PeriodoInsight.semanal) {
        final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));

        final inicio = DateTime(
          inicioSemana.year,
          inicioSemana.month,
          inicioSemana.day,
        );

        return data.isAfter(inicio) || _mesmoDia(data, inicio);
      }

      if (periodo == PeriodoInsight.mensal) {
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