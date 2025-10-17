import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/widgets/error_retry_widget.dart';

class PdfScreen extends StatefulWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  bool _isRetrying = false;
  Exception? _lastError;
  Key _futureBuilderKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is! List ||
        args.isEmpty ||
        args[0] is! ResumenPreoperacionalServer) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Preoperacional',
            style: TextStyle(fontSize: 16),
          ),
        ),
        body: const Center(
          child: Text(
            'Parámetros inválidos o faltantes',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final List params = args;
    final resumenPreoperacional = params[0] as ResumenPreoperacionalServer;
    final inspeccionService =
        Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    return FutureBuilder<PdfData>(
        key: _futureBuilderKey,
        future: _generatePdf(
            resumenPreoperacional, inspeccionService, loginService),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else if (snapshot.hasError) {
            _lastError = snapshot.error as Exception?;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Preoperacional ${resumenPreoperacional.resuPreId}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              body: ErrorRetryWidget(
                message: 'Error al generar el PDF',
                subtitle:
                    'No se pudo obtener la información del PDF. Verifica tu conexión a internet.',
                onRetry: () => _retryPdfGeneration(
                    resumenPreoperacional, inspeccionService, loginService),
                isLoading: _isRetrying,
                icon: Icons.picture_as_pdf,
              ),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data as PdfData;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Preoperacional ${resumenPreoperacional.resuPreId}',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () async {
                      final params = ShareParams(
                        text: 'Great picture',
                        files: [XFile(data.file.path)],
                      );
                      await SharePlus.instance.share(params);
                    },
                    tooltip: 'Compartir',
                  )
                ],
              ),
              body: PdfPreview(
                build: (format) => data.bytes,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                allowSharing: false,
                allowPrinting: false,
              ),
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Preoperacional ${resumenPreoperacional.resuPreId}',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              body: ErrorRetryWidget(
                message: 'No se pudo cargar el PDF',
                subtitle: 'Ocurrió un error inesperado al generar el PDF.',
                onRetry: () => _retryPdfGeneration(
                    resumenPreoperacional, inspeccionService, loginService),
                isLoading: _isRetrying,
                icon: Icons.picture_as_pdf,
              ),
            );
          }
        });
  }

  Future<void> _retryPdfGeneration(
    ResumenPreoperacionalServer resumenPreoperacional,
    InspeccionService inspeccionService,
    LoginService loginService,
  ) async {
    setState(() {
      _isRetrying = true;
      _futureBuilderKey = UniqueKey(); // Force rebuild of FutureBuilder
    });

    try {
      await Future.delayed(
          Duration(milliseconds: 100)); // Small delay to show loading
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _lastError = e as Exception?;
        });
      }
    }
  }

  // Genera el pdf
  Future<PdfData> _generatePdf(
      ResumenPreoperacionalServer resumenPreoperacional,
      InspeccionService inspeccionService,
      LoginService loginService) async {
    try {
      print('Starting PDF generation...');

      Pdf infoPdf = await inspeccionService
          .detatilPdf(loginService.selectedEmpresa, resumenPreoperacional)
          .timeout(Duration(seconds: 30), onTimeout: () {
        throw Exception('Timeout al obtener datos del PDF');
      });

      print('infoPdf: ${infoPdf.toJson()}');
      print('infoPdf.rutaLogo: ${infoPdf.rutaLogo}');
      print('infoPdf.urlFotoKm: ${infoPdf.urlFotoKm}');
      print('infoPdf.urlFotoCabezote: ${infoPdf.urlFotoCabezote}');
      print('infoPdf.urlFotoRemolque: ${infoPdf.urlFotoRemolque}');
      print('infoPdf.urlFotoGuia: ${infoPdf.urlFotoGuia}');
      print('infoPdf.firma: ${infoPdf.firma}');
      print('infoPdf.firmaAuditor: ${infoPdf.firmaAuditor}');

      print(
          'PDF data retrieved successfully, downloading additional images...');

      // Track failed images
      List<String> failedImages = [];

      // Validate and download images with timeout
      Uint8List? logoCliente;
      if (infoPdf.rutaLogo != null && infoPdf.rutaLogo!.isNotEmpty) {
        try {
          var responseLogoCliente = await get(Uri.parse(infoPdf.rutaLogo!))
              .timeout(Duration(seconds: 10));
          logoCliente = responseLogoCliente.bodyBytes;
        } catch (e) {
          print('Error downloading logo cliente: $e');
          failedImages.add('Logo Cliente');
          // Continue without logo
        }
      }

      Uint8List? logoQi;
      try {
        var responseLogoQi =
            await get(Uri.parse('https://qinspecting.com/img/Qi.png'))
                .timeout(Duration(seconds: 10));
        logoQi = responseLogoQi.bodyBytes;
      } catch (e) {
        print('Error downloading logo Qi: $e');
        failedImages.add('Logo Qi');
        // Continue without logo
      }

      Uint8List? fotoKilometraje;
      if (infoPdf.urlFotoKm != null && infoPdf.urlFotoKm!.isNotEmpty) {
        try {
          var responseKilometraje = await get(Uri.parse(infoPdf.urlFotoKm!))
              .timeout(Duration(seconds: 10));
          fotoKilometraje = responseKilometraje.bodyBytes;
        } catch (e) {
          print('Error downloading foto kilometraje: $e');
          failedImages.add('Foto Kilometraje');
          // Continue without image
        }
      }

      Uint8List? fotoCabezote;
      if (infoPdf.urlFotoCabezote != null &&
          infoPdf.urlFotoCabezote!.isNotEmpty) {
        try {
          var responseCabezote = await get(Uri.parse(infoPdf.urlFotoCabezote!))
              .timeout(Duration(seconds: 10));
          fotoCabezote = responseCabezote.bodyBytes;
        } catch (e) {
          print('Error downloading foto cabezote: $e');
          failedImages.add('Foto Cabezote');
          // Continue without image
        }
      }

      Uint8List? fotoRemolque;
      if (infoPdf.urlFotoRemolque != null &&
          infoPdf.urlFotoRemolque!.isNotEmpty) {
        try {
          var responseRemolque = await get(Uri.parse(infoPdf.urlFotoRemolque!))
              .timeout(Duration(seconds: 10));
          fotoRemolque = responseRemolque.bodyBytes;
        } catch (e) {
          print('Error downloading remolque image: $e');
          failedImages.add('Foto Remolque');
          // Continue without remolque image
        }
      }

      Uint8List? fotoGuia;
      if (infoPdf.urlFotoGuia != null && infoPdf.urlFotoGuia!.isNotEmpty) {
        try {
          var responseGuia = await get(Uri.parse(infoPdf.urlFotoGuia!))
              .timeout(Duration(seconds: 10));
          fotoGuia = responseGuia.bodyBytes;
          print(
              '✅ DEBUG: Foto de guía descargada exitosamente, tamaño: ${fotoGuia.length} bytes');
        } catch (e) {
          print('❌ DEBUG: Error downloading foto guia: $e');
          failedImages.add('Foto Guía');
          // Continue without guia image
        }
      } else {
        print('⚠️ DEBUG: urlFotoGuia es null o vacía: ${infoPdf.urlFotoGuia}');
      }

      Uint8List? firmaConductor;
      if (infoPdf.firma != null && infoPdf.firma!.isNotEmpty) {
        try {
          var resFirmaConductor = await get(Uri.parse(infoPdf.firma!))
              .timeout(Duration(seconds: 10));
          firmaConductor = resFirmaConductor.bodyBytes;
        } catch (e) {
          print('Error downloading firma conductor: $e');
          failedImages.add('Firma Conductor');
          // Continue without signature
        }
      }

      Uint8List? firmaAuditor;
      if (infoPdf.firmaAuditor != null && infoPdf.firmaAuditor!.isNotEmpty) {
        try {
          var resFirmaAuditor = await get(Uri.parse(infoPdf.firmaAuditor!))
              .timeout(Duration(seconds: 10));
          firmaAuditor = resFirmaAuditor.bodyBytes;
        } catch (e) {
          print('Error downloading firma auditor: $e');
          failedImages.add('Firma Auditor');
          // Continue without signature
        }
      }

      // Log failed images
      if (failedImages.isNotEmpty) {
        print('Failed to download images: ${failedImages.join(', ')}');
      }

      // Generate PDF
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final Size pageSize = page.getClientSize();

      // Draw rectangle used as margin
      page.graphics.drawRectangle(
          bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
          pen: PdfPen(PdfColor(0, 0, 0)));

      // Draw header
      final header = drawHeader(document, infoPdf, logoCliente, logoQi);
      document.template.top = header;

      // Generate PDF grid.
      final PdfGrid gridSummary = getGridSummary(infoPdf, pageSize,
          firmaConductor, firmaAuditor, resumenPreoperacional);

      final PdfGrid gridAnswers = getGridAnswers(infoPdf, pageSize, logoCliente,
          logoQi, fotoKilometraje, fotoCabezote, fotoRemolque, fotoGuia);

      // Draw grid
      PdfLayoutResult resultSummary = gridSummary.draw(
          page: page, bounds: Rect.fromLTWH(0, 60, 0, 0)) as PdfLayoutResult;

      // Draw the PDF grid
      gridAnswers.draw(
          page: page,
          bounds: Rect.fromLTWH(0, resultSummary.bounds.bottom, 0, 0));

      // Save the document
      final List<int> bytes = await document.save();
      document.dispose();

      // Create temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File(
          '${tempDir.path}/preoperacional_${resumenPreoperacional.resuPreId}.pdf');
      await tempFile.writeAsBytes(bytes);

      print('PDF generated successfully');
      return PdfData(file: tempFile, bytes: Uint8List.fromList(bytes));
    } catch (e) {
      print('Error generating PDF: $e');
      // Re-throw the exception so FutureBuilder can catch it
      rethrow;
    }
  }

  PdfPageTemplateElement drawHeader(PdfDocument document, Pdf infoPdf,
      Uint8List? logoCliente, Uint8List? logoQi) {
    final pageSize = document.pages[0].getClientSize();
    //Create the header with specific bounds
    PdfPageTemplateElement header =
        PdfPageTemplateElement(Rect.fromLTWH(0, 0, pageSize.width, 60));

    //Dibula el rectangulo que contiene el logo del cliente
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, 120, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo del cliente
    if (logoCliente != null) {
      header.graphics
          .drawImage(PdfBitmap(logoCliente), Rect.fromLTWH(1, 1, 118, 57));
    } else if (infoPdf.rutaLogo != null && infoPdf.rutaLogo!.isNotEmpty) {
      // Show "No URI" message only if there was a URL that failed
      header.graphics.drawString(
          'No URI', PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfBrushes.red,
          bounds: Rect.fromLTWH(1, 1, 118, 57),
          format: PdfStringFormat(
              lineAlignment: PdfVerticalAlignment.middle,
              alignment: PdfTextAlignment.center));
    }

    //Diduja el rectangulo con el titulo del pdf
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(120, 0, pageSize.width - 280, 60),
        pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el título del pdf
    header.graphics.drawString('${infoPdf.nombreFormatoPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(122, 0, pageSize.width - 285, 60),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja los rectangulos para el código y version del formato
    //Top-left
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(355, 0, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para CODIGO
    header.graphics.drawString(
        'Código', PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(355, 0, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));
    //Top-rigth
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(405, 0, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para CODIGO DE LA BASE
    header.graphics.drawString('${infoPdf.codFormtPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(405, 0, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Bottom-left
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(355, 30, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para VERSION
    header.graphics.drawString(
        'Versión', PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(355, 30, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Bottom-rigth
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(405, 30, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para VERSION DE LA BASE
    header.graphics.drawString('${infoPdf.versionFormtPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(405, 30, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja el rectangulo para logo de QI
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(455, 0, 60, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo de QI
    if (logoQi != null) {
      header.graphics
          .drawImage(PdfBitmap(logoQi), Rect.fromLTWH(462, 8, 45, 45));
    } else {
      // Show "No URI" message for Qi logo (it's always expected)
      header.graphics.drawString(
          'No URI', PdfStandardFont(PdfFontFamily.helvetica, 8),
          brush: PdfBrushes.red,
          bounds: Rect.fromLTWH(462, 8, 45, 45),
          format: PdfStringFormat(
              lineAlignment: PdfVerticalAlignment.middle,
              alignment: PdfTextAlignment.center));
    }

    //Return header
    return header;
  }

  PdfGrid getGridSummary(
      Pdf infoPdf,
      Size pageSize,
      Uint8List? firmaConductor,
      Uint8List? firmaAuditor,
      ResumenPreoperacionalServer resumenPreoperacional) {
    //Create a PDF grid
    final PdfGrid gridSummary = PdfGrid();
    //Secify the columns count to the grid.
    gridSummary.columns.add(count: 6);

    //Add header to the grid
    gridSummary.headers.add(3);
    gridSummary.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 5, right: 5, top: 0, bottom: 0));

    PdfGridRow rowSummary = gridSummary.headers[0];
    rowSummary.cells[0].value = '''CIUDAD Y FECHA: 
    ${infoPdf.fechaPreoperacional}''';
    rowSummary.cells[0].columnSpan = 2;
    rowSummary.cells[2].value = '''TIPO DE VEHÍCULO:
    ${infoPdf.tvDescripcion}''';
    rowSummary.cells[3].value = '''MARCA/LÍNEA/MODELO:
    ${infoPdf.mlm}''';
    rowSummary.cells[3].columnSpan = 2;
    rowSummary.cells[5].value = '''¿TANQUEO?
    ${infoPdf.tanque}''';

    PdfGridRow rowSummary1 = gridSummary.headers[1];
    rowSummary1.cells[0].value = '''KILOMETRAJE:
    ${infoPdf.kilometraje}''';
    rowSummary1.cells[1].value = '''NOMBRE QUIEN REALIZÓ LA INSPECCIÓN:
    ${infoPdf.conductor}''';
    rowSummary1.cells[1].columnSpan = 2;
    rowSummary1.cells[3].value = '''PLACA VEHÍCULO:
    ${infoPdf.placaVehiculo}''';
    rowSummary1.cells[4].value = '''PLACA REMOLQUE:
    ${infoPdf.placaRemolque}''';
    rowSummary1.cells[5].value = '''ESTADO:
    ${resumenPreoperacional.estado}''';

    PdfGridRow rowSummary2 = gridSummary.headers[2];
    rowSummary2.cells[0].value = 'N°. INSPECCIÓN';
    rowSummary2.cells[1].value = '${infoPdf.consecutivo}';
    rowSummary2.cells[2].value = 'FIRMA CONDUCTOR';
    if (firmaConductor != null) {
      rowSummary2.cells[3].style =
          PdfGridCellStyle(backgroundImage: PdfBitmap(firmaConductor));
    } else if (infoPdf.firma != null && infoPdf.firma!.isNotEmpty) {
      rowSummary2.cells[3].value = 'Sin firma';
      rowSummary2.cells[3].style = PdfGridCellStyle(
        textBrush: PdfBrushes.red,
        font: PdfStandardFont(PdfFontFamily.helvetica, 8),
      );
    }
    rowSummary2.height = 30;
    rowSummary2.cells[4].value = 'FIRMA DE QUIEN INSPECCIONA';
    if (firmaAuditor != null) {
      rowSummary2.cells[5].style =
          PdfGridCellStyle(backgroundImage: PdfBitmap(firmaAuditor));
    } else if (infoPdf.firmaAuditor != null &&
        infoPdf.firmaAuditor!.isNotEmpty) {
      rowSummary2.cells[5].value = 'Sin firma';
      rowSummary2.cells[5].style = PdfGridCellStyle(
        textBrush: PdfBrushes.red,
        font: PdfStandardFont(PdfFontFamily.helvetica, 8),
      );
    }

    // Styles for table
    gridSummary.style = PdfGridStyle(
      cellPadding: PdfPaddings(top: 2, left: 2, bottom: 2, right: 2),
      font: PdfStandardFont(PdfFontFamily.timesRoman, 8),
    );

    //Styles for headers
    //Styles for headers
    PdfStringFormat format = PdfStringFormat();
    format.alignment = PdfTextAlignment.center;
    format.lineAlignment = PdfVerticalAlignment.middle;
    // grid.columns[0].format = format;
    rowSummary2.cells[1].style = PdfGridCellStyle(
      format: PdfStringFormat(
          alignment: PdfTextAlignment.center,
          lineAlignment: PdfVerticalAlignment.middle),
      font: PdfStandardFont(PdfFontFamily.timesRoman, 10),
      textBrush: PdfBrushes.green,
    );
    rowSummary2.cells[0].stringFormat = format;
    rowSummary2.cells[2].stringFormat = format;
    rowSummary2.cells[4].stringFormat = format;
    rowSummary2.cells[5].stringFormat = format;

    return gridSummary;
  }

  //Create PDF grid and return
  PdfGrid getGridAnswers(
      Pdf infoPdf,
      Size pageSize,
      Uint8List? logoCliente,
      Uint8List? logoQi,
      Uint8List? fotoKilometraje,
      Uint8List? fotoCabezote,
      Uint8List? fotoRemolque,
      Uint8List? fotoGuia) {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 7);

    //Add header to the grid
    grid.headers.add(3);
    grid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 2, right: 2, top: 0, bottom: 0));

    //Styles for headers
    PdfStringFormat format = PdfStringFormat();
    format.alignment = PdfTextAlignment.center;
    format.lineAlignment = PdfVerticalAlignment.middle;

    //Styles for cells
    PdfStringFormat formatColumns = PdfStringFormat();
    formatColumns.alignment = PdfTextAlignment.left;
    formatColumns.lineAlignment = PdfVerticalAlignment.middle;

    //Add the rows to the grid
    PdfGridRow headerInfo = grid.headers[0];
    headerInfo.cells[0].value = 'S: Si 		N: No 		B: Bueno 		M: Malo';
    headerInfo.cells[0].columnSpan = 7;

    PdfGridRow header = grid.headers[1];
    header.cells[0].value = 'ITEM';
    header.cells[0].rowSpan = 2;
    header.cells[1].value = 'TIENE';
    header.cells[1].columnSpan = 2;
    header.cells[3].value = 'ESTADO';
    header.cells[3].columnSpan = 2;
    header.cells[5].value = 'OBSERVACIONES';
    header.cells[5].rowSpan = 2;
    header.cells[6].value = 'FOTO';
    header.cells[6].rowSpan = 2;

    PdfGridRow header1 = grid.headers[2];
    header1.cells[1].value = 'S';
    header1.cells[2].value = 'N';
    header1.cells[3].value = 'B';
    header1.cells[4].value = 'M';

    //Styles for headers
    grid.columns[0].format = format;
    grid.columns[0].width = pageSize.width - 320;
    grid.columns[1].format = format;
    grid.columns[2].format = format;
    grid.columns[3].format = format;
    grid.columns[4].format = format;
    grid.columns[5].format = format;
    grid.columns[5].width = pageSize.width - 350;
    grid.columns[6].format = format;
    grid.columns[6].width = pageSize.width - 450;

    DateTime fechaHoy = DateTime.now();
    //Add rows
    if (infoPdf.detalle.length > 0) {
      infoPdf.detalle.last.respuestas.add(RespuestaInspeccion(
          idItem: -1,
          item: 'Kilometraje',
          foto: infoPdf.urlFotoKm,
          fotoConverted: fotoKilometraje));

      infoPdf.detalle.last.respuestas.add(RespuestaInspeccion(
          idItem: -2,
          item: 'Cabezote',
          foto: infoPdf.urlFotoCabezote,
          fotoConverted: fotoCabezote));

      infoPdf.detalle.last.respuestas.add(RespuestaInspeccion(
          idItem: -3,
          item: 'Remolque',
          foto: infoPdf.urlFotoRemolque,
          fotoConverted: fotoRemolque));

      print(
          '🔍 DEBUG: Agregando respuesta de Guía - URL: ${infoPdf.urlFotoGuia}, fotoConverted: ${fotoGuia != null ? '${fotoGuia.length} bytes' : 'null'}');
      infoPdf.detalle.last.respuestas.add(RespuestaInspeccion(
          idItem: -4,
          item: 'Guía',
          foto: infoPdf.urlFotoGuia,
          fotoConverted: fotoGuia));

      infoPdf.detalle.forEach((categoria) {
        // Dibujas las categorias
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = categoria.categoria;
        row.cells[0].columnSpan = 7;
        row.cells[0].style =
            PdfGridCellStyle(backgroundBrush: PdfBrushes.lightGray);
        // Dibuja los items
        categoria.respuestas.forEach((respuesta) {
          addRows(grid, infoPdf, respuesta, formatColumns, fechaHoy);
        });
      });
    }

    return grid;
  }

  //Create and row for the grid.
  void addRows(PdfGrid grid, Pdf infoPdf, RespuestaInspeccion respuesta,
      PdfStringFormat formatColumns, DateTime fechaHoy) async {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = '${respuesta.item}';

    row.cells[0].style.stringFormat = formatColumns;
    if (respuesta.respuesta == 'S') {
      row.cells[1].value = 'X';
    } else if (respuesta.respuesta == 'N') {
      row.cells[2].value = 'X';
    } else if (respuesta.respuesta == 'B') {
      row.cells[3].value = 'X';
    } else {
      row.cells[4].value = 'X';
    }

    // Une las celdas de respuestas S, N, B, M y Observaciones para mostrar el kilometraje al final del pdf
    if (respuesta.idItem == -1) {
      row.cells[1].columnSpan = 5;
      row.cells[1].value = '${infoPdf.kilometraje} KM';
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == -2) {
      row.cells[1].columnSpan = 5;
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == -3) {
      row.cells[1].columnSpan = 5;
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == -4) {
      row.cells[1].columnSpan = 5;
      row.cells[1].style.stringFormat = formatColumns;
    }

    row.cells[5].style.stringFormat = formatColumns;

    if (respuesta.idItem == 1 && respuesta.fechaVencimiento != null ||
        respuesta.idItem == 3 && respuesta.fechaVencimiento != null ||
        respuesta.idItem == 4 && respuesta.fechaVencimiento != null ||
        respuesta.idItem == 5 && respuesta.fechaVencimiento != null ||
        respuesta.idItem == 6 && respuesta.fechaVencimiento != null ||
        respuesta.idItem == 7 && respuesta.fechaVencimiento != null) {
      // 1, "Licencia de Tránsito"
      row.cells[5].value =
          'Fecha de Vencimiento: ${respuesta.fechaVencimiento}';
      DateTime tempDate = DateTime.parse('${respuesta.fechaVencimiento}');
      final difference = tempDate.difference(fechaHoy).inDays;
      row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
          ? PdfBrushes.orange
          : PdfBrushes.red;
    } else {
      row.cells[5].value =
          '${respuesta.observacion == null ? '' : respuesta.observacion}';
    }

    if (respuesta.foto == null || respuesta.fotoConverted == null) {
      // Only show "No URI" if there was a URL that failed
      if (respuesta.foto != null && respuesta.foto!.isNotEmpty) {
        row.cells[6].value = 'Ver en web';
        row.cells[6].style = PdfGridCellStyle(
          textBrush: PdfBrushes.black,
          font: PdfStandardFont(PdfFontFamily.helvetica, 8),
        );
      } else {
        row.cells[6].value = '';
      }
    } else {
      try {
        row.cells[6].style = PdfGridCellStyle(
            backgroundImage: PdfBitmap(respuesta.fotoConverted!));
        row.height = 40;
      } catch (e) {
        print('Error setting image in PDF: $e');
        row.cells[6].value = 'No URI';
        row.cells[6].style = PdfGridCellStyle(
          textBrush: PdfBrushes.red,
          font: PdfStandardFont(PdfFontFamily.helvetica, 8),
        );
      }
    }
  }
}
