// Admin Dashboard JavaScript
const API_BASE_URL = 'http://localhost:5000/api';

// Global variables
let currentPage = 1;
let currentDrivers = [];
let authToken = null;

// Initialize dashboard
document.addEventListener('DOMContentLoaded', function() {
    // Check authentication first
    checkAuthentication();
});

// Authentication functions
function checkAuthentication() {
    authToken = localStorage.getItem('adminToken');
    
    if (!authToken) {
        redirectToLogin();
        return;
    }
    
    // Verify token with server
    fetch(`${API_BASE_URL}/auth/verify`, {
        headers: {
            'Authorization': `Bearer ${authToken}`
        }
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Token verification failed');
        }
        return response.json();
    })
    .then(data => {
        if (data.success) {
            // Update admin name in sidebar
            document.getElementById('adminName').textContent = data.user.name || data.user.username;
            // Initialize dashboard
            initializeDashboard();
        } else {
            throw new Error('Invalid token');
        }
    })
    .catch(error => {
        console.error('Authentication check failed:', error);
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        redirectToLogin();
    });
}

function redirectToLogin() {
    window.location.href = 'login.html';
}

function logout() {
    // Call logout API
    fetch(`${API_BASE_URL}/auth/logout`, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${authToken}`
        }
    })
    .then(() => {
        // Clear local storage
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        // Redirect to login
        redirectToLogin();
    })
    .catch(error => {
        console.error('Logout error:', error);
        // Still clear local storage and redirect
        localStorage.removeItem('adminToken');
        localStorage.removeItem('adminUser');
        redirectToLogin();
    });
}

function initializeDashboard() {
    loadDashboardStats();
    loadRecentDrivers();
    
    // Setup form submissions
    document.getElementById('driver-form').addEventListener('submit', handleDriverSubmit);
    document.getElementById('route-form').addEventListener('submit', handleRouteSubmit);
    document.getElementById('bus-form').addEventListener('submit', handleBusSubmit);
    
    // Setup search functionality
    document.getElementById('search-drivers').addEventListener('input', debounce(filterDrivers, 300));
    document.getElementById('search-routes').addEventListener('input', debounce(() => loadRoutes(), 300));
    document.getElementById('search-buses').addEventListener('input', debounce(() => loadBuses(), 300));
    
    // Setup form validation
    setupFormValidation();
}

// Helper function for authenticated API calls
async function apiCall(url, options = {}) {
    const defaultOptions = {
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${authToken}`,
            ...options.headers
        }
    };
    
    const mergedOptions = { ...defaultOptions, ...options };
    
    try {
        const response = await fetch(url, mergedOptions);
        
        if (response.status === 401) {
            // Token expired or invalid
            localStorage.removeItem('adminToken');
            localStorage.removeItem('adminUser');
            redirectToLogin();
            return null;
        }
        
        return response;
    } catch (error) {
        console.error('API call error:', error);
        throw error;
    }
}

// Form validation setup
function setupFormValidation() {
    const form = document.getElementById('driver-form');
    const inputs = form.querySelectorAll('input[required], select[required]');
    
    inputs.forEach(input => {
        input.addEventListener('blur', validateField);
        input.addEventListener('input', clearFieldError);
    });
    
    // Custom validations
    document.getElementById('idNumber').addEventListener('input', validateIdNumber);
    document.getElementById('phone').addEventListener('input', validatePhone);
    document.getElementById('email').addEventListener('input', validateEmail);
}

function validateField(e) {
    const field = e.target;
    const value = field.value.trim();
    
    clearFieldError({ target: field });
    
    if (field.hasAttribute('required') && !value) {
        showFieldError(field, 'This field is required');
        return false;
    }
    
    // Specific validations
    switch (field.id) {
        case 'age':
            if (value < 18 || value > 70) {
                showFieldError(field, 'Age must be between 18 and 70');
                return false;
            }
            break;
        case 'idNumber':
            return validateIdNumber(e);
        case 'phone':
            return validatePhone(e);
        case 'email':
            return validateEmail(e);
    }
    
    return true;
}

function validateIdNumber(e) {
    const field = e.target;
    const value = field.value.trim();
    
    if (value && !/^\d{8,15}$/.test(value)) {
        showFieldError(field, 'ID Number must be 8-15 digits');
        return false;
    }
    return true;
}

function validatePhone(e) {
    const field = e.target;
    const value = field.value.trim();
    
    if (value && !/^[\+]?[0-9\s\-\(\)]{10,15}$/.test(value)) {
        showFieldError(field, 'Please enter a valid phone number');
        return false;
    }
    return true;
}

