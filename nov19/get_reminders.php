<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once "config.php";

try {
    $conn = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    $patient_id = $data['patient_id'] ?? $_GET['patient_id'] ?? null;

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT reminder_id as id, title, body, due_date as dueDate, alarm_time as alarmTime, icon, color FROM patient_reminders WHERE patient_id = :pid");
    $stmt->execute([':pid' => $patient_id]);
    $reminders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => "success", "reminders" => $reminders]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "DB error: " . $e->getMessage()]);
}
?>