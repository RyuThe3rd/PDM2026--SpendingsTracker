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

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width * 0.8 ,
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: context.watch<ProviderGlobal>().login == 'azul' ? Image.asset('iconeAzul') : Image.asset('iconeBranco'),
            )
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