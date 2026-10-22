<?php
header("Content-Type: application/json; charset=UTF-8");
require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data['patient_id']) || empty($data['password'])) {
    echo json_encode(["status" => "error", "message" => "Missing patient ID or password"]);
    exit;
}

$patient_id = trim($data['patient_id']);
$password = trim($data['password']);

try {
    $conn = (new Database())->connect();

    // 🩺 Fetch patient details
    $stmt = $conn->prepare("SELECT * FROM patients WHERE patient_id = :patient_id AND password = :password LIMIT 1");
    $stmt->bindParam(":patient_id", $patient_id);
    $stmt->bindParam(":password", $password);
    $stmt->execute();

    if ($stmt->rowCount() === 0) {
        echo json_encode(["status" => "error", "message" => "Invalid patient ID or password"]);
        exit;
    }

    $patient = $stmt->fetch(PDO::FETCH_ASSOC);

    // ✅ Fetch latest questionnaire score for this specific patient
    $stmt2 = $conn->prepare("
        SELECT average_score 
        FROM questionnaires 
        WHERE patient_id = :patient_id 
        ORDER BY updated_at DESC 
        LIMIT 1
    ");
    $stmt2->bindParam(":patient_id", $patient_id);
    $stmt2->execute();
    $result = $stmt2->fetch(PDO::FETCH_ASSOC);

    $average_score = $result ? floatval($result['average_score']) : 0.0;

    // 🧩 Combine final response
    echo json_encode([
        "status" => "success",
        "data" => [
            "name" => $patient['name'],
            "age" => $patient['age'],
            "gender" => $patient['gender'],
            "height" => $patient['height'],
            "weight" => $patient['weight'],
            "diagnosis" => $patient['diagnosis'],
            "occupation" => $patient['occupation'],
            "my_analysis" => $average_score
        ]
    ]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
