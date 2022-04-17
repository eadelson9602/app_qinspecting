import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:app_qinspecting/models/models.dart';
import 'package:provider/provider.dart';
import 'package:app_qinspecting/services/services.dart';

class PdfScreen extends StatelessWidget {
  const PdfScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final params = ModalRoute.of(context)!.settings.arguments as List;
    final resumenPreoperacional = params[0] as ResumenPreoperacionalServer;

    final inspeccionService = Provider.of<InspeccionService>(context);
    final loginService = Provider.of<LoginService>(context);
    final sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: Text('PDF')),
      body: PdfPreview(
        pdfFileName: 'Preoperacional ${resumenPreoperacional.resuPreId}',
        dpi: 420,
        build: (format) => _generatePdf(format, sizeScreen,
            resumenPreoperacional, inspeccionService, loginService),
      ),
    );
  }

  // Genera el pdf
  Future<Uint8List> _generatePdf(
      PdfPageFormat format,
      Size sizeScreen,
      ResumenPreoperacionalServer resumenPreoperacional,
      InspeccionService inspeccionService,
      LoginService loginService) async {
    final pdf = pw.Document();
    final alto = sizeScreen.height * 1;
    final ancho = sizeScreen.width * 1;

    Pdf? infoPdf = await inspeccionService.detatilPdf(
        loginService.selectedEmpresa, resumenPreoperacional);
    String bodyResponse = infoPdf!.detalle.map((element) {
      '''
        <tr>
          <td colspan="191" class="categoria">
            ${element.categoria}
          </td>
        </tr>
      ''';
    }).toString();

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
              format: format,
              html: '''<html>
        <body>
          <style>
            body{
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
              font-size: 2px !important;
            }

            img {
              height: 20px;
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
                  <img src="${infoPdf.rutaLogo}" width=80 height=40 alt="Logo empresa cliente">
                </th>
                <th rowspan="2" colspan="110">${infoPdf.nombreFormatoPreope}</th>
                <th colspan="10">Código</th>
                <th colspan="10">${infoPdf.versionFormtPreope}</th>
                <th rowspan="2" colspan="16">
                  <img src="https://qinspecting.com/img/Qi.png" width=50 height=40 alt="Logo qinspecting">
                </th>
              </tr>
              <tr>
                <th colspan="10">Versión</th>
                <th colspan="10">${infoPdf.versionFormtPreope}</th>
              </tr>
            </thead>
            <tbody>
              <!-- Resumen preoperacional -->
              <tr>
                <td colspan="43">
                  <p>CIUDAD Y FECHA:</p>
                  <p>${infoPdf.resuPreFecha}</p>
                </td>
                <td colspan="43">
                  <p>TIPO DE VEHÍCULO:</p>
                  <p>${infoPdf.tvDescripcion}</p>
                </td>
                <td colspan="67">
                  <p>MARCA/LINEA/MODELO:</p>
                  <p>${infoPdf.mlm}</p>
                </td>
                <td colspan="39">
                  <p>¿REALIZÓ TANQUEO ?</p>
                  <p>${infoPdf.tanque}</p>
                </td>
              </tr>
            </tbody>
          </table>
          <table>
            <tr>
              <td>
                <p>KILOMETRAJE:</p>
                <p>${infoPdf.kilometraje}</p>
              </td>
              <td>
                <p>NOMBRE QUIEN REALIZÓ INSPECCIÓN:</p>
                <p>${infoPdf.conductor}</p>
              </td>
              <td>
                <p>PLACA VEHÍCULO:</p>
                <p>${infoPdf.vehPlaca}</p>
              </td>
              <td>
                <p>PLACA REMOLQUE:</p>
                <p>${infoPdf.remolPlaca}</p>
              </td>
              <td>
                <p>ESTADO:</p>
                <p>PENDIENTE AGREGAR PROPIEDAD A LA CONSULTA</p>
              </td>
            </tr>
          </table>
          <table>
            <tr>
              <td rowspan="2">
                <p>N° INSPECCION:</p>
              </td>
              <td class="consecutivo" rowspan="2">
                ${infoPdf.consecutivo}
              </td>

              <td rowspan="2">
                <p>FIRMA CONDUCTOR:</p>
              </td>
              <td rowspan="2">
                ${infoPdf.firma!.contains('.jpg') ? '<img src="${infoPdf.firma}" alt="Firma digital">' : infoPdf.firma}
              </td>
              <td rowspan="2">
                <p>FIRMA DE QUIEN INSPECCIONA:</p>
              </td>
              <td rowspan="2">
                ${infoPdf.firma!.contains('.jpg') ? '<img src="${infoPdf.firma}" alt="Firma digital">' : infoPdf.firma}
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
            ${bodyResponse}
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

    // final dir = await getExternalStorageDirectory();
    // final myPdfPath = '${dir!.path}/${resumenPreoperacional.id}.pdf';
    // final file = File(myPdfPath);
    return pdf.save();
  }
}
