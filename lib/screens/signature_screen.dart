import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/widgets/widgets.dart';

class SignatureScreen extends StatelessWidget {
  const SignatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: const CustomAppBar().createAppBar(),
      body: Container(
        child: MyStatelessWidget(),
      ),
    );
  }
}

const List<Tab> tabs = <Tab>[
  Tab(text: 'Mi firma'),
  Tab(text: 'Relizar firma'),
];

class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firmaService = Provider.of<FirmaService>(context);
    final loginService = Provider.of<LoginService>(context);
    return DefaultTabController(
      length: tabs.length,
      initialIndex: firmaService.indexTabaCreateSignature,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.index = firmaService.indexTabaCreateSignature;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Qinspecting'),
            backgroundColor: Colors.green,
            actions: [
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.notifications))
            ],
            bottom: const TabBar(
              tabs: tabs,
            ),
          ),
          drawer: const CustomDrawer(),
          body: TabBarView(
            children: [
              Container(
                child: FutureBuilder(
                    future:
                        firmaService.getInfoFirma(loginService.selectedEmpresa),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        final Firma dataFirma = snapshot.data as Firma;
                        return CardFirma(
                          infoFirma: dataFirma,
                        );
                      }
                    }),
              ),
              Container(
                child: TerminosCondiciones(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class CardFirma extends StatelessWidget {
  const CardFirma({Key? key, required this.infoFirma}) : super(key: key);

  final Firma infoFirma;

  @override
  Widget build(BuildContext context) {
    final sizeScreen = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(15),
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
            Image(
                image: NetworkImage(
                    'https://apis.qinspecting.com/pflutter/${infoFirma.firma}')),
            SizedBox(height: 10),
            Divider(
              height: 15,
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Usuario',
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
              subtitle: Text('${infoFirma.usuario}'),
            ),
            ListTile(
              leading: Icon(Icons.fact_check_outlined),
              title: Text('Aceptó términos y condiciones?',
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
              subtitle: Text('${infoFirma.terminosCondiciones}'),
            ),
            ListTile(
              leading: Icon(Icons.date_range),
              title: Text('Fecha de realización',
                  style: TextStyle(color: Colors.black87, fontSize: 16)),
              subtitle: Text('${infoFirma.fechaFirma}'),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
