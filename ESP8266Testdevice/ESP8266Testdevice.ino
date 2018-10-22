#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "secrets.h"

ESP8266WebServer server(80);

const long interval = 10000;  
unsigned long previousMillis = 0; 
bool hammerTime = true;

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
  "1-0:1.7.0(00.494*kW)",
  "1-0:2.7.0(00.000*kW)",
  "0-0:96.7.21(00004)",
  "0-0:96.7.9(00003)",
  "1-0:99.97.0(3)(0-0:96.7.19)(160315184219W)(0000000310*s)(160207164837W)(0000000981*s)(151118085623W)(0000502496*s)",
  "1-0:32.32.0(00000)",
  "1-0:32.36.0(00000)",
  "0-0:96.13.1()",
  "0-0:96.13.0()",
  "1-0:31.7.0(003*A)",
  "1-0:21.7.0(00.494*kW)",
  "1-0:22.7.0(00.000*kW)",
  "0-1:24.1.0(003)",
  "0-1:96.1.0(4730303139333430323231313938343135)",
  "0-1:24.2.1(170108160000W)(01234.000*m3)",
  "!D3B0"
};

void handleRoot() {
  String message = server.arg("text");
  server.send(200, "text/html", "<html><body><form method='POST'><textarea style='width:80%;height:80%;' id='text' name='text'>"+message+"</textarea><input type='submit' value='Send'></body></html>");
  Serial.println(message);
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

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

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
      for (int i = 0; i < 26; i++) {
        Serial.println(message[i]);
        delay(100);
      }
    }
  }
}
