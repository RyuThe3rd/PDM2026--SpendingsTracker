//Nosso nome do diretório de pacote é longo
//podemos fazer export assim só de uma vez tipo JS

//packages
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:flutter/material.dart';
export 'package:provider/provider.dart';

//1- Camada de Dominio
    //1.1 - entidades
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/tipoTransacao.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/tipoUsuario.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/admin.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/transacoes.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/userpremium.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/entidades/usuario.dart';

  //1.2 - Casos de Uso
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/contratos/interfaceAutenticacao.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/dominio/contratos/interfaceTransasoes.dart';

//2- Camada de Dados
//2.1 - Servicos

//2.2- Modelos
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/modelos/transacoesModelo.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/modelos/usuarioModelos.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/modelos/adminModelo.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/modelos/userPremiumModelo.dart';

//2.3 - Repositorios
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/repositorios/transacoesRepo.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/data/repositorios/userRepo.dart';

//3- Presentation
//3.1-
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/telas/telaCadastro.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/telas/telaLogin.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/telas/telaHome.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/telas/telaUser.dart';
export 'package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/telas/telaAdmin.dart';

//3.2- Providers
export "package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/providers/outrosProvider.dart";
export "package:lecc_pdm_trabalho_pratico_agilio_manuel_rui_wilson/presentation/providers/transacoesProvider.dart";
