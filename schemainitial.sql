DROP VIEW IF EXISTS useful_combinations_view;
DROP TABLE IF EXISTS fund,funddata, fundhistory, actions, subfund, fund;

CREATE TABLE fund (
  fund_id SERIAL PRIMARY KEY,
  fund_name TEXT NOT NULL,
  short_name TEXT NULL,
  regex_keyword TEXT NULL
);

CREATE TABLE subfund (
  subfund_id SERIAL PRIMARY KEY,
  fund_id INTEGER NOT NULL REFERENCES fund (fund_id),
  short_name TEXT NULL,
  subfund_type TEXT NULL,
  regex_keyword TEXT NULL,
  subfund_name TEXT NOT NULL
);

CREATE TABLE funddata (
  id SERIAL PRIMARY KEY,
  value NUMERIC NOT NULL,
  fund_id INTEGER NULL REFERENCES fund (fund_id),
  subfund_id INTEGER NULL REFERENCES subfund(subfund_id),
  attribute1 TEXT NOT NULL,
  attribute2 TEXT NULL,
  attribute3 TEXT NULL,
  attribute4 TEXT NULL,
  date TIMESTAMP NULL
);


CREATE TABLE actions (
  action_type TEXT PRIMARY KEY,
  description TEXT NOT NULL
);

CREATE TABLE fundhistory (
  origin_id INTEGER NOT NULL REFERENCES fund (fund_id),
  destination_id INTEGER NULL REFERENCES fund (fund_id),
  date TIMESTAMP NOT NULL,
  action_type TEXT NOT NULL REFERENCES actions (action_type),
  founded TIMESTAMP NULL,
  source TEXT NULL
  --PRIMARY KEY (origin_id, destination_id)
);


/*
CREATE TABLE subfundhistory (
  id SERIAL PRIMARY KEY,
  origin_id INTEGER NOT NULL REFERENCES subfund (subfund_id),
  destination_id INTEGER NOT NULL REFERENCES subfund (subfund_id),
  date TIMESTAMP NOT NULL,
  action_type TEXT NOT NULL REFERENCES actions (actiontype)
);
*/

----- VIEWIÐ
DROP VIEW IF EXISTS useful_combinations_view;
CREATE VIEW useful_combinations_view AS
SELECT
    f.fund_id AS fund_id,
    f.fund_name AS fund_name,
    sf.subfund_id AS subfund_id,
    sf.subfund_name AS subfund_name,
    sf.subfund_type AS subfund_type,
    fd.attribute1 AS attribute1,
    fd.attribute4 AS attribute4,
    fd.value AS value,
    to_char(fd.date, 'YYYY-MM-DD HH24:MI:SS') AS date,
CASE
    WHEN EXTRACT(year from fd.date) > 2015 and fd.attribute3 = 'Fjárfestingargjöld' THEN '(Samtals) Fjárfestingargjöld'
	else fd.attribute3
END AS attribute3,
CASE
	WHEN EXTRACT(year from fd.date) > 2015 and attribute2 = 'Hreinar Fjárfestingartekjur'  and attribute3 = 'Fjárfestingargjöld' 
		THEN 'Fjárfestingargjöld'
	WHEN EXTRACT(year from fd.date) > 2015 and attribute2 = 'Hreinar Fjárfestingartekjur' 
		THEN 'Fjárfestingartekjur'
else fd.attribute2
END AS attribute2
FROM
    funddata fd
JOIN
    fund f ON fd.fund_id = f.fund_id
JOIN
    subfund sf ON fd.subfund_id = sf.subfund_id
