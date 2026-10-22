<?php
// video_api.php - Video Upload & Retrieve API (Works with Database Class)

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET');
header('Access-Control-Allow-Headers: Content-Type');

// Include database configuration
require_once 'config.php';

// Create database connection
$database = new Database();
$pdo = $database->connect();

// Check if connection is successful
if (!$pdo) {
    die(json_encode(['status' => 'error', 'message' => 'Database connection failed']));
}

// ====================================
// BASE URL CONFIGURATION
// ====================================
$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
$host = $_SERVER['HTTP_HOST'];
$scriptPath = dirname($_SERVER['SCRIPT_NAME']);
$baseUrl = $protocol . "://" . $host . $scriptPath . "/";

// ====================================
// VIDEO UPLOAD DIRECTORY
// ====================================
$uploadDir = 'uploads/videos/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Maximum file size (300MB)
$maxFileSize = 300 * 1024 * 1024;

// Allowed video formats
$allowedFormats = ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', '3gp'];

// ====================================
// DETERMINE REQUEST TYPE
// ====================================
$requestMethod = $_SERVER['REQUEST_METHOD'];

if ($requestMethod === 'POST') {
    if (isset($_POST['action'])) {
        $action = $_POST['action'];

        if ($action === 'upload' && isset($_FILES['video'])) {
            // Local video upload
            handleVideoUpload($pdo, $uploadDir, $maxFileSize, $allowedFormats, $baseUrl);
        } elseif ($action === 'add_url') {
            // Add video URL (YouTube, Vimeo, etc.)
            handleVideoUrl($pdo);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Invalid action']);
        }
    } else {
        handleDataSubmission($pdo);
    }
} elseif ($requestMethod === 'GET') {
    handleVideoRetrieval($pdo);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Invalid request method']);
}

// ====================================
// FUNCTION: UPLOAD LOCAL VIDEO
// ====================================
function handleVideoUpload($pdo, $uploadDir, $maxFileSize, $allowedFormats, $baseUrl)
{
    try {
        $title = $_POST['title'] ?? 'Untitled Video';
        $description = $_POST['description'] ?? '';

        // Validate file upload
        if (!isset($_FILES['video']) || $_FILES['video']['error'] !== UPLOAD_ERR_OK) {
            echo json_encode(['status' => 'error', 'message' => 'Video upload failed']);
            return;
        }

        $file = $_FILES['video'];
        $fileName = $file['name'];
        $fileTmpName = $file['tmp_name'];
        $fileSize = $file['size'];

        // Check file size
        if ($fileSize > $maxFileSize) {
            echo json_encode(['status' => 'error', 'message' => 'File size exceeds 300MB limit']);
            return;
        }

        // Get file extension
        $fileExtension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));

        // Validate file format
        if (!in_array($fileExtension, $allowedFormats)) {
            echo json_encode(['status' => 'error', 'message' => 'Invalid file format. Allowed: ' . implode(', ', $allowedFormats)]);
            return;
        }

        // Generate unique filename
        $uniqueFileName = uniqid('video_', true) . '.' . $fileExtension;
        $relativePath = $uploadDir . $uniqueFileName;

        // Create full URL for database storage
        $videoUrl = $baseUrl . $relativePath;

        // Move uploaded file
        if (!move_uploaded_file($fileTmpName, $relativePath)) {
            echo json_encode(['status' => 'error', 'message' => 'Failed to save video file']);
            return;
        }

        // Insert video record into database
        $stmt = $pdo->prepare("
            INSERT INTO videos (title, description, file_name, video_url, file_size, video_type, upload_date) 
            VALUES (:title, :description, :file_name, :video_url, :file_size, 'local', NOW())
        ");

        $stmt->execute([
            ':title' => $title,
            ':description' => $description,
            ':file_name' => $uniqueFileName,
            ':video_url' => $videoUrl,
            ':file_size' => $fileSize
        ]);

        $videoId = $pdo->lastInsertId();

        echo json_encode([
            'status' => 'success',
            'message' => 'Video uploaded successfully',
            'video_id' => $videoId,
            'file_name' => $uniqueFileName,
            'video_url' => $videoUrl,
            'video_type' => 'local',
            'file_size' => $fileSize
        ]);

    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Upload error: ' . $e->getMessage()]);
    }
}

