import 'dart:io';
import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/inspeccion_provider.dart';
import 'package:app_qinspecting/services/services.dart';

class DesktopScreen extends StatelessWidget {
  const DesktopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    final inspeccionService = Provider.of<InspeccionService>(context);

    final allInspecciones = inspeccionProvider.allInspecciones;
    inspeccionProvider.cargarTodosInspecciones();

    Future<void> main(ResumenPreoperacional resumenPreoperacional) async {
      final pdf = pw.Document();

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
      final myPdfPath = '${dir!.path}/${resumenPreoperacional.Id}.pdf';
      final file = File(myPdfPath);
      await file.writeAsBytes(await pdf.save());
    }

    return Container(
      height: double.infinity,
      padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
      child: ListView.builder(
          itemCount: allInspecciones.length,
          itemBuilder: (_, int i) {
            if (inspeccionService.isSaving)
              return Container(
                padding: EdgeInsets.all(20),
                child: Column(children: [
                  Image(
                    image: AssetImage('assets/images/loading_3.gif'),
                    // fit: BoxFit.cover,
                    height: 50,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  LinearProgressIndicator(),
                ]),
              );
            return CardInspeccionDesktop(
                resumenPreoperacional: allInspecciones[i]);
          }),
    );
  }
}
