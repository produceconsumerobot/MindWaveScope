/*
  A simple oscilliscope widget test
 
 (c) 2009 David Konsumer <david.konsumer@gmail.com>
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General
 Public License along with this library; if not, write to the
 Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 Boston, MA  02111-1307  USA
 */

/**** MindWaveScope.pde ****
** Modified from TestOscope.pde by Sean M. Montgomery 2013/04
** http://produceconsumerobot.com/
** https://github.com/produceconsumerobot
**
** Tested working with Processing 2.0b8
** 
** Processing script written to view NeuroSky MindWave data in an 
** arduinoscope oscilloscope type display.
** Requirements:
** neurosky library (customized, https://github.com/produceconsumerobot/ThinkGear-Java-socket)
** arduinoscope library (customized, https://github.com/produceconsumerobot/arduinoscope)
** controlP5 library (2.0.4, http://www.sojamo.de/libraries/controlP5/)
** org.json library (https://github.com/agoransson/JSON-processing)
**
** -- Select plotVars to display (See User 
**   Selected Setup Variables below.)
** -- Data may be written to a csv file using the "RECORD" button.
** -- y-axis scale may be adjusted using the "*2" and "/2" buttons.
** -- y-axis scale and offset defaults may be adjusted in code below.
**
******************************/


/**** User Selected Setup Variables ****/
/***************************************/

/* plotVars determines which variables are plotted and in which order
Options are:
Raw
SignalLevel
BlinkStrength
Attention
Meditation
Delta
Theta
Alpha1
Alpha2
Beta1
Beta2
Gamma1
Gamma2
*/

String[] plotVars = {"Raw", "BlinkStrength", "Attention", "Beta1", "Meditation","Alpha2", "SignalLevel"};
// yFactors sets the default y-axis scale for each plotVar
// yFactors can also be adjusted using buttons in the display window
float[] yFactors = {1f, 8f, 8f, 1/32f, 8f, 1/32f, 1f, 1f, 1f, 1f, 1f, 1f, 1f};

/*
// Plot / Record All Variables
String[] plotVars = {"Raw", "BlinkStrength", "Attention", "Meditation", "Delta", "Theta", 
"Alpha1", "Alpha2", "Beta1", "Beta2", "Gamma1", "Gamma2", "SignalLevel"};
// yFactors sets the default y-axis scale for each plotVar
// yFactors can also be adjusted using buttons in the display window
float[] yFactors = {1f, 8f, 8f, 8f, 1/512f, 1/256f, 1/128f, 1/32f, 1/32f, 1/32f, 1/32f, 1/32f, 1f};
*/

// Duration of time shown in the window (assumes 512Hz sampling of MindWave)
float timeWindow = 10f; // seconds

// yOffsets sets the y-axis offset for each plotVar
// offset the raw data (1st variable) by half the default scope resolution
// to prevent negative values from extending into other windows
int[] yOffsets = {512,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};

 

// Directory and name of your saved MindSet data. Make sure you 
// have write privileges to that location.
String saveDir = ".\\";
String[] fName = {saveDir, "MindWaveData", nf(year(),4), nf(month(),2), nf(day(),2), 
  nf(hour(),2), nf(minute(),2), nf(second(),2), "csv"};
String saveFileName = join(fName, '.');

// Choose window dimensions in number of pixels
int windowWidth = 1400; 
int windowHeight = 825;
/*******************************************/
/**** END User Selected Setup Variables ****/


int mindwaveSamplingRate = 512; // Hz

int numScopes = plotVars.length;

// all plots default to off
int plotRaw = -1;
int plotSignalLevel = -1;
int plotBlinkStrength = -1;
int plotAttention = -1;
int plotMeditation = -1;
int plotDelta = -1;
int plotTheta = -1;
int plotAlpha1 = -1;
int plotAlpha2 = -1;
int plotBeta1 = -1;
int plotBeta2 = -1;
int plotGamma1 = -1;
int plotGamma2 = -1;
/* old variables
int plotBatteryLevel = -1;
int plotErrorRate = -1;
*/

boolean saveDataBool = false; // wait until user turns on recording
boolean firstSave = true; // data has not been saved yet

//;
import arduinoscope.*;
import controlP5.*;
import neurosky.*;
import org.json.*;

