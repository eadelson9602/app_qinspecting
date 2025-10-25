import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class PerfilFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isUploadingPhoto = false;
  bool isLoadingInitialData = false;
  UserData? userDataLogged;

  updateProfile(UserData value) {
    print(
        '[PERFIL FORM] Actualizando perfil: ${value.nombres} ${value.apellidos}');
    userDataLogged = value;
    notifyListeners();
    print('[PERFIL FORM] Perfil actualizado y notificado');
  }

  updateProfilePhoto(bool value) {
    print('[PERFIL FORM] Actualizando foto de perfil: $value');
    isUploadingPhoto = value;
    notifyListeners();
  }

  updateGenero(String value) {
    print('[PERFIL FORM] Actualizando género a: $value');
    userDataLogged?.genero = value;
    notifyListeners();
    print('[PERFIL FORM] Género actualizado y notificado');
  }

  /// Obtiene la imagen a mostrar (solo del servidor)
  String? getDisplayImage() {
    final result = userDataLogged?.urlFoto;
    print(
        '[PERFIL FORM] getDisplayImage() retornando: $result (urlFoto: ${userDataLogged?.urlFoto})');
    return result;
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Inicia la carga de datos iniciales
  void startLoadingInitialData() {
    isLoadingInitialData = true;
    notifyListeners();
  }

  /// Finaliza la carga de datos iniciales
  void finishLoadingInitialData() {
    isLoadingInitialData = false;
    notifyListeners();
  }

  /// Verifica si los datos están completamente cargados
  bool get hasCompleteData {
    if (userDataLogged == null) {
      print('[PERFIL FORM] hasCompleteData: false - userDataLogged es null');
      return false;
    }

    final hasNames =
        userDataLogged!.nombres != null && userDataLogged!.nombres!.isNotEmpty;
    final hasSurnames = userDataLogged!.apellidos != null &&
        userDataLogged!.apellidos!.isNotEmpty;
    final hasEmail =
        userDataLogged!.email != null && userDataLogged!.email!.isNotEmpty;
    final hasPhone = userDataLogged!.numeroCelular != null &&
        userDataLogged!.numeroCelular!.isNotEmpty;

    final result = hasNames && hasSurnames && hasEmail && hasPhone;
    print(
        '[PERFIL FORM] hasCompleteData: $result - Names: $hasNames, Surnames: $hasSurnames, Email: $hasEmail, Phone: $hasPhone');

    return result;
  }
}
