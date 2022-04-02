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
            body{
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
              font-size: 9px !important;
            }

            img {
              height: 40px;
            }

            table {
              width: 100%;
              border-spacing: 0 !important;
            }

            td, th{
              border: 1px solid #000;
              padding: 2px 5px;
              text-align: center;
              color: rgb(48, 48, 48);
            }

            td p, .item {
              margin: 0;
              font-weight: bold;
              text-align: left;
            }

            .consecutivo{
              color: #008500;
              /* font-size: 18px; */
              font-weight: bold;
            }

            .categoria{
              font-weight: bold;
              background-color: #e0e0e0;
            }

            .item {
               /*font-size: 12px;*/
            }

            .observaciones{
              text-align: left;
              /* font-size: 12px; */
            }

            td p:nth-child(even){
              font-weight: normal;
              text-transform: uppercase;
            }

            caption {
              text-align: left;
              font-size: 18px;
              padding: 5px;
              font-weight: bold;
            }

            .caption_title{
              text-align: center;
              border: 1px solid #000;
            }

            ul{
              list-style: none;
              text-align: center;
              margin: 0;
            }

            li{
              display: inline;
              margin-right: 20px;
              text-align: center;
            }

            table td {
              margin: 0;
            }
          </style>
          <table>
            <thead>
              <tr>
                <th rowspan="2" colspan="16">
                  <img src="https://apis.qinspecting.com/tmc/adjuntos/logo_tmc.png" width=80 height=40 alt="Logo corporativo">
                </th>
                <th rowspan="2" colspan="110">INSPECCIÓN DE VEHÍCULOS DE CARGA</th>
                <th colspan="10">Código</th>
                <th colspan="10">F-M-01</th>
                <th rowspan="2" colspan="16">
                  <img src="https://qinspecting.com/img/Qi.png" width=50 height=40 alt="Logo corporativo">
                </th>
              </tr>
              <tr>
                <th colspan="10">Versión</th>
                <th colspan="10">02</th>
              </tr>
            </thead>
            <tbody>
              <!-- Resumen preoperacional -->
              <tr>
                <td colspan="43">
                  <p>CIUDAD Y FECHA:</p>
                  <p>Puerto López 2022-03-28</p>
                </td>
                <td colspan="43">
                  <p>TIPO DE VEHÍCULO:</p>
                  <p>TractoCamión 6x4</p>
                </td>
                <td colspan="67">
                  <p>MARCA/LINEA/MODELO:</p>
                  <p>INTERNATIONAL / 9400 / 2012</p>
                </td>
                <td colspan="39">
                  <p>¿REALIZÓ TANQUEO ?</p>
                  <p>NO</p>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tr>
              <td>
                <p>KILOMETRAJE:</p>
                <p>30</p>
              </td>
              <td>
                <p>NOMBRE QUIEN REALIZÓ INSPECCIÓN:</p>
                <p>juan sin miedo</p>
              </td>
              <td>
                <p>PLACA VEHÍCULO:</p>
                <p>hpd 62d</p>
              </td>
              <td>
                <p>PLACA REMOLQUE:</p>
                <p>hpd 62drr</p>
              </td>
              <td>
                <p>ESTADO:</p>
                <p>Aprobado</p>
              </td>
            </tr>
          </table>
          <table>
            <tr>
              <td rowspan="2">
                <p>N° INSPECCION:</p>
              </td>
              <td class="consecutivo" rowspan="2">
                QI-TMC-05664
              </td>

              <td rowspan="2">
                <p>FIRMA CONDUCTOR:</p>
              </td>
              <td rowspan="2">
                <img src="https://qinspecting.com/img/Qi.png" alt="Firma digital">
              </td>
              <td rowspan="2">
                <p>FIRMA DE QUIEN INSPECCIONA:</p>
              </td>
              <td rowspan="2">
                <img src="https://qinspecting.com/img/Qi.png" alt="Firma digital">
              </td>
            </tr>
          </table>
          <table>
            <caption class="caption_title">
              <ul>
                <li>S: Si</li>
                <li>N: No</li>
                <li>B: Bueno</li>
                <li>M: Malo</li>
              </ul>
            </caption>
            <tr>
              <td rowspan="2" colspan="80">
                ITEM
              </td>

              <td colspan="20">
                TIENE:
              </td>
              <td colspan="20">
                ESTADO:
              </td>
              <td rowspan="2" colspan="72">
                OBSERVACIONES
              </td>
            </tr>

            <tr>
              <td colspan="10">S</td>
              <td colspan="10">N</td>
              <td colspan="10">B</td>
              <td colspan="10">M</td>
            </tr>
            <tr>
              <td colspan="191" class="categoria">
                Documentos Vehículo
              </td>
            </tr>

            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td colspan="191" class="categoria">
                Documentos Vehículo
              </td>
            </tr>

            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10">X</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
            <tr>
              <td class="item" colspan="80">Licencia de Tránsito</td>
              <td colspan="10"></td>
              <td colspan="10">x</td>
              <td colspan="10"></td>
              <td colspan="10"></td>
              <td colspan="72" class="observaciones">OBSERVACIONES:</td>
            </tr>
          </table>

          <table>
            <caption>Observaciones:</caption>
            <thead>
              <tr>
                <th colspan="68">ITEM:</th>
                <th colspan="94">OBSERVACIONES:</th>
                <th colspan="30">FOTO:</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td colspan="68" class="item">ITEM:</td>
                <td colspan="94" class="observaciones">OBSERVACIONES:</td>
                <td colspan="30">FOTO:</td>
              </tr>
            </tbody>
          </table>
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
