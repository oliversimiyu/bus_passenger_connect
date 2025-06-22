<?php
require_once 'includes/functions.php';
checkLogin();

$page_title = 'Add Driver';
$companies = getBusCompanies($pdo);

// Handle form submission
if ($_POST) {
    $errors = [];
    
    // Validate inputs
    $name = sanitize($_POST['name']);
    $id_number = sanitize($_POST['id_number']);
    $license_plate = strtoupper(sanitize($_POST['license_plate']));
    $bus_company = sanitize($_POST['bus_company']);
    $age = (int)$_POST['age'];
    $phone = sanitize($_POST['phone']);
    $email = sanitize($_POST['email']);
    $status = sanitize($_POST['status']);
    
    // Validation
    if (empty($name)) {
        $errors[] = "Driver name is required";
    }
    
    if (empty($id_number)) {
        $errors[] = "ID number is required";
    } elseif (!validateIdNumber($id_number)) {
        $errors[] = "Invalid ID number format";
    } elseif (idNumberExists($pdo, $id_number)) {
        $errors[] = "ID number already exists";
    }
    
    if (empty($license_plate)) {
        $errors[] = "License plate is required";
    } elseif (licensePlateExists($pdo, $license_plate)) {
        $errors[] = "License plate already exists";
    }
    
    if (empty($bus_company)) {
        $errors[] = "Bus company is required";
    }
    
    if ($age < 18 || $age > 70) {
        $errors[] = "Age must be between 18 and 70";
    }
    
    if (empty($phone)) {
        $errors[] = "Phone number is required";
    } elseif (!validatePhone($phone)) {
        $errors[] = "Invalid phone number format";
    }
    
    if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = "Invalid email format";
    }
    
    // If no errors, insert driver
    if (empty($errors)) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO drivers (name, id_number, license_plate, bus_company, age, phone, email, status) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            
            $stmt->execute([
                $name, $id_number, $license_plate, $bus_company, 
                $age, $phone, $email, $status
            ]);
            
            // Log activity
            logActivity($pdo, $_SESSION['admin_id'], 'driver_added', "Added driver: $name (ID: $id_number)");
            
            $_SESSION['success_message'] = "Driver registered successfully!";
            header('Location: drivers.php');
            exit();
            
        } catch (PDOException $e) {
            $errors[] = "Database error: " . $e->getMessage();
        }
    }
}

include 'includes/header.php';
?>

<div class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pt-3 pb-2 mb-3 border-bottom">
    <h1 class="h2"><i class="fas fa-user-plus me-2"></i>Add New Driver</h1>
    <div class="btn-toolbar mb-2 mb-md-0">
        <a href="drivers.php" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-1"></i>Back to Drivers
        </a>
    </div>
</div>

<?php if (!empty($errors)): ?>
    <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle me-2"></i>
        <strong>Please fix the following errors:</strong>
        <ul class="mb-0 mt-2">
            <?php foreach ($errors as $error): ?>
                <li><?php echo $error; ?></li>
            <?php endforeach; ?>
        </ul>
    </div>
<?php endif; ?>

