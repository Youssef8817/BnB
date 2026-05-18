import 'dart:convert';
import 'dart:io';
import 'package:b_and_b/constants.dart';
import 'package:b_and_b/models/user.dart';
import 'package:b_and_b/models/property.dart';
import 'package:b_and_b/models/worker_service.dart';
import 'package:b_and_b/models/service_request.dart';
import 'package:b_and_b/models/review.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'CF-Access-Client-Id': 'flutter-app',
      'User-Agent': 'BnBApp/1.0',
    };
  }

  static Future<dynamic> _handleResponse(http.Response response) async {
    final Map<String, dynamic> responseData = json.decode(response.body);
    if (responseData['success'] == true) {
      return responseData['data'];
    } else {
      final String message = responseData['message'] ?? 'Unknown error';
      throw Exception(message);
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/auth/login'),
      body: json.encode({
        'email': email,
        'password': password,
      }),
      headers: await _headers(),
    );
    return await _handleResponse(response);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String phone, String role) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/auth/register'),
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      }),
      headers: await _headers(),
    );
    return await _handleResponse(response);
  }

  static Future<void> logout() async {
    await http.post(
      Uri.parse('${Constants.baseUrl}/auth/logout'),
      headers: await _headers(),
    );
    // Clear token and user from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
  }

  static Future<User> getMe() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/me'),
      headers: await _headers(),
    );
    final Map<String, dynamic> data = (await _handleResponse(response)) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  static Future<List<Property>> getProperties({
    String? city,
    String? status,
    double? minPrice,
    double? maxPrice,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{};
    if (city != null && city.isNotEmpty) {
      queryParams['city'] = city;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }

    final uri = Uri.parse('${Constants.baseUrl}/properties');
    final uriWithQuery = uri.replace(queryParameters: queryParams);

    final response = await http.get(
      uriWithQuery,
      headers: await _headers(),
    );
    final dynamic raw = await _handleResponse(response);
    final List<dynamic> propertiesJson = raw is List
        ? raw
        : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  static Future<Property> getProperty(int id) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/properties/$id'),
      headers: await _headers(),
    );
    final Map<String, dynamic> data = (await _handleResponse(response)) as Map<String, dynamic>;
    return Property.fromJson(data);
  }

  static Future<Property> createProperty(Map<String, dynamic> data, List<File> images) async {
    final request = http.MultipartRequest('POST', Uri.parse('${Constants.baseUrl}/properties'));
    request.headers.addAll(await _headers());

    // Add the property fields
    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add the images
    for (var image in images) {
      request.files.add(
        await http.MultipartFile.fromPath('images[]', image.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return Property.fromJson(await _handleResponse(response));
  }

  static Future<void> updatePropertyStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/properties/$id/status'),
      body: json.encode({'status': status}),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<Property> updateProperty(int id, Map<String, dynamic> data, List<File> images) async {
    final request = http.MultipartRequest('PUT', Uri.parse('${Constants.baseUrl}/properties/$id'));
    request.headers.addAll(await _headers());

    data.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    for (final image in images) {
      request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return Property.fromJson(await _handleResponse(response));
  }

  static Future<List<WorkerService>> getWorkerServices() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/worker-services'),
      headers: await _headers(),
    );
    final dynamic raw = await _handleResponse(response);
    final List<dynamic> servicesJson = raw is List ? raw : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return servicesJson.map((json) => WorkerService.fromJson(json)).toList();
  }

  static Future<void> createWorkerService(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/worker-services'),
      body: json.encode(data),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<void> createServiceRequest(int workerServiceId, String note, String address) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/service-requests'),
      body: json.encode({
        'worker_service_id': workerServiceId,
        'note': note,
        'address': address,
      }),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<User> getUser(int id) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/users/$id'),
      headers: await _headers(),
    );
    final Map<String, dynamic> data = (await _handleResponse(response)) as Map<String, dynamic>;
    return User.fromJson(data);
  }

  // New methods for Plan 2

  static Future<List<Property>> getMyProperties() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/my-properties'),
      headers: await _headers(),
    );
    final dynamic raw = await _handleResponse(response);
    final List<dynamic> propertiesJson = raw is List
        ? raw
        : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return propertiesJson.map((json) => Property.fromJson(json)).toList();
  }

  static Future<void> deleteProperty(int id) async {
    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/properties/$id'),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<List<ServiceRequest>> getMyRequests() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/service-requests/mine'),
      headers: await _headers(),
    );
    final dynamic raw = await _handleResponse(response);
    final List<dynamic> requestsJson = raw is List ? raw : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return requestsJson.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  static Future<List<ServiceRequest>> getIncomingRequests() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/service-requests/incoming'),
      headers: await _headers(),
    );
    final dynamic raw = await _handleResponse(response);
    final List<dynamic> requestsJson = raw is List ? raw : (raw as Map<String, dynamic>)['data'] as List<dynamic>;
    return requestsJson.map((json) => ServiceRequest.fromJson(json)).toList();
  }

  static Future<void> updateRequestStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/service-requests/$id/status'),
      body: json.encode({
        'status': status,
      }),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<void> updateWorkerService(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/worker-services/$id'),
      body: json.encode(data),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<void> deleteWorkerService(int id) async {
    final response = await http.delete(
      Uri.parse('${Constants.baseUrl}/worker-services/$id'),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }

  static Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${Constants.baseUrl}/profile'),
      body: json.encode(data),
      headers: await _headers(),
    );
    final Map<String, dynamic> responseData = (await _handleResponse(response)) as Map<String, dynamic>;
    return User.fromJson(responseData);
  }

  static Future<Map<String, dynamic>> getAdminStats() async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/admin/stats'),
      headers: await _headers(),
    );
    return await _handleResponse(response);
  }

  static Future<WorkerService> getWorkerService(int id) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/worker-services/$id'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    return WorkerService.fromJson(data);
  }

  static Future<List<Review>> getServiceReviews(int serviceId) async {
    final response = await http.get(
      Uri.parse('${Constants.baseUrl}/worker-services/$serviceId/reviews'),
      headers: await _headers(),
    );
    final data = await _handleResponse(response);
    final List<dynamic> list = data is List ? data : (data['data'] ?? []);
    return list.map((j) => Review.fromJson(j)).toList();
  }

  static Future<void> submitReview(int serviceId, int rating, String comment) async {
    final response = await http.post(
      Uri.parse('${Constants.baseUrl}/worker-services/$serviceId/reviews'),
      body: json.encode({'rating': rating, 'comment': comment}),
      headers: await _headers(),
    );
    await _handleResponse(response);
  }
}