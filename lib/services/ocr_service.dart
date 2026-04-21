import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:googleapis_auth/auth_io.dart';

Future<String> getAccessToken() async {
  // Replace this with your service account JSON file path
  final serviceAccountJson = File('assets/service_account.json');
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
    serviceAccountJson.readAsStringSync(),
  );

  final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

  final client = await clientViaServiceAccount(
    serviceAccountCredentials,
    scopes,
  );

  // Get the access token
  final accessToken = client.credentials.accessToken.data;
  print('Access Token: $accessToken');
  client.close();
  return accessToken;
}

class OCRService {
  Future<String> encodeImageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  static Map<String, dynamic> parse(String rawText) {
    // Extract date, amount, vendor from OCR rawText
    return {"date": "2024-01-01", "amount": 19.99, "vendor": "Store A"};
  }

  static Future<XFile?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    return pickedFile;
  }

  static Future<dynamic> scanImageOld() async {
    final XFile? pickedFile = await pickImage();

    if (pickedFile == null) {
      return "";
    } else {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );

      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );
      await textRecognizer.close();

      return {"result": recognizedText.text, "isSuccess": true};
    }
  }

  static Future<dynamic> scanImage() async {
    final XFile? pickedFile = await pickImage();
    if (pickedFile == null) return;

    final File file = File(pickedFile.path);
    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    //const projectId = 'receipt-pro';
    const projectId = '649903021116';

    const location = 'us';
    const receiptProcessorId = '865802ced4a848c4';
    var accessToken = await getAccessToken();

    final url =
        'https://$location-documentai.googleapis.com/v1/projects/$projectId/locations/$location/processors/$receiptProcessorId:process';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        "rawDocument": {"content": base64Image, "mimeType": "image/jpeg"},
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final doc = json['document'];
      final rawText = doc['text'] ?? '';
      final entityData = <Map<String, String>>[];

      for (var entity in doc['entities'] ?? []) {
        final type = entity['type'] ?? 'unknown';
        final text = entity['mentionText'] ?? '';
        entityData.add({'type': type, 'text': text});
      }

      return {"result": rawText, "data": entityData, "isSuccess": true};
    } else {
      return {
        "result": 'Failed to process: ${response.statusCode}\n${response.body}',
        "data": null,
        "isSuccess": false,
      };
    }
  }
}
