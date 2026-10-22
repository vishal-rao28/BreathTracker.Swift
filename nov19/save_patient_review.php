<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php";

$db = new Database();
$conn = $db->connect();

// Get JSON input
$data = json_decode(file_get_contents("php://input"), true);
if (!$data) {
    echo json_encode(["status" => "error", "message" => "Invalid input."]);
    exit;
}

$user_id = isset($data["user_id"]) ? intval($data["user_id"]) : 0;
$name = $data["name"] ?? null;
$age = $data["age"] ?? null;
$gender = $data["gender"] ?? null;
$height = $data["height"] ?? null;
$weight = $data["weight"] ?? null;
$diagnosis = $data["diagnosis"] ?? null;
$occupation = $data["occupation"] ?? null;

// --- Collect COPD question scores ---
$q = [];
for ($i = 1; $i <= 8; $i++) {
    $key = "q$i";
    $q[$i] = isset($data[$key]) ? floatval($data[$key]) : 0;
}

// --- Compute Average ---
$total = array_sum($q);
$average_score = $total / 8;

// --- Check if record exists for this user ---
try {
    $check = $conn->prepare("SELECT id FROM patient_reviews WHERE user_id = ?");
    $check->execute([$user_id]);

    if ($check->rowCount() > 0) {
        // Update existing record
        $sql = "UPDATE patient_reviews SET 
                    name=:name, age=:age, gender=:gender, height=:height, weight=:weight,
                    diagnosis=:diagnosis, occupation=:occupation, average_score=:avg,
                    updated_at=NOW()
                WHERE user_id=:uid";
    } else {
        // Insert new record
        $sql = "INSERT INTO patient_reviews 
                (user_id, name, age, gender, height, weight, diagnosis, occupation, average_score)
                VALUES 
                (:uid, :name, :age, :gender, :height, :weight, :diagnosis, :occupation, :avg)";
    }

    $stmt = $conn->prepare($sql);
    $stmt->execute([
        ':uid' => $user_id,
        ':name' => $name,
        ':age' => $age,
        ':gender' => $gender,
        ':height' => $height,
        ':weight' => $weight,
        ':diagnosis' => $diagnosis,
        ':occupation' => $occupation,
        ':avg' => $average_score
    ]);

    echo json_encode([
        "status" => "success",
        "message" => "Patient review saved successfully.",
        "average_score" => $average_score
    ]);

} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Database error: " . $e->getMessage()
    ]);
}
?>
