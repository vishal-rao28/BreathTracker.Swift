<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['phone_number'])) {
    echo json_encode(["status" => "error", "message" => "Phone number is required"]);
    exit;
}

$phone_number = trim($data['phone_number']);

try {
    $stmt = $db->prepare("SELECT patient_id FROM patients WHERE phone_number = :phone_number LIMIT 1");
    $stmt->bindParam(":phone_number", $phone_number);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $patient = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(["status" => "success", "patient_id" => $patient['patient_id']]);
    } else {
        echo json_encode(["status" => "error", "message" => "No account found with this phone number."]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>