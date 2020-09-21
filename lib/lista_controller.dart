import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:get/get.dart';
import 'package:getx_firebase/env.dart';
import 'package:getx_firebase/item_lista.dart';
import 'package:getx_firebase/localizacao.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:latlong/latlong.dart';

class ListaController extends GetxController {
  final RxList dados = [].obs;
  final RxString ipAtual = ''.obs;

  ListaController() {
    getAcessos();
    registrarAcesso();
  }
  getIp() async {
    try {
      const url = 'https://api.ipify.org';
      var response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {}
    return null;
  }

  registrarAcesso() async {
    String ip = await getIp();
    if (ip == null) return;
    ipAtual.value = ip;
    final url = 'http://api.ipstack.com/$ip?access_key=${env['api']}';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Localizacao local = Localizacao.fromJson(jsonDecode(response.body));
      FirebaseFirestore.instance
          .collection('acessos')
          .doc()
          .set({'date': DateTime.now(), 'localizacao': local.toJson()});
    }
  }

  obterTitle(int index) {
    String complemento = ipAtual == dados[index].localizacao.ip ? '(Você)' : '';
    Localizacao local = dados[index].localizacao;
    return '${local.city} - ${local.regionCode}   $complemento';
  }

  obterSubtitle(int index) {
    return '${DateFormat('dd/MM/yy hh:mm').format(dados[index].date)}';
  }

  getAcessos() async {
    FirebaseFirestore.instance
        .collection('acessos')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      final lista = querySnapshot.docs.map((DocumentSnapshot documentSnapshot) {
        return ItemLista.fromJson(documentSnapshot.data());
      }).toList();
      lista.sort((a, b) => b.date.compareTo(a.date));
      dados.value = lista;
    });
  }

  obterMarcadores() {
    List<Marker> marcadores = [];
    for (ItemLista item in dados.value) {
      marcadores.add(Marker(
          width: 35.0,
          height: 35.0,
          builder: (ctx) => new Container(
                  child: new Icon(
                Icons.pin_drop,
                color: Colors.black,
              )),
          point:
              LatLng(item.localizacao.latitude, item.localizacao.longitude)));
    }
    return marcadores;
  }
}
