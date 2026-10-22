<?php
require_once "config.php";
$database = new Database();
$db = $database->connect();

try {
    // 1. Hash Patient Passwords
    $stmt = $db->query("SELECT id, password FROM patients");
    $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($patients as $p) {
        if (strlen($p['password']) < 30) { // Plaintext passwords are short, hashed are 60+
            $hashed = password_hash($p['password'], PASSWORD_DEFAULT);
            $update = $db->prepare("UPDATE patients SET password = :p WHERE id = :id");
            $update->execute([':p' => $hashed, ':id' => $p['id']]);
            echo "Hashed patient ID " . $p['id'] . "\n";
        }
    }

    // 2. Hash Doctor Passwords
    $stmt = $db->query("SELECT id, password FROM doctors");
    $doctors = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($doctors as $d) {
        if (strlen($d['password']) < 30) {
            $hashed = password_hash($d['password'], PASSWORD_DEFAULT);
            $update = $db->prepare("UPDATE doctors SET password = :p WHERE id = :id");
            $update->execute([':p' => $hashed, ':id' => $d['id']]);
            echo "Hashed doctor ID " . $d['id'] . "\n";
        }
    }

    // 3. Create missing 'videos' table if needed
    $db->exec("CREATE TABLE IF NOT EXISTS `videos` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `title` varchar(255) NOT NULL,
        `description` text DEFAULT NULL,
        `file_name` varchar(255) DEFAULT NULL,
        `video_url` varchar(500) DEFAULT NULL,
        `file_size` bigint(20) DEFAULT NULL,
        `video_type` varchar(50) DEFAULT 'local',
        `upload_date` timestamp NOT NULL DEFAULT current_timestamp(),
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;");
    echo "Videos table verified.\n";

    // Create patient_reminders table if needed
    $db->exec("CREATE TABLE IF NOT EXISTS `patient_reminders` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `patient_id` varchar(50) NOT NULL,
        `reminder_id` varchar(100) NOT NULL,
        `title` varchar(255) NOT NULL,
        `body` text NOT NULL,
        `due_date` varchar(20) NOT NULL,
        `alarm_time` varchar(10) NOT NULL,
        `icon` varchar(50) NOT NULL,
        `color` varchar(50) NOT NULL,
        UNIQUE KEY `pat_rem_unique` (`patient_id`, `reminder_id`),
        CONSTRAINT `fk_patient_reminders` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`patient_id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;");
    echo "patient_reminders table verified.\n";

    // 4. Cleanup redundant tables
    try {
        $db->exec("DROP TABLE IF EXISTS doctor_profile;");
        $db->exec("DROP TABLE IF EXISTS patient_profile;");
        echo "Redundant profile tables removed.\n";
    } catch (Exception $e) {
        echo "Profile tables already gone or not found.\n";
    }

    echo "Migration completed successfully.";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>