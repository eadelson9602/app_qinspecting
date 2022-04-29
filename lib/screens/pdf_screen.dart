// import 'package:printing/printing.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_qinspecting/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' show get;
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:provider/provider.dart';

class PdfScreen extends StatelessWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context)!.settings.arguments as List;
    final resumenPreoperacional = params[0] as ResumenPreoperacionalServer;

    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Preoperacional ${resumenPreoperacional.resuPreId}'),
      ),
      body: FutureBuilder(
          future: _generatePdf(
              resumenPreoperacional, inspeccionService, loginService),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingScreen();
            } else {
              final pathPdf = snapshot.data as File;
              return SfPdfViewer.file(pathPdf);
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final output = await getTemporaryDirectory();

          final ByteData file = await rootBundle
              .load('${output.path}/${resumenPreoperacional.consecutivo}.pdf');

          Share.shareFiles(
              ['${output.path}/${resumenPreoperacional.consecutivo}.pdf']);
        },
        tooltip: 'Compartir',
        child: const Icon(Icons.share),
      ),
    );
  }

  // Genera el pdf
  Future<File> _generatePdf(ResumenPreoperacionalServer resumenPreoperacional,
      InspeccionService inspeccionService, LoginService loginService) async {
    Pdf infoPdf = await inspeccionService
        .detatilPdf(loginService.selectedEmpresa, resumenPreoperacional)
        .then((data) => data, onError: (e) {
      showSimpleNotification(Text('Error al obtener detalle pdf: ${e}'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
    });

    var responseLogoCliente = await get(Uri.parse(infoPdf.rutaLogo!));
    var logoCliente = responseLogoCliente.bodyBytes;

    var responseLogoQi =
        await get(Uri.parse('https://qinspecting.com/img/Qi.png'));
    var logoQi = responseLogoQi.bodyBytes;

    var resFirmaConductor = await get(Uri.parse(infoPdf.firma!));
    var firmaConductor = resFirmaConductor.bodyBytes;
    var resFirmaAuditor = await get(Uri.parse(infoPdf.firma!));
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
    final PdfGrid gridAnswers = getGridAnswers(infoPdf, pageSize);

    final PdfGrid gridSummary =
        getGridSummary(infoPdf, pageSize, firmaConductor, firmaAuditor);

    //Draw grid
    PdfLayoutResult resultSummary = gridSummary.draw(
        page: page, bounds: Rect.fromLTWH(0, 60, 0, 0)) as PdfLayoutResult;

    //Draw the PDF grid
    gridAnswers.draw(
        page: page,
        bounds: Rect.fromLTWH(0, resultSummary.bounds.bottom, 0, 0));

    //Add invoice footer
    // drawFooter(page, pageSize);

    //Save the PDF document
    final output = await getTemporaryDirectory();

    File('${output.path}/${resumenPreoperacional.consecutivo}.pdf')
        .writeAsBytes(document.save());
    // Dispose the document.
    document.dispose();

    return File('${output.path}/${resumenPreoperacional.consecutivo}.pdf');
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
      Pdf infoPdf, Size pageSize, firmaConductor, firmaAuditor) {
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
    ${infoPdf.vehPlaca}''';
    rowSummary1.cells[4].value = '''PLACA REMOLQUE:
    ${infoPdf.remolPlaca}''';
    rowSummary1.cells[5].value = 'ESTADO';

    PdfGridRow rowSummary2 = gridSummary.headers[2];
    rowSummary2.cells[0].value = 'N°. INSPECCIÓN';
    rowSummary2.cells[1].value = '${infoPdf.consecutivo}';
    rowSummary2.cells[2].value = 'FIRMA CONDUCTOR';
    rowSummary2.cells[3].style =
        PdfGridCellStyle(backgroundImage: PdfBitmap(firmaConductor));
    rowSummary2.height = 30;
    rowSummary2.cells[4].value = 'FIRMA DE QUIEN INSPECCIONA';
    rowSummary2.cells[5].value = 'FOTO DE LA FIRMA';

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

  //Draw the invoice footer data.
  void drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219, 255), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));

    const String footerContent =
        // ignore: leading_newlines_in_multiline_strings
        '''800 Interchange Blvd.\r\n\r\nSuite 2501, Austin,
         TX 78721\r\n\r\nAny Questions? support@adventure-works.com''';

    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

  //Create PDF grid and return
  PdfGrid getGridAnswers(Pdf infoPdf, Size pageSize) {
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

    //Add rows
    infoPdf.detalle.forEach((categoria) {
      final PdfGridRow row = grid.rows.add();
      row.cells[0].value = categoria.categoria;
      row.cells[0].columnSpan = 7;
      row.cells[0].style =
          PdfGridCellStyle(backgroundBrush: PdfBrushes.lightGray);
      categoria.respuestas.forEach((respuesta) {
        addProducts(grid, respuesta, formatColumns);
      });
    });

    return grid;
  }

  //Create and row for the grid.
  void addProducts(PdfGrid grid, RespuestaInspeccion respuesta,
      PdfStringFormat formatColumns) async {
    final PdfGridRow row = grid.rows.add();

    row.cells[0].value = '${respuesta.item}';
    row.cells[0].style.stringFormat = formatColumns;
    if (respuesta.respuesta == 'S') {
      row.cells[1].value = 'S';
    } else if (respuesta.respuesta == 'N') {
      row.cells[2].value = 'N';
    } else if (respuesta.respuesta == 'B') {
      row.cells[3].value = 'B';
    } else {
      row.cells[4].value = 'M';
    }
    row.cells[5].value =
        '${respuesta.observacion == null ? '' : respuesta.observacion}';
    if (respuesta.foto == null) {
      row.cells[6].value = '';
    } else {
      row.cells[6].style = PdfGridCellStyle(
          backgroundImage: PdfBitmap(respuesta.fotoConverted!));
      row.height = 40;
    }
  }
}
