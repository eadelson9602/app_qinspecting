import 'dart:io';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

import 'package:app_qinspecting/models/inspeccion.dart';
import 'package:app_qinspecting/models/empresa.dart';
import 'package:app_qinspecting/models/departamentos_ciudad.dart';
import 'package:app_qinspecting/models/vehiculo.dart';
import 'package:app_qinspecting/models/remolque.dart';
import 'package:app_qinspecting/models/item_inspeccion.dart';
import 'package:app_qinspecting/models/user_data.dart';
import 'package:app_qinspecting/models/pdf.dart';
import 'package:app_qinspecting/providers/providers.dart';
import 'package:app_qinspecting/services/services.dart';
import 'package:app_qinspecting/services/notification_service.dart';
import 'package:app_qinspecting/services/background_upload_service.dart';
import 'package:overlay_support/overlay_support.dart';

class InspeccionService extends ChangeNotifier {
  final dio = Dio(BaseOptions(
    connectTimeout: Duration(seconds: 60), // Aumentado para segundo plano
    receiveTimeout: Duration(seconds: 90), // Aumentado para segundo plano
    sendTimeout: Duration(seconds: 60), // Aumentado para segundo plano
  ));
  final loginService = LoginService();
  bool isLoading = false;

  // StreamController para emitir progreso de carga de datos
  final StreamController<double> _dataLoadProgressController =
      StreamController<double>.broadcast();
  Stream<double> get dataLoadProgress => _dataLoadProgressController.stream;
  bool isSaving = false;
  // Progreso por lote para subidas masivas de imágenes
  double batchProgress = 0.0; // 0..1 del lote actual
  int currentBatchIndex = 0; // índice del lote actual (1-based)
  int totalBatches = 0; // total de lotes

  /// Obtiene el estado actual de la aplicación
  AppLifecycleState? get currentAppState =>
      WidgetsBinding.instance.lifecycleState;

