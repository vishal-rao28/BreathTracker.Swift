<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
require_once "config.php";

try {
    $db = (new Database())->connect();

    // Fetch patients
    $stmt = $db->query("SELECT * FROM doctor_patients ORDER BY name ASC");
    $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => "success", "patients" => $patients]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
