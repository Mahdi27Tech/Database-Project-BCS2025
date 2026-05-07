<?php
// ── DB CONNECTION ─────────────────────────────────────────
// Adjust these if your LAMPP setup differs
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');          // default LAMPP has no root password
define('DB_NAME', 'bakery_inventory');

function get_db() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    if ($conn->connect_error) {
        http_response_code(500);
        die(json_encode(['error' => 'DB connection failed: ' . $conn->connect_error]));
    }
    $conn->set_charset('utf8mb4');
    return $conn;
}

function send_json($data, $code = 200) {
    http_response_code($code);
    header('Content-Type: application/json');
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    echo json_encode($data);
    exit;
}

function get_body() {
    return json_decode(file_get_contents('php://input'), true) ?? [];
}

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    send_json(['ok' => true]);
}
