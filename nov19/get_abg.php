<?php
header("Content-Type: application/json");
require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);
$patient_id = $data['patient_id'] ?? null;

if (empty($patient_id)) {
    echo json_encode(["status" => "error", "message" => "Missing patient ID"]);
    exit;
}

try {
    $conn = (new Database())->connect();
    $stmt = $conn->prepare("SELECT * FROM abg_values WHERE patient_id = :pid LIMIT 1");
    $stmt->execute([':pid' => $patient_id]);
    $record = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($record) {
        // ✅ Determine condition
        $condition = "N/A";
        if ($record['normal']) $condition = "Normal";
        else if ($record['mild']) $condition = "Mild";
        else if ($record['moderate']) $condition = "Moderate";
        else if ($record['severe']) $condition = "Severe";

        $record['condition'] = $condition;
        // ✅ Add full image URL if available
        if (!empty($record['image_path'])) {
            $record['image_url'] = "http://172.20.10.3/breathtrack/" . $record['image_path'];
        }

        echo json_encode(["status" => "success", "data" => $record]);
    } else {
        echo json_encode(["status" => "empty", "message" => "No ABG record found for this patient"]);
    }

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
