<?php
header("Content-Type: application/json");
require_once "config.php";

$data = json_decode(file_get_contents("php://input"), true);

$patient_id = $data['patient_id'] ?? null;
if (empty($patient_id)) {
    echo json_encode(["status" => "error", "message" => "Missing patient ID"]);
    exit;
}

$normal = !empty($data['normal']) && $data['normal'] === "Yes" ? 1 : 0;
$mild = !empty($data['mild']) && $data['mild'] === "Yes" ? 1 : 0;
$moderate = !empty($data['moderate']) && $data['moderate'] === "Yes" ? 1 : 0;
$severe = !empty($data['severe']) && $data['severe'] === "Yes" ? 1 : 0;
$comments = $data['comments'] ?? "";
$image_base64 = $data['image'] ?? null;

// Save image file if provided
$image_path = null;
if (!empty($image_base64)) {
    $upload_dir = 'uploads/';
    if (!is_dir($upload_dir))
        mkdir($upload_dir, 0777, true);
    $file_name = $upload_dir . 'abg_report_' . time() . '_' . rand(100, 999) . '.jpg';
    if (file_put_contents($file_name, base64_decode($image_base64))) {
        $image_path = $file_name;
    }
}

try {
    $conn = (new Database())->connect();

    // ALWAYS INSERT a new row — this preserves full report history per patient
    $stmt = $conn->prepare("
        INSERT INTO abg_values (patient_id, normal, mild, moderate, severe, comments, image_path, created_at)
        VALUES (:pid, :normal, :mild, :moderate, :severe, :comments, :image_path, NOW())
    ");
    $stmt->execute([
        ':pid' => $patient_id,
        ':normal' => $normal,
        ':mild' => $mild,
        ':moderate' => $moderate,
        ':severe' => $severe,
        ':comments' => $comments,
        ':image_path' => $image_path
    ]);

    echo json_encode(["status" => "success", "message" => "ABG report submitted successfully"]);

} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>