<div class="row">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="fas fa-user-circle me-2"></i>Driver Information
                </h5>
            </div>
            <div class="card-body">
                <form method="POST" class="needs-validation" novalidate>
                    <div class="row">
                        <!-- Driver Name -->
                        <div class="col-md-6 mb-3">
                            <label for="name" class="form-label">
                                <i class="fas fa-user me-1"></i>Full Name <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="<?php echo isset($_POST['name']) ? htmlspecialchars($_POST['name']) : ''; ?>" 
                                   required placeholder="Enter driver's full name">
                            <div class="invalid-feedback">
                                Please provide a valid driver name.
                            </div>
                        </div>

                        <!-- ID Number -->
                        <div class="col-md-6 mb-3">
                            <label for="id_number" class="form-label">
                                <i class="fas fa-id-card me-1"></i>ID Number <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="id_number" name="id_number" 
                                   value="<?php echo isset($_POST['id_number']) ? htmlspecialchars($_POST['id_number']) : ''; ?>" 
                                   required placeholder="12345678" maxlength="8"
                                   oninput="validateIdNumber(this)">
                            <div class="form-text">Enter 7-8 digit Kenya ID number</div>
                            <div class="invalid-feedback">
                                Please provide a valid ID number.
                            </div>
                        </div>

                        <!-- Age -->
                        <div class="col-md-6 mb-3">
                            <label for="age" class="form-label">
                                <i class="fas fa-calendar me-1"></i>Age <span class="text-danger">*</span>
                            </label>
                            <input type="number" class="form-control" id="age" name="age" 
                                   value="<?php echo isset($_POST['age']) ? (int)$_POST['age'] : ''; ?>" 
                                   required min="18" max="70" placeholder="25">
                            <div class="form-text">Must be between 18 and 70 years</div>
                            <div class="invalid-feedback">
                                Please provide a valid age (18-70).
                            </div>
                        </div>

                        <!-- Phone Number -->
                        <div class="col-md-6 mb-3">
                            <label for="phone" class="form-label">
                                <i class="fas fa-phone me-1"></i>Phone Number <span class="text-danger">*</span>
                            </label>
                            <input type="tel" class="form-control" id="phone" name="phone" 
                                   value="<?php echo isset($_POST['phone']) ? htmlspecialchars($_POST['phone']) : ''; ?>" 
                                   required placeholder="+254712345678"
                                   oninput="formatPhone(this)">
                            <div class="form-text">Kenya mobile number format</div>
                            <div class="invalid-feedback">
                                Please provide a valid phone number.
                            </div>
                        </div>

                        <!-- Email (Optional) -->
                        <div class="col-md-6 mb-3">
                            <label for="email" class="form-label">
                                <i class="fas fa-envelope me-1"></i>Email Address
                            </label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="<?php echo isset($_POST['email']) ? htmlspecialchars($_POST['email']) : ''; ?>" 
                                   placeholder="driver@example.com">
                            <div class="form-text">Optional - for notifications</div>
                        </div>

                        <!-- License Plate -->
                        <div class="col-md-6 mb-3">
                            <label for="license_plate" class="form-label">
                                <i class="fas fa-car me-1"></i>License Plate <span class="text-danger">*</span>
                            </label>
                            <input type="text" class="form-control" id="license_plate" name="license_plate" 
                                   value="<?php echo isset($_POST['license_plate']) ? htmlspecialchars($_POST['license_plate']) : ''; ?>" 
                                   required placeholder="KAA 123B" maxlength="10"
                                   oninput="formatLicensePlate(this)">
                            <div class="form-text">Kenya vehicle registration format</div>
                            <div class="invalid-feedback">
                                Please provide a valid license plate.
                            </div>
                        </div>

                        <!-- Bus Company -->
                        <div class="col-md-6 mb-3">
                            <label for="bus_company" class="form-label">
                                <i class="fas fa-building me-1"></i>Bus Company <span class="text-danger">*</span>
                            </label>
                            <?php if (!empty($companies)): ?>
                                <select class="form-select" id="bus_company" name="bus_company" required>
                                    <option value="">Select a company</option>
                                    <?php foreach ($companies as $company): ?>
                                        <option value="<?php echo htmlspecialchars($company['name']); ?>"
                                                <?php echo (isset($_POST['bus_company']) && $_POST['bus_company'] === $company['name']) ? 'selected' : ''; ?>>
                                            <?php echo htmlspecialchars($company['name']); ?>
                                        </option>
                                    <?php endforeach; ?>
                                    <option value="other">Other (Enter manually)</option>
                                </select>
                                <input type="text" class="form-control mt-2 d-none" id="custom_company" 
                                       placeholder="Enter company name" name="custom_company">
                            <?php else: ?>
                                <input type="text" class="form-control" id="bus_company" name="bus_company" 
                                       value="<?php echo isset($_POST['bus_company']) ? htmlspecialchars($_POST['bus_company']) : ''; ?>" 
                                       required placeholder="Enter bus company name">
                            <?php endif; ?>
                            <div class="invalid-feedback">
                                Please select or enter a bus company.
                            </div>
                        </div>

                        <!-- Status -->
                        <div class="col-md-6 mb-3">
                            <label for="status" class="form-label">
                                <i class="fas fa-toggle-on me-1"></i>Status
                            </label>
                            <select class="form-select" id="status" name="status">
                                <option value="active" <?php echo (isset($_POST['status']) && $_POST['status'] === 'active') ? 'selected' : ''; ?>>
                                    Active
                                </option>
                                <option value="inactive" <?php echo (isset($_POST['status']) && $_POST['status'] === 'inactive') ? 'selected' : ''; ?>>
                                    Inactive
                                </option>
                            </select>
                        </div>
                    </div>

                    <!-- Submit Buttons -->
                    <div class="row">
                        <div class="col-12">
                            <hr>
                            <div class="d-flex gap-2">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i>Register Driver
                                </button>
                                <a href="drivers.php" class="btn btn-outline-secondary">
                                    <i class="fas fa-times me-2"></i>Cancel
                                </a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- Help Panel -->
    <div class="col-md-4">
        <div class="card">
            <div class="card-header">
                <h5 class="card-title mb-0">
                    <i class="fas fa-info-circle me-2"></i>Registration Guidelines
                </h5>
            </div>
            <div class="card-body">
                <div class="list-group list-group-flush">
                    <div class="list-group-item border-0 px-0">
                        <i class="fas fa-check-circle text-success me-2"></i>
                        <strong>Required Information:</strong>
                        <ul class="mt-2 mb-0">
                            <li>Full legal name</li>
                            <li>Valid Kenya ID number</li>
                            <li>Age (18-70 years)</li>
                            <li>Phone number</li>
                            <li>Vehicle license plate</li>
                            <li>Bus company</li>
                        </ul>
                    </div>
                    <div class="list-group-item border-0 px-0">
                        <i class="fas fa-exclamation-triangle text-warning me-2"></i>
                        <strong>Validation Rules:</strong>
                        <ul class="mt-2 mb-0">
                            <li>ID numbers must be unique</li>
                            <li>License plates must be unique</li>
                            <li>Phone format: +254XXXXXXXXX</li>
                            <li>Email is optional but recommended</li>
                        </ul>
                    </div>
                    <div class="list-group-item border-0 px-0">
                        <i class="fas fa-lightbulb text-info me-2"></i>
                        <strong>Tips:</strong>
                        <ul class="mt-2 mb-0">
                            <li>Double-check all information</li>
                            <li>Use proper capitalization</li>
                            <li>Verify license plate format</li>
                            <li>Ensure phone number is reachable</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Handle custom company input
document.getElementById('bus_company').addEventListener('change', function() {
    const customInput = document.getElementById('custom_company');
    if (this.value === 'other') {
        customInput.classList.remove('d-none');
        customInput.required = true;
        customInput.name = 'bus_company';
        this.name = '';
    } else {
        customInput.classList.add('d-none');
        customInput.required = false;
        customInput.name = 'custom_company';
        this.name = 'bus_company';
    }
});

// Bootstrap form validation
(function() {
    'use strict';
    window.addEventListener('load', function() {
        var forms = document.getElementsByClassName('needs-validation');
        var validation = Array.prototype.filter.call(forms, function(form) {
            form.addEventListener('submit', function(event) {
                if (form.checkValidity() === false) {
                    event.preventDefault();
                    event.stopPropagation();
                }
                form.classList.add('was-validated');
            }, false);
        });
    }, false);
})();
</script>

<?php include 'includes/footer.php'; ?>
