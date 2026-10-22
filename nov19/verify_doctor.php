<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['doctor_id'])) {
    echo json_encode(["status" => "error", "message" => "Doctor ID is required"]);
    exit;
}

$doctor_id = trim($data['doctor_id']);

try {
    $stmt = $db->prepare("SELECT id FROM doctors WHERE doctor_id = :doctor_id LIMIT 1");
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Doctor ID verified"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor ID not found"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>