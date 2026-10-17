-- Reparacion del respaldo: solo las seis tablas de la tienda.
-- Para MySQL 8.0. Destino exclusivo: `abarrotes 2`.
-- Ejecutar UNA VEZ sobre una base nueva o vacia.
-- No ejecutar si `abarrotes 2` ya contiene tablas de la tienda.
-- No contiene DROP, objetos de sys ni configuracion GTID.
-- Conserva nombres de columnas y datos originales.
SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS `abarrotes 2`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `abarrotes 2`;


CREATE TABLE `proveedores` (
  `id_proveedor` int NOT NULL AUTO_INCREMENT,
  `correo` varchar(100) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(200) DEFAULT NULL,
  `fecha_creacon` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `producto` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `codigo_de_barras` varchar(50) DEFAULT NULL,
  `precio` decimal(10,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `venta` (
  `id_venta` int NOT NULL AUTO_INCREMENT,
  `total` decimal(10,2) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `compra` (
  `id_compra` int NOT NULL AUTO_INCREMENT,
  `id_proveedor` int NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_compra`),
  KEY `id_proveedor` (`id_proveedor`),
  CONSTRAINT `compra_ibfk_1` FOREIGN KEY (`id_proveedor`) REFERENCES `proveedores` (`id_proveedor`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detalle_compra` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_compra` int NOT NULL,
  `id_producto` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `cantidad` int NOT NULL,
  `fecha_creación` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_compra` (`id_compra`),
  KEY `id_producto` (`id_producto`),
  CONSTRAINT `detalle_compra_ibfk_1` FOREIGN KEY (`id_compra`) REFERENCES `compra` (`id_compra`),
  CONSTRAINT `detalle_compra_ibfk_2` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `detalle_venta` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_producto` int NOT NULL,
  `id_venta` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_modif` datetime DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `estatus` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_producto` (`id_producto`),
  KEY `id_venta` (`id_venta`),
  CONSTRAINT `detalle_venta_ibfk_1` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `detalle_venta_ibfk_2` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

START TRANSACTION;

INSERT INTO `proveedores` VALUES (1,'ventas@cocacola.com.mx','8181234567','Av. Universidad 100, San Nicolás, N.L.','2026-01-10 08:00:00',NULL,1),(2,'contacto@sabritas.com.mx','8183456789','Av. Constitución 400, Monterrey, N.L.','2026-01-10 08:30:00',NULL,1),(3,'pedidos@bimbo.com.mx','8189876543','Av. Industrial 250, Guadalupe, N.L.','2026-01-11 09:00:00',NULL,1),(4,'servicio@lala.com.mx','8187654321','Carretera a Apodaca Km 5, Apodaca, N.L.','2026-01-12 10:00:00',NULL,1),(5,'atencion@gamesa.com.mx','8181122334','Av. Nogalar 500, San Nicolás, N.L.','2026-01-15 11:00:00',NULL,1);

INSERT INTO `producto` VALUES (1,'Coca Cola Original 600ml','7501055300078',19.50,40,'2026-01-10 09:00:00','2026-10-16 14:44:39',1),(2,'Papas Sabritas Sal 45g','7501011115682',22.00,25,'2026-01-10 09:15:00','2026-10-16 14:44:50',1),(3,'Pan Blanco Bimbo Grande 680g','7501000111201',48.00,10,'2026-01-11 09:30:00','2026-10-16 14:44:58',1),(4,'Leche Lala Entera 1 Litro','7501020512345',27.50,20,'2026-01-12 10:30:00','2026-10-16 14:45:05',1),(5,'Galletas Marías Gamesa 170g','7501000300100',16.00,40,'2026-01-15 11:30:00',NULL,1);

INSERT INTO `venta` VALUES (1,41.50,'2026-10-01 08:15:00','2026-10-01 08:15:00',NULL,1),(2,75.50,'2026-10-01 09:30:00','2026-10-01 09:30:00',NULL,1),(3,35.50,'2026-10-01 11:00:00','2026-10-01 11:00:00',NULL,1),(4,67.00,'2026-10-02 14:20:00','2026-10-02 14:20:00',NULL,1),(5,96.00,'2026-10-02 18:45:00','2026-10-02 18:45:00',NULL,1),(6,156.00,'2026-10-16 14:44:39','2026-10-16 14:44:39',NULL,1),(7,110.00,'2026-10-16 14:44:50','2026-10-16 14:44:50',NULL,1),(8,240.00,'2026-10-16 14:44:58','2026-10-16 14:44:58',NULL,1),(9,110.00,'2026-10-16 14:45:05','2026-10-16 14:45:05',NULL,1);

INSERT INTO `compra` VALUES (1,1,'2026-09-20 07:00:00','2026-09-20 07:00:00',NULL,1),(2,2,'2026-09-21 08:30:00','2026-09-21 08:30:00',NULL,1),(3,3,'2026-09-22 06:45:00','2026-09-22 06:45:00',NULL,1),(4,4,'2026-09-23 09:15:00','2026-09-23 09:15:00',NULL,1),(5,5,'2026-09-24 10:00:00','2026-09-24 10:00:00',NULL,1);

INSERT INTO `detalle_compra` VALUES (1,1,1,14.50,120,'2026-09-20 07:00:00',NULL,1),(2,2,2,16.00,60,'2026-09-21 08:30:00',NULL,1),(3,3,3,38.00,30,'2026-09-22 06:45:00',NULL,1),(4,4,4,21.00,48,'2026-09-23 09:15:00',NULL,1),(5,5,5,11.50,80,'2026-09-24 10:00:00',NULL,1);

INSERT INTO `detalle_venta` VALUES (1,1,1,1,19.50,'2026-10-01 08:15:00',NULL,1),(2,2,1,1,22.00,'2026-10-01 08:15:00',NULL,1),(3,3,2,1,48.00,'2026-10-01 09:30:00',NULL,1),(4,4,2,1,27.50,'2026-10-01 09:30:00',NULL,1),(5,1,3,1,19.50,'2026-10-01 11:00:00',NULL,1),(6,5,3,1,16.00,'2026-10-01 11:00:00',NULL,1),(7,2,4,1,22.00,'2026-10-02 14:20:00',NULL,1),(8,4,4,1,27.50,'2026-10-02 14:20:00',NULL,1),(9,5,4,1,16.00,'2026-10-02 14:20:00',NULL,1),(10,3,5,2,48.00,'2026-10-02 18:45:00',NULL,1),(11,1,6,8,19.50,'2026-10-16 14:44:39',NULL,1),(12,2,7,5,22.00,'2026-10-16 14:44:50',NULL,1),(13,3,8,5,48.00,'2026-10-16 14:44:58',NULL,1),(14,4,9,4,27.50,'2026-10-16 14:45:05',NULL,1);

COMMIT;

SELECT 'producto' AS tabla, COUNT(*) AS registros FROM producto
UNION ALL SELECT 'proveedores', COUNT(*) FROM proveedores
UNION ALL SELECT 'venta', COUNT(*) FROM venta
UNION ALL SELECT 'compra', COUNT(*) FROM compra
UNION ALL SELECT 'detalle_venta', COUNT(*) FROM detalle_venta
UNION ALL SELECT 'detalle_compra', COUNT(*) FROM detalle_compra;
