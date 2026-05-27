import '../../listaDeImports.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final tProvider = Provider.of<TransacoesProvider>(context, listen: false);
      final eProvider = Provider.of<EstatisticaProvider>(context, listen: false);

      // Sincroniza dados do dispositivo/repositório
      await tProvider.transacoesRepo.sincronizarSms();
      //tProvider.atualizarTransacoes();

      // Gera os relatórios e insights baseados nas novas transações
      await eProvider.carregarEstatisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 254),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Consumer<EstatisticaProvider>(
              builder: (context, eProvider, _) => _buildBalanceCard(eProvider.semanaAtual),
            ),
            const SizedBox(height: 25),

            //Gráfico de Gastos Dinâmico
            Consumer<EstatisticaProvider>(
              builder: (context, eProvider, _) => _buildChartSection(eProvider.semanaAtual),
            ),
            const SizedBox(height: 25),
            //Card de Insights da IA
            Consumer<EstatisticaProvider>(
              builder: (context, eProvider, _) => _buildInsightCard(eProvider.semanaAtual?.insights),
            ),
            const SizedBox(height: 25),
            _buildRecentActivityHeader(),
            const SizedBox(height: 15),

            //Lista de Atividades Recentes
            Consumer<TransacoesProvider>(
              builder: (context, tProvider, _) => _buildRecentActivityList(tProvider.transacoes),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 23, 24, 106),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
        ),
      ),
      title: const Text("Finança Local", style: TextStyle(color: Color.fromARGB(255, 23, 24, 106), fontWeight: FontWeight.bold)),
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Color.fromARGB(255, 23, 24, 106)), onPressed: () {}),
      ],
    );
  }

  Widget _buildBalanceCard(EstatisticaSemanal? semana) {
    // Busca o saldo 'final' do último dia registrado na semana
    double saldoFinal = 0.0;
    if (semana != null && semana.dadosDiarios!.isEmpty) {
      final ultimoDia = semana.dadosDiarios?.values.last;
      saldoFinal = (ultimoDia['final'] as num).toDouble();
    }

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 24, 106),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SALDO ATUAL", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text("MT ", style: TextStyle(color: Colors.white54, fontSize: 18)),
              Text(
                NumberFormat("#,##0.00", "pt_PT").format(saldoFinal),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildSmallStatsCard(Icons.arrow_upward, "GANHOS", semana?.valorGanho ?? 0.0),
              const SizedBox(width: 15),
              _buildSmallStatsCard(Icons.arrow_downward, "GASTOS", semana?.valorGasto ?? 0.0, isNegative: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(EstatisticaSemanal? semana) {
    final dados = semana?.dadosDiarios ?? {};

    // Cálculo da escala do gráfico
    double maxGasto = 1.0;
    for (var d in dados.values) {
      double levantado = (d['levantado'] as num).toDouble();
      if (levantado > maxGasto) maxGasto = levantado;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Gráficos de\nGastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
              _buildToggleButtons(),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dados.isEmpty
                ? [const Expanded(child: Center(child: Text("Processando estatísticas...", style: TextStyle(color: Colors.grey))))]
                : dados.entries.map((e) {
              double gastoDoDia = (e.value['levantado'] as num).toDouble();
              return _buildBar(
                  e.key.substring(0, 3).toUpperCase(),
                  (gastoDoDia / maxGasto).clamp(0.1, 1.0),
                  isHighlighted: DateFormat('EEEE').format(DateTime.now()) == _traduzirDia(e.key)
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color.fromARGB(255, 240, 240, 245), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          _buildTabButton("SEMANAL", true),
          _buildTabButton("MENSAL", false),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
      ),
      child: Text(text, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: active ? const Color.fromARGB(255, 23, 24, 106) : Colors.grey)),
    );
  }

  Widget _buildBar(String day, double heightFactor, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          height: 100 * heightFactor,
          width: 25,
          decoration: BoxDecoration(
            color: isHighlighted ? const Color.fromARGB(255, 185, 215, 190) : const Color.fromARGB(255, 215, 215, 225),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInsightCard(Insights? insight) {
    if (insight == null || insight.dadosDeInsight == null || insight.dadosDeInsight!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Definimos uma prioridade para escolher qual categoria mostrar na Home
    final prioridade = [
      TipoDeInsight.Alerta,
      TipoDeInsight.Orcamento,
      TipoDeInsight.Investimento,
      TipoDeInsight.Gastos,
      TipoDeInsight.Eficiencia,
      TipoDeInsight.Fluxo,
    ];

    TipoDeInsight? tipoSelecionado;
    for (var tipo in prioridade) {
      if (insight.dadosDeInsight!.containsKey(tipo)) {
        tipoSelecionado = tipo;
        break;
      }
    }

    //Rui: se não houver nenhum da prioridade, pega o Alerta
    tipoSelecionado = tipoSelecionado?? TipoDeInsight.Alerta;
    final textoExibido = insight.dadosDeInsight?[tipoSelecionado]
        ?? "Não há transações suficientes";

    IconData icon = Icons.lightbulb_outline;
    String tituloCard = "";

    switch (tipoSelecionado) {
      case TipoDeInsight.Alerta:
        icon = Icons.warning_amber_rounded;
        tituloCard = "Alerta de Gastos";
        break;
      case TipoDeInsight.Orcamento:
        icon = Icons.pie_chart;
        tituloCard = "Gestão de Orçamento";
        break;
      case TipoDeInsight.Investimento:
        icon = Icons.trending_up;
        tituloCard = "Sugestão de Investimento";
        break;
      case TipoDeInsight.Gastos:
        icon = Icons.shopping_bag_outlined;
        tituloCard = "Padrões de Consumo";
        break;
      case TipoDeInsight.Eficiencia:
        icon = Icons.speed;
        tituloCard = "Eficiência Financeira";
        break;
      case TipoDeInsight.Fluxo:
        icon = Icons.swap_horiz;
        tituloCard = "Comparação de Fluxo";
        break;
    }

    return GestureDetector(
      onTap: () {
        // Verificar se o usuário tem permissão para ver todos os insights
        final user = context.read<UserProvider>().usuario;

        if (user != null && user.temAcessoPremium) {
          Navigator.pushNamed(context, '/Insights');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Esta funcionalidade é exclusiva para membros Premium."),
              backgroundColor: Color.fromARGB(255, 23, 24, 106),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 236, 242),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color.fromARGB(255, 23, 24, 106)),
            const SizedBox(height: 10),
            Text(
              tituloCard, // Exibe o nome do tipo (Alerta, Dica, etc)
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 23, 24, 106)
              ),
            ),
            const SizedBox(height: 5),
            Text(
              textoExibido,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 15),
            const Row(
              children: [
                Text(
                  "VER MAIS INSIGHTS",
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 23, 24, 106)
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentActivityHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Atividade Recente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
        TextButton(onPressed: () {}, child: const Text("VER TUDO", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildRecentActivityList(List<Transacoes> transacoes) {
    final recentes = transacoes.reversed.take(3).toList();

    return Column(
      children: recentes.isEmpty
          ? [const Center(child: Text("Nenhuma transação encontrada.", style: TextStyle(color: Colors.grey)))]
          : recentes.map((t) => _buildActivityItem(
        title: "${t.fonte.name}: ${t.tipo.name}",
        date: DateFormat('dd MMM, HH:mm').format(t.data),
        amount: "${t.tipo == TipoTransacao.Levantamento ? '-' : '+'}${t.valor} MT",
        isEntry: t.tipo == TipoTransacao.Deposito,
      )).toList(),
    );
  }

  Widget _buildActivityItem({required String title, required String date, required String amount, required bool isEntry}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 5)]),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color.fromARGB(255, 23, 24, 106), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.phone_android, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color.fromARGB(255, 23, 24, 106))),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          )),
          Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isEntry ? Colors.green : Colors.red)),
        ],
      ),
    );
  }

  Widget _buildSmallStatsCard(IconData icon, String label, double value, {bool isNegative = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 10, color: isNegative ? Colors.redAccent : Colors.greenAccent),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ]),
            Text(value.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _traduzirDia(String dia) {
    const mapa = {'Segunda': 'Monday', 'Terça': 'Tuesday', 'Quarta': 'Wednesday', 'Quinta': 'Thursday', 'Sexta': 'Friday', 'Sábado': 'Saturday', 'Domingo': 'Sunday'};
    return mapa[dia] ?? '';
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, "Início", true),
          _buildNavItem(Icons.bar_chart, "Insights", false),
          _buildNavItem(Icons.account_balance_wallet, "Planos", false),
          _buildNavItem(Icons.person, "Perfil", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color.fromARGB(255, 23, 24, 106) : Colors.grey[400]),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: active ? const Color.fromARGB(255, 23, 24, 106) : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}