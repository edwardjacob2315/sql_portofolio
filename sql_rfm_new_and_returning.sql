WITH base_query AS(
SELECT
    `source`.`rfm_class` AS `rfm_class`,
    `source`.`new_or_returning` AS `new_or_returning`,
    COUNT(*) AS `count`
FROM (
WITH CTE AS (
    SELECT user_id,
           gender,
           count(id) AS count_trx_id,
           sum(value) AS sum_value,
           avg(value) AS atv,
           new_or_returning,
           min(user_age) AS user_age,
           members_created
    FROM (
    SELECT trx.id,
           trx.value,
           trx.user_id,
           trx.created AS trx_created,
           members.created AS members_created,
           trx.user_age,
        CASE
            WHEN members.gender = 2 THEN 'Female'
            WHEN members.gender = 1 THEN 'Male'
            ELSE 'Unknown'
        END AS gender,
        CASE
            WHEN toTimeZone(members.created, 'Asia/Jakarta') BETWEEN toDate({{start_date}})

   AND dateAdd(toDate(toDate({{end_date}})), 1) THEN 'NEW'
            ELSE 'RETURNING'
        END AS new_or_returning
    FROM stamps_levis.transaction AS trx
    JOIN stamps_levis.membership AS members ON trx.user_id = members.user_id

WHERE trx.user_id IS NOT NULL AND toTimeZone(transaction.created, 'Asia/Jakarta') BETWEEN toDate({{start_date}})
                           AND dateAdd(toDate(toDate({{end_date}})), 1)
                           AND trx.status != 2
                           AND trx.merchant_id = 2
                           AND members.merchant_group_id = 2
    )

GROUP BY user_id, gender, new_or_returning, members_created
)


SELECT user_id,
       gender,
       user_age,
       count_trx_id,
       sum_value,
       atv,
       new_or_returning,
       members_created,
       CASE
           WHEN atv < '1000000' THEN 'LS'
           WHEN atv BETWEEN '1000000' AND '2000000' THEN 'MS'
           ELSE 'HS'
       END AS spending,
       CASE
           WHEN count_trx_id < '2' THEN 'LF'
           WHEN count_trx_id BETWEEN '2' AND '4' THEN 'MF'
           ELSE 'HF'
       END AS frequency,
       CONCAT(frequency,'', spending) AS rfm_class

FROM CTE
WHERE gender = 'Male'
ORDER BY count_trx_id desc) `source`
GROUP BY `source`.`rfm_class`, `source`.`new_or_returning`
ORDER BY `source`.`rfm_class` ASC
)
SELECT
    `rfm_class`,
    SUM(CASE WHEN `new_or_returning` = 'NEW' THEN `count` ELSE 0 END) AS `NEW`,
    SUM(CASE WHEN `new_or_returning` = 'RETURNING' THEN `count` ELSE 0 END) AS `RETURNING`
FROM base_query
GROUP BY `rfm_class`
ORDER BY
    CASE `rfm_class`
        WHEN 'HFHS' THEN 1
        WHEN 'HFMS' THEN 2
        WHEN 'HFLS' THEN 3
        WHEN 'MFHS' THEN 4
        WHEN 'MFMS' THEN 5
        WHEN 'MFLS' THEN 6
        WHEN 'LFHS' THEN 7
        WHEN 'LFMS' THEN 8
        WHEN 'LFLS' THEN 9
        ELSE 10
    END
;
