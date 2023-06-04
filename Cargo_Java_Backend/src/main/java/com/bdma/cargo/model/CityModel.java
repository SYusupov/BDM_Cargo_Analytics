package com.bdma.cargo.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CityModel {

    private long id;
    private String name;
    private String country;
    double latitude;
    double longitude;

}
