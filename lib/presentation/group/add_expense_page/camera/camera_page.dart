import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/photo/photo_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({Key? key}) : super(key: key);

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      debugPrint('Kamera izni durumu: $status');

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Kamera bulunamadı')));
          Navigator.pop(context);
        }
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Kamera başlatma hatası: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Hata'),
            content: const Text(
              'Kamera başlatılamadı. Kamera iznini kontrol edin.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  openAppSettings();
                },
                child: const Text('Ayarlar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('İptal'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    setState(() {
      _capturedImage = image;
    });
  }

  void _saveAndReturn() async {
    if (_capturedImage == null) return;

    final file = File(_capturedImage!.path);
    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final jwtToken = await secureStorage.read(key: 'jwt');
    if (jwtToken == null || jwtToken.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kullanıcı bulunamadı')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return;
    }
    context.read<PhotoCubit>().uploadPhoto(jwtToken: jwtToken, photo: file);
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildCameraUI(PhotoState state) {
    if (state.isUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_capturedImage == null) {
      return Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _takePicture,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Icon(Icons.photo_camera, size: 36),
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.file(File(_capturedImage!.path), fit: BoxFit.contain),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _capturedImage = null);
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Tekrar Çek"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _saveAndReturn,
                icon: const Icon(Icons.check),
                label: const Text("Kaydet"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhotoCubit, PhotoState>(
      listener: (context, state) {
        state.photoUploadFailOrSuccess.fold(
          () => null,
          (result) => result.fold(
            (failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Yükleme başarısız: ${failure.message}"),
                ),
              );
            },
            (url) {
              Navigator.pop(context, url);
            },
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Fiş Fotoğrafı Çek")),
        body: _isCameraReady
            ? BlocBuilder<PhotoCubit, PhotoState>(
                builder: (context, state) {
                  return _buildCameraUI(state);
                },
              )
            : _buildLoading(),
      ),
    );
  }
}
