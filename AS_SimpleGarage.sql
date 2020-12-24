-- --------------------------------------------------------
-- Host:                         localhost
-- Server versie:                10.1.38-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Versie:              10.1.0.5464
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Structuur van  tabel fivem.owned_vehicles wordt geschreven
CREATE TABLE IF NOT EXISTS `owned_vehicles` (
  `owner` varchar(22) NOT NULL,
  `spawnstate` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1 = spawned',
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `garage` varchar(200) DEFAULT 'A' COMMENT '0 is geen garage',
  `lockcheck` varchar(50) NOT NULL DEFAULT 'no',
  `registered` varchar(50) NOT NULL DEFAULT 'no',
  `impounded` varchar(50) NOT NULL DEFAULT 'no',
  `impoundprice` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Prijs van impound',
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumpen data van tabel fivem.owned_vehicles: ~3 rows (ongeveer)
/*!40000 ALTER TABLE `owned_vehicles` DISABLE KEYS */;
/*!40000 ALTER TABLE `owned_vehicles` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
