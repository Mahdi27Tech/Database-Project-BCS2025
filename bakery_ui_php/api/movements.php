<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
require 'config.php';

try {
    $db   = get_db();
    $rows = [];
    $res  = $db->query("SELECT * FROM stock_movements ORDER BY moved_at DESC LIMIT 100");
    while ($row = $res->fetch_assoc()) $rows[] = $row;
    echo json_encode($rows);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
