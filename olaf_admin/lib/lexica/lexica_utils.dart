//------------------- FLUTTER IMPORTS -------------------
import 'package:file_picker/file_picker.dart';
import 'package:olaf_admin/classes.dart';
import 'package:olaf_admin/lexica/lexica_list.dart';

//------------------- CUSTOM IMPORTS --------------------
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Create a list with either all plants or all diseases listed in a scrollview,
/// the user can click on them, thus changing the viewed plant or disease
class NameList extends ConsumerWidget {
  final List<dynamic> plantOrDisease;
  const NameList({super.key, required this.plantOrDisease});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final textStyle = TextStyle(fontSize: mediaQuery.width * 0.015);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mediaQuery.width * 0.1),
      child: SingleChildScrollView(
        controller: ScrollController(initialScrollOffset: 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < plantOrDisease.length; i++)
              TextButton(
                onPressed: () {
                  ref.read(checkUserInputProvider.notifier).state=false;
                  ref.read(targetID.notifier).state = i;
                  ref.read(nameController.notifier).state.text =
                      plantOrDisease[i].name;
                  ref.read(checkUserInputProvider.notifier).state=true;
                },
                child: Text(
                  plantOrDisease[i].name,
                  style: textStyle.copyWith(
                      fontSize: mediaQuery.width * 0.02,
                      color: ref.watch(targetID) == i
                          ? Colors.blue.shade400
                          : Colors.black),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Name extends ConsumerWidget {
  final List<dynamic> plantOrDisease;
  const Name({super.key, required this.plantOrDisease});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.read(nameController).text == "") {
      ref.read(nameController.notifier).state.text =
          plantOrDisease[ref.read(targetID)].name;
    }
    final mediaQuery = MediaQuery.sizeOf(context);
    final titleStyle = TextStyle(fontSize: mediaQuery.width * 0.03);
    final textStyle = TextStyle(fontSize: mediaQuery.width * 0.015);
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Text(
            "Name:",
            style: titleStyle,
          ),
          TextFormField(
            decoration: const InputDecoration(border: InputBorder.none),
            controller: ref.watch(nameController),
            textAlign: TextAlign.start,
            style: textStyle,
          ),
          const Divider()
        ],
      ),
    );
  }
}

/// A widget that returns a modifiable image.
///
/// To select which image to modify use the [type] list, where index:
///
/// - 0 = Which element: plant image = 0, disease image = 1, disease icon = 2, plant's disease image = 3
/// - 1 = The index of the plant's disease, default value is 0
class ImageChanger extends ConsumerWidget {
  final String image;
  final List<int> type;
  ImageChanger({
    super.key,
    required this.image,
    required List<int> type,
  }) : type = (type.length > 1) ? type : [type[0], 0];

  Future<String?> _changePicture() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.single;
        Uint8List? bytes;

        if (file.bytes != null) {
          bytes = file.bytes;
        } else if (file.path != null) {
          final filePath = file.path!;
          bytes = await File(filePath).readAsBytes();
        } else {
          return null;
        }

        String base64Image = base64Encode(bytes!);
        return base64Image;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return InkWell(
        onTap: () async {
          final newImage = await _changePicture();
          if (newImage != null) {
            switch (type[0]) {
              case 0:
                CacheData.getInstance()
                    .lexica
                    .plants[ref.read(targetID)]
                    .image = newImage;

                break;
              case 1:
                CacheData.getInstance()
                    .lexica
                    .diseases[ref.read(targetID)]
                    .image = newImage;

                break;
              case 2:
                CacheData.getInstance()
                    .lexica
                    .diseases[ref.read(targetID)]
                    .icon = newImage;
                break;
              case 3:
                CacheData.getInstance()
                    .lexica
                    .plants[ref.read(targetID)]
                    .diseases[type[1]]
                    .image = newImage;
                break;
              default:
                debugPrint("Unknown type");
                break;
            }
            ref.read(rebuildTriggerProvider).update();
          }
        },
        child: Container(
          color: type[0] == 2 ? Colors.black : Colors.transparent,
          child: Image(
            image: image.startsWith('http')
                ? NetworkImage(image) as ImageProvider
                : image == "placeholder"
                    ? const AssetImage("assets/images/placeholder.png")
                    : MemoryImage(base64Decode(image)) as ImageProvider,
            width: type[0]==2? mediaQuery.width*0.05 : mediaQuery.width * 0.2,
          ),
        ));
  }
}
