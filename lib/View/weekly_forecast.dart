import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WeeklyForecast extends ConsumerStatefulWidget {
  final Map currentValue;
  final String city;
  final List pastWeek;
  final List next7days;
  final VoidCallback? onBack;

  const WeeklyForecast({
    super.key,
    required this.city,
    required this.currentValue,
    required this.pastWeek,
    required this.next7days,
    this.onBack,
  });

  @override
  ConsumerState<WeeklyForecast> createState() => _WeeklyForecastState();
}

class _WeeklyForecastState extends ConsumerState<WeeklyForecast> {
  int selectedForecastIndex =
      0; // 0 = Next 7 days (mặc định), 1 = Previous 7 days

  String formatApiData(String dataString) {
    DateTime date = DateTime.parse(dataString);
    return DateFormat('d MMMM, EEEE').format(date);
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
              // Button selector cố định (không scroll)
              Row(
                children: [
                  // Previous 7 Days - Bên trái
                  Expanded(
                    child: _buildForecastSelector(
                      1,
                      'Previous 7 Days',
                      Icons.arrow_back,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Next 7 Days - Bên phải
                  Expanded(
                    child: _buildForecastSelector(
                      0,
                      'Next 7 Days',
                      Icons.arrow_forward,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Forecast display
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
                        widget
                            .city, // Hiển thị tên thành phố thay vì "Next 7 Days Forecast"
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    _buildSelectedForecast(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForecastSelector(int index, String title, IconData icon) {
    final isSelected = selectedForecastIndex == index;
    final isNextDays = index == 0; // Kiểm tra có phải Next 7 Days không

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedForecastIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              isNextDays
                  ? [
                    // Next 7 Days: Text trước, Icon sau
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      icon,
                      color:
                          isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                  ]
                  : [
                    // Previous 7 Days: Icon trước, Text sau
                    Icon(
                      icon,
                      color:
                          isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
        ),
      ),
    );
  }

  Widget _buildSelectedForecast() {
    switch (selectedForecastIndex) {
      case 0:
        return _buildNext7DaysForecast();
      case 1:
        return _buildPrevious7DaysForecast();
      default:
        return _buildNext7DaysForecast();
    }
  }

  Widget _buildNext7DaysForecast() {
    if (widget.next7days.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No forecast data available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            widget.next7days.map((day) {
              final data = day['date'] ?? "";
              final condition = day['day']?['condition']?['text'] ?? '';
              final icon = day['day']?['condition']?['icon'] ?? '';
              final maxTemp = day['day']?['maxtemp_c'] ?? '';
              final minTemp = day['day']?['mintemp_c'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https:$icon',
                      width: 50,
                      height: 50,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatApiData(data),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            condition,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$minTemp°C - $maxTemp°C",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildPrevious7DaysForecast() {
    if (widget.pastWeek.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No past weather data available')),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children:
            widget.pastWeek.map((day) {
              final forecastDay = day['forecast']?['forecastday'];
              if (forecastDay == null || forecastDay.isEmpty) {
                return const SizedBox.shrink();
              }

              final forecast = forecastDay[0];
              final data = forecast['date'] ?? "";
              final condition = forecast['day']?['condition']?['text'] ?? '';
              final icon = forecast['day']?['condition']?['icon'] ?? '';
              final maxTemp = forecast['day']?['maxtemp_c'] ?? '';
              final minTemp = forecast['day']?['mintemp_c'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https:$icon',
                      width: 50,
                      height: 50,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatApiData(data),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            condition,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "$minTemp°C - $maxTemp°C",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
