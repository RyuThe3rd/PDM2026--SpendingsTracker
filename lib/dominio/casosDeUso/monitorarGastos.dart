//IMPORTANTE
// peço para depois limparmos e por tudo na lista de imports
import '../contratos/interfaceTransasoes.dart';

class MonitorarGastos {

  InterfaceTransacoes _transacoes;

  MonitorarGastos(this._transacoes);

  Map<String, dynamic> gastoSemanal() {

    return Map();

    /*
    retornar um mapa do tipo:
     {
     dia da semana: {
    inicial: valor,
      levantado: valor,
      depositado: valor,
      final: }
      }

     */
  }

  Map<String, dynamic> gastoMensal(){
    /*
    algo tipo semana 1,
     semana 2,
      semana 3,
       semana4

       onde cada semana tem valor inicial,
        final, levantamento, deposito
     */

    return Map();
  }


}