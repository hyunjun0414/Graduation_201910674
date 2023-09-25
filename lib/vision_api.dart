import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<String?> extractTextFromImage(String imagePath, String apiKey) async {
  final bytes = await File(imagePath).readAsBytes();
  final requestUrl = "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";
  final body = {
    "requests": [
      {
        "image": {
          "content": base64Encode(bytes)
        },
        "features": [
          {
            "type": "TEXT_DETECTION",
            "maxResults": 1
          }
        ]
      }
    ]
  };

  final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode(body)
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["responses"]?.first["textAnnotations"]?.first["description"];
  } else {
    print("Error with the vision API: ${response.body}");
    return null;
  }
}

