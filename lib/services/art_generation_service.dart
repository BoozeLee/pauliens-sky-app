import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ArtGenerationResult {
  final String svgString;
  final Uint8List bytes;
  final String revisedPrompt;

  ArtGenerationResult({
    required this.svgString,
    required this.bytes,
    required this.revisedPrompt,
  });
}

class ArtGenerationService {
  static const _imageBaseUrl =
      String.fromEnvironment('PAULIENS_SKY_APP_URL', defaultValue: '');
  static const _artEndpoint = '/api/ai/generate-image';

  static const styles = [
    'astrological',
    'traditional',
    'abstract',
    'minimalist',
    'watercolor',
  ];

  static const styleLabels = {
    'astrological': 'Celestial',
    'traditional': 'Illuminated',
    'abstract': 'Abstract',
    'minimalist': 'Minimal',
    'watercolor': 'Watercolor',
  };

static Future<ArtGenerationResult> generate({
  required String prompt,
  String style = 'astrological',
  String? negativePrompt,
  String provider = 'auto',
  int width = 1024,
  int height = 1024,
}) async {
  if (_imageBaseUrl.isEmpty) {
    throw Exception(
      'Art generation service not configured. Please set the PAULIENS_SKY_APP_URL environment variable to your deployed backend URL (e.g., https://your-app.vercel.app).'
    );
  }
  
  final url = '$_imageBaseUrl$_artEndpoint';

    final response = await http.post(
      Uri.parse(url),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'style': style,
        'negativePrompt': negativePrompt ?? '',
        'provider': provider,
        'width': width,
        'height': height,
      }),
    ).timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(
          'Art generation error: ${err['error'] ?? response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final imageStr = data['image'] as String;
    final revisedPrompt = data['revisedPrompt'] as String? ?? prompt;

    String svgString = '';
    Uint8List bytes;

    if (imageStr.startsWith('http')) {
      final imgResponse = await http.get(Uri.parse(imageStr)).timeout(const Duration(seconds: 30));
      if (imgResponse.statusCode != 200) {
        throw Exception('Failed to download generated image');
      }
      bytes = imgResponse.bodyBytes;
    } else {
      bytes = base64Decode(imageStr);
    }

    // Try to decode as SVG text
    try {
      svgString = utf8.decode(bytes);
      // Validate it's SVG
      if (!svgString.trimLeft().startsWith('<svg')) {
        svgString = '';
      }
    } catch (_) {
      svgString = '';
    }

    return ArtGenerationResult(
      svgString: svgString,
      bytes: bytes,
      revisedPrompt: revisedPrompt,
    );
  }

  static String buildPrompt({
    required String culture, required String sunSign,
    required String moonSign, required String risingSign,
    String? userDescription, String? birthDate, String? birthPlace,
  }) {
    final buf = StringBuffer()
      ..write('Astrological art for a $sunSign Sun, $moonSign Moon, $risingSign Rising')
      ..write(' in the $culture tradition');
    if (birthDate != null && birthPlace != null) {
      buf.write(', born $birthDate in $birthPlace');
    }
    if (userDescription != null && userDescription.isNotEmpty) {
      buf.write('. Vision: $userDescription');
    }
    buf.write('. Include zodiac symbols, celestial bodies, and sacred geometry');
    return buf.toString();
  }
}
