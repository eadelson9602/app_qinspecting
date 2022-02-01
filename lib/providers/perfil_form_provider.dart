import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class PerfilFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserData userDataLogged;

  PerfilFormProvider(this.userDataLogged);

  updateGenero(String value) {
    userDataLogged.persGenero = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
