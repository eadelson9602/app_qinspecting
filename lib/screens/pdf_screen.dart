import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfScreen extends StatelessWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context)!.settings.arguments as List;
    ResumenPreoperacional resumenPreoperacional = params[0];
    final sizeScreen = MediaQuery.of(context).size;
    List<Item> respuestas = params[1];
    return Scaffold(
      appBar: AppBar(title: Text('PDF')),
      body: PdfPreview(
        pdfFileName: 'Preoperacional ${resumenPreoperacional.resuPreId}',
        dpi: 420,
        build: (format) =>
            _generatePdf(format, resumenPreoperacional, respuestas, sizeScreen),
      ),
    );
  }

  // Genera el pdf
  Future<Uint8List> _generatePdf(
      PdfPageFormat format,
      ResumenPreoperacional resumenPreoperacional,
      List<Item> respuestas,
      sizeScreen) async {
    final pdf = pw.Document();
    // respuestas.forEach((element) {
    //   print(element.idItem);
    // });
    final alto = sizeScreen.height * 1;
    final ancho = sizeScreen.width * 1;

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
              format: format,
              html: '''<html>
              <body>
                <style>
                  .container{
                    display: grid;
                    grid-template-columns: 20% 50% 10% 10% 10%;
                    grid-template-rows: 60px;
                  }
                  .container div {
                    border:  1px solid black;
                    /* padding: 1em; */
                  }
                  .container div:hover {
                    border: 2px solid white;
                  }
                  .text-center {
                    text-align: center !important;
                  }
                  .no-borbder{
                    border: 0px !important;
                  }
                  .py-md {
                    padding: 20px;
                  }
                  .container-img{
                    display: flex;
                    justify-content: center;
                  }
                  img {
                    height: 50px;
                    margin-top: 5px;
                  }
                </style>
                <div class="container">
                  <div class="container-img">
                    <img src="https://apis.qinspecting.com/tmc/adjuntos/1589494292.png" alt="Imagen logo">
                  </div>
                  <div class="text-center py-md">
                    INSPECCIÓN DE VEHÍCULOS DE CARGA
                  </div>
                  <div>
                    <div class="text-center">Código</div>
                    <div class="text-center">Versión</div>
                  </div>
                  <div>
                    <div class="text-center">F-M-01</div>
                    <div class="text-center">02</div>
                  </div>
                  <div class="container-img">
                    <img src="https://qinspecting.com/favicon.ico" alt="Imagen logo">
                  </div>
                </div>
              </body>
              </html>''',
            ));

    final netImage = await networkImage('https://www.nfet.net/nfet.jpg');
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(ancho, alto, marginAll: 2),
        build: (context) {
          return pw.Row(
            children: [
              pw.Container(
                width: ancho,
                color: PdfColors.cyan,
                child: pw.Table(
                  children: [
                    pw.TableRow(children: [
                      pw.Container(
                        color: PdfColors.green,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("Logo Empresa"),
                      ),
                      pw.Container(
                        color: PdfColors.red,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("INSPECCIÓN DE VEHICULOS DE CARGA"),
                      ),
                      pw.Container(
                        color: PdfColors.red,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("Código"),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Container(
                        color: PdfColors.deepPurple,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("5"),
                      ),
                      pw.Container(
                        color: PdfColors.cyan,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("6"),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Container(
                        color: PdfColors.amberAccent,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("7"),
                      ),
                      pw.Container(
                        color: PdfColors.black,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("8"),
                      ),
                    ]),
                  ],
                ),
              ),
              pw.Container(
                width: ancho,
                color: PdfColors.cyan,
                child: pw.Table(
                  columnWidths: {
                    1: pw.FractionColumnWidth(.3),
                  },
                  children: [
                    pw.TableRow(children: [
                      pw.Container(
                        color: PdfColors.green,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text(
                            "1111111111111111111111111111111111111111111"),
                      ),
                      pw.Container(
                        color: PdfColors.red,
                        width: 50.0,
                        height: 50.0,
                        child: pw.Text("2"),
                      ),
                    ]),
                    pw.TableRow(children: [
                      pw.Container(
                        color: PdfColors.deepPurple,
                        width: 50.0,
                        height: 100.0,
                        child: pw.Text("5"),
                      ),
                      pw.Container(
                        color: PdfColors.cyan,
                        width: 50.0,
                        height: 100.0,
                        child: pw.Text("6"),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // final dir = await getExternalStorageDirectory();
    // final myPdfPath = '${dir!.path}/${resumenPreoperacional.id}.pdf';
    // final file = File(myPdfPath);
    return pdf.save();
  }
}
