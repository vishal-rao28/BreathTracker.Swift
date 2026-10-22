<?php
header("Content-Type: application/json");
require_once "config.php";

$patient_id = $_GET['patient_id'] ?? null;

if (empty($patient_id)) {
    echo json_encode(["success" => false, "message" => "Missing patient ID"]);
    exit;
}

try {
    $db = (new Database())->connect();
    $stmt = $db->prepare("SELECT temperature, oxygen_level, lung_function FROM patient_checkup WHERE patient_id = :pid LIMIT 1");
    $stmt->execute([':pid' => $patient_id]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($result) {
        echo json_encode(["success" => true, "data" => $result]);
    } else {
        echo json_encode(["success" => false, "message" => "No data found for patient"]);
    }
} catch (PDOException $e) {
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}
?>
