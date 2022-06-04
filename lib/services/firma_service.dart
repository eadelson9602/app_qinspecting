import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:overlay_support/overlay_support.dart';

class FirmaService extends ChangeNotifier {
  final loginService = LoginService();
  final dio = Dio();
  bool isLoading = false;
  int indexTabaCreateSignature = 0;
  String aceptaTerminos = 'NO';
  final storage = new FlutterSecureStorage();

  updateTabIndex(int value) {
    indexTabaCreateSignature = value;
    notifyListeners();
  }

  updateTerminos(String value) {
    aceptaTerminos = value;
    notifyListeners();
  }

  Future<Map<dynamic, dynamic>> insertSignature(Map firma) async {
    try {
      isLoading = true;
      notifyListeners();

      Response response = await dio.post('${loginService.baseUrl}/insert_signature', options: loginService.options, data: jsonEncode(firma));

      isLoading = false;
      notifyListeners();
      return response.data;
    } on DioError catch (error) {
      print(error.response!.data);
      showSimpleNotification(
        Text('No hemos podido obtener la firma'),
        leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
      return Future.error(error.response!.data);
    }
  }

  Future<Firma?> getInfoFirma(Empresa empresaSelected) async {
    try {
      // Buscamos en el storage el token y lo asignamos a la instancia para poderlo usar en todas las peticiones de este servicio
      String token = await storage.read(key: 'token') ?? '';
      loginService.options.headers = {
        "x-access-token": token
      };
      Response response = await dio.get('${loginService.baseUrl}/get_info_firma/${empresaSelected.nombreBase}/${empresaSelected.numeroDocumento}', options: loginService.options);

      return response.data.toString().isNotEmpty ? Firma.fromMap(response.data) : null;
    } on DioError catch (error) {
      showSimpleNotification(
        Text('No hemos podido obtener la firma'),
        leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom,
      );
      return Future.error(error.response!.data);
    }
  }
}
