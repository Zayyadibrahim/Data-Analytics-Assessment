# DataAnalytics-Assessment

This assessment was done using MySQLWorkbench on my computer. I selected the adashi_staging schema, containing all the tables to be used for this exercise, as the default schema, so I can just include the table names without the schema name into my queries.


## Question 1.  High value customers with multiple products

I was asked to identify customers who have at least one savings plan and at least one investment plan. The result should include the customer's ID, full name, the number of each plan type, and their total deposit amount. Sorted by total deposits in descending order.

Step below:
1. To make the query cleaner, I used aliases for the tables: users_customuser as users, plans_plan as plan, and savings_savingsaccount as save.

2. I joined users with plan on the owner_id, and plan with save on plan_id. Then I concatenated the first and last name into a single column 'name'.

3. I filtered out only the deposit records where confirmed_amount was greater than 0, as this indicates actual inflow activity.

4. To calculate, I used COUNT(DISTINCT CASE WHEN) to separately count savings plans (is_regular_savings = 1) and investment plans (is_a_fund = 1) per user. Then I summed up the confirmed_amount from the savings table, converting it from kobo to naira by dividing by 100 (only because kobo was longer and I needed 2 less figures), and rounding to the nearest whole number.

5. I grouped the data by customer and used a HAVING clause to ensure only customers with at least one of each plan type were included. Finally, I sorted the results by total_deposits_naira in descending order to prioritise high value customers.

6. The queried table included 179 rows of data. 

Some of the challenges I faced was how to make it less tedious and long. I started by using multiple CTEs, but it felt inefficient and ran slower on MySQL workbench at around 1.0s compared to the final query that ran at half the time (0.6s).



## Question 2. Transaction frequency analysis.

I was asked to analyse how often customers perform transactions. Based on their average monthly transaction rate, I needed to categorise them into:
* High Frequency: >= 10 transactions/month
* Medium Frequency: 3–9 transactions/month
* Low Frequency: <= 2 transactions/month

Steps below:
1. I started by creating a CTE named transactions_per_customer. This CTE calculates:
   * The total number of transactions for each customer
   * The number of active months between their first and last transaction using TIMESTAMPDIFF
   * The average number of transactions per month, using a NULLIF to avoid division by zero in cases where all transactions happened within a single month.

2. I created a second CTE called categorised_customers, where I used a CASE statement to group each customer into one of the frequency categories above based on their monthly average.

3. In the final query, I grouped these frequency categories and:
    * Counted the number of customers in each group
    * Calculated the average monthly transaction rate within each group.

4. I used ORDER BY FIELD to ensure the frequency categories appear in logical order: High, Medium, then Low. Rather than alphabetically.

5. 3 rows of data.

The only challenge here was having to figure out what function to use to count the number of months as I tried counting the number of days and dividing by 30. I eventually used TIMESTAMPDIFF.



## Question 3. Account inactivity alert.

The task here was to identify all active accounts (either savings or investment) that have not received any deposits (inflow) in at least the last 365 days. This helps the operations team to flag dormant accounts.

Steps below:
1. I created a CTE called latest_tx, which fetches:
    * The most recent transaction date per plan. The transaction_date column is in a datetime format, so I converted to just date.
    * I filtered the transactions to include only actual inflows by checking that confirmed_amount > 0.

2. In the main query:
    * I joined the CTE with the plans_plan table to link each transaction to its respective plan and owner.
    * I used a CASE statement to assign a readable plan type (Savings, Investment, or Others for the unspecified ones).

3. I then calculated the number of days since the last transaction using DATEDIFF.

4. To meet the requirement, I applied a filter for plans with inactivity over 365 days and ordered the output by inactivity_days in descending order for easy review of the most dormant accounts.

5. 2664 rows of data was returned.

The challenge faced was me trying to optimise just like the first question. I used subqueries instead of CTEs to try to make the queries shorter but they were not easily readable.



## Question 4. CLV estimation.

Here, I was asked to estimate each customer’s Customer Lifetime Value (CLV) using a model that considers transaction volume, account tenure, and average profit per transaction. The formula given was:

CLV = (total_transactions / tenure_months) * 12 * avg_profit_per_transaction. Where avg_profit_per_transaction = 0.1% of transaction value.

Steps below:
1. I joined the users_customuser table with savings_savingsaccount to access both the customers' signup date and their transaction records.

2. In the query, I calculated tenure_months using TIMESTAMPDIFF to find the number of months between signup date and the current date.

3. I concatenated the first and last names. 

4. For total_transactions, I used COUNT(save.id) after checking that the id column has more distinct values than savings_id.

5. The average profit per transaction was computed as:
0.001 * (SUM(confirmed_amount) / total_transactions). I left the values in kobo here unlike in question 1 because the numbers are not as lengthy.
     * The estimated_clv formula follows the above logic, and I rounded up to the nearest whole number.
     * I used NULLIF() to prevent division by zero when tenure is zero.

6. Finally, I ordered the results by estimated_clv in descending order to show the most valuable customers.

7. The final table included 872 rows of data.

The first challenge was in figuring out which id to use in the savings_savingsaccount table. Knowing that a primary key has to have every value being unique, I figured the id with the most distinct values was the primary id.
The second challenge was in the formula of CLV given. I had to figure that since it was the profit per transaction that was given as 0.1% of the transaction value, the average profit per transaction had to be the the total confirmed amount divided by the number of transactions, then multiplied by 0.1% (0.001) per customer.
