<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once "config.php";

try {
    $conn = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    $patient_id = $data['patient_id'] ?? null;
    $reminder_id = $data['id'] ?? $data['reminder_id'] ?? null;

    if (empty($patient_id) || empty($reminder_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id or reminder_id"]);
        exit;
    }

    $stmt = $conn->prepare("DELETE FROM patient_reminders WHERE patient_id = :pid AND reminder_id = :rid");
    $stmt->execute([':pid' => $patient_id, ':rid' => $reminder_id]);

    echo json_encode(["status" => "success", "message" => "Reminder deleted successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "DB error: " . $e->getMessage()]);
}
?>