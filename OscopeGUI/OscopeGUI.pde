
/*
Osilliscope GUI
 ECE 258
 Spring 2015
 David Kaplan & Bradley Natarian
 */

import controlP5.*;
import processing.serial.*;
import java.lang.Math;

ControlP5 cp5;
int padding = 20;
int numVertDivisions = 10;
int numHorDivisions = 10;
float vertPos, horPos;
int timeDiv, voltsDiv;
float vVal, hVal, vcVal;
int trigger, Hslider1, Hslider2, Vslider1, Vslider2;
boolean Tcursor1, Tcursor2, Vcursor1, Vcursor2;
boolean Vmax, Vmin, Vpp, Vave, Freq, Period, RF, SR, AS, SC;
float max, min;
PFont f;
float vScale, tScale;
float v1, v2, dv, t1, t2, dt, freq, period, freqT;
float prevFreqT = 0;
float offset;
String vVal2, hVal2;
int buffLength = 50000;
int windowOffset = 0;
boolean triggered = false;
int timeLength = 1200;
float samplingRate = 23.26; //Sampling rate in kHz 11.36
float samplingPeriod = 1/samplingRate; //Sampling period in ms
float timeRatio = 1;
int windowLength = Math.round(1000*samplingRate);
int filledI = 0;

Serial port;  // Create object from Serial class
int val;      // Data received from the serial port
int[] buff = new int[buffLength];
int[] windowBuff = new int[windowLength];


