package com.bdma.cargo.controller;

import com.bdma.cargo.dao.RequestsDao;
import com.bdma.cargo.entity.Requests;
import com.bdma.cargo.model.AddressModel;
import com.bdma.cargo.model.RequestsModel;
import org.apache.avro.reflect.ReflectData;
import org.apache.commons.net.ntp.TimeStamp;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.parquet.avro.AvroParquetWriter;
import org.apache.parquet.hadoop.ParquetFileWriter;
import org.apache.parquet.hadoop.ParquetWriter;
import org.neo4j.driver.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.repository.query.Param;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping("/requests")
@Service
public class RequestsController {

    String[] ids = {"1", "4", "7", "10", "13"};
    Random random = new Random();

    @Autowired
    RequestsDao requestsDao;

    @Value("${output.directoryPath}")
    private String outputDirectoryPath;

    @Value("${output.filename.requests}")
    private String outputFilename;

    @Value("${output.extension}")
    private String outputExtension;

    private String[] offices = {"Barcelona", "Madrid", "Palma", "Malaga"};

    @PostMapping("/create")
    public ResponseEntity<Void> createRequest(@RequestBody RequestsModel creationRequest) {
        String collId = creationRequest.getCollectionAddress().getId();
        new AddressModel(collId, "Spain", offices[Integer.parseInt(collId)], "12435", "testST.", "11", "33", "testPR.");
        String pickUpId = creationRequest.getPickUpAddress().getId();
        new AddressModel(pickUpId, "Spain", offices[Integer.parseInt(pickUpId)], "12435", "testST.", "11", "33", "testPR.");
        if (creationRequest.getTravellerId() == null)
            creationRequest.setId(UUID.randomUUID().toString());
        long time = TimeStamp.getCurrentTime().getTime();
        Path dataFile = new Path(outputDirectoryPath + outputFilename + "-" + time + outputExtension);
        try (ParquetWriter<RequestsModel> writer = AvroParquetWriter.<RequestsModel>builder(dataFile)
                .withSchema(ReflectData.AllowNull.get().getSchema(RequestsModel.class))
                .withDataModel(ReflectData.get())
                .withWriteMode(ParquetFileWriter.Mode.CREATE)
                .withConf(new Configuration())
                .build()) {
            writer.write(creationRequest);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/by/id")
    public ResponseEntity<List<RequestsModel>> getRequestsById(@Param("initUserId") String initUserId) {
        List<RequestsModel> requestsModelList = new ArrayList<>();
        for (Requests request : requestsDao.getAllByInitializationUserIdAndTravellerIdIsNull(Long.valueOf(initUserId)))
            requestsModelList.add(requestsToRequestsModel(request));
        return ResponseEntity.ok(requestsModelList);
    }

    @GetMapping("/not/selected")
    public ResponseEntity<List<RequestsModel>> getNotSelectedRequests() {
        List<RequestsModel> requestsModelList = new ArrayList<>();
        for (Requests request : requestsDao.getAllByTravellerIdIsNull())
            requestsModelList.add(requestsToRequestsModel(request));
        return ResponseEntity.ok(requestsModelList);
    }

    @GetMapping("/recommended")
    public ResponseEntity<List<RequestsModel>> getRecommendedRequests() {
        List<RequestsModel> requestsModelList = new ArrayList<>();
        Driver driver = GraphDatabase.driver("bolt://localhost:7687", AuthTokens.basic("neo4j", "password"));
        Session session = driver.session();
        String cypherQuery = "MATCH (t:Travel)<-[:MAKES]-(u:User), \n" +
                "      (r:Request)-[:CONTAIN]->(p:Product), \n" +
                "      (iu:User)-[:INITIALIZE]->(r),\n" +
                "      (cu:User)-[:COLLECT]->(r),\n" +
                "      (u)-[:DELIVER]->(hr:Request)-[:CONTAIN]->(hp:Product)\n" +
                "WHERE iu.city = t.departureAirportFsCode AND \n" +
                "      cu.city = t.arrivalAirportFsCode AND\n" +
                "      p.product_weight_g <= t.extraLuggage * 1000 AND \n" +
                "      // NOT (r)<-[:DELIVER]-() AND\n" +
                "      t.departureTime >= r.requestDate AND \n" +
                "      t.departureTime <= r.dateToDeliver \n" +
                "WITH t, r, p, u,\n" +
                "     COLLECT(hp.product_category_name_english) AS delivered_categories \n" +
                "WITH t, r, p, \n" +
                "     SIZE(delivered_categories) AS total_delivered_categories, \n" +
                "     SIZE([x IN delivered_categories WHERE x = p.product_category_name_english]) AS matching_categories \n" +
                "WITH t, r, \n" +
                "     toFloat(matching_categories) / total_delivered_categories AS similarity \n" +
                "ORDER BY similarity DESC, p.product_weight_g DESC \n" +
                "RETURN t, COLLECT({request: r, similarity: similarity})[0..5] AS top_requests";
        try (Transaction tx = session.beginTransaction()) {
            Result result = tx.run(cypherQuery);
            while (result.hasNext()) {
                Record record = result.next();
                int requestId = record.get("top_requests").get(0).get("request").get("requestid").asInt();
                int initializationUserId = record.get("top_requests").get(0).get("request").get("initializationUserId").asInt();
                int collectionUserId = record.get("top_requests").get(0).get("request").get("collectionUserId").asInt();
                String productId = record.get("top_requests").get(0).get("request").get("productId").asString();
                String dateToDeliver = record.get("top_requests").get(0).get("request").get("dateToDeliver").toString();
                requestsModelList.add(new RequestsModel(String.valueOf(requestId), String.valueOf(initializationUserId),
                        String.valueOf(collectionUserId), null, productId,
                        "0", dateToDeliver, getAddress2(1), getAddress2(2), BigDecimal.TEN));

            }
        }
        session.close();
        driver.close();
        return ResponseEntity.ok(requestsModelList);
    }

    private RequestsModel requestsToRequestsModel(Requests request) {
        return new RequestsModel(request.getRequestId().toString(),
                request.getInitializationUserId().toString(),
                request.getCollectionUserId().toString(),
                null,
                request.getProductId(),
                "0",
        request.getDateToDeliver(),
        getAddress2(1),
                getAddress2(2),
                BigDecimal.valueOf(request.getDeliveryFee() != null ? request.getDeliveryFee() : 0.0));
    }

    private AddressModel getAddress2(int id) {
        return new AddressModel(String.valueOf(id), "Spain", offices[id], "12435", "testST.", "11", "33", "testPR.");
    }

    @GetMapping
    public ResponseEntity<List<RequestsModel>> getRequests() {
        List<RequestsModel> requestsList = new ArrayList<>();
        for (int i = 0 ; i < 5 ; i++)
            requestsList.add(buildRandomRequests(i));
        return ResponseEntity.ok(requestsList);
    }

    RequestsModel buildRandomRequests(int i){
        RequestsModel requestsModel = new RequestsModel();
        requestsModel.setId(UUID.randomUUID().toString());
        requestsModel.setInitializationUserId(ids[random.nextInt(5)]);
        requestsModel.setCollectionUserId(ids[random.nextInt(5)] + 1);
        requestsModel.setTravellerId(ids[random.nextInt(5)] + 2);
        requestsModel.setProductId("888777");
        requestsModel.setWeight("1");
        requestsModel.setDeliveryFees(BigDecimal.TEN);
        requestsModel.setDateToDeliver("25-07-2023");
        requestsModel.setCollectionAddress(getAddress());
        requestsModel.setPickUpAddress(getAddress());
        return requestsModel;
    }

    AddressModel getAddress() {
        return new AddressModel(ids[random.nextInt(5)], "Spain", "BCN", "12333" , "", "", "", "");
    }
}
