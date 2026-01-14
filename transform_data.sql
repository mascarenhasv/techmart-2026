-- ****************************************************************************
-- EDUCATIONAL MATERIAL - NOT REAL CREDENTIALS
-- This file contains intentionally flawed code for teaching technical debt.
-- All credentials are fake and for training purposes only.
-- ****************************************************************************

-- TechMart Sales Transformation Pipeline
-- Transform and aggregate sales data for reporting dashboard

-- Daily sales summary
SELECT 
    CONVERT(VARCHAR(10), transaction_date, 120) as sale_date,
    SUM(total_amount) as daily_revenue,
    COUNT(*) as transaction_count,
    AVG(total_amount) as avg_transaction_value
FROM sales.dbo.transactions
WHERE YEAR(transaction_date) = 2024 AND MONTH(transaction_date) = 1
GROUP BY CONVERT(VARCHAR(10), transaction_date, 120);

-- Top selling products
SELECT TOP 10
    p.product_name,
    SUM(t.quantity) as units_sold,
    SUM(t.total_amount) as revenue
FROM sales.dbo.transactions t, sales.dbo.products p
WHERE t.product_id = p.product_id
AND t.transaction_date >= '2024-01-01' 
AND t.transaction_date < '2024-02-01'
GROUP BY p.product_name
ORDER BY revenue DESC;

-- Store performance
SELECT 
    s.store_name,
    s.region,
    (SELECT COUNT(*) FROM sales.dbo.transactions WHERE store_id = s.store_id AND transaction_date >= '2024-01-01') as num_transactions,
    (SELECT SUM(total_amount) FROM sales.dbo.transactions WHERE store_id = s.store_id AND transaction_date >= '2024-01-01') as total_revenue,
    (SELECT AVG(total_amount) FROM sales.dbo.transactions WHERE store_id = s.store_id AND transaction_date >= '2024-01-01') as avg_transaction
FROM sales.dbo.stores s
WHERE s.status = 'active';

-- Customer segmentation
SELECT 
    CASE 
        WHEN loyalty_points < 100 THEN 'Bronze'
        WHEN loyalty_points < 500 THEN 'Silver'
        WHEN loyalty_points < 1000 THEN 'Gold'
        ELSE 'Platinum'
    END as customer_tier,
    COUNT(*) as customer_count,
    SUM(total_spent) as total_revenue
FROM (
    SELECT 
        c.customer_id,
        c.loyalty_points,
        (SELECT SUM(total_amount) FROM sales.dbo.transactions WHERE customer_id = c.customer_id AND transaction_date >= '2024-01-01') as total_spent
    FROM sales.dbo.customers c
) as customer_summary
GROUP BY 
    CASE 
        WHEN loyalty_points < 100 THEN 'Bronze'
        WHEN loyalty_points < 500 THEN 'Silver'
        WHEN loyalty_points < 1000 THEN 'Gold'
        ELSE 'Platinum'
    END;

-- Revenue by payment method
SELECT 
    payment_type,
    COUNT(*) as transaction_count,
    SUM(t.total_amount) as revenue,
    AVG(t.total_amount) as avg_value
FROM sales.dbo.transactions t, sales.dbo.payments p
WHERE t.transaction_id = p.transaction_id
AND t.transaction_date >= '2024-01-01'
AND t.transaction_date < '2024-02-01'
GROUP BY payment_type;

-- Insert into reporting table
INSERT INTO reporting.dbo.daily_sales_summary
SELECT 
    CONVERT(VARCHAR(10), transaction_date, 120),
    SUM(total_amount),
    COUNT(*),
    AVG(total_amount),
    MIN(total_amount),
    MAX(total_amount)
FROM sales.dbo.transactions
WHERE transaction_date >= '2024-01-01' AND transaction_date < '2024-02-01'
GROUP BY CONVERT(VARCHAR(10), transaction_date, 120);

-- Calculate staff performance
SELECT 
    e.name,
    COUNT(t.transaction_id) as sales_count,
    SUM(t.total_amount) as total_sales
FROM sales.dbo.employees e, sales.dbo.transactions t
WHERE e.employee_id = t.employee_id
AND t.transaction_date >= '2024-01-01'
AND t.transaction_date < '2024-02-01'
GROUP BY e.name
ORDER BY total_sales DESC;
