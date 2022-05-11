import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/ui/input_decorations.dart';
import 'package:date_time_picker/date_time_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    final perfilForm = Provider.of<PerfilFormProvider>(context);
    perfilForm.userDataLogged = loginService.userDataLogged;

    final inspeccionProvider =
        Provider.of<InspeccionProvider>(context, listen: false);
    inspeccionProvider.listarDepartamentos();
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(children: [
      Stack(
        children: [
          _PortadaProfile(
            url: perfilForm.userDataLogged?.persImagen,
          ),
          const _PhotoDirectionCard(),
        ],
      ),
      const SizedBox(
        height: 20,
      ),
      const _FormProfile(),
      const SizedBox(
        height: 30,
      ),
    ])));
  }
}

enum GenrePerson { masculino, femenino }

class _FormProfile extends StatelessWidget {
  const _FormProfile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perfilForm = Provider.of<PerfilFormProvider>(context);
    final inspeccionProvider = Provider.of<InspeccionProvider>(context);
    inspeccionProvider.listarCiudades(perfilForm.userDataLogged!.dptId!);
    inspeccionProvider.listarTipoDocs();
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
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    initialValue: perfilForm.userDataLogged?.persNombres,
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
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    initialValue: perfilForm.userDataLogged?.persApellidos,
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
                  DropdownButtonFormField<int>(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.map,
                          hintText: '',
                          labelText: 'Departamento de expedición'),
                      value: perfilForm.userDataLogged?.dptId,
                      items: inspeccionProvider.departamentos.map((e) {
                        return DropdownMenuItem(
                          child: Text(e.label),
                          value: e.value,
                        );
                      }).toList(),
                      onChanged: (value) {
                        perfilForm.userDataLogged?.persLugarExpDoc = null;
                        inspeccionProvider.listarCiudades(value!);
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<int>(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.location_city,
                          hintText: '',
                          labelText: 'Ciudad de expedición'),
                      value: perfilForm.userDataLogged?.persLugarExpDoc,
                      items: inspeccionProvider.ciudades.map((e) {
                        return DropdownMenuItem(
                          child: Text(e.label),
                          value: e.value,
                        );
                      }).toList(),
                      onChanged: (value) {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField(
                      decoration: InputDecorations.authInputDecorations(
                          prefixIcon: Icons.assignment_ind,
                          hintText: '',
                          labelText: 'Tipo documento'),
                      value: perfilForm.userDataLogged?.tipoDocId,
                      items: inspeccionProvider.tipoDocumentos.map((e) {
                        return DropdownMenuItem(
                          child: Text(e.label!),
                          value: e.value,
                        );
                      }).toList(),
                      onChanged: (value) {}),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    autocorrect: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^(\d+)?\.?\d{0}'))
                    ],
                    initialValue: perfilForm.userDataLogged?.id.toString(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Ingrese número de documento';
                      return null;
                    },
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Número de documento',
                        prefixIcon: Icons.badge),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.date,
                    dateMask: 'd MMM, yyyy',
                    initialValue:
                        perfilForm.userDataLogged?.persFechaNaci.toString(),
                    firstDate: DateTime(1900),
                    decoration: InputDecorations.authInputDecorations(
                        hintText: '',
                        labelText: 'Fecha de nacimiento',
                        prefixIcon: Icons.calendar_today),
                    lastDate: DateTime(2030),
                    icon: const Icon(Icons.event),
                    onChanged: (val) => {},
                    onSaved: (val) => {},
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    title: const Text('¿Género?'),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Radio(
                            activeColor: Colors.green,
                            groupValue: perfilForm.userDataLogged?.persGenero.toString(),
                            value: 'MASCULINO',
                            onChanged: (value) => perfilForm.updateGenero(value.toString()),
                          ),
                          Text('Masculino'),
                          Radio(
                            activeColor: Colors.red,
                            groupValue: perfilForm.userDataLogged?.persGenero.toString(),
                            value: 'FEMENINO',
                            onChanged: (value) => perfilForm.updateGenero(value.toString()),
                          ),
                          Text('Femenino'),
                        ],
                      ),
                    ),
                  )
                ]))));
  }
}

class _PhotoDirectionCard extends StatelessWidget {
  const _PhotoDirectionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final perfilForm = Provider.of<PerfilFormProvider>(context, listen: true);
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
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(100)),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: _PortadaProfile(
                          url: perfilForm.userDataLogged?.persImagen,
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
                              onPressed: () {},
                              icon: const Icon(Icons.camera_alt_sharp)),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                    child: ListTile(
                  title:
                      Text(perfilForm.userDataLogged!.persNombres.toString()),
                  subtitle: Text(
                    perfilForm.userDataLogged!.persApellidos.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
              ],
            ),
          ),
          const Divider(
            height: 2,
            color: Colors.black26,
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.map_sharp),
            title: Text(perfilForm.userDataLogged!.departamento.toString()),
            subtitle: Text(
              perfilForm.userDataLogged!.ciuNombre.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.business),
            title: Text(perfilForm.userDataLogged!.persDireccion.toString()),
            subtitle: Text(
              perfilForm.userDataLogged!.ciuNombre.toString(),
              style: const TextStyle(fontSize: 12),
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
