<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['patient_id']) || empty($data['description'])) {
    echo json_encode(["status" => "error", "message" => "Patient ID and description are required"]);
    exit;
}

$patient_id = trim($data['patient_id']);
$description = trim($data['description']);

try {
    $stmt = $db->prepare("INSERT INTO walk_test_reports (patient_id, description) VALUES (:patient_id, :description)");
    $stmt->bindParam(":patient_id", $patient_id);
    $stmt->bindParam(":description", $description);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "6 Min Walk Test report saved successfully!"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Failed to save the report."]);
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>