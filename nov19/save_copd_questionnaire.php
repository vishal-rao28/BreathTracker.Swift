<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php"; // include your Database class file

$db = new Database();
$conn = $db->connect();

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);
if (!$data) {
    echo json_encode(["status" => "error", "message" => "Invalid input."]);
    exit;
}

// --- Extract fields ---
$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;

$q1 = isset($data["q1_cough"]) ? intval($data["q1_cough"]) : null;
$q2 = isset($data["q2_phlegm"]) ? intval($data["q2_phlegm"]) : null;
$q3 = isset($data["q3_chest_tightness"]) ? intval($data["q3_chest_tightness"]) : null;
$q4 = isset($data["q4_breathlessness"]) ? intval($data["q4_breathlessness"]) : null;
$q5 = isset($data["q5_activity_limitation"]) ? intval($data["q5_activity_limitation"]) : null;
$q6 = isset($data["q6_confidence_leaving_home"]) ? intval($data["q6_confidence_leaving_home"]) : null;
$q7 = isset($data["q7_sleep_quality"]) ? intval($data["q7_sleep_quality"]) : null;
$q8 = isset($data["q8_energy_level"]) ? intval($data["q8_energy_level"]) : null;

$date_pneumococcal = !empty($data["date_pneumococcal"]) ? $data["date_pneumococcal"] : null;
$date_flu = !empty($data["date_flu"]) ? $data["date_flu"] : null;
$date_pertussis = !empty($data["date_pertussis"]) ? $data["date_pertussis"] : null;
$date_shingles1 = !empty($data["date_shingles1"]) ? $data["date_shingles1"] : null;
$date_shingles2 = !empty($data["date_shingles2"]) ? $data["date_shingles2"] : null;

// --- Calculate total score ---
$total_score = 0;
$answers = [$q1, $q2, $q3, $q4, $q5, $q6, $q7, $q8];
foreach ($answers as $a) {
    if ($a !== null) $total_score += $a;
}

// --- Check if questionnaire exists ---
try {
    $checkStmt = $conn->prepare("SELECT id FROM questionnaires WHERE user_id = ?");
    $checkStmt->execute([$user_id]);

    if ($checkStmt->rowCount() > 0) {
        // --- Update existing record ---
        $sql = "UPDATE questionnaires SET 
                    q1_cough=:q1, q2_phlegm=:q2, q3_chest_tightness=:q3, q4_breathlessness=:q4,
                    q5_activity_limitation=:q5, q6_confidence_leaving_home=:q6,
                    q7_sleep_quality=:q7, q8_energy_level=:q8,
                    date_pneumococcal=:dp, date_flu=:df, date_pertussis=:dpe,
                    date_shingles1=:ds1, date_shingles2=:ds2,
                    updated_at=NOW()
                WHERE user_id=:uid";
    } else {
        // --- Insert new record ---
        $sql = "INSERT INTO questionnaires (
                    user_id, q1_cough, q2_phlegm, q3_chest_tightness, q4_breathlessness,
                    q5_activity_limitation, q6_confidence_leaving_home,
                    q7_sleep_quality, q8_energy_level,
                    date_pneumococcal, date_flu, date_pertussis, date_shingles1, date_shingles2
                ) VALUES (
                    :uid, :q1, :q2, :q3, :q4, :q5, :q6, :q7, :q8, :dp, :df, :dpe, :ds1, :ds2
                )";
    }

    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':uid' => $user_id,
        ':q1' => $q1, ':q2' => $q2, ':q3' => $q3, ':q4' => $q4,
        ':q5' => $q5, ':q6' => $q6, ':q7' => $q7, ':q8' => $q8,
        ':dp' => $date_pneumococcal,
        ':df' => $date_flu,
        ':dpe' => $date_pertussis,
        ':ds1' => $date_shingles1,
        ':ds2' => $date_shingles2
    ]);

    echo json_encode([
        "status" => "success",
        "message" => "Questionnaire saved successfully.",
        "user_id" => $user_id,
        "total_score" => $total_score
    ]);
} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>
