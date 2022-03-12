import 'package:flutter/material.dart';
import 'package:app_qinspecting/models/models.dart';

class CardInspeccionDesktop extends StatelessWidget {
  const CardInspeccionDesktop({Key? key, required this.resumenPreoperacional})
      : super(key: key);

  final ResumenPreoperacional resumenPreoperacional;

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.qr_code_scanner_sharp),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Divider(
            height: 10,
          ),
          Text('ID Inspección', style: TextStyle(color: Colors.black54)),
          Text('${resumenPreoperacional.Id}'),
          Text(
            'Documento conductor',
            style: TextStyle(color: Colors.black54),
          ),
          Text('${resumenPreoperacional.persNumeroDoc}'),
          Text('Kilometraje', style: TextStyle(color: Colors.black54)),
          Text('${resumenPreoperacional.resuPreKilometraje}'),
          Text(
            'Galones tanqueados',
            style: TextStyle(color: Colors.black54),
          ),
          Text('${resumenPreoperacional.tanqueGalones}'),
          Text(
            'Fecha inspección',
            style: TextStyle(color: Colors.black54),
          ),
          Text('${resumenPreoperacional.resuPreFecha}'),
        ],
      ),
    );
  }
}
