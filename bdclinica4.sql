-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-11-2022 a las 14:59:47
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
-- Base de datos: `bdclinica4`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Cancelar_Atencion_Paciente` (IN `idaten` INT, IN `idmedi` INT, IN `idpaci` INT, IN `accion` CHAR(1))   BEGIN
DECLARE registro INT;
DECLARE validar INT;

set registro = (SELECT count(*) FROM `atencion` where idatencion=idaten and idmedico=idmedi);


	if (registro =0) then
		  select "No encotrado" as 'Mensaje';
	else
    set validar = (SELECT idestadosatencion FROM `atencion` where idatencion=idaten and idmedico=idmedi);
     if(validar=1) then
     
        UPDATE `atencion` SET `idestadosatencion` = '2' WHERE `atencion`.`idatencion` = idaten;
		INSERT INTO detalleatencion (`idatencion`, `idpaciente`, `fechahora`, `accion`, `idestadosatencion`, `hora`, `fecha`, `fechacreacion`,idtipo_usuario) 
		VALUES (idaten, idpaci, now(), 'Actualizar', '2', now(), now(), now(),1);
		select "Actalizado" as 'Mensaje';
     else
      select "Ya esta Actualizado" as 'Mensaje';
     end if;
    
	end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Registra_Atencion` (IN `fechaatencion` VARCHAR(100), IN `hora_ate` VARCHAR(30), IN `idhorario` INT, IN `idmedico` INT, IN `idpaciente` INT, IN `accion` CHAR(1))   BEGIN
DECLARE registro INT;
DECLARE hora time;
DECLARE horasegundos int;
declare estadocanselado int;
DECLARE estadofecha1 INT;
DECLARE estadofecha2 INT;
 set  estadofecha1 = (select count(*)   from  horario  where horainicio_hor <= time(hora_ate)  and idhorario=idhorario);
 set  estadofecha2=  (select count(*)  from  horario  where horafin_hor > time(hora_ate)  and idhorario=idhorario);
 
 if(estadofecha1 !=0 and estadofecha2 !=0 ) then 
  set registro = (select count(*) from atencion  as T 
inner join detalleatencion as D on T.idatencion=D.idatencion 
where T.fecha_ate=fechaatencion and  T.hora_ate=hora_ate and D.idpaciente=idpaciente);

	if (registro =0) then
     insert into atencion (estado_ate, fecha_ate, fechahora_ate, hora_ate, idhorario, idtipo_atencion, idmedico, fecharegistro, idestadosatencion, recomendacion) 
		  values ('1', fechaatencion, now(), hora_ate, idhorario, '1', idmedico, now(), '1', NULL);
		  set @Idatencion = (SELECT LAST_INSERT_ID());  
		  insert INTO detalleatencion ( idatencion, idpaciente, fechahora, accion, idestadosatencion, hora, fecha, fechacreacion,idtipo_usuario) 
		  VALUES (@Idatencion, idpaciente, now(), 'Registro', '1', hora_ate, fechaatencion, now(),1);
		  select "Registro correcto" as 'Mensaje';
	else
       set estadocanselado=(select  T.idestadosatencion from atencion  as T  inner join detalleatencion as D on T.idatencion=D.idatencion 
       where  T.fecha_ate=fechaatencion and  T.hora_ate=hora_ate and T.idestadosatencion=2 and D.idpaciente=idpaciente);
    -- validacion 
      if(registro =1 and estadocanselado=2) then 
       insert into atencion (estado_ate, fecha_ate, fechahora_ate, hora_ate, idhorario, idtipo_atencion, idmedico, fecharegistro, idestadosatencion, recomendacion) 
		  values ('1', fechaatencion, now(), hora_ate, idhorario, '1', idmedico, now(), '1', NULL);
		  set @Idatencion = (SELECT LAST_INSERT_ID());  
		  insert INTO detalleatencion ( idatencion, idpaciente, fechahora, accion, idestadosatencion, hora, fecha, fechacreacion,idtipo_usuario) 
		  VALUES (@Idatencion, idpaciente, now(), 'Registro', '1', hora_ate, fechaatencion, now(),1);
		  select "Registro correcto" as 'Mensaje';
      
      else
        select "Ya esta Registrado" as 'Mensaje';
      end if; 
     select "Ya esta Registrado" as estadocanselado;
	end if;
  else 
   select "hora fuera de rango" as 'Mensaje';
