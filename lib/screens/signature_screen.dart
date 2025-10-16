import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SignatureScreen extends StatelessWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyStatelessWidget();
  }
}

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firmaService = Provider.of<FirmaService>(context);
    final loginService = Provider.of<LoginService>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);

    List<Widget> _widgetOptions = <Widget>[
      FutureBuilder(
          future: inspeccionService.checkConnection(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return FutureBuilder(
                  future:
                      firmaService.getInfoFirma(loginService.selectedEmpresa),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.data != null) {
                        final Firma dataFirma = snapshot.data as Firma;
                        return CardFirma(
                          infoFirma: dataFirma,
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: 50.0,
                            ),
                            Image(
                                image: AssetImage(
                                    'assets/images/boot_signature_2.gif')),
                            SizedBox(
                              width: 250,
                              child: DefaultTextStyle(
                                  style: TextStyle(
                                      fontSize: 30.0,
                                      fontFamily: 'Agne',
                                      color: Colors.black),
                                  child: GestureDetector(
                                    onTap: () {
                                      print("Tap Event");
                                    },
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: true,
                                      animatedTexts: [
                                        TypewriterAnimatedText(
                                            'Oops!!! Debe realizar su firma',
                                            speed: Duration(milliseconds: 100),
                                            textAlign: TextAlign.center),
                                      ],
                                    ),
                                  )),
                            )
                          ],
                        );
                      }
                    }
                  });
            } else {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: NoInternet(),
              );
            }
          }),
      TerminosCondiciones()
    ];
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Center(
        child: _widgetOptions.elementAt(firmaService.indexTabaCreateSignature),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.gesture),
            label: 'Firma',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.create),
            label: 'Realizar firma',
          ),
        ],
        currentIndex: firmaService.indexTabaCreateSignature,
        selectedItemColor: Colors.green,
        onTap: (value) => firmaService.updateTabIndex(value),
      ),
    );
  }
}

class CardFirma extends StatelessWidget {
  const CardFirma({Key? key, required this.infoFirma}) : super(key: key);

  final Firma infoFirma;

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    print(infoFirma.firma);
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        height: sizeScreen.height * 1,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _SignatureImage(
                  source: infoFirma.firma?.toString(),
                  height: sizeScreen.height * 0.4,
                ),
              ),
              SizedBox(height: 10),
              Divider(
                height: 15,
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Usuario',
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
                subtitle: Text('${infoFirma.fkNumeroDoc}'),
              ),
              ListTile(
                leading: Icon(Icons.fact_check_outlined),
                title: Text('Aceptó términos y condiciones?',
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
                subtitle: Text('${infoFirma.terminosCondiciones}'),
              ),
              ListTile(
                leading: Icon(Icons.date_range),
                title: Text('Fecha de realización',
                    style: TextStyle(color: Colors.black87, fontSize: 16)),
                subtitle: Text('${infoFirma.fechaControl}'),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureImage extends StatelessWidget {
  const _SignatureImage({Key? key, required this.source, required this.height})
      : super(key: key);
  final String? source;
  final double height;

  bool _looksLikeBase64(String s) {
    // Heurística simple: contiene ',' (data URI) o solo charset base64
    return s.startsWith('data:image') ||
        RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(s);
  }

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.isEmpty) {
      return Image(
        image: const AssetImage('assets/images/no-image.png'),
        height: height,
        fit: BoxFit.contain,
      );
    }

    try {
      final String value = source!;
      if (value.startsWith('http')) {
        // URL remota
        return FadeInImage(
          placeholder: const AssetImage('assets/images/loading-2.gif'),
          image: NetworkImage(value),
          height: height,
          fit: BoxFit.contain,
        );
      }

      // Base64: permitir prefijo data:image/...
      String pure = value;
      final commaIndex = value.indexOf(',');
      if (commaIndex != -1) {
        pure = value.substring(commaIndex + 1);
      }

      if (_looksLikeBase64(pure)) {
        Uint8List bytes = base64Decode(pure);
        return Image.memory(
          bytes,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Image(
            image: AssetImage('assets/images/no-image.png'),
            fit: BoxFit.contain,
          ),
        );
      }

      // Ruta local
      return FadeInImage(
        placeholder: const AssetImage('assets/images/loading-2.gif'),
        image: NetworkImage(value),
        height: height,
        fit: BoxFit.contain,
      );
    } catch (_) {
      return Image(
        image: const AssetImage('assets/images/no-image.png'),
        height: height,
        fit: BoxFit.contain,
      );
    }
  }
}
