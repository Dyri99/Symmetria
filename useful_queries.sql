-- ná öllum distinct attributeum í viewinu, ætti að vera 50
SELECT DISTINCT
  attribute1,
  attribute2,
  attribute3,
  attribute4
FROM
  useful_combinations_view;

---- Ná öllum distinct attributeum, og finna hvaða ár það er í

WITH attribute_combinations AS (
    SELECT DISTINCT
        attribute1,
        attribute2,
        attribute3,
        attribute4
    FROM
        funddata
    ORDER BY
        attribute1,
        attribute2,
        attribute3,
        attribute4
),

years_combinations AS (
    SELECT
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        ARRAY_AGG(DISTINCT EXTRACT(YEAR FROM date)::integer) AS years
    FROM
        funddata
    GROUP BY
        attribute1,
        attribute2,
        attribute3,
        attribute4
)

SELECT
    ac.attribute1,
    ac.attribute2,
    ac.attribute3,
    ac.attribute4,
    yc.years AS "occurs in"
FROM
    attribute_combinations ac
JOIN
    years_combinations yc ON ac.attribute1 = yc.attribute1
                            AND ac.attribute2 = yc.attribute2
                            AND ac.attribute3 = yc.attribute3
                            AND ac.attribute4 = yc.attribute4
ORDER BY
    ac.attribute1,
    ac.attribute2,
    ac.attribute3,
    ac.attribute4;


---