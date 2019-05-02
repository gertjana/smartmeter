#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "secrets.h"

ESP8266WebServer server(80);

const long interval = 10000;  
unsigned long previousMillis = 0; 
bool hammerTime = false;

char* message[]={"/XMX5LGBBFG10",
  " ",
  "1-3:0.2.8(42)",
  "0-0:1.0.0(170108161107W)",
  "0-0:96.1.1(4530303331303033303031363939353135)",
  "1-0:1.8.1(002074.842*kWh)",
  "1-0:1.8.2(000881.383*kWh)",
  "1-0:2.8.1(000010.981*kWh)",
  "1-0:2.8.2(000028.031*kWh)",
  "0-0:96.14.0(0001)",
  "1-0:1.7.0(00.###*kW)",
  "1-0:2.7.0(00.###*kW)",
  "0-0:96.7.21(00004)",
  "0-0:96.7.9(00003)",
  "1-0:99.97.0(3)(0-0:96.7.19)(160315184219W)(0000000310*s)(160207164837W)(0000000981*s)(151118085623W)(0000502496*s)",
  "1-0:32.32.0(00000)",
  "1-0:32.36.0(00000)",
  "0-0:96.13.1(3031203631203831)",
  "0-0:96.13.0(303132333435363738393A3B3C3D3E3F303132333435363738393A3B3C3D3E3F303132333435363738393A3B)",
  "1-0:32.7.0(220.1*V)",
  "1-0:52.7.0(220.2*V)",
  "1-0:72.7.0(220.3*V)",  
  "1-0:31.7.0(005*A)",
  "1-0:51.7.0(004*A)",
  "1-0:71.7.0(016*A)",
  "1-0:21.7.0(01.111*kW)",
  "1-0:41.7.0(02.222*kW)",
  "1-0:61.7.0(03.333*kW)",
  "1-0:22.7.0(04.444*kW)",
  "1-0:42.7.0(05.555*kW)",
  "1-0:62.7.0(06.666*kW)",
  "0-1:24.1.0(003)",
  "0-1:96.1.0(4730303139333430323231313938343135)",
  "0-1:24.2.1(170108160000W)(01234.000*m3)",
  "0-2:24.1.0(007)",
  "0-2:96.1.0(4730303139333430323231313938343135)",
  "0-2:24.2.1(170108160000W)(00345.000*m3)",
  "!D3B0",
  "EOF"
};

String getPage(String text) {
  String btn = (hammerTime) ? "btn-success" : "btn-warning";
  String page = "<html>";
  page += "  <head>";
  page += "    <link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css'>";
  page += "    <script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js'></script>";
  page += "  </head>";
  page += "  <body>";
  page += "    <div class='container-fluid'>";
  page += "      <div class='row'>";
  page += "        <div class='col-md-12'>";
  page += "          <h3>ESP8266 based Smartmeter test device</h3>";
  page += "        </div>";
  page += "      </div>";
  page += "      <div class='row'>";
  page += "        <div class='col-md-6'>";
  page += "            <label for='hammer_time'>Toggle sending a telegram every 10 seconds</label>";
  page += "        </div>";
  page += "        <div class='col-md-12'>";
  page += "          <form method='POST'>";
  page += "            <button type='buttonsubmit' name='hammer_time' class='btn "+btn+"'>HammerTime</button>";

  page += "          </form>";
  page += "        </div>";
  page += "      </div>";
  page += "      <div class='row'>";
  page += "        <div class='col-md-6'>";
  page += "          <label for='text'>Send some text to the serial port</label>";
  page += "        </div>";
  page += "        <div class='col-md-12'>";
  page += "          <form method='POST'>";
  page += "            <textarea style='width:50%;height:100px;' id='text' name='text'>"+text+"</textarea>";
  page += "            <br/><button type='buttonsubmit' name='send' class='btn btn-success'>Send</button>";
  page += "          </form>";
  page += "        </div>";
  page += "      </div>";
  page += "    </div>";
  page += "  </body>";
  page += "</html>";
  return page;
}  

void handleRoot() {
  String text = "";
  if (server.hasArg("text")) {
    text = server.arg("text");
    Serial.println(text);
  }
  if (server.hasArg("hammer_time")) {
    hammerTime = !hammerTime;
  }
  server.send(200, "text/html", getPage(text));
}


void handleNotFound(){
  String message = "File Not Found\n\n";
  message += "URI: ";
  message += server.uri();
  message += "\nMethod: ";
  message += (server.method() == HTTP_GET)?"GET":"POST";
  message += "\nArguments: ";
  message += server.args();
  message += "\n";
  for (uint8_t i=0; i<server.args(); i++){
    message += " " + server.argName(i) + ": " + server.arg(i) + "\n";
  }
  server.send(404, "text/plain", message);
}

void setup(void){
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  randomSeed(analogRead(0));
  Serial.println("");
  Serial.print("# ");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("# Connected to ");
  Serial.println(ssid);
  Serial.print("# IP address: ");
  Serial.println(WiFi.localIP());


  server.on("/", handleRoot);

  server.onNotFound(handleNotFound);

  server.begin();
}

void loop(void){
  server.handleClient();
  unsigned long currentMillis = millis();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    if (hammerTime) {
      for (int i = 0; message[i] != "EOF"; i++) {
        String l = String(message[i]);
        String nrs = String(random(0,999), DEC);
        l.replace("###", nrs);
        Serial.println(l);
//        delay(100);
      }
    }
  }
}
