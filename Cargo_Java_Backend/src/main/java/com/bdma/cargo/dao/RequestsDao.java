package com.bdma.cargo.dao;

import com.bdma.cargo.entity.Requests;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RequestsDao extends CrudRepository<Requests, Long> {

    List<Requests> getAllByInitializationuserid(Long id);
}