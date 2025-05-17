-- Question 3. Account inactivity alert.

-- A CTE to check for the last transaction date for each plan.
WITH latest_tx AS (
    SELECT
        plan_id,
        MAX(transaction_date) AS last_tx_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY plan_id
)
/* Assigning a name to each plan type (Using 'Others' for unknown and non-specified types).
Found the number of days between the current date and the last transaction date.
Then filtered for days longer than a year (365 days).
*/
SELECT
    plan.id AS plan_id,
    plan.owner_id AS owner_id,
    CASE
        WHEN plan.is_regular_savings = 1 THEN 'Savings'
        WHEN plan.is_a_fund = 1 THEN 'Investment'
        ELSE 'Others'
    END AS type,
    latest_tx.last_tx_date,
    DATEDIFF(CURRENT_DATE, latest_tx.last_tx_date) AS inactivity_days
FROM plans_plan plan
JOIN latest_tx ON plan.id = latest_tx.plan_id
WHERE DATEDIFF(CURRENT_DATE, latest_tx.last_tx_date) > 365

-- Ordering by inactivity days for easy viewing.
ORDER BY inactivity_days DESC;
    