
class AddressModel {
  late String id;
  String city;
  String country;
  String postalCode;
  String streetName;
  String streetNumber;
  String buildingNumber;
  String provence;

  AddressModel({
    required id,
    required this.city,
    required this.country,
    required this.postalCode,
    required this.streetName,
    required this.streetNumber,
    required this.buildingNumber,
    required this.provence,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streetName': streetName,
      'streetNumber': streetNumber,
      'buildingNumber': buildingNumber,
      'provence': provence,
      'postalCode': postalCode,
      'city': city,
      'country': country,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postalCode'],
      streetName: json['streetName'],
      streetNumber: json['streetNumber'],
      buildingNumber: json['buildingNumber'],
      provence: json['provence'],
    );
  }
}