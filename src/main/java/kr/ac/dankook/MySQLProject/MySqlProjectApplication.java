package kr.ac.dankook.MySQLProject;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
public class MySqlProjectApplication {

	public static void main(String[] args) {
		SpringApplication.run(MySqlProjectApplication.class, args);
	}

}
