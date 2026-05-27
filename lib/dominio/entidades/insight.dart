
import "../../listaDeImports.dart";

class Insights {

  /*texto será gerado por uma IA (deepseek)
   ao recber histórico de várias transações de SMS
   */

  Map<TipoDeInsight, String>? dadosDeInsight = {};
  //TipoDeInsight tipo;
  ///String textoDoInsight;
  DateTime data;

  Insights({
    //required this.tipo,
    //required this.textoDoInsight,
    required this.data,
    this.dadosDeInsight,
  });


}