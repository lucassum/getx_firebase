import 'package:firebase_core/firebase_core.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:get/get.dart';
import 'package:getx_firebase/item_lista.dart';
import 'package:getx_firebase/lista_controller.dart';
import 'package:latlong/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      defaultTransition: Transition.fade,
      home: Home()));
}

class Home extends StatelessWidget {
  Home({Key key}) : super(key: key);
  ListaController controller = Get.put(ListaController());
  final GlobalKey<FlipCardState> flipKey = GlobalKey<FlipCardState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.pin_drop),
              onPressed: () => flipKey.currentState.toggleCard())
        ],
        title: Text('Acessos'),
        centerTitle: true,
      ),
      body: Lista(flipKey),
    );
  }
}

class Lista extends GetView<ListaController> {
  final flipKey;

  Lista(this.flipKey);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: FlipCard(
          key: flipKey,
          back: FlutterMap(
            options: new MapOptions(
              center: LatLng(-14, -51),
              zoom: 3.0,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(
                markers: controller.obterMarcadores(),
              ),
            ],
          ),
          front: ListView.builder(
            itemCount: controller.dados.length,
            itemBuilder: (BuildContext context, int index) {
              return Obx(() => ListTile(
                    title: Text('${controller.obterTitle(index)}'),
                    subtitle: Text('${controller.obterSubtitle(index)}'),
                  ));
            },
          ),
        ),
      ),
    );
  }
}
