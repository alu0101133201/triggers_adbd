CREATE DEFINER=`sergio`@`localhost` TRIGGER `viveros`.`Reducir_Stock` BEFORE INSERT ON `Pedido_has_Producto` FOR EACH ROW
BEGIN
	SET @nuevoStock = (SELECT Stock FROM Producto WHERE codigo = NEW.codigoProducto);
    SET @nuevoStock = (@nuevoStock - NEW.Cantidad);
    IF @nuevoStock < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay producto en stock para realizar el pedido';
	ELSE 
		UPDATE Producto SET Stock = @nuevoStock WHERE codigo = NEW.codigoProducto;
	END IF;
END