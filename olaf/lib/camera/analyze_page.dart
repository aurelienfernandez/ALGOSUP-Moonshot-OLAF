//------------------- FLUTTER IMPORTS -------------------
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//-------------------- CUSTOM IMPORTS -------------------
import 'package:olaf/camera/picture_list.dart';
import 'package:olaf/classes.dart';

//---------------------- PROVIDERS ----------------------
final AnalyzeTab = StateProvider<int>((ref) => 0);
final AnalyzePicture = StateProvider<analyzedImages>(
    (ref) => analyzedImages(name: "", image: "image", result: "result"));

//-------------------- ANALYZE STATE --------------------
class AnalyzePage extends ConsumerStatefulWidget {
  const AnalyzePage({super.key});

  @override
  _AnalyzePageState createState() => _AnalyzePageState();
}

//--------------------- ANALYZE PAGE --------------------
class _AnalyzePageState extends ConsumerState<AnalyzePage> {
  List<dynamic> tabs = [PictureList(), PicutreDetails()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ref.read(AnalyzeTab) == 1
            ? AppBar(
                leading: IconButton(
                  onPressed: () {
                    ref.read(AnalyzeTab.notifier).state = 0;
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              )
            : null,
        backgroundColor: Colors.white,
        body: tabs[ref.watch(AnalyzeTab)]);
  }
}


/// This widget displays from the selected picture: the picture, the detected plant, and status
class PicutreDetails extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final text = ref.read(AnalyzePicture).result;
    final index = text.indexOf(' ');
    List parts = [
      text.substring(0, index).replaceAll(RegExp(r'-'), ' ').trim(),
      text.substring(index + 1).trim()
    ];
    final titleStyle = TextStyle(fontSize: mediaQuery.width * 0.08);
    final defaultStyle = TextStyle(fontSize: mediaQuery.width * 0.05);
    return SizedBox(
      height: mediaQuery.height,
      child: Column(
        children: [
          Image(
            image: MemoryImage(base64Decode(ref.read(AnalyzePicture).image)),
            width: mediaQuery.width * 0.5,
          ),
          Divider(),
          Text(
            'Plant',
            style: titleStyle,
          ),
          Text(
            parts[0],
            style: defaultStyle,
          ),
          Divider(),
          Text(
            'Status',
            style: titleStyle,
          ),
          Text(
            parts[1],
            style: defaultStyle,
          ),
        ],
      ),
    );
  }
}
