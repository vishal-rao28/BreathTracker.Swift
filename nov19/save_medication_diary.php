<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php";

try {
    $conn = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    // ✅ Input validation
    $patient_id = $data['patient_id'] ?? null;
    $medicines = $data['medicines'] ?? [];
    $remarks = trim($data['remarks'] ?? '');

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    if (empty($medicines) || !is_array($medicines)) {
        echo json_encode(["status" => "error", "message" => "No medicines selected"]);
        exit;
    }

    // ✅ Convert medicine array to JSON string
    $medicines_json = json_encode($medicines, JSON_UNESCAPED_UNICODE);

    // ✅ Check if record already exists for this patient
    $checkStmt = $conn->prepare("SELECT id FROM medication_diary WHERE patient_id = :pid LIMIT 1");
    $checkStmt->execute([':pid' => $patient_id]);
    $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        // 🔁 Update existing record
        $stmt = $conn->prepare("
            UPDATE medication_diary
            SET medicines = :medicines, remarks = :remarks, updated_at = NOW()
            WHERE patient_id = :pid
        ");
        $stmt->execute([
            ':pid' => $patient_id,
            ':medicines' => $medicines_json,
            ':remarks' => $remarks
        ]);
        $action = "updated";
    } else {
        // 🆕 Insert new record
        $stmt = $conn->prepare("
            INSERT INTO medication_diary (patient_id, medicines, remarks, created_at)
            VALUES (:pid, :medicines, :remarks, NOW())
        ");
        $stmt->execute([
            ':pid' => $patient_id,
            ':medicines' => $medicines_json,
            ':remarks' => $remarks
        ]);
        $action = "added";
    }

    echo json_encode(["status" => "success", "message" => "Medication diary $action successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
