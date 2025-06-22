<?php
session_start();
require_once 'config/database.php';

// Check if user is logged in
function checkLogin() {
    if (!isset($_SESSION['admin_id'])) {
        header('Location: login.php');
        exit();
    }
}

// Sanitize input
function sanitize($data) {
    return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
}

// Validate phone number (Kenya format)
function validatePhone($phone) {
    $phone = preg_replace('/\D/', '', $phone);
    return preg_match('/^(254|0)[17]\d{8}$/', $phone);
}

// Validate ID number (Kenya format)
function validateIdNumber($id) {
    return preg_match('/^\d{7,8}$/', $id);
}

// Validate license plate (Kenya format)
function validateLicensePlate($plate) {
    return preg_match('/^[A-Z]{3}\s?\d{3}[A-Z]?$/i', $plate);
}

// Get all bus companies
function getBusCompanies($pdo) {
    $stmt = $pdo->query("SELECT * FROM bus_companies WHERE status = 'active' ORDER BY name");
    return $stmt->fetchAll();
}

// Get driver statistics
function getDriverStats($pdo) {
    $stats = [];
    
    // Total drivers
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM drivers");
    $stats['total'] = $stmt->fetch()['total'];
    
    // Active drivers
    $stmt = $pdo->query("SELECT COUNT(*) as active FROM drivers WHERE status = 'active'");
    $stats['active'] = $stmt->fetch()['active'];
    
    // Inactive drivers
    $stmt = $pdo->query("SELECT COUNT(*) as inactive FROM drivers WHERE status = 'inactive'");
    $stats['inactive'] = $stmt->fetch()['inactive'];
    
    // Suspended drivers
    $stmt = $pdo->query("SELECT COUNT(*) as suspended FROM drivers WHERE status = 'suspended'");
    $stats['suspended'] = $stmt->fetch()['suspended'];
    
    return $stats;
}

// Get recent drivers
function getRecentDrivers($pdo, $limit = 5) {
    $stmt = $pdo->prepare("SELECT * FROM drivers ORDER BY created_at DESC LIMIT ?");
    $stmt->execute([$limit]);
    return $stmt->fetchAll();
}

// Format phone number for display
function formatPhoneDisplay($phone) {
    $phone = preg_replace('/\D/', '', $phone);
    if (strlen($phone) === 12 && substr($phone, 0, 3) === '254') {
        return '+254 ' . substr($phone, 3, 3) . ' ' . substr($phone, 6, 3) . ' ' . substr($phone, 9);
    }
    return $phone;
}

// Generate unique driver ID
function generateDriverId($pdo) {
    do {
        $driver_id = 'DRV' . date('Y') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
        $stmt = $pdo->prepare("SELECT id FROM drivers WHERE driver_id = ?");
        $stmt->execute([$driver_id]);
    } while ($stmt->fetch());
    
    return $driver_id;
}

// Log admin activity
function logActivity($pdo, $admin_id, $action, $details = '') {
    $stmt = $pdo->prepare("INSERT INTO admin_activity_log (admin_id, action, details, ip_address, created_at) VALUES (?, ?, ?, ?, NOW())");
    $stmt->execute([$admin_id, $action, $details, $_SERVER['REMOTE_ADDR'] ?? 'Unknown']);
}

// Check if ID number exists
function idNumberExists($pdo, $id_number, $exclude_id = null) {
    $sql = "SELECT id FROM drivers WHERE id_number = ?";
    $params = [$id_number];
    
    if ($exclude_id) {
        $sql .= " AND id != ?";
        $params[] = $exclude_id;
    }
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetch() !== false;
}

// Check if license plate exists
function licensePlateExists($pdo, $license_plate, $exclude_id = null) {
    $sql = "SELECT id FROM drivers WHERE license_plate = ?";
    $params = [$license_plate];
    
    if ($exclude_id) {
        $sql .= " AND id != ?";
        $params[] = $exclude_id;
    }
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    return $stmt->fetch() !== false;
}
?>