WHERE
    (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Iðgjöld' AND fd.attribute3 = '(Samtals) Iðgjöld')
    OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Lífeyrir' AND fd.attribute3 = '(Samtals) Lífeyrir')
    OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Hreinar Fjárfestingartekjur' AND fd.attribute3 = '(Samtals) Hreinar fjárfestingartekjur')
    OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Fjárfestingartekjur' AND fd.attribute3 = '(Samtals) Fjárfestingartekjur')
    OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Rekstrarkostnaður' AND fd.attribute3 = '(Samtals) Rekstrarkostnaður')
    OR (fd.attribute1 = 'Efnahagsreikningur' AND fd.attribute2 = '(Samtals) Hrein eign til greiðslu lífeyris')
    OR (fd.attribute1 = 'Efnahagsreikningur' AND fd.attribute2 = 'Eignir' AND fd.attribute3 = '(Samtals) Eignir samtals')
    OR (fd.attribute1 = 'Efnahagsreikningur' AND fd.attribute2 = 'Skuldir' AND fd.attribute3 = '(Samtals) Skuldir samtals')
	
	OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Fjárfestingargjöld' AND fd.attribute3 = '(Samtals) Fjárfestingargjöld')
	OR (fd.attribute1 = 'Rekstur' AND fd.attribute2 = 'Hreinar Fjárfestingartekjur' AND fd.attribute3 = 'Fjárfestingargjöld')
	
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Hrein raunávöxtun (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Ellilífeyrir (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Örorkulífeyrir (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Makalífeyrir (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Barnalífeyrir (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Annar lífeyrir (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Stöðugildi')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Lífeyrisbyrði')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Fjárfestingargjöld (bein og áætluð/reiknuð)' AND fd.attribute3 = 'Hlutfall fjárfestingargjalda alls af heildareignum (%)')
    OR (fd.attribute1 = 'Kennitölur' AND fd.attribute2 = 'Skrifstofu og stjórnunarkostnaður (alls) í % af meðalstöðu eigna')
    OR (fd.attribute1 = 'Lífeyrisþegar' AND fd.attribute2 ='Örorku')
    OR (fd.attribute1 = 'Framtíðariðgjöld')
    OR (fd.attribute1 = 'Ellilífeyrir á mán (þús. kr.)' AND fd.attribute2 ='Karlar')
    OR (fd.attribute1 = 'Samtals sjóðfélagar og lífeyrisþegar')
    OR (fd.attribute1 = 'Iðgjöld ársins (þús. kr.)' AND fd.attribute2 ='Karlar')
    OR (fd.attribute1 = 'Fjöldi ellilífeyrisþega' AND fd.attribute2 ='Konur')
    OR (fd.attribute1 = 'Óvirkir sjóðfélagar')
    OR (fd.attribute1 = 'Heildarstaða %' AND fd.attribute2 ='NaN')
    OR (fd.attribute1 = 'Lífeyrisþegar' AND fd.attribute2 ='Elli')
    OR (fd.attribute1 = 'Iðgjöld ársins (þús. kr.)' AND fd.attribute2 ='Konur')
    OR (fd.attribute1 = 'Áætlaðar launagr.' AND fd.attribute2 ='Konur')
    OR (fd.attribute1 = 'Eignir í tryggingafræðilegu mati')
    OR (fd.attribute1 = 'Heildarstaða samtals')
    OR (fd.attribute1 = 'Áætlað iðgjöld %')
    OR (fd.attribute1 = 'Framtíðarstaða %')
    OR (fd.attribute1 = 'Ellilífeyrir á mán (þús. kr.)' AND fd.attribute2 ='Konur')
    OR (fd.attribute1 = 'Fjöldi iðgjaldagreiðenda' AND fd.attribute2 ='Karlar')
    OR (fd.attribute1 = 'Heildarskuldbindingar' AND fd.attribute2 ='NaN')
    OR (fd.attribute1 = 'Virkir sjóðfélagar')
    OR (fd.attribute1 = 'Fjöldi iðgjaldagreiðenda' AND fd.attribute2 ='Konur')
    OR (fd.attribute1 = 'Heildareignir')
    OR (fd.attribute1 = 'Áfallnar skuldbindingar')
    OR (fd.attribute1 = 'Áfallin staða')
    OR (fd.attribute1 = 'Lífeyrisþegar' AND fd.attribute2 ='Barna')
    OR (fd.attribute1 = 'Lífeyrisþegar' AND fd.attribute2 ='Maka')
    OR (fd.attribute1 = 'Fjöldi ellilífeyrisþega' AND fd.attribute2 ='Karlar')
    OR (fd.attribute1 = 'Framtíðarskuldbinding')
    OR (fd.attribute1 = 'Áfallin staða %')
    OR (fd.attribute1 = 'Framtíðarstaða')
    OR (fd.attribute1 = 'Áætlaðar launagr.' AND fd.attribute2 ='Karlar')
    OR (fd.attribute1 = 'Samtals sjóðfélagar');




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