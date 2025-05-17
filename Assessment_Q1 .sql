-- Question 1. High value customers with multiple products.

-- Names of tables are shortened to an alias for ease of typing (users, plan, save).
SELECT 
    users.id AS owner_id,
    CONCAT(users.first_name, ' ', users.last_name) AS name,
    COUNT(DISTINCT CASE WHEN plan.is_regular_savings = 1 THEN plan.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN plan.is_a_fund = 1 THEN plan.id END) AS investment_count,
    ROUND(SUM(save.confirmed_amount) / 100.0, 0) AS total_deposits_naira -- figures are converted from Kobo to Naira.
FROM users_customuser users
JOIN plans_plan plan ON users.id = plan.owner_id
JOIN savings_savingsaccount save ON plan.id = save.plan_id
WHERE save.confirmed_amount > 0
GROUP BY 
	owner_id, 
    name
HAVING 
    savings_count >= 1
    AND
    investment_count >= 1
ORDER BY total_deposits_naira DESC;
