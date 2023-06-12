import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:test_project/addressModel.dart';
import 'package:test_project/requestmodel.dart';

import 'RequestsForm.dart';

class RequestsListPage extends StatefulWidget {
  @override
  _RequestsListPageState createState() => _RequestsListPageState();
}

class _RequestsListPageState extends State<RequestsListPage> {
  List<RequestsModel> requestListAccepted = [];
  List<RequestsModel> requestListAvailable = [];
  List<RequestsModel> requestListRecommended = [];

  int currentIndex = 0;
  int currentIndexRecommended = 0;
  int currentIndexAccepted = 0;
  bool isButtonVisibleAccepted = false;
  bool isVisibleAccepted = false;
  bool isButtonVisibleAvailable = false;
  bool isButtonVisibleRecommended = false;

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
        weight: Decimal.parse("0"),
        dateToDeliver: '',
        pickUpAddress: newAddress(),
        collectionAddress: newAddress(),
        deliveryFees: Decimal.parse("0"));
    requestsModel.getNotSelectedRequests().then((List<RequestsModel>? requests) {
      if (requests != null) {
        setState(() {
          requestListAvailable = requests;
        });
      }
    });
    requestsModel.getRecommendedRequests().then((List<RequestsModel>? requests) {
      if (requests != null) {
        setState(() {
          requestListRecommended = requests;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: Column(
        children: [
        Visibility(
        visible: isVisibleAccepted,
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Accepted Requests',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      Visibility(
        visible: isVisibleAccepted,
          child: Expanded(
            child: PageView.builder(
              itemCount: requestListAccepted.length,
              controller: PageController(
                initialPage: currentIndexAccepted,
                viewportFraction:
                0.8, // Adjust the visible fraction of each item
              ),
              onPageChanged: (index) {
                setState(() {
                  currentIndexAccepted = index;
                });
              },
              itemBuilder: (context, index) {
                RequestsModel request = requestListAccepted[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isButtonVisibleAccepted = !isButtonVisibleAccepted;
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(request.productId),
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
      ),
          Visibility(
            visible: isButtonVisibleAccepted,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    requestListAccepted.removeAt(currentIndexAccepted);
                    isVisibleAccepted = requestListAccepted.isNotEmpty;
                    isButtonVisibleAccepted = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Remove'),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Available Requests',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: requestListAvailable.length,
              controller: PageController(
                initialPage: currentIndex,
                viewportFraction:
                    0.8, // Adjust the visible fraction of each item
              ),
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  isButtonVisibleAvailable =
                      false; // Reset button visibility on page change
                });
              },
              itemBuilder: (context, index) {
                RequestsModel request = requestListAvailable[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isButtonVisibleAvailable = !isButtonVisibleAvailable;
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(request.productId),
                        subtitle: Text('From: ${request.pickUpAddress.city} \n'
                            'to: ${request.collectionAddress.city}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: isButtonVisibleAvailable,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    requestListAccepted.add(requestListAvailable[currentIndex]);
                    isVisibleAccepted = requestListAccepted.isNotEmpty;
                    requestListAvailable.removeAt(currentIndex);
                    isButtonVisibleAvailable = false;
                  });
                },
                child: Text('Accept'),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Recommended Requests',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: requestListRecommended.length,
              controller: PageController(
                initialPage: currentIndexRecommended,
                viewportFraction:
                    0.8, // Adjust the visible fraction of each item
              ),
              onPageChanged: (index) {
                setState(() {
                  currentIndexRecommended = index;
                  isButtonVisibleRecommended =
                      false; // Reset button visibility on page change
                });
              },
              itemBuilder: (context, index) {
                RequestsModel request = requestListRecommended[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isButtonVisibleRecommended =
                            !isButtonVisibleRecommended;
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(request.productId),
                        subtitle: Text('From: ${request.pickUpAddress.city} \n'
                            'to: ${request.collectionAddress.city}'),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: isButtonVisibleRecommended,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    requestListAccepted.add(requestListRecommended[currentIndexRecommended]);
                    isVisibleAccepted = requestListAccepted.isNotEmpty;
                    requestListRecommended.removeAt(currentIndexRecommended);
                    isButtonVisibleRecommended = false;
                  });
                },
                child: Text('Accept'),
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
              child: Text('Add Request'),
            ),
          ),
        ],
      ),
    );
  }
}
