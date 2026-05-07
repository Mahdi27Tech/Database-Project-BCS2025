<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
require 'config.php';

try {
    $db    = get_db();
    $stats = [];

    $stats['total_ingredients'] = $db->query("SELECT COUNT(*) AS n FROM ingredients")->fetch_assoc()['n'];
    $stats['total_products']    = $db->query("SELECT COUNT(*) AS n FROM products")->fetch_assoc()['n'];
    $stats['total_suppliers']   = $db->query("SELECT COUNT(*) AS n FROM suppliers")->fetch_assoc()['n'];
    $stats['pending_orders']    = $db->query("SELECT COUNT(*) AS n FROM purchase_orders WHERE status='pending'")->fetch_assoc()['n'];

    $alerts = [];
    $res = $db->query("SELECT * FROM vw_low_stock_alerts ORDER BY shortage DESC LIMIT 8");
    while ($row = $res->fetch_assoc()) $alerts[] = $row;
    $stats['low_stock'] = $alerts;

    $movements = [];
    $res = $db->query("SELECT * FROM stock_movements ORDER BY moved_at DESC LIMIT 6");
    while ($row = $res->fetch_assoc()) $movements[] = $row;
    $stats['recent_movements'] = $movements;

    $costs = [];
    $res = $db->query("SELECT * FROM vw_recipe_cost");
    while ($row = $res->fetch_assoc()) $costs[] = $row;
    $stats['recipe_costs'] = $costs;

    echo json_encode($stats);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
