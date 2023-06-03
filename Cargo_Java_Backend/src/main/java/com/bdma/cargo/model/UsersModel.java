package com.bdma.cargo.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class UsersModel {

    String id;
    String firstname;
    String lastname;
    String gender;
    String mobileNumber;
    String email;
    String nationality;
    AddressModel address;
    boolean isTraveller;
    String dob;

}
