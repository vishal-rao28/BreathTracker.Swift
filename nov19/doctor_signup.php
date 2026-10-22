<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['doctor_id']) || !isset($data['password'])) {
    echo json_encode(["status" => "error", "message" => "Doctor ID or Password missing"]);
    exit;
}

$doctor_id = trim($data['doctor_id']);
$password = trim($data['password']);
$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$age = intval($data['age'] ?? 0);
$phone = trim($data['phone'] ?? '');

try {
    // Check if doctor_id already exists
    $stmt = $db->prepare("SELECT * FROM doctors WHERE doctor_id = :doctor_id");
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        echo json_encode(["status" => "error", "message" => "Doctor ID already exists"]);
        exit;
    }

    // Insert new doctor
    $stmt = $db->prepare("INSERT INTO doctors (doctor_id, password, name, email, age, phone) VALUES (:doctor_id, :password, :name, :email, :age, :phone)");
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->bindParam(":password", $password); // For security, consider password_hash()
    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":email", $email);
    $stmt->bindParam(":age", $age);
    $stmt->bindParam(":phone", $phone);
    $stmt->execute();

    echo json_encode(["status" => "success", "message" => "Doctor registered successfully"]);

} catch(PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
