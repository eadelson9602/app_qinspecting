import 'dart:io';

import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      Stack(
        children: const [
          _PortadaProfile(
            url:
                'https://conceptodefinicion.de/wp-content/uploads/2016/01/Perfil2.jpg',
          ),
          _PhotoDirectionCard()
        ],
      )
    ])));
  }
}

class _PhotoDirectionCard extends StatelessWidget {
  const _PhotoDirectionCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))
            ]),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            height: 140,
            child: Row(
              children: [
                Stack(
                  children: [
                    const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: _PortadaProfile(
                          url:
                              'https://conceptodefinicion.de/wp-content/uploads/2016/01/Perfil2.jpg',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -1,
                      left: 45,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        child: Container(
                          height: 35,
                          width: 35,
                          color: Colors.green,
                          child: IconButton(
                              color: Colors.white,
                              iconSize: 20,
                              onPressed: () => print('HOla'),
                              icon: Icon(Icons.camera_alt_sharp)),
                        ),
                      ),
                    )
                  ],
                ),
                const Expanded(
                    child: ListTile(
                  title: Text('HOlA mundo'),
                  subtitle: Text(
                    'HOlA mundo',
                    style: TextStyle(fontSize: 12),
                  ),
                ))
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.black26,
          ),
          const ListTile(
            dense: true,
            leading: Icon(Icons.maps_ugc),
            title: Text('HOlA mundo'),
            subtitle: Text(
              'HOlA mundo',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const ListTile(
            dense: true,
            leading: Icon(Icons.business),
            title: Text('HOlA mundo'),
            subtitle: Text(
              'HOlA mundo',
              style: TextStyle(fontSize: 12),
            ),
          )
        ]),
      ),
    );
  }
}

class _PortadaProfile extends StatelessWidget {
  const _PortadaProfile({Key? key, this.url}) : super(key: key);

  final String? url;

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: _screenSize.height * 0.3,
      child: Opacity(opacity: 0.9, child: getImage(url)),
    );
  }

  Widget getImage(String? picture) {
    if (picture == null) {
      return const Image(
        image: AssetImage('assets/images/no-image.png'),
        fit: BoxFit.cover,
      );
    }

    if (picture.startsWith('http')) {
      return FadeInImage(
        placeholder: const AssetImage('assets/images/loading-2.gif'),
        image: NetworkImage(url.toString()),
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(picture),
      fit: BoxFit.cover,
    );
  }
}
