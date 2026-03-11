/* PROJECT: NVIDIA Internal Sampling & Demand Optimization
AUTHOR: Aarha Khanna
DESCRIPTION: SQL simulation of internal hardware supply chain to track H100/GPU demand across business units.
*/

-- RERUN-SAFE RESET (Updated to include Employees)
DROP TABLE IF EXISTS Hardware_Requests;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Departments;

-- ==========================================
-- PHASE 1: SCHEMA SETUP
-- ==========================================

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    cost_center_code VARCHAR(20),
    region VARCHAR(50) -- NEW: Tracks geographical locations
);

CREATE TABLE Employees ( -- NEW: Tracks the "requestor"
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    title VARCHAR(50),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    product_family VARCHAR(50),
    unit_cost DECIMAL(10, 2)
);

CREATE TABLE Hardware_Requests (
    request_id INT PRIMARY KEY,
    request_date DATE,
    employee_id INT,
    dept_id INT,
    product_id INT,
    quantity_requested INT,
    status VARCHAR(20),
    return_date DATE,
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id) -- NEW: Link request to employee
);

-- ==========================================
-- PHASE 2: DATA SIMULATION (The "NVIDIA Context")
-- ==========================================

-- NEW: Added Global Regions
INSERT INTO Departments VALUES 
(1, 'Deep Learning Research', 'AI-001', 'North America (Santa Clara)'),
(2, 'GeForce Driver Dev', 'GF-202', 'APAC (Taipei)'),
(3, 'Omniverse Platform', 'OV-303', 'EMEA (London)'),
(4, 'Automotive/Robotics', 'AU-404', 'EMEA (Tel Aviv)');

-- NEW: Added Employee Roster
INSERT INTO Employees VALUES
(501, 'Ada', 'Lovelace', 'Senior AI Researcher', 1),
(502, 'David', 'Patterson', 'Lead Driver Engineer', 2),
(503, 'Katherine', 'Johnson', 'Robotics Product Manager', 4),
(504, 'John', 'Carmack', 'Omniverse Architect', 3);

INSERT INTO Products VALUES 
(101, 'NVIDIA H100 Tensor Core GPU', 'Data Center', 25000.00),
(102, 'NVIDIA L40S', 'Data Center', 12000.00),
(103, 'GeForce RTX 4090', 'Gaming', 1500.00),
(104, 'NVIDIA Orin SoC', 'Automotive', 800.00);

INSERT INTO Hardware_Requests VALUES 
(1, '2024-01-10', 501, 1, 101, 8, 'Fulfilled', '2024-03-10'),
(2, '2024-01-12', 502, 2, 103, 50, 'Fulfilled', '2024-06-12'),
(3, '2024-01-15', 503, 4, 104, 20, 'Pending', NULL),
(4, '2024-01-18', 501, 1, 101, 4, 'Fulfilled', '2024-02-18'),
(5, '2024-02-01', 504, 3, 102, 10, 'Backordered', NULL);

-- ==========================================
-- PHASE 3: ANALYTICAL QUERIES (The Insights)
-- ==========================================

-- Query A: Cost Analysis by Department & Region
-- Goal: Identify which business units are driving the highest internal costs.
SELECT 
    d.dept_name,
    d.region,
    p.product_family,
    COUNT(r.request_id) as total_requests,
    SUM(r.quantity_requested) as total_units_needed,
    SUM(r.quantity_requested * p.unit_cost) as total_internal_cost
FROM Hardware_Requests r
JOIN Departments d ON r.dept_id = d.dept_id
JOIN Products p ON r.product_id = p.product_id
GROUP BY d.dept_name, p.product_family
ORDER BY total_internal_cost DESC;

-- Spacer for readable output in SQLite CLI
-- .print ''

-- Query B: Stagnant Inventory Report
-- Goal: Find expensive hardware held longer than 60 days to improve circulation.
-- (Note: Using SQLite syntax for date; if using MySQL, use DATEDIFF)
-- Stable snapshot date for reproducible results (update as needed).
-- If you want live/updating values, replace params.report_date with DATE('now').
WITH params AS (SELECT DATE('2026-03-11') AS report_date)
SELECT 
    r.request_id,
    d.dept_name,
    e.first_name || ' ' || e.last_name as requestor,
    p.product_name,
    r.quantity_requested,
    (JULIANDAY(params.report_date) - JULIANDAY(r.request_date)) as days_held,
    (r.quantity_requested * p.unit_cost) as capital_tied_up
FROM Hardware_Requests r
JOIN Departments d ON r.dept_id = d.dept_id
JOIN Employees e ON r.employee_id = e.employee_id
JOIN Products p ON r.product_id = p.product_id
JOIN params
WHERE r.status = 'Fulfilled' 
AND (JULIANDAY(params.report_date) - JULIANDAY(r.request_date)) > 60
ORDER BY capital_tied_up DESC;

-- ==========================================
-- PHASE 4: FULL TABLE VALIDATION
-- ==========================================
-- Goal: Display the raw underlying data tables on execution

-- .print '--- DEPARTMENTS TABLE ---'
SELECT * FROM Departments;

-- .print '--- EMPLOYEES TABLE ---'
SELECT * FROM Employees;

-- .print '--- PRODUCTS TABLE ---'
SELECT * FROM Products;

-- .print '--- HARDWARE REQUESTS TABLE ---'
SELECT * FROM Hardware_Requests;
