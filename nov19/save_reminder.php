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
    $reminder_id = $data['id'] ?? null;
    $title = $data['title'] ?? '';
    $body = $data['body'] ?? '';
    // map either due_date or dueDate
    $due_date = $data['due_date'] ?? $data['dueDate'] ?? '';
    // map either alarm_time or alarmTime
    $alarm_time = $data['alarm_time'] ?? $data['alarmTime'] ?? '';
    $icon = $data['icon'] ?? '';
    $color = $data['color'] ?? '';

    if (empty($patient_id) || empty($reminder_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id or reminder ID"]);
        exit;
    }

    $stmt = $conn->prepare("
        INSERT INTO patient_reminders (patient_id, reminder_id, title, body, due_date, alarm_time, icon, color)
        VALUES (:pid, :rid, :title, :body, :due_date, :alarm_time, :icon, :color)
        ON DUPLICATE KEY UPDATE 
            title = VALUES(title),
            body = VALUES(body),
            due_date = VALUES(due_date),
            alarm_time = VALUES(alarm_time),
            icon = VALUES(icon),
            color = VALUES(color)
    ");

    $stmt->execute([
        ':pid' => $patient_id,
        ':rid' => $reminder_id,
        ':title' => $title,
        ':body' => $body,
        ':due_date' => $due_date,
        ':alarm_time' => $alarm_time,
        ':icon' => $icon,
        ':color' => $color
    ]);

    echo json_encode(["status" => "success", "message" => "Reminder saved successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "DB error: " . $e->getMessage()]);
}
?>