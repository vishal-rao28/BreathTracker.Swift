<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

// Read JSON input
$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['doctor_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Doctor ID is required"
    ]);
    exit;
}

$doctor_id = trim($data['doctor_id']);
$name = isset($data['name']) ? trim($data['name']) : '';
$email = isset($data['email']) ? trim($data['email']) : '';
$phone = isset($data['phone']) ? trim($data['phone']) : null;
$age = isset($data['age']) && $data['age'] !== '' ? intval($data['age']) : null;

if (empty($name)) {
    echo json_encode([
        "status" => "error",
        "message" => "Name cannot be empty"
    ]);
    exit;
}

try {
    // Check if doctor exists
    $check_stmt = $db->prepare("SELECT id FROM doctors WHERE doctor_id = :doctor_id LIMIT 1");
    $check_stmt->bindParam(":doctor_id", $doctor_id);
    $check_stmt->execute();

    if ($check_stmt->rowCount() === 0) {
        echo json_encode([
            "status" => "error",
            "message" => "Doctor not found"
        ]);
        exit;
    }

    // Update profile details
    $stmt = $db->prepare("
        UPDATE doctors 
        SET name = :name, 
            age = :age, 
            email = :email, 
            phone = :phone 
        WHERE doctor_id = :doctor_id
    ");

    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":age", $age, PDO::PARAM_INT);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":phone", $phone);
    $stmt->bindParam(":doctor_id", $doctor_id);

    if ($stmt->execute()) {
        echo json_encode([
            "status" => "success",
            "message" => "Profile updated successfully"
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Failed to update profile details"
        ]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>