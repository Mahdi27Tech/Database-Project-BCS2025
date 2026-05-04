/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: bakery_inventory
-- ------------------------------------------------------
-- Server version	11.8.6-MariaDB-6 from Debian

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `type` enum('ingredient','product','packaging','equipment') NOT NULL,
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES
(1,'Flour & Grains','ingredient'),
(2,'Sweeteners','ingredient'),
(3,'Dairy & Eggs','ingredient'),
(4,'Fats & Oils','ingredient'),
(5,'Leavening Agents','ingredient'),
(6,'Flavorings','ingredient'),
(7,'Breads','product'),
(8,'Pastries & Cakes','product'),
(9,'Cookies','product'),
(10,'Boxes & Bags','packaging'),
(11,'Equipment','equipment');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ingredients`
--

DROP TABLE IF EXISTS `ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredients` (
  `ingredient_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `category_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `quantity_in_stock` decimal(10,3) NOT NULL DEFAULT 0.000,
  `reorder_level` decimal(10,3) NOT NULL DEFAULT 0.000,
  `cost_per_unit` decimal(10,4) NOT NULL DEFAULT 0.0000,
  `supplier_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ingredient_id`),
  KEY `fk_ing_category` (`category_id`),
  KEY `fk_ing_unit` (`unit_id`),
  KEY `fk_ing_supplier` (`supplier_id`),
  CONSTRAINT `fk_ing_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk_ing_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`),
  CONSTRAINT `fk_ing_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredients`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ingredients` WRITE;
