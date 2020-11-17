DELIMITER //
CREATE PROCEDURE crear_email (IN dni INT,IN dom VARCHAR(15), INOUT email VARCHAR(50))
BEGIN
    SET email = CONCAT(dni, "@");
    SET email = CONCAT(email, dom);
END
//
DELIMITER ;