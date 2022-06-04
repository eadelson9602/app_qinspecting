import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class PerfilFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserData? userDataLogged;

  updateTieneGuia(UserData value) {
    userDataLogged = value;
    notifyListeners();
  }

  updateGenero(String value) {
    userDataLogged?.genero = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
