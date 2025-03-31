import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:olaf/classes.dart';
import 'package:olaf/plants/plant_page.dart';

/// Plant data visualization widgets for the OLAF application.
/// 
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
  final Plant plant;
  disconnectButton({required this.plant});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.sizeOf(context);
    return TextButton(
      onPressed: () {
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
          child: Text(
            "Disconnect plant pot",
            style: TextStyle(
              fontSize: mediaQuery.width * 0.05,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
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
            color: theme.colorScheme.secondary),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            image,
            Text(
              title,
              style: TextStyle(fontSize: mediaQuery.width * 0.05),
            ),
            Text(
              valueWithUnit,
              style: TextStyle(fontSize: mediaQuery.width * 0.05),
            ),
          ],
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
  final Plant plant;

  const DataGraph({super.key, required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get data based on choice
    List<num> _getDataByChoice() {
      switch (ref.watch(GraphChoice)) {
        case 0:
          return plant.temperature;
        case 1:
          return plant.soilHumidity;
        case 2:
          return plant.airHumidity;
        default:
          return plant.temperature;
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

    // Get appropriate Y-axis maximum
    double _getMaxY() {
      switch (ref.watch(GraphChoice)) {
        case 0:
          return 40.0; // Temperature max
        case 1:
        case 2:
          return 100.0; // Humidity percentage
        default:
          return 40.0;
      }
    }

    final mediaQuery = MediaQuery.sizeOf(context);
    final data = _getDataByChoice();
    final yAxisTitle = _getYAxisTitle();
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
        lineColor = Colors.brown;
        break;
      case 2:
        lineColor = Colors.blue;
        break;
      default:
        lineColor = Colors.blue;
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
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 3,
                color: lineColor,
                dotData: FlDotData(show: true),
              ),
            ],
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                axisNameWidget: Text("Time"),
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    DateTime time = timeFrame.subtract(Duration(
                        minutes: ((spots.last.x - value) * 60).toInt()));
                    if (time.hour < 0 || time.minute < 0) {
                      return Container();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                    );
                  },
                  reservedSize: 25,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameWidget: Text(yAxisTitle),
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
