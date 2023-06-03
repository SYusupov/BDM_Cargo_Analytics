package com.bdma.cargo.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AddressModel {

    String id;
    String country;
    String city;
    String postalCode;
    String streetName;
    String streetNumber;
    String buildingNumber;
    String provence;

}
