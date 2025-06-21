import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_page.dart';
import 'package:olaf/app_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:olaf/plants/remove_plant.dart';
import 'dart:convert';

/// This file contains various widgets and utilities used to display and 
/// interact with plant monitoring data. These components are designed to 
/// visualize sensor readings for plants, including temperature, soil humidity,
/// and air humidity.
/// 
/// Key components:
/// - [disconnectButton]: Allows users to disconnect a plant pot from the system
/// - [DashboardDataCard]: Displays individual sensor readings with appropriate icons
/// - [DataGraph]: Visualizes historical plant data as a time series graph
/// - [roundToLowestHalfHour]: Utility function for time calculations on graph data
/// 
/// These widgets use Riverpod for state management and fl_chart for data visualization.
/// They are designed to be used within the plant monitoring pages of the application.

/// A button widget that allows users to disconnect a plant pot from the system.
/// 
/// This widget creates a red button that when pressed removes the [plant] from saved plants
/// and resets the plants index to 0 in the provider state.
/// 
/// Parameters:
///   - [plant]: The Plant object to disconnect when the button is pressed.
/// 
/// Returns a styled TextButton with "Disconnect plant pot" text.
class disconnectButton extends ConsumerWidget {
  final SavedPlant plant;
  disconnectButton({required this.plant});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return TextButton(
      onPressed: () {
        removePlantFromS3(plant.potName);
        cacheData.getInstance().savedPlants.remove(plant);
        ref.read(plantsIndex.notifier).state = 0;
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: SizedBox(
        width: mediaQuery.width * 0.5,
        height: mediaQuery.height * 0.06,
        child: Center(
          child: AutoSizeText(
            AppLocalizations.of(context).translate('disconnect_plant_pot'),
            style: TextStyle(
              fontSize: mediaQuery.width * 0.05,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            minFontSize: 12,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// A widget displaying plant measurement data in a card format.
/// 
/// This widget creates a touchable card showing a specific plant metric with an
/// appropriate icon and formatted value. When tapped, it updates the graph choice
/// in the provider state.
/// 
/// Parameters:
///   - [title]: The type of data being displayed ("temperature", "soil humidity", or "air humidity").
///   - [value]: The string representation of the measurement value.
///   - [choice]: Integer representing this data type for the graph selector.
/// 
/// Returns a styled container with an icon, title, and value with appropriate units.
class DashboardDataCard extends ConsumerWidget {
  final String title;
  final String value;
  final int choice;
  DashboardDataCard(this.title, this.value, this.choice);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);

    Image image;
    String valueWithUnit;
    String translationKey = title.replaceAll(' ', '_');
    
    if (title == "temperature") {
      image = Image.asset(
        "./assets/images/dashboard/good_temp.png",
        width: mediaQuery.width * 0.17,
      );
      valueWithUnit = value + "°C";
    } else if (title == "soil humidity") {
      image = Image.asset(
        "./assets/images/dashboard/good_soil.png",
        width: mediaQuery.width * 0.17,
      );
      valueWithUnit = value + "%";
    } else if (title == "air humidity") {
      image = Image.asset(
        "./assets/images/dashboard/good_air.png",
        width: mediaQuery.width * 0.17,
      );
      valueWithUnit = value + "%";
    } else {
      throw "Unknown data type for dashboard data";
    }
    
    return InkWell(
      onTap: () {
        ref.read(GraphChoice.notifier).state = choice;
      },
      child: Container(
        width: mediaQuery.width * 0.4,
        height: mediaQuery.width * 0.4,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), 
            // Add a white background layer to prevent shadow showing through
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                offset: Offset(0, 3),
                spreadRadius: 1.0,
              )
            ]),
        // Add a child container with the semi-transparent background
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: theme.colorScheme.secondary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              AutoSizeText(
                AppLocalizations.of(context).translate(translationKey),
                style: TextStyle(fontSize: mediaQuery.width * 0.05),
                minFontSize: 12,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                valueWithUnit,
                style: TextStyle(fontSize: mediaQuery.width * 0.06),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounds a DateTime to the nearest previous half hour (XX:00 or XX:30).
///
/// Parameters:
///   - [time]: The DateTime to round.
///
/// Returns a new DateTime object rounded down to either XX:00 or XX:30.
DateTime roundToLowestHalfHour(DateTime time) {
  if (time.minute < 30) {
    return DateTime(time.year, time.month, time.day, time.hour, 0);
  } else {
    return DateTime(time.year, time.month, time.day, time.hour, 30);
  }
}

/// A widget that displays a line chart of plant data over time.
/// 
/// This widget creates a line chart visualization that shows historical data for
/// the selected plant metric (temperature, soil humidity, or air humidity).
/// The graph adapts its appearance and scale based on the selected data type.
/// 
/// Parameters:
///   - [plant]: The Plant object containing the data to be visualized.
/// 
/// Returns a LineChart visualization with appropriate styling and labeling based
/// on the selected data type from GraphChoice provider.
class DataGraph extends ConsumerWidget {
  final SavedPlant plant;

  const DataGraph({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get data based on choice
    List<num> _getDataByChoice() {
      switch (ref.watch(GraphChoice)) {
        case 0:
          return plant.temperature.reversed.toList();
        case 1:
          return plant.soilHumidity.reversed.toList();
        case 2:
          return plant.airHumidity.reversed.toList();
        default:
          return plant.temperature.reversed.toList();
      }
    }

    // Get title for the Y-axis
    String _getYAxisTitle() {
      switch (ref.watch(GraphChoice)) {
        case 0:
          return "Temperature (°C)";
        case 1:
          return "Soil Humidity (%)";
        case 2:
          return "Air Humidity (%)";
        default:
          return "Temperature (°C)";
      }
    }

    // Get appropriate Y-axis minimum
    double _getMinY() {
      return 0.0;
    }
    // Get appropriate Y-axis maximum
    double _getMaxY() {
      switch (ref.watch(GraphChoice)) {
        case 0:
          return 35.0; // Temperature max
        case 1:
        case 2:
          return 100.0; // Humidity percentage
        default:
          return 35.0;
      }
    }

    // Find the corresponding plant in lexica for thresholds
    final lexicaPlant = cacheData.getInstance().lexica.plants.firstWhere(
      (p) => p.name == plant.plantName,
      orElse: () => cacheData.getInstance().lexica.plants.first,
    );

    // Check if value exceeds thresholds based on current graph type
    Color isOutsideRange(double value, Color baseColor) {
      switch (ref.watch(GraphChoice)) {
        case 0: // Temperature
          if (value < lexicaPlant.temperatureRange[0]) return Colors.blue;
          if (value > lexicaPlant.temperatureRange[1]) return Colors.red;
          return baseColor;
        case 1: // Soil humidity
          if (value < lexicaPlant.soilHumidityRange[0]) return Colors.blue;
          if (value > lexicaPlant.soilHumidityRange[1]) return Colors.red;
          return baseColor;
        case 2: // Air humidity
          if (value < lexicaPlant.airHumidityRange[0]) return Colors.blue;
          if (value > lexicaPlant.airHumidityRange[1]) return Colors.red;
          return baseColor;
        default:
          return baseColor;
      }
    }

    // Get threshold lines based on the selected data type
    List<HorizontalLine> getThresholdLines() {
      List<HorizontalLine> lines = [];
      switch (ref.watch(GraphChoice)) {
        case 0: // Temperature
          lines.add(
            HorizontalLine(
              y: lexicaPlant.temperatureRange[0].toDouble(),
              color: Colors.blue,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, top: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.blue.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('min')}: ${line.y.toStringAsFixed(1)}°C  ',
              ),
            ),
          );
          lines.add(
            HorizontalLine(
              y: lexicaPlant.temperatureRange[1].toDouble(),
              color: Colors.red,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.red.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('max')}: ${line.y.toStringAsFixed(1)}°C  ',
              ),
            ),
          );
          break;
        case 1: // Soil humidity
          lines.add(
            HorizontalLine(
              y: lexicaPlant.soilHumidityRange[0].toDouble(),
              color: Colors.blue,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, top: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.blue.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('min')}: ${line.y.toStringAsFixed(1)}%  ',
              ),
            ),
          );
          lines.add(
            HorizontalLine(
              y: lexicaPlant.soilHumidityRange[1].toDouble(),
              color: Colors.red,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.red.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('max')}: ${line.y.toStringAsFixed(1)}%  ',
              ),
            ),
          );
          break;
        case 2: // Air humidity
          lines.add(
            HorizontalLine(
              y: lexicaPlant.airHumidityRange[0].toDouble(),
              color: Colors.blue,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, top: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.blue.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('min')}: ${line.y.toStringAsFixed(1)}%  ',
              ),
            ),
          );
          lines.add(
            HorizontalLine(
              y: lexicaPlant.airHumidityRange[1].toDouble(),
              color: Colors.red,
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.only(right: 5, bottom: 5),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.red.withAlpha(170),
                ),
                labelResolver: (line) => '  ${AppLocalizations.of(context).translate('max')}: ${line.y.toStringAsFixed(1)}%  ',
              ),
            ),
          );
          break;
      }
      return lines;
    }

    final mediaQuery = MediaQuery.sizeOf(context);
    final data = _getDataByChoice();
    final yAxisTitle = _getYAxisTitle();
    final minY = _getMinY();
    final maxY = _getMaxY();

    DateTime timeFrame = roundToLowestHalfHour(DateTime.now());
    List<FlSpot> spots = List.generate(data.length, (index) {
      DateTime time = timeFrame.subtract(Duration(minutes: index * 30));
      double timeInHours = time.hour + (time.minute / 60.0);
      return FlSpot(timeInHours, data[index].toDouble());
    });
    spots.sort((a, b) => a.x.compareTo(b.x));

    // Choose appropriate color
    Color lineColor;
    switch (ref.watch(GraphChoice)) {
      case 0:
        lineColor = Colors.green;
        break;
      case 1:
        lineColor = Colors.amber;
        break;
      case 2:
        lineColor = Colors.blue;
        break;
      default:
        lineColor = Colors.blue;
    }

    // Ensure minY is always at least 0, and add a margin to avoid curve going under the graph
    double margin = ((maxY - minY).abs() * 0.05).clamp(1, 10); // 5% of range, at least 1, max 10
    double adjustedMinY = (minY - margin).clamp(0, double.infinity);

    // Handle empty data gracefully
    if (spots.isEmpty) {
      return Container(
        width: mediaQuery.width * 1,
        height: mediaQuery.height * 0.4,
        alignment: Alignment.center,
        child: AutoSizeText(
          AppLocalizations.of(context).translate("no_data_available"),
          style: TextStyle(fontSize: 16, color: Colors.grey),
          maxLines: 1,
        ),
      );
    }

    return Container(
      width: mediaQuery.width * 1,
      height: mediaQuery.height * 0.4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: spots.first.x,
            maxX: spots.last.x,
            minY: adjustedMinY,
            maxY: maxY,
            clipData: FlClipData(
              top: true,
              bottom: false, 
              left: true,
              right: true,
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: lineColor,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    // Use red for values outside the acceptable range
                    Color dotColor = isOutsideRange(spot.y,lineColor);
                    
                    return FlDotCirclePainter(
                      radius: 5,
                      color: dotColor,
                      strokeWidth: 1,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
            extraLinesData: ExtraLinesData(
              horizontalLines: getThresholdLines(),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: AutoSizeText(
                  AppLocalizations.of(context).translate("time"),
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    // Map x value to index in the reversed data (oldest to newest)
                    int index = (spots.length - 1) - ((spots.last.x - value).round());
                    if (index < 0 || index >= plant.timestamps.length) {
                      return Container();
                    }
                    String label = plant.timestamps[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        textAlign: TextAlign.center,
                        label,
                        style: TextStyle(fontSize: 7, color: Colors.black),
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: AutoSizeText(
                  yAxisTitle,
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                ),
                sideTitles: SideTitles(showTitles: true, reservedSize: 35),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}

/// A widget that displays a plant metric image in a dialog overlay when tapped.
/// The image is provided as a base64 encoded string.
/// 
/// This widget is useful for showing plant-related images or icons in a dynamic
/// and interactive way, with the image occupying the full screen in a dialog.
/// 
/// Parameters:
///   - [base64Image]: A base64 encoded string representing the image to be displayed.
/// 
/// Returns a GestureDetector wrapping a Container that shows the image in a dialog
/// overlay when tapped.
class ImageDataCard extends StatefulWidget {
  final String base64Image;
  const ImageDataCard({super.key, required this.base64Image});

  @override
  State<ImageDataCard> createState() => _ImageDataCardState();
}

class _ImageDataCardState extends State<ImageDataCard> {
  bool _dialogOpen = false;

  void _showImageDialog(BuildContext context, Uint8List imageBytes) async {
    setState(() {
      _dialogOpen = true;
    });
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final mediaQuery = MediaQuery.of(context).size;
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black.withOpacity(0.85),
            alignment: Alignment.center,
            child: Image.memory(
              imageBytes,
              width: mediaQuery.width * 0.9,
              height: mediaQuery.height * 0.8,
              fit: BoxFit.contain
            ),
          ),
        );
      },
    );
    setState(() {
      _dialogOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.sizeOf(context);
    final isAsset = widget.base64Image == "assets/images/no-image.png";
    Uint8List? imageBytes;
    if (!isAsset) {
      try {
        imageBytes = base64Decode(widget.base64Image);
      } catch (e) {
        imageBytes = null;
      }
    }

    return InkWell(
      onTap: () {
        if (!_dialogOpen && !isAsset && imageBytes != null) {
          _showImageDialog(context, imageBytes);
        }
      },
      child: Container(
        width: mediaQuery.width * 0.4,
        height: mediaQuery.width * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(0, 3),
              spreadRadius: 1.0,
            )
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.secondary,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: isAsset
                ? Image.asset(
                    "assets/images/no-image.png",
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : (imageBytes != null
                    ? Image.memory(
                        imageBytes,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      )
                    : const Icon(Icons.error)),
          ),
        ),
      ),
    );
  } 
}
