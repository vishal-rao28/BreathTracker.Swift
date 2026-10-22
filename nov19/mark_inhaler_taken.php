<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['patient_id']) || !isset($input['date_taken'])) {
    echo json_encode(["status" => "error", "message" => "Missing data"]);
    exit();
}

$patient_id = $input['patient_id'];
$date_taken = $input['date_taken'];

try {
    $query = "INSERT IGNORE INTO inhaler_adherence (patient_id, date_taken) VALUES (:patient_id, :date_taken)";
    $stmt = $db->prepare($query);

    $stmt->bindParam(':patient_id', $patient_id);
    $stmt->bindParam(':date_taken', $date_taken);

    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Inhaler marked as taken"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Could not mark inhaler"]);
    }
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>