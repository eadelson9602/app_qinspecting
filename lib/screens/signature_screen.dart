import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
    final appBar = CustomAppBar();
    return DefaultTabController(
      length: tabs.length,
      initialIndex: firmaService.indexTabaCreateSignature,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.index = firmaService.indexTabaCreateSignature;
        return Scaffold(
          appBar: appBar.createAppBar(context),
          drawer: const CustomDrawer(),
          body: TabBarView(
            children: [
              FutureBuilder(
                  future: Connectivity().checkConnectivity(),
                  builder: (context, snapshot) {
                    if (snapshot.data == ConnectivityResult.mobile ||
                        snapshot.data == ConnectivityResult.wifi) {
                      return Container(
                        child: FutureBuilder(
                            future: firmaService
                                .getInfoFirma(loginService.selectedEmpresa),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else {
                                if (snapshot.data != null) {
                                  final Firma dataFirma =
                                      snapshot.data as Firma;
                                  return CardFirma(
                                    infoFirma: dataFirma,
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      SizedBox(
                                        height: 50.0,
                                      ),
                                      Image(
                                        image: AssetImage(
                                            'assets/images/boot_signature_2.gif'),
                                        // fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        width: 250,
                                        child: DefaultTextStyle(
                                            style: TextStyle(
                                                fontSize: 30.0,
                                                fontFamily: 'Agne',
                                                color: Colors.black),
                                            child: AnimatedTextKit(
                                              isRepeatingAnimation: true,
                                              animatedTexts: [
                                                TypewriterAnimatedText(
                                                    'Oops!!! Debe realizar su firma',
                                                    speed: Duration(
                                                        milliseconds: 100),
                                                    textAlign:
                                                        TextAlign.center),
                                              ],
                                              onTap: () {
                                                print("Tap Event");
                                              },
                                            )),
                                      )
                                    ],
                                  );
                                }
                              }
                            }),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(15),
                        child: NoInternet(),
                      );
                    }
                  }),
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
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
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
                height: 270,
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
