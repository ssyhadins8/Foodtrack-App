import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double temperature;
  final double windspeed;
  final int weatherCode;
  final String condition;
  final String recommendation;
  final String icon;

  WeatherInfo({
    required this.temperature,
    required this.windspeed,
    required this.weatherCode,
    required this.condition,
    required this.recommendation,
    required this.icon,
  });

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    final cur = map['current_weather'] ?? {};
    final temp = (cur['temperature'] as num?)?.toDouble() ?? 30.0;
    final wind = (cur['windspeed'] as num?)?.toDouble() ?? 10.0;
    final code = (cur['weathercode'] as num?)?.toInt() ?? 0;

    String cond = 'Cerah';
    String rec = 'Cuaca cerah di Kampus! ☀️ Ayo jalan kaki ambil makananmu.';
    String ico = '☀️';

    // WMO Weather interpretation codes (https://open-meteo.com/en/docs)
    if (code == 0) {
      cond = 'Cerah';
      rec = 'Cuaca cerah di Kampus! ☀️ Ayo ambil makananmu ke kantin.';
      ico = '☀️';
    } else if (code >= 1 && code <= 3) {
      cond = 'Cerah Berawan';
      rec = 'Cuaca berawan nyaman! ⛅ Cocok untuk jalan santai ambil makanan.';
      ico = '⛅';
    } else if (code == 45 || code == 48) {
      cond = 'Berkabut';
      rec = 'Kampus sedang berkabut! 🌫️ Tetap hati-hati saat berkendara.';
      ico = '🌫️';
    } else if (code >= 51 && code <= 57) {
      cond = 'Gerimis';
      rec = 'Gerimis tipis di Kampus! 🌦️ Bawa payung/jas hujan tipis ya.';
      ico = '🌦️';
    } else if (code >= 61 && code <= 67) {
      cond = 'Hujan';
      rec = 'Sedang hujan di Kampus! 🌧️ Jangan lupa bawa payung sebelum mengambil makanan.';
      ico = '🌧️';
    } else if (code >= 71 && code <= 77) {
      cond = 'Salju';
      rec = 'Dingin sekali di Kampus! ❄️ Hangatkan dirimu dengan makanan hangat.';
      ico = '❄️';
    } else if (code >= 80 && code <= 82) {
      cond = 'Hujan Deras';
      rec = 'Hujan deras mengguyur Kampus! 🌧️ Tunggu hujan reda atau gunakan payung lebar.';
      ico = '🌧️';
    } else if (code >= 95 && code <= 99) {
      cond = 'Badai Petir';
      rec = 'Ada badai petir di Kampus! ⛈️ Sebaiknya tunggu reda sebelum keluar.';
      ico = '⛈️';
    }

    return WeatherInfo(
      temperature: temp,
      windspeed: wind,
      weatherCode: code,
      condition: cond,
      recommendation: rec,
      icon: ico,
    );
  }

  factory WeatherInfo.fallback() {
    return WeatherInfo(
      temperature: 30.0,
      windspeed: 12.0,
      weatherCode: 0,
      condition: 'Cerah',
      recommendation: 'Hubungan internet terputus. Cuaca diasumsikan cerah normal. ☀️ Ayo ambil makananmu!',
      icon: '☀️',
    );
  }
}

class WeatherService {
  // UNESA Lidah Wetan Campus, Surabaya coordinates
  static const double _lat = -7.2802;
  static const double _lon = 112.6749;

  static Future<WeatherInfo> fetchCampusWeather() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=$_lat&longitude=$_lon&current_weather=true',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherInfo.fromMap(data);
      } else {
        throw Exception('Gagal memuat data cuaca (Status: ${response.statusCode})');
      }
    } catch (e) {
      // Graceful error handling - fallback to standard weather info without crashing
      print('Weather API Error: $e');
      return WeatherInfo.fallback();
    }
  }
}