function validateEmail(e) {
    const field = e.target;
    const value = field.value.trim();
    
    if (value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
        showFieldError(field, 'Please enter a valid email address');
        return false;
    }
    return true;
}

function showFieldError(field, message) {
    clearFieldError({ target: field });
    
    field.classList.add('is-invalid');
    const errorDiv = document.createElement('div');
    errorDiv.className = 'invalid-feedback';
    errorDiv.textContent = message;
    field.parentNode.appendChild(errorDiv);
}

function clearFieldError(e) {
    const field = e.target;
    field.classList.remove('is-invalid');
    const errorDiv = field.parentNode.querySelector('.invalid-feedback');
    if (errorDiv) {
        errorDiv.remove();
    }
}

function validateForm(form) {
    const inputs = form.querySelectorAll('input[required], select[required]');
    let isValid = true;
    
    inputs.forEach(input => {
        const fieldValid = validateField({ target: input });
        if (!fieldValid) {
            isValid = false;
        }
    });
    
    return isValid;
}

// Navigation functions
function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.style.display = 'none';
    });
    
    // Show selected section
    document.getElementById(sectionId).style.display = 'block';
    
    // Update navigation active state
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`[href="#${sectionId}"]`).classList.add('active');
    
    // Load section-specific data
    if (sectionId === 'drivers') {
        loadDrivers();
    } else if (sectionId === 'routes') {
        loadRouteStats();
        loadRoutes();
    } else if (sectionId === 'buses') {
        loadBusStats();
        loadBuses();
    }
}

// Dashboard stats functions
async function loadDashboardStats() {
    try {
        const response = await apiCall(`${API_BASE_URL}/drivers/stats`);
        if (!response) return; // Authentication failed
        
        const data = await response.json();
        
        if (response.ok) {
            const stats = data.statusStats;
            document.getElementById('total-drivers').textContent = stats.total;
            document.getElementById('active-drivers').textContent = stats.active;
            document.getElementById('inactive-drivers').textContent = stats.inactive;
            document.getElementById('suspended-drivers').textContent = stats.suspended;
        }
    } catch (error) {
        console.error('Error loading dashboard stats:', error);
        showAlert('Error loading dashboard statistics', 'danger');
    }
}

async function loadRecentDrivers() {
    try {
        const response = await apiCall(`${API_BASE_URL}/drivers?limit=5`);
        if (!response) return; // Authentication failed
        
        const data = await response.json();
        
        if (response.ok) {
            const tbody = document.querySelector('#recent-drivers-table tbody');
            tbody.innerHTML = '';
            
            data.drivers.forEach(driver => {
                const row = createDriverRow(driver, true);
                tbody.appendChild(row);
            });
        }
    } catch (error) {
        console.error('Error loading recent drivers:', error);
    }
}

// Driver management functions
async function loadDrivers(page = 1) {
    try {
        const searchParams = new URLSearchParams({
            page: page,
            limit: 10
        });
        
        // Add filters
        const search = document.getElementById('search-drivers')?.value;
        const status = document.getElementById('filter-status')?.value;
        const company = document.getElementById('filter-company')?.value;
        
        if (search) searchParams.append('search', search);
        if (status) searchParams.append('status', status);
        if (company) searchParams.append('busCompany', company);
        
        const response = await apiCall(`${API_BASE_URL}/drivers?${searchParams}`);
        if (!response) return; // Authentication failed
        
        const data = await response.json();
        
        if (response.ok) {
            currentDrivers = data.drivers;
            displayDrivers(data.drivers);
            updatePagination(data.currentPage, data.totalPages);
            currentPage = data.currentPage;
        }
    } catch (error) {
        console.error('Error loading drivers:', error);
        showAlert('Error loading drivers', 'danger');
    }
}

function displayDrivers(drivers) {
    const tbody = document.querySelector('#drivers-table tbody');
    tbody.innerHTML = '';
    
    drivers.forEach(driver => {
        const row = createDriverRow(driver, false);
        tbody.appendChild(row);
    });
}