void setup() {
  size(1900, 950); //size of window
  surface.setResizable(true);
  cp5 = new ControlP5(this); //controll object

  cp5.addSlider("vertPos") //vertPos slider
      .setPosition(1250, 25)
      .setRange(0, 1024)
        .setSize(20, 900)
          .setValue(512)
            ;

  //sets label at top and no value   
  cp5.getController("vertPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);   
  cp5.getController("vertPos").getValueLabel().setVisible(false);


  cp5.addSlider("horPos") //horPos slider
      .setPosition(1360, 25)
      .setWidth(515)
        .setHeight(20)
          .setRange(0, 1024)
            .setValue(1024)
              ;

  //sets label at top and no value
  cp5.getController("horPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("horPos").getValueLabel().setVisible(false); 


  cp5.addSlider("voltsDiv") //voltsDiv slider
      .setPosition(1360, 175)
      .setWidth(515)
        .setRange(0, 255)
          .setValue(153)
            .setHeight(20)
              .setNumberOfTickMarks(6)
                .setSliderMode(Slider.FLEXIBLE)
                  ;

  //sets label top
  cp5.getController("voltsDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("voltsDiv").getValueLabel().setVisible(false); 


  cp5.addSlider("timeDiv") //timeDiv slider
      .setPosition(1360, 105)
      .setWidth(515)
        .setHeight(20)
          .setRange(0, 255)
            .setValue(148)
              .setNumberOfTickMarks(13)
                .setSliderMode(Slider.FLEXIBLE)
                  ;

  //sets lable at top
  cp5.getController("timeDiv").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("timeDiv").getValueLabel().setVisible(false); 

  cp5.addSlider("trigger") //trigger slider
      .setPosition(1300, 25)
      .setWidth(20)
        .setHeight(900)
          .setRange(0, 1024)
            .setValue(512)
              ;

  //sets label at top and no value
  cp5.getController("trigger").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  cp5.getController("trigger").getValueLabel().setVisible(false);


  cp5.addToggle("Tcursor1") //toggle for time 1
    .setPosition(1470, 250)
      .setSize(70, 30)
          ;
  cp5.getController("Tcursor1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);          

  cp5.addToggle("Tcursor2") //toggle for time 2
    .setPosition(1570, 250)
      .setSize(70, 30)
          ;
  cp5.getController("Tcursor2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);          

  cp5.addToggle("Vcursor1") //toggle for volts 1
    .setPosition(1670, 250)
      .setSize(70, 30)
          ;
  cp5.getController("Vcursor1").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);          

  cp5.addToggle("Vcursor2") //toggle for volts 2
    .setPosition(1770, 250)
      .setSize(70, 30)
          ;
  cp5.getController("Vcursor2").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);          
          
  cp5.addToggle("Rising_Falling") //TrigMode
    .setPosition(1500, 900)
      .setSize(70, 30)
        .setMode(ControlP5.SWITCH)
          ;
  cp5.getController("Rising_Falling").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  cp5.addToggle("Single_Cont") //trigmode2
    .setPosition(1630, 900)
      .setSize(70, 30)
        .setMode(ControlP5.SWITCH)
          ;
  cp5.getController("Single_Cont").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
          
  cp5.addToggle("Stop_Run") //on/off
    .setPosition(1760, 900)
      .setSize(70, 30)
        .setMode(ControlP5.SWITCH)
          ;          
  cp5.getController("Stop_Run").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  cp5.addSlider("Vslider1") //slider along with Vcursor1 for volts 1
    .setPosition(1360, 400)
      .setWidth(20)
        .setHeight(525)
          .setRange(925, 25)
            .setValue(475)
              .setVisible(false)
                ; 

  cp5.getController("Vslider1").getValueLabel().setVisible(false);

  cp5.addSlider("Vslider2") //slider along with Vcursor2 for volts 2 
    .setPosition(1410, 400)
      .setWidth(20)
        .setHeight(525)
          .setRange(925, 25)
            .setValue(475)
              .setVisible(false)
                ; 

  cp5.getController("Vslider2").getValueLabel().setVisible(false);


  cp5.addSlider("Hslider1") //slider along with Tcursor1 for time 1
    .setPosition(1460, 310)
      .setWidth(400)
        .setHeight(20)
          .setRange(25, 1225)
            .setValue(625)
              .setVisible(false)
                ; 

  cp5.getController("Hslider1").getValueLabel().setVisible(false);


  cp5.addSlider("Hslider2") //slider along with Tcursor2 for time 2 
    .setPosition(1460, 350)
      .setWidth(400)
        .setHeight(20)
          .setRange(25, 1225)
            .setValue(625)
              .setVisible(false)
                ;     

  cp5.getController("Hslider2").getValueLabel().setVisible(false);


  cp5.addToggle("Vmax", 1500, 390, 70, 20); //bang for zero the horPos
  cp5.getController("Vmax").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);  
  cp5.addToggle("Vmin", 1500, 430, 70, 20); //bang for zero the horPos
  cp5.getController("Vmin").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.addToggle("Vpp", 1630, 390, 70, 20); //bang for zero the horPos
  cp5.getController("Vpp").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.addToggle("Vave", 1630, 430, 70, 20); //bang for zero the horPos
  cp5.getController("Vave").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.addToggle("Freq", 1760, 390, 70, 20); //bang for zero the horPos
  cp5.getController("Freq").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.addToggle("Period", 1760, 430, 70, 20); //bang for zero the horPos
  cp5.getController("Period").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);

  cp5.addBang("ZeroH", 1360, 52, 25, 25); //bang for zero the horPos

  cp5.addBang("ZeroV", 1360, 330, 25, 25); //bang for zero the vertPos
  cp5.getController("ZeroV").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); //lable at top

  cp5.addBang("Reset_Trig", 1360, 270, 25, 25);//bang for trigger reset
  cp5.getController("Reset_Trig").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0); //label at top
  
  cp5.addBang("Auto_Scale", 1490, 800, 140, 40);//bang for trigger reset
  cp5.getController("Auto_Scale").getCaptionLabel().setVisible(false);

  f = createFont("Arial", 16, true); //creates font class

  //serial link setup
  //port = new Serial(this, "COM4", 1000000);
  smooth();
} //end setup


