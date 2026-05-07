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
            SELECT po.*, s.name AS supplier_name,
                   COUNT(poi.poi_id) AS item_count,
                   SUM(poi.quantity_ordered * poi.cost_per_unit) AS total_cost
            FROM purchase_orders po
            LEFT JOIN suppliers s ON s.supplier_id = po.supplier_id
            LEFT JOIN purchase_order_items poi ON poi.po_id = po.po_id
            GROUP BY po.po_id ORDER BY po.order_date DESC
        ");
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        echo json_encode($rows);
    }

    if ($method === 'POST') {
        $d      = json_decode(file_get_contents('php://input'), true);
        $action = $d['action'] ?? 'create';

        if ($action === 'receive') {
            $id = (int)$d['po_id'];
            $db->query("UPDATE purchase_orders SET status='received', received_date=CURDATE() WHERE po_id=$id");
            $items_res = $db->query("SELECT * FROM purchase_order_items WHERE po_id=$id");
            while ($item = $items_res->fetch_assoc()) {
                $qty = (float)$item['quantity_ordered'];
                $poi = (int)$item['poi_id'];
                $db->query("UPDATE purchase_order_items SET quantity_received=$qty WHERE poi_id=$poi");
            }
            echo json_encode(['ok' => true]);
        } else {
            $sql = "INSERT INTO purchase_orders (supplier_id, order_date, expected_date, status, notes) VALUES (?, ?, ?, 'pending', ?)";
            $st  = $db->prepare($sql);
            $st->bind_param('isss', $d['supplier_id'], $d['order_date'], $d['expected_date'], $d['notes']);
            $st->execute();
            $oid = $db->insert_id;

            foreach ($d['items'] as $item) {
                $sql2 = "INSERT INTO purchase_order_items (po_id, ingredient_id, quantity_ordered, unit_id, cost_per_unit) VALUES (?, ?, ?, ?, ?)";
                $st2  = $db->prepare($sql2);
                $st2->bind_param('iiiid', $oid, $item['ingredient_id'], $item['quantity_ordered'], $item['unit_id'], $item['cost_per_unit']);
                $st2->execute();
            }

            $db->query("UPDATE purchase_orders SET total_cost = (SELECT SUM(quantity_ordered * cost_per_unit) FROM purchase_order_items WHERE po_id=$oid) WHERE po_id=$oid");
            echo json_encode(['id' => $oid, 'ok' => true]);
        }
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
