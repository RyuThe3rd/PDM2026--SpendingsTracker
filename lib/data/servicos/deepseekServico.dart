import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../listaDeImports.dart';

class DeepseekServico {
  final String _apiUrl;
  final String _apiKey;

  DeepseekServico({required String apiUrl, required String apiKey})
      : _apiUrl = apiUrl,
        _apiKey = apiKey;

  String _transacoesParaString(List<Transacoes> transacoes) {
    final buffer = StringBuffer();
    for (var t in transacoes) {
      buffer.writeln(
          '${t.data.toIso8601String()} | Tipo: ${t.tipo.name} | Fonte: ${t.fonte.name} | Valor: ${t.valor}');
    }
    return buffer.toString();
  }

  Future<String> gerarInsightSemanal(List<Transacoes> transacoes) async {
    final dadosComoString = _transacoesParaString(transacoes);
    return await _enviarParaDeepseek(
      'Analisa estas transações da última semana e dá um insight financeiro útil:\n$dadosComoString',
    );
  }

  Future<String> gerarInsightMensal(List<Transacoes> transacoes) async {
    final dadosComoString = _transacoesParaString(transacoes);
    return await _enviarParaDeepseek(
      'Analisa estas transações do último mês e dá um insight financeiro útil:\n$dadosComoString',
    );
  }

  Future<String> _enviarParaDeepseek(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Erro ao obter insight: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erro de ligação: $e';
    }
  }
}
