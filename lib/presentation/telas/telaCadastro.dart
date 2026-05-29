import '../../listaDeImports.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});
  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("NOME COMPLETO",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 23, 24, 106))),
        const SizedBox(height: 8),
        TextField(
          controller: _nomeController,
          decoration: InputDecoration(
            hintText: "Ex: Albino Manuel",
            suffixIcon: const Icon(Icons.person_outline),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 255, 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
          ),
        ),
        const SizedBox(height: 16),
        const Text("E-MAIL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "seu@email.com",
            suffixIcon: const Icon(Icons.mail_outline),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 255, 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
          ),
        ),
        const SizedBox(height: 16),
        const Text("NÚMERO DE TELEFONE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 55,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color.fromARGB(255, 224, 224, 224)),
              ),
              child: const Center(child: Text("+258", style: TextStyle(fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: "84 000 0000",
                  suffixIcon: const Icon(Icons.phone_android),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 255, 255),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("SENHA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 23, 24, 106))),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "........",
            suffixIcon: const Icon(Icons.visibility_off_outlined),
            filled: true,
            fillColor: const Color.fromARGB(255, 255, 255, 255),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 224, 224, 224))),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              try {
                final dadosDePerfil = {"nome" : _nomeController.text.trim(),
                                      "email" : _emailController.text.trim(),
                                      "telefone": _phoneController.text.trim(),
                                      "senha": _passwordController.text.trim()
                };
                await context.read<UserProvider>().criarUsuario(dadosDePerfil);

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
                Text("Criar minha conta", style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color.fromARGB(255, 255, 255, 255)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}