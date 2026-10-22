<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");

require_once "config.php";

$database = new Database();
$db = $database->connect();

try {
    // Select minimal data for doctor display
    $sql = "SELECT patient_id, name, age, diagnosis FROM patients ORDER BY name ASC";
    $stmt = $db->prepare($sql);
    $stmt->execute();

    $patients = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => "success", "data" => $patients]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
