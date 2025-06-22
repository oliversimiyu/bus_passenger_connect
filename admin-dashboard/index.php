<?php
require_once 'includes/functions.php';
checkLogin();

$page_title = 'Dashboard';
$stats = getDriverStats($pdo);
$recent_drivers = getRecentDrivers($pdo);
$companies = getBusCompanies($pdo);

include 'includes/header.php';
?>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
    <h1 class="h2"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</h1>
    <div class="btn-toolbar mb-2 mb-md-0">
        <div class="btn-group me-2">
            <button type="button" class="btn btn-outline-secondary">
                <i class="fas fa-calendar-day me-1"></i>
                <?php echo date('F j, Y'); ?>
            </button>
        </div>
    </div>
</div>

<!-- Statistics Cards -->
<div class="row mb-4">
    <div class="col-md-3 mb-3">
        <div class="stats-card">
            <i class="fas fa-users"></i>
            <h3><?php echo $stats['total']; ?></h3>
            <p class="mb-0">Total Drivers</p>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="stats-card" style="background: linear-gradient(135deg, #28a745, #20c997);">
            <i class="fas fa-user-check"></i>
            <h3><?php echo $stats['active']; ?></h3>
            <p class="mb-0">Active Drivers</p>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="stats-card" style="background: linear-gradient(135deg, #ffc107, #fd7e14);">
            <i class="fas fa-user-clock"></i>
            <h3><?php echo $stats['inactive']; ?></h3>
            <p class="mb-0">Inactive Drivers</p>
        </div>
    </div>
    <div class="col-md-3 mb-3">
        <div class="stats-card" style="background: linear-gradient(135deg, #dc3545, #e83e8c);">
            <i class="fas fa-user-times"></i>
            <h3><?php echo $stats['suspended']; ?></h3>
            <p class="mb-0">Suspended Drivers</p>
        </div>
    </div>
</div>

<div class="row">
    <!-- Recent Drivers -->
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="fas fa-clock me-2"></i>Recent Driver Registrations
                </h5>
            </div>
            <div class="card-body">
                <?php if (empty($recent_drivers)): ?>
                    <div class="text-center py-4">
                        <i class="fas fa-user-plus fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">No drivers registered yet</h5>
                        <p class="text-muted">Start by adding your first driver to the system.</p>
                        <a href="add_driver.php" class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i>Add Driver
                        </a>
                    </div>
                <?php else: ?>
                    <div class="table-responsive">
                        <table class="table table-hover">
                            <thead>
                                <tr>
                                    <th>Driver</th>
                                    <th>ID Number</th>
                                    <th>License Plate</th>
                                    <th>Company</th>
                                    <th>Status</th>
                                    <th>Registered</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($recent_drivers as $driver): ?>
                                    <tr>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-circle me-2">
                                                    <i class="fas fa-user"></i>
                                                </div>
                                                <div>
                                                    <strong><?php echo htmlspecialchars($driver['name']); ?></strong>
                                                    <br>
                                                    <small class="text-muted">
                                                        <?php echo formatPhoneDisplay($driver['phone']); ?>
                                                    </small>
                                                </div>
                                            </div>
                                        </td>
                                        <td><?php echo htmlspecialchars($driver['id_number']); ?></td>
                                        <td>
                                            <span class="badge bg-secondary">
                                                <?php echo htmlspecialchars($driver['license_plate']); ?>
                                            </span>
                                        </td>
                                        <td><?php echo htmlspecialchars($driver['bus_company']); ?></td>
                                        <td>
                                            <?php
                                            $status_colors = [
                                                'active' => 'success',
                                                'inactive' => 'warning',
                                                'suspended' => 'danger'
                                            ];
                                            $color = $status_colors[$driver['status']] ?? 'secondary';
                                            ?>
                                            <span class="badge bg-<?php echo $color; ?>">
                                                <?php echo ucfirst($driver['status']); ?>
                                            </span>
                                        </td>
                                        <td>
                                            <small class="text-muted">
                                                <?php echo date('M j, Y', strtotime($driver['created_at'])); ?>
                                            </small>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                    <div class="text-center mt-3">
                        <a href="drivers.php" class="btn btn-outline-primary">
                            <i class="fas fa-eye me-2"></i>View All Drivers
                        </a>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <!-- Quick Actions & Stats -->
    <div class="col-md-4">
        <!-- Quick Actions -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="fas fa-bolt me-2"></i>Quick Actions
                </h5>
            </div>
            <div class="card-body">
                <div class="d-grid gap-2">
                    <a href="add_driver.php" class="btn btn-primary">
                        <i class="fas fa-user-plus me-2"></i>Add New Driver
                    </a>
                    <a href="drivers.php" class="btn btn-outline-primary">
                        <i class="fas fa-users me-2"></i>Manage Drivers
                    </a>
                    <a href="companies.php" class="btn btn-outline-secondary">
                        <i class="fas fa-building me-2"></i>Manage Companies
                    </a>
                    <a href="reports.php" class="btn btn-outline-info">
                        <i class="fas fa-chart-bar me-2"></i>View Reports
                    </a>
                </div>
            </div>
        </div>

        <!-- Bus Companies -->
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="fas fa-building me-2"></i>Registered Companies
                </h5>
            </div>
            <div class="card-body">
                <?php if (empty($companies)): ?>
                    <div class="text-center py-3">
                        <i class="fas fa-building fa-2x text-muted mb-2"></i>
                        <p class="text-muted mb-0">No companies registered</p>
                    </div>
                <?php else: ?>
                    <div class="list-group list-group-flush">
                        <?php foreach (array_slice($companies, 0, 5) as $company): ?>
                            <div class="list-group-item border-0 px-0">
                                <div class="d-flex align-items-center">
                                    <i class="fas fa-building text-primary me-2"></i>
                                    <div>
                                        <strong><?php echo htmlspecialchars($company['name']); ?></strong>
                                        <?php if ($company['phone']): ?>
                                            <br>
                                            <small class="text-muted">
                                                <?php echo formatPhoneDisplay($company['phone']); ?>
                                            </small>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                    <?php if (count($companies) > 5): ?>
                        <div class="text-center mt-2">
                            <a href="companies.php" class="btn btn-sm btn-outline-primary">
                                View All (<?php echo count($companies); ?>)
                            </a>
                        </div>
                    <?php endif; ?>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<style>
.avatar-circle {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
}
</style>

<?php include 'includes/footer.php'; ?>