ThinkGearSocket neuroSocket;
Oscilloscope[] scopes = new Oscilloscope[numScopes];
ControlP5 controlP5;
PrintWriter output = null;

int LINE_FEED=10; 
int[] vals;

void setup() {
  size(windowWidth, windowHeight, P2D);
  background(0);

  controlP5 = new ControlP5(this);

  int[] dimv = new int[2];
  dimv[0] = width-130; // 130 margin for text
  dimv[1] = height/scopes.length;

  // setup vals from serial
  vals = new int[scopes.length];

  for (int i=0;i<scopes.length;i++){
    int[] posv = new int[2];
    posv[0]=0;
    posv[1]=dimv[1]*i;

    // random color, that will look nice and be visible
    scopes[i] = new Oscilloscope(this, posv, dimv);
    scopes[i].setLine_color(color((int)random(255), (int)random(127)+127, 255)); 
    scopes[i].setPointsPerWindow(int(timeWindow * mindwaveSamplingRate)); // requires customized arduinoscope

    // yFactor buttons
    int yButH = dimv[0]+10;
    controlP5.addButton(i+"*2")
     .setLabel("*2")
     .setId(i)
     .setPosition(yButH,posv[1]+20)
     .setSize(20,20)
     ;
    controlP5.addButton((20+i)+"/2")
     .setLabel("/2")
     .setId(20+i)
     .setPosition(yButH+30,posv[1]+20)
     .setSize(20,20); 
    // old code
    //controlP5.addButton(i+"*2",1,dimv[0]+10,posv[1]+20,20,20).setId(i).setLabel("*2");  
    //controlP5.addButton((20+i)+"/2",1,dimv[0]+10,posv[1]+70,20,20).setId(20+i).setLabel("/2");

  }
  // record and pause buttons at top of window
   int rButH = dimv[0]+85;
   controlP5.addButton("Record")
     .setId(1000)
     .setPosition(rButH,5)
     .setSize(40,20)
     .setColorBackground( color( 0, 255 , 0 ) )
     ;
   controlP5.addButton("Pause")
     .setId(1100)
     .setPosition(rButH,30)
     .setSize(40,20)
     ; 
  // old code
  //controlP5.addButton("Record",1,rButH,5,40,20).setId(1000);
  //controlP5.controller("Record").setColorBackground( color( 0, 255 , 0 ) );
  //controlP5.addButton("Pause",1,rButH,30,40,20).setId(1100);

  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  neuroSocket.setRawArraySize(16); // Receive 16 rawEEG samples at a time, requires customized neurosky library

  try {
    neuroSocket.start();
  } 
  catch (Exception e) {
    //println("Is ThinkGear running??");
  } 
  
  ParsePlotVars();

}

void draw() {

  background(0);

  for (int i=0;i<scopes.length;i++){
    scopes[i].drawBounds();   

    // Moved addData to the rawEvent()
    //scopes[i].addData(int(vals[i] * yFactors[i]) + yOffsets[i]);
    scopes[i].draw();

    stroke(255);

    int[] pos = scopes[i].getPos();
    int[] dim = scopes[i].getDim();

    // separator lines
    line(0, pos[1], width, pos[1]);

    if (true) {
      // yfactor text
      fill(255);
      text("y * " + yFactors[i], dim[0] + 10,pos[1] + 55); 
    }
    
    // variable name text
    fill(scopes[i].getLine_color());
    text(plotVars[i], dim[0] + 10, pos[1] + 15);
  }    

  // draw text seperator, based on first scope
  int[] dim = scopes[0].getDim();
  stroke(255);
  line(dim[0], 0, dim[0], height);

  // update buttons
  if (true) {
    controlP5.draw();
  }
}

void rawEvent(int[] raw) {
  //println("RE");
  for (int r : raw) {
    if (plotRaw >= 0) {
      vals[plotRaw] = r;
    }
    if (saveDataBool) {
      SaveData();
    }   
    for (int i=0;i<scopes.length;i++){
      scopes[i].addData(int(vals[i] * yFactors[i]) + yOffsets[i]);
    }
    // reset the blink strength to show punctate blink events
    if (plotBlinkStrength >= 0)
      vals[plotBlinkStrength] = 0;
  }
}

void poorSignalEvent(int sig) {
  if (plotSignalLevel >= 0)
    vals[plotSignalLevel] = sig;
}

