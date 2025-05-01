import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:olaf/camera/lambda.dart';
import 'package:olaf/classes.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  bool responseReceived = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          return Stack(
            children: [
              CameraPreview(_controller),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: mediaQuery.width * 1,
                    height: mediaQuery.height * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: mediaQuery.height * 0.73,
                left: mediaQuery.width * 0.44,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: theme.colorScheme.secondary,
                  ),
                  child: IconButton(
                    onPressed: () async {
                
                      try {
                        // Take the picture and encode it in base64
                        await _initializeControllerFuture;
                        final image = await _controller.takePicture();
                        final toBytes = await File(image.path).readAsBytes();
                        final toBase64 = base64Encode(toBytes);
                        // Get the user ID
                        final user = await Amplify.Auth.getCurrentUser();
                        List<int> payload =
                            '{"image": "$toBase64", "userId": "${user.userId}"}'
                                .codeUnits;

                        final date = DateTime.now().toString();
                        cacheData.getInstance().addImages(analyzedImages(
                            name: date, image: toBase64, result: "loading"));
                        invoke(payload);
                        Navigator.pop(context);
                        
                      } catch (e) {
                        throw(e);
                      }
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
