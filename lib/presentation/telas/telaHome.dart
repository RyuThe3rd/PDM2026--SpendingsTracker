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
    // Sincronizar SMS ao iniciar a tela
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //sim, State tem build context como uma variável
      //consequentemente tem context mesmo fora do metodo build
      final transacoesProvider = Provider.of<TransacoesProvider>(context, listen: false);
      await transacoesProvider.transacoesRepo.sincronizarSms();
      //transacoesProvider.atualizarTransacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 254),
      appBar: AppBar(
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
        title: const Text(
          "Finança Local",
          style: TextStyle(color: Color.fromARGB(255, 23, 24, 106), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color.fromARGB(255, 23, 24, 106)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 25),
            _buildChartSection(),
            const SizedBox(height: 25),
            _buildInsightCard(),
            const SizedBox(height: 25),
            _buildRecentActivityHeader(),
            const SizedBox(height: 15),
            _buildRecentActivityList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 23, 24, 106),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "SALDO ATUAL",
            style: TextStyle(color: Color.fromARGB(180, 255, 255, 255), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text("MT ", style: TextStyle(color: Color.fromARGB(150, 255, 255, 255), fontSize: 18)),
              Text("12.450,00", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildSmallStatsCard(Icons.arrow_upward, "GANHOS", "4.200,00"),
              const SizedBox(width: 15),
              _buildSmallStatsCard(Icons.arrow_downward, "GASTOS", "1.850,00", isNegative: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatsCard(IconData icon, String label, String value, {bool isNegative = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(30, 255, 255, 255),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: isNegative ? const Color.fromARGB(255, 255, 120, 120) : const Color.fromARGB(255, 120, 255, 120)),
                const SizedBox(width: 5),
                Text(label, style: const TextStyle(color: Color.fromARGB(180, 255, 255, 255), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Gráficos de\nGastos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color.fromARGB(255, 240, 240, 245), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _buildTabButton("SEMANAL", true),
                    _buildTabButton("MENSAL", false),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar("SEG", 0.4),
              _buildBar("TER", 0.7),
              _buildBar("QUA", 0.5),
              _buildBar("QUI", 1.0, isHighlighted: true),
              _buildBar("SEX", 0.65),
              _buildBar("SÁB", 0.3),
              _buildBar("DOM", 0.45),
            ],
          ),
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
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? const Color.fromARGB(255, 23, 24, 106) : Colors.grey)),
    );
  }

  Widget _buildBar(String day, double heightFactor, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          height: 100 * heightFactor,
          width: 30,
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

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 235, 236, 242),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb, color: Color.fromARGB(255, 23, 24, 106)),
          const SizedBox(height: 10),
          const Text("Dica do Mês", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
          const SizedBox(height: 5),
          const Text(
            "Você economizou 15% a mais em transporte comparado ao mês passado.",
            style: TextStyle(color: Color.fromARGB(255, 80, 80, 100), fontSize: 13),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Text("VER INSIGHTS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward, size: 14, color: Color.fromARGB(255, 23, 24, 106)),
            ],
          ),
        ],
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

  Widget _buildRecentActivityList() {
    return Column(
      children: [
        _buildActivityItem("M-Pesa: Depósito", "14 de Out, 10:24", "+500 MT", "ENTRADA", true),
        const SizedBox(height: 12),
        _buildActivityItem("IZI: Levantamento", "13 de Out, 18:45", "-200 MT", "SAÍDA", false),
        const SizedBox(height: 12),
        _buildActivityItem("e-Mola: Pagamento", "12 de Out, 09:12", "-1.250 MT", "SAÍDA", false),
      ],
    );
  }

  Widget _buildActivityItem(String title, String date, String amount, String status, bool isEntry) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 23, 24, 106),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.phone_android, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isEntry ? Colors.green : Colors.red)),
              Text(status, style: TextStyle(color: isEntry ? Colors.green : Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
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
