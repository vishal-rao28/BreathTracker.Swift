<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

try {
    $db = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    $patient_id = $data['patient_id'] ?? null;
    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    // Patient fields
    $fields = [
        'name', 'age', 'gender', 'contact', 'email', 'address',
        'copd_confirmed', 'duration_symptoms', 'symptoms',
        'medications', 'allergies', 'smoking_status',
        'preferred_date', 'preferred_time', 'consultation_mode'
    ];
    $values = [];
    foreach ($fields as $f) $values[$f] = trim($data[$f] ?? '');

    // Check if appointment exists for this patient
    $check = $db->prepare("SELECT appointment_id FROM appointments WHERE patient_id = :pid LIMIT 1");
    $check->execute([':pid' => $patient_id]);

    if ($check->rowCount() > 0) {
        // ✅ Update only this patient's data
        $update = $db->prepare("
            UPDATE appointments SET
                name = :name,
                age = :age,
                gender = :gender,
                contact = :contact,
                email = :email,
                address = :address,
                copd_confirmed = :copd_confirmed,
                duration_symptoms = :duration_symptoms,
                symptoms = :symptoms,
                medications = :medications,
                allergies = :allergies,
                smoking_status = :smoking_status,
                preferred_date = :preferred_date,
                preferred_time = :preferred_time,
                consultation_mode = :consultation_mode,
                updated_at = NOW()
            WHERE patient_id = :pid
        ");
        $update->execute(array_merge($values, [':pid' => $patient_id]));
        echo json_encode(["status" => "success", "message" => "Appointment updated successfully"]);
    } else {
        // 🆕 Insert new appointment for this patient
        $insert = $db->prepare("
            INSERT INTO appointments (
                patient_id, name, age, gender, contact, email, address,
                copd_confirmed, duration_symptoms, symptoms,
                medications, allergies, smoking_status,
                preferred_date, preferred_time, consultation_mode
            ) VALUES (
                :pid, :name, :age, :gender, :contact, :email, :address,
                :copd_confirmed, :duration_symptoms, :symptoms,
                :medications, :allergies, :smoking_status,
                :preferred_date, :preferred_time, :consultation_mode
            )
        ");
        $insert->execute(array_merge($values, [':pid' => $patient_id]));
        echo json_encode(["status" => "success", "message" => "Appointment created successfully"]);
    }

} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
