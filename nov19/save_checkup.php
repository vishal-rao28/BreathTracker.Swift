<?php
header("Content-Type: application/json");
require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

// Accept either key
$patient_id = $data['patient_id'] ?? $data['user_id'] ?? null;
$temperature = $data['temperature'] ?? null;
$oxygen_level = $data['oxygen_level'] ?? null;
$lung_function = $data['lung_function'] ?? null;

if (empty($patient_id)) {
    echo json_encode(["success" => false, "message" => "Missing patient ID"]);
    exit;
}

try {
    $db = (new Database())->connect();

    // ✅ Check if patient checkup already exists
    $checkStmt = $db->prepare("SELECT * FROM patient_checkup WHERE patient_id = :pid LIMIT 1");
    $checkStmt->execute([':pid' => $patient_id]);
    $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        // 🧾 Update existing record
        $updateStmt = $db->prepare("
            UPDATE patient_checkup 
            SET 
                temperature = :temp, 
                oxygen_level = :oxy, 
                lung_function = :lung, 
                updated_at = NOW()
            WHERE patient_id = :pid
        ");
        $updateStmt->execute([
            ':pid' => $patient_id,
            ':temp' => $temperature,
            ':oxy' => $oxygen_level,
            ':lung' => $lung_function
        ]);
        echo json_encode(["success" => true, "message" => "Checkup data updated successfully"]);
    } else {
        // 🆕 Insert new record
        $insertStmt = $db->prepare("
            INSERT INTO patient_checkup (patient_id, temperature, oxygen_level, lung_function, created_at, updated_at) 
            VALUES (:pid, :temp, :oxy, :lung, NOW(), NOW())
        ");
        $insertStmt->execute([
            ':pid' => $patient_id,
            ':temp' => $temperature,
            ':oxy' => $oxygen_level,
            ':lung' => $lung_function
        ]);
        echo json_encode(["success" => true, "message" => "Checkup data submitted successfully"]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>