import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/providers/providers.dart';

import 'package:app_qinspecting/screens/loading_screen.dart';
import 'package:app_qinspecting/services/services.dart';

class CreateSignatureScreen extends StatefulWidget {
  const CreateSignatureScreen({Key? key}) : super(key: key);

  @override
  State<CreateSignatureScreen> createState() => _CreateSignatureScreenState();
}

class _CreateSignatureScreenState extends State<CreateSignatureScreen> {
  List<Offset> _points = [];
  List<List<Offset>> _strokes = [];
  List<List<Offset>> _undoStack = [];
  List<List<Offset>> _redoStack = [];

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
            // Área de firma
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _points = [details.localPosition];
                  _redoStack.clear();
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  // Solo agregar puntos si hay suficiente distancia para evitar puntos muy cercanos
                  if (_points.isEmpty ||
                      (_points.last - details.localPosition).distance > 2.0) {
                    _points.add(details.localPosition);
                  }
                });
              },
              onPanEnd: (details) {
                setState(() {
                  if (_points.isNotEmpty) {
                    _strokes.add(List.from(_points));
                    _undoStack.add(List.from(_points));
                    _points = [];
                  }
                });
              },
              child: CustomPaint(
                painter: SignaturePainter(_strokes, _points),
                size: Size(screenSize.width, screenSize.height * 0.9),
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
                if (_strokes.isNotEmpty || _points.isNotEmpty) {
                  try {
                    inspeccionService.isSaving = true;
                    final Uint8List? data = await _captureSignature();
                    if (data != null) {
                      final dir = await getExternalStorageDirectory();
                      final myImagePath =
                          '${dir!.path}/${loginService.selectedEmpresa.nombreBase}_${loginService.userDataLogged.numeroDocumento}.png';
                      File imageFile = File(myImagePath);
                      if (!await imageFile.exists()) {
                        imageFile.create(recursive: true);
                      }
                      imageFile.writeAsBytesSync(data);

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
                setState(() {
                  if (_strokes.isNotEmpty) {
                    _redoStack.add(_strokes.removeLast());
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_redoStack.isNotEmpty) {
                    _strokes.add(_redoStack.removeLast());
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              color: Colors.black,
              onPressed: () {
                setState(() {
                  _strokes.clear();
                  _points.clear();
                  _undoStack.clear();
                  _redoStack.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> _captureSignature() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final painter = SignaturePainter(_strokes, _points);
      painter.paint(canvas, Size(400, 300));
      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 300);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing signature: $e');
      return null;
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentPoints;

  SignaturePainter(this.strokes, this.currentPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.length > 1) {
        _drawSmoothPath(canvas, paint, stroke);
      }
    }

    // Draw current stroke
    if (currentPoints.length > 1) {
      _drawSmoothPath(canvas, paint, currentPoints);
    }
  }

  void _drawSmoothPath(Canvas canvas, Paint paint, List<Offset> points) {
    if (points.length < 2) return;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 2) {
      // Si solo hay 2 puntos, dibujar una línea recta
      path.lineTo(points[1].dx, points[1].dy);
    } else {
      // Para más de 2 puntos, usar curvas suaves
      for (int i = 1; i < points.length - 1; i++) {
        final currentPoint = points[i];
        final nextPoint = points[i + 1];

        // Calcular punto de control para curva suave
        final controlPoint1 = Offset(
          currentPoint.dx + (nextPoint.dx - currentPoint.dx) * 0.3,
          currentPoint.dy + (nextPoint.dy - currentPoint.dy) * 0.3,
        );

        final controlPoint2 = Offset(
          currentPoint.dx + (nextPoint.dx - currentPoint.dx) * 0.7,
          currentPoint.dy + (nextPoint.dy - currentPoint.dy) * 0.7,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          nextPoint.dx,
          nextPoint.dy,
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentPoints != currentPoints;
  }
}
