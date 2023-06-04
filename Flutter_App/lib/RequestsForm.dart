import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_project/requestsList.dart';

import 'City.dart';
import 'Product.dart';
import 'addressModel.dart';

class RequestFormPage extends StatefulWidget {
  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String initializationUserId = "1";
  late String collectionUserId;
  late String productId;
  late BigInt weight;
  late String dateToDeliver;
  late AddressModel pickUpAddress = AddressModel(
      id: null,
      city: 'city',
      country: 'Spain',
      postalCode: '12345',
      streetName: 'testSt.',
      streetNumber: '11',
      buildingNumber: '22',
      provence: 'testPR.');
  late AddressModel collectionAddress = AddressModel(
      id: null,
      city: 'city',
      country: 'Spain',
      postalCode: '54321',
      streetName: 'testSt.',
      streetNumber: '44',
      buildingNumber: '55',
      provence: 'testPR.');
  late String description;
  late BigInt deliveryFees;

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text('New Request'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Collection User ID'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the collector user ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  collectionUserId = value!;
                },
              ),
              DropdownButtonFormField<Product>(
                onChanged: (value) {
                  setState(() {
                    productId = value!.id;
                  });
                },
                items: productList.map((Product product) {
                  return DropdownMenuItem<Product>(
                    value: product,
                    child: Text(product.name),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select a product',
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Weight in Grams'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter weight in grams';
                  }
                  return "0";
                },
                onSaved: (value) {
                  weight = BigInt.parse(value!);
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the description';
                  }
                  return null;
                },
                onSaved: (value) {
                  description = value!;
                },
              ),
              DropdownButtonFormField<City>(
                onChanged: (value) {
                  setState(() {
                    pickUpAddress.id = value!.id;
                    pickUpAddress.city = value.name;
                  });
                },
                items: citiesList.map((City city) {
                  return DropdownMenuItem<City>(
                    value: city,
                    child: Text(city.name),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select the drop office',
                ),
              ),
              DropdownButtonFormField<City>(
                onChanged: (value) {
                  setState(() {
                    collectionAddress.id = value!.id;
                    collectionAddress.city = value.name;
                  });
                },
                items: citiesList.map((City city) {
                  return DropdownMenuItem<City>(
                    value: city,
                    child: Text(city.name),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select the pick up office',
                ),
              ),
              TextFormField(
                controller: _controller,
                maxLength: 10,
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  DateInputFormatter(),
                ],
                validator: (value) {
                  if (value!.isEmpty || value.length < 10) {
                    return 'Please enter a valid date of birth';
                  }
                  return null;
                },
                onSaved: (value) {
                  dateToDeliver = value!;
                },
                decoration: InputDecoration(
                  labelText: 'Date of Birth (DD/MM/YYYY)',
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Fees in Euro'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter fees in euro';
                  }
                  return "0";
                },
                onSaved: (value) {
                  deliveryFees = BigInt.parse(value!);
                },
              ),
              // Add more form fields for the remaining fields
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Call a function to submit the form data
                    printForm();
                    sendPostRequest();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RequestsListPage(),
                      ),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': null,
      'initializationUserId': initializationUserId,
      'collectionUserId': collectionUserId,
      'travellerId': null,
      'productId': productId,
      'weight': weight,
      'dateToDeliver': dateToDeliver,
      'pickUpAddress': pickUpAddress.toJson(),
      'collectionAddress': collectionAddress.toJson(),
      'description': description,
      'deliveryFees': deliveryFees,
    };
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

  void printForm() {
    // Perform actions with the form data (e.g., send data to backend)
    // Access the form field values using the instance variables
    print('initializationUserId: $initializationUserId');
    print('collectionUserId: $collectionUserId');
    print('productId: $productId');
    print('weight: $weight');
    print('dateToDeliver: $dateToDeliver');
    print('pickUpAddress: $pickUpAddress');
    print('collectionAddress: $collectionAddress');
    print('description: $description');
    print('deliveryFees: $deliveryFees');
    // Print the remaining field values
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();

    if (newTextLength >= 1) {
      newText.write(newValue.text.substring(0, usedSubstringIndex = 2) + '/');
      if (newValue.selection.end >= 2) selectionIndex++;
    }
    if (newTextLength >= 3) {
      newText.write(newValue.text.substring(2, usedSubstringIndex = 4) + '/');
      if (newValue.selection.end >= 4) selectionIndex++;
    }
    if (newTextLength >= 5) {
      newText.write(newValue.text.substring(4, usedSubstringIndex = 8));
      if (newValue.selection.end >= 8) selectionIndex++;
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

