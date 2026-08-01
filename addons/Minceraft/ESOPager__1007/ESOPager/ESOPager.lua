ESOPager = {}
ESOPager.name = "ESOPager"
ESOPager.Version =  "1.0"
ESOPager.settingsVersion = "1"
ESOPager.settingsDefaults = {

          TrackingNames = {
          
          name1 = "",
          name2 = "",
          name3 = "",
          name4 = "",
          name5 = "",
          name6 = "",
          name7 = "",
          name8 = "",
                        };
         
         
          StatusTracking = false,
          ZoneTracking = false,
          ZoneTrackingDefault = false,
          StatusTrackingDefault = false,
          
          TransitHubs = {
          
          Home = ""
          
          
          
          
          
                          },
          
         TransitGrid = {
         
         
         
         
         
         
                     },
          
        LocalTransitGrid = {
        
        
        
             
        
        
        
        
        
                      },
        ChosenType = "Choose Local Transit"             
          
                            }
                            

local AddonLoaded = false

function ESOPager.Initialize(eventCode, addOnName)
   if (addOnName ~= ESOPager.name) then
   
   return
 end     
 
 AddonLoaded = true
  ESOPager.settings = ZO_SavedVars:New("ESOPager_SavedVars", ESOPager.settingsVersion, nil, ESOPager.settingsDefaults, nil );


  ZO_CreateStringId("SI_BINDING_NAME_PAGER", "ESOPager")
  ESOPager_CreateSettingsMenu()
 
 return AddonLoaded 

end

local LAM2

local function alertAddonLoaded()

   if (AddonLoaded) then
 


  -- d("|cFF0000Minceraft's|r ESOPager v1.0 Loaded  !! ");
  
       --PrintInfo() 
      
         
       
 
     return
  
   end 
 
 EVENT_MANAGER:UnregisterForEvent("ESOPager", EVENT_PLAYER_ACTIVATED)

end




 TablePractice = {

[1] = "foo",
[2] = "bar"





                 }



function IterateTables(table)

 for k,v in ipairs(table) do


   d(v)

  end
end

function Jumper1()

    
   
   JumpToGuildMember(ESOPager.settings.TrackingNames.name1) 
   
  
end
      
 function Jumper2()

    
   
   JumpToGuildMember(ESOPager.settings.TrackingNames.name2) 
   
  
end      

function Jumper3()

    
   
   JumpToGuildMember(ESOPager.settings.TrackingNames.name3) 
   
  
end

function Jumper4()

    
   
   JumpToGuildMember(ESOPager.settings.TrackingNames.name4) 
   
  
end


--["PLAYER_STATUS_AWAY"] = 2

--["PLAYER_STATUS_DO_NOT_DISTURB"] = 3

--["PLAYER_STATUS_OFFLINE"] = 4

--["PLAYER_STATUS_ONLINE"] = 1 
 


function ESOPager_StatusAlert(eventCode,_,DisplayName,_,newStatus)
   if AddonLoaded then
  local status 
  local StatusTracking = ESOPager.settings.StatusTracking 
  
  if StatusTracking == true then
  if (DisplayName == GetUnitName("player")) then return end
  if (newStatus == 1 or 4) then
 
  if newStatus == 1 then status = "|c00FF00Online|r" end
  if newStatus == 4 then status = "|cFF0000Offline|r" end
 
  if (DisplayName == ESOPager.settings.TrackingNames.name1)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." is now "..status)
  
  end
    
  if (DisplayName == ESOPager.settings.TrackingNames.name2)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." is now "..status)
  
  end 
    
  if (DisplayName == ESOPager.settings.TrackingNames.name3)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." is now "..status)
  
  end  
    
  if (DisplayName == ESOPager.settings.TrackingNames.name4)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." is now "..status)
  
  end
    
    
    
      end
    end
  end
end


function ESOPager_ZoneAlert(eventCode,_,DisplayName,_,newZone)
  
  
  if AddonLoaded then
  
  
  
  
  
  if ESOPager.settings.ZoneTracking  == true then
  
  if DisplayName == GetUnitName("player") then return end
 
  if (DisplayName == ESOPager.settings.TrackingNames.name1)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." has moved to "..newZone)
  
  end
    
  if (DisplayName == ESOPager.settings.TrackingNames.name2)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
    d(DisplayName.." has moved to "..newZone)
  
  end 
    
  if (DisplayName == ESOPager.settings.TrackingNames.name3)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." has moved to "..newZone)
  
  end  
    
  if (DisplayName == ESOPager.settings.TrackingNames.name4)  then
  
   PlayItemSound(ITEM_SOUND_CATEGORY_RING,ITEM_SOUND_ACTION_EQUIP )
   d(DisplayName.." has moved to "..newZone)
  
  end
    
    
    
    
    end
  end
end














EVENT_MANAGER:RegisterForEvent("ESOPager", EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, ESOPager_ZoneAlert )
EVENT_MANAGER:RegisterForEvent("ESOPager", EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, ESOPager_StatusAlert )
EVENT_MANAGER:RegisterForEvent( "ESOPager", EVENT_PLAYER_ACTIVATED, alertAddonLoaded)
EVENT_MANAGER:RegisterForEvent( "ESOPager", EVENT_ADD_ON_LOADED, ESOPager.Initialize)  