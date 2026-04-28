import 'dart:convert';
import 'dart:io';

import 'package:budgetting_backend/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

/// GET /places/autocomplete?q={query}
///
/// Proxies to Google Places Autocomplete API and returns a trimmed list of
/// predictions. Keeps the API key server-side to avoid CORS and key exposure.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final query = context.request.uri.queryParameters['q'];
  if (query == null || query.trim().isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'q query parameter is required'},
    );
  }

  final apiKey = Config.placesApiKey;
  if (apiKey == null || apiKey.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Places API key not configured'},
    );
  }

  final url = Uri.https(
    'maps.googleapis.com',
    '/maps/api/place/autocomplete/json',
    {
      'input': query.trim(),
      'key': apiKey,
      'language': 'en-GB',
      'components': 'country:gb',
    },
  );

  final googleResponse = await http.get(url);

  if (googleResponse.statusCode != HttpStatus.ok) {
    return Response.json(
      statusCode: HttpStatus.badGateway,
      body: {'error': 'Upstream Places API error'},
    );
  }

  final data = jsonDecode(googleResponse.body) as Map<String, dynamic>;
  final predictions = (data['predictions'] as List<dynamic>? ?? [])
      .cast<Map<String, dynamic>>()
      .map(
        (p) => {
          'place_id': p['place_id'],
          'description': p['description'],
        },
      )
      .toList();

  return Response.json(body: {'predictions': predictions});
}
