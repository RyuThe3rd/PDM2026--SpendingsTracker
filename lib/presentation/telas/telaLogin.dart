import '../../listaDeImports.dart';

class TelaLoginCadastro extends StatelessWidget {
  const TelaLoginCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Erro ao carregar')));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const TelaLogin();
        }

        return const TelaHome();

      },
    );
  }
}

class TelaLogin extends StatelessWidget {
  const TelaLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ProviderGlobal>();
    bool estadoLogin = context.watch<ProviderGlobal>().login == "azul";
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 249, 254),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: width * 0.8,
            padding: const EdgeInsets.only(top: 60, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 23, 24, 106),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance, color: Color.fromARGB(255, 255, 255, 255), size: 40),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Finança Local",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 23, 24, 106),
                  ),
                ),
                Text(
                  estadoLogin ? "Bem-vindo de volta ao seu livro digital." :
                  "Bem-vindo à nova era do seu dinheiro.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color.fromARGB(255, 117, 117, 117), fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Seletor de Abas
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 238, 235, 241),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setLogin('branco'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !estadoLogin ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(0, 0, 0, 0),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !estadoLogin ? [const BoxShadow(color: Color.fromARGB(31, 0, 0, 0), blurRadius: 4)] : [],
                            ),
                            child: Center(
                              child: Text(
                                "Criar Conta",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: !estadoLogin ? const Color.fromARGB(255, 23, 24, 106) : const Color.fromARGB(255, 158, 158, 158),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setLogin('azul'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: estadoLogin ? const Color.fromARGB(255, 23, 24, 106) : const Color.fromARGB(0, 0, 0, 0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Entrar",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: estadoLogin ? const Color.fromARGB(255, 255, 255, 255) : const Color.fromARGB(255, 158, 158, 158),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                estadoLogin ? const PaginLoginAzul() : const TelaCadastro(),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(estadoLogin ? "Ainda não tem conta? " : "Já tem uma conta? "),
                    GestureDetector(
                      onTap: () => provider.setLogin(estadoLogin ? 'branco' : 'azul'),
                      child: Text(
                        estadoLogin ? "Criar conta" : "Entrar agora",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106)),
                      ),
                    ),
                  ],
                ),
                if (!estadoLogin) ...[
                  const SizedBox(height: 40),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user, color: Color.fromARGB(255, 158, 158, 158), size: 30),
                      SizedBox(width: 20),
                      Icon(Icons.lock, color: Color.fromARGB(255, 158, 158, 158), size: 30),
                      SizedBox(width: 20),
                      Icon(Icons.shield, color: Color.fromARGB(255, 158, 158, 158), size: 30),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Seus dados são protegidos por criptografia de ponta a ponta. Ao continuar, você concorda com nossos Termos de Uso e Política de Privacidade.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Color.fromARGB(255, 158, 158, 158)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PaginLoginAzul extends StatefulWidget {
  const PaginLoginAzul({super.key});
  @override
  State<PaginLoginAzul> createState() => _PaginLoginAzulState();
}

class _PaginLoginAzulState extends State<PaginLoginAzul> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [const BoxShadow(color: Color.fromARGB(13, 0, 0, 0), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Entrar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
          const SizedBox(height: 24),
          const Text("E-MAIL OU TELEFONE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "exemplo@mail.com",
              prefixIcon: const Icon(Icons.alternate_email, size: 20),
              filled: true,
              fillColor: const Color.fromARGB(255, 243, 244, 249),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("SENHA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
              TextButton(onPressed: () {}, child: const Text("Esqueci minha senha", style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 23, 24, 106)))),
            ],
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "........",
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: const Icon(Icons.visibility_outlined, size: 20),
              filled: true,
              fillColor: const Color.fromARGB(255, 243, 244, 249),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 23, 24, 106),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Entrar", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 18)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Color.fromARGB(255, 255, 255, 255)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}