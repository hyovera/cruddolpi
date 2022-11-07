-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-11-2022 a las 22:15:04
-- Versión del servidor: 10.4.24-MariaDB
-- Versión de PHP: 8.0.19

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_trabajando`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Actualizar_Empleado` (IN `_id` INT, IN `_nombre` VARCHAR(30), IN `_edad` INT)   begin
DECLARE registro INT;
 set  registro = (select count(*) from trabajado  where id=_id);
 
 	if (registro =1) then
     UPDATE `trabajado` SET `nombre` = _nombre, `edad` = _edad, `fechaActualizacion` = now() WHERE `trabajado`.`id` = _id;
     
    select "Actaulizado" as 'Mensaje';
    else
	select "No encontrado" as 'Mensaje';
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Eliminar_Empleado` (IN `_id` INT)   begin
DECLARE registro INT;
 set  registro = (select count(*) from trabajado  where id=_id);
 
 	if (registro =1) then
    DELETE FROM trabajado WHERE `trabajado`.`id` = _id;
     
    select "Eliminado" as 'Mensaje';
    else
	select "No encontrado" as 'Mensaje';
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Registra_Empleado` (IN `_dni` VARCHAR(8), IN `_nombre` VARCHAR(30), IN `_edad` INT)   begin
DECLARE registro INT;
 set  registro = (select  count(*)  from trabajado where dni=_dni);
 
 	if (registro =0) then
    INSERT INTO trabajado ( dni, nombre, edad, fechaRegistro, fechaActualizacion) 
    VALUES (_dni , _nombre, _edad, now(), '');
    select "Registro correcto" as 'Mensaje';
    else
	select "Ya registrado" as 'Mensaje';
end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `trabajado`
--

CREATE TABLE `trabajado` (
  `id` int(11) NOT NULL,
  `dni` varchar(8) NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `edad` int(11) NOT NULL,
  `fechaRegistro` datetime NOT NULL,
  `fechaActualizacion` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Volcado de datos para la tabla `trabajado`
--

INSERT INTO `trabajado` (`id`, `dni`, `nombre`, `edad`, `fechaRegistro`, `fechaActualizacion`) VALUES
(1, '12345678', 'rrrrr', 36, '2022-11-07 17:48:55', '2022-11-07 15:28:07'),
(2, '78547588', 'gggg', 28, '2022-11-07 13:52:37', '2022-11-07 16:13:42'),
(4, '12414744', 'rrrr', 36, '2022-11-07 14:04:30', '2022-11-07 16:13:33');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `trabajado`
--
ALTER TABLE `trabajado`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `trabajado`
--
ALTER TABLE `trabajado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
