<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php";

try {
    $conn = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    // ✅ Support both patient_id and user_id
    $patient_id = $data['patient_id'] ?? $data['user_id'] ?? null;
    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    // 🧭 Normalize optional vaccine dates
    $date_pneumococcal = $data['date_pneumococcal'] ?? null;
    $date_flu = $data['date_flu'] ?? null;
    $date_pertussis = $data['date_pertussis'] ?? null;
    $date_shingles1 = $data['date_shingles1'] ?? null;
    $date_shingles2 = $data['date_shingles2'] ?? null;

    // 🩺 Questionnaire answers
    $q1 = $data["q1_cough"] ?? null;
    $q2 = $data["q2_phlegm"] ?? null;
    $q3 = $data["q3_chest_tightness"] ?? null;
    $q4 = $data["q4_breathlessness"] ?? null;
    $q5 = $data["q5_activity_limitation"] ?? null;
    $q6 = $data["q6_confidence_leaving_home"] ?? null;
    $q7 = $data["q7_sleep_quality"] ?? null;
    $q8 = $data["q8_energy_level"] ?? null;

    // 📊 Calculate average score
    $answers = [$q1,$q2,$q3,$q4,$q5,$q6,$q7,$q8];
    $validAnswers = array_filter($answers,'is_numeric');
    $average_score = count($validAnswers) > 0 ? round(array_sum($validAnswers)/count($validAnswers), 2) : 0;

    // 🔍 Check if this patient already exists
    $check = $conn->prepare("SELECT id FROM questionnaires WHERE patient_id = :pid LIMIT 1");
    $check->execute([':pid' => $patient_id]);
    $exists = $check->fetch(PDO::FETCH_ASSOC);

    if ($exists) {
        // ✅ Update the existing record
        $update = $conn->prepare("
            UPDATE questionnaires SET
                date_pneumococcal = :dp,
                date_flu = :df,
                date_pertussis = :dpe,
                date_shingles1 = :ds1,
                date_shingles2 = :ds2,
                q1_cough = :q1,
                q2_phlegm = :q2,
                q3_chest_tightness = :q3,
                q4_breathlessness = :q4,
                q5_activity_limitation = :q5,
                q6_confidence_leaving_home = :q6,
                q7_sleep_quality = :q7,
                q8_energy_level = :q8,
                average_score = :avg,
                updated_at = NOW()
            WHERE patient_id = :pid
        ");
        $update->execute([
            ':pid' => $patient_id,
            ':dp' => $date_pneumococcal, ':df' => $date_flu, ':dpe' => $date_pertussis,
            ':ds1' => $date_shingles1, ':ds2' => $date_shingles2,
            ':q1' => $q1, ':q2' => $q2, ':q3' => $q3, ':q4' => $q4,
            ':q5' => $q5, ':q6' => $q6, ':q7' => $q7, ':q8' => $q8,
            ':avg' => $average_score
        ]);

        echo json_encode([
            "status" => "success",
            "message" => "Questionnaire updated successfully",
            "patient_id" => $patient_id,
            "average_score" => $average_score
        ]);
    } else {
        // 🆕 Insert a new record for new patient
        $insert = $conn->prepare("
            INSERT INTO questionnaires (
                patient_id,
                date_pneumococcal, date_flu, date_pertussis,
                date_shingles1, date_shingles2,
                q1_cough, q2_phlegm, q3_chest_tightness, q4_breathlessness,
                q5_activity_limitation, q6_confidence_leaving_home,
                q7_sleep_quality, q8_energy_level,
                average_score, created_at, updated_at
            ) VALUES (
                :pid,
                :dp, :df, :dpe, :ds1, :ds2,
                :q1, :q2, :q3, :q4,
                :q5, :q6, :q7, :q8,
                :avg, NOW(), NOW()
            )
        ");
        $insert->execute([
            ':pid' => $patient_id,
            ':dp' => $date_pneumococcal, ':df' => $date_flu, ':dpe' => $date_pertussis,
            ':ds1' => $date_shingles1, ':ds2' => $date_shingles2,
            ':q1' => $q1, ':q2' => $q2, ':q3' => $q3, ':q4' => $q4,
            ':q5' => $q5, ':q6' => $q6, ':q7' => $q7, ':q8' => $q8,
            ':avg' => $average_score
        ]);

        echo json_encode([
            "status" => "success",
            "message" => "Questionnaire submitted successfully",
            "patient_id" => $patient_id,
            "average_score" => $average_score
        ]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: ".$e->getMessage()]);
}
?>
