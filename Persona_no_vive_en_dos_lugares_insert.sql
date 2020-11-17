CREATE DEFINER = CURRENT_USER TRIGGER `catastro`.`Persona_no_vive_en_dos_lugares` BEFORE INSERT ON `Persona` FOR EACH ROW
BEGIN
	if ((NEW.Piso_Letra IS NOT NULL) AND (NEW.Piso_Planta IS NOT NULL) AND 
			(Piso_Bloque_Construccion_Calle IS NOT NULL) AND (Piso_Bloque_Construccion_Numero IS NOT NULL) AND
            (Unifamiliar_Construccion_Numero IS NOT NULL) AND (Unifamiliar_Construccion_Calle IS NOT NULL))
	THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una persona no puede vivir en dos viviendas';
	END IF;
END
