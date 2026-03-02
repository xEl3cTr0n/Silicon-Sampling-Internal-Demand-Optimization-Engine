/* PROJECT: NVIDIA Internal Sampling & Demand Optimization
AUTHOR: Aarha Khanna
DESCRIPTION: SQL simulation of internal hardware supply chain to track H100/GPU demand across business units.
*/

-- ==========================================
-- PHASE 1: SCHEMA SETUP
-- ==========================================

CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    cost_center_code VARCHAR(20)
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
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- ==========================================
-- PHASE 2: DATA SIMULATION (The "NVIDIA Context")
-- ==========================================

INSERT INTO Departments VALUES 
(1, 'Deep Learning Research', 'AI-001'),
(2, 'GeForce Driver Dev', 'GF-202'),
(3, 'Omniverse Platform', 'OV-303'),
(4, 'Automotive/Robotics', 'AU-404');

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

-- Query A: Cost Analysis by Department
-- Goal: Identify which business units are driving the highest internal costs.
SELECT 
    d.dept_name,
    p.product_family,
    COUNT(r.request_id) as total_requests,
    SUM(r.quantity_requested) as total_units_needed,
    SUM(r.quantity_requested * p.unit_cost) as total_internal_cost
FROM Hardware_Requests r
JOIN Departments d ON r.dept_id = d.dept_id
JOIN Products p ON r.product_id = p.product_id
GROUP BY d.dept_name, p.product_family
ORDER BY total_internal_cost DESC;

-- Query B: Stagnant Inventory Report
-- Goal: Find expensive hardware held longer than 60 days to improve circulation.
-- (Note: Using SQLite syntax for date; if using MySQL, use DATEDIFF)
SELECT 
    r.request_id,
    d.dept_name,
    p.product_name,
    r.quantity_requested,
    (JULIANDAY('now') - JULIANDAY(r.request_date)) as days_held,
    (r.quantity_requested * p.unit_cost) as capital_tied_up
FROM Hardware_Requests r
JOIN Departments d ON r.dept_id = d.dept_id
JOIN Products p ON r.product_id = p.product_id
WHERE r.status = 'Fulfilled' 
AND (JULIANDAY('now') - JULIANDAY(r.request_date)) > 60
ORDER BY capital_tied_up DESC;