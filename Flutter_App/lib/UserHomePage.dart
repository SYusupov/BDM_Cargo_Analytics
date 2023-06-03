import 'package:flutter/material.dart';
import 'package:test_project/addressModel.dart';
import 'package:test_project/requestmodel.dart';

import 'RequestsForm.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  List<RequestsModel> requestList = [];
  int currentIndex = 0;
  bool isButtonVisible = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  AddressModel newAddress() {
    return AddressModel(
        id: '',
        city: '',
        country: '',
        postalCode: '',
        streetName: '',
        streetNumber: '',
        buildingNumber: '',
        provence: '');
  }

  void fetchData() {
    RequestsModel requestsModel = RequestsModel(
        id: '',
        initializationUserId: '',
        collectionUserId: '',
        travellerId: '',
        productId: '',
        weight: BigInt.zero,
        dateToDeliver: '',
        pickUpAddress: newAddress(),
        collectionAddress: newAddress(),
        description: '',
        deliveryFees: BigInt.zero);
    requestsModel.getRequests().then((List<RequestsModel>? requests) {
      if (requests != null) {
        setState(() {
          requestList = requests;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Your Requests',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: requestList.length,
              controller: PageController(
                initialPage: currentIndex,
                viewportFraction:
                    0.8, // Adjust the visible fraction of each item
              ),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  isButtonVisible =
                      false; // Reset button visibility on page change
                });
              },
              itemBuilder: (context, index) {
                RequestsModel request = requestList[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isButtonVisible = !isButtonVisible;
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('${request.productId}\n'
                            '${request.description}'),
                        subtitle: Text('From: ${request.pickUpAddress.city} \n'
                            'to: ${request.collectionAddress.city}\n'
                            'weight: ${request.weight}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: isButtonVisible,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  requestList.removeAt(currentIndex);
                  // Button action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Delete'),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RequestFormPage(),
                  ),
                );
              },
              child: Text('Add New Request'),
            ),
          ),
        ],
      ),
    );
  }
}
