<?php
require 'config.php';
$db     = get_db();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $rows = [];
    $res  = $db->query("
        SELECT i.*, c.name AS category_name, u.abbreviation AS unit_abbr, s.name AS supplier_name
        FROM ingredients i
        LEFT JOIN categories c ON c.category_id = i.category_id
        LEFT JOIN units u      ON u.unit_id      = i.unit_id
        LEFT JOIN suppliers s  ON s.supplier_id  = i.supplier_id
        ORDER BY c.name, i.name
    ");
    while ($row = $res->fetch_assoc()) $rows[] = $row;
    send_json($rows);
}

if ($method === 'POST') {
    $d   = get_body();
    $sql = "INSERT INTO ingredients (name, category_id, unit_id, quantity_in_stock, reorder_level, cost_per_unit, supplier_id, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    $st  = $db->prepare($sql);
    $st->bind_param('siiiddis',
        $d['name'], $d['category_id'], $d['unit_id'],
        $d['quantity_in_stock'], $d['reorder_level'], $d['cost_per_unit'],
        $d['supplier_id'], $d['notes']
    );
    $st->execute();
    send_json(['id' => $db->insert_id, 'ok' => true]);
}

if ($method === 'PUT') {
    $id  = (int)($_GET['id'] ?? 0);
    $d   = get_body();
    $sql = "UPDATE ingredients SET name=?, category_id=?, unit_id=?,
            quantity_in_stock=?, reorder_level=?, cost_per_unit=?,
            supplier_id=?, notes=? WHERE ingredient_id=?";
    $st  = $db->prepare($sql);
    $st->bind_param('siiiddisd',
        $d['name'], $d['category_id'], $d['unit_id'],
        $d['quantity_in_stock'], $d['reorder_level'], $d['cost_per_unit'],
        $d['supplier_id'], $d['notes'], $id
    );
    $st->execute();
    send_json(['ok' => true]);
}

if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    $db->query("DELETE FROM ingredients WHERE ingredient_id = $id");
    send_json(['ok' => true]);
}
