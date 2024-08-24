//------------------- FLUTTER IMPORTS -------------------
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//-------------------- CUSTOM IMPORTS -------------------
import 'package:olaf/camera/analyze_page.dart';
import 'package:olaf/camera/camera.dart';
import 'package:olaf/camera/lambda.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/main.dart';

//-------------------- LIST STATE --------------------
class PictureList extends ConsumerStatefulWidget {
  const PictureList({super.key});

  @override
  _PictureListState createState() => _PictureListState();
}
class _PictureListState extends ConsumerState<PictureList> {
  void _onChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    cacheData.getInstance().addListener(_onChange);
  }

  @override
  void dispose() {
    cacheData.getInstance().removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.sizeOf(context);
    print(cacheData.getInstance().images.last.result);
    return Column(
      children: [
        Container(
          height: mediaQuery.height * 0.7,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(children: [
                DataTable(
                    horizontalMargin: 10,
                    dataTextStyle: TextStyle(),
                    border: TableBorder(
                      bottom: BorderSide(
                          width: mediaQuery.width * 0.001, color: Colors.grey),
                    ),
                    dataRowMaxHeight: mediaQuery.height * 0.1,
                    columns: [
                      DataColumn(
                          label: Text("Images", textAlign: TextAlign.center)),
                      DataColumn(
                          label: Text("Plants", textAlign: TextAlign.center)),
                    ],
                    rows: getRows(mediaQuery, ref)),
              ]),
            ),
          ),
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: theme.colorScheme.secondary,
          ),
          child: IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          CameraScreen(cameras: ref.read(CamerasProvider))));
            },
            icon: Icon(Icons.camera_alt_outlined),
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: mediaQuery.height * 0.02,
        )
      ],
    );
  }
}

/// Returns the list of the rows displayed in the *PictureList* widget
List<DataRow> getRows(Size mediaQuery, WidgetRef ref) {
  List<DataRow> rows = [];
  final images = cacheData.getInstance().images;
  if (images.length > 0) {
    for (var image in cacheData.getInstance().images) {
      int index = 0;
      if (image.result != "loading") {
        index = image.result.indexOf(" ");
      }
      rows.add(
        DataRow(
          cells: [
            DataCell(Padding(
              padding:
                  EdgeInsets.symmetric(vertical: mediaQuery.height * 0.005),
              child: Image(
                alignment: Alignment.centerLeft,
                width: mediaQuery.width * 0.3,
                image: MemoryImage(base64Decode(image.image)),
              ),
            )),
            DataCell(Row(
              children: [
                image.result != "loading"
                    ? Text(
                        image.result
                            .substring(0, index)
                            .trim()
                            .replaceAll(RegExp(r'-'), ' '),
                        textAlign: TextAlign.center,
                      )
                    : CircularProgressIndicator(),
                IconButton(
                    onPressed: () {
                      ref.read(AnalyzePicture.notifier).state = analyzedImages(
                          name: image.name,
                          image: image.image,
                          result: image.result);
                      ref.read(AnalyzeTab.notifier).state = 1;
                    },
                    icon: Icon(Icons.remove_red_eye_outlined)),
                IconButton(
                    onPressed: () {
                      deleteAnalyzedPicture(image.name);
                      final index =
                          cacheData.getInstance().images.indexOf(image);
                      cacheData.getInstance().removeImage(index);
                    },
                    icon: Icon(Icons.close))
              ],
            ))
          ],
        ),
      );
    }
  } else {
    rows.add(
      DataRow(
        cells: [
          DataCell(
            Text("No images taken."),
          )
        ],
      ),
    );
  }
  return rows;
}
