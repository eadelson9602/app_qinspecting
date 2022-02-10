import 'package:flutter/material.dart';

import 'package:app_qinspecting/widgets/widgets.dart';

class SendPendingInspectionScree extends StatelessWidget {
  const SendPendingInspectionScree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar().createAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        height: double.infinity,
        padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 50),
        child: ListView.builder(
            itemCount: 15,
            itemBuilder: (_, int i) => ListTile(
                  iconColor: Colors.green,
                  shape: Border.all(
                      style: BorderStyle.solid,
                      color: Colors.green,
                      width: 0.2),
                  leading: Icon(
                    Icons.find_in_page,
                  ),
                  title: Text('Hola'),
                  subtitle: Text('10/02/2022'),
                  trailing: Icon(
                    Icons.upload,
                  ),
                )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () {},
        child: Icon(Icons.upload_rounded),
      ),
    );
  }
}
