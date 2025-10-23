import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:app_qinspecting/providers/providers.dart';

import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:app_qinspecting/services/services.dart';

class CreateSignatureScreen extends StatefulWidget {
  const CreateSignatureScreen({Key? key}) : super(key: key);

  @override
  State<CreateSignatureScreen> createState() => _CreateSignatureScreenState();
}

class _CreateSignatureScreenState extends State<CreateSignatureScreen> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.transparent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final inspeccionService = Provider.of<InspeccionService>(context);
    final firmaService = Provider.of<FirmaService>(context);
    final loginService = Provider.of<LoginService>(context);
    if (inspeccionService.isSaving) return LoadingScreen();
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Stack(
          children: [
            // Área de firma usando la librería signature
            Positioned.fill(
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent,
                width: screenSize.width,
                height: screenSize.height * 0.9,
              ),
            ),
            // Botón de volver atrás (al final para estar por delante)
            Positioned(
              left: 20,
              top: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.grey),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              color: Colors.black,
              onPressed: () async {
                if (_controller.isNotEmpty) {
                  try {
                    inspeccionService.isSaving = true;
                    final Uint8List? data = await _controller.toPngBytes();
                    if (data != null) {
                      final dir = await getExternalStorageDirectory();
                      final myImagePath =
                          '${dir!.path}/${loginService.selectedEmpresa.nombreBase}_${loginService.userDataLogged.numeroDocumento}.png';
                      print('myImagePath: $myImagePath');
                      File imageFile = File(myImagePath);

                      if (!await imageFile.exists()) {
                        imageFile.create(recursive: true);
                      }
                      imageFile.writeAsBytesSync(data);

                      print('myImagePath: $myImagePath');

                      Map<String, dynamic>? responseUploadFirma =
                          await inspeccionService.uploadImage(
                              path: myImagePath,
                              company: loginService.selectedEmpresa.nombreQi!
                                  .toLowerCase(),
                              folder: 'firmas');

                      Map dataFirmaSave = {
                        "base": loginService.selectedEmpresa.nombreBase,
                        "idFirma": null,
                        "terminosCondiciones": "SI",
                        "firma": responseUploadFirma?['path'],
                        "fkNumeroDoc":
                            loginService.userDataLogged.numeroDocumento
                      };
                      Map responseSaveFirma =
                          await firmaService.insertSignature(dataFirmaSave);

                      loginService.userDataLogged.idFirma =
                          responseSaveFirma['insertId'];
                      DBProvider.db.updateUser(loginService.userDataLogged);

                      inspeccionService.isSaving = false;
                      firmaService.updateTerminos('NO');
                      firmaService.updateTabIndex(0);

                      showSimpleNotification(
                          Text(responseSaveFirma['message']!),
                          leading: Icon(Icons.check),
                          autoDismiss: true,
                          background: Colors.green,
                          position: NotificationPosition.bottom);
                      Navigator.pop(context);
                    }
                  } on DioException catch (_) {
                    showSimpleNotification(
                        Text('No se ha podido guardar la firma'),
                        leading: Icon(Icons.check),
                        autoDismiss: true,
                        background: Colors.orange,
                        position: NotificationPosition.bottom);
                  }
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              color: Colors.black,
              onPressed: () {
                // La librería signature no tiene undo/redo nativo
                // Se puede implementar con un stack de puntos si es necesario
              },
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              color: Colors.black,
              onPressed: () {
                // La librería signature no tiene undo/redo nativo
                // Se puede implementar con un stack de puntos si es necesario
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              color: Colors.black,
              onPressed: () {
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
