# PapaCrown
PapaCrown is ESO Addon.  
Version: 1.6.5  
APIVersion: 100020  

PapaCrown Fixed & Improved made by @triase to continue work of @Area51Visitor on PapaCrown untill he return.   
tiase's original advance emphasized crown Addon is CrownCustomizer.  
http://www.esoui.com/downloads/info1548-CrownCustomizer.html  


Increases the size of leaders crown so no one has excuse for being lost .  

Changing the color of the icon is impossible, but you can change the texture file it references.   
For example, replace the line of code in the addon with this to get the red ebonheart pact banner:  

SetFloatingMarkerInfo(MAP_PIN_TYPE_GROUP_LEADER, 64, "EsoUI/Art/MapPins/AvA_flagEbonheart.dds")  

If you decide to change it...be sure to close your game and log back in; just reloading UI will crash it.  

- Edited function in attempt to stop crashing.