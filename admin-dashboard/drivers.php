<?php
require_once 'includes/functions.php';
checkLogin();

$page_title = 'Manage Drivers';

// Handle delete action
if (isset($_GET['delete'])) {
    $driver_id = (int)$_GET['delete'];
    try {
        $stmt = $pdo->prepare("DELETE FROM drivers WHERE id = ?");
        $stmt->execute([$driver_id]);
        
        logActivity($pdo, $_SESSION['admin_id'], 'driver_deleted', "Deleted driver ID: $driver_id");
        $_SESSION['success_message'] = "Driver deleted successfully!";
    } catch (PDOException $e) {
        $_SESSION['error_message'] = "Error deleting driver: " . $e->getMessage();
    }
    header('Location: drivers.php');
    exit();
}

// Handle status update
if (isset($_POST['update_status'])) {
    $driver_id = (int)$_POST['driver_id'];
    $new_status = sanitize($_POST['status']);
    
    try {
        $stmt = $pdo->prepare("UPDATE drivers SET status = ? WHERE id = ?");
        $stmt->execute([$new_status, $driver_id]);
        
        logActivity($pdo, $_SESSION['admin_id'], 'driver_status_updated', "Updated driver $driver_id status to $new_status");
        $_SESSION['success_message'] = "Driver status updated successfully!";
    } catch (PDOException $e) {
        $_SESSION['error_message'] = "Error updating status: " . $e->getMessage();
    }
    header('Location: drivers.php');
    exit();
}

// Pagination and search
$page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
$per_page = 10;
$search = isset($_GET['search']) ? sanitize($_GET['search']) : '';
$status_filter = isset($_GET['status']) ? sanitize($_GET['status']) : '';
$company_filter = isset($_GET['company']) ? sanitize($_GET['company']) : '';

// Build query
$where_conditions = [];
$params = [];

if ($search) {
    $where_conditions[] = "(name LIKE ? OR id_number LIKE ? OR license_plate LIKE ? OR phone LIKE ?)";
    $search_param = "%$search%";
    $params = array_merge($params, [$search_param, $search_param, $search_param, $search_param]);
}

if ($status_filter) {
    $where_conditions[] = "status = ?";
    $params[] = $status_filter;
}

if ($company_filter) {
    $where_conditions[] = "bus_company = ?";
    $params[] = $company_filter;
}

$where_clause = $where_conditions ? 'WHERE ' . implode(' AND ', $where_conditions) : '';

// Get total count
$count_sql = "SELECT COUNT(*) FROM drivers $where_clause";
$count_stmt = $pdo->prepare($count_sql);
$count_stmt->execute($params);
$total_drivers = $count_stmt->fetchColumn();

$total_pages = ceil($total_drivers / $per_page);
$offset = ($page - 1) * $per_page;

// Get drivers
$sql = "SELECT * FROM drivers $where_clause ORDER BY created_at DESC LIMIT $per_page OFFSET $offset";
$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$drivers = $stmt->fetchAll();

// Get companies for filter
$companies = getBusCompanies($pdo);

include 'includes/header.php';
?>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
    <h1 class="h2"><i class="fas fa-users me-2"></i>Manage Drivers</h1>
    <div class="btn-toolbar mb-2 mb-md-0">
        <a href="add_driver.php" class="btn btn-primary me-2">
            <i class="fas fa-user-plus me-1"></i>Add Driver
        </a>
        <button type="button" class="btn btn-outline-secondary" onclick="window.print()">
            <i class="fas fa-print me-1"></i>Print List
        </button>
    </div>
</div>

