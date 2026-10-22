<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

require_once "config.php";

try {
    $conn = (new Database())->connect();

    $data = json_decode(file_get_contents("php://input"));
    $patient_id = $data->patient_id ?? $_GET['patient_id'] ?? '';

    if (empty($patient_id)) {
        echo json_encode(["status" => "error", "message" => "Missing patient_id"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT medicines, remarks FROM medication_diary WHERE patient_id = :pid LIMIT 1");
    $stmt->execute([':pid' => $patient_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($row) {
        echo json_encode([
            "status" => "success",
            "medicines" => json_decode($row['medicines'], true),
            "remarks" => $row['remarks']
        ]);
    } else {
        echo json_encode(["status" => "not_found", "message" => "No record found"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>