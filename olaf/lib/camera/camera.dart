import 'dart:convert';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:olaf/camera/lambda.dart';

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
  late List<String> response;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary);

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
          if (snapshot.connectionState == ConnectionState.done) {
            if (responseReceived) {
              // Show the dialog when responseReceived is true
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: theme.colorScheme.primary,
                      title: Text(
                        'Plant Status',
                        style: style.copyWith(fontSize: mediaQuery.width * 0.1),
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        "Your plant is a ${response[0]}\n and it's status is:${response[1]}",
                        style:
                            style.copyWith(fontSize: mediaQuery.width * 0.05),
                        textAlign: TextAlign.center,
                      ),
                      actions: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            responseReceived = false;
                          },
                          child: Text(
                            'OK',
                            style: style.copyWith(
                                fontSize: mediaQuery.width * 0.05),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                );
              });
            }
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "The image is currently being reviewed by an AI.\nIt might require up to a few minutes to be finished."),
                          duration: Duration(seconds: 5),
                          behavior: SnackBarBehavior
                              .floating, // Makes the SnackBar float over the content
                        ));
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
                          response = await invoke(payload);
                          setState(() {
                            responseReceived = true;
                          });
                        } catch (e) {
                          debugPrint("${e}");
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
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
