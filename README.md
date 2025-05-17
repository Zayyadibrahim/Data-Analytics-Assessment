# DataAnalytics-Assessment

## Question 1.  High value customers with multiple products

I was asked to identify customers who have at least one savings plan and at least one investment plan. The result should include the customer's ID, full name, the number of each plan type, and their total deposit amount. Sorted by total deposits in descending order.

Step below:
1. To make the query cleaner, I used aliases for the tables: users_customuser as users, plans_plan as plan, and savings_savingsaccount as save.

2. I joined users with plan on the owner_id, and plan with save on plan_id. Then I concatenated the first and last name into a single column 'name'.

3. I filtered out only the deposit records where confirmed_amount was greater than 0, as this indicates actual inflow activity.

4. To calculate, I used COUNT(DISTINCT CASE WHEN) to separately count savings plans (is_regular_savings = 1) and investment plans (is_a_fund = 1) per user. Then I summed up the confirmed_amount from the savings table, converting it from kobo to naira by dividing by 100 (only because kobo was longer and I needed 2 less figures), and rounding to the nearest whole number.

5. I grouped the data by customer and used a HAVING clause to ensure only customers with at least one of each plan type were included. Finally, I sorted the results by total_deposits_naira in descending order to prioritise high value customers.

Some of the challenges I faced was how to make it less tedious and long. I started by using multiple CTEs, but it felt inefficient and ran slower on MySQL workbench at around 1.0s compared to the final query that ran at half the time (0.6s).



## Question 2. Transaction frequency analysis.

I was asked to analyse how often customers perform transactions. Based on their average monthly transaction rate, I needed to categorise them into:
High Frequency: >= 10 transactions/month
Medium Frequency: 3–9 transactions/month
Low Frequency: <= 2 transactions/month

Steps below:
1. I started by creating a CTE named transactions_per_customer. This CTE calculates:
   * The total number of transactions for each customer
   * The number of active months between their first and last transaction using TIMESTAMPDIFF
   * The average number of transactions per month, using a NULLIF to avoid division by zero in cases where all transactions happened within a single month.

2. I created a second CTE called categorised_customers, where I used a CASE statement to group each customer into one of the frequency categories above based on their monthly average.

3. In the final query, I grouped by these frequency categories and:
    * Counted the number of customers in each group (COUNT(*))
    * Calculated the average monthly transaction rate within each group (AVG(avg_tx_per_month))

4. I used ORDER BY FIELD to ensure the frequency categories appear in logical order: High, Medium, then Low. Rather than alphabetically.

The only challenge here was having to figure out what function to use to count the number of months as I tried counting the number of days and dividing by 30. I eventually found TIMESTAMPDIFF online.
