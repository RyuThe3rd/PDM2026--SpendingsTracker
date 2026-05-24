import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class ColetarTransacoes {
  final SmsQuery query = SmsQuery();

  Future<List<Map<String, dynamic>>> coletar() async {
    List<Map<String, dynamic>> transacoesExtraidas = [];

    var permission = await Permission.sms.status;
    if (permission.isGranted) {
      List<SmsMessage> messages = await query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 50,
      );

      for (var msg in messages) {

        //mensagens corporativas vem com um nome ao invês de numero né
        if (msg.address!.toUpperCase().contains("M-PESA")||
            msg.address!.toUpperCase().contains("E MOlA")
            || msg.address!.toUpperCase().contains("MBIM")) {

          // Extraímos os dados da mensagem para um Map
          transacoesExtraidas.add({
            'id_sms': msg.id,
            'remetente': msg.address,
            'corpo': msg.body,
            'data': msg.date ?? DateTime.now(),
            'valor': _extrairValor(msg.body ?? ""),
          });
        }
      }
    } else {
      await Permission.sms.request();
    }

    return transacoesExtraidas;
  }

  double _extrairValor(String body) {
    // Regex simples para capturar números (ex: 500.00)
    final regExp = RegExp(r'(\d+[\d.,]*)');
    final match = regExp.firstMatch(body);
    if (match != null) {
      return double.tryParse(match.group(0)?.replaceAll(',', '') ?? '0.0') ?? 0.0;
    }
    return 0.0;
  }
}