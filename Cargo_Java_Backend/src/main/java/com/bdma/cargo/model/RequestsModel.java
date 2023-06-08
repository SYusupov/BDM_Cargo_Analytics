package com.bdma.cargo.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.math.BigInteger;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RequestsModel {

    String id;
    String initializationUserId;
    String collectionUserId;
    String travellerId;
    String productId;
    String weight;
    String dateToDeliver;
    AddressModel pickUpAddress;
    AddressModel collectionAddress;
    BigDecimal deliveryFees;

}
