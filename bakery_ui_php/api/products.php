<?php
require 'config.php';
$db     = get_db();
$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $rows = [];
    $res  = $db->query("
        SELECT p.*, c.name AS category_name, u.abbreviation AS unit_abbr
        FROM products p
        LEFT JOIN categories c ON c.category_id = p.category_id
        LEFT JOIN units u      ON u.unit_id      = p.unit_id
        ORDER BY c.name, p.name
    ");
    while ($row = $res->fetch_assoc()) $rows[] = $row;
    send_json($rows);
}

if ($method === 'POST') {
    $d   = get_body();
    $sql = "INSERT INTO products (name, category_id, unit_id, quantity_in_stock, reorder_level, sale_price, notes)
            VALUES (?, ?, ?, ?, ?, ?, ?)";
    $st  = $db->prepare($sql);
    $st->bind_param('siiddds',
        $d['name'], $d['category_id'], $d['unit_id'],
        $d['quantity_in_stock'], $d['reorder_level'], $d['sale_price'], $d['notes']
    );
    $st->execute();
    send_json(['id' => $db->insert_id, 'ok' => true]);
}

if ($method === 'PUT') {
    $id  = (int)($_GET['id'] ?? 0);
    $d   = get_body();
    $sql = "UPDATE products SET name=?, category_id=?, unit_id=?,
            quantity_in_stock=?, reorder_level=?, sale_price=?, notes=?
            WHERE product_id=?";
    $st  = $db->prepare($sql);
    $st->bind_param('siidddsi',
        $d['name'], $d['category_id'], $d['unit_id'],
        $d['quantity_in_stock'], $d['reorder_level'], $d['sale_price'], $d['notes'], $id
    );
    $st->execute();
    send_json(['ok' => true]);
}

if ($method === 'DELETE') {
    $id = (int)($_GET['id'] ?? 0);
    $db->query("DELETE FROM products WHERE product_id = $id");
    send_json(['ok' => true]);
}
