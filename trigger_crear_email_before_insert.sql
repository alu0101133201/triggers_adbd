CREATE DEFINER=`sergio`@`localhost` TRIGGER `viveros`.`trigger_crear_email_before_insert` BEFORE INSERT ON `Cliente` FOR EACH ROW
BEGIN
	if NEW.email  IS NULL THEN
    	CALL crear_email(NEW.DNI, 'gmail.com', @email);
		SET NEW.email = @email;
	END IF;
END