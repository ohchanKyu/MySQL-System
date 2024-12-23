DROP DATABASE IF EXISTS testdb;
CREATE DATABASE testdb;
USE testdb;

CREATE TABLE member (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NULL,
    phone_number VARCHAR(15) NULL,
    status ENUM('VALID', 'INVALID') DEFAULT 'VALID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE TABLE member_validation_log (
    id BIGINT NOT NULL AUTO_INCREMENT,
    member_id BIGINT NOT NULL,
    validation_result ENUM('INVALID', 'VALID') NOT NULL,
    validation_type ENUM('EMAIL', 'PHONE') NOT NULL,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (member_id) REFERENCES member(id) ON DELETE CASCADE
);


CREATE TABLE member_delete (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone_number VARCHAR(15),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE PROCEDURE validate_member_data()
BEGIN
       
    INSERT INTO member_validation_log (member_id, validation_type, validation_result, checked_at)
    SELECT id, 'EMAIL', 
           CASE WHEN email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN 'VALID' ELSE 'INVALID' END,
           NOW()
    FROM member
    WHERE email IS NOT NULL;

    INSERT INTO member_validation_log (member_id, validation_type, validation_result, checked_at)
    SELECT id, 'PHONE', 
           CASE WHEN phone_number REGEXP '^(01[016789]{1})-?[0-9]{3,4}-?[0-9]{4}$' THEN 'VALID' ELSE 'INVALID' END,
           NOW()
    FROM member
    WHERE phone_number IS NOT NULL;

    UPDATE member
    SET status = 'INVALID'
    WHERE id IN (
        SELECT member_id
        FROM member_validation_log
        WHERE validation_result = 'INVALID'
    );
    UPDATE member
    SET status = 'VALID'
    WHERE id NOT IN (
        SELECT member_id
        FROM member_validation_log
        WHERE validation_result = 'INVALID'
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_member_insert
BEFORE INSERT ON member
FOR EACH ROW
BEGIN
    IF NEW.email IS NOT NULL AND NOT (NEW.email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        SET NEW.status = 'INVALID';
    ELSEIF NEW.phone_number IS NOT NULL AND NOT (NEW.phone_number REGEXP '^(01[016789]{1})-?[0-9]{3,4}-?[0-9]{4}$') THEN
        SET NEW.status = 'INVALID';
    ELSE
        SET NEW.status = 'VALID';
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER before_member_update
BEFORE UPDATE ON member
FOR EACH ROW
BEGIN
    IF NEW.email IS NOT NULL AND NOT (NEW.email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        SET NEW.status = 'INVALID';
    ELSEIF NEW.phone_number IS NOT NULL AND NOT (NEW.phone_number REGEXP '^(01[016789]{1})-?[0-9]{3,4}-?[0-9]{4}$') THEN
        SET NEW.status = 'INVALID';
    ELSE
        SET NEW.status = 'VALID';
    END IF;
END $$

DELIMITER ;

DELIMITER $$

CREATE EVENT IF NOT EXISTS daily_member_validation_event
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    CALL validate_member_data();
END $$

DELIMITER ;

DELIMITER $$

CREATE EVENT IF NOT EXISTS cleanup_invalid_members
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    DELETE FROM member WHERE status = 'INVALID' AND created_at < NOW() - INTERVAL 30 DAY;
END $$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE generate_invalid_member_report()
BEGIN
    SELECT id, name, email, phone_number, status, created_at, updated_at
    FROM member
    WHERE status = 'INVALID';
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER before_member_delete
BEFORE DELETE ON member
FOR EACH ROW
BEGIN
    INSERT INTO member_delete (name, email, phone_number, deleted_at)
    VALUES (OLD.name, OLD.email, OLD.phone_number, CURRENT_TIMESTAMP);
    DELETE FROM member_validation_log WHERE member_id = OLD.id;
END $$

DELIMITER ;