//getY method
int getY(int val) {
  int y = Math.round(-112.5f*((-10/vScale)*(.0078431373f*val-1)) + 475.5);
  return y;
}


//events for zero vertPos bang
public void ZeroV(int theValue) {
  //println("event from ZeroV");
  cp5.getController("vertPos").setValue(512);
}

//events for reset trigger bang
public void Reset_Trig(int theValue) {
  //println("event from reset");
  cp5.getController("trigger").setValue(512);
}

//events for zero horPos bang
public void ZeroH(int theValue) {
  //println("event from ZeroH");
  cp5.getController("horPos").setValue(1024);
}

//events for vertPos slider
public void vertPos(int theValue) {
  //println("event from verPos");
}

//evets for voltsDiv
public void voltsDiv(int theValue) {
  switch (theValue) {
  case 0:
    vScale = .1;
    break;
  case 51:
    vScale = .2;
    break;
  case 102:
    vScale = .5;
    break;
  case 153:
    vScale = 1;
    break;
  case 204:
    vScale = 2;
    break;
  case 255:
    vScale = 5;
    break;
  }
}

//events for timeDiv
public void timeDiv(int theValue) {
  switch (theValue) {
  case 0:
    tScale = .01;
    break;
  case 21:
    tScale = .02;
    break;
  case 42:
    tScale = .05;
    break;
  case 63:
    tScale = .1;
    break;
  case 85:
    tScale = .2;
    break;
  case 106:
    tScale = .5;
    break;
  case 127:
    tScale = 1;
    break;
  case 148:
    tScale = 2;
    break;
  case 170:
    tScale = 5;
    break;
  case 191:
    tScale = 10;
    break;
  case 212:
    tScale = 20;
    break;
  case 233:
    tScale = 50;
    break;
  case 255:
    tScale = 100;
    break;
  }
  timeLength = Math.round((10*tScale)/samplingPeriod);
  timeRatio = ((10*tScale)/samplingPeriod)/1200;
}

//events for volts 1 toggle
public void Vcursor1(boolean flag) {
  if (flag == true) {
    cp5.getController("Vslider1").setVisible(true);
    Vcursor1 = true;
  } else {
    cp5.getController("Vslider1").setVisible(false);
    Vcursor1 = false;
  }
}

//events for volts 2 toggle
public void Vcursor2(boolean flag) {
  if (flag == true) {
    cp5.getController("Vslider2").setVisible(true);
    Vcursor2 = true;
  } else {
    cp5.getController("Vslider2").setVisible(false);
    Vcursor2 = false;
  }
}

public void Auto_Scale(boolean flag) {
  if (flag == true) {
    AS = true;
    textFont(f, 600);
    text("NO!", 120, 670);
  }
}

public void Vmax(boolean flag) {
  if (flag == true) {
    Vmax = true;
  } else {
    Vmax = false;
    Vpp = false;
    cp5.getController("Vpp").setValue(0);
  }
}

public void Vmin(boolean flag) {
  if (flag == true) {
    Vmin = true;
  } else {
    Vmin = false;
    Vpp = false;
    cp5.getController("Vpp").setValue(0);
  }
}

public void Vpp(boolean flag) {
  if (flag == true) {
    Vpp = true;
    Vmax = true;
    cp5.getController("Vmax").setValue(1);
    Vmin = true;
    cp5.getController("Vmin").setValue(1);
  } else {
    Vpp = false;
  }
}

public void Vave(boolean flag) {
  if (flag == true) {
    Vave = true;
  } else {
    Vave = false;
  }
}

public void Freq(boolean flag) {
  if (flag == true) {
    Freq = true;
  } else {
    Freq = false;
  }
}

public void Period(boolean flag) {
  if (flag == true) {
    Period = true;
  } else {
    Period = false;
  }
}

public void Rising_Falling(boolean flag) {
  if (flag == true) {
    RF = true;
  } else {
    RF = false;
  }
}

