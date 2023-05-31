MATCH (t:Travel)<-[:MAKES]-(u:User), 
      (r:Request)-[:CONTAIN]->(p:Product), 
      (iu:User)-[:INITIALIZE]->(r)
WHERE u.city = t.departureAirportFsCode AND 
      p.product_weight_g <= t.extraLuggage * 1000 AND 
      NOT (r)<-[:DELIVER]-() AND
      t.departureTime >= r.requestDate AND 
      t.departureTime <= r.dateToDeliver
RETURN t, COLLECT(r) AS requests