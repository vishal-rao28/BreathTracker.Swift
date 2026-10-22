<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

try {
    $data = json_decode(file_get_contents("php://input"), true);
    $patient_id = $data['patient_id'] ?? null;

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    $db = (new Database())->connect();
    $stmt = $db->prepare("SELECT * FROM appointments WHERE patient_id = :patient_id LIMIT 1");
    $stmt->execute([':patient_id' => $patient_id]);

    if ($stmt->rowCount() === 0) {
        echo json_encode(["status" => "empty", "message" => "No appointment found"]);
        exit;
    }

    $appointment = $stmt->fetch(PDO::FETCH_ASSOC);
    echo json_encode(["status" => "success", "appointment" => $appointment]);

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>