<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

$database = new Database();
$db = $database->connect();

$data = json_decode(file_get_contents("php://input"), true);

// Required fields
$required = ['name', 'age', 'gender', 'height', 'weight', 'diagnosis', 'occupation', 'phone_number', 'password'];
foreach ($required as $field) {
    if (empty($data[$field])) {
        echo json_encode(["status" => "error", "message" => "$field is required"]);
        exit;
    }
}

$name = trim($data['name']);
$age = intval($data['age']);
$gender = trim($data['gender']);
$height = floatval($data['height']);
$weight = floatval($data['weight']);
$diagnosis = trim($data['diagnosis']);
$occupation = trim($data['occupation']);
$phone_number = trim($data['phone_number']);
$password = trim($data['password']);
$hashed_password = password_hash($password, PASSWORD_BCRYPT);

// ✅ Generate unique Patient ID only here
do {
    $random = rand(1, 999);
    $patient_id = sprintf("pat_%03d", $random);
    $stmt = $db->prepare("SELECT COUNT(*) FROM patients WHERE patient_id = :pid");
    $stmt->bindParam(":pid", $patient_id);
    $stmt->execute();
    $exists = $stmt->fetchColumn();
} while ($exists > 0);

try {
    $stmt = $db->prepare("INSERT INTO patients (patient_id, name, age, gender, height, weight, diagnosis, occupation, phone_number, password)
                          VALUES (:pid, :name, :age, :gender, :height, :weight, :diagnosis, :occupation, :phone_number, :password)");
    $stmt->bindParam(":pid", $patient_id);
    $stmt->bindParam(":name", $name);
    $stmt->bindParam(":age", $age);
    $stmt->bindParam(":gender", $gender);
    $stmt->bindParam(":height", $height);
    $stmt->bindParam(":weight", $weight);
    $stmt->bindParam(":diagnosis", $diagnosis);
    $stmt->bindParam(":occupation", $occupation);
    $stmt->bindParam(":phone_number", $phone_number);
    $stmt->bindParam(":password", $hashed_password);
    $stmt->execute();

    echo json_encode(["status" => "success", "message" => "Signup successful", "patient_id" => $patient_id]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>