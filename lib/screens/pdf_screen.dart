import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:provider/provider.dart';

class PdfScreen extends StatelessWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context)!.settings.arguments as List;
    final resumenPreoperacional = params[0] as ResumenPreoperacionalServer;
    final inspeccionService = Provider.of<InspeccionService>(context, listen: false);
    final loginService = Provider.of<LoginService>(context, listen: false);

    return FutureBuilder(
      future: _generatePdf(resumenPreoperacional, inspeccionService, loginService),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return LoadingScreen();
        } else {
          var data = snapshot.data as PdfData;
          
          return Scaffold(
            appBar: AppBar(
              title: Text('Preoperacional ${resumenPreoperacional.resuPreId}', style: TextStyle(fontSize: 16),),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await Share.shareFiles([data.file.path]);
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
        }
      }
    );
  }

  // Genera el pdf
  Future<PdfData> _generatePdf(
    ResumenPreoperacionalServer resumenPreoperacional,
    InspeccionService inspeccionService,
    LoginService loginService
  ) async {
    Pdf infoPdf = await inspeccionService.detatilPdf(loginService.selectedEmpresa, resumenPreoperacional).then((data) => data, onError: (e) {
      showSimpleNotification(Text('Error al obtener detalle pdf'),
        leading: Icon(Icons.check),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom
      );
    });

    var responseLogoCliente = await get(Uri.parse(infoPdf.rutaLogo!));
    var logoCliente = responseLogoCliente.bodyBytes;

    var responseLogoQi = await get(Uri.parse('https://qinspecting.com/img/Qi.png'));
    var logoQi = responseLogoQi.bodyBytes;

    var responseKilometraje = await get(Uri.parse(infoPdf.fotoKm!));
    var fotoKilometraje = responseKilometraje.bodyBytes;

    var resFirmaConductor = await get(Uri.parse(infoPdf.firma!));
    var firmaConductor = resFirmaConductor.bodyBytes;
    var resFirmaAuditor = await get(Uri.parse(infoPdf.firmaAuditor!));
    var firmaAuditor = resFirmaAuditor.bodyBytes;

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

    // Draw header
    final header = drawHeader(document, infoPdf, logoCliente, logoQi);
    document.template.top = header;

    //Generate PDF grid.
    final PdfGrid gridSummary = getGridSummary(infoPdf, pageSize, firmaConductor, firmaAuditor, resumenPreoperacional);

    final PdfGrid gridAnswers =
        getGridAnswers(infoPdf, pageSize, fotoKilometraje);

    //Draw grid
    PdfLayoutResult resultSummary = gridSummary.draw(
        page: page, bounds: Rect.fromLTWH(0, 60, 0, 0)) as PdfLayoutResult;

    //Draw the PDF grid
    gridAnswers.draw(
        page: page,
        bounds: Rect.fromLTWH(0, resultSummary.bounds.bottom, 0, 0));

    //Save the PDF document
    final outputExternal = await getExternalStorageDirectory();
    final pathFile = '${outputExternal!.path}/${resumenPreoperacional.consecutivo}.pdf';

    await File(pathFile).writeAsBytes(document.save());

    Uint8List bytes = File(pathFile).readAsBytesSync();
    // Dispose the document.
    document.dispose();

    return PdfData(bytes: bytes, file: File(pathFile));
  }

  PdfPageTemplateElement drawHeader(PdfDocument document, Pdf infoPdf,
      Uint8List logoCliente, Uint8List logoQi) {
    final pageSize = document.pages[0].getClientSize();
    //Create the header with specific bounds
    PdfPageTemplateElement header =
        PdfPageTemplateElement(Rect.fromLTWH(0, 0, pageSize.width, 60));

    //Dibula el rectangulo que contiene el logo del cliente
    header.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, 120, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo del cliente
    header.graphics
        .drawImage(PdfBitmap(logoCliente), Rect.fromLTWH(1, 1, 118, 57));

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
    header.graphics.drawImage(PdfBitmap(logoQi), Rect.fromLTWH(462, 8, 45, 45));

    //Return header
    return header;
  }

  PdfGrid getGridSummary(
    Pdf infoPdf,
    Size pageSize,
    firmaConductor,
    firmaAuditor,
    ResumenPreoperacionalServer resumenPreoperacional
  ) {
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
    ${infoPdf.resuPreFecha}''';
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
    rowSummary2.cells[3].style = PdfGridCellStyle(backgroundImage: PdfBitmap(firmaConductor));
    rowSummary2.height = 30;
    rowSummary2.cells[4].value = 'FIRMA DE QUIEN INSPECCIONA';
    rowSummary2.cells[5].value = PdfGridCellStyle(backgroundImage: PdfBitmap(firmaAuditor));

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
      Pdf infoPdf, Size pageSize, Uint8List fotoKilometraje) {
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
    if(infoPdf.detalle.length > 0){
      infoPdf.detalle.last.respuestas.add(RespuestaInspeccion(
        idItem: -1,
        item: 'Kilometraje',
        foto: infoPdf.fotoKm,
        fotoConverted: fotoKilometraje)
      );
      infoPdf.detalle.forEach((categoria) {
        // Dibujas las categorias
        final PdfGridRow row = grid.rows.add();
        row.cells[0].value = categoria.categoria;
        row.cells[0].columnSpan = 7;
        row.cells[0].style = PdfGridCellStyle(backgroundBrush: PdfBrushes.lightGray);
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

    row.cells[5].style.stringFormat = formatColumns;

    // if (respuesta.idItem == 1 && infoPdf.fechaVencLicCond != '') {
    //   // 1, "Licencia de Tránsito"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.fechaVencLicCond}';

    //   DateTime tempDate = DateTime.parse(infoPdf.fechaVencLicCond!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else if (respuesta.idItem == 3 && infoPdf.fechaFinSoat != '') {
    //   //3, "Soat"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.fechaFinSoat}';

    //   DateTime tempDate = DateTime.parse(infoPdf.fechaFinSoat!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else if (respuesta.idItem == 4 && infoPdf.fechaFinPoExtra != '') {
    //   //4, "Póliza Contra Actual"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.fechaFinPoExtra}';

    //   DateTime tempDate = DateTime.parse(infoPdf.fechaFinPoExtra!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else if (respuesta.idItem == 5 && infoPdf.rcHidroFechaFin != '') {
    //   //5, "Póliza Extracontractual (Hidrocarburos)"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.rcHidroFechaFin}';

    //   DateTime tempDate = DateTime.parse(infoPdf.rcHidroFechaFin!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else if (respuesta.idItem == 6 && infoPdf.fechaFinReTec != '') {
    //   //6, "Certificado de Revisión Técnico mecánica  y de Gases"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.fechaFinReTec}';

    //   DateTime tempDate = DateTime.parse(infoPdf.fechaFinReTec!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else if (respuesta.idItem == 7 && infoPdf.fechaFinQr != '') {
    //   //7, "Revisión Luz Negra 5° Rueda"
    //   row.cells[5].value = 'Fecha de Vencimiento: ${infoPdf.fechaFinQr}';

    //   DateTime tempDate = DateTime.parse(infoPdf.fechaFinQr!);
    //   final difference = tempDate.difference(fechaHoy).inDays;
    //   row.cells[5].style.backgroundBrush = difference <= 15 && difference > 0
    //       ? PdfBrushes.orange
    //       : PdfBrushes.red;
    // } else {
    // }
    row.cells[5].value = '${respuesta.observacion == null ? '' : respuesta.observacion}';
    if (respuesta.foto == null) {
      row.cells[6].value = '';
    } else {
      row.cells[6].style = PdfGridCellStyle(backgroundImage: PdfBitmap(respuesta.fotoConverted!));
      row.height = 40;
    }
  }
}