function createDriverRow(driver, isRecent = false) {
    const row = document.createElement('tr');
    
    const statusBadge = `<span class="badge status-badge ${driver.status}">${driver.status.toUpperCase()}</span>`;
    const formattedDate = new Date(driver.createdAt).toLocaleDateString();
    
    if (isRecent) {
        row.innerHTML = `
            <td>${driver.name}</td>
            <td>${driver.idNumber}</td>
            <td>${driver.busCompany}</td>
            <td>${driver.licensePlate}</td>
            <td>${statusBadge}</td>
            <td>${formattedDate}</td>
        `;
    } else {
        row.innerHTML = `
            <td>${driver.name}</td>
            <td>${driver.idNumber}</td>
            <td>${driver.age}</td>
            <td>${driver.phone}</td>
            <td>${driver.busCompany}</td>
            <td>${driver.licensePlate}</td>
            <td>${statusBadge}</td>
            <td>
                <button class="btn btn-sm btn-outline-primary me-1" onclick="editDriver('${driver._id}')">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-outline-danger" onclick="deleteDriver('${driver._id}')">
                    <i class="fas fa-trash"></i>
                </button>
            </td>
        `;
    }
    
    return row;
}

function updatePagination(currentPage, totalPages) {
    const pagination = document.getElementById('pagination');
    pagination.innerHTML = '';
    
    // Previous button
    const prevLi = document.createElement('li');
    prevLi.className = `page-item ${currentPage === 1 ? 'disabled' : ''}`;
    prevLi.innerHTML = `<a class="page-link" href="#" onclick="loadDrivers(${currentPage - 1})">Previous</a>`;
    pagination.appendChild(prevLi);
    
    // Page numbers
    for (let i = 1; i <= totalPages; i++) {
        if (i === currentPage || i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
            const li = document.createElement('li');
            li.className = `page-item ${i === currentPage ? 'active' : ''}`;
            li.innerHTML = `<a class="page-link" href="#" onclick="loadDrivers(${i})">${i}</a>`;
            pagination.appendChild(li);
        } else if (i === currentPage - 2 || i === currentPage + 2) {
            const li = document.createElement('li');
            li.className = 'page-item disabled';
            li.innerHTML = '<span class="page-link">...</span>';
            pagination.appendChild(li);
        }
    }
    
    // Next button
    const nextLi = document.createElement('li');
    nextLi.className = `page-item ${currentPage === totalPages ? 'disabled' : ''}`;
    nextLi.innerHTML = `<a class="page-link" href="#" onclick="loadDrivers(${currentPage + 1})">Next</a>`;
    pagination.appendChild(nextLi);
}

// Form handling
async function handleDriverSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    
    // Validate all fields before submission
    const isValid = validateForm(form);
    if (!isValid) {
        showAlert('Please fix the errors in the form', 'warning');
        return;
    }
    
    const isEditMode = form.dataset.mode === 'edit';
    const driverId = form.dataset.editId;
    
    const formData = {
        name: document.getElementById('name').value,
        idNumber: document.getElementById('idNumber').value,
        age: parseInt(document.getElementById('age').value),
        phone: document.getElementById('phone').value,
        email: document.getElementById('email').value,
        busCompany: document.getElementById('busCompany').value,
        licensePlate: document.getElementById('licensePlate').value,
        licenseNumber: document.getElementById('licenseNumber').value,
        experienceYears: parseInt(document.getElementById('experienceYears').value) || 0,
        status: document.getElementById('status').value
    };
    
    try {
        const url = isEditMode ? `${API_BASE_URL}/drivers/${driverId}` : `${API_BASE_URL}/drivers`;
        const method = isEditMode ? 'PUT' : 'POST';
        
        const response = await apiCall(url, {
            method: method,
            body: JSON.stringify(formData)
        });
        
        if (!response) return; // Authentication failed
        
        const result = await response.json();
        
        if (response.ok) {
            const message = isEditMode ? 'Driver updated successfully!' : 'Driver registered successfully!';
            showAlert(message, 'success');
            clearForm();
            loadDashboardStats(); // Refresh stats
            if (isEditMode) {
                showSection('drivers'); // Go back to drivers list after edit
                loadDrivers(currentPage);
            }
        } else {
            showAlert(result.error || `Error ${isEditMode ? 'updating' : 'registering'} driver`, 'danger');
        }
    } catch (error) {
        console.error('Error submitting driver:', error);
        showAlert(`Error ${isEditMode ? 'updating' : 'registering'} driver`, 'danger');
    }
}

function clearForm() {
    const form = document.getElementById('driver-form');
    form.reset();
    
    // Reset form mode
    delete form.dataset.editId;
    delete form.dataset.mode;
    
    // Reset form title and button
    document.querySelector('#add-driver h2').textContent = 'Add New Driver';
    document.querySelector('#driver-form button[type="submit"]').innerHTML = 
        '<i class="fas fa-save me-2"></i> Save Driver';
    
    // Hide cancel edit button
    document.getElementById('cancel-edit-btn').style.display = 'none';
}

