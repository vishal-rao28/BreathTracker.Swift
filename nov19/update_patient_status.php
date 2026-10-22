<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

try {
    $data = json_decode(file_get_contents("php://input"), true);
    $patient_id = $data['patient_id'] ?? '';
    $status = $data['status'] ?? '';

    if (empty($patient_id) || empty($status)) {
        echo json_encode(["status" => "error", "message" => "Missing parameters"]);
        exit;
    }

    $db = (new Database())->connect();
    $stmt = $db->prepare("UPDATE doctor_patients SET status = :status WHERE patient_id = :pid");
    $stmt->execute([':status' => $status, ':pid' => $patient_id]);

    echo json_encode(["status" => "success", "message" => "Status updated successfully"]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
