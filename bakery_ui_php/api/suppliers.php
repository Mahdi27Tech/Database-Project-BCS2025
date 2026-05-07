<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { exit; }
require 'config.php';

try {
    $db     = get_db();
    $method = $_SERVER['REQUEST_METHOD'];

    if ($method === 'GET') {
        $rows = [];
        $res  = $db->query("
            SELECT s.*, COUNT(i.ingredient_id) AS ingredient_count
            FROM suppliers s
            LEFT JOIN ingredients i ON i.supplier_id = s.supplier_id
            GROUP BY s.supplier_id ORDER BY s.name
        ");
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        echo json_encode($rows);
    }

    if ($method === 'POST') {
        $d   = json_decode(file_get_contents('php://input'), true);
        $sql = "INSERT INTO suppliers (name, contact_name, email, phone, address) VALUES (?,?,?,?,?)";
        $st  = $db->prepare($sql);
        $st->bind_param('sssss', $d['name'], $d['contact_name'], $d['email'], $d['phone'], $d['address']);
        $st->execute();
        echo json_encode(['id' => $db->insert_id, 'ok' => true]);
    }

    if ($method === 'PUT') {
        $id  = (int)($_GET['id'] ?? 0);
        $d   = json_decode(file_get_contents('php://input'), true);
        $sql = "UPDATE suppliers SET name=?, contact_name=?, email=?, phone=?, address=? WHERE supplier_id=?";
        $st  = $db->prepare($sql);
        $st->bind_param('sssssi', $d['name'], $d['contact_name'], $d['email'], $d['phone'], $d['address'], $id);
        $st->execute();
        echo json_encode(['ok' => true]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
