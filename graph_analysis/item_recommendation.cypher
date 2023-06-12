MATCH (t:Travel)<-[:MAKES]-(u:User), 
      (r:Request)-[:CONTAIN]->(p:Product), 
      (iu:User)-[INI:INITIALIZE]->(r),
      (cu:User)-[:COLLECT]->(r),
      (u)-[:DELIVER]->(hr:Request)-[:CONTAIN]->(hp:Product)
WHERE iu.city = t.departureAirportFsCode AND 
      cu.city = t.arrivalAirportFsCode AND
      p.product_weight_g <= t.extraLuggage * 1000 AND 
      NOT (r)<-[:DELIVER]-() AND
      t.departureTime >= INI.date AND 
      t.departureTime <= r.dateToDeliver
WITH t, r, p,
     COLLECT(hp.product_category_name_english) AS delivered_categories
WITH t, r, p, 
     SIZE(delivered_categories) AS total_delivered_categories, 
     SIZE([x IN delivered_categories WHERE x = p.product_category_name_english]) AS matching_categories
WITH t, r, 
     toFloat(matching_categories) / total_delivered_categories AS similarity
ORDER BY similarity DESC, p.product_weight_g DESC
RETURN t, COLLECT({request: r, similarity: similarity})[0..5] AS top_requests
