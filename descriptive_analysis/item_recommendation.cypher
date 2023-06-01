MATCH (t:Travel)<-[:MAKES]-(u:User), 
      (r:Request)-[:CONTAIN]->(p:Product), 
      (iu:User)-[:INITIALIZE]->(r),
      (cu:User)-[:COLLECT]->(r)
WHERE iu.city = t.departureAirportFsCode AND 
      cu.city = t.arrivalAirportFsCode AND
      p.product_weight_g <= t.extraLuggage * 1000 AND 
      NOT (r)<-[:DELIVER]-() AND
      t.departureTime >= r.requestDate AND 
      t.departureTime <= r.dateToDeliver
WITH t, r, p
ORDER BY p.product_weight_g DESC
RETURN t, COLLECT(r)[0..5] AS top_requests