end if;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pa_Usuario_Ver` (IN `tipousuario` INT, IN `idpersona` INT)   begin

    if(tipousuario=1) then
       select *from users as U  
		inner join persona  as P  on U.idpersona=P.idpersona  
		inner join paciente as PA  on P.idpersona=PA.idpersona
		where  U.idpersona=idpersona and U.idpersona=tipousuario;
    else
       select *from users as U  
		inner join persona  as P  on U.idpersona=P.idpersona  
		inner join medico as M   on  M.idpersona=P.idpersona
		where  U.idpersona=tipousuario and U.idpersona=idpersona;
    end if;  
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pa_Validar_AtencionHora` (IN `hora_ate` VARCHAR(30), IN `idhorario` INT)   BEGIN
DECLARE estadofecha1 INT;
DECLARE estadofecha2 INT;
 set  estadofecha1 = (select count(*)   from  horario  where horainicio_hor <= time(hora_ate)  and idhorario=idhorario);
 set  estadofecha2=  (select count(*)  from  horario  where horafin_hor > time(hora_ate)  and idhorario=idhorario);


 if(estadofecha1 !=0 and estadofecha2 !=0 ) then 
   select "Hora correcta" as 'Mensaje';
  else 
   select "hora fuera de rango" as 'Mensaje';
end if;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `atencion`
--

