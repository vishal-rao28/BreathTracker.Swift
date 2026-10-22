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

try {
    $stmt = $db->prepare("SELECT * FROM doctors WHERE doctor_id = :doctor_id LIMIT 1");
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->execute();

    if ($stmt->rowCount() === 1) {
        $doctor = $stmt->fetch(PDO::FETCH_ASSOC);
        $is_correct = false;
        if (password_verify($password, $doctor['password'])) {
            $is_correct = true;
        } else if ($password === $doctor['password']) {
            $is_correct = true;
        }

        if ($is_correct) {
            unset($doctor['password']);
            echo json_encode(["status" => "success", "message" => "Login successful", "name" => $doctor['name'], "data" => $doctor]);
        } else {
            echo json_encode(["status" => "error", "message" => "Invalid password"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Doctor not found"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>