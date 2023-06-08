package com.bdma.cargo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Setter
@Getter
@Table(name = "requests")
public class Requests implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    @Column(name = "request_id")
    Long requestId;
    @Column(name = "initialization_user_id")
    Long initializationUserId;
    @Column(name = "collection_user_id")
    Long collectionUserId;
    @Column(name = "traveller_id")
    Double travellerId;
    @Column(name = "product_id")
    String productId;
    @Column(name = "date_to_deliver")
    String dateToDeliver;
    @Column(name = "date_delivered")
    String dateDelivered;
    @Column(name = "request_date")
    String requestDate;
    @Column(name = "pick_up_address")
    Long pickUpAddress;
    @Column(name = "collection_address")
    Long collectionAddress;
    @Column(name = "delivery_fee")
    Double deliveryFee;
    @Column(name = "dhl_fee")
    Double dhl_fee;
    @Column(name = "satisfactory")
    String satisfactory;

}
