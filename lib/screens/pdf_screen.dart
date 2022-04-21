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
        PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(122, 0, pageSize.width - 285, 60),
        format: PdfStringFormat(
            lineAlignment: PdfVerticalAlignment.middle,
            alignment: PdfTextAlignment.center));

    //Dibuja el rectangulo para el codigo y version del formato
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(355, 0, 100, 60), pen: PdfPen(PdfColor(0, 0, 0)));

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
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

    //Draw grand total.
    page.graphics.drawString('Grand Total',
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            quantityCellBounds!.left,
            result.bounds.bottom + 10,
            quantityCellBounds!.width,
            quantityCellBounds!.height));
    page.graphics.drawString(getTotalAmount(grid).toString(),
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
            totalPriceCellBounds!.left,
            result.bounds.bottom + 10,
            totalPriceCellBounds!.width,
            totalPriceCellBounds!.height));
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
    grid.columns.add(count: 5);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Product Id';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Product Name';
    headerRow.cells[2].value = 'Price';
    headerRow.cells[3].value = 'Quantity';
    headerRow.cells[4].value = 'Total';
    //Add rows
    addProducts('CA-1098', 'AWC Logo Cap', 8.99, 2, 17.98, grid);
    addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 3, 149.97, grid);
    addProducts('So-B909-M', 'Mountain Bike Socks,M', 9.5, 2, 19, grid);
    addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 4, 199.96, grid);
    addProducts('FK-5136', 'ML Fork', 175.49, 6, 1052.94, grid);
    addProducts('HL-U509', 'Sports-100 Helmet,Black', 34.99, 1, 34.99, grid);
    //Apply the table built-in style
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    //Set gird columns width
    grid.columns[1].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
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
