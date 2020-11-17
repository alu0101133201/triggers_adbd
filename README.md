# Práctica triggers - ADBD
### Sergio Guerra Arencibia - ULL  

# 1.- Dada la base de dato de viveros:
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
