import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ChartScreen extends ConsumerStatefulWidget {
  final Map currentValue;
  final List hourly;
  final List next7Days;
  final String city;

  const ChartScreen({
    super.key,
    required this.currentValue,
    required this.hourly,
    required this.next7Days,
    required this.city,
  });

  @override
  ConsumerState<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends ConsumerState<ChartScreen> {
  int selectedChartIndex = 0;
  int? selectedHourIndex;
  int currentHourIndex = -1;

  @override
  void initState() {
    super.initState();
    _findCurrentHour();
  }

  void _findCurrentHour() {
    final now = DateTime.now();
    for (int i = 0; i < widget.hourly.length; i++) {
      final hourTime = DateTime.parse(widget.hourly[i]['time']);
      if (now.hour == hourTime.hour && now.day == hourTime.day) {
        currentHourIndex = i;
        selectedHourIndex = i; // Set default selected to current hour
        break;
      }
    }
  }

  String formatTime(String timeString) {
    final time = DateTime.parse(timeString);
    return DateFormat('HH:mm').format(time);
  }

  String formatDetailTime(String timeString) {
    final time = DateTime.parse(timeString);
    return DateFormat('HH:mm').format(time);
  }

  Widget buildTemperatureChart() {
    if (widget.hourly.isEmpty) {
      return const Center(child: Text('Không có dữ liệu nhiệt độ'));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < widget.hourly.length; i++) {
      final temp = widget.hourly[i]['temp_c']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), temp));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 5,
            verticalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < widget.hourly.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        formatTime(widget.hourly[value.toInt()]['time']),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}°C',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          minX: 0,
          maxX: (widget.hourly.length - 1).toDouble(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (
              FlTouchEvent event,
              LineTouchResponse? touchResponse,
            ) {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
                final spot = touchResponse.lineBarSpots!.first;
                setState(() {
                  selectedHourIndex = spot.spotIndex;
                });
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              getTooltipItems: (_) => [],
            ),
          ),
          showingTooltipIndicators:
              currentHourIndex >= 0
                  ? [
                    ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: spots),
                        currentHourIndex,
                        spots[currentHourIndex],
                      ),
                    ]),
                  ]
                  : [],
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  return spot.x.toInt() == currentHourIndex;
                },
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 6,
                      color: Colors.orangeAccent,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.3),
                    Colors.red.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHumidityChart() {
    if (widget.hourly.isEmpty) {
      return const Center(child: Text('Không có dữ liệu độ ẩm'));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < widget.hourly.length; i++) {
      final humidity = widget.hourly[i]['humidity']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), humidity));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < widget.hourly.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        formatTime(widget.hourly[value.toInt()]['time']),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 42,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          minX: 0,
          maxX: (widget.hourly.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (
              FlTouchEvent event,
              LineTouchResponse? touchResponse,
            ) {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
                final spot = touchResponse.lineBarSpots!.first;
                setState(() {
                  selectedHourIndex = spot.spotIndex;
                });
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              getTooltipItems: (_) => [],
            ),
          ),
          showingTooltipIndicators:
              currentHourIndex >= 0
                  ? [
                    ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: spots),
                        currentHourIndex,
                        spots[currentHourIndex],
                      ),
                    ]),
                  ]
                  : [],
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlue]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  return spot.x.toInt() == currentHourIndex;
                },
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 6,
                      color: Colors.lightBlue,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.lightBlue.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWindChart() {
    if (widget.hourly.isEmpty) {
      return const Center(child: Text('Không có dữ liệu gió'));
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < widget.hourly.length; i++) {
      final windSpeed = widget.hourly[i]['wind_kph']?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), windSpeed));
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10,
            verticalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() < widget.hourly.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        formatTime(widget.hourly[value.toInt()]['time']),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()} km/h',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 10,
                    ),
                  );
                },
                reservedSize: 50,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
          ),
          minX: 0,
          maxX: (widget.hourly.length - 1).toDouble(),
          lineTouchData: LineTouchData(
            enabled: true,
            touchCallback: (
              FlTouchEvent event,
              LineTouchResponse? touchResponse,
            ) {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
                final spot = touchResponse.lineBarSpots!.first;
                setState(() {
                  selectedHourIndex = spot.spotIndex;
                });
              }
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
              getTooltipItems: (_) => [],
            ),
          ),
          showingTooltipIndicators:
              currentHourIndex >= 0
                  ? [
                    ShowingTooltipIndicators([
                      LineBarSpot(
                        LineChartBarData(spots: spots),
                        currentHourIndex,
                        spots[currentHourIndex],
                      ),
                    ]),
                  ]
                  : [],
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  return spot.x.toInt() == currentHourIndex;
                },
                getDotPainter:
                    (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 6,
                      color: Colors.lightGreen,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.lightGreen.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailInfo() {
    if (selectedHourIndex == null ||
        selectedHourIndex! >= widget.hourly.length) {
      return const SizedBox.shrink();
    }

    final hourData = widget.hourly[selectedHourIndex!];
    final time = formatDetailTime(hourData['time']);

    String detailText = '';
    switch (selectedChartIndex) {
      case 0:
        detailText = '$time ${hourData['temp_c']}°C';
        break;
      case 1:
        detailText = '$time ${hourData['humidity']}%';
        break;
      case 2:
        detailText = '$time ${hourData['wind_kph']} km/h';
        break;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getChartIcon(), color: _getChartColor(), size: 24),
          const SizedBox(width: 12),
          Text(
            detailText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getChartIcon() {
    switch (selectedChartIndex) {
      case 0:
        return Icons.thermostat;
      case 1:
        return Icons.water_drop;
      case 2:
        return Icons.air;
      default:
        return Icons.thermostat;
    }
  }

  Color _getChartColor() {
    switch (selectedChartIndex) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biểu đồ thời tiết - ${widget.city}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 20),

              // Chart selector
              Container(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChartSelector(0, 'Nhiệt độ', Icons.thermostat),
                    _buildChartSelector(1, 'Độ ẩm', Icons.water_drop),
                    _buildChartSelector(2, 'Gió', Icons.air),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Chart display
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary,
                      offset: const Offset(2, 2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _getChartTitle(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    _buildSelectedChart(),
                  ],
                ),
              ),

              // Detail info
              _buildDetailInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartSelector(int index, String title, IconData icon) {
    final isSelected = selectedChartIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedChartIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orangeAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color:
                isSelected
                    ? Colors.orangeAccent
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedChart() {
    switch (selectedChartIndex) {
      case 0:
        return buildTemperatureChart();
      case 1:
        return buildHumidityChart();
      case 2:
        return buildWindChart();
      default:
        return buildTemperatureChart();
    }
  }

  String _getChartTitle() {
    switch (selectedChartIndex) {
      case 0:
        return 'Biểu đồ nhiệt độ 24 giờ';
      case 1:
        return 'Biểu đồ độ ẩm 24 giờ';
      case 2:
        return 'Biểu đồ tốc độ gió 24 giờ';
      default:
        return 'Biểu đồ nhiệt độ 24 giờ';
    }
  }
}
