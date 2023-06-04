package com.bdma.cargo.controller;

import com.bdma.cargo.model.GasModel;
import org.apache.avro.reflect.ReflectData;
import org.apache.commons.net.ntp.TimeStamp;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.parquet.avro.AvroParquetWriter;
import org.apache.parquet.hadoop.ParquetFileWriter;
import org.apache.parquet.hadoop.ParquetWriter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

@RestController
@RequestMapping("/gas")
public class GasController {

    @Value("${output.directoryPath}")
    private String outputDirectoryPath;

    @Value("${output.filename.gas}")
    private String outputFilename;

    @Value("${output.extension}")
    private String outputExtension;

    @GetMapping()
    public ResponseEntity<Void> getGasPrice() {
        long time = TimeStamp.getCurrentTime().getTime();
        Path dataFile = new Path(outputDirectoryPath + outputFilename + "-" + time + outputExtension);
        try (ParquetWriter<GasModel> writer = AvroParquetWriter.<GasModel>builder(dataFile)
                .withSchema(ReflectData.AllowNull.get().getSchema(GasModel.class))
                .withDataModel(ReflectData.get())
                .withWriteMode(ParquetFileWriter.Mode.CREATE)
                .withConf(new Configuration())
                .build()) {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create("https://gas-price.p.rapidapi.com/europeanCountries"))
                    .header("X-RapidAPI-Key", "38bfcd91bdmsh5b9084a6d3f689dp1eeeeajsn4ee48dc54b02")
                    .header("X-RapidAPI-Host", "gas-price.p.rapidapi.com")
                    .method("GET", HttpRequest.BodyPublishers.noBody())
                    .build();
            HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());
            JSONObject jsonObject = new JSONObject(response.body());
            JSONArray gasObject = jsonObject.getJSONArray("results");
            for (int i = 0; i < gasObject.length(); i++) {
                JSONObject ss = gasObject.getJSONObject(i);
                writer.write(
                        new GasModel(ss.getString("currency"),
                                getPrice(ss, "lpg"),
                                getPrice(ss, "diesel"),
                                getPrice(ss, "gasoline"),
                                ss.getString("country"))
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok().build();
    }

    @GetMapping("/simulator")
    public ResponseEntity<Void> getSimulatedResponse() {
        long time = TimeStamp.getCurrentTime().getTime();
        Path dataFile = new Path(outputDirectoryPath + outputFilename + "-" + time + outputExtension);
        try (ParquetWriter<GasModel> writer = AvroParquetWriter.<GasModel>builder(dataFile)
                .withSchema(ReflectData.AllowNull.get().getSchema(GasModel.class))
                .withDataModel(ReflectData.get())
                .withWriteMode(ParquetFileWriter.Mode.CREATE)
                .withConf(new Configuration())
                .build()) {
            JSONObject jsonObject = new JSONObject("{\"results\":" +
                    "[{\"currency\":\"euro\",\"lpg\":\"0,662\",\"diesel\":\"1,651\",\"gasoline\":\"1,641\",\"country\":\"Albania\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"1,422\",\"gasoline\":\"1,492\",\"country\":\"Andorra\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,496\",\"diesel\":\"0,898\",\"gasoline\":\"0,968\",\"country\":\"Armenia\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"1,380\",\"diesel\":\"1,597\",\"gasoline\":\"1,615\",\"country\":\"Austria\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,421\",\"diesel\":\"0,804\",\"gasoline\":\"0,804\",\"country\":\"Belarus\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,711\",\"diesel\":\"1,767\",\"gasoline\":\"1,791\",\"country\":\"Belgium\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,730\",\"diesel\":\"1,352\",\"gasoline\":\"1,354\",\"country\":\"Bosnia and Herzegovina\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,583\",\"diesel\":\"1,380\",\"gasoline\":\"1,314\",\"country\":\"Bulgaria\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"0,948\",\"diesel\":\"1,432\",\"gasoline\":\"1,437\",\"country\":\"Croatia\"}" +
                    ",{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"1,513\",\"gasoline\":\"1,396\",\"country\":\"Cyprus\"}," +
                    "{\"currency\":\"euro\",\"lpg\":\"0,696\",\"diesel\":\"1,497\",\"gasoline\":\"1,568\",\"country\":\"Czech Republic\"}," +
                    "{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"1,714\",\"gasoline\":\"1,940\",\"country\":\"Denmark\"},{\"currency\":\"euro\",\"lpg\":\"0,715\",\"diesel\":\"1,626\",\"gasoline\":\"1,701\",\"country\":\"Estonia\"},{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"1,951\",\"gasoline\":\"1,942\",\"country\":\"Finland\"},{\"currency\":\"euro\",\"lpg\":\"0,999\",\"diesel\":\"1,802\",\"gasoline\":\"1,904\",\"country\":\"France\"},{\"currency\":\"euro\",\"lpg\":\"0,647\",\"diesel\":\"1,330\",\"gasoline\":\"1,024\",\"country\":\"Georgia\"},{\"currency\":\"euro\",\"lpg\":\"1,082\",\"diesel\":\"1,757\",\"gasoline\":\"1,844\",\"country\":\"Germany\"},{\"currency\":\"euro\",\"lpg\":\"0,997\",\"diesel\":\"1,674\",\"gasoline\":\"1,910\",\"country\":\"Greece\"},{\"currency\":\"euro\",\"lpg\":\"0,955\",\"diesel\":\"1,586\",\"gasoline\":\"1,607\",\"country\":\"Hungary\"},{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"2,108\",\"gasoline\":\"2,069\",\"country\":\"Iceland\"},{\"currency\":\"euro\",\"lpg\":\"0,890\",\"diesel\":\"1,626\",\"gasoline\":\"1,596\",\"country\":\"Ireland\"},{\"currency\":\"euro\",\"lpg\":\"0,808\",\"diesel\":\"1,802\",\"gasoline\":\"1,866\",\"country\":\"Italy\"},{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"0,000\",\"gasoline\":\"0,000\",\"country\":\"Kosovo\"},{\"currency\":\"euro\",\"lpg\":\"0,790\",\"diesel\":\"1,579\",\"gasoline\":\"1,637\",\"country\":\"Latvia\"},{\"currency\":\"euro\",\"lpg\":\"0,568\",\"diesel\":\"1,540\",\"gasoline\":\"1,530\",\"country\":\"Lithuania\"},{\"currency\":\"euro\",\"lpg\":\"0,766\",\"diesel\":\"1,519\",\"gasoline\":\"1,587\",\"country\":\"Luxembourg\"},{\"currency\":\"euro\",\"lpg\":\"0,818\",\"diesel\":\"1,289\",\"gasoline\":\"1,313\",\"country\":\"North Macedonia\"},{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"1,204\",\"gasoline\":\"1,333\",\"country\":\"Malta\"},{\"currency\":\"euro\",\"lpg\":\"0,811\",\"diesel\":\"1,080\",\"gasoline\":\"1,236\",\"country\":\"Moldova\"},{\"currency\":\"euro\",\"lpg\":\"0,850\",\"diesel\":\"1,480\",\"gasoline\":\"1,550\",\"country\":\"Montenegro\"},{\"currency\":\"euro\",\"lpg\":\"0,974\",\"diesel\":\"1,691\",\"gasoline\":\"1,878\",\"country\":\"Netherlands\"},{\"currency\":\"euro\",\"lpg\":\"1,260\",\"diesel\":\"1,817\",\"gasoline\":\"2,039\",\"country\":\"Norway\"},{\"currency\":\"euro\",\"lpg\":\"0,662\",\"diesel\":\"1,470\",\"gasoline\":\"1,424\",\"country\":\"Poland\"},{\"currency\":\"euro\",\"lpg\":\"0,888\",\"diesel\":\"1,537\",\"gasoline\":\"1,703\",\"country\":\"Portugal\"},{\"currency\":\"euro\",\"lpg\":\"0,738\",\"diesel\":\"1,445\",\"gasoline\":\"1,347\",\"country\":\"Romania\"},{\"currency\":\"euro\",\"lpg\":\"0,237\",\"diesel\":\"0,695\",\"gasoline\":\"0,609\",\"country\":\"Russia\"},{\"currency\":\"euro\",\"lpg\":\"0,870\",\"diesel\":\"1,633\",\"gasoline\":\"1,476\",\"country\":\"Serbia\"},{\"currency\":\"euro\",\"lpg\":\"0,758\",\"diesel\":\"1,514\",\"gasoline\":\"1,575\",\"country\":\"Slovakia\"},{\"currency\":\"euro\",\"lpg\":\"0,906\",\"diesel\":\"1,457\",\"gasoline\":\"1,358\",\"country\":\"Slovenia\"},{\"currency\":\"euro\",\"lpg\":\"0,973\",\"diesel\":\"1,540\",\"gasoline\":\"1,623\",\"country\":\"Spain\"},{\"currency\":\"euro\",\"lpg\":\"1,188\",\"diesel\":\"2,022\",\"gasoline\":\"1,794\",\"country\":\"Sweden\"},{\"currency\":\"euro\",\"lpg\":\"1,294\",\"diesel\":\"2,013\",\"gasoline\":\"1,835\",\"country\":\"Switzerland\"},{\"currency\":\"euro\",\"lpg\":\"0,539\",\"diesel\":\"1,014\",\"gasoline\":\"1,040\",\"country\":\"Turkey\"},{\"currency\":\"euro\",\"lpg\":\"-\",\"diesel\":\"0,000\",\"gasoline\":\"0,000\",\"country\":\"U.S.A\"},{\"currency\":\"euro\",\"lpg\":\"0,573\",\"diesel\":\"1,212\",\"gasoline\":\"1,180\",\"country\":\"Ukraine\"},{\"currency\":\"euro\",\"lpg\":\"0,871\",\"diesel\":\"2,003\",\"gasoline\":\"1,670\",\"country\":\"United Kingdom\"}],\"success\":true}");
            JSONArray gasObject = jsonObject.getJSONArray("results");
            for (int i = 0; i < gasObject.length(); i++) {
                JSONObject ss = gasObject.getJSONObject(i);
                writer.write(
                        new GasModel(ss.getString("currency"),
                                getPrice(ss, "lpg"),
                                getPrice(ss, "diesel"),
                                getPrice(ss, "gasoline"),
                                ss.getString("country"))
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok().build();

    }

    private BigDecimal getPrice(JSONObject ss, String gasolineName) {
        BigDecimal gasolineType = BigDecimal.ZERO;
        if (!ss.getString(gasolineName).equals("") && !ss.getString(gasolineName).equals("-") && ss.getString(gasolineName) != null)
            gasolineType = new BigDecimal(ss.getString(gasolineName).replace(',','.'));
        return gasolineType;
    }

}
