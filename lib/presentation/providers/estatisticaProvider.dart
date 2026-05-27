import '../../listaDeImports.dart';

class EstatisticaProvider extends ChangeNotifier {
  final InterfaceEstatisticas _estatisticasRepo;
  final InterfaceTransacoes _transacoesRepo;

  EstatisticaSemanalModelo? _semanaAtual;
  EstatisticaMensalModelo? _mesAtual;
  bool _isLoading = false;

  EstatisticaProvider(this._estatisticasRepo, this._transacoesRepo);

  EstatisticaSemanalModelo? get semanaAtual => _semanaAtual;
  EstatisticaMensalModelo? get mesAtual => _mesAtual;
  bool get isLoading => _isLoading;

  Future<void> inicializarEstatisticas() async {
    _isLoading = true;
    notifyListeners();

    try {
      final agora = DateTime.now();
      
      //Gestão da Estatistica Semanal corrente
      _semanaAtual = await _estatisticasRepo.obterSemanaMaisRecente();
      final weekIdAgora = (_estatisticasRepo as EstatisticasRepo).getWeekId(agora);

      if (_semanaAtual == null) {
        // Primeira vez do usuário no app
        final monday = agora.subtract(Duration(days: agora.weekday - 1));
        _semanaAtual = await _estatisticasRepo.criarEstatisticaSemanalVazia(monday);
      } else if (_semanaAtual!.weekId != weekIdAgora) {
        // Se mudou de semana: Preencher gaps se existirem
        await (_estatisticasRepo).preencherGapsDeSemanas(
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

      //gestão da Estatistica Mensal corrente
      _mesAtual = await _estatisticasRepo.obterMesMaisRecente();
      final monthIdAgora = (_estatisticasRepo).getMonthId(agora);

      if (_mesAtual == null) {
        _mesAtual = await _estatisticasRepo.criarEstatisticaMensalVazia(agora);
      } else if (_mesAtual!.monthId != monthIdAgora) {
        _mesAtual = await _estatisticasRepo.criarEstatisticaMensalVazia(
          agora, 
          anteriorId: _mesAtual!.monthId
        );
      }

      await recarregarValoresDasEstatisticas();
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

  Future<void> recarregarValoresDasEstatisticas() async {
    if (_semanaAtual == null) return;

    final monitorar = MonitorarGastos(_transacoesRepo);

    //Atualizar dados da semana (Gráfico de barras e saldo semanal)
    final dadosSemanais = monitorar.gastoSemanal();
    double ganhoS = 0; // ganhoSemanal
    double gastoS = 0;

    dadosSemanais.forEach((dia, valores) {
      ganhoS += (valores['depositado'] as num).toDouble();
      gastoS += (valores['levantado'] as num).toDouble();
    });

    _semanaAtual!.valorGanho = ganhoS;
    _semanaAtual!.valorGasto = gastoS;
    _semanaAtual!.dadosDiarios = dadosSemanais;

    // Calcular a diferença comparativa se houver semana anterior
    if (_semanaAtual!.semanaAnteriorId != null) {
      final anterior = await (_estatisticasRepo as EstatisticasRepo).buscarSemanaPorId(_semanaAtual!.semanaAnteriorId!);
      if (anterior != null) {
        _semanaAtual!.diferencaComparativa = ((ganhoS - gastoS) - (anterior.valorGanho - anterior.valorGasto));
      }
    }

    //Atualizar dados do mês (Agregado das semanas)
    if (_mesAtual != null) {
      final dadosMensais = monitorar.gastoMensal();
      double ganhoM = 0; //ganhoMensal
      double gastoM = 0;
      dadosMensais.forEach((sem, val) {
        ganhoM += (val['depositado'] as num).toDouble();
        gastoM += (val['levantado'] as num).toDouble();
      });
      _mesAtual!.valorGanho = ganhoM;
      _mesAtual!.valorGasto = gastoM;
      _mesAtual!.dadosSemanais = dadosMensais;
    }

    notifyListeners();
  }
}
