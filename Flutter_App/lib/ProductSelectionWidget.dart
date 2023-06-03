import 'package:flutter/material.dart';

import 'Product.dart';

class ProductSelectionWidget extends StatefulWidget {
  @override
  _ProductSelectionWidgetState createState() => _ProductSelectionWidgetState();
}

class _ProductSelectionWidgetState extends State<ProductSelectionWidget> {
  String? productId;

  void onProductChanged(Product? newValue) {
    setState(() {
      if (newValue != null) {
        productId = newValue.id;
      } else {
        productId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Product>(
      value: null, // Set initial value as null
      hint: Text('Select product'),
      items: productList.map((Product product) {
        return DropdownMenuItem<Product>(
          value: product,
          child: Text(product.name),
        );
      }).toList(),
      onChanged: onProductChanged,
      isExpanded: true,
      isDense: true,
    );
  }
}
