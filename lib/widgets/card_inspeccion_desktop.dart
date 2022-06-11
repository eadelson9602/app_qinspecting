import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class CardInspeccionDesktop extends StatelessWidget {
  const CardInspeccionDesktop({Key? key, required this.resumenPreoperacional})
      : super(key: key);

  final ResumenPreoperacionalServer resumenPreoperacional;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      width: 280,
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
                      onPressed: () => Navigator.pushNamed(context, 'pdf',
                          arguments: [resumenPreoperacional]),
                    ),
                    // IconButton(
                    //   icon: Icon(Icons.qr_code_scanner_sharp),
                    //   onPressed: () {},
                    // ),
                    // IconButton(
                    //   icon: Icon(
                    //     Icons.edit,
                    //     color: Colors.green,
                    //   ),
                    //   onPressed: () {},
                    // ),
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
                        '${resumenPreoperacional.resuPreId}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Detalle',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.detalle}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Persona responsable',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                        child: Text(
                      '${resumenPreoperacional.creado}',
                      textAlign: TextAlign.end,
                    )),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Hora de inspección',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.hora}',
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
                        '${resumenPreoperacional.fechaPreoperacional}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Tanqueo?',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.tanqueo}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Fallas graves',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.grave}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Fallas moderadas',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Text(
                        '${resumenPreoperacional.moderada}',
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text('Estado',
                          style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Chip(
                            padding: EdgeInsets.all(0),
                            backgroundColor:
                                resumenPreoperacional.estado == 'APROBADO'
                                    ? Colors.green
                                    : Colors.red,
                            label: Text(
                              '${resumenPreoperacional.estado}',
                              textAlign: TextAlign.end,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
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
}
