SELECT apartments.address, apartments.price_mln, round(apartments.price_mln * 1000 / apartments.area_m2)
FROM apartments ORDER BY price_mln;





SELECT DISTINCT * FROM apartments WHERE status = 'For sale' and address Like '%Ave%' ORDER BY district;





SELECT apartments.district, COUNT(*) as listing, count(price_mln) AS with_price, round(avg(price_mln)) as avg_price 
FROM apartments GROUP BY district HAVING count(*) >= 3;





SELECT district FROM apartments WHERE status = 'For sale';
INTERSECT
SELECT district FROM apartments WHERE status = 'Sold';





SELECT agents.full_name FROM agents WHERE agent_id IN (SELECT agent_id FROM apartments WHERE status = 'Sold' and price_mln > ( SELECT avg(price_mln) FROM apartments WHERE status = 'Sold'))