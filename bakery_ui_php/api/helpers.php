<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

require 'config.php';

try {
    $db = get_db();

    $cats = [];
    $res  = $db->query("SELECT * FROM categories ORDER BY type, name");
    while ($r = $res->fetch_assoc()) $cats[] = $r;

    $units = [];
    $res   = $db->query("SELECT * FROM units ORDER BY name");
    while ($r = $res->fetch_assoc()) $units[] = $r;

    $sups = [];
    $res  = $db->query("SELECT supplier_id, name FROM suppliers ORDER BY name");
    while ($r = $res->fetch_assoc()) $sups[] = $r;

    $ings = [];
    $res  = $db->query("SELECT ingredient_id, name, unit_id FROM ingredients ORDER BY name");
    while ($r = $res->fetch_assoc()) $ings[] = $r;

    echo json_encode([
        'cats'  => $cats,
        'units' => $units,
        'sups'  => $sups,
        'ings'  => $ings,
    ]);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