CREATE TABLE `atencion` (
  `idatencion` int(11) NOT NULL,
  `estado_ate` int(11) NOT NULL,
  `fecha_ate` date NOT NULL,
  `fechahora_ate` datetime NOT NULL,
  `hora_ate` time NOT NULL,
  `idhorario` int(11) NOT NULL,
  `idtipo_atencion` int(11) NOT NULL,
  `idmedico` int(11) NOT NULL,
  `fecharegistro` datetime DEFAULT NULL,
  `idestadosatencion` int(11) NOT NULL,
  `recomendacion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `atencion`
--

INSERT INTO `atencion` (`idatencion`, `estado_ate`, `fecha_ate`, `fechahora_ate`, `hora_ate`, `idhorario`, `idtipo_atencion`, `idmedico`, `fecharegistro`, `idestadosatencion`, `recomendacion`) VALUES
(1, 1, '2022-11-05', '2022-11-05 10:28:33', '08:00:00', 1, 1, 1, '2022-11-05 10:28:33', 1, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clinica`
--

CREATE TABLE `clinica` (
  `idclinica` int(11) NOT NULL,
  `nombre_cli` varchar(45) NOT NULL,
  `direccion_cli` varchar(45) NOT NULL,
  `lat_cli` decimal(10,7) NOT NULL,
  `lng_cli` decimal(10,7) NOT NULL,
  `estado_cli` int(11) DEFAULT NULL,
  `idmedico` int(11) NOT NULL,
  `telefono_cli` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `clinica`
--

INSERT INTO `clinica` (`idclinica`, `nombre_cli`, `direccion_cli`, `lat_cli`, `lng_cli`, `estado_cli`, `idmedico`, `telefono_cli`) VALUES
(1, 'Centro Médico MAPFRE San Miguel', 'C. Cardenal Guevara 132 &, Av. Rafael Escardó', '-12.0779740', '-77.0943677', 1, 2, '98589858'),
(2, 'Hospital Sta. Rosa', 'bolívar', '-12.0740086', '-77.0784517', 1, 3, '2545556'),
(3, 'Global Salud', 'Venezuela', '-12.0614305', '-77.0838018', 1, 4, '52589545'),
(4, 'Puesto de Salud Pando', 'puesto pando', '-12.0622467', '-77.0846911', 1, 5, '789689878'),
(5, 'Centro Medico Seraphis', 'asssssssssssssssssssssssssss', '-12.0740086', '-77.0784517', 1, 6, '985878988'),
(6, 'Perufarma SA', '', '-12.0634021', '-77.0856048', 1, 7, '895858877');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleatencion`
--

CREATE TABLE `detalleatencion` (
  `iddetalleAtencion` int(11) NOT NULL,
  `idatencion` int(11) NOT NULL,
  `idpaciente` int(11) NOT NULL,
  `fechahora` datetime DEFAULT NULL,
  `accion` varchar(45) DEFAULT NULL,
  `idestadosatencion` int(11) NOT NULL,
  `hora` time DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `fechacreacion` timestamp NULL DEFAULT NULL,
  `idtipo_usuario` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `detalleatencion`
--

INSERT INTO `detalleatencion` (`iddetalleAtencion`, `idatencion`, `idpaciente`, `fechahora`, `accion`, `idestadosatencion`, `hora`, `fecha`, `fechacreacion`, `idtipo_usuario`) VALUES
(1, 1, 2, '2022-11-05 10:28:33', 'Registro', 1, '08:00:00', '2022-11-05', '2022-11-05 15:28:33', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direcciones`
--

CREATE TABLE `direcciones` (
  `iddirecciones` int(11) NOT NULL,
  `nombre_dir` varchar(45) NOT NULL,
  `lat_dir` decimal(10,7) NOT NULL,
  `lng_dir` decimal(10,7) NOT NULL,
  `idpaciente` int(11) NOT NULL,
  `referencia_dir` varchar(45) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estadosatencion`
--

CREATE TABLE `estadosatencion` (
  `idestadosatencion` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `estado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `estadosatencion`
--

INSERT INTO `estadosatencion` (`idestadosatencion`, `nombre`, `estado`) VALUES
(1, 'Enviado', 1),
(2, 'Cancelado', 1),
(3, 'Ausente', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horario`
--

CREATE TABLE `horario` (
  `idhorario` int(11) NOT NULL,
  `diainicio_hor` varchar(45) NOT NULL,
  `diafin_hor` varchar(45) DEFAULT NULL,
  `horainicio_hor` time NOT NULL,
  `horafin_hor` time NOT NULL,
  `estado_hor` int(11) NOT NULL,
  `idservicios` int(11) NOT NULL,
  `numeroconsulta` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `horario`
--

INSERT INTO `horario` (`idhorario`, `diainicio_hor`, `diafin_hor`, `horainicio_hor`, `horafin_hor`, `estado_hor`, `idservicios`, `numeroconsulta`) VALUES
(1, 'Lunes', 'Viernes', '08:00:00', '20:38:02', 1, 1, 3),
(2, 'Martes', 'Viernes', '08:00:00', '20:38:02', 1, 2, 4),
(3, 'Lunes', '', '08:00:00', '20:38:02', 1, 6, 5),
(4, 'Martes', '', '08:00:00', '20:38:02', 1, 7, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medico`
--

CREATE TABLE `medico` (
  `idmedico` int(11) NOT NULL,
  `cmp_med` varchar(45) NOT NULL,
  `idpersona` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `medico`
--

INSERT INTO `medico` (`idmedico`, `cmp_med`, `idpersona`, `updated_at`, `created_at`) VALUES
(1, '54784147', 2, '2022-10-27 11:16:30', '2022-10-27 11:16:30'),
(2, '7485478788', 3, '2022-10-27 11:20:38', '2022-10-27 11:20:38'),
(3, '85878744', 4, '2022-10-27 11:23:44', '2022-10-27 11:23:44'),
(4, '474147445', 5, '2022-10-27 11:24:48', '2022-10-27 11:24:48'),
(5, '45845845', 6, '2022-10-27 11:25:37', '2022-10-27 11:25:37'),
(6, '85458525', 7, '2022-10-27 11:28:42', '2022-10-27 11:28:42'),
(7, '56958635', 8, '2022-10-27 11:30:04', '2022-10-27 11:30:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paciente`
--

CREATE TABLE `paciente` (
  `idpaciente` int(11) NOT NULL,
  `edad_pac` int(11) NOT NULL,
  `idpersona` int(11) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `paciente`
--

INSERT INTO `paciente` (`idpaciente`, `edad_pac`, `idpersona`, `updated_at`, `created_at`) VALUES
(1, 36, 1, '2022-10-27 11:09:25', '2022-10-27 11:09:25'),
(2, 36, 9, '2022-11-03 11:12:40', '2022-11-03 11:12:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `persona`
--

CREATE TABLE `persona` (
  `idpersona` int(11) NOT NULL,
  `dni_per` varchar(45) NOT NULL,
  `nombre_per` varchar(45) NOT NULL,
  `paterno_per` varchar(45) NOT NULL,
  `materno_per` varchar(45) NOT NULL,
  `email_per` varchar(45) NOT NULL,
  `telefono_per` varchar(9) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `persona`
--

INSERT INTO `persona` (`idpersona`, `dni_per`, `nombre_per`, `paterno_per`, `materno_per`, `email_per`, `telefono_per`, `updated_at`, `created_at`) VALUES
(1, '12345678', 'Julio', 'Delgado', 'Rojas', 'overma@gmail.com', '798589588', '2022-10-27 11:09:25', '2022-10-27 11:09:25'),
(2, '82345678', 'Miguel', 'Couto', 'Delgado', 'miguel@gmail.com', '85484855', '2022-10-27 11:16:30', '2022-10-27 11:16:30'),
(3, '12451477', 'Carlos', 'Couto', 'Delgado', 'carlso@gmail.com', '85484855', '2022-10-27 11:20:37', '2022-10-27 11:20:37'),
(4, '84587598', 'Luis', 'Rojas', 'Delgado', 'luis@gmail.com', '748547844', '2022-10-27 11:23:44', '2022-10-27 11:23:44'),
(5, '45614748', 'Henry', 'Rojas', 'Delgado', 'henry@gmail.com', '85896898', '2022-10-27 11:24:48', '2022-10-27 11:24:48'),
(6, '55965895', 'Diana', 'Rojas', 'Delgado', 'diana@gmail.com', '95868958', '2022-10-27 11:25:37', '2022-10-27 11:25:37'),
(7, '56585895', 'Ivan', 'Rojas', 'Delgado', 'ivan@gmail.com', '95868958', '2022-10-27 11:28:42', '2022-10-27 11:28:42'),
(8, '56585854', 'Ricardo', 'Rojas', 'Delgado', 'ricardo@gmail.com', '95868958', '2022-10-27 11:30:04', '2022-10-27 11:30:04'),
(9, '45845878', 'Julio', 'Delgado', 'Rojas', 'overma1@gmail.com', '798589588', '2022-11-03 11:12:40', '2022-11-03 11:12:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `servicios`
--

CREATE TABLE `servicios` (
  `idservicios` int(11) NOT NULL,
  `nombre_ser` varchar(45) NOT NULL,
  `estado_ser` varchar(45) NOT NULL,
  `fechacreacion` datetime DEFAULT NULL,
  `idclinica` int(11) NOT NULL,
  `descripcion` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `servicios`
--

INSERT INTO `servicios` (`idservicios`, `nombre_ser`, `estado_ser`, `fechacreacion`, `idclinica`, `descripcion`) VALUES
(1, 'Farmacia', '1', '2022-10-25 14:35:53', 1, ''),
(2, 'Laboratorio', '1', '2022-10-25 14:36:09', 1, ''),
(3, 'Terapias', '1', '2022-10-25 14:37:21', 1, ''),
(4, 'MEDICINA GENERAL', '1', '2022-10-25 14:39:39', 1, ''),
(5, 'CARDIOLOGÍA', '1', '2022-10-25 14:40:28', 1, ''),
(6, 'Farmacia', '1', '2022-10-25 14:35:53', 2, 'todo'),
(7, 'MEDICINA GENERAL', '1', '2022-10-27 11:42:49', 2, 'niños de 0 a 14 año');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_atencion`
--

CREATE TABLE `tipo_atencion` (
  `idtipo_atencion` int(11) NOT NULL,
  `nombre_tat` varchar(45) NOT NULL,
  `estado_tat` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_atencion`
--

INSERT INTO `tipo_atencion` (`idtipo_atencion`, `nombre_tat`, `estado_tat`) VALUES
(1, 'Domicilio', 1),
(2, 'Establecimiento', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `idtipo_usuario` int(11) NOT NULL,
  `nombre_tip` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `tipo_usuario`
--

INSERT INTO `tipo_usuario` (`idtipo_usuario`, `nombre_tip`) VALUES
(1, 'Paciente'),
(2, 'Medico'),
(3, 'Admin');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `users`
--

CREATE TABLE `users` (
  `iduser` int(11) NOT NULL,
  `usuario_use` varchar(45) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(200) NOT NULL,
  `idtipo_usuario` int(11) NOT NULL,
  `estado` int(11) NOT NULL,
  `activar_use` int(11) NOT NULL,
  `idpersona` int(11) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Volcado de datos para la tabla `users`
--

INSERT INTO `users` (`iduser`, `usuario_use`, `email_verified_at`, `password`, `idtipo_usuario`, `estado`, `activar_use`, `idpersona`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'julio', NULL, '$2y$10$bQCfPSIC3bpzTx0vGdbXRuMmg4Pl5WLQHTj58kzkx.cytlTKPV.nW', 1, 1, 1, 1, NULL, '2022-10-27 21:09:25', '2022-10-27 21:09:25'),
(2, 'miguel', NULL, '$2y$10$MPnFlKVySGAuiPRhYQI5r..P658SurThccFGenc3UJf6igeWSUREW', 2, 1, 1, 2, NULL, '2022-10-27 21:16:30', '2022-10-27 21:16:30'),
(3, 'karlos', NULL, '$2y$10$828mR4WYHuItQEu3xljkwuN1nK/uryipiGwUR6bUUlSQ9oPqzEwhm', 2, 1, 1, 3, NULL, '2022-10-27 21:20:38', '2022-10-27 21:20:38'),
(4, 'luis', NULL, '$2y$10$LI8GKbdBekzh.blwXnirzuu.aL2qW9xa87.vLA9geIduIVTl9qGFG', 2, 1, 1, 4, NULL, '2022-10-27 21:23:44', '2022-10-27 21:23:44'),
(5, 'henry', NULL, '$2y$10$vGcjD3Y3JM86qGaljQKpTOIaSf1grp3KPL.RdPQSwCpfxwgWCWAf2', 2, 1, 1, 5, NULL, '2022-10-27 21:24:48', '2022-10-27 21:24:48'),
(6, 'diana', NULL, '$2y$10$qpJlLQEDlskttBgEoRViTe/uBZfZqfW4SstlPM37V.ob3Ef9qTcq.', 2, 1, 1, 6, NULL, '2022-10-27 21:25:37', '2022-10-27 21:25:37'),
(7, 'ivan', NULL, '$2y$10$hD/Aa4.69WRsv5/LgmDfR.ea0FUVo3S3Vuz3KqWRSK0LtyqaNAhQ.', 2, 1, 1, 7, NULL, '2022-10-27 21:28:42', '2022-10-27 21:28:42'),
(8, 'ricardo', NULL, '$2y$10$tAcuXsKdGDGdK84brQgKcOpWsZmiJouUqZ9n4MkQsHVuucWznYot6', 2, 1, 1, 8, NULL, '2022-10-27 21:30:04', '2022-10-27 21:30:04'),
(9, 'julio2', NULL, '$2y$10$p8joGZErqePdrLnkXoUpcur/GePOp/dWPfG3PQf4I9MG/lZO0lOcG', 1, 1, 1, 9, NULL, '2022-11-03 16:12:40', '2022-11-03 16:12:40');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `atencion`
--
ALTER TABLE `atencion`
  ADD PRIMARY KEY (`idatencion`);

--
-- Indices de la tabla `clinica`
--
ALTER TABLE `clinica`
  ADD PRIMARY KEY (`idclinica`);

--
-- Indices de la tabla `detalleatencion`
--
ALTER TABLE `detalleatencion`
  ADD PRIMARY KEY (`iddetalleAtencion`);

--
-- Indices de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  ADD PRIMARY KEY (`iddirecciones`);

--
-- Indices de la tabla `estadosatencion`
--
ALTER TABLE `estadosatencion`
  ADD PRIMARY KEY (`idestadosatencion`);

--
-- Indices de la tabla `horario`
--
ALTER TABLE `horario`
  ADD PRIMARY KEY (`idhorario`);

--
-- Indices de la tabla `medico`
--
ALTER TABLE `medico`
  ADD PRIMARY KEY (`idmedico`);

--
-- Indices de la tabla `paciente`
--
ALTER TABLE `paciente`
  ADD PRIMARY KEY (`idpaciente`);

--
-- Indices de la tabla `persona`
--
ALTER TABLE `persona`
  ADD PRIMARY KEY (`idpersona`),
  ADD UNIQUE KEY `dni_UNIQUE` (`dni_per`);

--
-- Indices de la tabla `servicios`
--
ALTER TABLE `servicios`
  ADD PRIMARY KEY (`idservicios`);

--
-- Indices de la tabla `tipo_atencion`
--
ALTER TABLE `tipo_atencion`
  ADD PRIMARY KEY (`idtipo_atencion`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`idtipo_usuario`);

--
-- Indices de la tabla `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`iduser`),
  ADD UNIQUE KEY `userna_UNIQUE` (`usuario_use`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `atencion`
--
ALTER TABLE `atencion`
  MODIFY `idatencion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `clinica`
--
ALTER TABLE `clinica`
  MODIFY `idclinica` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `detalleatencion`
--
ALTER TABLE `detalleatencion`
  MODIFY `iddetalleAtencion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `direcciones`
--
ALTER TABLE `direcciones`
  MODIFY `iddirecciones` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `estadosatencion`
--
ALTER TABLE `estadosatencion`
  MODIFY `idestadosatencion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `horario`
--
ALTER TABLE `horario`
  MODIFY `idhorario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `medico`
--
ALTER TABLE `medico`
  MODIFY `idmedico` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `paciente`
--
ALTER TABLE `paciente`
  MODIFY `idpaciente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `persona`
--
ALTER TABLE `persona`
  MODIFY `idpersona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `servicios`
--
ALTER TABLE `servicios`
  MODIFY `idservicios` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `tipo_atencion`
--
ALTER TABLE `tipo_atencion`
  MODIFY `idtipo_atencion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  MODIFY `idtipo_usuario` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `users`
--
ALTER TABLE `users`
  MODIFY `iduser` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