function cancelEdit() {
    clearForm();
    showSection('drivers');
}

// Export functionality
async function exportDrivers() {
    try {
        showAlert('Preparing export...', 'info');
        
        // Fetch all drivers without pagination
        const response = await apiCall(`${API_BASE_URL}/drivers?limit=1000`);
        if (!response) return; // Authentication failed
        
        const data = await response.json();
        
        if (response.ok) {
            const drivers = data.drivers;
            const csvContent = generateCSV(drivers);
            downloadCSV(csvContent, 'drivers_export.csv');
            showAlert('Drivers exported successfully!', 'success');
        } else {
            showAlert('Error exporting drivers', 'danger');
        }
    } catch (error) {
        console.error('Error exporting drivers:', error);
        showAlert('Error exporting drivers', 'danger');
    }
}

function generateCSV(drivers) {
    const headers = [
        'Name', 'ID Number', 'Age', 'Phone', 'Email', 'Bus Company', 
        'License Plate', 'License Number', 'Experience Years', 'Status', 'Registration Date'
    ];
    
    const csvRows = [headers.join(',')];
    
    drivers.forEach(driver => {
        const row = [
            `"${driver.name}"`,
            `"${driver.idNumber}"`,
            driver.age,
            `"${driver.phone}"`,
            `"${driver.email || ''}"`,
            `"${driver.busCompany}"`,
            `"${driver.licensePlate}"`,
            `"${driver.licenseNumber || ''}"`,
            driver.experienceYears || 0,
            `"${driver.status}"`,
            `"${new Date(driver.createdAt).toLocaleDateString()}"`
        ];
        csvRows.push(row.join(','));
    });
    
    return csvRows.join('\n');
}

function downloadCSV(csvContent, filename) {
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    
    if (link.download !== undefined) {
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', filename);
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(url);
    }
}

// Driver actions
async function editDriver(driverId) {
    try {
        // Fetch driver data
        const response = await apiCall(`${API_BASE_URL}/drivers/${driverId}`);
        if (!response) return; // Authentication failed
        
        const data = await response.json();
        
        if (response.ok) {
            const driver = data.driver;
            
            // Populate form with driver data
            document.getElementById('name').value = driver.name;
            document.getElementById('idNumber').value = driver.idNumber;
            document.getElementById('age').value = driver.age;
            document.getElementById('phone').value = driver.phone;
            document.getElementById('email').value = driver.email || '';
            document.getElementById('busCompany').value = driver.busCompany;
            document.getElementById('licensePlate').value = driver.licensePlate;
            document.getElementById('licenseNumber').value = driver.licenseNumber || '';
            document.getElementById('experienceYears').value = driver.experienceYears || 0;
            document.getElementById('status').value = driver.status;
            
            // Change form to edit mode
            const form = document.getElementById('driver-form');
            form.dataset.editId = driverId;
            form.dataset.mode = 'edit';
            
            // Update form title and button
            document.querySelector('#add-driver h2').textContent = 'Edit Driver';
            document.querySelector('#driver-form button[type="submit"]').innerHTML = 
                '<i class="fas fa-save me-2"></i> Update Driver';
            
            // Show cancel edit button
            document.getElementById('cancel-edit-btn').style.display = 'inline-block';
            
            // Show the form section
            showSection('add-driver');
            
            showAlert('Driver data loaded for editing', 'info');
        } else {
            showAlert(data.error || 'Error loading driver data', 'danger');
        }
    } catch (error) {
        console.error('Error loading driver for edit:', error);
        showAlert('Error loading driver data', 'danger');
    }
}

async function deleteDriver(driverId) {
    if (!confirm('Are you sure you want to delete this driver?')) {
        return;
    }
    
    try {
        const response = await apiCall(`${API_BASE_URL}/drivers/${driverId}`, {
            method: 'DELETE'
        });
        
        if (!response) return; // Authentication failed
        
        if (response.ok) {
            showAlert('Driver deleted successfully!', 'success');
            loadDrivers(currentPage);
            loadDashboardStats();
        } else {
            const result = await response.json();
            showAlert(result.error || 'Error deleting driver', 'danger');
        }
    } catch (error) {
        console.error('Error deleting driver:', error);
        showAlert('Error deleting driver', 'danger');
    }
}

