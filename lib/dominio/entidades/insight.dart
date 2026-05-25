
import "../../listaDeImports.dart";

class Insight {

  /*texto será gerado por uma IA (deepseek)
   ao recber histórico de várias transações de SMS
   */
  TipoDeInsight tipo;
  String textoDoInsight;
  DateTime data;

  Insight({
    required this.tipo,
    required this.textoDoInsight,
    required this.data,
  });


}