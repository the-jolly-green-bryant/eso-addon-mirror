


function ESOPager_CreateSettingsMenu()




local panelData = {
       type = "panel",
       name = "ESOPager",
       displayName = "|cFFFF00ESO|rPager",
       author = "|cFF0000Minceraft|r",
       version = "1.0",
       registerForRefresh = true,
       registerForDefaults = true,
       slashCommand = "/ep",     
       resetFunc = function() d("Defaults Reset") end,
                     };
       
       
local optionsTable = {
       
      
        [1] = {
           type = "description",
          
           text = "Control which information you would like\n to be notified of in your chat box!",
           width = "full", --or "half" (optional)
           reference = "ESOPagerDescription"  --(optional) unique global reference to control
               },
        [2] = {     
           type = "texture",
           image = "esoui/art/miscellaneous/horizontaldivider.dds",
           imageWidth = 720,  
           imageHeight = 5, 
            width = "full", 
              },     
       
        [3] = { 
            type = "submenu",
            name = "   |cFFFF00Selected Guildies|r ",
            controls = {
            
               
               [1] = {
                type = "description",
                text = "Must be an |cFFFF00@Name|r and a member of one of your |c00FF00Guilds|r !!",
                width = "full", --or "half" (optional)
                reference = "ESOPagerNameDescription"  --(optional) unique global reference to control
                     },
               
               
               
               
               
            
               [2] = {
                type = "editbox",
                name = "  Guildie 1",
                tooltip = "@Name #1 to add to notifications.",
                getFunc = function() return ESOPager.settings.TrackingNames.name1 end, 
                setFunc = function(text) ESOPager.settings.TrackingNames.name1 = text end,      
                isMultiline = false,
                width = "half",
                default = "",
                                       
                reference = "Name1ToAnnounce"
             
               
             
                     },
               
               [3] = {
                type = "button",
                name = "Jump",
                func = function() Jumper1() end, 
                --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                width = "half",
                reference = "JumperNum1"

                 
  
               
               },
               
               [4] = {
                type = "editbox",
                name = "  Guildie 2",
                tooltip = "@Name #2 to add to notifications",
                getFunc = function() return ESOPager.settings.TrackingNames.name2 end, 
                setFunc = function(text) ESOPager.settings.TrackingNames.name2 = text end,      
                isMultiline = false,
                width = "half",
                default = "",
                                        
                reference = "@Name2ToAnnounce"
             
             
             
                     },
               
               [5] = {
                type = "button",
                name = "Jump",
                func = function() Jumper2() end, 
                --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                width = "half",
                reference = "JumperNum2"
               
               
               
                },
               
               
               
               
               
               [6] = {
                type = "editbox",
                name = "  Guildie 3",
                tooltip = "@Name #3 to add to notifications",
                getFunc = function() return ESOPager.settings.TrackingNames.name3 end, 
                setFunc = function(text) ESOPager.settings.TrackingNames.name3 = text end,      
                isMultiline = false,
                width = "half",
                default = "",
                                        
                reference = "@Name3ToAnnounce"
             
             
             
                     },
               [7] = {
                type = "button",
                name = "Jump",
                func = function() Jumper3() end, 
                --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                width = "half",
                reference = "JumperNum3"
               
               
               
                },
               
               
               [8] = {
                type = "editbox",
                name = "  Guildie 4",
                tooltip = "@Name #4 to add to notifications",
                getFunc = function() return ESOPager.settings.TrackingNames.name4 end, 
                setFunc = function(text) ESOPager.settings.TrackingNames.name4 = text end,      
                isMultiline = false,
                width = "half",
                default = "",
                                      
                reference = "@Name4ToAnnounce"
             
             
             
                     },
            
                       
               [9] = {
                type = "button",
                name = "Jump",
                func = function() Jumper4() end, 
                --disabled = function() return db.someBooleanSetting end, --or boolean (optional)
                width = "half",
                reference = "JumperNum4"
               
               
               
                },       
                       
                       
                       
                       
                       
                       
                       
                       
                        }
                          },
              
         
               [4] = { 
                type = "submenu",
                name = "   |cFF0000Tracking|r",
                controls = {
            
                 [1] = {
                  type = "checkbox",
                  name = "   |cFF0000Status|r Tracking",
                  tooltip = "Enables tracking of chosen Guildies And Friends Online Status.",
                  getFunc = function()  return ESOPager.settings.StatusTracking  end,
                  setFunc = function(val)  ESOPager.settings.StatusTracking = val
                                          
                                                                                 end,
                  width = "half",
                  default = ( ESOPager.settings.StatusTrackingDefault)   
                                            },
            
                 [2] = {
                  type = "checkbox",
                  name = " |cFF0000Zone|r Tracking",
                  tooltip = "Enables tracking for Zone Changes of chosen Guildies And Friends.",
                  getFunc = function()  return ESOPager.settings.ZoneTracking  end,
                  setFunc = function(val)  ESOPager.settings.ZoneTracking = val
                                          
                                                                                 end,
                  width = "half",
                  default = (ESOPager.settings.ZoneTrackingDefault)   
                                            },
            
            
            
            
            
            
            
                        }
                          },
                [5] = { 
                      type = "submenu",
                      name = "   |c0000FFTransit|r ",
                      controls = {
                      
                      [1] = {
                        type = "editbox",
                        name = " Home ",
                        tooltip = "This Sets Your |cFF0000Home|r Button Jump Location ",
                        getFunc = function() return ESOPager.settings.TransitHubs.Home end, 
                        setFunc = function(text) ESOPager.settings.TransitHubs.Home = text end,      
                        isMultiline = false,
                        width = "half",
                        default = "",
                                      
                        reference = "HomeLocation"
                      
                      
                      
                      
                      
                             }
                      
                           }
                      
                      
                      
                      }
            






}       

local LAM2 = LibStub("LibAddonMenu-2.0")
      LAM2:RegisterAddonPanel("ESOPagerOptions", panelData)  
      LAM2:RegisterOptionControls("ESOPagerOptions", optionsTable)
      
      
      
      
      
      
end      