import 'dart:ui';
import 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/providers/transacoesProvider.dart';
import 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/providers/userProvider.dart';

import 'listaDeImports.dart';

void main() async {
  //fala com o OS mas sem necessariamente iniciar a renderização no flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  /*Rui: inicializar Firebase para android
  (não temos firebase options pq eu não vou rodar npm install
  e não precisamos de web ou IOS)
  */
  await Firebase.initializeApp(
  );

  //chamar o serviço de coletar mensagens
  final transacoesRepo = TransacoesRepo();
  //transacoesRepo.sincronizarSms();
  // fazer no initState da Tela home
  final usuarioRepo = UserRepo();
  final estatisticasRepo = EstatisticasRepo();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProviderGlobal()),
        Provider.value(value: transacoesRepo),
        ChangeNotifierProvider(create: (_) => TransacoesProvider(transacoesRepo)),
        ChangeNotifierProvider(create: (_) => UserProvider(usuarioRepo)),
        ChangeNotifierProvider(create: (_) => EstatisticaProvider(estatisticasRepo)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Rui: Aceder diretamente à lingua do OS através do PlatformDispatcher
    final String sistemaIdioma = PlatformDispatcher.instance.locale.languageCode;

    return MaterialApp(
      title: "${sistemaIdioma == 'pt' ?'Finança Local' : 'Spendings Tracker'}",
      home: const TelaLogin(),
      routes: <String, WidgetBuilder>{
        '/Admin' : (contexto) => TelaAdmin(),
        '/User' : (contexto) => TelaUser(),
        '/Login' : (contexto) => TelaLogin(),
        '/Cadastro' : (contexto) => TelaCadastro(),
        '/Home' : (contexto) => TelaHome(),
      }
    );
  }
}
