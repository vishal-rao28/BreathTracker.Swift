<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php";

try {
    $conn = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    // Accept both patient_id and user_id
    $patient_id = $data['patient_id'] ?? $data['user_id'] ?? null;
    $date_pneumococcal = $data['date_pneumococcal'] ?? null;
    $date_flu = $data['date_flu'] ?? null;
    $date_pertussis = $data['date_pertussis'] ?? null;
    $date_shingles1 = $data['date_shingles1'] ?? null;
    $date_shingles2 = $data['date_shingles2'] ?? null;

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    // Check if record already exists for this patient
    $checkStmt = $conn->prepare("SELECT id FROM questionnaires WHERE patient_id = :pid LIMIT 1");
    $checkStmt->execute([':pid' => $patient_id]);
    $existing = $checkStmt->fetch(PDO::FETCH_ASSOC);

    if ($existing) {
        // Update existing record
        $stmt = $conn->prepare("
            UPDATE questionnaires
            SET date_pneumococcal = :dp, date_flu = :df, date_pertussis = :dpe, 
                date_shingles1 = :ds1, date_shingles2 = :ds2, updated_at = NOW()
            WHERE patient_id = :pid
        ");
    } else {
        // Insert new record
        $stmt = $conn->prepare("
            INSERT INTO questionnaires (patient_id, date_pneumococcal, date_flu, date_pertussis, date_shingles1, date_shingles2, created_at, updated_at)
            VALUES (:pid, :dp, :df, :dpe, :ds1, :ds2, NOW(), NOW())
        ");
    }

    $stmt->execute([
        ':pid' => $patient_id,
        ':dp' => $date_pneumococcal,
        ':df' => $date_flu,
        ':dpe' => $date_pertussis,
        ':ds1' => $date_shingles1,
        ':ds2' => $date_shingles2
    ]);

    echo json_encode(["status" => "success", "message" => "Vaccine dates saved successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "DB error: " . $e->getMessage()]);
}
?>