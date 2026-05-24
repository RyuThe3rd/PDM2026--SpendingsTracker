//Nosso nome do diretório de pacote é longo
//podemos fazer export assim só de uma vez tipo JS

//packages
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
//2.1 -

//2.2-

//2.3 -
