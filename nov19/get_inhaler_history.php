<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$input = json_decode(file_get_contents('php://input'), true);

if (!isset($input['patient_id'])) {
    echo json_encode(["status" => "error", "message" => "Missing patient ID"]);
    exit();
}

$patient_id = $input['patient_id'];

try {
    $query = "SELECT date_taken FROM inhaler_adherence WHERE patient_id = :patient_id";
    $stmt = $db->prepare($query);

    $stmt->bindParam(':patient_id', $patient_id);
    $stmt->execute();

    $taken_dates = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $taken_dates[] = $row['date_taken'];
    }

    echo json_encode([
        "status" => "success",
        "taken_dates" => $taken_dates
    ]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>