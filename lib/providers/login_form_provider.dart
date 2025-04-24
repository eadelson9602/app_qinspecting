import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginFormProvider extends ChangeNotifier {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int usuario = 0;
  String password = '';
  bool existUser = true;
  bool obscureText = true;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  updateObscureText(bool value) {
    obscureText = value;
    notifyListeners();
  }

  bool isValidForm() {
    return formKey.currentState?.validate() ?? false;
  }

  Widget getImage(String? url) {
    if (url == null) {
      return const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        child: Image(
          image: AssetImage('assets/images/no-image.png'),
          height: 40,
        ),
      );
    } else if (url.contains('svg')) {
      return SvgPicture.network(
        url,
        semanticsLabel: 'Profile Image!',
        placeholderBuilder: (BuildContext context) =>
            Image(image: AssetImage('assets/images/loading-2.gif')),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(50)),
      child: FadeInImage(
          placeholder: const AssetImage('assets/images/loading-2.gif'),
          image: NetworkImage(url)),
    );
  }
}
