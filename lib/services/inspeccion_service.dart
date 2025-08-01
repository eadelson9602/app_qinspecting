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
  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 60),
    sendTimeout: Duration(seconds: 30),
  ));
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

  void clearData() {
    resumePreoperacional.idCiudad = 0;
    resumePreoperacional.kilometraje = 0;
    resumePreoperacional.placaVehiculo = '';
  }

  Future<bool> checkConnection() async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
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
        loginService.options.headers = {"x-access-token": token};

        Response response = await dio.get(
            '${loginService.baseUrl}/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.numeroDocumento}',
            options: loginService.options);
        List<ResumenPreoperacionalServer> tempData = [];
        for (var item in response.data) {
          tempData.add(ResumenPreoperacionalServer.fromMap(item));
        }

        listInspections = [...tempData];
        return true;
      } on DioException catch (error) {
        print(error.response?.data);
        showSimpleNotification(
          Text('No hemos podido obtener las inspecciones'),
          leading: Icon(Icons.wifi_tethering_error_rounded_outlined),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return Future.error(error);
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

    Response response = await dio.get(
        '${loginService.baseUrl}/list_departments/$baseEmpresa',
        options: loginService.options);
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

    Response response =
        await dio.get('${loginService.baseUrl}/list_city/$baseEmpresa');
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

    Response response = await dio.get(
        '${loginService.baseUrl}/show_placas_cabezote/$baseEmpresa',
        options: loginService.options);
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

    Response response = await dio.get(
        '${loginService.baseUrl}/show_placas_trailer/$baseEmpresa',
        options: loginService.options);
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

  Future<Map<String, dynamic>?> uploadImage(
      {required String path,
      required String company,
      required String folder}) async {
    try {
      var fileName = (path.split('/').last);
      var formData = FormData.fromMap({
        'files':
            await MultipartFile.fromFile('${path}', filename: '${fileName}')
      });
      Response response = await dio.post(
          '${loginService.baseUrl}/upload_file/${company.toLowerCase()}/${folder}',
          data: formData,
          options: loginService.options);
      final resp = ResponseUploadFile.fromMap(response.data);

      return resp.toMap();
    } on DioException catch (error) {
      print(error.response!.data);
      showSimpleNotification(Text('No se ha podido subir la foto al servidor'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
      return Future.error(error.response!.data);
    }
  }

  Future<bool> getData(Empresa selectedEmpresa) async {
    try {
      // Buscamos en el storage el token y lo asignamos a la instancia para poderlo usar en todas las peticiones de este servicio
      String token = await storage.read(key: 'token') ?? '';
      loginService.options.headers = {"x-access-token": token};
      final baseEmpresa = selectedEmpresa.nombreBase;

      await loginService.getUserData(selectedEmpresa);

      // Perform all API calls in parallel to reduce total time
      List<Future> apiCalls = [];

      apiCalls.add(dio.get(
          '${loginService.baseUrl}/get_placas_cabezote/$baseEmpresa',
          options: loginService.options));

      apiCalls.add(dio.get(
          '${loginService.baseUrl}/get_placas_trailer/$baseEmpresa',
          options: loginService.options));

      apiCalls.add(dio.get(
          '${loginService.baseUrl}/list_departments/$baseEmpresa',
          options: loginService.options));

      apiCalls.add(dio.get('${loginService.baseUrl}/list_city/$baseEmpresa',
          options: loginService.options));

      apiCalls.add(dio.get(
          '${loginService.baseUrl}/list_items_x_placa/$baseEmpresa',
          options: loginService.options));

      apiCalls.add(dio.get(
          '${loginService.baseUrl}/list_type_documents/$baseEmpresa',
          options: loginService.options));

      // Wait for all API calls to complete
      List<dynamic> responses = await Future.wait(apiCalls);

      // Process database operations in batches to reduce lock time
      List<Future> dbOperations = [];

      // Process vehicles
      for (var item in responses[0].data) {
        final tempVehiculo = Vehiculo.fromMap(item);
        dbOperations.add(DBProvider.db.nuevoVehiculo(tempVehiculo));
      }

      // Process trailers
      for (var item in responses[1].data) {
        final tempRemolque = Remolque.fromMap(item);
        dbOperations.add(DBProvider.db.nuevoRemolque(tempRemolque));
      }

      // Process departments
      for (var item in responses[2].data) {
        final tempDepartamento = Departamentos.fromMap(item);
        dbOperations.add(DBProvider.db.nuevoDepartamento(tempDepartamento));
      }

      // Process cities
      for (var item in responses[3].data) {
        final tempCiudad = Ciudades.fromMap(item);
        dbOperations.add(DBProvider.db.nuevaCiudad(tempCiudad));
      }

      // Process items
      for (var item in responses[4].data) {
        final tempItem = ItemInspeccion.fromMap(item);
        dbOperations.add(DBProvider.db.nuevoItem(tempItem));
      }

      // Process document types
      for (var item in responses[5].data) {
        final tempTipoDoc = TipoDocumentos.fromMap(item);
        dbOperations.add(DBProvider.db.nuevoTipoDocumento(tempTipoDoc));
      }

      // Execute all database operations in parallel
      await Future.wait(dbOperations);

      return true;
    } on DioException catch (error) {
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

  Future<Map<String, dynamic>> sendInspeccion(
      ResumenPreoperacional inspeccion, Empresa selectedEmpresa) async {
    try {
      final connectivityResult = await checkConnection();
      if (connectivityResult) {
        // Se envia la foto del kilometraje al servidor
        Map<String, dynamic>? responseUploadKilometraje = await uploadImage(
            path: inspeccion.urlFotoKm!,
            company: '${selectedEmpresa.nombreQi}',
            folder: 'inspecciones');
        inspeccion.urlFotoKm = responseUploadKilometraje?['path'];

        // Se envia la foto de la guia si tiene
        if (inspeccion.numeroGuia?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploadGuia = await uploadImage(
              path: inspeccion.urlFotoGuia!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoGuia = responseUploadGuia?['path'];
        }

        // Se envia la foto del cabezote si tiene
        if (resumePreoperacional.urlFotoCabezote?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploaCabezote = await uploadImage(
              path: resumePreoperacional.urlFotoCabezote!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoCabezote = responseUploaCabezote?['path'];
        }

        // Se envia la foto del remolque si tiene
        if (resumePreoperacional.urlFotoRemolque?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploaRemolque = await uploadImage(
              path: resumePreoperacional.urlFotoRemolque!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoRemolque = responseUploaRemolque?['path'];
        }

        // Guardamos el resumen del preoperacional en el server
        final responseResumen = await dio.post(
            '${loginService.baseUrl}/insert_preoperacional',
            options: loginService.options,
            data: inspeccion.toJson());
        final resumen = Respuesta.fromMap(responseResumen.data);

        // Consultamos en sqlite las respuestas
        List<Item> respuestas =
            await inspeccionProvider.cargarTodasRespuestas(inspeccion.id!);

        List<Future> Promesas = [];
        respuestas.forEach((element) {
          element.fkPreoperacional = resumen.idInspeccion;
          if (element.adjunto != null) {
            Promesas.add(uploadImage(
                    path: element.adjunto!,
                    company: selectedEmpresa.nombreQi!,
                    folder: 'inspecciones')
                .then((response) {
              final responseUpload = ResponseUploadFile.fromMap(response!);
              element.adjunto = responseUpload.path;

              return dio.post(
                  '${loginService.baseUrl}/insert_respuestas_preoperacional',
                  options: loginService.options,
                  data: element.toJson());
            }));
          } else {
            Promesas.add(dio.post(
                '${loginService.baseUrl}/insert_respuestas_preoperacional',
                options: loginService.options,
                data: element.toJson()));
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
            position: NotificationPosition.bottom);

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
    } on DioException catch (error) {
      print(error.response?.data);
      showSimpleNotification(Text('No se ha podido guardar la inspección'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
      return Future.error(error.response?.data);
    } finally {
      isSaving = false;
    }
  }

  Future<Pdf> detatilPdf(
      Empresa empresaSelected, ResumenPreoperacionalServer inspeccion) async {
    try {
      print('Starting detatilPdf for inspection: ${inspeccion.resuPreId}');

      // Check connectivity first
      bool hasConnection = await checkConnection();
      if (!hasConnection) {
        throw Exception('Sin conexión a internet');
      }

      print('Network connectivity confirmed');

      Response response = await dio
          .get(
              '${loginService.baseUrl}/inspeccion/${empresaSelected.nombreBase}/${inspeccion.resuPreId}',
              options: loginService.options)
          .timeout(Duration(seconds: 30));

      print('API call completed successfully');
      Pdf temData = Pdf.fromJson(response.toString());

      // Collect all image URLs that need to be downloaded
      List<String> imageUrls = [];
      temData.detalle.forEach((categoria) {
        categoria.respuestas.forEach((respuesta) {
          if (respuesta.foto != null && respuesta.foto!.isNotEmpty) {
            imageUrls.add(respuesta.foto!);
          }
        });
      });

      print('Found ${imageUrls.length} images to download');

      // Download images with better timeout handling
      List<Future> promesas = [];
      Map<String, dynamic> imageResults = {};

      for (String imageUrl in imageUrls) {
        promesas.add(get(Uri.parse(imageUrl))
            .timeout(Duration(seconds: 8))
            .then((value) {
          imageResults[imageUrl] = value.bodyBytes;
          print('Successfully downloaded: $imageUrl');
          return {"foto": imageUrl, "data": value};
        }).catchError((error) {
          print('Error downloading image $imageUrl: $error');
          imageResults[imageUrl] = null;
          return {"foto": imageUrl, "data": null};
        }));
      }

      // Wait for all image downloads with overall timeout
      if (promesas.isNotEmpty) {
        print('Starting concurrent image downloads...');
        try {
          await Future.wait(promesas).timeout(Duration(seconds: 25));
          print('Image downloads completed');
        } catch (error) {
          print('Error during image downloads: $error');
          // Continue with partial data
        }
      }

      // Assign downloaded images to responses
      int successfulDownloads = 0;
      temData.detalle.forEach((categoria) {
        categoria.respuestas.forEach((respuesta) {
          if (respuesta.foto != null && respuesta.foto!.isNotEmpty) {
            if (imageResults.containsKey(respuesta.foto!) &&
                imageResults[respuesta.foto!] != null) {
              respuesta.fotoConverted = imageResults[respuesta.foto!];
              successfulDownloads++;
            }
          }
        });
      });

      print(
          'Successfully processed $successfulDownloads out of ${imageUrls.length} images');
      return temData;
    } catch (e) {
      print('Error in detatilPdf: $e');
      throw Exception('Error al obtener datos del PDF: $e');
    }
  }
}
