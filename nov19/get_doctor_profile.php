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

try {
    $stmt = $db->prepare("
        SELECT doctor_id, name, age, email, phone 
        FROM doctors 
        WHERE doctor_id = :doctor_id 
        LIMIT 1
    ");
    $stmt->bindParam(":doctor_id", $doctor_id);
    $stmt->execute();

    if ($stmt->rowCount() === 1) {
        $doctor = $stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode([
            "status" => "success",
            "message" => "Profile fetched successfully",
            "data" => $doctor
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Doctor not found"
        ]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>
