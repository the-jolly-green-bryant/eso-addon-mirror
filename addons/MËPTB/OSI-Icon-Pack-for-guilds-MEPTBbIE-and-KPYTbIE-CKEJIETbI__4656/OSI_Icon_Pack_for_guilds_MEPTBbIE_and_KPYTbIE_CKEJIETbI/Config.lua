local function OnPlayerActivated(eventCode)
    if OSI and OSI.AddUniqueIconPack then
        local myIcons = {
            ["@BOCKPECJIA"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/nick.dds",
            ["@AlextRaszaa"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/AlextRaszaa.dds",
            ["@IngridBright"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/ingrid.dds",
            ["@MEPTBA"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/lusha.dds",
            ["@kpopklop"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/klop.dds",
            ["@MËPTB"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/meptb.dds",
			["@MEPTß"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/kiragog.dds",
			["@LaVey1966"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/LaVey.dds",
			["@GrafP2142"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/Graf.dds",
			["@Sheogar92"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/Sheogar.dds",
			["@TJIEHOCOC"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/raskumar.dds",
			["@CKEJIET"] = "OSI_Icon_Pack_for_guilds_MEPTBbIE_and_KPYTbIE_CKEJIETbI/icons/CKEJIET.dds",
			
        }
        
        OSI.AddUniqueIconPack(myIcons)
    end
    
    EVENT_MANAGER:UnregisterForEvent("OSI_MyConfig", EVENT_PLAYER_ACTIVATED)
end

EVENT_MANAGER:RegisterForEvent("OSI_MyConfig", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)