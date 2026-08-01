local addonName = "AUI"
	
local function GetTemplateData()	
	local templateData = 
	{
		[AUI_BUFF_TYPE_PLAYER] = 
		{
			["name"] = "Tactical_Player_Buff_Control",		
		},
		[AUI_DEBUFF_TYPE_PLAYER] = 
		{
			["name"] = "Tactical_Player_Debuff_Control",		
		},		
		[AUI_BUFF_TYPE_TARGET] = 
		{
			["name"] = "Tactical_Target_Buff_Control",				
		},		
		[AUI_DEBUFF_TYPE_TARGET] = 
		{
			["name"] = "Tactical_Target_Debuff_Control",			
		},		
	}
	
	return templateData
end

local function OnLoad(p_eventCode, p_addOnName)
	if p_addOnName ~= addonName then
        return
    end	

	if AUI then
		AUI.Buffs.AddTemplate("AUI Tactical", "AUI_Tactical", 1, GetTemplateData())
	end	

	EVENT_MANAGER:UnregisterForEvent(addonName .. "_AUI_BUFFS_TACTICAL_DESIGN", EVENT_ADD_ON_LOADED)	
end

EVENT_MANAGER:RegisterForEvent(addonName .. "_AUI_BUFFS_TACTICAL_DESIGN", EVENT_ADD_ON_LOADED, OnLoad)