  /// Log del estado de la app para debugging
  void _logAppState(String operation) {
    final state = currentAppState;
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
      case null:
        break;
    }
  }

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

  // Verificación de conexión estable (WiFi o móvil >= 4G aprox.)
  Future<bool> isConnectionStable({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      print('[IS CONNECTION STABLE] 🔍 Verificando estabilidad de conexión...');

      final connectivityList = await Connectivity().checkConnectivity();
      print('[IS CONNECTION STABLE] 📡 Tipo de conexión: $connectivityList');

      // Obtener el primer resultado o 'none' si está vacío
      final connectivity = connectivityList.isNotEmpty
          ? connectivityList.first
          : ConnectivityResult.none;

      print('[IS CONNECTION STABLE] 📡 Conexión detectada: $connectivity');

      if (connectivity == ConnectivityResult.none) {
        print('[IS CONNECTION STABLE] ❌ Sin conexión');
        return false;
      }

      // Si es Wi‑Fi, considerar estable inmediatamente
      if (connectivity == ConnectivityResult.wifi) {
        print('[IS CONNECTION STABLE] ✅ Conexión WiFi - estable');
        return true;
      }

      if (connectivity != ConnectivityResult.mobile) {
        print(
            '[IS CONNECTION STABLE] ❌ Tipo de conexión no soportado: $connectivity');
        return false;
      }

      // Para móvil (4G/5G), hacer una verificación simple a un solo endpoint
      print(
          '[IS CONNECTION STABLE] 📱 Conexión móvil detectada, probando estabilidad...');

      try {
        // Usar un endpoint simple para verificar
        final testUrl = '${loginService.baseUrl}/get_user_data';
        print('[IS CONNECTION STABLE] 🌐 Probando: $testUrl');

        final uri = Uri.parse(testUrl);
        final res = await dio
            .getUri(uri, options: Options(method: 'GET'))
            .timeout(timeout);

        // Si la respuesta es exitosa o es un error de autenticación, la conexión está estable
        if (res.statusCode != null && res.statusCode! < 500) {
          print(
              '[IS CONNECTION STABLE] ✅ Conexión estable (status: ${res.statusCode})');
          return true;
        }

        print(
            '[IS CONNECTION STABLE] ⚠️ Respuesta del servidor: ${res.statusCode}');
        return false;
      } catch (e) {
        print('[IS CONNECTION STABLE] ⚠️ Error al verificar: $e');
        // Si es un error de timeout, la conexión puede no ser estable
        if (e.toString().contains('timeout')) {
          print('[IS CONNECTION STABLE] ❌ Timeout en verificación');
          return false;
        }
        // Para otros errores (auth, etc), considerar estable
        print('[IS CONNECTION STABLE] ✅ Conexión estable (error no crítico)');
        return true;
      }
    } catch (e) {
      print('[IS CONNECTION STABLE] ❌ Error general: $e');
      return false;
    }
  }

  Future<bool> getLatesInspections(Empresa selectedEmpresa,
      {int maxRetries = 3}) async {
    final connectivityResult = await checkConnection();

    if (connectivityResult) {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          // Configuramos el token desde secure storage
          await loginService.setTokenFromStorage();

          Response response = await dio.get(
              '${loginService.baseUrl}/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.numeroDocumento}',
              options: loginService.options,
              queryParameters: {'timeout': 30});

          List<ResumenPreoperacionalServer> tempData = [];
          if (response.data != null && response.data is List) {
            for (var item in response.data) {
              tempData.add(ResumenPreoperacionalServer.fromMap(item));
            }
          }

          listInspections = [...tempData];
          return true;
        } on DioException catch (error) {
          // Si es un error de timeout o conexión, continuar con el siguiente intento
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError) {
            if (attempt == maxRetries) {
              return false; // Retornar false en lugar de lanzar excepción
            } else {
              await Future.delayed(Duration(seconds: 2 * attempt));
            }
          } else {
            // Para otros tipos de errores, lanzar excepción
            if (attempt == maxRetries) {
              throw Exception(
                  'No hemos podido obtener las inspecciones después de $maxRetries intentos: ${error.message}');
            } else {
              await Future.delayed(Duration(seconds: 2 * attempt));
            }
          }
        } catch (e) {
          if (attempt == maxRetries) {
            return false; // Retornar false en lugar de lanzar excepción
          } else {
            await Future.delayed(Duration(seconds: 2 * attempt));
          }
        }
      }
      return false; // Retornar false en lugar de lanzar excepción
    } else {
      return false; // Retornar false en lugar de lanzar excepción
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
      _logAppState('UPLOAD_IMAGE');

      var fileName = (path.split('/').last);
      var formData = FormData.fromMap({
        'files':
            await MultipartFile.fromFile('${path}', filename: '${fileName}')
      });

      print('📤 DEBUG: Enviando petición al servidor...');
      print(
          '📤 DEBUG: Archivo: $fileName, Tamaño: ${await File(path).length()} bytes');
      print(
          '📤 DEBUG: URL: ${loginService.baseUrl}/upload_file/${company.toLowerCase()}/${folder}');

      // Asegurarse de que el token esté actualizado
      await loginService.setTokenFromStorage();

      // Obtener headers del dio de loginService que tiene el token configurado
      final headers =
          Map<String, dynamic>.from(loginService.dio.options.headers);
      print('📤 DEBUG: Headers: $headers');

      // Verificar que el token esté presente en los headers
      if (!headers.containsKey('x-access-token') ||
          headers['x-access-token'] == null ||
          headers['x-access-token'].toString().isEmpty) {
        print('❌ ERROR: Token de autenticación no disponible');
        throw Exception(
            'Token de autenticación no disponible. Por favor, inicia sesión nuevamente.');
      }

      final startTime = DateTime.now();
      Response response = await dio.post(
          '${loginService.baseUrl}/upload_file/${company.toLowerCase()}/${folder}',
          data: formData,
          options: Options(
            headers: headers,
            sendTimeout: Duration(seconds: 60), // Aumentado a 60 segundos
            receiveTimeout: Duration(seconds: 60), // Aumentado a 60 segundos
            validateStatus: (status) {
              return status! < 500; // Aceptar códigos de estado menores a 500
            },
          ));

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      print('📤 DEBUG: Petición completada en ${duration.inSeconds} segundos');

      print(
          '📤 DEBUG: Respuesta recibida del servidor: ${response.statusCode}');
      final resp = ResponseUploadFile.fromMap(response.data);
      print('✅ DEBUG: Imagen subida exitosamente: ${resp.path}');
      return resp.toMap();
    } on DioException catch (error) {
      print('❌ ERROR: Error en uploadImage: ${error.message}');

      // Manejo específico de diferentes tipos de errores
      if (error.type == DioExceptionType.receiveTimeout) {
        print(
            '❌ ERROR: Timeout de recepción - El servidor tardó más de 60 segundos en responder');
        showSimpleNotification(
          Text(
              'El servidor está tardando mucho en responder. Intenta nuevamente.'),
          leading: Icon(Icons.timer_off),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
      } else if (error.type == DioExceptionType.sendTimeout) {
        print(
            '❌ ERROR: Timeout de envío - No se pudo enviar el archivo en 60 segundos');
        showSimpleNotification(
          Text('No se pudo enviar el archivo. Verifica tu conexión.'),
          leading: Icon(Icons.wifi_off),
          autoDismiss: true,
          background: Colors.red,
          position: NotificationPosition.bottom,
        );
      } else if (error.type == DioExceptionType.connectionTimeout) {
        print('❌ ERROR: Timeout de conexión - No se pudo conectar al servidor');
        showSimpleNotification(
          Text('No se pudo conectar al servidor. Verifica tu conexión.'),
          leading: Icon(Icons.cloud_off),
          autoDismiss: true,
          background: Colors.red,
          position: NotificationPosition.bottom,
        );
      } else {
        print('❌ ERROR: Otro tipo de error: ${error.type}');
        showSimpleNotification(
          Text('Error al subir la imagen. Intenta nuevamente.'),
          leading: Icon(Icons.error),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
      }

      if (error.response != null) {
        print('❌ ERROR: Response data: ${error.response!.data}');
      } else {
        print('❌ ERROR: No response data available');
      }

      return Future.error(error.response?.data ?? error.message);
    } catch (e) {
      print('❌ ERROR: Error inesperado en uploadImage: $e');
      return Future.error(e);
    }
  }

  Future<bool> getData(Empresa selectedEmpresa) async {
    try {
      // Emitir progreso inicial
      _dataLoadProgressController.add(0.05);

      // Configuramos el token desde secure storage
      await loginService.setTokenFromStorage();
      final baseEmpresa = selectedEmpresa.nombreBase;

      _dataLoadProgressController.add(0.10);
      await loginService.getUserData(selectedEmpresa);

      _dataLoadProgressController.add(0.15);
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

      _dataLoadProgressController.add(0.20);
      // Wait for all API calls to complete
      List<dynamic> responses = await Future.wait(apiCalls);

      _dataLoadProgressController.add(0.30);
      // Process database operations in batches to reduce lock time
      List<Future> dbOperationsVehiculos = [];
      List<Future> dbOperationsRemolques = [];
      List<Future> dbOperationsDepartamentos = [];
      List<Future> dbOperationsCiudades = [];
      List<Future> dbOperationsItems = [];
      List<Future> dbOperationsTipoDocumentos = [];
      // // Process vehicles
      for (var item in responses[0].data) {
        final tempVehiculo = Vehiculo.fromMap(item);
        dbOperationsVehiculos.add(DBProvider.db.nuevoVehiculo(tempVehiculo));
      }

      print('dbOperationsVehiculos: ${dbOperationsVehiculos.length}');
      await Future.wait(dbOperationsVehiculos);
      _dataLoadProgressController.add(0.40);

      print('✅vehiculos cargados');

      // // Process trailers
      for (var item in responses[1].data) {
        final tempRemolque = Remolque.fromMap(item);
        dbOperationsRemolques.add(DBProvider.db.nuevoRemolque(tempRemolque));
      }

      print('dbOperationsRemolques: ${dbOperationsRemolques.length}');
      await Future.wait(dbOperationsRemolques);
      _dataLoadProgressController.add(0.50);
      print('✅remolques cargados');

      // Process departments
      for (var item in responses[2].data) {
        final tempDepartamento = Departamentos.fromMap(item);
        dbOperationsDepartamentos
            .add(DBProvider.db.nuevoDepartamento(tempDepartamento));
      }

      print('dbOperationsDepartamentos: ${dbOperationsDepartamentos.length}');
      await Future.wait(dbOperationsDepartamentos);
      _dataLoadProgressController.add(0.60);
      print('✅departamentos cargados');

      // Process cities
      for (var item in responses[3].data) {
        final tempCiudad = Ciudades.fromMap(item);
        dbOperationsCiudades.add(DBProvider.db.nuevaCiudad(tempCiudad));
      }

      // Process items - Limpiar tabla primero para evitar conflictos
      await DBProvider.db.clearItemsInspeccion();
      _dataLoadProgressController.add(0.65);
      print('✅ Items de inspección limpiados');

      for (var item in responses[4].data) {
        final tempItem = ItemInspeccion.fromMap(item);
        dbOperationsItems.add(DBProvider.db.nuevoItem(tempItem));
      }

      print('dbOperationsItems: ${dbOperationsItems.length}');
      await Future.wait(dbOperationsItems);
      _dataLoadProgressController.add(0.80);
      print('✅items cargados');

      // Verificar que los items se guardaron correctamente
      final itemsStats = await DBProvider.db.verifyItemsSaved(baseEmpresa!);
      print('📊 Estadísticas de items: $itemsStats');

      // Process document types
      for (var item in responses[5].data) {
        final tempTipoDoc = TipoDocumentos.fromMap(item);
        dbOperationsTipoDocumentos
            .add(DBProvider.db.nuevoTipoDocumento(tempTipoDoc));
      }

      _dataLoadProgressController.add(1.0);
      print('✅ Carga de datos completada');

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

  /// Envía la inspección de forma tradicional (foreground)
  Future<Map<String, dynamic>> sendInspeccion(
      ResumenPreoperacional inspeccion, Empresa selectedEmpresa,
      {bool showProgressNotifications = false}) async {
    try {
      // Asegurar que el token esté configurado antes de cualquier operación
      await loginService.setTokenFromStorage();
      print('[SEND INSPECCION] Token configurado');

      final connectivityResult = await checkConnection();
      if (connectivityResult) {
        // Declarar respuestas primero
        List<Item> respuestas = [];

        // Variables para progreso (se calcularán después de cargar respuestas)
        int totalElements = 0;
        int currentElement = 0;

        if (showProgressNotifications) {
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Iniciando subida...',
            progress: 0,
            total: totalElements > 0 ? totalElements : 1,
          );

          // Sincronizar batchProgress inicial
          batchProgress = 0.0;
          notifyListeners();
        }

        // Se envia la foto del kilometraje al servidor
        _logAppState('SUBIDA_IMAGEN_KM');
        Map<String, dynamic>? responseUploadKilometraje = await uploadImage(
            path: inspeccion.urlFotoKm!,
            company: '${selectedEmpresa.nombreQi}',
            folder: 'inspecciones');
        inspeccion.urlFotoKm = responseUploadKilometraje?['path'];

        // Actualizar progreso
        if (showProgressNotifications) {
          currentElement++;
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Subiendo imagen del kilometraje...',
            progress: currentElement,
            total: totalElements > 0 ? totalElements : 1,
          );
          batchProgress = totalElements > 0
              ? (currentElement / totalElements).clamp(0.0, 1.0)
              : 0.0;
          notifyListeners();
        }

        // Se envia la foto de la guia si tiene (basado en existencia de la foto)
        if (inspeccion.urlFotoGuia != null) {
          Map<String, dynamic>? responseUploadGuia = await uploadImage(
              path: inspeccion.urlFotoGuia!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');

          inspeccion.urlFotoGuia = responseUploadGuia?['path'];

          // Actualizar progreso
          if (showProgressNotifications) {
            currentElement++;
            await NotificationService.showUploadProgressNotification(
              title: 'Subiendo Inspección',
              body: 'Subiendo imagen de la guía...',
              progress: currentElement,
              total: totalElements,
            );
            batchProgress = totalElements > 0
                ? (currentElement / totalElements).clamp(0.0, 1.0)
                : 0.0;
            notifyListeners();
          }
        }

        // Se envia la foto del cabezote si tiene
        if (inspeccion.urlFotoCabezote != null) {
          Map<String, dynamic>? responseUploaCabezote = await uploadImage(
              path: inspeccion.urlFotoCabezote!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoCabezote = responseUploaCabezote?['path'];

          // Actualizar progreso
          if (showProgressNotifications) {
            currentElement++;
            await NotificationService.showUploadProgressNotification(
              title: 'Subiendo Inspección',
              body: 'Subiendo imagen del cabezote...',
              progress: currentElement,
              total: totalElements,
            );
            batchProgress = totalElements > 0
                ? (currentElement / totalElements).clamp(0.0, 1.0)
                : 0.0;
            notifyListeners();
          }
        }

        // Se envia la foto del remolque si tiene
        if (inspeccion.urlFotoRemolque != null) {
          Map<String, dynamic>? responseUploaRemolque = await uploadImage(
              path: inspeccion.urlFotoRemolque!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoRemolque = responseUploaRemolque?['path'];

          // Actualizar progreso
          if (showProgressNotifications) {
            currentElement++;
            await NotificationService.showUploadProgressNotification(
              title: 'Subiendo Inspección',
              body: 'Subiendo imagen del remolque...',
              progress: currentElement,
              total: totalElements,
            );
            batchProgress = totalElements > 0
                ? (currentElement / totalElements).clamp(0.0, 1.0)
                : 0.0;
            notifyListeners();
          }
        }

        // Guardamos el resumen del preoperacional en el server
        if (showProgressNotifications) {
          currentElement++;
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Guardando resumen...',
            progress: currentElement,
            total: totalElements > 0 ? totalElements : 1,
          );
          batchProgress = totalElements > 0
              ? (currentElement / totalElements).clamp(0.0, 1.0)
              : 0.0;
          notifyListeners();
        }

        // Configurar el token antes de enviar
        await loginService.setTokenFromStorage();

        // Obtener headers del dio de loginService que tiene el token configurado
        final headers =
            Map<String, dynamic>.from(loginService.dio.options.headers);

        final responseResumen =
            await dio.post('${loginService.baseUrl}/insert_preoperacional',
                options: Options(
                  headers: headers,
                  sendTimeout: Duration(seconds: 60),
                  receiveTimeout: Duration(seconds: 60),
                ),
                data: inspeccion.toJson());
        final resumen = Respuesta.fromMap(responseResumen.data);

        if (inspeccion.respuestas != null &&
            inspeccion.respuestas!.isNotEmpty) {
          List tempData = jsonDecode(inspeccion.respuestas!) as List;

          // Crear un Set para evitar duplicados por ID de item
          final Set<String> processedItemIds = {};

          tempData.forEach((element) {
            final data = ItemsVehiculo.fromMap(element);
            // Filtramos los items que tienen respuesta
            final tempRespuestas =
                data.items.where((item) => item.respuesta != null).toList();

            tempRespuestas.forEach((item) {
              // Evitar duplicados verificando el ID del item
              if (!processedItemIds.contains(item.idItem)) {
                item.fkPreoperacional = resumen.idInspeccion;
                item.base = selectedEmpresa.nombreBase;
                respuestas.add(item);
                processedItemIds.add(item.idItem);
              }
            });
          });

          print(
              '[SEND INSPECCION] ✅ Respuestas procesadas: ${respuestas.length} (duplicados evitados)');
        }

        // Calcular elementos totales para progreso real (después de cargar respuestas)
        // Contar imágenes del resumen
        if (inspeccion.urlFotoKm != null && inspeccion.urlFotoKm!.isNotEmpty)
          totalElements++;
        if (inspeccion.urlFotoCabezote != null &&
            inspeccion.urlFotoCabezote!.isNotEmpty) totalElements++;
        if (inspeccion.urlFotoRemolque != null &&
            inspeccion.urlFotoRemolque!.isNotEmpty) totalElements++;
        if (inspeccion.urlFotoGuia != null &&
            inspeccion.urlFotoGuia!.isNotEmpty) totalElements++;

        // Contar respuestas (ahora ya están cargadas)
        totalElements += respuestas.length;

        // Agregar 1 para el resumen final
        totalElements += 1;

        // Validar que totalElements sea válido
        if (totalElements <= 0) {
          totalElements = 1;
        }

        // Preparar el array de respuestas para el nuevo endpoint
        List<Map<String, dynamic>> respuestasArray = [];

        for (int i = 0; i < respuestas.length; i++) {
          final element = respuestas[i];
          element.fkPreoperacional = resumen.idInspeccion;

          final hasAdjunto =
              element.adjunto != null && element.adjunto!.isNotEmpty;
          // Actualizar progreso
          if (showProgressNotifications) {
            currentElement++;
            await NotificationService.showUploadProgressNotification(
              title: 'Subiendo Inspección',
              body: 'Preparando respuesta ${i + 1}/${respuestas.length}',
              progress: currentElement,
              total: totalElements,
            );

            batchProgress = totalElements > 0
                ? (currentElement / totalElements).clamp(0.0, 1.0)
                : 0.0;
            notifyListeners();
          }

          _logAppState('PREPARANDO_RESPUESTA_${i + 1}');

          // Subir imagen adjunta si existe
          if (hasAdjunto) {
            try {
              final responseUpload = await uploadImage(
                  path: element.adjunto!,
                  company: selectedEmpresa.nombreQi!,
                  folder: 'inspecciones');

              if (responseUpload != null) {
                element.adjunto = responseUpload['path'];
              } else {
                element.adjunto = null;
              }
            } catch (e) {
              element.adjunto = null; // Continuar sin adjunto
            }
          }

          // Agregar respuesta al array
          respuestasArray.add(jsonDecode(element.toJson()));
        }

        // Enviar todas las respuestas en una sola petición
        if (showProgressNotifications) {
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Enviando respuestas al servidor...',
            progress: currentElement,
            total: totalElements,
          );
        }

        // Asegurar que el token esté actualizado
        await loginService.setTokenFromStorage();
        final respuestasHeaders =
            Map<String, dynamic>.from(loginService.dio.options.headers);

        await dio
            .post('${loginService.baseUrl}/insert_respuestas_preoperacional',
                options: Options(
                  headers: respuestasHeaders,
                  sendTimeout: Duration(seconds: 60),
                  receiveTimeout: Duration(seconds: 60),
                ),
                data: {
              'respuestas': respuestasArray,
              'base': selectedEmpresa.nombreBase,
            });

        // Actualizar progreso final
        if (showProgressNotifications) {
          currentElement = totalElements;
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Respuestas guardadas exitosamente',
            progress: currentElement,
            total: totalElements,
          );
          batchProgress = 1.0;
          notifyListeners();
        }

        // Cancelar notificación de progreso al completar
        await NotificationService.cancelProgressNotification();

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
      // Cancelar notificación de progreso en caso de error
      await NotificationService.cancelProgressNotification();
      isSaving = false;
    }
  }

  /// Envía la inspección en segundo plano con notificaciones
  Future<Map<String, dynamic>> sendInspeccionBackground(
      ResumenPreoperacional inspeccion, Empresa selectedEmpresa) async {
    try {
      final connectivityResult = await checkConnection();
      if (!connectivityResult) {
        return {
          "message": 'Sin conexión a internet',
          "ok": false,
          "idInspeccion": 0
        };
      }
      // Verificar permisos de notificación
      final hasPermissions = await NotificationService.requestPermissions();
      if (!hasPermissions) {
        showSimpleNotification(
          Text(
              'Se requieren permisos de notificación para la subida en segundo plano'),
          leading: Icon(Icons.notifications_off),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom,
        );
        return {
          "message": 'Permisos de notificación requeridos',
          "ok": false,
          "idInspeccion": 0
        };
      }
      // Configurar el token antes de cualquier operación
      await loginService.setTokenFromStorage();
      print('[SEND INSPECCION BACKGROUND] Token configurado');

      // Obtener token de autenticación usando la clave correcta
      String nombreBase = await storage.read(key: 'nombreBase') ?? '';
      String tokenKey = nombreBase.isNotEmpty ? 'token_$nombreBase' : 'token';
      String token = await storage.read(key: tokenKey) ?? '';
      print('[SEND INSPECCION BACKGROUND] Token key usada: $tokenKey');

      if (token.isEmpty) {
        print(
            '[SEND INSPECCION BACKGROUND] ⚠️ Token no encontrado con clave: $tokenKey');
        return {
          "message": 'Token de autenticación no encontrado',
          "ok": false,
          "idInspeccion": 0
        };
      }
      print('[SEND INSPECCION BACKGROUND] ✅ Token encontrado');

      // Programar tarea en segundo plano
      await BackgroundUploadService.scheduleUploadTask(
        inspeccion: inspeccion,
        empresa: selectedEmpresa,
        token: token,
        inspeccionService: this,
      );

      // Mostrar notificación inicial
      await NotificationService.showUploadProgressNotification(
        title: 'Subiendo Inspección',
        body: 'La subida comenzará en segundo plano...',
        progress: 0,
        total: 100,
      );

      // Mostrar notificación en la app - COMENTADA para evitar duplicación
      // print('📱 DEBUG: Mostrando notificación en la app...');
      // showSimpleNotification(
      //   Text('Subida iniciada en segundo plano. Puedes salir de la app.'),
      //   leading: Icon(Icons.cloud_upload),
      //   autoDismiss: true,
      //   background: Colors.blue,
      //   position: NotificationPosition.bottom,
      // );
      // print('✅ DEBUG: Notificación en la app mostrada');

      // Cancelar notificación de progreso al completar
      await NotificationService.cancelProgressNotification();

      isSaving = false;
      notifyListeners();

      return {
        "message": 'Subida iniciada en segundo plano',
        "ok": true,
        "idInspeccion": inspeccion.id ?? 0,
        "background": true,
      };
    } catch (e) {
      showSimpleNotification(
        Text('Error iniciando subida en segundo plano'),
        leading: Icon(Icons.error),
        autoDismiss: true,
        background: Colors.red,
        position: NotificationPosition.bottom,
      );

      // Cancelar notificación de progreso en caso de error
      await NotificationService.cancelProgressNotification();
      isSaving = false;
      notifyListeners();

      return {
        "message": 'Error iniciando subida en segundo plano: $e',
        "ok": false,
        "idInspeccion": 0
      };
    }
  }

  /// Cancela la subida en segundo plano
  Future<void> cancelBackgroundUpload() async {
    await BackgroundUploadService.cancelUploadTask();
    showSimpleNotification(
      Text('Subida en segundo plano cancelada'),
      leading: Icon(Icons.cancel),
      autoDismiss: true,
      background: Colors.orange,
      position: NotificationPosition.bottom,
    );
  }

  /// Verifica si hay una subida en progreso
  Future<bool> isBackgroundUploadInProgress() async {
    return await BackgroundUploadService.isUploadInProgress();
  }

  Future<Pdf> detatilPdf(
      Empresa empresaSelected, ResumenPreoperacionalServer inspeccion,
      {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        // Check connectivity first
        bool hasConnection = await checkConnection();
        if (!hasConnection) {
          throw Exception('Sin conexión a internet');
        }

        Response response = await dio
            .get(
                '${loginService.baseUrl}/inspeccion/${empresaSelected.nombreBase}/${inspeccion.resuPreId}',
                options: loginService.options)
            .timeout(Duration(seconds: 60)); // Aumentado para segundo plano

        Pdf temData = Pdf.fromJson(response.toString());

        // Helper function to validate and process image
        Future<Map<String, dynamic>> processImage(String imageUrl) async {
          try {
            // Check if it's a valid URL
            if (imageUrl.startsWith('http://') ||
                imageUrl.startsWith('https://')) {
              // Try to download the image
              var response =
                  await get(Uri.parse(imageUrl)).timeout(Duration(seconds: 8));
              return {"foto": imageUrl, "data": response, "type": "url"};
            } else if (imageUrl.startsWith('data:image/') ||
                imageUrl.contains('base64')) {
              // It's a base64 image
              return {
                "foto": imageUrl,
                "data": null,
                "type": "base64",
                "message": "Ver en web"
              };
            } else {
              // Invalid or unsupported format
              return {
                "foto": imageUrl,
                "data": null,
                "type": "invalid",
                "message": "No-uri"
              };
            }
          } catch (error) {
            return {
              "foto": imageUrl,
              "data": null,
              "type": "error",
              "message": "No-uri"
            };
          }
        }

        // Collect all image URLs that need to be processed
        List<String> imageUrls = [];
        temData.detalle.forEach((categoria) {
          categoria.respuestas.forEach((respuesta) {
            if (respuesta.foto != null && respuesta.foto!.isNotEmpty) {
              imageUrls.add(respuesta.foto!);
            }
          });
        });

        // Process images with validation
        List<Future> promesas = [];
        Map<String, dynamic> imageResults = {};

        for (String imageUrl in imageUrls) {
          promesas.add(processImage(imageUrl).then((result) {
            if (result["type"] == "url" && result["data"] != null) {
              imageResults[imageUrl] = result["data"].bodyBytes;
            } else {
              imageResults[imageUrl] = null;
              // Store the message for display
              imageResults['${imageUrl}_message'] = result["message"];
            }
            return result;
          }));
        }

        // Wait for all image processing with overall timeout
        if (promesas.isNotEmpty) {
          try {
            await Future.wait(promesas).timeout(Duration(seconds: 25));
          } catch (error) {
            // Continue with partial data
          }
        }

        // Assign processed images to responses
        int successfulDownloads = 0;
        int base64Images = 0;
        int invalidImages = 0;

        temData.detalle.forEach((categoria) {
          categoria.respuestas.forEach((respuesta) {
            if (respuesta.foto != null && respuesta.foto!.isNotEmpty) {
              if (imageResults.containsKey(respuesta.foto!) &&
                  imageResults[respuesta.foto!] != null) {
                respuesta.fotoConverted = imageResults[respuesta.foto!];
                respuesta.imageMessage = null; // Clear any previous message
                successfulDownloads++;
              } else {
                // Check if there's a message for this image
                String? message = imageResults['${respuesta.foto}_message'];
                if (message != null) {
                  respuesta.imageMessage = message;
                  respuesta.fotoConverted = null; // Clear the image data
                  if (message == "Ver en web") {
                    base64Images++;
                  } else if (message == "No-uri") {
                    invalidImages++;
                  }
                }
              }
            }
          });
        });

        // Log image processing statistics
        print(
            '📊 Image processing stats: $successfulDownloads successful, $base64Images base64, $invalidImages invalid');

        return temData;
      } catch (e) {
        if (attempt == maxRetries) {
          throw Exception(
              'Error al obtener datos del PDF después de $maxRetries intentos: $e');
        } else {
          // Wait before retrying with exponential backoff
          int waitTime = 2 * attempt;
          await Future.delayed(Duration(seconds: waitTime));
        }
      }
    }
    throw Exception(
        'Error al obtener datos del PDF después de $maxRetries intentos');
  }

  @override
  void dispose() {
    _dataLoadProgressController.close();
    super.dispose();
  }
}