/*!40000 ALTER TABLE `ingredients` DISABLE KEYS */;
INSERT INTO `ingredients` VALUES
(1,'All-Purpose Flour',1,1,50.000,10.000,0.8500,1,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(2,'Bread Flour',1,1,30.000,8.000,0.9200,1,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(3,'Granulated Sugar',2,1,20.000,5.000,1.1000,3,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(4,'Brown Sugar',2,1,10.000,3.000,1.2500,3,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(5,'Whole Milk',3,3,8.000,2.000,0.9500,2,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(6,'Unsalted Butter',4,1,15.000,3.000,5.5000,2,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(7,'Eggs',3,5,120.000,30.000,0.2500,2,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(8,'Active Dry Yeast',5,2,500.000,100.000,0.0450,1,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(9,'Baking Powder',5,2,800.000,150.000,0.0200,1,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(10,'Vanilla Extract',6,4,500.000,100.000,0.0600,3,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00');
/*!40000 ALTER TABLE `ingredients` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `category_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `quantity_in_stock` decimal(10,3) NOT NULL DEFAULT 0.000,
  `reorder_level` decimal(10,3) NOT NULL DEFAULT 0.000,
  `sale_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`product_id`),
  KEY `fk_prod_category` (`category_id`),
  KEY `fk_prod_unit` (`unit_id`),
  CONSTRAINT `fk_prod_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk_prod_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES
(1,'Classic White Bread',7,5,20.000,5.000,3.50,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(2,'Croissant',8,5,30.000,10.000,2.75,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(3,'Chocolate Chip Cookie',9,5,100.000,20.000,0.75,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(4,'Vanilla Sponge Cake',8,5,5.000,2.000,18.00,NULL,'2026-03-24 09:27:00','2026-03-24 09:27:00'),
(5,'Chapat',5,4,27.000,7.000,1000.00,NULL,'2026-03-24 09:47:19','2026-03-24 09:47:19');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `purchase_order_items`
--

DROP TABLE IF EXISTS `purchase_order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_order_items` (
  `poi_id` int(11) NOT NULL AUTO_INCREMENT,
  `po_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `quantity_ordered` decimal(10,3) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `cost_per_unit` decimal(10,4) NOT NULL,
  `quantity_received` decimal(10,3) NOT NULL DEFAULT 0.000,
  PRIMARY KEY (`poi_id`),
  KEY `fk_poi_po` (`po_id`),
  KEY `fk_poi_ingredient` (`ingredient_id`),
  KEY `fk_poi_unit` (`unit_id`),
  CONSTRAINT `fk_poi_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`),
  CONSTRAINT `fk_poi_po` FOREIGN KEY (`po_id`) REFERENCES `purchase_orders` (`po_id`),
  CONSTRAINT `fk_poi_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_order_items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `purchase_order_items` WRITE;
/*!40000 ALTER TABLE `purchase_order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_order_items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_po_item_received
AFTER UPDATE ON purchase_order_items
FOR EACH ROW
BEGIN
  IF NEW.quantity_received > OLD.quantity_received THEN
    UPDATE ingredients
    SET quantity_in_stock = quantity_in_stock + (NEW.quantity_received - OLD.quantity_received)
    WHERE ingredient_id = NEW.ingredient_id;

    INSERT INTO stock_movements
      (movement_type, item_type, item_id, quantity_change, reference_id, notes)
    VALUES
      ('purchase', 'ingredient', NEW.ingredient_id,
       NEW.quantity_received - OLD.quantity_received,
       NEW.po_id, 'Auto-updated from PO receipt');
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `purchase_orders`
--

DROP TABLE IF EXISTS `purchase_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `purchase_orders` (
  `po_id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL,
  `order_date` date NOT NULL,
  `expected_date` date DEFAULT NULL,
  `received_date` date DEFAULT NULL,
  `status` enum('pending','received','cancelled') NOT NULL DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `total_cost` decimal(12,2) DEFAULT 0.00,
  PRIMARY KEY (`po_id`),
  KEY `fk_po_supplier` (`supplier_id`),
  CONSTRAINT `fk_po_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `purchase_orders`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `purchase_orders` WRITE;
/*!40000 ALTER TABLE `purchase_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `purchase_orders` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `recipe_ingredients`
--

DROP TABLE IF EXISTS `recipe_ingredients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipe_ingredients` (
  `recipe_id` int(11) NOT NULL,
  `ingredient_id` int(11) NOT NULL,
  `quantity_needed` decimal(10,4) NOT NULL,
  `unit_id` int(11) NOT NULL,
  PRIMARY KEY (`recipe_id`,`ingredient_id`),
  KEY `fk_ri_ingredient` (`ingredient_id`),
  KEY `fk_ri_unit` (`unit_id`),
  CONSTRAINT `fk_ri_ingredient` FOREIGN KEY (`ingredient_id`) REFERENCES `ingredients` (`ingredient_id`),
  CONSTRAINT `fk_ri_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`recipe_id`),
  CONSTRAINT `fk_ri_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recipe_ingredients`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `recipe_ingredients` WRITE;
/*!40000 ALTER TABLE `recipe_ingredients` DISABLE KEYS */;
INSERT INTO `recipe_ingredients` VALUES
(1,2,0.5000,1),
(1,5,0.3000,3),
(1,6,0.0300,1),
(1,8,7.0000,2),
(2,1,0.2800,1),
(2,3,0.2000,1),
(2,6,0.2250,1),
(2,7,2.0000,5),
(2,10,5.0000,4);
/*!40000 ALTER TABLE `recipe_ingredients` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `recipes`
--

DROP TABLE IF EXISTS `recipes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `recipes` (
  `recipe_id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `yield_quantity` decimal(10,3) NOT NULL DEFAULT 1.000,
  `instructions` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`recipe_id`),
  KEY `fk_recipe_product` (`product_id`),
  CONSTRAINT `fk_recipe_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `recipes`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `recipes` WRITE;
/*!40000 ALTER TABLE `recipes` DISABLE KEYS */;
INSERT INTO `recipes` VALUES
(1,1,'Classic White Bread Recipe',2.000,NULL,'2026-03-24 09:27:00'),
(2,3,'Chocolate Chip Cookies Batch',24.000,NULL,'2026-03-24 09:27:00');
/*!40000 ALTER TABLE `recipes` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `stock_movements`
--

DROP TABLE IF EXISTS `stock_movements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `stock_movements` (
  `movement_id` int(11) NOT NULL AUTO_INCREMENT,
  `movement_type` enum('purchase','production','sale','adjustment','waste') NOT NULL,
  `item_type` enum('ingredient','product') NOT NULL,
  `item_id` int(11) NOT NULL,
  `quantity_change` decimal(10,3) NOT NULL,
  `reference_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `moved_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`movement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_movements`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `stock_movements` WRITE;
/*!40000 ALTER TABLE `stock_movements` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_movements` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_uca1400_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER trg_production_deduct
AFTER INSERT ON stock_movements
FOR EACH ROW
BEGIN
  IF NEW.movement_type = 'production' AND NEW.item_type = 'product' THEN
    
    INSERT INTO stock_movements (movement_type, item_type, item_id, quantity_change, reference_id, notes)
    SELECT
      'production',
      'ingredient',
      ri.ingredient_id,
      -(ri.quantity_needed * NEW.quantity_change),
      NEW.reference_id,
      CONCAT('Auto-deducted for production of product #', NEW.item_id)
    FROM recipe_ingredients ri
    JOIN recipes r ON r.recipe_id = ri.recipe_id
    WHERE r.product_id = NEW.item_id;

    
    UPDATE ingredients ing
    JOIN recipe_ingredients ri ON ri.ingredient_id = ing.ingredient_id
    JOIN recipes r ON r.recipe_id = ri.recipe_id
    SET ing.quantity_in_stock = ing.quantity_in_stock - (ri.quantity_needed * NEW.quantity_change)
    WHERE r.product_id = NEW.item_id;

    
    UPDATE products
    SET quantity_in_stock = quantity_in_stock + NEW.quantity_change
    WHERE product_id = NEW.item_id;
  END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `suppliers` (
  `supplier_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(120) NOT NULL,
  `contact_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`supplier_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suppliers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `suppliers` WRITE;
/*!40000 ALTER TABLE `suppliers` DISABLE KEYS */;
INSERT INTO `suppliers` VALUES
(1,'Golden Grain Co.','Maria Lopez','maria@goldengrain.com','555-0101',NULL,'2026-03-24 09:27:00'),
(2,'Dairy Fresh Inc.','Tom Baker','tom@dairyfresh.com','555-0102',NULL,'2026-03-24 09:27:00'),
(3,'Sweet Supply Co.','Anna White','anna@sweetsupply.com','555-0103',NULL,'2026-03-24 09:27:00');
/*!40000 ALTER TABLE `suppliers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `units` (
  `unit_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `abbreviation` varchar(10) NOT NULL,
  PRIMARY KEY (`unit_id`),
  UNIQUE KEY `uq_units_abbr` (`abbreviation`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `units`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `units` WRITE;
/*!40000 ALTER TABLE `units` DISABLE KEYS */;
INSERT INTO `units` VALUES
(1,'Kilogram','kg'),
(2,'Gram','g'),
(3,'Liter','L'),
(4,'Milliliter','mL'),
(5,'Piece','pcs'),
(6,'Bag','bag'),
(7,'Box','box');
/*!40000 ALTER TABLE `units` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Temporary table structure for view `vw_low_stock_alerts`
--

DROP TABLE IF EXISTS `vw_low_stock_alerts`;
/*!50001 DROP VIEW IF EXISTS `vw_low_stock_alerts`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_low_stock_alerts` AS SELECT
 1 AS `item_type`,
  1 AS `item_id`,
  1 AS `name`,
  1 AS `quantity_in_stock`,
  1 AS `reorder_level`,
  1 AS `shortage` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `vw_recipe_cost`
--

DROP TABLE IF EXISTS `vw_recipe_cost`;
/*!50001 DROP VIEW IF EXISTS `vw_recipe_cost`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8mb4;
/*!50001 CREATE VIEW `vw_recipe_cost` AS SELECT
 1 AS `recipe_id`,
  1 AS `recipe_name`,
  1 AS `product_name`,
  1 AS `yield_quantity`,
  1 AS `total_ingredient_cost`,
  1 AS `cost_per_unit` */;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_low_stock_alerts`
--

/*!50001 DROP VIEW IF EXISTS `vw_low_stock_alerts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_low_stock_alerts` AS select 'ingredient' AS `item_type`,`ingredients`.`ingredient_id` AS `item_id`,`ingredients`.`name` AS `name`,`ingredients`.`quantity_in_stock` AS `quantity_in_stock`,`ingredients`.`reorder_level` AS `reorder_level`,`ingredients`.`reorder_level` - `ingredients`.`quantity_in_stock` AS `shortage` from `ingredients` where `ingredients`.`quantity_in_stock` <= `ingredients`.`reorder_level` union all select 'product' AS `item_type`,`products`.`product_id` AS `item_id`,`products`.`name` AS `name`,`products`.`quantity_in_stock` AS `quantity_in_stock`,`products`.`reorder_level` AS `reorder_level`,`products`.`reorder_level` - `products`.`quantity_in_stock` AS `shortage` from `products` where `products`.`quantity_in_stock` <= `products`.`reorder_level` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_recipe_cost`
--

/*!50001 DROP VIEW IF EXISTS `vw_recipe_cost`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_uca1400_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_recipe_cost` AS select `r`.`recipe_id` AS `recipe_id`,`r`.`name` AS `recipe_name`,`p`.`name` AS `product_name`,`r`.`yield_quantity` AS `yield_quantity`,sum(`ri`.`quantity_needed` * `i`.`cost_per_unit`) AS `total_ingredient_cost`,sum(`ri`.`quantity_needed` * `i`.`cost_per_unit`) / `r`.`yield_quantity` AS `cost_per_unit` from (((`recipes` `r` join `products` `p` on(`p`.`product_id` = `r`.`product_id`)) join `recipe_ingredients` `ri` on(`ri`.`recipe_id` = `r`.`recipe_id`)) join `ingredients` `i` on(`i`.`ingredient_id` = `ri`.`ingredient_id`)) group by `r`.`recipe_id`,`r`.`name`,`p`.`name`,`r`.`yield_quantity` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-04 16:39:08
