AUI.Minimap = {}

local isLoaded = false
AUI_MINIMAP_SCENE_FRAGMENT = nil

function AUI.Minimap.IsLoaded()
	if isLoaded then
		return true
	end
	
	return false
end

function AUI.Minimap.GetVersion()
	return AUI_MINIMAP_VERSION
end

function AUI.Minimap.Show()
	if not AUI.Minimap.IsShow() then
		AUI_MINIMAP_SCENE_FRAGMENT:Show()
	end
end

function AUI.Minimap.Hide()
	if AUI.Minimap.IsShow() then
		AUI_MINIMAP_SCENE_FRAGMENT:Hide()
	end
end

function AUI.Minimap.IsShow()
	return not AUI_Minimap_MainWindow:IsHidden()
end

function AUI.Minimap.Toggle()
	if not isLoaded or not AUI_MINIMAP_SCENE_FRAGMENT.allowToggle then
		return
	end

	if AUI.Minimap.IsShow() then
		AUI.Settings.Minimap.enable = false	
		AUI_MINIMAP_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", true)
		AUI.Minimap.Hide()
	else
		AUI.Settings.Minimap.enable = true	
		AUI_MINIMAP_SCENE_FRAGMENT.hiddenReasons:SetHiddenForReason("ShouldntShow", false)
		AUI.Minimap.Show()
	end
end

function AUI.Minimap.Load()
	if isLoaded then
		return
	end

	isLoaded = true
	
	-- For the default Theme		
	local defaultThemeData = {["Default_Frame"] = true}		
	AUI.Minimap.Theme.AddMinimapTheme("default", AUI.L10n.GetString("default"), defaultThemeData)		
	
	-- Add the default icon theme
	AUI.Minimap.Theme.AddMinimapIconTheme("default", AUI.L10n.GetString("default"), {})	
	
	-- For the Blank Theme		
	local blankThemeData = {["Default_Frame"] = false}		
	AUI.Minimap.Theme.AddMinimapTheme("blank", "Blank", blankThemeData)		
	
	AUI.Minimap.SetMenuData()		

	AUI.Minimap.Pin.Init()
	AUI.Minimap.UI.Init()	
	AUI.Minimap.Map.Init()	
	AUI.WorldMap.Init()	
	
	AUI_MINIMAP_SCENE_FRAGMENT = ZO_SimpleSceneFragment:New(AUI_Minimap_MainWindow)									
	AUI_MINIMAP_SCENE_FRAGMENT.hiddenReasons = ZO_HiddenReasons:New()		
    AUI_MINIMAP_SCENE_FRAGMENT:SetConditional(function()
        return not AUI_MINIMAP_SCENE_FRAGMENT.hiddenReasons:IsHidden()
    end)
	
	AUI_MINIMAP_SCENE_FRAGMENT.allowToggle = true	

	HUD_SCENE:AddFragment(AUI_MINIMAP_SCENE_FRAGMENT)
	HUD_UI_SCENE:AddFragment(AUI_MINIMAP_SCENE_FRAGMENT)
	SIEGE_BAR_SCENE:AddFragment(AUI_MINIMAP_SCENE_FRAGMENT)
	if SIEGE_BAR_UI_SCENE then
		SIEGE_BAR_UI_SCENE:AddFragment(AUI_MINIMAP_SCENE_FRAGMENT)
	end
end