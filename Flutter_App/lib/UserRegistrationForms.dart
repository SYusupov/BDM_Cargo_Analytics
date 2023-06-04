import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_project/requestsList.dart';

import 'addressModel.dart';

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String firstname;
  late String lastname;
  late String gender = "M";
  late String mobileNumber;
  late String email;
  late String nationality;
  late AddressModel address = AddressModel(
      id: null,
      city: 'city',
      country: 'Spain',
      postalCode: 'postalCode',
      streetName: 'streetName',
      streetNumber: 'streetNumber',
      buildingNumber: 'buildingNumber',
      provence: 'provence');
  late bool isTraveller = false;
  late String dob;

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text('User Registration'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
                onSaved: (value) {
                  firstname = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
                onSaved: (value) {
                  lastname = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Gender'),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text("M"),
                      value: "Male",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title: Text("F"),
                      value: "Female",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() {
                          gender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: InputDecoration(labelText: 'Mobile Number'),
                validator: (value) {
                  if (value!.isEmpty || value.length < 9) {
                    return 'Please enter a valid spanish mobile number';
                  }
                  return null;
                },
                onSaved: (value) {
                  mobileNumber = "+34${value!}";
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      onChanged: (value) {
                        setState(() {
                          nationality = value!;
                        });
                      },
                      items: getEUCountries().map((country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(country),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select a nationality',
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
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
                        dob = value!;
                      },
                      decoration: InputDecoration(
                        labelText: 'Date of Birth (DD/MM/YYYY)',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('register as Traveller also'),
                  ),
                  Expanded(
                    child: Checkbox(
                      value: isTraveller,
                      onChanged: (value) {
                        setState(() {
                          isTraveller = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Text('Address'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Street Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your street name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address.streetName = value!;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: InputDecoration(labelText: 'Street Number'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid street number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address.streetNumber = value!;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      decoration: InputDecoration(labelText: 'Building Number'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a valid building number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address.buildingNumber = value!;
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      onChanged: (value) {
                        setState(() {
                          address.city = value!;
                        });
                      },
                      items: getCities().map((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Select your city',
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Provence'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your provence';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address.provence = value!;
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      decoration: InputDecoration(labelText: 'Postal Code'),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 5) {
                          return 'Please enter a valid postal code';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        address.postalCode = value!;
                      },
                    ),
                  ),
                ],
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
      'firstname': firstname,
      'lastname': lastname,
      'gender': gender,
      'mobileNumber': mobileNumber,
      'email': email,
      'nationality': nationality,
      'address': address.toJson(),
      'isTraveller': isTraveller,
      'dob': dob,
    };
  }

  Future<void> sendPostRequest() async {
    final url = 'http://localhost:9090/users/create';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(toJson());

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Request successful
        print('Post request sent successfully');
      } else {
        // Request failed
        print(
            'Failed to send post request. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Exception occurred during the request
      print('Error sending post request: $error');
    }
  }

  void printForm() {
    // Perform actions with the form data (e.g., send data to backend)
    // Access the form field values using the instance variables
    print('First Name: $firstname');
    print('Last Name: $lastname');
    print('Gender: $gender');
    print('Mobile number: $mobileNumber');
    print('Email: $email');
    print('Nationality: $nationality');
    print('DoB: $dob');
    print('is Traveller: $isTraveller');
    print('address: $address');
    // Print the remaining field values
  }

  List<String> getEUCountries() {
    return [
      'Austria',
      'Belgium',
      'Bulgaria',
      'Croatia',
      'Cyprus',
      'Czech Republic',
      'Denmark',
      'Estonia',
      'Finland',
      'France',
      'Germany',
      'Greece',
      'Hungary',
      'Ireland',
      'Italy',
      'Latvia',
      'Lithuania',
      'Luxembourg',
      'Malta',
      'Netherlands',
      'Poland',
      'Portugal',
      'Romania',
      'Slovakia',
      'Slovenia',
      'Spain',
      'Sweden',
    ];
  }

  List<String> getCities() {
    return [
      'Barcelona',
      'Palma',
      'Madrid',
      'Málaga',
    ];
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

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
      ),
      body: Center(
        child: Text('This is the next page'),
      ),
    );
  }
}

// void main() {
//   runApp(MaterialApp(
//     home: FormPage(),
//   ));
// }
