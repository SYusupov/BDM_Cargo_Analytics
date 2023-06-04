package com.bdma.cargo.entity;

import lombok.Getter;
import lombok.Setter;

import javax.persistence.Entity;
import javax.persistence.Id;
import java.io.Serializable;

@Entity
@Setter
@Getter
public class Users implements Serializable {
    private static final long serialVersionUID = 1L;

    @Id
    Long user_id;
    Long address;
    String gender;
    String city;
    String nationality;
    String is_traveller;
    String dob;

}
