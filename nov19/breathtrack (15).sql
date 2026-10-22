-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for osx10.10 (x86_64)
--
-- Host: 127.0.0.1    Database: breathtrack
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `abg_values`
--

DROP TABLE IF EXISTS `abg_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `abg_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `normal` tinyint(1) DEFAULT 0,
  `mild` tinyint(1) DEFAULT 0,
  `moderate` tinyint(1) DEFAULT 0,
  `severe` tinyint(1) DEFAULT 0,
  `comments` text DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `abg_values_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `abg_values`
--

LOCK TABLES `abg_values` WRITE;
/*!40000 ALTER TABLE `abg_values` DISABLE KEYS */;
INSERT INTO `abg_values` VALUES (24,'pat_579',0,1,0,0,'Okkk',NULL,'2026-08-05 11:22:07','2026-08-05 11:22:07');
/*!40000 ALTER TABLE `abg_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `appointments` (
  `appointment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(100) NOT NULL,
  `name` varchar(200) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `gender` varchar(20) DEFAULT 'Other',
  `contact` varchar(50) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `copd_confirmed` tinyint(1) DEFAULT 0,
  `duration_symptoms` varchar(200) DEFAULT NULL,
  `symptoms` text DEFAULT NULL,
  `medications` text DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `smoking_status` varchar(100) DEFAULT 'Never Smoked',
  `preferred_date` date DEFAULT NULL,
  `preferred_time` varchar(100) DEFAULT NULL,
  `consultation_mode` varchar(100) DEFAULT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  PRIMARY KEY (`appointment_id`),
  KEY `patient_id` (`patient_id`),
  KEY `status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (5,'pat_295','Ram Srinu',20,'Male','8975465456','ram@gmail.com','nellore',1,'','Shortness of breath','','','Never Smoked','2026-06-25','Morning','','accepted','2026-03-05 10:41:53','2026-06-24 06:07:33'),(17,'pat_579','Sathish',19,'Male','9390661398','sathish@gmail.com','kodur,Andhra pradhesh',1,'','Shortness of breath','','','Never Smoked','2026-08-20','Morning','','accepted','2026-08-05 05:47:37','2026-08-05 05:50:38');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `doctors`
--

DROP TABLE IF EXISTS `doctors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doctors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `doctor_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `doctor_id` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `doctors`
--

LOCK TABLES `doctors` WRITE;
/*!40000 ALTER TABLE `doctors` DISABLE KEYS */;
INSERT INTO `doctors` VALUES (4,'doc_002','Moukthika','m@gmail.com',25,'9663952802','$2y$10$WFRNyd8kaA1f3LVVGoyJb.qyyobnJNCxfkctJ0LHbAZRQ8t6wF7Km','2025-10-14 03:20:53');
/*!40000 ALTER TABLE `doctors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inhaler_adherence`
--

DROP TABLE IF EXISTS `inhaler_adherence`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inhaler_adherence` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `date_taken` date NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dose` (`patient_id`,`date_taken`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inhaler_adherence`
--

LOCK TABLES `inhaler_adherence` WRITE;
/*!40000 ALTER TABLE `inhaler_adherence` DISABLE KEYS */;
INSERT INTO `inhaler_adherence` VALUES (6,'pat_295','2026-06-12','2026-06-12 07:59:15'),(16,'pat_579','2026-08-05','2026-08-05 05:41:10');
/*!40000 ALTER TABLE `inhaler_adherence` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `medication_diary`
--

DROP TABLE IF EXISTS `medication_diary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `medication_diary` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `medicines` text NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medication_diary`
--

LOCK TABLES `medication_diary` WRITE;
/*!40000 ALTER TABLE `medication_diary` DISABLE KEYS */;
INSERT INTO `medication_diary` VALUES (7,'pat_295','[\"MDI Glycohale FB (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, Glycopyrronium 12.5 mcg and budesonide 200 mcg\",\"MDI Budamate (LABA + ICS) - Formoterol fumarate 6 mcg and budesonide 200\\/400 mcg\",\"MDI Duolin (SABA + SAMA) - Levosalbutamol 50 mcg and ipratropium bromide 20 mcg\"]','Use this medicine','2026-03-10 10:46:53','2026-04-22 03:12:24'),(14,'pat_579','[\"MDI Glycohale FB (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, Glycopyrronium 12.5 mcg and budesonide 200 mcg\",\"MDI Budamate (LABA + ICS) - Formoterol fumarate 6 mcg and budesonide 200\\/400 mcg\"]','Use this','2026-08-05 05:52:17','2026-08-05 05:52:17');
/*!40000 ALTER TABLE `medication_diary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_checkup`
--

DROP TABLE IF EXISTS `patient_checkup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patient_checkup` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(20) NOT NULL,
  `temperature` decimal(5,2) DEFAULT NULL,
  `oxygen_level` decimal(5,2) DEFAULT NULL,
  `lung_function` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `patient_id` (`patient_id`),
  CONSTRAINT `patient_checkup_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_checkup`
--

LOCK TABLES `patient_checkup` WRITE;
/*!40000 ALTER TABLE `patient_checkup` DISABLE KEYS */;
INSERT INTO `patient_checkup` VALUES (25,'pat_579',100.00,96.00,96.00,'2026-08-05 05:39:42','2026-08-05 05:39:42');
/*!40000 ALTER TABLE `patient_checkup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_reminders`
--

DROP TABLE IF EXISTS `patient_reminders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patient_reminders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `reminder_id` varchar(100) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `due_date` varchar(20) NOT NULL,
  `alarm_time` varchar(10) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `color` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pat_rem_unique` (`patient_id`,`reminder_id`),
  CONSTRAINT `fk_patient_reminders` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_reminders`
--

LOCK TABLES `patient_reminders` WRITE;
/*!40000 ALTER TABLE `patient_reminders` DISABLE KEYS */;
INSERT INTO `patient_reminders` VALUES (1,'pat_295','inhaler_daily_alarm','Daily Inhaler Reminder 🫁','Time to take your daily inhaler dose for better breathing.','2026-08-05','09:00','wind','#3b82f6'),(2,'pat_295','inhaler_refill','Inhaler Refill Due ⚠️','Your inhaler is due for a refill. Please contact your pharmacy or doctor.','2026-06-19','09:00','alert-triangle','#f59e0b'),(5,'pat_295','vaccine_pneumococcal_vaccination','Pneumococcal Vaccination Due 💉','Next checkup due on 06 Mar 2030','2030-03-06','09:00','💉','#10b981'),(6,'pat_295','vaccine_flu_vaccine','Flu Vaccine Due 💉','Next shot due on 04 Aug 2027','2027-08-04','09:00','💉','#10b981'),(7,'pat_295','vaccine_pertussis_vaccine','Pertussis Vaccine Due 💉','Next booster due on 12 Mar 2036','2036-03-12','09:00','💉','#10b981'),(8,'pat_295','vaccine_shingles','Shingles Immunity Review 💉','Next review on 01 Apr 2031','2031-04-01','09:00','💉','#10b981'),(13,'pat_579','inhaler_daily_alarm','Daily Inhaler Reminder 🫁','Time to take your daily inhaler dose for better breathing.','2026-08-05','11:47','wind','#3b82f6'),(14,'pat_579','inhaler_refill','Inhaler Empty! 🚨','You\'ve marked your inhaler as empty. Reminder to request a refill!','2026-08-06','11:24','exclamationmark.triangle.fill','#f59e0b'),(26,'pat_579','vaccine_flu_vaccine','Flu Vaccine Due 💉','It has been 1 year since your Flu Shot. Time to get your next one!','2027-08-05','09:00','syringe.fill','#10b981');
/*!40000 ALTER TABLE `patient_reminders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `patients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(11) NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL,
  `height` decimal(5,2) NOT NULL,
  `weight` decimal(5,2) NOT NULL,
  `diagnosis` varchar(255) NOT NULL,
  `occupation` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `inhaler_alarm_time` varchar(10) DEFAULT '09:00',
  `inhaler_refill_date` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `patient_id` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (10,'pat_295','Ram',18,'Male',6.00,60.00,'Copd','Student','','$2y$10$.Pc5qTTZGhdbCgs5yDLELeKLufGImSMl9hnL97E9OexKGd64tT2Ui','2026-03-05 10:10:16','09:00',NULL),(39,'pat_579','Sathish',19,'Male',175.00,60.00,'copd','student','9390661398','$2y$10$IjdRXdldGDuVN31Rm5iaxeuJoGRBSvDfI9315z40BIDMuzbAqyEdy','2026-08-05 05:39:23','09:00',NULL);
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pft_values`
--

DROP TABLE IF EXISTS `pft_values`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pft_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `normal` tinyint(1) DEFAULT 0,
  `mild` tinyint(1) DEFAULT 0,
  `moderate` tinyint(1) DEFAULT 0,
  `severe` tinyint(1) DEFAULT 0,
  `comments` text DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `pft_values_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pft_values`
--

LOCK TABLES `pft_values` WRITE;
/*!40000 ALTER TABLE `pft_values` DISABLE KEYS */;
INSERT INTO `pft_values` VALUES (31,'pat_579',1,0,0,0,'Good',NULL,'2026-08-05 11:21:56','2026-08-05 11:21:56');
/*!40000 ALTER TABLE `pft_values` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `questionnaires`
--

DROP TABLE IF EXISTS `questionnaires`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `questionnaires` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `date_pneumococcal` varchar(20) DEFAULT NULL,
  `date_flu` varchar(20) DEFAULT NULL,
  `date_pertussis` varchar(20) DEFAULT NULL,
  `date_shingles1` varchar(20) DEFAULT NULL,
  `date_shingles2` varchar(20) DEFAULT NULL,
  `q1_cough` int(11) DEFAULT NULL,
  `q2_phlegm` int(11) DEFAULT NULL,
  `q3_chest_tightness` int(11) DEFAULT NULL,
  `q4_breathlessness` int(11) DEFAULT NULL,
  `q5_activity_limitation` int(11) DEFAULT NULL,
  `q6_confidence_leaving_home` int(11) DEFAULT NULL,
  `q7_sleep_quality` int(11) DEFAULT NULL,
  `q8_energy_level` int(11) DEFAULT NULL,
  `average_score` decimal(5,2) DEFAULT 0.00,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `patient_id` (`patient_id`),
  CONSTRAINT `questionnaires_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `questionnaires`
--

LOCK TABLES `questionnaires` WRITE;
/*!40000 ALTER TABLE `questionnaires` DISABLE KEYS */;
INSERT INTO `questionnaires` VALUES (27,'pat_579','N/A','2026-08-05','N/A','N/A','N/A',2,5,2,5,3,3,3,3,3.25,'2026-08-05 11:10:11','2026-08-05 11:53:33');
/*!40000 ALTER TABLE `questionnaires` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `videos`
--

DROP TABLE IF EXISTS `videos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `videos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `video_url` varchar(500) DEFAULT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `video_type` varchar(50) DEFAULT 'local',
  `upload_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `videos`
--

LOCK TABLES `videos` WRITE;
/*!40000 ALTER TABLE `videos` DISABLE KEYS */;
INSERT INTO `videos` VALUES (1,'Tutorial','',NULL,'https://www.youtube.com/watch?v=bWuB_zLcOL8',NULL,'youtube','2026-07-14 08:23:48'),(2,'YouTube Video','',NULL,'https://www.youtube.com/watch?v=bWuB_zLcOL8',NULL,'youtube','2026-07-14 08:24:14'),(3,'Inhaler usage','',NULL,'https://www.youtube.com/watch?v=bWuB_zLcOL8',NULL,'youtube','2026-08-05 06:08:38');
/*!40000 ALTER TABLE `videos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `walk_test_reports`
--

DROP TABLE IF EXISTS `walk_test_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `walk_test_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `patient_id` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `walk_test_reports`
--

LOCK TABLES `walk_test_reports` WRITE;
/*!40000 ALTER TABLE `walk_test_reports` DISABLE KEYS */;
INSERT INTO `walk_test_reports` VALUES (4,'pat_579','Breathing is okay','2026-08-05 05:52:42');
/*!40000 ALTER TABLE `walk_test_reports` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-08-05 13:26:22
