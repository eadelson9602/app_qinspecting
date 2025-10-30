import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class EmbeddedCameraScreen extends StatefulWidget {
  const EmbeddedCameraScreen({Key? key}) : super(key: key);

  @override
  State<EmbeddedCameraScreen> createState() => _EmbeddedCameraScreenState();
}

class _EmbeddedCameraScreenState extends State<EmbeddedCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<CameraDescription> _cameras = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    try {
      // Pedir permiso de cámara (seguro)
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        final r = await Permission.camera.request();
        if (!r.isGranted) {
          if (mounted) Navigator.of(context).pop(null);
          return;
        }
      }

      _cameras = await availableCameras();
      final back = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        back,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _initializeControllerFuture = _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) Navigator.of(context).pop(null);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_controller == null) return;
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await _initializeControllerFuture;
      final XFile xfile = await _controller!.takePicture();

      // Persistir a Documents/images con nombre único
      final docs = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docs.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final String ext =
          xfile.path.contains('.') ? xfile.path.split('.').last : 'jpg';
      final String fileName = const Uuid().v4();
      final String dstPath = '${imagesDir.path}/$fileName.$ext';
      final saved = await File(xfile.path).copy(dstPath);

      if (mounted) Navigator.of(context).pop(saved.path);
    } catch (e) {
      if (mounted) Navigator.of(context).pop(null);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (_controller != null && _initializeControllerFuture != null)
              FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // Cubrir toda la pantalla respetando aspect ratio de la cámara
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final preview = CameraPreview(_controller!);
                        return FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: preview,
                          ),
                        );
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              left: 16,
              top: 16,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _isSaving ? null : _capture,
                    child: const Icon(Icons.camera_alt, size: 28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
