package com.bdma.cargo.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
public class GasModel {

    String currency;
    BigDecimal lpg;
    BigDecimal diesel;
    BigDecimal gasoline;
    String country;

}
