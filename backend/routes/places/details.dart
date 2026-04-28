import 'dart:convert';
import 'dart:io';

import 'package:budgetting_backend/config.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:http/http.dart' as http;

/// GET /places/details?place_id={id}
///
/// Proxies to Google Places Details API and returns the place name and
/// coordinates. Requesting only `name,geometry` uses the cheapest billing SKU.
Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final placeId = context.request.uri.queryParameters['place_id'];
  if (placeId == null || placeId.trim().isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'place_id query parameter is required'},
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
    '/maps/api/place/details/json',
    {
      'place_id': placeId.trim(),
      'key': apiKey,
      'fields': 'name,geometry',
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
  final result = data['result'] as Map<String, dynamic>?;

  if (result == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Place not found'},
    );
  }

  final location =
      ((result['geometry'] as Map<String, dynamic>)['location'])
          as Map<String, dynamic>;

  return Response.json(
    body: {
      'name': result['name'],
      'latitude': location['lat'],
      'longitude': location['lng'],
    },
  );
}
