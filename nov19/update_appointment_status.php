<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
require_once "config.php";

try {
    $db = (new Database())->connect();
    $data = json_decode(file_get_contents("php://input"), true);

    if (empty($data['appointment_id']) || empty($data['status'])) {
        echo json_encode(["status" => "error", "message" => "Missing parameters"]);
        exit;
    }

    $stmt = $db->prepare("UPDATE appointments SET status = :status WHERE appointment_id = :id");
    $stmt->bindParam(":status", $data['status']);
    $stmt->bindParam(":id", $data['appointment_id']);
    $stmt->execute();

    echo json_encode(["status" => "success"]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>
