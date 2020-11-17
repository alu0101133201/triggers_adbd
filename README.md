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
  
### 3. Crear el o los trigger que permitan mantener actualizado el stock de la base de dato de viveros.







