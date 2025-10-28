import 'package:printing/printing.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:app_qinspecting/services/services.dart';

class PdfScreenOffline extends StatelessWidget {
  const PdfScreenOffline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context)!.settings.arguments as List;
    final resumenPreoperacional = params[0] as ResumenPreoperacional;
    final loginService = Provider.of<LoginService>(context, listen: false);
    return FutureBuilder(
        future: _generatePdf(resumenPreoperacional, loginService),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return LoadingScreen();
          } else {
            var data = snapshot.data as PdfData;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Preoperacional ${resumenPreoperacional.id}',
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
              body: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: PdfPreview(
                  build: (format) => data.bytes,
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowSharing: false,
                  allowPrinting: false,
                ),
              ),
            );
          }
        });
  }

  // Genera el pdf
  Future<PdfData> _generatePdf(
      ResumenPreoperacional infoPdf, LoginService loginService) async {
    // Directory documentsDirectory = await getApplicationDocumentsDirectory();

    // Mapeamos las respuestas a una lista
    List<ItemsVehiculo> respuestas = [];
    List tempData = jsonDecode(infoPdf.respuestas!) as List;
    tempData.forEach((element) {
      // Tranformamor el elemento a una instancia de ItemsVehiculo
      final data = ItemsVehiculo.fromMap(element);
      // Filtramos los items que tienen respuesta
      final tempRespuestas =
          data.items.where((item) => item.respuesta != null).toList();
      // Si hay respuestas los pusheamos al array de respuestas
      if (tempRespuestas.length > 0) {
        respuestas.add(data);
      }
    });

    final infoVehiculo = await DBProvider.db.getVehiculoByPlate(infoPdf.placa!);

    // print('CABEZOTE 1 ${infoPdf.urlFotoRemolque}');

    // var firmaConductor = PdfBitmap(File(resumenPreoperacional.resuPreFotokm!).readAsBytesSync());
    // var firmaAuditor = PdfBitmap(File(resumenPreoperacional.resuPreFotokm!).readAsBytesSync());

    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle used how margin
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(0, 0, 0)));

    //Generate PDF grid.
    final PdfGrid gridSummary =
        getGridSummary(infoPdf, pageSize, infoVehiculo!, loginService);

    final PdfGrid gridAnswers = getGridAnswers(infoPdf, pageSize, respuestas);

    //Draw grid
    PdfLayoutResult resultSummary = gridSummary.draw(
        page: page, bounds: Rect.fromLTWH(0, 0, 0, 0)) as PdfLayoutResult;

    //Draw the PDF grid
    gridAnswers.draw(
        page: page,
        bounds: Rect.fromLTWH(0, resultSummary.bounds.bottom, 0, 0));

    //Save the PDF document
    final outputExternal = await getExternalStorageDirectory();
    final pathFile = '${outputExternal!.path}/preoperacional ${infoPdf.id}.pdf';

    final pdf = await document.save();

    await File(pathFile).writeAsBytes(pdf);

    Uint8List bytes = File(pathFile).readAsBytesSync();
    // Dispose the document.
    document.dispose();

    return PdfData(bytes: bytes, file: File(pathFile));
  }

  PdfPageTemplateElement drawHeader(PdfDocument document,
      ResumenPreoperacional infoPdf, PdfBitmap logoCliente, PdfBitmap logoQi) {
    final pageSize = document.pages[0].getClientSize();
    //Create the header with specific bounds
    PdfPageTemplateElement header =
        PdfPageTemplateElement(Rect.fromLTWH(0, 0, pageSize.width, 60));

    //Dibula el rectangulo que contiene el logo del cliente
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, 120, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo del cliente
    header.graphics.drawImage(logoCliente, Rect.fromLTWH(1, 1, 118, 57));

    //Diduja el rectangulo con el titulo del pdf
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(120, 0, pageSize.width - 280, 60),
        pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el título del pdf
    header.graphics.drawString('INSPECCIÓN DE VEHÍCULOS DE CARGA',
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
    header.graphics.drawString(
        'CODE', PdfStandardFont(PdfFontFamily.helvetica, 9),
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
    header.graphics.drawString('V', PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(405, 30, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja el rectangulo para logo de QI
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(455, 0, 60, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo de QI
    header.graphics.drawImage(logoQi, Rect.fromLTWH(462, 8, 45, 45));

    //Return header
    return header;
  }

  PdfGrid getGridSummary(ResumenPreoperacional infoPdf, Size pageSize,
      Vehiculo infoVehiculo, LoginService loginService) {
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
    ${infoPdf.ciudad} / ${infoPdf.fechaPreoperacional}''';
    rowSummary.cells[0].columnSpan = 2;
    rowSummary.cells[2].value = '''TIPO DE VEHÍCULO:
    PENDIENTE''';
    rowSummary.cells[3].value = '''MARCA/LÍNEA/MODELO:
    ${infoVehiculo.nombreMarca} / ${infoVehiculo.modelo}''';
    rowSummary.cells[3].columnSpan = 2;
    rowSummary.cells[5].value = '''¿TANQUEO?
    ${infoPdf.cantTanqueoGalones != null || infoPdf.cantTanqueoGalones != 0 ? 'SI' : 'NO'}''';

    PdfGridRow rowSummary1 = gridSummary.headers[1];
    rowSummary1.cells[0].value = '''KILOMETRAJE:
    ${infoPdf.kilometraje}''';
    rowSummary1.cells[1].value = '''NOMBRE QUIEN REALIZÓ LA INSPECCIÓN:
    ${loginService.userDataLogged.nombres}''';
    rowSummary1.cells[1].columnSpan = 2;
    rowSummary1.cells[3].value = '''PLACA VEHÍCULO:
    ${infoPdf.placa}''';
    rowSummary1.cells[4].value = '''PLACA REMOLQUE:
    ${infoPdf.placaRemolque != null ? infoPdf.placaRemolque : ''}''';
    rowSummary1.cells[5].value = '''ESTADO:
    PENDIENTE''';

    PdfGridRow rowSummary2 = gridSummary.headers[2];
    rowSummary2.cells[0].value = 'N°. INSPECCIÓN';
    rowSummary2.cells[1].value = '${infoPdf.id}';
    rowSummary2.cells[2].value = 'FIRMA CONDUCTOR';
    // rowSummary2.cells[3].style = PdfGridCellStyle(backgroundImage: PdfBitmap(firmaConductor));
    rowSummary2.height = 30;
    rowSummary2.cells[4].value = 'FIRMA DE QUIEN INSPECCIONA';
    // rowSummary2.cells[5].value = 'FOTO DE LA FIRMA';

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
  PdfGrid getGridAnswers(ResumenPreoperacional infoPdf, Size pageSize,
      List<ItemsVehiculo> respuestas) {
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
    respuestas.last.items.add(Item(
      idItem: '-1',
      item: 'Kilometraje',
      adjunto: infoPdf.urlFotoKm,
    ));

    print('KM ${infoPdf.urlFotoKm}');
    print('CABEZOTE ${infoPdf.urlFotoRemolque}');
    print('REMOLQUE ${infoPdf.urlFotoRemolque}');
    respuestas.last.items.add(Item(
      idItem: '-2',
      item: 'Cabezote',
      adjunto: infoPdf.urlFotoCabezote,
    ));

    print('📋 [PDF OFFLINE] Agregando items especiales:');
    print('   - Guía transporte URL: ${infoPdf.urlFotoGuia}');
    print('   - Número guía: ${infoPdf.numeroGuia}');

    respuestas.last.items.add(Item(
      idItem: '-3',
      item: 'Guía de transporte',
      adjunto: infoPdf.urlFotoGuia,
    ));

    print('   - Remolque URL: ${infoPdf.urlFotoRemolque}');

    respuestas.last.items.add(Item(
      idItem: '-4',
      item: 'Remolque',
      adjunto: infoPdf.urlFotoRemolque,
    ));

    respuestas.forEach((element) {
      // Dibujas las categorias
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = element.categoria;
      row.cells[0].columnSpan = 7;
      row.cells[0].style =
          PdfGridCellStyle(backgroundBrush: PdfBrushes.lightGray);
      // Dibuja los items
      element.items.forEach((respuesta) {
        addRows(grid, infoPdf, respuesta, formatColumns, fechaHoy);
      });
    });
    return grid;
  }

  //Create and row for the grid.
  void addRows(PdfGrid grid, ResumenPreoperacional infoPdf, Item respuesta,
      PdfStringFormat formatColumns, DateTime fechaHoy) async {
    // Log para items especiales
    if (respuesta.idItem == '-3') {
      print('📄 [ADD ROWS] Procesando Guía de transporte:');
      print('   - item: ${respuesta.item}');
      print('   - adjunto: ${respuesta.adjunto}');
      print('   - numeroGuia: ${infoPdf.numeroGuia}');
    }

    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = '${respuesta.item}';

    row.cells[0].style.stringFormat = formatColumns;

    // Verificar si es un item especial primero
    if (respuesta.idItem == '-1' ||
        respuesta.idItem == '-2' ||
        respuesta.idItem == '-3' ||
        respuesta.idItem == '-4') {
      // Para items especiales, no asignamos X en las celdas de respuesta
      print(
          '🔍 [ADD ROWS] Item especial: ${respuesta.item} (idItem: ${respuesta.idItem})');
    } else {
      // Para items normales, asignar X según la respuesta
      if (respuesta.respuesta == 'S') {
        row.cells[1].value = 'X';
      } else if (respuesta.respuesta == 'N') {
        row.cells[2].value = 'X';
      } else if (respuesta.respuesta == 'B') {
        row.cells[3].value = 'X';
      } else {
        row.cells[4].value = 'X';
      }
    }

    // Une las celdas de respuestas S, N, B, M y Observaciones para mostrar el kilometraje al final del pdf
    if (respuesta.idItem == '-1') {
      row.cells[1].columnSpan = 5;
      row.cells[1].value = '${infoPdf.kilometraje} KM';
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == '-2') {
      row.cells[1].columnSpan = 5;
      row.cells[1].value = 'Cabezote'; // Mostrar texto para identificación
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == '-3') {
      row.cells[1].columnSpan = 5;
      // Mostrar el número de guía si existe
      String guiaTexto = 'Guía de transporte';
      if (infoPdf.numeroGuia != null && infoPdf.numeroGuia!.isNotEmpty) {
        guiaTexto = 'Guía de transporte: ${infoPdf.numeroGuia}';
      }
      row.cells[1].value = guiaTexto;
      row.cells[1].style.stringFormat = formatColumns;
    }

    if (respuesta.idItem == '-4') {
      row.cells[1].columnSpan = 5;
      row.cells[1].value = 'Remolque'; // Mostrar texto para identificación
      row.cells[1].style.stringFormat = formatColumns;
    }

    // Solo asignar observaciones si NO es un item especial
    if (respuesta.idItem != '-1' &&
        respuesta.idItem != '-2' &&
        respuesta.idItem != '-3' &&
        respuesta.idItem != '-4') {
      row.cells[5].style.stringFormat = formatColumns;
      row.cells[5].value =
          '${respuesta.observaciones == null ? '' : respuesta.observaciones}';
    }

    // Mostrar la imagen si existe adjunto
    if (respuesta.adjunto == null || respuesta.adjunto!.isEmpty) {
      row.cells[6].value = '';
      print('⚠️ [ADD ROWS] No hay adjunto para: ${respuesta.item}');
    } else {
      try {
        row.cells[6].style = PdfGridCellStyle(
            backgroundImage:
                PdfBitmap(File(respuesta.adjunto!).readAsBytesSync()));
        row.height = 40;
        print('✅ [ADD ROWS] Imagen cargada para: ${respuesta.item}');
      } catch (e) {
        print('❌ [ADD ROWS] Error al cargar imagen para ${respuesta.item}: $e');
        row.cells[6].value = 'Error al cargar imagen';
      }
    }
  }
}
