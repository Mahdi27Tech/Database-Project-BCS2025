<?php
require 'config.php';
$db     = get_db();
$method = $_SERVER['REQUEST_METHOD'];
$endpoint = basename(__FILE__, '.php'); // suppliers | orders | movements | helpers

// ── SUPPLIERS ─────────────────────────────────────────────
if ($endpoint === 'suppliers') {
    if ($method === 'GET') {
        $rows = [];
        $res  = $db->query("
            SELECT s.*, COUNT(i.ingredient_id) AS ingredient_count
            FROM suppliers s
            LEFT JOIN ingredients i ON i.supplier_id = s.supplier_id
            GROUP BY s.supplier_id ORDER BY s.name
        ");
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        send_json($rows);
    }
    if ($method === 'POST') {
        $d   = get_body();
        $sql = "INSERT INTO suppliers (name, contact_name, email, phone, address) VALUES (?,?,?,?,?)";
        $st  = $db->prepare($sql);
        $st->bind_param('sssss', $d['name'], $d['contact_name'], $d['email'], $d['phone'], $d['address']);
        $st->execute();
        send_json(['id' => $db->insert_id, 'ok' => true]);
    }
    if ($method === 'PUT') {
        $id  = (int)($_GET['id'] ?? 0);
        $d   = get_body();
        $sql = "UPDATE suppliers SET name=?, contact_name=?, email=?, phone=?, address=? WHERE supplier_id=?";
        $st  = $db->prepare($sql);
        $st->bind_param('sssssi', $d['name'], $d['contact_name'], $d['email'], $d['phone'], $d['address'], $id);
        $st->execute();
        send_json(['ok' => true]);
    }
}

// ── PURCHASE ORDERS ───────────────────────────────────────
if ($endpoint === 'orders') {
    if ($method === 'GET') {
        // Return order list
        $rows = [];
        $res  = $db->query("
            SELECT po.*, s.name AS supplier_name,
                   COUNT(poi.poi_id) AS item_count,
                   SUM(poi.quantity_ordered * poi.cost_per_unit) AS total_cost
            FROM purchase_orders po
            LEFT JOIN suppliers s          ON s.supplier_id  = po.supplier_id
            LEFT JOIN purchase_order_items poi ON poi.po_id  = po.po_id
            GROUP BY po.po_id ORDER BY po.order_date DESC
        ");
        while ($row = $res->fetch_assoc()) $rows[] = $row;
        send_json($rows);
    }

    if ($method === 'POST') {
        $d    = get_body();
        $action = $d['action'] ?? 'create';

        // Mark order as received
        if ($action === 'receive') {
            $id = (int)$d['po_id'];
            $db->query("UPDATE purchase_orders SET status='received', received_date=CURDATE() WHERE po_id=$id");

            // Update quantity_received on each item to trigger auto-stock update
            $items_res = $db->query("SELECT * FROM purchase_order_items WHERE po_id=$id");
            while ($item = $items_res->fetch_assoc()) {
                $qty = (float)$item['quantity_ordered'];
                $iid = (int)$item['ingredient_id'];
                $poi = (int)$item['poi_id'];
                $db->query("UPDATE purchase_order_items SET quantity_received=$qty WHERE poi_id=$poi");
            }
            send_json(['ok' => true]);
        }

        // Create new order
        $sql = "INSERT INTO purchase_orders (supplier_id, order_date, expected_date, status, notes)
                VALUES (?, ?, ?, 'pending', ?)";
        $st  = $db->prepare($sql);
        $st->bind_param('isss', $d['supplier_id'], $d['order_date'], $d['expected_date'], $d['notes']);
        $st->execute();
        $oid = $db->insert_id;

        foreach ($d['items'] as $item) {
            $sql2 = "INSERT INTO purchase_order_items (po_id, ingredient_id, quantity_ordered, unit_id, cost_per_unit)
                     VALUES (?, ?, ?, ?, ?)";
            $st2  = $db->prepare($sql2);
            $st2->bind_param('iiiid', $oid, $item['ingredient_id'], $item['quantity_ordered'], $item['unit_id'], $item['cost_per_unit']);
            $st2->execute();
        }

        // Update total cost
        $db->query("UPDATE purchase_orders po
                    SET total_cost = (SELECT SUM(quantity_ordered * cost_per_unit) FROM purchase_order_items WHERE po_id=$oid)
                    WHERE po_id=$oid");

        send_json(['id' => $oid, 'ok' => true]);
    }
}

// ── STOCK MOVEMENTS ───────────────────────────────────────
if ($endpoint === 'movements') {
    $rows = [];
    $res  = $db->query("SELECT * FROM stock_movements ORDER BY moved_at DESC LIMIT 100");
    while ($row = $res->fetch_assoc()) $rows[] = $row;
    send_json($rows);
}

// ── HELPERS (categories, units, suppliers list) ───────────
if ($endpoint === 'helpers') {
    $cats  = []; $res = $db->query("SELECT * FROM categories ORDER BY type, name");
    while ($r = $res->fetch_assoc()) $cats[] = $r;

    $units = []; $res = $db->query("SELECT * FROM units ORDER BY name");
    while ($r = $res->fetch_assoc()) $units[] = $r;

    $sups  = []; $res = $db->query("SELECT supplier_id, name FROM suppliers ORDER BY name");
    while ($r = $res->fetch_assoc()) $sups[] = $r;

    $ings  = []; $res = $db->query("SELECT ingredient_id, name, unit_id FROM ingredients ORDER BY name");
    while ($r = $res->fetch_assoc()) $ings[] = $r;

    send_json(compact('cats', 'units', 'sups', 'ings'));
}
