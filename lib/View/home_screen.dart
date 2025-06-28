import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Provider/theme_provider.dart';
import 'package:weather_app/Service/api_service.dart';
import 'package:weather_app/View/weekly_forecast.dart';
import 'package:weather_app/View/chart_screen.dart';

class WeatherAppHomeScreen extends ConsumerStatefulWidget {
  const WeatherAppHomeScreen({super.key});

  @override
  ConsumerState<WeatherAppHomeScreen> createState() =>
      _WeatherAppHomeScreenState();
}

class _WeatherAppHomeScreenState extends ConsumerState<WeatherAppHomeScreen> {
  final _weatherService = WeatherApiService();
  String city = "Ho Chi Minh";
  String country = '';
  Map currentValue = {};
  List hourly = [];
  List past7Days = [];
  List next7Days = [];
  bool isLoading = false;
  int _currentIndex = 0;
  int? selectedHourIndex;
  int currentHourIndex = -1;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      isLoading = true;
    });
    try {
      final forecast = await _weatherService.getHourlyForecast(city);
      final past = await _weatherService.getPastSevenDaysWeather(city);
      setState(() {
        currentValue = forecast['current'] ?? {};
        hourly = forecast['forecast']?['forecastday']?[0]?['hour'] ?? [];
        next7Days = forecast['forecast']?['forecastday'] ?? [];
        past7Days = past;
        city = forecast['location']?['name'] ?? city;
        country = forecast['location']?['country'] ?? '';
        isLoading = false;
        _findCurrentHour();
      });
    } catch (e) {
      setState(() {
        currentValue = {};
        hourly = [];
        past7Days = [];
        next7Days = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Thành phố không tìm thấy hoặc không hợp lệ. Vui lòng thử thành phố khác",
          ),
        ),
      );
    }
  }

  void _findCurrentHour() {
    final now = DateTime.now();
    for (int i = 0; i < hourly.length; i++) {
      final hourTime = DateTime.parse(hourly[i]['time']);
      if (now.hour == hourTime.hour && now.day == hourTime.day) {
        currentHourIndex = i;
        selectedHourIndex = i; // Set default selected to current hour
        break;
      }
    }
  }

  // Tính toán max values từ dữ liệu hourly
  double _getMaxTemperature() {
    if (hourly.isEmpty) return 0;
    double max = hourly[0]['temp_c']?.toDouble() ?? 0;
    for (var hour in hourly) {
      final temp = hour['temp_c']?.toDouble() ?? 0;
      if (temp > max) max = temp;
    }
    return max;
  }

  double _getMaxHumidity() {
    if (hourly.isEmpty) return 0;
    double max = hourly[0]['humidity']?.toDouble() ?? 0;
    for (var hour in hourly) {
      final humidity = hour['humidity']?.toDouble() ?? 0;
      if (humidity > max) max = humidity;
    }
    return max;
  }

  double _getMaxWindSpeed() {
    if (hourly.isEmpty) return 0;
    double max = hourly[0]['wind_kph']?.toDouble() ?? 0;
    for (var hour in hourly) {
      final windSpeed = hour['wind_kph']?.toDouble() ?? 0;
      if (windSpeed > max) max = windSpeed;
    }
    return max;
  }

  String formatTime(String timeString) {
    final time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  String formatDetailTime(String timeString) {
    final time = DateTime.parse(timeString);
    return DateFormat('HH:mm').format(time);
  }

  Widget _buildDetailInfo() {
    if (selectedHourIndex == null || selectedHourIndex! >= hourly.length) {
      return const SizedBox.shrink();
    }

    final hourData = hourly[selectedHourIndex!];
    final time = formatDetailTime(hourData['time']);
    final temp = hourData['temp_c'];
    final humidity = hourData['humidity'];
    final windSpeed = hourData['wind_kph'];
    final icon = hourData['condition']?['icon'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary,
            offset: const Offset(1, 1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          if (icon.isNotEmpty)
            Image.network(
              'https:$icon',
              width: 30,
              height: 30,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.error),
            ),
          Row(
            children: [
              Icon(Icons.thermostat, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(
                '${temp}°C',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                '${humidity}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.air, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${windSpeed}km/h',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScreen() {
    final iconPath = currentValue['condition']?['icon'] as String? ?? '';
    final imageUrl = iconPath.isNotEmpty ? "https:$iconPath" : "";

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (currentValue.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "$city${country.isNotEmpty ? ', $country' : ''}",
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "${currentValue['temp_c'] ?? 'N/A'}°C",
                  style: TextStyle(
                    fontSize: 50,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${currentValue['condition']?['text'] ?? 'N/A'}",
                  style: TextStyle(
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(Icons.error),
                  ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    height: 80,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary,
                          offset: const Offset(1, 1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Nhiệt độ (Max từ hourly data)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: Colors.orange,
                              size: 30,
                            ),
                            Text(
                              "${_getMaxTemperature().toInt()}°C",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Max Temp",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        // Độ ẩm (Max từ hourly data)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 30,
                            ),
                            Text(
                              "${_getMaxHumidity().toInt()}%",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Max Humidity",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        // Gió (Max từ hourly data)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.air, color: Colors.green, size: 30),
                            Text(
                              "${_getMaxWindSpeed().toInt()}km/h",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Max Wind",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Today Forecast",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(height: 5),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: hourly.length,
                          itemBuilder: (context, index) {
                            final hour = hourly[index];
                            final now = DateTime.now();
                            final hourTime = DateTime.parse(hour['time']);
                            final isCurrentHour =
                                now.hour == hourTime.hour &&
                                now.day == hourTime.day;
                            final isSelected = selectedHourIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedHourIndex = index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        isCurrentHour
                                            ? Colors.orangeAccent
                                            : isSelected
                                            ? Colors.blueAccent.withOpacity(0.7)
                                            : Colors.black38,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isCurrentHour
                                            ? "Now"
                                            : formatTime(hour['time']),
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Image.network(
                                        "https:${hour['condition']?['icon'] ?? ''}",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.error),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${hour['temp_c'] ?? 'N/A'}°C",
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Thêm thông tin chi tiết
                _buildDetailInfo(),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final notifier = ref.read(themeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          const SizedBox(width: 25),
          SizedBox(
            width: 280,
            height: 50,
            child: TextField(
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              onSubmitted: (value) {
                if (value.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nhập tên thành phố.")),
                  );
                  return;
                }
                city = value.trim();
                _fetchWeather();
              },
              decoration: InputDecoration(
                labelText: "Tìm kiếm thành phố",
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.surface,
                ),
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: notifier.toggleTheme,
            child: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
              size: 30,
            ),
          ),
          const SizedBox(width: 25),
        ],
      ),
      body:
          _currentIndex == 0
              ? _buildTodayScreen()
              : _currentIndex == 1
              ? WeeklyForecast(
                city: city,
                currentValue: currentValue,
                pastWeek: past7Days,
                next7days: next7Days,
                onBack: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              )
              : ChartScreen(
                city: city,
                currentValue: currentValue,
                hourly: hourly,
                next7Days: next7Days,
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: 'Today'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Charts'),
        ],
      ),
    );
  }
}
