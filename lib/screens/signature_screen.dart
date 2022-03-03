import 'package:app_qinspecting/providers/inspeccion_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/widgets/widgets.dart';
import 'package:app_qinspecting/services/inspeccion_service.dart';

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
    final inspeccionService = Provider.of<InspeccionService>(context);
    return DefaultTabController(
      length: tabs.length,
      initialIndex: inspeccionService.indexTabaCreateSignature,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.index = inspeccionService.indexTabaCreateSignature;
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
                width: double.infinity,
                height: 500,
                child: Text('Aqui se vera la firma realizada'),
              ),
              Container(
                width: double.infinity,
                height: 500,
                child: TerminosCondiciones(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
