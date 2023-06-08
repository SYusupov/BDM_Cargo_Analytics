import 'dart:convert';
import 'dart:ffi';
import 'package:http/http.dart' as http;
import 'package:decimal/decimal.dart';
import 'addressModel.dart';

class RequestsModel {
  String id;
  String initializationUserId;
  String collectionUserId;
  String travellerId;
  String productId;
  Decimal weight;
  String dateToDeliver;
  AddressModel pickUpAddress;
  AddressModel collectionAddress;
  Decimal deliveryFees;

  RequestsModel({
    required this.id,
    required this.initializationUserId,
    required this.collectionUserId,
    required this.travellerId,
    required this.productId,
    required this.weight,
    required this.dateToDeliver,
    required this.pickUpAddress,
    required this.collectionAddress,
    required this.deliveryFees,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'initializationUserId': initializationUserId,
      'collectionUserId': collectionUserId,
      'travellerId': travellerId,
      'productId': productId,
      'weight': weight.toString(),
      'dateToDeliver': dateToDeliver,
      'pickUpAddress': pickUpAddress.toJson(),
      'collectionAddress': collectionAddress.toJson(),
      'deliveryFees': deliveryFees.toString(),
    };
  }

  factory RequestsModel.fromJson(Map<String, dynamic> json) {
    return RequestsModel(
      id: json['id'],
      initializationUserId: json['initializationUserId'],
      collectionUserId: json['collectionUserId'],
      travellerId: '',
      productId: json['productId'],
      weight: Decimal.parse(json['weight']),
      dateToDeliver: json['dateToDeliver'],
      pickUpAddress: AddressModel.fromJson(json['pickUpAddress']),
      collectionAddress: AddressModel.fromJson(json['collectionAddress']),
      deliveryFees: Decimal.parse(json['deliveryFees'].toString()),
    );
  }

  Future<void> sendPostRequest() async {
    final url = 'http://localhost:9090/requests/create';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(toJson());

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
      } else {
        // Request failed
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
  }

  Future<List<RequestsModel>?> getRequests() async {
    final url = 'http://localhost:9090/requests';
    final headers = {'Content-Type': 'application/json'};
    List<RequestsModel>? objects;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
        final List<dynamic> jsonResponse = json.decode(response.body);
        objects = jsonResponse.map((data) => RequestsModel.fromJson(data)).toList();
        return objects;
      } else {
        // Request failed
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
    return objects ?? [];
  }

  Future<List<RequestsModel>?> getRequestsByUserID(String userID) async {
    final url = 'http://localhost:9090/requests/by/id';
    final headers = {'Content-Type': 'application/json'};

    List<RequestsModel>? objects;
    try {
      var getURL = Uri.parse('$url?initUserId=$userID');
      final response = await http.get(getURL, headers: headers);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
        final List<dynamic> jsonResponse = json.decode(response.body);
        objects = jsonResponse.map((data) => RequestsModel.fromJson(data)).toList();
        return objects;
      } else {
        // Request failed
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
    return objects ?? [];
  }

  Future<List<RequestsModel>?> getNotSelectedRequests() async {
    final url = 'http://localhost:9090/requests/not/selected';
    final headers = {'Content-Type': 'application/json'};

    List<RequestsModel>? objects;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
        final List<dynamic> jsonResponse = json.decode(response.body);
        objects = jsonResponse.map((data) => RequestsModel.fromJson(data)).toList();
        return objects;
      } else {
        // Request failed
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
    return objects ?? [];
  }

  Future<List<RequestsModel>?> getRecommendedRequests() async {
    final url = 'http://localhost:9090/requests/recommended';
    final headers = {'Content-Type': 'application/json'};

    List<RequestsModel>? objects;
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
        final List<dynamic> jsonResponse = json.decode(response.body);
        objects = jsonResponse.map((data) => RequestsModel.fromJson(data)).toList();
        return objects;
      } else {
        // Request failed
        print('Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
    return objects ?? [];
  }
}


