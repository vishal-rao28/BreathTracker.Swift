<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

try {
    // ✅ Capture raw input for debugging
    $raw = file_get_contents("php://input");
    error_log("📥 RAW INPUT: " . $raw);

    $data = json_decode($raw, true);
    if (json_last_error() !== JSON_ERROR_NONE) {
        echo json_encode(["status" => "error", "message" => "Invalid JSON received"]);
        exit;
    }

    $patient_id = $data['patient_id'] ?? null;
    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    // ✅ Connect to DB
    $conn = (new Database())->connect();

    // ✅ Fetch patient info
    $stmt1 = $conn->prepare("SELECT patient_id, name, age, gender, height, weight, diagnosis, occupation 
                             FROM patients WHERE patient_id = :pid");
    $stmt1->execute([':pid' => $patient_id]);
    $patient = $stmt1->fetch(PDO::FETCH_ASSOC);

    if (!$patient) {
        echo json_encode(["status" => "error", "message" => "Patient not found"]);
        exit;
    }

    // ✅ Fetch vitals
    $stmt2 = $conn->prepare("SELECT temperature, oxygen_level, lung_function 
                             FROM patient_checkup WHERE patient_id = :pid ORDER BY updated_at DESC LIMIT 1");
    $stmt2->execute([':pid' => $patient_id]);
    $checkup = $stmt2->fetch(PDO::FETCH_ASSOC);

    // ✅ Fetch questionnaire
    $stmt3 = $conn->prepare("SELECT 
                                date_pneumococcal, date_flu, date_pertussis, 
                                date_shingles1, date_shingles2,
                                q1_cough, q2_phlegm, q3_chest_tightness, q4_breathlessness,
                                q5_activity_limitation, q6_confidence_leaving_home,
                                q7_sleep_quality, q8_energy_level,
                                average_score
                            FROM questionnaires WHERE patient_id = :pid");
    $stmt3->execute([':pid' => $patient_id]);
    $questionnaire = $stmt3->fetch(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "patient" => $patient,
        "checkup" => $checkup ?: new stdClass(),
        "questionnaire" => $questionnaire ?: new stdClass()
    ]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "DB error: " . $e->getMessage()]);
}
?>
