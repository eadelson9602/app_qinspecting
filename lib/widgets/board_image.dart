import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class BoardImage extends StatefulWidget {
  const BoardImage({Key? key, this.url, this.onImageCaptured})
      : super(key: key);
  final String? url;
  final ValueChanged<String>? onImageCaptured;

  @override
  State<BoardImage> createState() => _BoardImageState();
}

class _BoardImageState extends State<BoardImage> {
  String? _currentUrl;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;
  }

  @override
  void didUpdateWidget(covariant BoardImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _currentUrl = widget.url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: _buildBoxDecoration(),
          height: 250,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(15)),
            child: _buildImage(context),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: FloatingActionButton(
            heroTag: null,
            mini: true,
            onPressed: _openInlineCamera,
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    final picture = _currentUrl;
    if (picture == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              SizedBox(height: 8),
              Text(
                'No hay imagen',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Image.file(
      File(picture),
      fit: BoxFit.cover,
      cacheWidth: 640,
      cacheHeight: 640,
    );
  }

  BoxDecoration _buildBoxDecoration() => BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(13, 0, 0, 0),
                blurRadius: 2,
                offset: Offset(0, 5))
          ]);

  Future<void> _openInlineCamera() async {
    try {
      // Permisos
      var cam = await Permission.camera.status;
      if (!cam.isGranted) {
        cam = await Permission.camera.request();
        if (!cam.isGranted) return;
      }

      final String? result = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.black,
        builder: (ctx) => const _InlineCameraSheet(),
      );

      if (result != null && result.isNotEmpty && mounted) {
        setState(() => _currentUrl = result);
        widget.onImageCaptured?.call(result);
      }
    } catch (e) {
      // Silenciar, UX sigue en formulario
    }
  }
}

class _InlineCameraSheet extends StatefulWidget {
  const _InlineCameraSheet({Key? key}) : super(key: key);

  @override
  State<_InlineCameraSheet> createState() => _InlineCameraSheetState();
}

class _InlineCameraSheetState extends State<_InlineCameraSheet> {
  CameraController? _controller;
  Future<void>? _initFuture;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      back,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _disposed = true;
    final ctrl = _controller;
    _controller = null;
    Future.microtask(() => ctrl?.dispose());
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      await _initFuture;
      final ctrl = _controller;
      if (ctrl == null || _disposed || !(ctrl.value.isInitialized)) return;
      final XFile x = await ctrl.takePicture();
      final docs = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${docs.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      final String ext = x.path.contains('.') ? x.path.split('.').last : 'jpg';
      final String fileName = const Uuid().v4();
      final String dstPath = '${imagesDir.path}/$fileName.$ext';
      final saved = await File(x.path).copy(dstPath);
      if (!mounted) return;
      Navigator.of(context).pop(saved.path);
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

// Modificar la altura de la pantalla para que ocupe toda la pantalla
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            if (_controller != null)
              FutureBuilder<void>(
                future: _initFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      _controller != null &&
                      !_disposed &&
                      _controller!.value.isInitialized) {
                    return CameraPreview(_controller!);
                  }
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                },
              )
            else
              const Center(
                  child: CircularProgressIndicator(color: Colors.white)),
            Positioned(
              left: 12,
              top: 12,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(18),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _capture,
                  child: const Icon(Icons.camera_alt, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
