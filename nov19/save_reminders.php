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
    $reminders = $data['reminders'] ?? [];

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    $conn->beginTransaction();

    // 1. Delete existing vaccine reminders first to handle deactivated/cancelled ones
    $deleteStmt = $conn->prepare("DELETE FROM patient_reminders WHERE patient_id = :pid AND reminder_id LIKE 'vaccine_%'");
    $deleteStmt->execute([':pid' => $patient_id]);

    // 2. Insert new list of reminders
    if (!empty($reminders) && is_array($reminders)) {
        $insertStmt = $conn->prepare("
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

        foreach ($reminders as $r) {
            $rid = $r['id'] ?? null;
            $title = $r['title'] ?? '';
            $body = $r['body'] ?? '';
            $due_date = $r['dueDate'] ?? $r['due_date'] ?? '';
            $alarm_time = $r['alarmTime'] ?? $r['alarm_time'] ?? '';
            $icon = $r['icon'] ?? '';
            $color = $r['color'] ?? '';

            if ($rid) {
                $insertStmt->execute([
                    ':pid' => $patient_id,
                    ':rid' => $rid,
                    ':title' => $title,
                    ':body' => $body,
                    ':due_date' => $due_date,
                    ':alarm_time' => $alarm_time,
                    ':icon' => $icon,
                    ':color' => $color
                ]);
            }
        }
    }

    $conn->commit();
    echo json_encode(["status" => "success", "message" => "Reminders batch updated successfully"]);

} catch (Exception $e) {
    if (isset($conn) && $conn->inTransaction()) {
        $conn->rollBack();
    }
    echo json_encode(["status" => "error", "message" => "Transaction error: " . $e->getMessage()]);
}
?>