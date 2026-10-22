-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 11, 2025 at 09:43 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `breathtrack`
--

-- --------------------------------------------------------

--
-- Table structure for table `abg_values`
--

CREATE TABLE `abg_values` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `normal` tinyint(1) DEFAULT 0,
  `mild` tinyint(1) DEFAULT 0,
  `moderate` tinyint(1) DEFAULT 0,
  `severe` tinyint(1) DEFAULT 0,
  `comments` text DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `abg_values`
--

INSERT INTO `abg_values` (`id`, `patient_id`, `normal`, `mild`, `moderate`, `severe`, `comments`, `image_path`, `created_at`, `updated_at`) VALUES
(1, 'pat_628', 1, 0, 0, 1, 'better', 'uploads/abg_report_1761659576.jpg', '2025-10-28 19:22:56', '2025-10-28 19:22:56'),
(2, 'pat_037', 1, 0, 0, 0, 'your in normal condition n', 'uploads/abg_report_1761727170.jpg', '2025-10-29 14:09:30', '2025-10-29 14:09:30'),
(3, 'pat_954', 1, 0, 0, 1, 'good', 'uploads/abg_report_1761968608.jpg', '2025-11-01 09:13:28', '2025-11-01 09:13:28'),
(4, 'pat_133', 0, 0, 1, 0, 'below', 'uploads/abg_report_1762848988.jpg', '2025-11-07 18:01:43', '2025-11-11 13:46:28'),
(5, 'pat_676', 0, 1, 0, 0, 'too much', 'uploads/abg_report_1762520919.jpg', '2025-11-07 18:38:39', '2025-11-07 18:38:39'),
(6, 'pat_857', 0, 0, 1, 0, 'moderate', 'uploads/abg_report_1762850188.jpg', '2025-11-11 14:06:28', '2025-11-11 14:06:28');

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `appointment_id` int(10) UNSIGNED NOT NULL,
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
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`appointment_id`, `patient_id`, `name`, `age`, `gender`, `contact`, `email`, `address`, `copd_confirmed`, `duration_symptoms`, `symptoms`, `medications`, `allergies`, `smoking_status`, `preferred_date`, `preferred_time`, `consultation_mode`, `status`, `created_at`, `updated_at`) VALUES
(1, 'pat_133', 'dileep', 45, 'Male', '7093950943', 'd@gmail.com', 'kadapa', 1, '7 months', 'Shortness of breath,Chest tightness,Fatigue', 'no', 'no', 'Former Smoker', '2025-11-07', 'Morning,Afternoon', 'In-Person', 'accepted', '2025-10-31 03:53:01', '2025-11-07 10:21:33'),
(2, 'pat_676', 'bhargavi', 67, 'Female', '9885426287', 'bharu@gmail.com', 'kadaapa', 1, '9 months', 'Shortness of breath,Fatigue', 'no', 'no', 'Former Smoker', '2028-09-24', 'Morning', 'In-Person', 'rejected', '2025-10-31 07:31:59', '2025-11-04 04:23:05'),
(3, 'pat_954', 'janaki', 47, 'Female', '70933950943', 'janaki@gmail.com', 'kadapa', 1, '8 months', 'Shortness of breath,Fatigue', 'yes', 'yes', 'Former Smoker', '2025-11-01', 'Morning', 'In-Person', 'accepted', '2025-11-01 03:40:57', '2025-11-04 04:23:57'),
(4, 'pat_857', 'N. Madhuri', 21, 'Female', '9885426287', 'madhu@gmail.com', 'mfkrefj', 1, '9 months', 'Shortness of breath', 'nothing', 'nothing', 'Former Smoker', '2025-11-11', 'Morning', 'In-Person', 'accepted', '2025-11-11 08:27:15', '2025-11-11 08:35:27');

-- --------------------------------------------------------

--
-- Table structure for table `doctors`
--

