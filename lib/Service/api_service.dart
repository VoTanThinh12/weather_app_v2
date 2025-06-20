// import 'dart:convert';

// import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/foundation.dart';

// const String apiKey = "612532f7683246cba4d121126251706";

// class WeatherApiService {
//   final String _baseUrl = "https://api.weatherapi.com/v1";
//   Future<Map<String, dynamic>> getHourlyForecast(String location) async {
//     final url = Uri.parse(
//       "$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7",
//     );

//     final res = await http.get(url);
//     if (res.statusCode != 200) {
//       throw Exception("Failed to fetch data: ${res.body}");
//     }
//     final data = json.decode(res.body);
//     if (data.containsKey('error')) {
//       throw Exception(data['error']['message'] ?? 'Invalid location');
//     }
//     return data;
//   }

//   Future<List<Map<String, dynamic>>> getPastSevenDaysWeather(
//     String location,
//   ) async {
//     final List<Map<String, dynamic>> pastWeather = [];
//     final today = DateTime.now();
//     for (int i = 1; i <= 7; i++) {
//       final pastDate = today.subtract(
//         Duration(days: i),
//       ); // Đổi tên từ data sang pastDate
//       final formattedDate =
//           "${pastDate.year}-${pastDate.month.toString().padLeft(2, "0")}-${pastDate.day.toString().padLeft(2, "0")}";

//       final url = Uri.parse(
//         "$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate",
//       );
//       final res = await http.get(url);
//       if (res.statusCode == 200) {
//         final data = json.decode(res.body);
//         if (data.containsKey('error')) {
//           throw Exception(data['error']['message'] ?? 'Invalid location');
//         }
//         if (data['forecast']?['forecastday'] != null) {
//           pastWeather.add(data);
//         }
//       } else {
//         debugPrint("Failed to fetch past data for $formattedDate:${res.body}");
//       }
//     }
//     return pastWeather;
//   }
// }
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String apiKey = "612532f7683246cba4d121126251706";

class WeatherApiService {
  final String _baseUrl = "https://api.weatherapi.com/v1";

  Future<Map<String, dynamic>> getHourlyForecast(String location) async {
    final url = Uri.parse(
      "$_baseUrl/forecast.json?key=$apiKey&q=$location&days=7", // Sửa lỗi: bỏ dấu {}
    );

    try {
      final response = await http.get(url); // Đổi tên từ res sang response
      if (response.statusCode != 200) {
        throw Exception("Failed to fetch data: ${response.body}");
      }
      final forecastData = json.decode(
        response.body,
      ); // Đổi tên từ data sang forecastData
      if (forecastData.containsKey('error')) {
        throw Exception(forecastData['error']['message'] ?? 'Invalid location');
      }
      return forecastData;
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getPastSevenDaysWeather(
    String location,
  ) async {
    final List<Map<String, dynamic>> pastWeather = [];
    final today = DateTime.now();

    for (int i = 1; i <= 7; i++) {
      final pastDate = today.subtract(Duration(days: i));
      final formattedDate =
          "${pastDate.year}-${pastDate.month.toString().padLeft(2, "0")}-${pastDate.day.toString().padLeft(2, "0")}";

      final url = Uri.parse(
        "$_baseUrl/history.json?key=$apiKey&q=$location&dt=$formattedDate",
      );

      try {
        final response = await http.get(url); // Đổi tên từ res sang response
        if (response.statusCode == 200) {
          final historyData = json.decode(
            response.body,
          ); // Đổi tên từ data sang historyData
          if (historyData.containsKey('error')) {
            debugPrint(
              "Error for $formattedDate: ${historyData['error']['message']}",
            );
            continue; // Tiếp tục với ngày tiếp theo
          }
          if (historyData['forecast']?['forecastday'] != null) {
            pastWeather.add(historyData);
          }
        } else {
          debugPrint(
            "Failed to fetch past data for $formattedDate: ${response.body}",
          );
        }
      } catch (e) {
        debugPrint("Network error for $formattedDate: $e");
        // Tiếp tục với ngày tiếp theo thay vì dừng hoàn toàn
      }
    }
    return pastWeather;
  }
}
