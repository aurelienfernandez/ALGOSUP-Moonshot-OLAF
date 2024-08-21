//------------------- CUSTOM IMPORTS --------------------
import 'package:olaf_admin/classes.dart';
import 'package:olaf_admin/lexica/lexica_utils.dart';

//------------------- FLUTTER IMPORTS -------------------
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//------------------ GENERAL PROVIDERS ------------------
//----------------- ID -----------------
final targetID = StateProvider<int>((ref) => 0);

//---------------- NAME ----------------
final nameController =
    StateProvider<TextEditingController>((ref) => TextEditingController());

//-------------- REBUILD ---------------
final rebuildTriggerProvider = ChangeNotifierProvider<Notifier>((ref) {
  return Notifier();
});

class Notifier extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

//------------- USER INPUT -------------
final checkUserInputProvider = StateProvider<bool>((ref) => false);

class LexicaListState extends ConsumerStatefulWidget {
  final String type;

  const LexicaListState({super.key, required this.type});

  @override
  ConsumerState<LexicaListState> createState() => LexicaList();
}

class LexicaList extends ConsumerState<LexicaListState> {
  late Widget finalWidget;
  final lexica = CacheData.getInstance().lexica;
  late dynamic plantOrDisease;

  List<VoidCallback> listeners = [];

  TextEditingController bigTextController = TextEditingController();
  TextEditingController preventController = TextEditingController();
  TextEditingController cureController = TextEditingController();
  List<TextEditingController> tipsController = [];
  List<TextEditingController> diseasesController = [];

  @override
  void initState() {
    super.initState();

    createListeners();
  }

  void createListeners() {
    if (widget.type == "plants") {
      plantOrDisease =
          CacheData.getInstance().lexica.plants[ref.read(targetID)];
    } else {
      plantOrDisease =
          CacheData.getInstance().lexica.diseases[ref.read(targetID)];
    }

    // Create a listener for the name of the plant/disease
    createListener(() {
      _onChange(
          ref.read(nameController).text, plantOrDisease.name, plantOrDisease);
    }, ref.read(nameController));

    // If it is a plant, create listeners for: how to, tips, and diseases
    if (plantOrDisease is Plant) {
      plantOrDisease =
          CacheData.getInstance().lexica.plants[ref.read(targetID)];

      // Create how to listener
      createListener(() {
        _onChange(bigTextController.text, plantOrDisease.howTo, plantOrDisease);
      }, bigTextController);

      // Create tips listeners
      int tipsLength = plantOrDisease.tips.length;
      for (int index = 0; index < tipsLength; index++) {
        tipsController.add(TextEditingController(
            text: "${index + 1}- ${plantOrDisease.tips[index]}"));
        createListener(() {
          _onChange(tipsController[index].text, plantOrDisease.tips[index],
              plantOrDisease);
        }, tipsController[index]);
      }

      // Create listeners for diseases
      int diseasesLength = plantOrDisease.diseases.length;
      for (int index = 0; index < diseasesLength; index++) {
        diseasesController.add(
            TextEditingController(text: plantOrDisease.diseases[index].name));
        createListener(() {
          _onChange(diseasesController[index].text,
              plantOrDisease.diseases[index].name, plantOrDisease);
        }, diseasesController[index]);
      }

      // If it is a disease, create a listener for: description, prevent, and cure
    } else {
      plantOrDisease =
          CacheData.getInstance().lexica.diseases[ref.read(targetID)];

      // Create listener for description
      createListener(() {
        _onChange(
            bigTextController.text, plantOrDisease.description, plantOrDisease);
      }, bigTextController);

      // Create listener for prevent
      createListener(() {
        _onChange(
            bigTextController.text, plantOrDisease.prevent, plantOrDisease);
      }, bigTextController);

      // Create listener for cure
      createListener(() {
        _onChange(cureController.text, plantOrDisease.cure, plantOrDisease);
      }, cureController);
    }
  }

  void createListener(VoidCallback listener, TextEditingController controller) {
    listeners.add(listener);
    controller.addListener(listener);
  }