CREATE TABLE `doctors` (
  `id` int(11) NOT NULL,
  `doctor_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `doctors`
--

INSERT INTO `doctors` (`id`, `doctor_id`, `name`, `email`, `age`, `phone`, `password`, `created_at`) VALUES
(1, 'doc123', 'Dr. John Doe', 'john.doe@example.com', NULL, NULL, 'doctorpass', '2025-10-13 07:58:20'),
(2, 'doc_001', 'Dr. Smith', 'dr.smith@example.com', 40, '9876543210', 'docpass123', '2025-10-13 08:11:42'),
(3, 'd123', 'sri', 's@gmail.com', 35, '8765246424', '123', '2025-10-13 09:32:06'),
(4, 'doc_002', 'madhu', 'm@gmail.com', 20, '9885426287', 'madhu', '2025-10-14 03:20:53');

-- --------------------------------------------------------

--
-- Table structure for table `doctor_patients`
--

CREATE TABLE `doctor_patients` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(11) DEFAULT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `status` enum('pending','accepted','rejected') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `doctor_profile`
--

CREATE TABLE `doctor_profile` (
  `doctor_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medication_diary`
--

CREATE TABLE `medication_diary` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `medicines` text NOT NULL,
  `remarks` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `medication_diary`
--

INSERT INTO `medication_diary` (`id`, `patient_id`, `medicines`, `remarks`, `created_at`, `updated_at`) VALUES
(1, 'pat_681', '[\"MDI Trimium (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, tiotropium bromide 9 mcg and cyclosonide 200 mcg\",\"MDI Tiova (LAMA) - Tiotropium bromide 9 mcg\"]', 'better', '2025-10-29 03:26:30', '2025-10-29 03:27:23'),
(2, 'pat_133', '[\"MDI Glycohale FB (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, Glycopyrronium 12.5 mcg and budesonide 200 mcg\",\"MDI Tiova (LAMA) - Tiotropium bromide 9 mcg\"]', 'perfect', '2025-10-29 03:28:03', '2025-11-11 08:15:21'),
(3, 'pat_037', '[\"MDI Duolin (SABA + SAMA) - Levosalbutamol 50 mcg and ipratropium bromide 20 mcg\"]', 'qaverage', '2025-10-29 08:35:12', '2025-10-29 08:35:12'),
(4, 'pat_954', '[\"MDI Budamate (LABA + ICS) - Formoterol fumarate 6 mcg and budesonide 200\\/400 mcg\",\"MDI Tiova (LAMA) - Tiotropium bromide 9 mcg\"]', 'take this medicine', '2025-11-01 03:37:00', '2025-11-01 03:37:00'),
(5, 'pat_524', '[\"MDI Glycohale FB (LABA + LAMA + ICS) - Formoterol fumarate 6 mcg, Glycopyrronium 12.5 mcg and budesonide 200 mcg\"]', 'God gift', '2025-11-10 08:16:13', '2025-11-10 08:16:13'),
(6, 'pat_857', '[\"MDI Tiova (LAMA) - Tiotropium bromide 9 mcg\"]', 'moderate', '2025-11-11 08:36:39', '2025-11-11 08:36:39');

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(11) NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL,
  `height` decimal(5,2) NOT NULL,
  `weight` decimal(5,2) NOT NULL,
  `diagnosis` varchar(255) NOT NULL,
  `occupation` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `patient_id`, `name`, `age`, `gender`, `height`, `weight`, `diagnosis`, `occupation`, `password`, `created_at`) VALUES
(1, 'pat_628', 'madhuri', 90, 'Female', 6.50, 67.00, 'copd', 'student', '1234', '2025-10-28 13:13:21'),
(2, 'pat_133', 'dileep', 40, 'Male', 5.90, 70.00, 'copd', 'student', '12345', '2025-10-28 14:00:42'),
(3, 'pat_681', 'venku', 79, 'Female', 6.50, 78.00, 'asthama', 'student', '123', '2025-10-29 03:03:32'),
(4, 'pat_037', 'deepika', 22, 'Female', 4.00, 44.00, 'sinus', 'no use', 'deepu', '2025-10-29 08:31:20'),
(5, 'pat_676', 'bhargavi', 32, 'Female', 5.30, 56.00, 'breathing problem', 'engineer', 'bharu', '2025-10-31 07:08:34'),
(6, 'pat_208', 'madhuri', 67, '', 5.00, 65.00, '654', '546', '123', '2025-10-31 07:11:35'),
(7, 'pat_524', 'karthik', 67, '', 757.00, 588.00, 'f gg', 'ngkt', '222', '2025-10-31 07:14:36'),
(8, 'pat_954', 'jjanaki', 46, 'Female', 4.70, 67.00, 'brething issue', 'house wife', 'janaki', '2025-11-01 03:34:26'),
(9, 'pat_857', 'N. Madhuri', 21, 'Female', 5.00, 48.00, 'breathing problem', 'student', 'madhu', '2025-11-11 08:20:20');

-- --------------------------------------------------------

--
-- Table structure for table `patient_checkup`
--

CREATE TABLE `patient_checkup` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(20) NOT NULL,
  `temperature` decimal(5,2) DEFAULT NULL,
  `oxygen_level` decimal(5,2) DEFAULT NULL,
  `lung_function` decimal(5,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_checkup`
--

INSERT INTO `patient_checkup` (`id`, `patient_id`, `temperature`, `oxygen_level`, `lung_function`, `created_at`, `updated_at`) VALUES
(1, 'pat_628', 97.00, 98.00, 100.00, '2025-10-28 13:13:41', '2025-10-28 13:24:56'),
(2, 'pat_133', 97.00, 100.00, 100.00, '2025-10-28 14:02:41', '2025-11-05 07:34:50'),
(3, 'pat_681', 103.00, 100.00, 100.00, '2025-10-29 03:03:55', '2025-10-31 07:12:17'),
(4, 'pat_037', 97.00, 93.00, 96.00, '2025-10-29 08:31:52', '2025-10-29 08:31:52'),
(5, 'pat_524', 104.00, 97.00, 102.00, '2025-10-31 07:15:32', '2025-10-31 07:15:32'),
(6, 'pat_954', 97.00, 98.00, 94.00, '2025-11-01 03:35:12', '2025-11-01 03:35:12'),
(7, 'pat_208', 97.00, 98.00, 103.00, '2025-11-04 08:07:03', '2025-11-04 08:07:03'),
(8, 'pat_857', 96.00, 97.00, 98.00, '2025-11-11 08:20:48', '2025-11-11 08:33:31');

-- --------------------------------------------------------

--
-- Table structure for table `patient_profile`
--

CREATE TABLE `patient_profile` (
  `patient_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `age` int(11) NOT NULL,
  `gender` enum('Male','Female','Other') NOT NULL,
  `occupation` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pft_values`
--

CREATE TABLE `pft_values` (
  `id` int(11) NOT NULL,
  `patient_id` varchar(50) NOT NULL,
  `normal` tinyint(1) DEFAULT 0,
  `mild` tinyint(1) DEFAULT 0,
  `moderate` tinyint(1) DEFAULT 0,
  `severe` tinyint(1) DEFAULT 0,
  `comments` text DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `pft_values`
--

INSERT INTO `pft_values` (`id`, `patient_id`, `normal`, `mild`, `moderate`, `severe`, `comments`, `image_path`, `created_at`, `updated_at`) VALUES
(1, 'pat_628', 1, 0, 0, 0, 'awsome', 'uploads/report_1762520107.jpg', '2025-10-28 19:22:16', '2025-11-07 18:25:07'),
(2, 'pat_133', 1, 0, 0, 0, 'fantacy', 'uploads/report_1762848969.jpg', '2025-10-28 19:40:20', '2025-11-11 13:46:09'),
(3, 'pat_037', 0, 1, 0, 0, 'hjkjhi', 'uploads/report_1762519520.jpg', '2025-10-29 14:08:48', '2025-11-07 18:15:20'),
(4, 'pat_954', 0, 0, 1, 0, 'good', 'uploads/report_1762519443.jpg', '2025-11-01 09:12:45', '2025-11-07 18:14:03'),
(5, 'pat_208', 1, 0, 0, 0, 'truth', 'uploads/report_1762519692.jpg', '2025-11-07 18:18:12', '2025-11-07 18:18:12'),
(6, 'pat_676', 0, 1, 0, 0, 'balance', 'uploads/report_1762520223.jpg', '2025-11-07 18:27:03', '2025-11-07 18:27:03'),
(7, 'pat_857', 0, 0, 1, 0, 'moderate', 'uploads/report_1762850170.jpg', '2025-11-11 14:06:10', '2025-11-11 14:06:10');

-- --------------------------------------------------------

--
-- Table structure for table `questionnaires`
--

CREATE TABLE `questionnaires` (
  `id` int(11) NOT NULL,
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
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `questionnaires`
--

INSERT INTO `questionnaires` (`id`, `patient_id`, `date_pneumococcal`, `date_flu`, `date_pertussis`, `date_shingles1`, `date_shingles2`, `q1_cough`, `q2_phlegm`, `q3_chest_tightness`, `q4_breathlessness`, `q5_activity_limitation`, `q6_confidence_leaving_home`, `q7_sleep_quality`, `q8_energy_level`, `average_score`, `created_at`, `updated_at`) VALUES
(1, 'pat_628', '28/10/2025', '28/10/2025', '28/10/2025', '28/10/2025', '', 2, 5, 3, 1, 3, 3, 2, 4, 2.88, '2025-10-28 18:55:50', '2025-10-28 18:55:50'),
(2, 'pat_133', '09/12/2027', '25/10/2025', '22/10/2025', '30/10/2025', '60/10/2025', 2, 2, 3, 3, 3, 3, 4, 4, 3.00, '2025-10-28 19:36:19', '2025-11-05 12:37:16'),
(3, 'pat_681', '31/10/2025', '31/10/2025', '31/10/2025', '31/10/2025', '31/09/2028', 2, 5, 3, 3, 4, 5, 2, 5, 3.63, '2025-10-29 08:35:41', '2025-10-31 12:39:40'),
(4, 'pat_037', '17/06/2025', '29/10/2025', '10/10/2025', '05/10/2025', '', 0, 5, 4, 5, 0, 2, 0, 0, 2.00, '2025-10-29 14:04:27', '2025-10-29 14:04:27'),
(5, 'pat_676', '', '', '', '', '', 1, 5, 2, 1, 3, 4, 2, 5, 2.88, '2025-10-31 12:59:33', '2025-10-31 12:59:33'),
(6, 'pat_954', '27/11/2025', '11/11/2025', '22/11/2025', '23/11/2025', '06/09/2023', 2, 4, 1, 5, 4, 3, 5, 5, 3.63, '2025-11-01 09:06:23', '2025-11-01 09:06:23'),
(7, 'pat_208', '04/11/2025', '04/11/2025', '04/11/2025', '04/11/2025', '04/11/2025', 6, 3, 1, 5, 3, 2, 2, 5, 3.38, '2025-11-04 13:37:54', '2025-11-04 13:37:54'),
(8, 'pat_857', '11/11/2025', '11/11/2025', '11/11/2025', '11/11/2025', 'NA', 2, 6, 4, 2, 1, 5, 5, 5, 3.75, '2025-11-11 13:52:17', '2025-11-11 13:52:17');

-- --------------------------------------------------------

--
-- Table structure for table `vaccine_dates`
--

CREATE TABLE `vaccine_dates` (
  `user_id` varchar(50) NOT NULL,
  `date_pneumococcal` varchar(20) DEFAULT NULL,
  `date_flu` varchar(20) DEFAULT NULL,
  `date_pertussis` varchar(20) DEFAULT NULL,
  `date_shingles1` varchar(20) DEFAULT NULL,
  `date_shingles2` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `youtube_videos`
--

CREATE TABLE `youtube_videos` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `youtube_url` varchar(500) NOT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `youtube_videos`
--

INSERT INTO `youtube_videos` (`id`, `title`, `youtube_url`, `uploaded_at`) VALUES
(1, 'Breathing Exercise Tutorial', 'https://www.youtube.com/watch?v=bWuB_zLcOL8', '2025-11-04 08:22:04'),
(2, 'Breathing Exercise Tutorial', 'https://www.youtube.com/watch?v=bWuB_zLcOL8', '2025-11-04 08:59:59'),
(3, 'Breathing Exercise Tutorial 2', 'https://youtu.be/bWuB_zLcOL8?si=zL00gVeAhOxWfh_z', '2025-11-04 09:05:49');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `abg_values`
--
ALTER TABLE `abg_values`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `patient_id` (`patient_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `doctors`
--
ALTER TABLE `doctors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `doctor_patients`
--
ALTER TABLE `doctor_patients`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `doctor_profile`
--
ALTER TABLE `doctor_profile`
  ADD PRIMARY KEY (`doctor_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `medication_diary`
--
ALTER TABLE `medication_diary`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patient_checkup`
--
ALTER TABLE `patient_checkup`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patient_profile`
--
ALTER TABLE `patient_profile`
  ADD PRIMARY KEY (`patient_id`);

--
-- Indexes for table `pft_values`
--
ALTER TABLE `pft_values`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `questionnaires`
--
ALTER TABLE `questionnaires`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `vaccine_dates`
--
ALTER TABLE `vaccine_dates`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `youtube_videos`
--
ALTER TABLE `youtube_videos`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `abg_values`
--
ALTER TABLE `abg_values`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `appointment_id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `doctors`
--
ALTER TABLE `doctors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `doctor_patients`
--
ALTER TABLE `doctor_patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctor_profile`
--
ALTER TABLE `doctor_profile`
  MODIFY `doctor_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `medication_diary`
--
ALTER TABLE `medication_diary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `patient_checkup`
--
ALTER TABLE `patient_checkup`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `pft_values`
--
ALTER TABLE `pft_values`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `questionnaires`
--
ALTER TABLE `questionnaires`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `youtube_videos`
--
ALTER TABLE `youtube_videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `abg_values`
--
ALTER TABLE `abg_values`
  ADD CONSTRAINT `abg_values_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `patient_checkup`
--
ALTER TABLE `patient_checkup`
  ADD CONSTRAINT `patient_checkup_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`);

--
-- Constraints for table `patient_profile`
--
ALTER TABLE `patient_profile`
  ADD CONSTRAINT `patient_profile_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `pft_values`
--
ALTER TABLE `pft_values`
  ADD CONSTRAINT `pft_values_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;

--
-- Constraints for table `questionnaires`
--
ALTER TABLE `questionnaires`
  ADD CONSTRAINT `questionnaires_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
