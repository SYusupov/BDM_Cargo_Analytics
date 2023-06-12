import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'City.dart';
import 'Product.dart';
import 'addressModel.dart';

class RequestFormPage extends StatefulWidget {
  @override
  _RequestFormPageState createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
  bool isVisible = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String initializationUserId = "1";
  late String collectionUserId;
  late String productId;
  late int weight;
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
  double deliveryFees = 0.0;
  List<int> distances = [500, 600, 750];
  Random random = Random();

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
                    weight = value.weight;
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
                  labelText: 'Date To Be Delivered (DD/MM/YYYY)',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    // if (_formKey.currentState!.validate()) {
                    //   _formKey.currentState!.save();
                      // Call a function to submit the form data
                      sendGetPrediction();
                    // }
                  });
                },
                child: Text('Calculate'),
              ),
              Visibility(
                visible: isVisible,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Fees in Euro'
                        ),
                        initialValue: '$deliveryFees',
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter fees in euro';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          deliveryFees = double.parse(value!);
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            // Call a function to submit the form data
                            printForm();
                            sendPostRequest();
                            Navigator.pop(context);
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
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

  Map<String, dynamic> toPredictionJson() {
    return {
      'features': [pickUpAddress.city != collectionAddress.city ? distances[random.nextInt(2)] : 0,
        42.8572, 42.3948, 56.2964, weight, 27.0, 19.0, 20.0, 17.05]
    };
  }

  Future<void> sendGetPrediction() async {
    final url = 'http://127.0.0.1:5000/predict';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(toPredictionJson());

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
        var responseBody = json.decode(response.body);
        deliveryFees = responseBody['prediction'];
        print(deliveryFees);
        setState(() {
          isVisible = true;
        });
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