// Filter and search
function filterDrivers() {
    loadDrivers(1); // Reset to first page when filtering
}

// Routes Management Functions
let currentRoutesPage = 1;
let currentBusesPage = 1;

// Load route statistics
async function loadRouteStats() {
    try {
        const response = await apiCall(`${API_BASE_URL}/routes/stats`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const stats = data.stats;
            document.getElementById('total-routes').textContent = stats.total;
            document.getElementById('active-routes').textContent = stats.active;
            document.getElementById('avg-fare').textContent = `$${stats.averageFare}`;
            document.getElementById('avg-distance').textContent = `${stats.averageDistance} km`;
        }
    } catch (error) {
        console.error('Error loading route stats:', error);
    }
}

// Load routes with pagination
async function loadRoutes(page = 1) {
    try {
        const searchParams = new URLSearchParams({
            page: page,
            limit: 10
        });
        
        const search = document.getElementById('search-routes')?.value;
        const status = document.getElementById('filter-route-status')?.value;
        
        if (search) searchParams.append('search', search);
        if (status !== '') searchParams.append('isActive', status);
        
        const response = await apiCall(`${API_BASE_URL}/routes?${searchParams}`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const tbody = document.getElementById('routes-table-body');
            tbody.innerHTML = '';
            
            data.routes.forEach(route => {
                const row = createRouteRow(route);
                tbody.appendChild(row);
            });
            
            // Update pagination
            updateRoutesPagination(data.pagination);
            currentRoutesPage = page;
        }
    } catch (error) {
        console.error('Error loading routes:', error);
        showAlert('Error loading routes', 'danger');
    }
}

// Create route table row
function createRouteRow(route) {
    const row = document.createElement('tr');
    row.innerHTML = `
        <td>
            <strong>${route.name}</strong><br>
            <small class="text-muted">${route.description}</small>
        </td>
        <td>${route.distanceInKm} km</td>
        <td>${route.estimatedTimeInMinutes} min</td>
        <td>$${route.fareAmount}</td>
        <td>
            <span class="badge ${route.isActive ? 'bg-success' : 'bg-secondary'}">
                ${route.isActive ? 'Active' : 'Inactive'}
            </span>
        </td>
        <td>
            <button class="btn btn-sm btn-outline-primary me-1" onclick="editRoute('${route._id}')">
                <i class="fas fa-edit"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger" onclick="deleteRoute('${route._id}')">
                <i class="fas fa-trash"></i>
            </button>
        </td>
    `;
    return row;
}

// Update routes pagination
function updateRoutesPagination(pagination) {
    const paginationContainer = document.getElementById('routes-pagination');
    paginationContainer.innerHTML = '';
    
    if (pagination.pages <= 1) return;
    
    for (let i = 1; i <= pagination.pages; i++) {
        const li = document.createElement('li');
        li.className = `page-item ${i === pagination.current ? 'active' : ''}`;
        li.innerHTML = `<a class="page-link" href="#" onclick="loadRoutes(${i})">${i}</a>`;
        paginationContainer.appendChild(li);
    }
}

// Show add route form
function showAddRouteForm() {
    document.getElementById('route-form-title').textContent = 'Add New Route';
    document.getElementById('route-form').dataset.mode = 'add';
    document.getElementById('route-form').reset();
    document.getElementById('route-form-container').style.display = 'block';
    document.getElementById('route-form-container').scrollIntoView();
}

// Hide route form
function hideRouteForm() {
    document.getElementById('route-form-container').style.display = 'none';
    document.getElementById('route-form').reset();
    delete document.getElementById('route-form').dataset.editId;
}

// Route form submission
async function handleRouteSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    const isEditMode = form.dataset.mode === 'edit';
    const routeId = form.dataset.editId;
    
    const formData = {
        name: document.getElementById('route-name').value,
        description: document.getElementById('route-description').value,
        distanceInKm: parseFloat(document.getElementById('route-distance').value),
        estimatedTimeInMinutes: parseInt(document.getElementById('route-time').value),
        fareAmount: parseFloat(document.getElementById('route-fare').value),
        isActive: document.getElementById('route-status').value === 'true',
        startLocation: {
            latitude: parseFloat(document.getElementById('start-lat').value),
            longitude: parseFloat(document.getElementById('start-lng').value)
        },
        endLocation: {
            latitude: parseFloat(document.getElementById('end-lat').value),
            longitude: parseFloat(document.getElementById('end-lng').value)
        }
    };
    
    try {
        const url = isEditMode ? `${API_BASE_URL}/routes/${routeId}` : `${API_BASE_URL}/routes`;
        const method = isEditMode ? 'PUT' : 'POST';
        
        const response = await apiCall(url, {
            method: method,
            body: JSON.stringify(formData)
        });
        
        if (!response) return;
        
        const result = await response.json();
        
        if (response.ok) {
            const message = isEditMode ? 'Route updated successfully!' : 'Route created successfully!';
            showAlert(message, 'success');
            hideRouteForm();
            loadRouteStats();
            loadRoutes(currentRoutesPage);
        } else {
            showAlert(result.message || `Error ${isEditMode ? 'updating' : 'creating'} route`, 'danger');
        }
    } catch (error) {
        console.error('Error submitting route:', error);
        showAlert('Error submitting route', 'danger');
    }
}

