import '../services/monitorar_gastos_service.dart';

class MonitorarGastos {
  final MonitorarGastosService service;

  MonitorarGastos(this.service);

  Future<void> executar() async {
    await service.monitorar();
  }
}