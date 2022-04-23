import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' show get;

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              child: const Text('Generate PDF'),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.lightBlue,
                onSurface: Colors.grey,
              ),
              onPressed: () async {
                final pathPdf = await _generatePdf(
                    resumenPreoperacional, inspeccionService, loginService);
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return Scaffold(
                        appBar: AppBar(),
                        body: SfPdfViewer.file(pathPdf),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
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

    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(0, 0, 0)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid(infoPdf, pageSize);
    //Draw the header section by creating text element
    final PdfLayoutResult result =
        drawHeader(page, pageSize, grid, infoPdf, logoCliente, logoQi);
    //Draw grid
    drawGrid(page, grid, result);
    //Add invoice footer
    // drawFooter(page, pageSize);
    //Save the PDF document
    final output = await getTemporaryDirectory();

    File('${output.path}/example.pdf').writeAsBytes(document.save());
    // Dispose the document.
    document.dispose();

    return File('${output.path}/example.pdf');
  }

  //Dibuja el encabezado
  PdfLayoutResult drawHeader(PdfPage page, Size pageSize, PdfGrid grid,
      Pdf infoPdf, Uint8List logoCliente, Uint8List logoQi) {
    //Dibula el rectangulo que contiene el logo del cliente
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, 120, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo del cliente
    page.graphics
        .drawImage(PdfBitmap(logoCliente), Rect.fromLTWH(1, 1, 118, 57));

    //Diduja el rectangulo con el titulo del pdf
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(120, 0, pageSize.width - 280, 60),
        pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el título del pdf
    page.graphics.drawString('${infoPdf.nombreFormatoPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(122, 0, pageSize.width - 285, 60),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja los rectangulos para el código y version del formato
    //Top-left
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(355, 0, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para CODIGO
    page.graphics.drawString(
        'Código', PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(355, 0, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));
    //Top-rigth
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(405, 0, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para CODIGO DE LA BASE
    page.graphics.drawString('${infoPdf.codFormtPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(405, 0, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Bottom-left
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(355, 30, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para VERSION
    page.graphics.drawString(
        'Versión', PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(355, 30, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Bottom-rigth
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(405, 30, 50, 30), pen: PdfPen(PdfColor(0, 0, 0)));
    //Texto para VERSION DE LA BASE
    page.graphics.drawString('${infoPdf.versionFormtPreope}',
        PdfStandardFont(PdfFontFamily.helvetica, 9),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(405, 30, 50, 30),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja el rectangulo para logo de QI
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(455, 0, 60, 60), pen: PdfPen(PdfColor(0, 0, 0)));

    //Dibuja el logo de QI
    page.graphics.drawImage(PdfBitmap(logoQi), Rect.fromLTWH(462, 8, 45, 45));

    return PdfTextElement()
        .draw(page: page, bounds: Rect.fromLTWH(0, 20, pageSize.width, 80))!;
  }

  //Draws the grid
  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    //Draw the PDF grid
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
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
  PdfGrid getGrid(Pdf infoPdf, Size pageSize) {
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
      PdfStringFormat formatColumns) {
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
    row.cells[6].value = '${respuesta.foto == null ? '' : respuesta.foto}';
  }
}
