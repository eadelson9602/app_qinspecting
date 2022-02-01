import 'package:flutter/material.dart';

import 'package:app_qinspecting/models/models.dart';

class PerfilFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  UserData userData;

  PerfilFormProvider(this.userData);

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }
}
