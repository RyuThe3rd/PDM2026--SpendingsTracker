import '../../listaDeImports.dart';
import '../../dominio/casosDeUso/monitorarGastos.dart';

//este provider é suposto entregar o a Estatistica Semanal e Mensal corrente
//
class EstatisticaProvider extends ChangeNotifier {
  final InterfaceEstatisticas _estatisticasRepo;
  final agora = DateTime.now();
  EstatisticaSemanalModelo? _semanaAtual;
  EstatisticaMensalModelo? _mesAtual;
  bool _isLoading = false;

  EstatisticaProvider(this._estatisticasRepo){
    final agora = DateTime.now();

    _semanaAtual = EstatisticaSemanalModelo(
      mes: "${agora.month}",
      valorGanho: 0,
      valorGasto: 0,
      diferencaComparativa: 0,
      dadosDiarios: {},
      semanaCounter: ((agora.day - 1) / 7).floor() + 1,
      insight: InsightModelo(
        textoDoInsight: "Sem insights",
        data: agora,
        tipo: TipoDeInsight.Alerta,
      ),
    );

    _mesAtual = EstatisticaMensalModelo(
      mes: "${agora.month}",
      ano: agora.year,
      valorGanho: 0,
      valorGasto: 0,
      diferencaComparativa: 0,
      semanasDoMesIds: [],
      dadosSemanais: {},
      insight: InsightModelo(
        textoDoInsight: "Sem insights",
        data: agora,
        tipo: TipoDeInsight.Alerta,
      ),
    );

    _salvarNoFirestore();
  }

  EstatisticaSemanalModelo? get semanaAtual => _semanaAtual;
  EstatisticaMensalModelo? get mesAtual => _mesAtual;
  bool get isLoading => _isLoading;

  Future<void> carregarEstatisticas() async {
    _isLoading = true;
    notifyListeners();


  }

  Future<void> carregarInsights() async {

  }

  Future<void> _salvarNoFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_semanaAtual != null) {
      await firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Estatisticas')
          .add(_semanaAtual!.toMap());
    }

    if (_mesAtual != null) {
      await firestore
          .collection('Users')
          .doc(user.uid)
          .collection('Estatisticas')
          .add(_mesAtual!.toMap());
    }
  }
}
