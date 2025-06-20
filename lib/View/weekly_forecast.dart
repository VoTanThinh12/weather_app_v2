import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// import 'package:weather_app/Provider/theme_provider.dart';

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
  String formatApiData(String dataString) {
    DateTime date = DateTime.parse(dataString);
    return DateFormat('d MMMM, EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: Text(
          'Weekly Forecast - ${widget.city}',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.city,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "${widget.currentValue['temp_c']}°C",
                      style: TextStyle(
                        fontSize: 40,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${widget.currentValue['condition']['text']}",
                      style: TextStyle(
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    Image.network(
                      "https:${widget.currentValue['condition']?['icon'] ?? ''}",
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Next 7 Days Forecast",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 10),
              ...widget.next7days.map((day) {
                final data = day['date'] ?? "";
                final condition = day['day']?['condition']?['text'] ?? '';
                final icon = day['day']?['condition']?['icon'] ?? '';
                final maxTemp = day['day']?['maxtemp_c'] ?? '';
                final minTemp = day['day']?['mintemp_c'] ?? '';

                return ListTile(
                  leading: Image.network('https:$icon', width: 40),
                  title: Text(
                    formatApiData(data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    "$condition $minTemp°C - $maxTemp°C",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              Text(
                "Previous 7 Days Forecast",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              SizedBox(height: 10),
              ...widget.pastWeek.map((day) {
                final forecastDay = day['forecast']?['forecastday'];
                if (forecastDay == null || forecastDay.isEmpty) {
                  return SizedBox.shrink();
                }

                final forecast = forecastDay[0];
                final data = forecast['date'] ?? "";
                final condition = forecast['day']?['condition']?['text'] ?? '';
                final icon = forecast['day']?['condition']?['icon'] ?? '';
                final maxTemp = forecast['day']?['maxtemp_c'] ?? '';
                final minTemp = forecast['day']?['mintemp_c'] ?? '';

                return ListTile(
                  leading: Image.network('https:$icon', width: 40),
                  title: Text(
                    formatApiData(data),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  subtitle: Text(
                    "$condition $minTemp°C - $maxTemp°C",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