public void attentionEvent(int attentionLevel) {
  vals[plotAttention] = attentionLevel;
}

void meditationEvent(int meditationLevel) {
  if (plotMeditation >= 0)
    vals[plotMeditation] = meditationLevel;
}

void blinkEvent(int blinkStrength) {
  //println("blinkStrength: " + blinkStrength);
  if (plotBlinkStrength >= 0)
    vals[plotBlinkStrength] = blinkStrength;
    
}

public void eegEvent(int delta, int theta, int low_alpha, int high_alpha, int low_beta, int high_beta, int low_gamma, int mid_gamma) {
  if (plotDelta >= 0)
    vals[plotDelta] = delta;
  if (plotTheta >= 0)
    vals[plotTheta] = theta;
  if (plotAlpha1 >= 0)
    vals[plotAlpha1] = low_alpha;
  if (plotAlpha2 >= 0)
    vals[plotAlpha2] = high_alpha;
  if (plotBeta1 >= 0)
    vals[plotBeta1] = low_beta;
  if (plotBeta2 >= 0)
    vals[plotBeta2] = high_beta;
  if (plotGamma1 >= 0)
    vals[plotGamma1] = low_gamma;
  if (plotGamma2 >= 0)
    vals[plotGamma2] = mid_gamma;
}

void stop() {
  neuroSocket.stop();
  super.stop();
}

void SaveData() {
  // save all plotVars
  output.print(join(nf(vals,0),',')); 
  //output.print("," + nf(millis()*10,0)); // output time in 1/10ths of milliseconds to match Arduino Viewer
  output.println(""); 
}

// handles button clicks
void controlEvent(ControlEvent theEvent) {
  int id = theEvent.controller().id();

  if (id < 20) { // increase yFactor
    yFactors[id] = yFactors[id] * 2;
  } 
  else if (id < 40){ // decrease yFactor
    yFactors[id-20] = yFactors[id-20] / 2;
  } 
  else if ( id == 1100) { // pause display
    for (int i=0; i<numScopes; i++) {
      scopes[i].setPause(!scopes[i].isPause());
    }
  } 
  else if (id == 1000) { // Record/Stop button
    if (saveDataBool == false) // Start Recording
    {
      output = createWriter(saveFileName);
      // old code
      /*try {
        output = new PrintWriter(new FileWriter(saveFileName, true));
      } 
      catch (IOException e) {
        e.printStackTrace(); 
        print("ERROR: e.printStackTrace(); ");
      }
      */
      
      if (firstSave) {
        output.print(join(plotVars,','));
        //output.print(",time");
        output.println("");
        firstSave = false;
      }

      saveDataBool = true;
      controlP5.controller("Record").setCaptionLabel("Stop");
      controlP5.controller("Record").setColorBackground( color( 255,0,0 ) );
    } 
    else { // Stop Recording
      saveDataBool = false;
      output.flush();
      output.close();
      controlP5.controller("Record").setCaptionLabel("Record");
      controlP5.controller("Record").setColorBackground( color( 0,255,0 ) );
    }
  } // id == 1000
}

void ParsePlotVars() {
  for (int i=0; i<plotVars.length; i++) {
    if (plotVars[i].equals("Raw"))
      plotRaw = i;
    else if (plotVars[i].equals("SignalLevel"))
      plotSignalLevel = i;
    else if (plotVars[i].equals("BlinkStrength"))
      plotBlinkStrength = i;
    else if (plotVars[i].equals("Attention"))
      plotAttention = i;
    else if (plotVars[i].equals("Meditation"))
      plotMeditation = i;
    else if (plotVars[i].equals("Delta"))
      plotDelta = i;
    else if (plotVars[i].equals("Theta"))
      plotTheta = i;
    else if (plotVars[i].equals("Alpha1"))
      plotAlpha1 = i;
    else if (plotVars[i].equals("Alpha2"))
      plotAlpha2 = i;
    else if (plotVars[i].equals("Beta1"))
      plotBeta1 = i;
    else if (plotVars[i].equals("Beta2"))
      plotBeta2 = i;
    else if (plotVars[i].equals("Gamma1"))
      plotGamma1 = i;
    else if (plotVars[i].equals("Gamma2"))
      plotGamma2 = i;
  }
}
