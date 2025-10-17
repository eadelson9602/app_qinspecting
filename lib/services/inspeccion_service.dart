import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

import 'package:app_qinspecting/models/models.dart';
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
    print('📱 DEBUG: [$operation] Estado de la app: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        print('🟢 DEBUG: [$operation] APP EN PRIMER PLANO');
        break;
      case AppLifecycleState.paused:
        print('🟡 DEBUG: [$operation] APP EN SEGUNDO PLANO');
        break;
      case AppLifecycleState.inactive:
        print('🟠 DEBUG: [$operation] APP INACTIVA');
        break;
      case AppLifecycleState.detached:
        print('🔴 DEBUG: [$operation] APP DESCONECTADA');
        break;
      case AppLifecycleState.hidden:
        print('⚫ DEBUG: [$operation] APP OCULTA');
        break;
      case null:
        print('❓ DEBUG: [$operation] Estado de app desconocido');
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
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) return false;
      if (!(connectivity == ConnectivityResult.wifi ||
          connectivity == ConnectivityResult.mobile)) return false;

      // Si es Wi‑Fi, considerar estable inmediatamente (evita falsos negativos por endpoints no disponibles)
      if (connectivity == ConnectivityResult.wifi) {
        print('[conn] WIFI detected => stable=true');
        return true;
      }

      // Probar múltiples endpoints del backend (algunos proyectos no exponen /health)
      final candidates = <String>[
        '${loginService.baseUrl}/health',
        '${loginService.baseUrl}/',
        '${loginService.baseUrl}/status',
        '${loginService.baseUrl}/ping',
      ];

      int ok = 0;
      for (final url in candidates) {
        try {
          final uri = Uri.parse(url);
          // Usar GET ligero: algunos backends no aceptan HEAD
          final res = await dio
              .getUri(uri, options: Options(method: 'GET'))
              .timeout(timeout);
          print('[conn] GET ${uri.path} -> ${res.statusCode}');
          if (res.statusCode != null && res.statusCode! < 500) ok++;
        } catch (e) {
          print('[conn] GET error $url: $e');
          // Ignorar y seguir probando otros endpoints
        }
        if (ok >= 2) break; // suficientemente estable
      }
      // Consideramos estable si al menos 2 endpoints respondieron o si 1 respondió y es WiFi
      if (ok >= 2) return true;
      if (ok >= 1 && connectivity == ConnectivityResult.wifi) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> getLatesInspections(Empresa selectedEmpresa,
      {int maxRetries = 3}) async {
    final connectivityResult = await checkConnection();

    if (connectivityResult) {
      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print(
              'Attempting to get latest inspections (attempt $attempt/$maxRetries)');
          print(
              'URL: ${loginService.baseUrl}/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.numeroDocumento}');

          // Buscamos en el storage el token y lo asignamos a la instancia para poderlo usar en todas las peticiones de este servicio
          String token = await storage.read(key: 'token') ?? '';
          loginService.options.headers = {"x-access-token": token};

          print('Starting API call with 30s timeout...');
          Response response = await dio.get(
              '${loginService.baseUrl}/get_latest_inspections/${selectedEmpresa.nombreBase}/${selectedEmpresa.numeroDocumento}',
              options: loginService.options,
              queryParameters: {'timeout': 30});

          print(
              'API call completed successfully. Status: ${response.statusCode}');
          print('Response data length: ${response.data?.length ?? 0}');

          List<ResumenPreoperacionalServer> tempData = [];
          if (response.data != null && response.data is List) {
            for (var item in response.data) {
              tempData.add(ResumenPreoperacionalServer.fromMap(item));
            }
          }

          listInspections = [...tempData];
          print('✅ Successfully obtained latest inspections');
          return true;
        } on DioException catch (error) {
          print('Error in attempt $attempt: ${error.message}');
          print('Error type: ${error.type}');
          print('Error response: ${error.response?.data}');

          // Si es un error de timeout o conexión, continuar con el siguiente intento
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionError) {
            if (attempt == maxRetries) {
              print(
                  '⚠️ Returning false due to connection issues after $maxRetries attempts');
              return false; // Retornar false en lugar de lanzar excepción
            } else {
              print('⏳ Waiting before retry...');
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
          print('Unexpected error in attempt $attempt: $e');
          if (attempt == maxRetries) {
            print(
                '⚠️ Returning false due to unexpected error after $maxRetries attempts');
            return false; // Retornar false en lugar de lanzar excepción
          } else {
            await Future.delayed(Duration(seconds: 2 * attempt));
          }
        }
      }
      print('⚠️ Returning false after $maxRetries attempts');
      return false; // Retornar false en lugar de lanzar excepción
    } else {
      print('⚠️ No internet connection, returning false');
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
      print('📤 DEBUG: Iniciando subida de imagen: $path');
      _logAppState('UPLOAD_IMAGE');
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
      print('✅ DEBUG: Imagen subida exitosamente: ${resp.path}');
      return resp.toMap();
    } on DioException catch (error) {
      print('❌ ERROR: Error en uploadImage: ${error.message}');
      if (error.response != null) {
        print('❌ ERROR: Response data: ${error.response!.data}');
      } else {
        print('❌ ERROR: No response data available');
      }
      showSimpleNotification(Text('No se ha podido subir la foto al servidor'),
          leading: Icon(Icons.check),
          autoDismiss: true,
          background: Colors.orange,
          position: NotificationPosition.bottom);
      return Future.error(error.response?.data ?? error.message);
    } catch (e) {
      print('❌ ERROR: Error inesperado en uploadImage: $e');
      return Future.error(e);
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

      print('✅vehiculos cargados');

      // // Process trailers
      for (var item in responses[1].data) {
        final tempRemolque = Remolque.fromMap(item);
        dbOperationsRemolques.add(DBProvider.db.nuevoRemolque(tempRemolque));
      }

      print('dbOperationsRemolques: ${dbOperationsRemolques.length}');
      await Future.wait(dbOperationsRemolques);
      print('✅remolques cargados');

      // Process departments
      for (var item in responses[2].data) {
        final tempDepartamento = Departamentos.fromMap(item);
        dbOperationsDepartamentos
            .add(DBProvider.db.nuevoDepartamento(tempDepartamento));
      }

      print('dbOperationsDepartamentos: ${dbOperationsDepartamentos.length}');
      await Future.wait(dbOperationsDepartamentos);
      print('✅departamentos cargados');

      // Process cities
      for (var item in responses[3].data) {
        final tempCiudad = Ciudades.fromMap(item);
        dbOperationsCiudades.add(DBProvider.db.nuevaCiudad(tempCiudad));
      }

      // Process items
      for (var item in responses[4].data) {
        final tempItem = ItemInspeccion.fromMap(item);
        dbOperationsItems.add(DBProvider.db.nuevoItem(tempItem));
      }

      // Process document types
      for (var item in responses[5].data) {
        final tempTipoDoc = TipoDocumentos.fromMap(item);
        dbOperationsTipoDocumentos
            .add(DBProvider.db.nuevoTipoDocumento(tempTipoDoc));
      }

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
      final connectivityResult = await checkConnection();
      if (connectivityResult) {
        if (showProgressNotifications) {
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Subiendo imágenes...',
            progress: 0,
            total: 100,
          );
        }

        // Se envia la foto del kilometraje al servidor
        _logAppState('SUBIDA_IMAGEN_KM');
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
        if (inspeccion.urlFotoCabezote?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploaCabezote = await uploadImage(
              path: inspeccion.urlFotoCabezote!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoCabezote = responseUploaCabezote?['path'];
        }

        // Se envia la foto del remolque si tiene
        if (inspeccion.urlFotoRemolque?.isNotEmpty ?? false) {
          Map<String, dynamic>? responseUploaRemolque = await uploadImage(
              path: inspeccion.urlFotoRemolque!,
              company: selectedEmpresa.nombreQi!,
              folder: 'inspecciones');
          inspeccion.urlFotoRemolque = responseUploaRemolque?['path'];
        }

        // Guardamos el resumen del preoperacional en el server
        if (showProgressNotifications) {
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Guardando resumen...',
            progress: 30,
            total: 100,
          );
        }

        _logAppState('GUARDADO_RESUMEN');
        final responseResumen = await dio.post(
            '${loginService.baseUrl}/insert_preoperacional',
            options: loginService.options,
            data: inspeccion.toJson());
        final resumen = Respuesta.fromMap(responseResumen.data);

        // Obtenemos las respuestas desde el JSON almacenado en el objeto inspección
        List<Item> respuestas = [];

        if (inspeccion.respuestas != null &&
            inspeccion.respuestas!.isNotEmpty) {
          print(
              '🔍 DEBUG: Obteniendo respuestas desde JSON del objeto inspección');
          List tempData = jsonDecode(inspeccion.respuestas!) as List;

          tempData.forEach((element) {
            final data = ItemsVehiculo.fromMap(element);
            // Filtramos los items que tienen respuesta
            final tempRespuestas =
                data.items.where((item) => item.respuesta != null).toList();
            // Agregamos todas las respuestas a la lista
            respuestas.addAll(tempRespuestas);
          });

          print(
              '🔍 DEBUG: Respuestas obtenidas desde JSON: ${respuestas.length}');
        } else {
          print(
              '⚠️ WARNING: No hay respuestas en el JSON del objeto inspección');

          // Fallback: intentar desde SQLite
          List<Item> respuestasSQLite =
              await inspeccionProvider.cargarTodasRespuestas(inspeccion.id!);
          print(
              '🔍 DEBUG: Respuestas desde SQLite (fallback): ${respuestasSQLite.length}');
          respuestas = respuestasSQLite;
        }

        // Subida secuencial con reintentos para mayor estabilidad
        print(
            '🔍 DEBUG: Iniciando subida secuencial de ${respuestas.length} respuestas');

        if (showProgressNotifications) {
          await NotificationService.showUploadProgressNotification(
            title: 'Subiendo Inspección',
            body: 'Procesando respuestas...',
            progress: 60,
            total: 100,
          );
        }

        int exitosos = 0;
        int fallidos = 0;

        for (int i = 0; i < respuestas.length; i++) {
          final element = respuestas[i];
          element.fkPreoperacional = resumen.idInspeccion;
          element.base = selectedEmpresa.nombreBase;

          final hasAdjunto =
              element.adjunto != null && element.adjunto!.isNotEmpty;
          print(
              '🔍 DEBUG: Procesando respuesta ${i + 1}/${respuestas.length} - ID: ${element.idItem}, Adjunto: ${hasAdjunto ? "SÍ" : "NO"}');

          // Actualizar progreso
          if (showProgressNotifications) {
            final progress = 60 + ((i / respuestas.length) * 40).round();
            await NotificationService.showUploadProgressNotification(
              title: 'Subiendo Inspección',
              body: 'Procesando respuesta ${i + 1}/${respuestas.length}',
              progress: progress,
              total: 100,
            );
          }

          _logAppState('PROCESANDO_RESPUESTA_${i + 1}');

          bool procesadoExitosamente = false;
          int intentos = 0;
          const maxIntentos = 3;

          while (!procesadoExitosamente && intentos < maxIntentos) {
            intentos++;
            print(
                '🔄 DEBUG: Intento $intentos/$maxIntentos para respuesta ${element.idItem}');

            try {
              if (hasAdjunto) {
                print('📤 DEBUG: Subiendo imagen adjunta: ${element.adjunto}');
                final responseUpload = await uploadImage(
                    path: element.adjunto!,
                    company: selectedEmpresa.nombreQi!,
                    folder: 'inspecciones');

                if (responseUpload != null) {
                  element.adjunto = responseUpload['path'];
                  print('✅ DEBUG: Imagen subida exitosamente');
                } else {
                  print('⚠️ WARNING: Imagen no se subió, enviando sin adjunto');
                  element.adjunto = null;
                }
              }

              print('📤 DEBUG: Enviando respuesta al servidor');
              print('🔍 DEBUG: Datos a enviar: ${element.toJson()}');

              await dio.post(
                  '${loginService.baseUrl}/insert_respuestas_preoperacional',
                  options: loginService.options,
                  data: element.toJson());

              print(
                  '✅ DEBUG: Respuesta ${element.idItem} enviada exitosamente');
              procesadoExitosamente = true;
              exitosos++;
            } catch (e) {
              print(
                  '❌ ERROR: Error en intento $intentos para respuesta ${element.idItem}: $e');

              if (intentos < maxIntentos) {
                print('⏳ DEBUG: Esperando antes del siguiente intento...');
                await Future.delayed(Duration(
                    seconds:
                        5 * intentos)); // Backoff más largo para segundo plano
              } else {
                print(
                    '❌ ERROR: Respuesta ${element.idItem} falló después de $maxIntentos intentos');
                fallidos++;
              }
            }
          }

          // Actualizar progreso
          batchProgress = (i + 1) / respuestas.length;
          currentBatchIndex = i + 1;
          totalBatches = respuestas.length;
          notifyListeners();

          print(
              '📊 DEBUG: Progreso: ${(batchProgress * 100).toStringAsFixed(1)}% (${i + 1}/${respuestas.length})');

          // Delay entre respuestas para no sobrecargar el servidor
          if (i < respuestas.length - 1) {
            await Future.delayed(
                Duration(milliseconds: 1000)); // 1 segundo entre respuestas
          }
        }

        print(
            '🎉 DEBUG: Subida secuencial completada - Exitosos: $exitosos, Fallidos: $fallidos');

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

  /// Envía la inspección en segundo plano con notificaciones
  Future<Map<String, dynamic>> sendInspeccionBackground(
      ResumenPreoperacional inspeccion, Empresa selectedEmpresa) async {
    print('🚀 DEBUG: Iniciando sendInspeccionBackground');
    print('📋 DEBUG: Inspección ID: ${inspeccion.id}');
    print('🏢 DEBUG: Empresa: ${selectedEmpresa.nombreQi}');

    try {
      print('🌐 DEBUG: Verificando conectividad...');
      final connectivityResult = await checkConnection();
      if (!connectivityResult) {
        print('❌ DEBUG: Sin conexión a internet');
        return {
          "message": 'Sin conexión a internet',
          "ok": false,
          "idInspeccion": 0
        };
      }
      print('✅ DEBUG: Conectividad verificada');

      // Verificar permisos de notificación
      print('🔔 DEBUG: Verificando permisos de notificación...');
      final hasPermissions = await NotificationService.requestPermissions();
      if (!hasPermissions) {
        print('❌ DEBUG: Permisos de notificación denegados');
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
      print('✅ DEBUG: Permisos de notificación verificados');

      // Obtener token de autenticación
      print('🔑 DEBUG: Obteniendo token de autenticación...');
      String token = await storage.read(key: 'token') ?? '';
      if (token.isEmpty) {
        print('❌ DEBUG: Token de autenticación no encontrado');
        return {
          "message": 'Token de autenticación no encontrado',
          "ok": false,
          "idInspeccion": 0
        };
      }
      print('✅ DEBUG: Token obtenido: ${token.substring(0, 10)}...');

      // Programar tarea en segundo plano
      print('📅 DEBUG: Programando tarea en segundo plano...');
      await BackgroundUploadService.scheduleUploadTask(
        inspeccion: inspeccion,
        empresa: selectedEmpresa,
        token: token,
        inspeccionService: this,
      );
      print('✅ DEBUG: Tarea programada exitosamente');

      // Mostrar notificación inicial
      print('📱 DEBUG: Mostrando notificación inicial...');
      await NotificationService.showUploadProgressNotification(
        title: 'Subiendo Inspección',
        body: 'La subida comenzará en segundo plano...',
        progress: 0,
        total: 100,
      );
      print('✅ DEBUG: Notificación inicial mostrada');

      // Mostrar notificación en la app
      print('📱 DEBUG: Mostrando notificación en la app...');
      showSimpleNotification(
        Text('Subida iniciada en segundo plano. Puedes salir de la app.'),
        leading: Icon(Icons.cloud_upload),
        autoDismiss: true,
        background: Colors.blue,
        position: NotificationPosition.bottom,
      );
      print('✅ DEBUG: Notificación en la app mostrada');

      isSaving = false;
      notifyListeners();

      print('🎉 DEBUG: sendInspeccionBackground completado exitosamente');
      return {
        "message": 'Subida iniciada en segundo plano',
        "ok": true,
        "idInspeccion": inspeccion.id ?? 0,
        "background": true,
      };
    } catch (e) {
      print('❌ ERROR: Error iniciando subida en segundo plano: $e');
      showSimpleNotification(
        Text('Error iniciando subida en segundo plano'),
        leading: Icon(Icons.error),
        autoDismiss: true,
        background: Colors.red,
        position: NotificationPosition.bottom,
      );

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
        print(
            'Starting detatilPdf for inspection: ${inspeccion.resuPreId} (attempt $attempt/$maxRetries)');

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
            .timeout(Duration(seconds: 60)); // Aumentado para segundo plano

        print('API call completed successfully');
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
              print('Successfully downloaded: $imageUrl');
              return {"foto": imageUrl, "data": response, "type": "url"};
            } else if (imageUrl.startsWith('data:image/') ||
                imageUrl.contains('base64')) {
              // It's a base64 image
              print('Base64 image detected: $imageUrl');
              return {
                "foto": imageUrl,
                "data": null,
                "type": "base64",
                "message": "Ver en web"
              };
            } else {
              // Invalid or unsupported format
              print('Invalid image format: $imageUrl');
              return {
                "foto": imageUrl,
                "data": null,
                "type": "invalid",
                "message": "No-uri"
              };
            }
          } catch (error) {
            print('Error processing image $imageUrl: $error');
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

        print('Found ${imageUrls.length} images to process');

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
          print('Starting concurrent image processing...');
          try {
            await Future.wait(promesas).timeout(Duration(seconds: 25));
            print('Image processing completed');
          } catch (error) {
            print('Error during image processing: $error');
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

        print(
            'Successfully processed $successfulDownloads URLs, $base64Images base64 images, $invalidImages invalid images out of ${imageUrls.length} total images');
        return temData;
      } catch (e) {
        print('Error in detatilPdf attempt $attempt: $e');
        if (attempt == maxRetries) {
          throw Exception(
              'Error al obtener datos del PDF después de $maxRetries intentos: $e');
        } else {
          // Wait before retrying with exponential backoff
          int waitTime = 2 * attempt;
          print('Retrying in $waitTime seconds...');
          await Future.delayed(Duration(seconds: waitTime));
        }
      }
    }
    throw Exception(
        'Error al obtener datos del PDF después de $maxRetries intentos');
  }
}
