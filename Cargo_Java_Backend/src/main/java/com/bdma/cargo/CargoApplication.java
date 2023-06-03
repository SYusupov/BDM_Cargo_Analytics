package com.bdma.cargo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EntityScan(basePackages = "com.bdma.cargo.entity")
@Configuration
@EnableJpaRepositories(basePackages = "com.bdma.cargo.dao")
public class CargoApplication {

	public static void main(String[] args) {
		SpringApplication.run(CargoApplication.class, args);
	}

}
