
import 'package:test_project/requestmodel.dart';

import 'addressModel.dart';


class Functions {

  void sendRequest() {
    final request = RequestsModel(
      id: '1',
      initializationUserId: 'user1',
      collectionUserId: 'user2',
      travellerId: 'user3',
      productId: 'product1',
      weight: BigInt.from(10),
      dateToDeliver: '2023-05-23',
      pickUpAddress: AddressModel(
          id: '34',
          postalCode: '12356',
          streetName: 'Street',
          streetNumber: '123',
          buildingNumber: '1',
          provence: 'provence1',
          city: 'City1',
          country: 'Country1'),
      collectionAddress: AddressModel(
          id: '12',
          postalCode: '12456',
          streetName: 'Street',
          streetNumber: '456',
          buildingNumber: '4',
          provence: 'provence2',
          city: 'City2',
          country: 'Country2'),
      description: 'Sample request',
      deliveryFees: BigInt.from(20),
    );

    request.sendPostRequest();
  }

}