// Edit route
async function editRoute(routeId) {
    try {
        const response = await apiCall(`${API_BASE_URL}/routes/${routeId}`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok) {
            const route = data;
            
            // Populate form
            document.getElementById('route-name').value = route.name;
            document.getElementById('route-description').value = route.description;
            document.getElementById('route-distance').value = route.distanceInKm;
            document.getElementById('route-time').value = route.estimatedTimeInMinutes;
            document.getElementById('route-fare').value = route.fareAmount;
            document.getElementById('route-status').value = route.isActive.toString();
            document.getElementById('start-lat').value = route.startLocation.latitude;
            document.getElementById('start-lng').value = route.startLocation.longitude;
            document.getElementById('end-lat').value = route.endLocation.latitude;
            document.getElementById('end-lng').value = route.endLocation.longitude;
            
            // Set form to edit mode
            const form = document.getElementById('route-form');
            form.dataset.mode = 'edit';
            form.dataset.editId = routeId;
            document.getElementById('route-form-title').textContent = 'Edit Route';
            document.getElementById('route-form-container').style.display = 'block';
            document.getElementById('route-form-container').scrollIntoView();
        }
    } catch (error) {
        console.error('Error loading route for edit:', error);
        showAlert('Error loading route details', 'danger');
    }
}

// Delete route
async function deleteRoute(routeId) {
    if (!confirm('Are you sure you want to delete this route?')) return;
    
    try {
        const response = await apiCall(`${API_BASE_URL}/routes/${routeId}`, {
            method: 'DELETE'
        });
        
        if (!response) return;
        
        if (response.ok) {
            showAlert('Route deleted successfully!', 'success');
            loadRouteStats();
            loadRoutes(currentRoutesPage);
        } else {
            const result = await response.json();
            showAlert(result.message || 'Error deleting route', 'danger');
        }
    } catch (error) {
        console.error('Error deleting route:', error);
        showAlert('Error deleting route', 'danger');
    }
}

// Export routes
async function exportRoutes() {
    try {
        showAlert('Preparing export...', 'info');
        
        const response = await apiCall(`${API_BASE_URL}/routes?limit=1000`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const csvContent = generateRoutesCSV(data.routes);
            downloadCSV(csvContent, 'routes_export.csv');
            showAlert('Routes exported successfully!', 'success');
        } else {
            showAlert('Error exporting routes', 'danger');
        }
    } catch (error) {
        console.error('Error exporting routes:', error);
        showAlert('Error exporting routes', 'danger');
    }
}

// Generate CSV for routes
function generateRoutesCSV(routes) {
    const headers = ['Name', 'Description', 'Distance (km)', 'Time (min)', 'Fare', 'Status', 'Start Lat', 'Start Lng', 'End Lat', 'End Lng'];
    const csvRows = [headers.join(',')];
    
    routes.forEach(route => {
        const row = [
            `"${route.name}"`,
            `"${route.description}"`,
            route.distanceInKm,
            route.estimatedTimeInMinutes,
            route.fareAmount,
            route.isActive ? 'Active' : 'Inactive',
            route.startLocation.latitude,
            route.startLocation.longitude,
            route.endLocation.latitude,
            route.endLocation.longitude
        ];
        csvRows.push(row.join(','));
    });
    
    return csvRows.join('\n');
}

// Bus Management Functions

// Load bus statistics
async function loadBusStats() {
    try {
        const response = await apiCall(`${API_BASE_URL}/buses/stats`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const stats = data.stats;
            document.getElementById('total-buses').textContent = stats.total;
            document.getElementById('in-service-buses').textContent = stats.inService;
            document.getElementById('maintenance-buses').textContent = stats.maintenance;
            document.getElementById('out-service-buses').textContent = stats.outOfService;
        }
    } catch (error) {
        console.error('Error loading bus stats:', error);
    }
}

