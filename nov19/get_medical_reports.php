<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");

require_once "config.php";

$data = json_decode(file_get_contents("php://input"));
if (!isset($data->patient_id) || empty(trim($data->patient_id))) {
    echo json_encode(["status" => "error", "message" => "Patient ID is required"]);
    exit;
}

$patient_id = trim($data->patient_id);

try {
    $db = (new Database())->connect();

    // Fetch PFT
    $pftStmt = $db->prepare("SELECT id, normal, mild, moderate, severe, comments, image_path, created_at FROM pft_values WHERE patient_id = :pid ORDER BY created_at DESC");
    $pftStmt->execute([':pid' => $patient_id]);
    $pftRecords = $pftStmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch ABG
    $abgStmt = $db->prepare("SELECT id, normal, mild, moderate, severe, comments, image_path, created_at FROM abg_values WHERE patient_id = :pid ORDER BY created_at DESC");
    $abgStmt->execute([':pid' => $patient_id]);
    $abgRecords = $abgStmt->fetchAll(PDO::FETCH_ASSOC);

    // Fetch Walk Test
    $walkStmt = $db->prepare("SELECT id, description, created_at FROM walk_test_reports WHERE patient_id = :pid ORDER BY created_at DESC");
    $walkStmt->execute([':pid' => $patient_id]);
    $walkRecords = $walkStmt->fetchAll(PDO::FETCH_ASSOC);

    $formatRecord = function ($record) {
        $condition = "Unknown";
        if ($record['normal'])
            $condition = "Normal";
        else if ($record['mild'])
            $condition = "Mild";
        else if ($record['moderate'])
            $condition = "Moderate";
        else if ($record['severe'])
            $condition = "Severe";

        return [
            "id" => $record['id'],
            "condition" => $condition,
            "comments" => $record['comments'] ?? "",
            "image_path" => $record['image_path'],
            "created_at" => $record['created_at']
        ];
    };

    $formatWalk = function ($record) {
        return [
            "id" => $record['id'],
            "description" => $record['description'],
            "created_at" => $record['created_at']
        ];
    };

    echo json_encode([
        "status" => "success",
        "patient_id" => $patient_id,
        "pft_history" => array_map($formatRecord, $pftRecords),
        "abg_history" => array_map($formatRecord, $abgRecords),
        "walk_test_history" => array_map($formatWalk, $walkRecords)
    ]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>