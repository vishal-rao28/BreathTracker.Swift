<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

try {
    $data = json_decode(file_get_contents("php://input"), true);

    // ✅ Required field
    $patient_id = $data['patient_id'] ?? null;
    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    // 🧾 Patient info
    $name = trim($data['name'] ?? '');
    $age = intval($data['age'] ?? 0);
    $gender = trim($data['gender'] ?? 'Other');
    $contact = trim($data['contact'] ?? '');
    $email = trim($data['email'] ?? '');
    $address = trim($data['address'] ?? '');

    // 🩺 Medical info
    $copd_confirmed = !empty($data['copd_confirmed']) ? 1 : 0;
    $duration_symptoms = trim($data['duration_symptoms'] ?? '');
    $symptoms = !empty($data['symptoms']) ? implode(',', (array) $data['symptoms']) : '';
    $medications = trim($data['medications'] ?? '');
    $allergies = trim($data['allergies'] ?? '');
    $smoking_status = trim($data['smoking_status'] ?? 'Never Smoked');

    // 📅 Appointment details
    $preferred_date = trim($data['preferred_date'] ?? '');
    $preferred_time = !empty($data['preferred_time']) ? implode(',', (array) $data['preferred_time']) : '';
    $consultation_mode = !empty($data['consultation_mode']) ? implode(',', (array) $data['consultation_mode']) : '';

    // 🧠 Database connect
    $db = (new Database())->connect();

    // 🔍 Check if appointment exists
    $checkStmt = $db->prepare("SELECT appointment_id FROM appointments WHERE patient_id = :patient_id LIMIT 1");
    $checkStmt->execute([':patient_id' => $patient_id]);

    if ($checkStmt->rowCount() > 0) {
        // ✅ Update existing appointment
        $sql = "
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
                status = 'Pending',
                updated_at = NOW()
            WHERE patient_id = :patient_id
        ";
    } else {
        // ✅ Insert new appointment
        $sql = "
            INSERT INTO appointments (
                patient_id, name, age, gender, contact, email, address,
                copd_confirmed, duration_symptoms, symptoms,
                medications, allergies, smoking_status,
                preferred_date, preferred_time, consultation_mode,
                status, created_at
            ) VALUES (
                :patient_id, :name, :age, :gender, :contact, :email, :address,
                :copd_confirmed, :duration_symptoms, :symptoms,
                :medications, :allergies, :smoking_status,
                :preferred_date, :preferred_time, :consultation_mode,
                'Pending', NOW()
            )
        ";
    }

    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':patient_id' => $patient_id,
        ':name' => $name,
        ':age' => $age,
        ':gender' => $gender,
        ':contact' => $contact,
        ':email' => $email,
        ':address' => $address,
        ':copd_confirmed' => $copd_confirmed,
        ':duration_symptoms' => $duration_symptoms,
        ':symptoms' => $symptoms,
        ':medications' => $medications,
        ':allergies' => $allergies,
        ':smoking_status' => $smoking_status,
        ':preferred_date' => $preferred_date,
        ':preferred_time' => $preferred_time,
        ':consultation_mode' => $consultation_mode
    ]);

    $action = ($checkStmt->rowCount() > 0) ? "updated" : "submitted";
    echo json_encode(["status" => "success", "message" => "Appointment $action successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
} catch (Exception $e) {
    echo json_encode(["status" => "error", "message" => "Unexpected error: " . $e->getMessage()]);
}
?>