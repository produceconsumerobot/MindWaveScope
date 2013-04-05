*** MindWaveScope Install Instructions ***

Written by Dr. Sean M. Montgomery
http://produceconsumerobot.com/
https://github.com/produceconsumerobot

Tested working with Processing 2.0b8

Below are the instructions to use the MindWaveScope processing script to read, plot, and log data from the NeuroSky MindWave directly over your computer's bluetooth connection.

Materials:
1	NeuroSky MindWave
1	Computer

Required Software (see below for download instructions):
** neurosky library (customized, https://github.com/produceconsumerobot/ThinkGear-Java-socket)
** arduinoscope library (customized, https://github.com/produceconsumerobot/arduinoscope)
** controlP5 library (2.0.4, http://www.sojamo.de/libraries/controlP5/)
** org.json library (https://github.com/agoransson/JSON-processing)
** MindWaveScope.pde


Instructions:

Follow the instructions that came with your MindWave to connect the MindWave to the Bluetooth port on your computer. 

Download and extract Processing software
getting started - http://processing.org/learning/gettingstarted/

Download Neurosky library
https://github.com/produceconsumerobot/ThinkGear-Java-socket
(see https://github.com/borg/ThinkGear-Java-socket for original version)

Download Arduinoscope library
https://github.com/produceconsumerobot/arduinoscope
(see https://github.com/konsumer/arduinoscope for original version)

Download ControlP5 library
http://www.sojamo.de/libraries/controlP5/

Download json library
https://github.com/agoransson/JSON-processing

In your libraries\ directory (look in File:Preferences:Sketchbook location)
unzip contents of neurosky.zip
unzip contents of arduinoscope.zip
unzip contents of controlp5.zip
unzip contents of json.zip
Directory structure should be:
processing\libraries\neurosky\library\
processing\libraries\arduinoscope\examples\
processing\libraries\arduinoscope\library\
processing\libraries\arduinoscope\reference\
processing\libraries\arduinoscope\src\
processing\libraries\controlP5\examples\
processing\libraries\controlP5\library\
processing\libraries\controlP5\reference\
processing\libraries\controlP5\src\
processing\libraries\json\library\

Download and extract MindWaveScope from 
https://github.com/produceconsumerobot/

Open MindWaveScope.pde with processing.

Hit Run. If you want to record data, press the green record button. You must have write privileges in your processing directory or change the directory specified in MindWaveScope.pde. You may change the y-scale of the individual plots using the "*2" and "/2" buttons or in the user-variable section of the code.

If you haven't already, put the MindWave on your head and try to get a good EEG signal. Look for low background noise in the Raw EEG and low SignalLevel score as seen in the top panel of "signal_quality.jpg". Note how you can clearly see eyeblinks on a low noise background indicating a a high quality signal in the top panel, while in the lower two panels it is not possible to distinguish eyeblinks from background noise.