  void deleteListeners() {
    if (plantOrDisease is Plant) {
      for (TextEditingController controller in diseasesController) {
        deleteListener(controller);
      }
      diseasesController.clear();
      for (TextEditingController controller in tipsController) {
        deleteListener(controller);
      }
      tipsController.clear();
    } else if (plantOrDisease is Disease) {
      deleteListener(cureController);
      deleteListener(preventController);
    }
    deleteListener(bigTextController);
    deleteListener(ref.read(nameController));
  }

  void deleteListener(TextEditingController controller) {
    controller.removeListener(listeners.last);
    listeners.removeLast();
  }

  void _onChange(
      String changeString, String originalString, dynamic plantOrDisease) {
    // If the action has not been performed by the user, cancel the changes
    if (ref.read(checkUserInputProvider) == false) {
      return;
    }
    if (plantOrDisease is Plant) {
      if (plantOrDisease.name == originalString) {
        plantOrDisease.name = changeString;
      } else if (plantOrDisease.howTo == originalString) {
        plantOrDisease.howTo = changeString;
      } else if (plantOrDisease.tips.contains(originalString)) {
        final int index = plantOrDisease.tips.indexOf(originalString);
        plantOrDisease.tips[index] = changeString;
      } else if (plantOrDisease.diseases
          .any((element) => element.name == originalString)) {
        final int index = plantOrDisease.diseases
            .indexWhere((element) => element.name == originalString);
        plantOrDisease.diseases[index].name = changeString;
      }
      return;
    } else if (plantOrDisease is Disease) {
      if (plantOrDisease.name == originalString) {
        plantOrDisease.name = changeString;
      } else if (plantOrDisease.description == originalString) {
        plantOrDisease.description = changeString;
      } else if (plantOrDisease.prevent == originalString) {
        plantOrDisease.prevent = changeString;
      } else if (plantOrDisease.cure == originalString) {
        plantOrDisease.cure = changeString;
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(targetID, (previous, next) {
      deleteListeners();
      createListeners();
    });
    //----------- NOTIFIER -----------
    ref.watch(rebuildTriggerProvider);

    final type = widget.type;
    final mediaQuery = MediaQuery.sizeOf(context);
    final titleStyle = TextStyle(fontSize: mediaQuery.width * 0.03);
    final textStyle = TextStyle(fontSize: mediaQuery.width * 0.015);

    //------------ PLANTS ------------
    if (type == "plants") {
      final plants = lexica.plants;
      final plant = plants[ref.watch(targetID)];
      // Reset how to controller
      bigTextController.text = plant.howTo;

      finalWidget = Row(children: [
        //---------- PLANT LIST ----------
        NameList(plantOrDisease: plants),
        //------------ DIVIDER -----------
        const VerticalDivider(),

        //---------- PLANT INFO ----------
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //------------- NAME -------------
                Name(plantOrDisease: plants),
                //------------- IMAGE -------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "Image:",
                        style: titleStyle,
                      ),
                      ImageChanger(
                        image: plant.image,
                        type: const [0, 0],
                      ),
                      const Divider()
                    ],
                  ),
                ),

                //------------- HOW TO ------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Text(
                        "How to take care of it:",
                        style: titleStyle,
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        controller: bigTextController,
                        textAlign: TextAlign.start,
                        maxLines: null,
                        style: textStyle,
                      ),
                      const Divider()
                    ],
                  ),
                ),

                //------------- TIPS ------------
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Tips:", style: titleStyle),
                          ]),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (int tipsIndex = 0;
                              tipsIndex < tipsController.length;
                              tipsIndex++)
                            Wrap(
                              alignment: WrapAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: mediaQuery.width * 0.6,
                                  ),
                                  child: TextFormField(
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                        border: InputBorder.none),
                                    controller: tipsController[tipsIndex],
                                    textAlign: TextAlign.start,
                                    style: textStyle,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    listeners.removeAt(tipsIndex +
                                        2); // +2 since there is the name and howTo before
                                    tipsController.removeAt(tipsIndex);
                                    plant.tips.removeAt(tipsIndex);
                                    ref.watch(rebuildTriggerProvider).update();
                                  },
                                  icon: const Icon(
                                      Icons.remove_circle_outline_outlined),
                                ),
                              ],
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    plant.tips.add("new tip");
                                    tipsController.add(TextEditingController(
                                        text:
                                            "${plant.tips.length}- ${plant.tips.last}"));
                                    createListener(() {
                                      _onChange(tipsController.last.text,
                                          plantOrDisease.name, plantOrDisease);
                                    }, tipsController.last);
                                    ref.watch(rebuildTriggerProvider).update();
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: mediaQuery.width * 0.02,
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const Divider(),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Diseases:", style: titleStyle),
                      for (int diseaseIndex = 0;
                          diseaseIndex < plant.diseases.length;
                          diseaseIndex++)
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: mediaQuery.width * 0.1,
                                ),
                                IconButton(
                                  padding: EdgeInsets.only(
                                      top: mediaQuery.width * 0.005),
                                  onPressed: () {
                                    listeners.removeAt(diseaseIndex +
                                        2 +
                                        tipsController
                                            .length); // +2 and tips's length as it is the last items
                                    diseasesController.removeAt(diseaseIndex);
                                    plant.diseases.removeAt(diseaseIndex);
                                    ref.watch(rebuildTriggerProvider).update();
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth: mediaQuery.width * 0.2),
                                  child: TextFormField(
                                    maxLines: null,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    controller:
                                        diseasesController[diseaseIndex],
                                    textAlign: TextAlign.start,
                                    style: textStyle,
                                  ),
                                ),
                              ],
                            ),
                            ImageChanger(
                                image: plant.diseases[diseaseIndex].image,
                                type: [3, diseaseIndex]),
                            if (diseaseIndex < plant.diseases.length - 1)
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: mediaQuery.height * 0.03)),
                            if (diseaseIndex < plant.diseases.length - 1)
                              Divider(
                                indent: mediaQuery.width * 0.2,
                                endIndent: mediaQuery.width * 0.2,
                                thickness: 3,
                              ),
                          ],
                        ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            plant.diseases.add(PlantDisease(
                                name: "NewDisease", image: "placeholder"));
                            ref.watch(rebuildTriggerProvider).update();
                            diseasesController.add(TextEditingController(
                                text: plant.diseases.last.name));
                            createListener(() {
                              _onChange(diseasesController.last.text,
                                  plantOrDisease.name, plantOrDisease);
                            }, diseasesController.last);
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        iconSize: mediaQuery.width * 0.05,
                      )
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(bottom: mediaQuery.height * 0.1))
              ],
            ),
          ),
        ),
      ]);
    } else if (type == "diseases") {
      final diseases = lexica.diseases;
      final disease = diseases[ref.watch(targetID)];

      // Reset description controller
      bigTextController.text = disease.description;

      // Reset prevent controller
      preventController.text = disease.prevent;

      // Reset cure controller
      cureController.text = disease.cure;

      finalWidget = Row(children: [
        //---------- PLANT LIST ----------
        NameList(plantOrDisease: diseases),
        //------------ DIVIDER -----------
        const VerticalDivider(),

        //---------- PLANT INFO ----------
        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              //------------- NAME -------------
              Name(plantOrDisease: diseases),

              //------------- IMAGE -------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Image:",
                      style: titleStyle,
                    ),
                    ImageChanger(
                      image: disease.image,
                      type: const [1, 0],
                    ),
                    const Divider()
                  ],
                ),
              ),

              //------------- ICON -------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Icon:",
                      style: titleStyle,
                    ),
                    ImageChanger(
                      image: disease.icon,
                      type: const [2, 0],
                    ),
                    const Divider()
                  ],
                ),
              ),
              //---------- DESCRIPTION ----------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Description:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: bigTextController,
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                    const Divider()
                  ],
                ),
              ),
              //---------- PREVENT ----------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Prevent:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: preventController,
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                    const Divider()
                  ],
                ),
              ),
              //----------- CURE ------------
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      "Cure:",
                      style: titleStyle,
                    ),
                    TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: cureController,
                      textAlign: TextAlign.start,
                      style: textStyle,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ]);
    } else {
      throw "Unkown type in lexica";
    }
    return finalWidget;
  }
}
