-- =========================================
-- PHARMACY STOCK & BILLING DATABASE
-- =========================================

DROP DATABASE IF EXISTS pharmacy_db;
CREATE DATABASE pharmacy_db;
USE pharmacy_db;

-- =========================================
-- 1. ADMIN TABLE
-- =========================================
CREATE TABLE Admin (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE,
    password VARCHAR(255),
    role ENUM('Admin','Pharmacist','Manager'),
    email VARCHAR(100),
    last_login DATETIME
);

-- =========================================
-- 2. MEDICINE TABLE
-- =========================================
CREATE TABLE Medicine (
    med_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    manufacturer VARCHAR(100),
    category VARCHAR(50),
    gst_percent DECIMAL(5,2)
);

-- =========================================
-- 3. BATCH TABLE (CRITICAL)
-- =========================================
CREATE TABLE Batch (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    med_id INT,
    batch_number VARCHAR(50),
    mfg_date DATE,
    expiry_date DATE,
    purchase_price DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    quantity_available INT DEFAULT 0,
    FOREIGN KEY (med_id) REFERENCES Medicine(med_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =========================================
-- 4. SUPPLIER TABLE
-- =========================================
CREATE TABLE Supplier (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    address TEXT
);

-- =========================================
-- 5. PURCHASE TABLE
-- =========================================
CREATE TABLE Purchase (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    purchase_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =========================================
-- 6. PURCHASE DETAILS (BATCH ENTRY)
-- =========================================
CREATE TABLE Purchase_Details (
    purchase_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT,
    batch_id INT,
    quantity INT,
    cost_price DECIMAL(10,2),
    FOREIGN KEY (purchase_id) REFERENCES Purchase(purchase_id)
        ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
        ON DELETE CASCADE
);

-- =========================================
-- 7. CUSTOMER TABLE
-- =========================================
CREATE TABLE Customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(15)
);

-- =========================================
-- 8. BILL TABLE
-- =========================================
CREATE TABLE Bill (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    bill_date DATETIME,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
        ON DELETE SET NULL
);

-- =========================================
-- 9. BILL DETAILS (BATCH-WISE SALES)
-- =========================================
CREATE TABLE Bill_Details (
    bill_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    batch_id INT,
    quantity INT,
    selling_price DECIMAL(10,2),
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id)
        ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
        ON DELETE CASCADE
);

-- =========================================
-- 10. SALES RETURN
-- =========================================
CREATE TABLE Sales_Return (
    return_id INT AUTO_INCREMENT PRIMARY KEY,
    bill_id INT,
    return_date DATE,
    reason VARCHAR(255),
    FOREIGN KEY (bill_id) REFERENCES Bill(bill_id)
        ON DELETE CASCADE
);

-- =========================================
-- 11. SALES RETURN DETAILS
-- =========================================
CREATE TABLE Sales_Return_Details (
    return_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    return_id INT,
    batch_id INT,
    quantity INT,
    FOREIGN KEY (return_id) REFERENCES Sales_Return(return_id)
        ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
        ON DELETE CASCADE
);

-- =========================================
-- 12. SUPPLIER RETURN (EXPIRED/DAMAGED)
-- =========================================
CREATE TABLE Supplier_Return (
    supplier_return_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    return_date DATE,
    reason VARCHAR(255),
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
        ON DELETE SET NULL
);

-- =========================================
-- 13. SUPPLIER RETURN DETAILS
-- =========================================
CREATE TABLE Supplier_Return_Details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_return_id INT,
    batch_id INT,
    quantity INT,
    FOREIGN KEY (supplier_return_id) REFERENCES Supplier_Return(supplier_return_id)
        ON DELETE CASCADE,
    FOREIGN KEY (batch_id) REFERENCES Batch(batch_id)
        ON DELETE CASCADE
);

-- =========================================
-- TRIGGERS FOR STOCK MANAGEMENT
-- =========================================

-- Reduce stock on sale
DELIMITER //
CREATE TRIGGER reduce_stock_after_sale
AFTER INSERT ON Bill_Details
FOR EACH ROW
BEGIN
    UPDATE Batch
    SET quantity_available = quantity_available - NEW.quantity
    WHERE batch_id = NEW.batch_id;
END;
//
DELIMITER ;

-- Increase stock on sales return
DELIMITER //
CREATE TRIGGER increase_stock_after_return
AFTER INSERT ON Sales_Return_Details
FOR EACH ROW
BEGIN
    UPDATE Batch
    SET quantity_available = quantity_available + NEW.quantity
    WHERE batch_id = NEW.batch_id;
END;
//
DELIMITER ;

-- Reduce stock on supplier return
DELIMITER //
CREATE TRIGGER reduce_stock_supplier_return
AFTER INSERT ON Supplier_Return_Details
FOR EACH ROW
BEGIN
    UPDATE Batch
    SET quantity_available = quantity_available - NEW.quantity
    WHERE batch_id = NEW.batch_id;
END;
//
DELIMITER ;

-- =========================================
-- SAMPLE DATA
-- =========================================

INSERT INTO Medicine (name, manufacturer, category, gst_percent)
VALUES ('Paracetamol','Cipla','Tablet',5),
       ('Amoxicillin','Sun Pharma','Capsule',12);

INSERT INTO Supplier (name, phone, email, address)
VALUES ('ABC Pharma','9876543210','abc@pharma.com','Delhi');

INSERT INTO Customer (name, phone)
VALUES ('Rahul Sharma','9999999999');

-- Add batch
INSERT INTO Batch (med_id, batch_number, mfg_date, expiry_date, purchase_price, selling_price, quantity_available)
VALUES (1,'BATCH001','2025-01-01','2027-01-01',10,15,100);

-- Purchase entry
INSERT INTO Purchase (supplier_id, purchase_date, total_amount)
VALUES (1,CURDATE(),1000);

INSERT INTO Purchase_Details (purchase_id, batch_id, quantity, cost_price)
VALUES (1,1,100,10);

-- Sale
INSERT INTO Bill (customer_id, bill_date, total_amount)
VALUES (1,NOW(),150);

INSERT INTO Bill_Details (bill_id, batch_id, quantity, selling_price)
VALUES (1,1,10,15);

-- Sales Return
INSERT INTO Sales_Return (bill_id, return_date, reason)
VALUES (1,CURDATE(),'Damaged');

INSERT INTO Sales_Return_Details (return_id, batch_id, quantity)
VALUES (1,1,2);

-- Supplier Return
INSERT INTO Supplier_Return (supplier_id, return_date, reason)
VALUES (1,CURDATE(),'Expired');

INSERT INTO Supplier_Return_Details (supplier_return_id, batch_id, quantity)
VALUES (1,1,5);

-- =========================================
-- USEFUL QUERY (EXPIRY CHECK)
-- =========================================
SELECT * FROM Batch
WHERE expiry_date < CURDATE() + INTERVAL 30 DAY;
