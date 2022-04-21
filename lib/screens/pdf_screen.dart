import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';

import 'package:app_qinspecting/models/models.dart';
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
    Pdf? infoPdf = await inspeccionService.detatilPdf(
        loginService.selectedEmpresa, resumenPreoperacional);

    var responseLogoCliente = await get(Uri.parse(infoPdf!.rutaLogo!));
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
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult result =
        drawHeader(page, pageSize, grid, infoPdf, logoCliente, logoQi);
    //Draw grid
    drawGrid(page, grid, result);
    //Add invoice footer
    drawFooter(page, pageSize);
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
  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 7);

    //Add header to the grid
    grid.headers.add(2);

    //Add the rows to the grid
    PdfGridRow header = grid.headers[0];
    header.cells[0].value = 'Item';
    header.cells[1].value = 'Employee Name';
    header.cells[2].value = 'Salary';

    PdfGridRow header1 = grid.headers[1];
    header1.cells[0].value = 'Item';
    header1.cells[1].value = 'Employee Name';
    header1.cells[1].columnSpan = 2;
    // header1.cells[2].value = '';
    header1.cells[3].value = 'Salary';

    return grid;
  }

  //Create and row for the grid.
  void addProducts(String productId, String productName, double price,
      int quantity, double total, PdfGrid grid) {
    final PdfGridRow row = grid.rows.add();
    row.cells[0].value = productId;
    row.cells[1].value = productName;
    row.cells[2].value = price.toString();
    row.cells[3].value = quantity.toString();
    row.cells[4].value = total.toString();
  }

  //Get the total amount.
  double getTotalAmount(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      final String value =
          grid.rows[i].cells[grid.columns.count - 1].value as String;
      total += double.parse(value);
    }
    return total;
  }
}
