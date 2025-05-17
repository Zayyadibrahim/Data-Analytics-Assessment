-- Question 2. Transaction frequency analysis.

/* Creating a CTE (Common Table Expression) to get the average transaction per month
for each customer (More explanations in the README file).
*/
WITH transactions_per_customer AS (
    SELECT
        owner_id,
        COUNT(*) AS total_transactions,
        ROUND(
            COUNT(*) / NULLIF( 
                TIMESTAMPDIFF( -- This finds the number of months between the min and max transaction dates.
                    MONTH, MIN(transaction_date), MAX(transaction_date)
                ), 0 -- NULLIF here makes sure I don't divide by 0 if all transaction dates are in the same month.
            ), 2
        ) AS avg_tx_per_month
    FROM savings_savingsaccount
    GROUP BY owner_id
),
-- A second CTE to sort the transactions into high, medium and low frequency using CASE.
categorised_customers AS (
    SELECT
        CASE
            WHEN avg_tx_per_month >= 10 THEN 'High Frequency'
            WHEN avg_tx_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        avg_tx_per_month
    FROM transactions_per_customer
)
SELECT
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_tx_per_month), 1) AS avg_transactions_per_month
FROM categorised_customers
GROUP BY frequency_category

-- ORDER BY FIELD lets me order in the exact order I want instead of alphabetical.
ORDER BY FIELD(frequency_category, 'High Frequency', 'Medium Frequency', 'Low Frequency');
