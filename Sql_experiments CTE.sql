SELECT mONth(purchASe_time)AS month, count(buyer_id) AS purchASes
FROM transactions
GROUP BY month;


WITH cte AS
(SELECT
month(purchASe_time) AS bulan,
year(purchASe_time),
count(store_id) AS transaksi,
store_id
FROM transactions
WHERE month(purchASe_time)= '10'
AND year(purchASe_time) = '2020'
GROUP BY store_id)

SELECT count(store_id) jumlah_toko
WHERE transaksi >= 5;

SELECT store_id, minute(min(timediff(refund_time,purchASe_time)))
FROM transactions
GROUP BY store_id
ORDER BY store_id;

WITH cte AS(SELECT store_id, purchASe_time,gross_transaction_value
row_number() OVER(PARTITION BY store_id ORDER BY purchASe_time) AS urutan
FROM transactions
ORDER BY store_id, purchASe_time)
SELECT store_id, gross_transaction_value
FROM cte
WHERE urutan='1';


WITH cte2 AS
(WITH cte AS
(SELECT trx.store_id, trx.purchASe_time, it.item_name
row_number() OVER(PARTITION BY trx.store_id ORDER BY trx.purchASe_time) AS urutan
FROM transactions AS trx
JOIN items AS its
ON trx.item_id=it.item_id
ORDER BY store_id, purchASe_time)

SELECT item_name, count(item_name) number_of_items
FROM cte
WHERE urutan = '1'
GROUP BY item_name)

SELECT item_name, max(number_of_items)
FROM cte2