public void Stop_Run(boolean flag) {
  if (flag == true) {
    SR = true;
  } else {
    for (int i=buffLength-1; i>0; i--)
    buff[i] = 127;
    filledI = 0;
    SR = false;
  }
}

public void Single_Cont(boolean flag) {
  if (flag == true) {
    SC = true;
  } else {
    SC = false;
  }
}

//events for time 1 toggle
public void Tcursor1(boolean flag) {
  if (flag == true) {
    cp5.getController("Hslider1").setVisible(true);
    Tcursor1 = true;
  } else {
    cp5.getController("Hslider1").setVisible(false);
    Tcursor1 = false;
  }
}

//events for time 2 toggle
public void Tcursor2(boolean flag) {
  if (flag == true) {
    cp5.getController("Hslider2").setVisible(true);
    Tcursor2 = true;
  } else {
    cp5.getController("Hslider2").setVisible(false);
    Tcursor2 = false;
  }
}

void draw() {

  background(120); //light grey backgroung
  
  //vertPos slider
  cp5.getController("vertPos").setPosition((width/1.5)+(2*padding), padding);
  cp5.getController("vertPos").setSize(20, height-(2*padding));
  cp5.getController("vertPos").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  //trigger slider
  cp5.getController("trigger").setPosition((width/1.5)+(3*padding)+20, padding);
  cp5.getController("trigger").setSize(20, height-(2*padding));
  cp5.getController("trigger").getCaptionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE).setPaddingX(0);
  
  strokeWeight(1);
  stroke(0);
  fill(200);
  rect(1460, 475, 400, 400, 7); //white info box in bottom right

  //text for volts and time div position info
  textFont(f, 12);
  fill(255);
  text("100mV", 1352, 217);
  text("200mV", 1450, 217);
  text("500mV", 1548, 217);
  text("1V", 1660, 217);
  text("2V", 1762, 217);
  text("5V", 1864, 217);

  textFont(f, 12);
  text("10us", 1353, 147);
  text("20us", 1395, 147);
  text("50us", 1440, 147);
  text("100us", 1480, 147);
  text("200us", 1522, 147);
  text("500us", 1564, 147);
  text("1ms", 1606, 147);
  text("2ms", 1648, 147);
  text("5ms", 1689, 147);
  text("10ms", 1730, 147);
  text("20ms", 1771, 147);
  text("50ms", 1813, 147);
  text("100ms", 1854, 147);
  
  textFont(f, 18);
  fill(0);
  text("Auto Scale", 1515, 860);

  //gets buff from sliders
  trigger = Math.round(cp5.getController("trigger").getValue());
  vertPos = cp5.getController("vertPos").getValue();
  horPos = cp5.getController("horPos").getValue();
  voltsDiv = Math.round(cp5.getController("voltsDiv").getValue());
  timeDiv = Math.round(cp5.getController("timeDiv").getValue());
  Hslider1 = Math.round(cp5.getController("Hslider1").getValue());
  Hslider2 = Math.round(cp5.getController("Hslider2").getValue());
  Vslider1 = Math.round(cp5.getController("Vslider1").getValue());
  Vslider2 = Math.round(cp5.getController("Vslider2").getValue());  

  //math for offset and delay
  hVal = ((horPos*.009765625) - 10)*tScale;
  int hValI = Math.round(abs(hVal/samplingPeriod));
  vVal = ((vertPos*.0078125) - 4)*vScale;
  float trigger_V = ((trigger*.0078125) - 4)*vScale;
  
  int trigger_p = Math.round(-.87890626*trigger + 925);

  offset = ((vertPos*.87890625)+25);

  vcVal = (vertPos*.87890625) - 450;

  //draw screen in colors of sliders
  fill(128, 150, 140);
  rect(padding, padding, round(width/1.5), height-(2*padding), 7);

  //black axes 
  stroke(0);
  strokeWeight(1.5);
  line(padding, height/2, padding+(width/1.5), height/2); // x-axis
  line(round((width/1.5)/2)+padding, padding, ((width/1.5)/2)+padding, height-padding); // y-axis

  //grey gridlines
  stroke(100);
  strokeWeight(1);
  int gridHeight = height-(2*padding);
  int gridWidth = round(width/1.5);
  
  for(int i=1; i<numHorDivisions; i++){
    if(i!=numHorDivisions/2){
      line(padding, i*(gridHeight/numHorDivisions)+padding, (width/1.5)+padding, i*(gridHeight/numHorDivisions)+padding);
    }
  }
  for(int i=1; i<numVertDivisions; i++){
    if(i!=numVertDivisions/2){
      line(i*(gridWidth/numVertDivisions)+padding, padding, i*(gridWidth/numVertDivisions)+padding, height-padding);
    }
  }

  //black trigger line
  stroke(0);
  strokeWeight(1.5);
  line(padding, trigger_p, round(width/1.5)+padding, trigger_p); //draws trigger line at vert position of trigger

  stroke(245, 245, 40); //bright yellow for cursor lines
  textFont(f, 18);
  fill(0);
  

  //logic for trigger lines and text and such
  if (Tcursor1==true) {
    line(Hslider1, 25, Hslider1, 925);
    t1 = ((.0083333333)*(Hslider1-25) - 5)*tScale;
    String t1_1 = String.format("%.3f", t1);
    text("Time 1 = "+t1_1+" ms", 1490, 555);
  }

  if (Tcursor2==true) {
    line(Hslider2, 25, Hslider2, 925);
    t2 = ((.0083333333)*(Hslider2-25) - 5)*tScale;
    String t2_2 = String.format("%.3f", t2);
    text("Time 2 = "+t2_2+" ms", 1490, 585);
  }  

  if ((Tcursor1==true) && (Tcursor2==true)) {
    dt = Math.abs(t1-t2);
    freq = (1/dt)*1000;
    String dt_1 = String.format("%.3f", dt);
    String freq_1 = String.format("%.2f", freq);
    text("\u0394 Time = "+dt_1+" ms", 1490, 615);
    text("Freq = "+(freq_1)+" Hz", 1490, 645);
  }

  if (Vcursor1==true) {
    float y1 = Vslider1 - vcVal;
    float y2 = Vslider1 - vcVal;
    y1 = constrain(y1, 26, 924);
    y2 = constrain(y2, 26, 924);
    line(25, y1, 1225, y2);
    v1 = ((-.0088888888)*(Vslider1-25) + 4)*vScale;
    String v1_1 = String.format("%.3f", v1);
    text("Voltage 1 = "+v1_1+" V", 1680, 555);
  }

  if (Vcursor2==true) {
    float y1 = Vslider2 - vcVal;
    float y2 = Vslider2 - vcVal;
    y1 = constrain(y1, 26, 924);
    y2 = constrain(y2, 26, 924);
    line(25, y1, 1225, y2);
    v2 = ((-.0088888888)*(Vslider2-25) + 4)*vScale;
    String v2_2 = String.format("%.3f", v2);
    text("Voltage 2 = "+v2_2+" V", 1680, 585);
  } 

  if ((Vcursor1==true) && (Vcursor2==true)) {
    dv = Math.abs(v1-v2);
    String dv_1 = String.format("%.3f", dv);
    text("\u0394 Voltage = "+dv_1+" V", 1680, 615);
  }
  
  stroke(0);
  line(1460,660,1860,660);
  text("Cursors:", 1490, 515);
  line(1490, 516, 1490+textWidth("Cursors:"), 516);
  text("Measurments:", 1490, 700);
  line(1490, 701, 1490+textWidth("Measurments:"), 701);

  //text for offset and delay
  textFont(f, 14);
  vVal2 = String.format("%.3f", vVal);
  fill(255);
  text("Offset = "+vVal2+" V", 1335, 370);

  hVal2 = String.format("%.3f", hVal);
  text("Delay = "+hVal2+ " ms", 1400, 70);


  //draw signal

  //println(buffLength-windowLength);
  
  if(filledI >= timeLength){
  for (int j=0; j<(buffLength-timeLength-1); j++) {
    int trig_val1 = 900+50-getY(buff[j])+(475-Math.round(offset));
    int trig_val2 = 900+50-getY(buff[j+1])+(475-Math.round(offset));
    //println(trigger_p + "   " + trig_val1);
    if (RF == false) {
      if ((trigger_p > trig_val1) && (trigger_p < trig_val2)){
        windowOffset = j;
        triggered = true;
        break;
      } else {
        triggered = false;
        }
    } 
    if (RF == true) {
        if ((trigger_p < trig_val1) && (trigger_p > trig_val2)){
        windowOffset = j;
        triggered = true;
        break;
      } else {
        triggered = false;
        }
    }
  }
  if ((SC == true) && (triggered == true) ){
          cp5.getController("Stop_Run").setValue(1);
    }
  
  //println(windowOffset);
  if (triggered == false) {
    for (int i=0; i<timeLength-1; i++)
    windowBuff[i] = buff[i];
  }
  if (triggered == true) {
    for (int i=windowOffset; i<(timeLength-1+windowOffset); i++){
      windowBuff[i-windowOffset] = buff[i];
    }
  }
  //println(trigger_p + "   " + getY(windowBuff[0]) + "   " + windowOffset );
  stroke(180, 30, 30);
  strokeWeight(2);
  textFont(f, 18);
  fill(0);
  for (int x=timeLength-2; x>0; x--) {
    float x1 = (x/timeRatio)+25;
    float x2 = (x/timeRatio)+26;
    float y1 = 900+50-getY(windowBuff[x-1])+(475-Math.round(offset));
    float y2 = 900+50-getY(windowBuff[x])+(475-Math.round(offset));
    x1 = constrain(x1, 26, 1224);
    x2 = constrain(x2, 26, 1224);
    y1 = constrain(y1, 26, 924);
    y2 = constrain(y2, 26, 924);
    line(x1, y1, x2, y2);
  }
  filledI = timeLength;
  }
  stroke(85,240,120);
  strokeWeight(1);  
  if (Vmax == true) {
    int index = 0;
    int maxY = 900+50-getY(windowBuff[0])+(475-Math.round(offset));
    int Y;
    for (int i=0; i<timeLength-1; i++) {
      Y = 900+50-getY(windowBuff[i])+(475-Math.round(offset));
      if (Y<maxY) {
         maxY = Y;
         index = i;
      }
    }
    line(25,maxY,1225,maxY);
    max = (10*(.0078431373f*windowBuff[index]-1));
    String max1 = String.format("%.3f", max);
    text("Vmax = "+max1+" V", 1680, 740);
  }
  
  if (Vmin == true) {
    int index = 0;
    int minY = 900+50-getY(windowBuff[0])+(475-Math.round(offset));
    int Y;
    for (int i=0; i<timeLength-1; i++) {
      Y = 900+50-getY(windowBuff[i])+(475-Math.round(offset));
      if (Y>minY) {
         minY = Y;
         index = i;
      }
    }
    line(25,minY,1225,minY);
    min = (10*(.0078431373f*windowBuff[index]-1));
    String min1 = String.format("%.3f", min);
    text("Vmin = "+min1+" V", 1680, 770);
  }
  
  if (Vpp == true) {
    float pp = (Math.abs(max) + Math.abs(min));
    String pp1 = String.format("%.3f", pp);
    text("Vp-p = "+pp1+" V", 1680, 800);
  }
  
  stroke(0, 255,255);
  if (Vave == true) {
    float total = 0;
    int totalY = 0;
    float ave = 0;
    int Y = 0;
    for (int i=0; i<timeLength-1; i++) {
      Y = 900+50-getY(windowBuff[i])+(475-Math.round(offset));
      totalY = totalY + Y;
      total = total + (10*(.0078431373f*windowBuff[i]-1));
    }
    ave = total/timeLength;
    int aveY = totalY/timeLength;
    line(25,aveY,1225,aveY);
    String ave1 = String.format("%.3f", ave);
    text("Vave = "+ave1+" V", 1680, 830);
  }
  
  if (Freq == true) {
    int trig1 = -1;
    int trig2 = -1;
    boolean triggs = false;
    for (int j=0; j<(timeLength-1); j++) {
    int trig_val1 = 900+50-getY(windowBuff[j])+(475-Math.round(offset));
    int trig_val2 = 900+50-getY(windowBuff[j+1])+(475-Math.round(offset));
    //println(trigger_p + "   " + trig_val1);
    if (RF == false) {
      if ((trigger_p > trig_val1) && (trigger_p < trig_val2)){
        if (trig1 == -1){
        trig1 = j;
        }
        else if ((trig1 != -1) && (trig2 == -1)){
          trig2 = j;
          triggs = true;
          break;
        }
      } 
    } 
    if (RF == true) {
        if ((trigger_p < trig_val1) && (trigger_p > trig_val2)){
        if (trig1 == -1){
        trig1 = j;
        }
        else if ((trig1 != -1) && (trig2 == -1)){
          trig2 = j;
          triggs = true;
          break;
        }
      } 
    }
  }
  
  if (triggs == true){
   int diff = trig2 - trig1;
   freqT = 1/(diff * (samplingPeriod/1000)); 
   if(abs(freqT - prevFreqT) < 20){
     freqT = prevFreqT;
   }
   period = diff * (samplingPeriod/1000);
   prevFreqT = freqT;
   String freqT1 = String.format("%.2f", freqT);
   text("Freq = "+freqT1+" Hz", 1490, 740);
  }
  else{
    text("Freq not found", 1490,740);
  }
  
}
  
