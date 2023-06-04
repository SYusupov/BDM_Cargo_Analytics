import 'package:flutter/material.dart';

import 'City.dart';

class CitySelectionWidget extends StatefulWidget {
  @override
  _CitySelectionWidgetState createState() => _CitySelectionWidgetState();
}

class _CitySelectionWidgetState extends State<CitySelectionWidget> {
  List<City> selectedCities = [];

  void onCityChanged(City? newValue) {
    setState(() {
      if (newValue != null) {
        if (!selectedCities.contains(newValue)) {
          selectedCities.add(newValue);
        }
        if (selectedCities.length > 2) {
          selectedCities.removeAt(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<City>(
      value: null, // Set initial value as null
      hint: Text('Select city'),
      items: citiesList.map((City product) {
        return DropdownMenuItem<City>(
          value: product,
          child: Text(product.name),
        );
      }).toList(),
      onChanged: onCityChanged,
      isExpanded: true,
      isDense: true,
    );
  }
}
