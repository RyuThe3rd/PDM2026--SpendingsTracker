import '../../listaDeImports.dart';
import 'package:flutter/material.dart';


class TelaLoginCadastro extends StatefulWidget {


  build(BuildContext context){

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        if (!snapshot.hasData) {
          return const TelaLogin();
        }

        //desnecessário dado que o current user está no firebase auth
        final user = snapshot.data!;
        return TelaHome;
      },
    );
  }
}

class TelaLogin extends StatefulWidget {

  build(BuildContext context){
bool loginEstado = context.watch<ProviderGlobal>().login == 'azul';
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width * 0.8 ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: context.watch<ProviderGlobal>().login == 'azul'
                  ? Image.asset('iconeAzul') : Image.asset('iconeBranco'),
            ),
            Container(
              color: Color.fromARGB(255, 239, 236, 241),
              padding: ,
              child: Row(
                children: [
                  Container(
                    color: loginEstado?
              Color.fromARGB(255, 239, 236, 241) :
                    Color.fromARGB(255, 255, 255, 255)
                    ,
                    child: Center(
                      child: Text(
                        "Criar Conta",
                        style: TextStyle(
                          color: loginEstado?
                          Color.fromARGB(255, 23, 24, 106):
                          Color.fromARGB(255, 23, 24, 106),

                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: loginEstado?
                    Color.fromARGB(255, 28, 37, 127) :
                    Color.fromARGB(255, 240, 237, 242)
                    ,
                    child:  Text(
                        "Entrar",
                      style: TextStyle(
                          color: loginEstado?
                          Color.fromARGB(255, 247, 247, 247):
                          Color.fromARGB(255, 178, 178, 186)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(loginEstado)...[
              paginLoginAzul(),
            ] else ...[
              TelaCadastro()
            ]
            ,

          ],
        ),
      ),
    ) ;
  }
}

class TelaCadastro extends StatefulWidget {
  build(BuildContext context){
    return ;
  }
}