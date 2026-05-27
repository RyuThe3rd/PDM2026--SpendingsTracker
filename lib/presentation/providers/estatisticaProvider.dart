import '../../listaDeImports.dart';

class EstatisticaProvider extends ChangeNotifier {
  final InterfaceEstatisticas _estatisticasRepo;
  
  EstatisticaSemanalModelo? _semanaAtual;
  EstatisticaMensalModelo? _mesAtual;
  bool _isLoading = false;

  EstatisticaProvider(this._estatisticasRepo);

  EstatisticaSemanalModelo? get semanaAtual => _semanaAtual;
  EstatisticaMensalModelo? get mesAtual => _mesAtual;
  bool get isLoading => _isLoading;

  /// Método principal chamado na inicialização da TelaHome
  Future<void> inicializarEstatisticas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final agora = DateTime.now();
      
      // 1. GESTÃO SEMANAL
      _semanaAtual = await _estatisticasRepo.obterSemanaMaisRecente();
      final weekIdAgora = (_estatisticasRepo as EstatisticasRepo).getWeekId(agora);

      if (_semanaAtual == null) {
        // Primeira vez do usuário no app
        final monday = agora.subtract(Duration(days: agora.weekday - 1));
        _semanaAtual = await _estatisticasRepo.criarEstatisticaSemanalVazia(monday);
      } else if (_semanaAtual!.weekId != weekIdAgora) {
        // Mudou de semana! Preencher gaps se existirem
        await (_estatisticasRepo as EstatisticasRepo).preencherGapsDeSemanas(
          _semanaAtual!.dataInicio, 
          agora
        );
        // Criar a semana atual
        final monday = agora.subtract(Duration(days: agora.weekday - 1));
        _semanaAtual = await _estatisticasRepo.criarEstatisticaSemanalVazia(
          monday, 
          anteriorId: _semanaAtual!.weekId
        );
      }

      // 2. GESTÃO MENSAL
      _mesAtual = await _estatisticasRepo.obterMesMaisRecente();
      final monthIdAgora = (_estatisticasRepo as EstatisticasRepo).getMonthId(agora);

      if (_mesAtual == null) {
        _mesAtual = await _estatisticasRepo.criarEstatisticaMensalVazia(agora);
      } else if (_mesAtual!.monthId != monthIdAgora) {
        _mesAtual = await _estatisticasRepo.criarEstatisticaMensalVazia(
          agora, 
          anteriorId: _mesAtual!.monthId
        );
      }

      // 3. ATUALIZAR INSIGHTS SE NECESSÁRIO
      await carregarInsights();

    } catch (e) {
      debugPrint("Erro ao inicializar estatísticas: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarInsights() async {
    if (_semanaAtual != null) {
      await _estatisticasRepo.gerarInsightSemanal(_semanaAtual!);
    }
    if (_mesAtual != null) {
      await _estatisticasRepo.gerarInsightMensal(_mesAtual!);
    }
  }

  /// Chamado quando novas transações são sincronizadas para atualizar os valores
  void atualizarValoresComTransacoes(List<Transacoes> transacoes) {
    if (_semanaAtual == null) return;

    final monitorar = MonitorarGastos(_semanaAtual!.semanaAnteriorId as dynamic); // Apenas para reuso da lógica de cálculo
    // Nota: Aqui idealmente teríamos uma lógica no Repo para recalcular e persistir
    // Por agora, o inicializarEstatisticas trata da consistência estrutural.
  }
}