<!-- Search and Filters -->
<div class="card mb-4">
    <div class="card-body">
        <form method="GET" class="row g-3">
            <div class="col-md-4">
                <label for="search" class="form-label">Search</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-search"></i></span>
                    <input type="text" class="form-control" id="search" name="search" 
                           value="<?php echo htmlspecialchars($search); ?>" 
                           placeholder="Name, ID, License Plate, Phone...">
                </div>
            </div>
            <div class="col-md-3">
                <label for="status" class="form-label">Status</label>
                <select class="form-select" id="status" name="status">
                    <option value="">All Status</option>
                    <option value="active" <?php echo $status_filter === 'active' ? 'selected' : ''; ?>>Active</option>
                    <option value="inactive" <?php echo $status_filter === 'inactive' ? 'selected' : ''; ?>>Inactive</option>
                    <option value="suspended" <?php echo $status_filter === 'suspended' ? 'selected' : ''; ?>>Suspended</option>
                </select>
            </div>
            <div class="col-md-3">
                <label for="company" class="form-label">Company</label>
                <select class="form-select" id="company" name="company">
                    <option value="">All Companies</option>
                    <?php foreach ($companies as $company): ?>
                        <option value="<?php echo htmlspecialchars($company['name']); ?>" 
                                <?php echo $company_filter === $company['name'] ? 'selected' : ''; ?>>
                            <?php echo htmlspecialchars($company['name']); ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-md-2">
                <label class="form-label">&nbsp;</label>
                <div class="d-grid gap-2">
                    <button type="submit" class="btn btn-outline-primary">
                        <i class="fas fa-filter me-1"></i>Filter
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Results Summary -->
<div class="d-flex justify-content-between align-items-center mb-3">
    <h5 class="mb-0">
        <?php if ($search || $status_filter || $company_filter): ?>
            Search Results: <?php echo $total_drivers; ?> driver(s) found
        <?php else: ?>
            All Drivers (<?php echo $total_drivers; ?> total)
        <?php endif; ?>
    </h5>
    <?php if ($search || $status_filter || $company_filter): ?>
        <a href="drivers.php" class="btn btn-outline-secondary btn-sm">
            <i class="fas fa-times me-1"></i>Clear Filters
        </a>
    <?php endif; ?>
</div>

<!-- Drivers Table -->
<div class="card">
    <div class="card-body p-0">
        <?php if (empty($drivers)): ?>
            <div class="text-center py-5">
                <i class="fas fa-user-slash fa-3x text-muted mb-3"></i>
                <h5 class="text-muted">No drivers found</h5>
                <?php if ($search || $status_filter || $company_filter): ?>
                    <p class="text-muted">Try adjusting your search criteria or filters.</p>
                    <a href="drivers.php" class="btn btn-outline-primary">View All Drivers</a>
                <?php else: ?>
                    <p class="text-muted">Start by registering your first driver.</p>
                    <a href="add_driver.php" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Add Driver
                    </a>
                <?php endif; ?>
            </div>
        <?php else: ?>
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th>Driver</th>
                            <th>ID Number</th>
                            <th>Age</th>
                            <th>License Plate</th>
                            <th>Company</th>
                            <th>Status</th>
                            <th>Registered</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($drivers as $driver): ?>
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="avatar-circle me-3">
                                            <i class="fas fa-user"></i>
                                        </div>
                                        <div>
                                            <strong><?php echo htmlspecialchars($driver['name']); ?></strong>
                                            <br>
                                            <small class="text-muted">
                                                <i class="fas fa-phone me-1"></i>
                                                <?php echo formatPhoneDisplay($driver['phone']); ?>
                                            </small>
                                            <?php if ($driver['email']): ?>
                                                <br>
                                                <small class="text-muted">
                                                    <i class="fas fa-envelope me-1"></i>
                                                    <?php echo htmlspecialchars($driver['email']); ?>
                                                </small>
                                            <?php endif; ?>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span class="font-monospace"><?php echo htmlspecialchars($driver['id_number']); ?></span>
                                </td>
                                <td><?php echo $driver['age']; ?> years</td>
                                <td>
                                    <span class="badge bg-secondary fs-6">
                                        <?php echo htmlspecialchars($driver['license_plate']); ?>
                                    </span>
                                </td>
                                <td>
                                    <small><?php echo htmlspecialchars($driver['bus_company']); ?></small>
                                </td>
                                <td>
                                    <form method="POST" class="d-inline">
                                        <input type="hidden" name="driver_id" value="<?php echo $driver['id']; ?>">
                                        <select name="status" class="form-select form-select-sm status-select" 
                                                onchange="this.form.submit()" style="width: auto;">
                                            <option value="active" <?php echo $driver['status'] === 'active' ? 'selected' : ''; ?>>
                                                Active
                                            </option>
                                            <option value="inactive" <?php echo $driver['status'] === 'inactive' ? 'selected' : ''; ?>>
                                                Inactive
                                            </option>
                                            <option value="suspended" <?php echo $driver['status'] === 'suspended' ? 'selected' : ''; ?>>
                                                Suspended
                                            </option>
                                        </select>
                                        <input type="hidden" name="update_status" value="1">
                                    </form>
                                </td>
                                <td>
                                    <small class="text-muted">
                                        <?php echo date('M j, Y', strtotime($driver['created_at'])); ?>
                                        <br>
                                        <?php echo date('g:i A', strtotime($driver['created_at'])); ?>
                                    </small>
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="edit_driver.php?id=<?php echo $driver['id']; ?>" 
                                           class="btn btn-outline-primary" title="Edit Driver">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="view_driver.php?id=<?php echo $driver['id']; ?>" 
                                           class="btn btn-outline-info" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <button type="button" class="btn btn-outline-danger" title="Delete Driver"
                                                onclick="deleteDriver(<?php echo $driver['id']; ?>, '<?php echo htmlspecialchars($driver['name']); ?>')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </div>
