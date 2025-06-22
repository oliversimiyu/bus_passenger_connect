-- Create database
CREATE DATABASE IF NOT EXISTS bus_passenger_connect;
USE bus_passenger_connect;

-- Create drivers table
CREATE TABLE IF NOT EXISTS drivers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    id_number VARCHAR(20) UNIQUE NOT NULL,
    license_plate VARCHAR(20) NOT NULL,
    bus_company VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_id_number (id_number),
    INDEX idx_license_plate (license_plate),
    INDEX idx_bus_company (bus_company)
);

-- Create admin users table
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role ENUM('super_admin', 'admin') DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default admin user (password: admin123)
INSERT INTO admin_users (username, password, full_name, email, role) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'System Administrator', 'admin@busconnect.com', 'super_admin')
ON DUPLICATE KEY UPDATE username = username;

-- Create bus companies table
CREATE TABLE IF NOT EXISTS bus_companies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    contact_person VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    address TEXT,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some default bus companies
INSERT INTO bus_companies (name, contact_person, phone, email) VALUES 
('Nairobi City Express', 'John Kamau', '+254701234567', 'contact@nairobiexpress.co.ke'),
('Karen-Langata Shuttles', 'Mary Wanjiku', '+254712345678', 'info@karenlangata.co.ke'),
('Eastlands Connect', 'David Otieno', '+254723456789', 'support@eastlandsconnect.co.ke')
ON DUPLICATE KEY UPDATE name = name;
