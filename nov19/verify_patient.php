<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['patient_id'])) {
    echo json_encode(["status" => "error", "message" => "Patient ID is required"]);
    exit;
}

$patient_id = trim($data['patient_id']);

try {
    $stmt = $db->prepare("SELECT id FROM patients WHERE patient_id = :patient_id LIMIT 1");
    $stmt->bindParam(":patient_id", $patient_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Patient ID verified"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Patient ID not found"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>