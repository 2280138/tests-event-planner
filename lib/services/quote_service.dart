import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

Future<Quote?> fetchQuote() async {
  try {
    final response = await http.get(Uri.parse('https://api.adviceslip.com/advice'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // The JSON structure is: {"slip": { "id": 166, "advice": "The quieter you become, the more you can hear."}}
      final slip = data['slip'];
      if (slip != null) {
        return Quote.fromJson(slip);
      } else {
        print("Slip data not found in response");
        return null;
      }
    } else {
      print("Failed to load quote, status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error fetching quote: $e");
    return null;
  }
}
