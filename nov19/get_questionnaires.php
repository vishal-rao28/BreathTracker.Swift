<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);
$patient_id = $data['patient_id'] ?? '';

if (empty($patient_id)) {
    echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
    exit;
}

$query = "SELECT * FROM questionnaires WHERE patient_id = :patient_id";
$stmt = $db->prepare($query);
$stmt->bindParam(":patient_id", $patient_id);
$stmt->execute();

if ($stmt->rowCount() > 0) {
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo json_encode(["status" => "success", "data" => $result]);
} else {
    echo json_encode(["status" => "error", "message" => "No record found"]);
}
?>
