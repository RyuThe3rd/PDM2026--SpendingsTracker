import '../../listaDeImports.dart';

class Transacoes {

  TipoTransacao _tipo;
  FonteTransacao _fonte;
  double _valor;
  DateTime _data;
  int? _mes;
  int? _ano;

  Transacoes({required TipoTransacao tipo,
      required FonteTransacao fonte,
      required double valor,
      required DateTime? data}):
        this._tipo = tipo,
        this._fonte = fonte,
        this._valor = valor,
        this._data = data == null ? DateTime.now() : data,
        this._mes = data?.month,
        this._ano = data?.year;

  DateTime get data => _data;

  set data(DateTime value) {
    _data = value;
  }

  double get valor => _valor;

  set valor(double value) {
    _valor = value;
  }

  FonteTransacao get fonte => _fonte;

  set fonte(FonteTransacao value) {
    _fonte = value;
  }

  TipoTransacao get tipo => _tipo;

  set tipo(TipoTransacao value) {
    _tipo = value;
  }


}