// Load buses with pagination
async function loadBuses(page = 1) {
    try {
        const searchParams = new URLSearchParams({
            page: page,
            limit: 10
        });
        
        const search = document.getElementById('search-buses')?.value;
        const status = document.getElementById('filter-bus-status')?.value;
        
        if (search) searchParams.append('search', search);
        if (status) searchParams.append('status', status);
        
        const response = await apiCall(`${API_BASE_URL}/buses?${searchParams}`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const tbody = document.getElementById('buses-table-body');
            tbody.innerHTML = '';
            
            data.buses.forEach(bus => {
                const row = createBusRow(bus);
                tbody.appendChild(row);
            });
            
            // Update pagination
            updateBusesPagination(data.pagination);
            currentBusesPage = page;
        }
    } catch (error) {
        console.error('Error loading buses:', error);
        showAlert('Error loading buses', 'danger');
    }
}

// Create bus table row
function createBusRow(bus) {
    const row = document.createElement('tr');
    row.innerHTML = `
        <td><strong>${bus.busNumber}</strong></td>
        <td>${bus.licenseNumber}</td>
        <td>${bus.capacity} passengers</td>
        <td>${bus.currentRouteId?.name || 'No Route'}</td>
        <td>
            <span class="badge ${getBusStatusClass(bus.currentStatus)}">
                ${formatBusStatus(bus.currentStatus)}
            </span>
        </td>
        <td>
            <button class="btn btn-sm btn-outline-primary me-1" onclick="editBus('${bus._id}')">
                <i class="fas fa-edit"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger" onclick="deleteBus('${bus._id}')">
                <i class="fas fa-trash"></i>
            </button>
        </td>
    `;
    return row;
}

// Get bus status class for badge
function getBusStatusClass(status) {
    switch (status) {
        case 'in-service': return 'bg-success';
        case 'maintenance': return 'bg-warning';
        case 'out-of-service': return 'bg-secondary';
        default: return 'bg-secondary';
    }
}

// Format bus status for display
function formatBusStatus(status) {
    switch (status) {
        case 'in-service': return 'In Service';
        case 'maintenance': return 'Maintenance';
        case 'out-of-service': return 'Out of Service';
        default: return status;
    }
}

// Update buses pagination
function updateBusesPagination(pagination) {
    const paginationContainer = document.getElementById('buses-pagination');
    paginationContainer.innerHTML = '';
    
    if (pagination.pages <= 1) return;
    
    for (let i = 1; i <= pagination.pages; i++) {
        const li = document.createElement('li');
        li.className = `page-item ${i === pagination.current ? 'active' : ''}`;
        li.innerHTML = `<a class="page-link" href="#" onclick="loadBuses(${i})">${i}</a>`;
        paginationContainer.appendChild(li);
    }
}

// Show add bus form
function showAddBusForm() {
    document.getElementById('bus-form-title').textContent = 'Add New Bus';
    document.getElementById('bus-form').dataset.mode = 'add';
    document.getElementById('bus-form').reset();
    loadRoutesForSelect(); // Load routes for the dropdown
    document.getElementById('bus-form-container').style.display = 'block';
    document.getElementById('bus-form-container').scrollIntoView();
}

// Hide bus form
function hideBusForm() {
    document.getElementById('bus-form-container').style.display = 'none';
    document.getElementById('bus-form').reset();
    delete document.getElementById('bus-form').dataset.editId;
}

// Load routes for select dropdown
async function loadRoutesForSelect() {
    try {
        const response = await apiCall(`${API_BASE_URL}/routes?limit=100&isActive=true`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const select = document.getElementById('current-route');
            select.innerHTML = '<option value="">No Route Assigned</option>';
            
            data.routes.forEach(route => {
                const option = document.createElement('option');
                option.value = route._id;
                option.textContent = route.name;
                select.appendChild(option);
            });
        }
    } catch (error) {
        console.error('Error loading routes for select:', error);
    }
}

