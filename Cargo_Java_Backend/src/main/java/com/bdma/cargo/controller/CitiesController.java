package com.bdma.cargo.controller;

import com.bdma.cargo.model.CityModel;
import org.apache.avro.reflect.ReflectData;
import org.apache.commons.net.ntp.TimeStamp;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.apache.parquet.avro.AvroParquetWriter;
import org.apache.parquet.hadoop.ParquetWriter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import static org.apache.parquet.hadoop.ParquetFileWriter.Mode.CREATE;

@RestController
@RequestMapping("/cities")
public class CitiesController {

    @Value("${output.directoryPath}")
    private String outputDirectoryPath;

    @Value("${output.filename.cities}")
    private String outputFilename;

    @Value("${output.extension}")
    private String outputExtension;

    @GetMapping("/gather")
    public ResponseEntity<Void> gatherCities() {
        getCities();
        return ResponseEntity.ok().build();
    }

    private void getCities() {
        String query = "[out:json];\n" +
                "area[\"ISO3166-1\"=\"ES\"]->.a;\n" +
                "(node[\"place\"=\"city\"](area.a);\n" +
                " way[\"place\"=\"city\"](area.a);\n" +
                " rel[\"place\"=\"city\"](area.a););\n" +
                "out;";

        HttpPost httpPost = new HttpPost("https://overpass-api.de/api/interpreter");
        httpPost.setEntity(new StringEntity(query, ContentType.APPLICATION_FORM_URLENCODED));
        long time = TimeStamp.getCurrentTime().getTime();
        Path dataFile = new Path(outputDirectoryPath + outputFilename + "-" + time + outputExtension);

        try (CloseableHttpClient httpClient = HttpClients.createDefault();
             CloseableHttpResponse response = httpClient.execute(httpPost)) {
            try (ParquetWriter<CityModel> writer = AvroParquetWriter.<CityModel>builder(dataFile)
                    .withSchema(ReflectData.AllowNull.get().getSchema(CityModel.class))
                    .withDataModel(ReflectData.get())
                    .withConf(new Configuration())
                    .withWriteMode(CREATE)
                    .build()) {
                HttpEntity entity = response.getEntity();
                if (entity != null) {
                    String result = EntityUtils.toString(entity);
                    JSONArray jsonArray = new JSONArray("[" + result + "]");
                    JSONObject jsonObject = jsonArray.getJSONObject(0);
                    JSONArray addressObject = jsonObject.getJSONArray("elements");
                    for (int i = 0; i < addressObject.length(); i++) {
                        JSONObject ss = addressObject.getJSONObject(i);
                        if (ss.has("lat") && ss.has("lon")) {
                            double latitude = ss.getDouble("lat");
                            double longitude = ss.getDouble("lon");
                            writer.write(
                                    new CityModel(Long.parseLong(ss.optString("id", "")), getCityName(latitude, longitude), "Spain", latitude, longitude)
                            );
                        }
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private String getCityName(double latitude, double longitude) {
        String url = String.format("https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=%f&lon=%f", latitude, longitude);
        try {
            URL obj = new URL(url);
            HttpURLConnection con = (HttpURLConnection) obj.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("User-Agent", "Mozilla/5.0");

            int responseCode = con.getResponseCode();
            if (responseCode == HttpURLConnection.HTTP_OK) {
                BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    response.append(inputLine);
                }
                in.close();
                return parseCityName(response.toString());
            } else {
                System.out.println("Error: HTTP status code " + responseCode);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String parseCityName(String jsonResponse) {
        JSONObject jsonObject = new JSONObject(jsonResponse);
        JSONObject addressObject = jsonObject.getJSONObject("address");
        return addressObject.getString("city");
    }

}
