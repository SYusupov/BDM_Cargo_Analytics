package com.bdma.cargo.dao;

import com.bdma.cargo.entity.Users;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UsersDao extends CrudRepository<Users, Long> {

}