import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class PerfilFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isUploadingPhoto = true;
  UserData? userDataLogged;

  updateProfile(UserData value) {
    print(
        '[PERFIL FORM] Actualizando perfil: ${value.nombres} ${value.apellidos}');
    userDataLogged = value;
    notifyListeners();
    print('[PERFIL FORM] Perfil actualizado y notificado');
  }

  updateProfilePhoto(bool value) {
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
}
