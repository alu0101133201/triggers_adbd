# Práctica triggers - ADBD
## Sergio Guerra Arencibia - ULL  

### 1.- Dada la base de dato de viveros:
 Crear un procedimiento: crear_email devuelva una dirección de correo electrónico con el siguiente formato:
  - Un conjunto de caracteres del nombe y/o apellidos
  - El carácter @.
  - El dominio pasado como parámetro.
  
Para este primer punto, se crea el siguiente procedimiento 

```sql
  CREATE DEFINER=`sergio`@`localhost` PROCEDURE `crear_email`(IN dni INT,IN dom VARCHAR(15), OUT email VARCHAR(50))
  BEGIN
      SET email = CONCAT(dni, "@");
      SET email = CONCAT(email, dom);
  END
```  
  
Como vemos, este sencillo código concatena el dni del cliente, con un arroba y un dominio que recibe como parámetro.  
Al ser un trigger, no hay ningún valor que devolver así que uno de los parámetros está definido como salida. Colocamos el
email ahí y desde el exterior se podrá acceder a el.  

Si lo probamos obtenemos un resultado correcto. Ante la entrada siguiente:  
```sql
  CALL crear_email(11111, 'gmail.com', @email);
  select @email;
```  
Obtenemos el email 11111@gmail.com, guardado en la variable @email.

### Una vez creada la tabla escriba un trigger con las siguientes características:
  -Trigger: trigger_crear_email_before_insert
  -Se ejecuta sobre la tabla clientes.
  -Se ejecuta antes de una operación de inserción.
  -Si el nuevo valor del email que se quiere insertar es NULL, entonces se le creará automáticamente una dirección de email y se insertará en la tabla.
  -Si el nuevo valor del email no es NULL se guardará en la tabla el valor del email.  
    
Este trigger comprueba si el dato que se intenta insertar contiene ya un email. Si es así, no se hace nada, pero, si no contiene un email, se llama al 
procedimiento del punto anterior y se asigna.    

```sql
  CREATE DEFINER=`sergio`@`localhost` TRIGGER `viveros`.`trigger_crear_email_before_insert` BEFORE INSERT ON `Cliente` FOR EACH ROW
  BEGIN
   if NEW.email  IS NULL THEN
    CALL crear_email(NEW.DNI, 'gmail.com', @email);
    SET NEW.email = @email;
   END IF;
  END
```    
  
Lo probamos con las entradas siguientes:  
```sql  
   INSERT INTO Cliente VALUES (51151151, 00000000, 1, null);
   INSERT INTO Cliente VALUES (2222, 0, 2, 'test@gmail.com');
```

Y si mostramos la tabla vemos que funciona correctamente  

![alt_text](https://github.com/alu0101133201/triggers_adbd/blob/main/images/email.png)  

### 2. Crear un trigger permita verificar que las personas en el Municipio del catastro no pueden vivir en dos viviendas diferentes.

La condición para saber si un usuario vive en dos viviendas diferentes, es que tenga tanto valores asignados a las columnas correspondientes a un piso,
como a las columnas correspondientes a una vivienda unifamiliar.  
Por tanto, si estas combinaciones de valores no son nulas, debemos rechazar la inserción y avisar de lo que ha pasado.  
En mi caso, un piso se identifica con cuatro valores y una vivienda unifamiliar con dos, así que el trigger nos queda de la siguiente forma:   

```sql  
  CREATE DEFINER=`sergio`@`localhost` TRIGGER `catastro`.`Persona_no_vive_en_dos_lugares` BEFORE INSERT ON `Persona` FOR EACH ROW
  BEGIN
   if ((NEW.Piso_Letra IS NOT NULL) AND (NEW.Piso_Planta IS NOT NULL) AND 
     (NEW.Piso_Bloque_Construccion_Calle IS NOT NULL) AND (NEW.Piso_Bloque_Construccion_Numero IS NOT NULL) AND
              (NEW.Unifamiliar_Construccion_Numero IS NOT NULL) AND (NEW.Unifamiliar_Construccion_Calle IS NOT NULL))
   THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Una persona no puede vivir en dos viviendas';
   END IF;
  END
```  
Esto nos impediría no introducir una fila errónea. Pero sí se podría introducir este error mediante una actualización, por tanto creamos un trigger similar pero que se ejecute antes de cada actualización, completando así la verificación pedida.   

Si probamos a introducir una persona que vive en dos viviendas vemos que salta un error.  

```sql
   INSERT INTO Persona VALUES ('pepe', 5555, null, null, 'A', 3, 'Viana', 0, 0, 'Anchieta', null);
```
![alt_text](https://github.com/alu0101133201/triggers_adbd/blob/main/images/errorViviendas.png)  

### 3. Crear el o los trigger que permitan mantener actualizado el stock de la base de dato de viveros.

Para mantener actualizado el stock de la base de datos, debemos controla cuándo se hace un pedido.  
Un pedido tendrá diferentes productos, que se verán reflejados como inserciones en al tabla que relaciona Pedidos y Productos (pedido_has_Producto).  
Por tanto añadimos un trigger a esta tabla, y cuando se intente insertar datos, reducimos la cantidad de stock del producto en la tabla Productos. Esto lo 
realizamos mediante un UPDATE.  
También se comprueba que queden elementos de los que se piden. Si no es así, se muestra un error avisando de que no hay producto en stock.

```sql
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
```
Con esta situación inicial, donde tenemos dos productos de los cuales uno está agotado, vamos a hacer las pruebas.  

![alt_text](https://github.com/alu0101133201/triggers_adbd/blob/main/images/inicial.png)  

Realizamos las siguientes acciones. Retiramos un elemento del que existe stock, y otro del que está agotado  

```sql
   INSERT INTO Pedido_has_Producto VALUES(5, 1, 1);
   INSERT INTO Pedido_has_Producto VALUES(6, 2, 1);
```
Como suponíamos, la segunda consulta da error  

![alt_text](https://github.com/alu0101133201/triggers_adbd/blob/main/images/errorStock.png)

Y la tabla finalmente queda como se muestra en la imagen

![alt_text](https://github.com/alu0101133201/triggers_adbd/blob/main/images/situacionFinal.png)




