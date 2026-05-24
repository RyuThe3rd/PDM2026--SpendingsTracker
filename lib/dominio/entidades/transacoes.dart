enum TipoTransacao {
  Deposito,
  Levantamento,
  Consulta
}

enum FonteTransacao{
  Banco,
  ContaMovel
}

class Transacoes {

  TipoTransacao _tipo;
  FonteTransacao _fonte;
  double _valor;
  DateTime _data;

  Transacoes({required TipoTransacao tipo,
      required FonteTransacao fonte,
      required double valor,
      required DateTime? data}):
        this._tipo = tipo,
        this._fonte = fonte,
        this._valor = valor,
        this._data = data == null ? DateTime.now() : data
  ;


}