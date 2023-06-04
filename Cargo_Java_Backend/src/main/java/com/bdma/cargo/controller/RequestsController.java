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
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.repository.query.Param;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.math.BigInteger;
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
    public ResponseEntity<List<RequestsModel>> getRequestsById(@Param("id") Long initUserId) {
        List<RequestsModel> requestsModelList = new ArrayList<>();
        for (Requests request : requestsDao.getAllByInitializationuserid(initUserId))
            requestsModelList.add(requestsToRequestsModel(request));
        return ResponseEntity.ok(requestsModelList);
    }

    private RequestsModel requestsToRequestsModel(Requests request) {
        return new RequestsModel(request.getId().toString(),
                request.getInitializationuserid().toString(),
                request.getCollectionuserid().toString(),
                request.getTravellerid().toString(),
                request.getProductid(),
        BigInteger.ZERO,
        request.getDatetodeliver(),
        getAddress(request.getPickupaddress()),
                getAddress(request.getCollectionaddress()),
        request.getDescription().toString(),
        new BigInteger(String.valueOf(request.getDeliveryfee())));
    }

    private AddressModel getAddress(Long id) {
        return new AddressModel(String.valueOf(id), "Spain", offices[Math.toIntExact(id)], "12435", "testST.", "11", "33", "testPR.");
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
        requestsModel.setWeight(BigInteger.ONE);
        requestsModel.setDeliveryFees(BigInteger.TEN);
        requestsModel.setDateToDeliver("25-07-2023");
        requestsModel.setCollectionAddress(getAddress());
        requestsModel.setPickUpAddress(getAddress());
        requestsModel.setDescription("test request num " + i);
        return requestsModel;
    }

    AddressModel getAddress() {
        return new AddressModel(ids[random.nextInt(5)], "Spain", "BCN", "12333" , "", "", "", "");
    }
}