</div>

<!-- Pagination -->
<?php if ($total_pages > 1): ?>
    <nav aria-label="Drivers pagination" class="mt-4">
        <ul class="pagination justify-content-center">
            <?php if ($page > 1): ?>
                <li class="page-item">
                    <a class="page-link" href="?page=<?php echo $page - 1; ?>&search=<?php echo urlencode($search); ?>&status=<?php echo urlencode($status_filter); ?>&company=<?php echo urlencode($company_filter); ?>">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
            <?php endif; ?>
            
            <?php for ($i = max(1, $page - 2); $i <= min($total_pages, $page + 2); $i++): ?>
                <li class="page-item <?php echo $i === $page ? 'active' : ''; ?>">
                    <a class="page-link" href="?page=<?php echo $i; ?>&search=<?php echo urlencode($search); ?>&status=<?php echo urlencode($status_filter); ?>&company=<?php echo urlencode($company_filter); ?>">
                        <?php echo $i; ?>
                    </a>
                </li>
            <?php endfor; ?>
            
            <?php if ($page < $total_pages): ?>
                <li class="page-item">
                    <a class="page-link" href="?page=<?php echo $page + 1; ?>&search=<?php echo urlencode($search); ?>&status=<?php echo urlencode($status_filter); ?>&company=<?php echo urlencode($company_filter); ?>">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
            <?php endif; ?>
        </ul>
    </nav>
<?php endif; ?>

<style>
.avatar-circle {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 1.1rem;
}

.status-select {
    border: none;
    background: transparent;
    color: inherit;
    cursor: pointer;
}

.status-select option[value="active"] {
    background-color: #d4edda;
    color: #155724;
}

.status-select option[value="inactive"] {
    background-color: #fff3cd;
    color: #856404;
}

.status-select option[value="suspended"] {
    background-color: #f8d7da;
    color: #721c24;
}

@media print {
    .btn, .btn-group, .pagination, .card-header, .navbar, .sidebar {
        display: none !important;
    }
    .card {
        border: none !important;
        box-shadow: none !important;
    }
}
</style>

<script>
function deleteDriver(id, name) {
    if (confirmDelete(`Are you sure you want to delete driver "${name}"? This action cannot be undone.`)) {
        window.location.href = `drivers.php?delete=${id}`;
    }
}

// Auto-submit status changes with confirmation
document.addEventListener('DOMContentLoaded', function() {
    const statusSelects = document.querySelectorAll('.status-select');
    statusSelects.forEach(function(select) {
        const originalValue = select.value;
        select.addEventListener('change', function(e) {
            const driverName = this.closest('tr').querySelector('strong').textContent;
            const newStatus = this.value;
            
            if (confirm(`Change status of "${driverName}" to "${newStatus}"?`)) {
                // Form will submit automatically
            } else {
                this.value = originalValue;
                e.preventDefault();
            }
        });
    });
});
</script>

<?php include 'includes/footer.php'; ?>
