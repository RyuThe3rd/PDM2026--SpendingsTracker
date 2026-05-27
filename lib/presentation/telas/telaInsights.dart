import '../../listaDeImports.dart';

class TelaInsights extends StatefulWidget {  const TelaInsights({super.key});

@override
State<TelaInsights> createState() => _TelaInsightsState();
}

class _TelaInsightsState extends State<TelaInsights> {
  // Controle para alternar entre visão Semanal e Mensal
  PeriodoEstatistica periodoSelecionado = PeriodoEstatistica.semanal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 254),
      appBar: _construirAppBar(context),
      body: Consumer<EstatisticaProvider>(
        builder: (context, eProvider, child) {
          // Seleciona a estatística baseada no toggle (Semanal ou Mensal)
          final estatistica = periodoSelecionado == PeriodoEstatistica.semanal
              ? eProvider.semanaAtual
              : eProvider.mesAtual;

          if (eProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (estatistica == null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _construirTogglePeriodo(),
                  const SizedBox(height: 100),
                  const Center(
                    child: Text(
                      "Ainda não temos dados suficientes para gerar a sua análise deste período. Continue usando o app!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          final insights = estatistica.insights;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _construirTogglePeriodo(),
                const SizedBox(height: 30),
                const Text(
                  "ANÁLISE DE IA",
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 23, 24, 106),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Sugestões da IA baseadas nos teus SMS ${periodoSelecionado == PeriodoEstatistica.semanal ? 'da semana' : 'do mês'}",
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 23, 24, 106),
                  ),
                ),
                const SizedBox(height: 20),
                _construirBotaoPdf(),
                const SizedBox(height: 25),

                // Lista Dinâmica de Insights (Sugestão de Investimento, Gestão de Orçamento, etc)
                if (insights.dadosDeInsight != null)
                  ...insights.dadosDeInsight!.entries.map((entry) {
                    return _construirCardDeInsight(entry.key, entry.value);
                  }),

                const SizedBox(height: 10),

                _construirCardDeEficiencia(estatistica.diferencaComparativa, periodoSelecionado),
                const SizedBox(height: 20),

               _construirCardDeComparacaoDeFluxo(estatistica),
                const SizedBox(height: 20),

                _construirCardDePadroesDeGastos(estatistica),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _construirTogglePeriodo() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 238, 235, 241),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _construirBotaoAba("SEMANAL", PeriodoEstatistica.semanal),
          _construirBotaoAba("MENSAL", PeriodoEstatistica.mensal),
        ],
      ),
    );
  }

  Widget _construirBotaoAba(String texto, PeriodoEstatistica periodo) {
    bool ativo = periodoSelecionado == periodo;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            periodoSelecionado = periodo;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ativo ? const Color.fromARGB(255, 23, 24, 106) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: ativo ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _construirAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Color.fromARGB(255, 23, 24, 106),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ),
      title: Row(
        children: [
          const Text(
            "Finança Local",
            style: TextStyle(color: Color.fromARGB(255, 23, 24, 106), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 220, 225, 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "PREMIUM",
              style: TextStyle(color: Color.fromARGB(255, 23, 24, 106), fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Color.fromARGB(255, 23, 24, 106)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _construirBotaoPdf() {
    return InkWell(
      onTap: () {
        //Rui: Sevico para gerar PDF alguêm faça isso pfv
        //dependências/classes necessárias -> path_provider, File() e provavelmente filepicker
        ServicoGerarPDF().gerar();//essa classe está vazia
      },
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 2, 4, 86),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Gerar Relatório PDF",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCardDeInsight(TipoDeInsight tipo, String texto) {
    // Orçamento usa o estilo azul escuro do design
    bool isBudget = tipo == TipoDeInsight.Orcamento;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isBudget ? const Color.fromARGB(255, 23, 35, 120) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isBudget ? [] : [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isBudget
                  ? const Color.fromARGB(40, 255, 255, 255)
                  : const Color.fromARGB(255, 140, 245, 150),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isBudget ? Icons.pie_chart : Icons.trending_up,
              color: isBudget ? Colors.white : const Color.fromARGB(255, 0, 140, 50),
              size: 26,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _getInsightTitle(tipo),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isBudget ? Colors.white : const Color.fromARGB(255, 23, 24, 106),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            texto,
            style: TextStyle(
              color: isBudget ? Colors.white70 : Colors.black87,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Text(
                "Saber mais",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isBudget ? Colors.white : const Color.fromARGB(255, 23, 24, 106),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: isBudget ? Colors.white : const Color.fromARGB(255, 23, 24, 106),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getInsightTitle(TipoDeInsight tipo) {
    switch (tipo) {
      case TipoDeInsight.Investimento: return "Sugestão de Investimento";
      case TipoDeInsight.Orcamento:    return "Gestão de Orçamento";
      case TipoDeInsight.Eficiencia:   return "Eficiência de Gastos";
      case TipoDeInsight.Fluxo:        return "Comparação de Fluxo";
      case TipoDeInsight.Gastos:     return "Padrões de Gastos";
      case TipoDeInsight.Alerta:      return "Alerta Crítico";
      default: return "Insight Financeiro";
    }
  }

  Widget _construirCardDeEficiencia(double diferenca, PeriodoEstatistica periodo) {
    bool isPositive = diferenca >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 251, 248, 255),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              periodo == PeriodoEstatistica.semanal ? "Eficiência Semanal" : "Eficiência Mensal",
              style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                "${isPositive ? '+' : ''}${diferenca.toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Gastaste ${diferenca.abs().toStringAsFixed(0)}% a ${isPositive ? 'mais' : 'menos'} que o período passado",
            style: const TextStyle(fontSize: 13, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  Widget _construirCardDeComparacaoDeFluxo(Estatistica estatistica) {
    final max = (estatistica.valorGanho > estatistica.valorGasto ? estatistica.valorGanho : estatistica.valorGasto).clamp(1.0, double.infinity);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color.fromARGB(255, 241, 242, 248), borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Comparação de Fluxo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromARGB(255, 23, 24, 106))),
          const SizedBox(height: 25),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _colunaComLabel("ENTRADAS", (estatistica.valorGanho / max) * 100, const Color.fromARGB(255, 23, 24, 106)),
                _colunaComLabel("SAÍDAS", (estatistica.valorGasto / max) * 100, Colors.grey.shade400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _colunaComLabel(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(width: 35, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8))),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _construirBarraSimples(double heightPct, Color color) {
    return Container(
      width: 30,
      height: heightPct,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  Widget _construirCardDePadroesDeGastos(Estatistica estatistica) {
    final dados = (estatistica is EstatisticaSemanal)
        ? estatistica.dadosDiarios
        : (estatistica as EstatisticaMensal).dadosSemanais;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Padrões de Gastos vs\nRendimentos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color.fromARGB(255, 23, 24, 106))),
          const SizedBox(height: 20),
          Row(
            children: [
              _construirLegenda(Colors.green, "Entradas"),
              const SizedBox(width: 25),
              _construirLegenda(Colors.red, "Saídas"),
            ],
          ),
          const SizedBox(height: 25),
          // Gráfico de linha simulado
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(painter: LineChartPainter(dados)),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("SEG", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("TER", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("QUA", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("QUI", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("SEX", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text("SÁB", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _construirLegenda(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
final Map<String, dynamic>? dados;

LineChartPainter(this.dados);

@override
void paint(Canvas canvas, Size size) {
  if (dados == null || dados!.isEmpty) return;

  final greenPaint = Paint()..color = Colors.green.shade400..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
  final redPaint = Paint()..color = Colors.red.shade400..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;

  final values = dados!.values.toList();
  final stepX = size.width / (values.length - 1);

  // Escala para os gráficos (normalização)
  double maxVal = 1.0;
  for (var v in values) {
    if (v['depositado'] > maxVal) maxVal = v['depositado'].toDouble();
    if (v['levantado'] > maxVal) maxVal = v['levantado'].toDouble();
  }

  final pathGreen = Path();
  final pathRed = Path();

  for (int i = 0; i < values.length; i++) {
    double x = i * stepX;
    double yGreen = size.height - (values[i]['depositado'] / maxVal * size.height);
    double yRed = size.height - (values[i]['levantado'] / maxVal * size.height);

    if (i == 0) {
      pathGreen.moveTo(x, yGreen);
      pathRed.moveTo(x, yRed);
    } else {
      pathGreen.lineTo(x, yGreen);
      pathRed.lineTo(x, yRed);
    }
  }

  canvas.drawPath(pathGreen, greenPaint);
  canvas.drawPath(pathRed, redPaint);
}

@override
bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}