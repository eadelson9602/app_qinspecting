import 'package:app_qinspecting/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:app_qinspecting/models/models.dart';
import 'dart:io';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class CardInspeccionDesktop extends StatelessWidget {
  const CardInspeccionDesktop({Key? key, required this.resumenPreoperacional})
      : super(key: key);

  final ResumenPreoperacional resumenPreoperacional;

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                Icon(Icons.list_alt_sharp),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.picture_as_pdf_outlined,
                          color: Colors.red),
                      onPressed: () async {
                        // Consultamos en sqlite las respuestas
                        List<Item> respuestas = await inspeccionProvider
                            .cargarTodasRespuestas(resumenPreoperacional.id!);
                        await generatePdf(resumenPreoperacional, respuestas);
                        showSimpleNotification(Text('Pdf Generado'),
                            leading: Icon(Icons.check),
                            autoDismiss: true,
                            background: Colors.green,
                            position: NotificationPosition.bottom);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.qr_code_scanner_sharp),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.green,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ))
              ],
            ),
          ),
          Divider(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('ID Inspección',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.id}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Documento conductor',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                        child: Text(
                      '${resumenPreoperacional.persNumeroDoc}',
                      textAlign: TextAlign.end,
                    )),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Kilometraje',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.resuPreKilometraje}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Galones tanqueados',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.tanqueGalones}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Guía transporte',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.resuPreGuia}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Fecha inspección',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.resuPreFecha}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Genera el pdf
  Future<void> generatePdf(ResumenPreoperacional resumenPreoperacional,
      List<Item> respuestas) async {
    final pdf = pw.Document();
    respuestas.forEach((element) {
      print(element.idItem);
    });
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          child: pw.Table(children: [
            pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      width: 1,
                      style: pw.BorderStyle.solid,
                      color: PdfColors.black),
                ),
                children: [
                  pw.Row(children: [
                    pw.Text('title'),
                    pw.Text('title'),
                    pw.Text('title'),
                    pw.Text('title'),
                    pw.Text('title'),
                  ]),
                ]),
            pw.TableRow(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                    width: 1,
                    style: pw.BorderStyle.solid,
                    color: PdfColors.black),
              ),
              children: [
                pw.Text('Hola'),
                pw.Text('Hola'),
                pw.Text('Hola'),
                pw.Text('Hola'),
              ],
            )
          ]),
        ),
      ),
    );

    final dir = await getExternalStorageDirectory();
    final myPdfPath = '${dir!.path}/${resumenPreoperacional.id}.pdf';
    final file = File(myPdfPath);
    await file.writeAsBytes(await pdf.save());
  }
}
