import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

// 이미지를 잘라내고 확대하는 함수
Future<List<int>> cropAndResizeImage(
    String imagePath, Rect selectionRect) async {
  final imageFile = File(imagePath);
  final imageBytes = await imageFile.readAsBytes();

  img.Image originalImage = img.decodeImage(imageBytes)!;

  // 사용자가 선택한 영역을 잘라냅니다.
  img.Image croppedImage = img.copyCrop(
    originalImage,
    x: selectionRect.left.toInt(),
    y: selectionRect.top.toInt(),
    width: selectionRect.width.toInt(),
    height: selectionRect.height.toInt(),
  );

  // 잘라낸 영역을 확대합니다 (예: 2배 확대)
  img.Image resizedImage = img.copyResize(croppedImage,
      width: croppedImage.width * 2, height: croppedImage.height * 2);

  return img.encodePng(resizedImage);
}

// 수정된 extractTextFromImage 함수
Future<String?> extractTextFromImage(
    String imagePath, String apiKey, Rect selectionRect) async {
  // 이미지를 잘라내는 함수 호출
  final croppedResizedBytes =
      await cropAndResizeImage(imagePath, selectionRect);

  // Google Vision API 요청 URL
  final requestUrl =
      "https://vision.googleapis.com/v1/images:annotate?key=$apiKey";

  // 요청 본문 구성
  final body = {
    "requests": [
      {
        "image": {"content": base64Encode(croppedResizedBytes)},
        "features": [
          {"type": "TEXT_DETECTION", "maxResults": 1}
        ]
      }
    ]
  };

  // HTTP 요청 전송 및 응답 처리
  final response = await http.post(Uri.parse(requestUrl),
      headers: {"Content-Type": "application/json"}, body: jsonEncode(body));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["responses"]?.first["textAnnotations"]?.first["description"];
  } else {
    print("Error with the vision API: ${response.body}");
    return null;
  }
}
