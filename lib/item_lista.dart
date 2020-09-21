import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:getx_firebase/localizacao.dart';

class ItemLista {
  DateTime date;
  Localizacao localizacao;

  ItemLista({this.date, this.localizacao});

  ItemLista.fromJson(Map<String, dynamic> json) {
    Timestamp time = json['date'];
    date = DateTime.fromMillisecondsSinceEpoch(time.millisecondsSinceEpoch);
    localizacao = json['localizacao'] != null
        ? new Localizacao.fromJson(json['localizacao'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    if (this.localizacao != null) {
      data['localizacao'] = this.localizacao.toJson();
    }
    return data;
  }
}
