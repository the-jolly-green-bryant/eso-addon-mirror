===============
ravSpeed by rav
===============

This addon shows your current speed in units per second and a percentage of a reference speed you can set in a small, movable window.

To set a reference speed, run for a while and look at the ups display. Let's say it shows 250 ups while running.
Now you can set this speed as a reference:
/ravspeed 250
You will see 100% as new percentage while running. While sprinting, your speed will increase to 130%.


Commands:
=========
/ravspeed [referenceUPS]


License:
=========
[URL="http://creativecommons.org/licenses/by-nc-sa/4.0/"][IMG]http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png[/IMG][/URL]
This work is licensed under a [URL="http://creativecommons.org/licenses/by-nc-sa/4.0/"]Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License[/URL]


Changelog:
=========

1.3.1: 17/02/2021

	API bump to 101032 (Deadlands - ESO U32)

	Fixed controls that didn't always hide
	Fixed typos


1.3.0: 28/04/21

	API bump to 100035 (Blackwood - ESO U30)

	Speed calculation automatically adjusts depending on the refresh rate

	Added full customisation of the calculation
	- array size
	- magic value

	Remade the addon menu
	Split the code into 3 files
	- main
	- menu
	- control
	

1.2.2: 18/03/21
	Changed from OnUpdate to RegisterForUpdate() as default

	Added the following settings
	- force OnUpdate use
	- custom refresh rate

	Spacing between the Pct and the Ups labels now depends on the font size
	Added default values to all settings


1.2.1: 04/03/21
	API bump to 100034 (Flames of Ambition - ESO U29)

	The control now automatically hides if UI layer is on

	Added more options to the settings
	- font customisation
	- position lock
	- force control display

	Added more options to the chat command 
	- position lock
	- force control display


1.2.0: 13/11/20
    API bump to 100033 (Markarth - ESO U28)
    Added LAM2 dependency

    Changed saved variables to AccountWide

    Added addon menu with LAM2
    - show ups speed toggle
    - show % speed toogle
    - set reference reference speed 

    Changed GetMapPlayerPosition('player') to GetUnitRawWorldPosition('player')
    Removed zone check