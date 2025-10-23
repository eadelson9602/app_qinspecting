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

class MyStatelessWidget extends StatefulWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  State<MyStatelessWidget> createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<MyStatelessWidget> {
  @override
  void initState() {
    super.initState();
    // Resetear estado cuando se inicializa la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final firmaService = Provider.of<FirmaService>(context, listen: false);
      firmaService.updateTerminos('NO');
      firmaService.updateTabIndex(0);
    });
  }

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
      drawer: CustomDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            // Botón de volver atrás con estilo iOS
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Contenido principal
            Padding(
              padding: EdgeInsets.fromLTRB(
                  20, 50, 20, 0), // Reducido el espacio superior
              child: Center(
                child: _widgetOptions
                    .elementAt(firmaService.indexTabaCreateSignature),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              // Botón Firma
              Expanded(
                child: InkWell(
                  onTap: () => firmaService.updateTabIndex(0),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.gesture_rounded,
                              color: firmaService.indexTabaCreateSignature == 0
                                  ? Color(0xFF34A853)
                                  : Color(0xFF606060),
                              size: 28,
                            ),
                            if (firmaService.indexTabaCreateSignature == 0)
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF34A853),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Botón Realizar firma
              Expanded(
                child: InkWell(
                  onTap: () => firmaService.updateTabIndex(1),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.create_rounded,
                              color: firmaService.indexTabaCreateSignature == 1
                                  ? Color(0xFF34A853)
                                  : Color(0xFF606060),
                              size: 28,
                            ),
                            if (firmaService.indexTabaCreateSignature == 1)
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF34A853),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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

    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 20, left: 1, right: 1),
      child: Container(
        height: sizeScreen.height * 1,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                // Card de imagen de firma con estilo iOS
                Container(
                  width: sizeScreen.width * 0.9,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _SignatureImage(
                      source: infoFirma.firma?.toString(),
                      height: sizeScreen.height * 0.4,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Información del usuario con iconos coloridos
                _buildInfoCard(
                  icon: Icons.person_outline_rounded,
                  iconColor: Color(0xFF2196F3), // Azul
                  title: 'Usuario',
                  subtitle: '${infoFirma.fkNumeroDoc}',
                ),

                SizedBox(height: 16),

                // Términos y condiciones
                _buildInfoCard(
                  icon: Icons.fact_check_outlined,
                  iconColor: Color(0xFF4CAF50), // Verde
                  title: 'Aceptó términos y condiciones?',
                  subtitle: '${infoFirma.terminosCondiciones}',
                ),

                SizedBox(height: 16),

                // Fecha de realización
                _buildInfoCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: Color(0xFFFF9800), // Naranja
                  title: 'Fecha de realización',
                  subtitle: '${infoFirma.fechaControl}',
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icono circular colorido
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          imageErrorBuilder: (context, error, stackTrace) {
            // Mostrar imagen por defecto cuando falla la carga
            return Image(
              image: const AssetImage('assets/images/no-image.png'),
              height: height,
              fit: BoxFit.contain,
            );
          },
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
        imageErrorBuilder: (context, error, stackTrace) {
          // Mostrar imagen por defecto cuando falla la carga
          return Image(
            image: const AssetImage('assets/images/no-image.png'),
            height: height,
            fit: BoxFit.contain,
          );
        },
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
