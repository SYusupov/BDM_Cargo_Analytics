package com.bdma.cargo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.Entity;
import javax.persistence.Id;
import java.io.Serializable;

@Entity
@Setter
@Getter
public class Requests implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    Long id;
    Long initializationuserid;
    Long collectionuserid;
    Double travellerid;
    String productid;
    String datetodeliver;
    String datedelivered;
    String requestdate;
    Long pickupaddress;
    Long collectionaddress;
    Double description;
    Double deliveryfee;

}