// ====================================
// FUNCTION: ADD VIDEO URL (YouTube, etc.)
// ====================================
function handleVideoUrl($pdo)
{
    try {
        $videoUrl = $_POST['video_url'] ?? '';
        $title = $_POST['title'] ?? 'Untitled Video';
        $description = $_POST['description'] ?? '';

        // Validate URL
        if (empty($videoUrl)) {
            echo json_encode(['status' => 'error', 'message' => 'Video URL is required']);
            return;
        }

        if (!filter_var($videoUrl, FILTER_VALIDATE_URL)) {
            echo json_encode(['status' => 'error', 'message' => 'Invalid URL format']);
            return;
        }

        // Detect video type
        $videoType = 'external';
        if (strpos($videoUrl, 'youtube.com') !== false || strpos($videoUrl, 'youtu.be') !== false) {
            $videoType = 'youtube';
        } elseif (strpos($videoUrl, 'vimeo.com') !== false) {
            $videoType = 'vimeo';
        } elseif (strpos($videoUrl, 'dailymotion.com') !== false) {
            $videoType = 'dailymotion';
        }

        // Insert video URL into database
        $stmt = $pdo->prepare("
            INSERT INTO videos (title, description, video_url, video_type, upload_date) 
            VALUES (:title, :description, :video_url, :video_type, NOW())
        ");

        $stmt->execute([
            ':title' => $title,
            ':description' => $description,
            ':video_url' => $videoUrl,
            ':video_type' => $videoType
        ]);

        $videoId = $pdo->lastInsertId();

        echo json_encode([
            'status' => 'success',
            'message' => 'Video URL added successfully',
            'video_id' => $videoId,
            'video_url' => $videoUrl,
            'video_type' => $videoType
        ]);

    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Error: ' . $e->getMessage()]);
    }
}

// ====================================
// FUNCTION: RETRIEVE VIDEOS
// ====================================
function handleVideoRetrieval($pdo)
{
    try {
        $videoId = $_GET['video_id'] ?? null;
        $videoType = $_GET['video_type'] ?? null;

        if ($videoId) {
            // Retrieve specific video by ID
            $stmt = $pdo->prepare("SELECT * FROM videos WHERE id = :video_id");
            $stmt->execute([':video_id' => $videoId]);
            $video = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($video) {
                echo json_encode([
                    'status' => 'success',
                    'video' => $video
                ]);
            } else {
                echo json_encode(['status' => 'error', 'message' => 'Video not found']);
            }
        } elseif ($videoType) {
            // Retrieve videos by type (local, youtube, external, etc.)
            $stmt = $pdo->prepare("SELECT * FROM videos WHERE video_type = :video_type ORDER BY upload_date DESC");
            $stmt->execute([':video_type' => $videoType]);
            $videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'status' => 'success',
                'count' => count($videos),
                'videos' => $videos
            ]);
        } else {
            // Retrieve ALL videos
            $stmt = $pdo->prepare("SELECT * FROM videos ORDER BY upload_date DESC");
            $stmt->execute();
            $videos = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo json_encode([
                'status' => 'success',
                'count' => count($videos),
                'videos' => $videos
            ]);
        }

    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Retrieval error: ' . $e->getMessage()]);
    }
}

// ====================================
// FUNCTION: HANDLE DATA SUBMISSION (JSON)
// ====================================
function handleDataSubmission($pdo)
{
    try {
        $input = json_decode(file_get_contents('php://input'), true);

        $title = $input['title'] ?? 'Untitled';
        $description = $input['description'] ?? '';
        $videoUrl = $input['video_url'] ?? null;
        $videoType = $input['video_type'] ?? 'external';

        if ($videoUrl) {
            // Add video URL via JSON
            $stmt = $pdo->prepare("
                INSERT INTO videos (title, description, video_url, video_type, upload_date) 
                VALUES (:title, :description, :video_url, :video_type, NOW())
            ");

            $stmt->execute([
                ':title' => $title,
                ':description' => $description,
                ':video_url' => $videoUrl,
                ':video_type' => $videoType
            ]);
        } else {
            // Add metadata only
            $stmt = $pdo->prepare("
                INSERT INTO videos (title, description, upload_date) 
                VALUES (:title, :description, NOW())
            ");

            $stmt->execute([
                ':title' => $title,
                ':description' => $description
            ]);
        }

        echo json_encode(['status' => 'success', 'message' => 'Data submitted successfully']);

    } catch (Exception $e) {
        echo json_encode(['status' => 'error', 'message' => 'Submission error: ' . $e->getMessage()]);
    }
}
?>