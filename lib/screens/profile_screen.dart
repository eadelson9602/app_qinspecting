import 'dart:io';

import 'package:app_qinspecting/ui/input_decorations.dart';
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
          _PhotoDirectionCard(),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      _FormProfile(),
      const SizedBox(
        height: 30,
      ),
    ])));
  }
}

class _FormProfile extends StatelessWidget {
  const _FormProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
            padding:
                const EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 40),
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5))
                ]),
            child: Form(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text('Datos personales',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black38)),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese nombres';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Nombres',
                        prefixIcon: Icons.person),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese apellidos';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Apellidos',
                        prefixIcon: Icons.person),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.map,
                          hintText: '',
                          labelText: 'Departamento de expedición'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Ciudad 1'))
                      ],
                      onChanged: (value) {
                        print(value);
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.location_city,
                          hintText: '',
                          labelText: 'Ciudad de expedición'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Ciudad 1'))
                      ],
                      onChanged: (value) {
                        print(value);
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.assignment_ind,
                          hintText: '',
                          labelText: 'Tipo documento'),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('Ciudad 1'))
                      ],
                      onChanged: (value) {
                        print(value);
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese su usuario';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Número documento',
                        prefixIcon: Icons.badge),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese su usuario';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '1121947539',
                        labelText: 'Usuario',
                        prefixIcon: Icons.person),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese su usuario';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '1121947539',
                        labelText: 'Usuario',
                        prefixIcon: Icons.person),
                  ),
                ]))));
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100)),
                        child: Container(
                          height: 35,
                          width: 35,
                          color: Colors.green,
                          child: IconButton(
                              color: Colors.white,
                              iconSize: 20,
                              onPressed: () => print('HOla'),
                              icon: const Icon(Icons.camera_alt_sharp)),
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
