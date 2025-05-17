-- Question 4. CLV estimation.

/* There are 2 ID-related columns in the savingsaccount table (id and savings_id).
I'm using the id column for count because it has more distinct values.
*/
SELECT
    users.id AS customer_id,
    CONCAT(users.first_name, ' ', users.last_name) AS name,
    TIMESTAMPDIFF(MONTH, users.date_joined, CURRENT_DATE) AS tenure_months,
    COUNT(save.id) AS total_transactions,
    ROUND(
        (
            COUNT(save.id) /
            NULLIF(TIMESTAMPDIFF(MONTH, users.date_joined, CURRENT_DATE), 0)
        ) * 12 * 
        (0.001 * (SUM(save.confirmed_amount) / NULLIF(COUNT(save.id), 0))),
        0
    ) AS estimated_clv
FROM users_customuser users
JOIN savings_savingsaccount save ON users.id = save.owner_id
WHERE save.confirmed_amount > 0
GROUP BY customer_id, name, tenure_months
ORDER BY estimated_clv DESC;
