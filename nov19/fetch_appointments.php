<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET");

require_once "config.php";

try {
    $db = (new Database())->connect();

    // Fetch all appointments including gender and address
    $stmt = $db->prepare("
        SELECT 
            appointment_id,
            patient_id,
            name,
            age,
            gender,
            contact,
            email,
            address,
            duration_symptoms,
            copd_confirmed,
            symptoms,
            medications,
            allergies,
            smoking_status,
            preferred_date,
            preferred_time,
            consultation_mode,
            status,
            created_at
        FROM appointments
        ORDER BY created_at DESC
    ");
    $stmt->execute();

    $appointments = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "appointments" => $appointments
    ]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
