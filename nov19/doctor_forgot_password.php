<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['doctor_id']) || empty($data['new_password'])) {
    echo json_encode(["status" => "error", "message" => "Doctor ID and new password are required"]);
    exit;
}

$doctor_id = trim($data['doctor_id']);
$new_password = trim($data['new_password']);
$hashed_password = password_hash($new_password, PASSWORD_BCRYPT);

try {
    $stmt = $db->prepare("UPDATE doctors SET password = :password WHERE doctor_id = :doctor_id");
    $stmt->bindParam(":password", $hashed_password);
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "success", "message" => "Password updated successfully"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor ID not found or password unchanged"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => "Database error: " . $e->getMessage()]);
}
?>