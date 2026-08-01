AUI_KRPatch = {
    name = "AUI_KRPatch",
    univers57KR = "EsoKR/fonts/univers57.otf",
    univers67KR = "EsoKR/fonts/univers67.otf",
    version = 1.02
}

function AUI.Menu.GetFontTypeList() -- modify dropdown options to include KRFont
	local fontTypeList = 
	{
		[0] = {["EsoUI/Common/Fonts/univers55.otf"]							= "Univers 55"},
		[1] = {["EsoUI/Common/Fonts/univers57.otf"]							= "Univers 57"},
		[2] = {["EsoUI/Common/Fonts/univers67.otf"]							= "Univers 67"},
		[3] = {["EsoUI/Common/Fonts/ProseAntiquePSMT.otf"]					= "ProseAntique"},
		[4] = {["EsoUI/Common/Fonts/consola.ttf"]							= "Consolas"},
		[5] = {["EsoUI/Common/Fonts/FTN57.otf"]								= "Futura Condensed"},
		[6] = {["EsoUI/Common/Fonts/FTN87.otf"]								= "EsoUI/Common/Fonts/FTN87.otf"},
		[7] = {["EsoUI/Common/Fonts/FTN47.otf"]								= "Futura Condensed Light"},
		[8] = {["EsoUI/Common/Fonts/FTN47.otf"]								= "Skyrim Handwritten"},
		[9] = {["EsoUI/Common/Fonts/trajanpro-regular.otf"]					= "Trajan Pro"},
		[10] = {["AUI/fonts/Kingthings_Calligraphica_2.ttf"]				= "Calligraphica"},
		[11] = {["AUI/fonts/Almendra-Bold.otf"]								= "Almendra"},
		[12] = {["AUI/fonts/SansitaOne.ttf"]								= "Sansita One"},
	    [13] = {["AUI/fonts/Bellota-Bold.otf"]								= "Bellota"},
		[14] = {["esoui/common/fonts/eso_fwudc_70-m.ttf"]					= "ESO-FWUDC_70 M"},
		[15] = {["esoui/common/fonts/eso_fwntlgudc70-db.ttf"]				= "ESO-FWNTLGUDC70 DB"},
		[16] = {["EsoKR/fonts/univers55.otf"]				                    = "Univers 55 KR"},
		[17] = {["EsoKR/fonts/univers57.otf"]				= "Univers 57 KR"},
		[18] = {["EsoKR/fonts/univers67.otf"]				= "Univers 67 KR"},
		[19] = {["EsoKR/fonts/proseantiquepsmt.otf"]				= "ProseAntique KR"},
		[20] = {["EsoKR/fonts/handwritten_bold.otf"]				= "Handwritten KR"},
		[21] = {["EsoKR/fonts/trajanpro-regular.otf"]				= "Trajan Pro KR"},
		[22] = {["EsoKR/fonts/ftn47.otf"]				= "Futura Condensed 47 KR"},
		[23] = {["EsoKR/fonts/ftn57.otf"]				= "Futura Condensed 57 KR"},
		[24] = {["EsoKR/fonts/ftn87.otf"]				= "Futura Condensed 87 KR"},
	}
	
	return fontTypeList
end

AUI_MAIN_AUTHOR = AUI_MAIN_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_MINIMAP_AUTHOR = AUI_MINIMAP_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_ATTRIBUTE_AUTHOR = AUI_ATTRIBUTE_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_COMBAT_AUTHOR = AUI_COMBAT_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_ACTIONBAR_AUTHOR = AUI_ACTIONBAR_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_BUFFS_AUTHOR = AUI_BUFFS_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_QUESTTRACKER_AUTHOR = AUI_QUESTTRACKER_AUTHOR .. " - (KR Patch by @Bihyeon)"
AUI_FRAMEMOVER_AUTHOR = AUI_FRAMEMOVER_AUTHOR .. " - (KR Patch by @Bihyeon)"

function AUI_KRPatch:Init()
    AUI_KRPatch.setMinimapFont(AUI_KRPatch.univers57KR)
    AUI_KRPatch.setQuesttrackerFont(AUI_KRPatch.univers57KR)
    AUI_KRPatch.setCombatFont(AUI_KRPatch.univers67KR, AUI_KRPatch.univers57KR)
    AUI_KRPatch.setMousemenuFont(AUI_KRPatch.univers57KR)
    AUI_KRPatch.setUnitframeFont(AUI_KRPatch.univers57KR)
end

local function OnAddOnLoaded(eventCode, addOnName)
    if addOnName ~= AUI_KRPatch.name or AUI == nil or AUI.UnitFrames == nil or AUI.Combat == nil or AUI.Minimap == nil or AUI.Questtracker == nil or AUI_MouseMenu == nil then
        return
    end

    AUI_KRPatch:Init()
end

EVENT_MANAGER:RegisterForEvent(AUI_KRPatch.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)