if (Period == true) {
    int trig1 = -1;
    int trig2 = -1;
    boolean triggs = false;
    for (int j=0; j<(timeLength-1); j++) {
    int trig_val1 = 900+50-getY(windowBuff[j])+(475-Math.round(offset));
    int trig_val2 = 900+50-getY(windowBuff[j+1])+(475-Math.round(offset));
    //println(trigger_p + "   " + trig_val1);
    if (RF == false) {
      if ((trigger_p > trig_val1) && (trigger_p < trig_val2)){
        if (trig1 == -1){
        trig1 = j;
        }
        else if ((trig1 != -1) && (trig2 == -1)){
          trig2 = j;
          triggs = true;
          break;
        }
      } 
    } 
    if (RF == true) {
        if ((trigger_p < trig_val1) && (trigger_p > trig_val2)){
        if (trig1 == -1){
        trig1 = j;
        }
        else if ((trig1 != -1) && (trig2 == -1)){
          trig2 = j;
          triggs = true;
          break;
        }
      } 
    }
  }
  
  if (triggs == true){
   int diff = trig2 - trig1;
   freqT = 1/(diff * (samplingPeriod/1000)); 
   if(abs(freqT - prevFreqT) < 20){
     freqT = prevFreqT;
   }
   period = diff * samplingPeriod;
   prevFreqT = freqT;
   String period1 = String.format("%.2f", period);
   text("Period = "+period1+" ms", 1490, 770);
  }
  else{
    text("Period not found", 1490,770);
  }
}
 
} //end draw

void serialEvent(Serial port){
  if (SR == false){
//while (port.available () >= 1) {
    //if (port.read() == 0xff) {
    val = port.read();
  
    //println(val);
    //port.write(0xff);
    //}
 // }
  for (int i=buffLength-1; i>0; i--)
    buff[i] = buff[i-1];
  buff[0] = val;
  filledI++;
  }
}