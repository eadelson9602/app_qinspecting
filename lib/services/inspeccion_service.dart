import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' show get;

import 'package:app_qinspecting/models/models.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:overlay_support/overlay_support.dart';

class InspeccionService extends ChangeNotifier {
  final dio = Dio();
  final loginService = LoginService();
  bool isLoading = false;
  bool isSaving = false;
  final List<Departamentos> departamentos = [];
  final List<Ciudades> ciudades = [];
  final List<Vehiculo> vehiculos = [];
  final List<Remolque> remolques = [];
  final List<ItemInspeccion> itemsInspeccion = [];
  final inspeccionProvider = InspeccionProvider();
  List<ResumenPreoperacionalServer> listInspections = [];
  int indexSelected = 0;
  DateTimeRange? myDateRange;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  ResumenPreoperacional resumePreoperacional = ResumenPreoperacional();
  final storage = new FlutterSecureStorage();


  void clearData (){
    resumePreoperacional.idCiudad = 0;
    resumePreoperacional.kilometraje = 0;
    resumePreoperacional.placaVehiculo = '';
  }

  Future<bool> checkConnection() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }

  void updateDate(DateTimeRange value) {
    myDateRange = value;
    notifyListeners();
  }

  void updateSaving(bool value) {
    isSaving = value;
    notifyListeners();
  }

  Future<bool> getLatesInspections(Empresa selectedEmpresa) async {
    final connectivityResult = await checkConnection();

    if (connectivityResult) {
      try {
        // Buscamos en el storage el token y lo asignamos a la instancia para poderlo usar en todas las peticiones de este servicio
        String token = await storage.read(key: 'token') ?? '';
        loginService.options.headers = {
          "x-access-token": token
        };

        Response response = await dio.get('${loginService.baseUrl}/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.numeroDocumento}', options: loginService.options);
        List<ResumenPreoperacionalServer> tempData = [];
        for (var item in response.data) {
          tempData.add(ResumenPreoperacionalServer.fromMap(item));
        }

        listInspections = [...tempData];
        return true;
      } on DioError catch (error) {
        print(error.response!.data);     
        showSimpleNotification(
          Text('No hemos podido obtener las inspecciones'),
          leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return Future.error(error.response!.data);
      }
    } else {
      // showSimpleNotification(
      //   Text('Sin conexión a internet'),
      //   leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
      //   autoDismiss: true,
      //   background: Colors.orange,
      //   position: NotificationPosition.bottom,
      // );
      return false;
    }
  }

  Future<List<Departamentos>> getDepartamentos(Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get('${loginService.baseUrl}/list_departments/$baseEmpresa', options: loginService.options);
    departamentos.clear();
    for (var item in response.data) {
      final tempDepartamento = Departamentos.fromMap(item);
      departamentos.add(tempDepartamento);
      DBProvider.db.nuevoDepartamento(tempDepartamento);
    }
    isLoading = false;
    notifyListeners();
    return departamentos;
  }

  Future<List<Ciudades>> getCiudades(Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get('${loginService.baseUrl}/list_city/$baseEmpresa');
    ciudades.clear();
    for (var item in response.data) {
      final tempCiudad = Ciudades.fromMap(item);
      ciudades.add(tempCiudad);
      DBProvider.db.nuevaCiudad(tempCiudad);
    }
    isLoading = false;
    notifyListeners();
    return ciudades;
  }

  Future<List<Vehiculo>> getVehiculos(Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get('${loginService.baseUrl}/show_placas_cabezote/$baseEmpresa', options: loginService.options);
    vehiculos.clear();
    DBProvider.db.clearsVehiculos();
    List<Future> futures = [];
    for (var item in response.data) {
      final tempVehiculo = Vehiculo.fromMap(item);
      vehiculos.add(tempVehiculo);
      futures.add(DBProvider.db.nuevoVehiculo(tempVehiculo));
    }
    await Future.wait(futures);
    isLoading = false;
    notifyListeners();
    return vehiculos;
  }

  Future<List<Remolque>> getTrailers(Empresa empresaSelected) async {
    isLoading = true;
    notifyListeners();
    final baseEmpresa = empresaSelected.nombreBase;

    Response response = await dio.get('${loginService.baseUrl}/show_placas_trailer/$baseEmpresa', options: loginService.options);
    remolques.clear();
    DBProvider.db.clearsRemolques();
    List<Future> futures = [];
    for (var item in response.data) {
      final tempRemolque = Remolque.fromMap(item);
      remolques.add(tempRemolque);
      futures.add(DBProvider.db.nuevoRemolque(tempRemolque));
    }
    await Future.wait(futures);
    isLoading = false;
    notifyListeners();
    return remolques;
  }

  Future<Map<String, dynamic>?> uploadImage({required String path, required String company, required String folder}) async {
    try {
      
      var fileName = (path.split('/').last);
      var formData = FormData.fromMap({'files': await MultipartFile.fromFile('${path}', filename: '${fileName}')});
      Response response = await dio.post('${loginService.baseUrl}/upload_file/${company.toLowerCase()}/${folder}', data: formData, options: loginService.options);
      final resp = ResponseUploadFile.fromMap(response.data);
      
      return resp.toMap();
    } on DioError catch (error) {
      print(error.response!.data);
      showSimpleNotification(Text('No se ha podido subir la foto al servidor'),
        leading: Icon(Icons.check),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom
      );
      return Future.error(error.response!.data);
    }
  }

  Future<bool> getData(Empresa selectedEmpresa) async {
    try {
      // Buscamos en el storage el token y lo asignamos a la instancia para poderlo usar en todas las peticiones de este servicio
      String token = await storage.read(key: 'token') ?? '';
      loginService.options.headers = {
        "x-access-token": token
      };
      final baseEmpresa = selectedEmpresa.nombreBase;
      await loginService.getUserData(selectedEmpresa);
      Response response = await dio.get('${loginService.baseUrl}/get_placas_cabezote/$baseEmpresa', options: loginService.options);
      for (var item in response.data) {
        final tempVehiculo = Vehiculo.fromMap(item);
        DBProvider.db.nuevoVehiculo(tempVehiculo);
      }
      Response responseTrailer = await dio.get('${loginService.baseUrl}/get_placas_trailer/$baseEmpresa', options: loginService.options);
      for (var item in responseTrailer.data) {
        final tempRemolque = Remolque.fromMap(item);
        DBProvider.db.nuevoRemolque(tempRemolque);
      }
      Response responseDepartamentos = await dio.get('${loginService.baseUrl}/list_departments/$baseEmpresa', options: loginService.options);
      for (var item in responseDepartamentos.data) {
        final tempDepartamento = Departamentos.fromMap(item);
        DBProvider.db.nuevoDepartamento(tempDepartamento);
      }
      Response responseCiudades = await dio.get('${loginService.baseUrl}/list_city/$baseEmpresa', options: loginService.options);
      for (var item in responseCiudades.data) {
        final tempCiudad = Ciudades.fromMap(item);
        DBProvider.db.nuevaCiudad(tempCiudad);
      }
      Response responseItems = await dio.get('${loginService.baseUrl}/list_items_x_placa/$baseEmpresa', options: loginService.options);
      for (var item in responseItems.data) {
        final tempItem = ItemInspeccion.fromMap(item);
        DBProvider.db.nuevoItem(tempItem);
      }

      Response responseTipodoc = await dio.get('${loginService.baseUrl}/list_type_documents/$baseEmpresa', options: loginService.options);
      for (var item in responseTipodoc.data) {
        final tempTipoDoc = TipoDocumentos.fromMap(item);
        DBProvider.db.nuevoTipoDocumento(tempTipoDoc);
      }

      return true;
    } on DioError catch (error) {
      print(error.response!.data);
      showSimpleNotification(Text('No se ha podido obtener datos iniciales'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);

      Future.error(error.response!.data);
      return false;
    }
  }

  Future<Map<String, dynamic>> sendInspeccion(ResumenPreoperacional inspeccion, Empresa selectedEmpresa) async {
    try {
      final connectivityResult = await checkConnection();
      if (connectivityResult) {
        // Se envia la foto del kilometraje al servidor
        Map<String, dynamic>? responseUploadKilometraje = await uploadImage(
          path: inspeccion.urlFotoKm!,
          company: '${selectedEmpresa.nombreQi}',
          folder: 'inspecciones'
        );
        print(inspeccion.toJson());
        inspeccion.urlFotoKm = responseUploadKilometraje?['path'];

        // Se envia la foto de la guia si tiene
        if (inspeccion.numeroGuia?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploadGuia = await uploadImage(
            path: inspeccion.urlFotoGuia!,
            company: selectedEmpresa.nombreQi!,
            folder: 'inspecciones'
          );
          inspeccion.urlFotoGuia = responseUploadGuia?['path'];
        }

        // Guardamos el resumen del preoperacional en el server
        final responseResumen = await dio.post('${loginService.baseUrl}/insert_preoperacional', options: loginService.options, data: inspeccion.toJson());
        final resumen = Respuesta.fromMap(responseResumen.data);
        // Consultamos en sqlite las respuestas
        List<Item> respuestas = await inspeccionProvider.cargarTodasRespuestas(inspeccion.id!);

        List<Future> Promesas = [];
        respuestas.forEach((element) {
          element.fkPreoperacional = resumen.idInspeccion;
          if (element.adjunto != null) {
            Promesas.add(uploadImage(path: element.adjunto!, company: selectedEmpresa.nombreQi!, folder: 'inspecciones')
            .then((response) {
              final responseUpload = ResponseUploadFile.fromMap(response!);
              element.adjunto = responseUpload.path;

              return dio.post('${loginService.baseUrl}/insert_respuestas_preoperacional', options: loginService.options, data: element.toJson());
            }));
          } else {
            Promesas.add(dio.post('${loginService.baseUrl}/insert_respuestas_preoperacional', options: loginService.options, data: element.toJson()));
          }
        });

        // Ejecutamos todas las peticiones
        await Future.wait(Promesas).then((value) async {
          // print(value);
        });

        // get a notification at top of screen.
        showSimpleNotification(Text(resumen.message!),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.green,
          position: NotificationPosition.bottom
        );

        isSaving = false;
        notifyListeners();
        return resumen.toMap();
      } else {
        showSimpleNotification(
          Text('Debe conectarse a internet'),
          leading: Icon(Icons.wifi_off),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return {
          "message": 'Sin conexión a internet',
          "ok": false,
          "idInspeccion": 0
        };
      }
    } on DioError catch (error) {
      print(error.response!.data);
      showSimpleNotification(Text('No se ha podido guardar la inspección'),
        leading: Icon(Icons.check),
        autoDismiss: true,
        background: Colors.orange,
        position: NotificationPosition.bottom
      );
      return Future.error(error.response!.data);
    } finally {
      isSaving = false;
    }
  }

  Future<Pdf> detatilPdf(Empresa empresaSelected, ResumenPreoperacionalServer inspeccion) async {
    Response response = await dio.get('${loginService.baseUrl}/inspeccion/${empresaSelected.nombreBase}/${inspeccion.resuPreId}', options: loginService.options);

    List<Future> promesas = [];

    Pdf temData = Pdf.fromJson(response.toString());
    temData.detalle.forEach((categoria) {
      categoria.respuestas.forEach((respuesta) {
        if (respuesta.foto != null) {
          promesas.add(get(Uri.parse(respuesta.foto!)).then((value) {
            return {"foto": respuesta.foto!, "data": value};
          }));
        }
      });
    });

    List<dynamic> responseFile = await Future.wait(promesas).then((value) => value);

    temData.detalle.forEach((categoria) {
      categoria.respuestas.forEach((respuesta) {
        if (respuesta.foto != null) {
          responseFile.forEach((element) {
            if (element['foto'] == respuesta.foto) {
              respuesta.fotoConverted = element['data'].bodyBytes;
            }
          });
        }
      });
    });
    return temData;
  }
}