// Bus form submission
async function handleBusSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    const isEditMode = form.dataset.mode === 'edit';
    const busId = form.dataset.editId;
    
    const formData = {
        busNumber: document.getElementById('bus-number').value,
        licenseNumber: document.getElementById('license-number').value,
        capacity: parseInt(document.getElementById('bus-capacity').value),
        currentStatus: document.getElementById('bus-status').value
    };
    
    const routeId = document.getElementById('current-route').value;
    if (routeId) {
        formData.currentRouteId = routeId;
    }
    
    try {
        const url = isEditMode ? `${API_BASE_URL}/buses/${busId}` : `${API_BASE_URL}/buses`;
        const method = isEditMode ? 'PUT' : 'POST';
        
        const response = await apiCall(url, {
            method: method,
            body: JSON.stringify(formData)
        });
        
        if (!response) return;
        
        const result = await response.json();
        
        if (response.ok) {
            const message = isEditMode ? 'Bus updated successfully!' : 'Bus created successfully!';
            showAlert(message, 'success');
            hideBusForm();
            loadBusStats();
            loadBuses(currentBusesPage);
        } else {
            showAlert(result.message || `Error ${isEditMode ? 'updating' : 'creating'} bus`, 'danger');
        }
    } catch (error) {
        console.error('Error submitting bus:', error);
        showAlert('Error submitting bus', 'danger');
    }
}

// Edit bus
async function editBus(busId) {
    try {
        const response = await apiCall(`${API_BASE_URL}/buses/${busId}`);
        if (!response) return;
        
        const bus = await response.json();
        
        if (response.ok) {
            // Load routes first, then populate form
            await loadRoutesForSelect();
            
            // Populate form
            document.getElementById('bus-number').value = bus.busNumber;
            document.getElementById('license-number').value = bus.licenseNumber;
            document.getElementById('bus-capacity').value = bus.capacity;
            document.getElementById('bus-status').value = bus.currentStatus;
            
            if (bus.currentRouteId) {
                document.getElementById('current-route').value = bus.currentRouteId._id || bus.currentRouteId;
            }
            
            // Set form to edit mode
            const form = document.getElementById('bus-form');
            form.dataset.mode = 'edit';
            form.dataset.editId = busId;
            document.getElementById('bus-form-title').textContent = 'Edit Bus';
            document.getElementById('bus-form-container').style.display = 'block';
            document.getElementById('bus-form-container').scrollIntoView();
        }
    } catch (error) {
        console.error('Error loading bus for edit:', error);
        showAlert('Error loading bus details', 'danger');
    }
}

// Delete bus
async function deleteBus(busId) {
    if (!confirm('Are you sure you want to delete this bus?')) return;
    
    try {
        const response = await apiCall(`${API_BASE_URL}/buses/${busId}`, {
            method: 'DELETE'
        });
        
        if (!response) return;
        
        if (response.ok) {
            showAlert('Bus deleted successfully!', 'success');
            loadBusStats();
            loadBuses(currentBusesPage);
        } else {
            const result = await response.json();
            showAlert(result.message || 'Error deleting bus', 'danger');
        }
    } catch (error) {
        console.error('Error deleting bus:', error);
        showAlert('Error deleting bus', 'danger');
    }
}

// Export buses
async function exportBuses() {
    try {
        showAlert('Preparing export...', 'info');
        
        const response = await apiCall(`${API_BASE_URL}/buses?limit=1000`);
        if (!response) return;
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            const csvContent = generateBusesCSV(data.buses);
            downloadCSV(csvContent, 'buses_export.csv');
            showAlert('Buses exported successfully!', 'success');
        } else {
            showAlert('Error exporting buses', 'danger');
        }
    } catch (error) {
        console.error('Error exporting buses:', error);
        showAlert('Error exporting buses', 'danger');
    }
}

// Generate CSV for buses
function generateBusesCSV(buses) {
    const headers = ['Bus Number', 'License Number', 'Capacity', 'Current Route', 'Status'];
    const csvRows = [headers.join(',')];
    
    buses.forEach(bus => {
        const row = [
            `"${bus.busNumber}"`,
            `"${bus.licenseNumber}"`,
            bus.capacity,
            `"${bus.currentRouteId?.name || 'No Route'}"`,
            `"${formatBusStatus(bus.currentStatus)}"`
        ];
        csvRows.push(row.join(','));
    });
    
    return csvRows.join('\n');
}

// Utility functions
function showAlert(message, type = 'info') {
    // Create alert element
    const alertDiv = document.createElement('div');
    alertDiv.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    alertDiv.style.cssText = 'top: 20px; right: 20px; z-index: 1050; min-width: 300px;';
    alertDiv.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `;
    
    document.body.appendChild(alertDiv);
    
    // Auto dismiss after 5 seconds
    setTimeout(() => {
        if (alertDiv.parentNode) {
            alertDiv.remove();
        }
    }, 5000);
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
