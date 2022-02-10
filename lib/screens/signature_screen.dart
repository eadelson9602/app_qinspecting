import 'package:flutter/material.dart';

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
    return DefaultTabController(
      length: tabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
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
              ),
              Container(
                width: double.infinity,
                height: 500,
                child: SignaturePad(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
