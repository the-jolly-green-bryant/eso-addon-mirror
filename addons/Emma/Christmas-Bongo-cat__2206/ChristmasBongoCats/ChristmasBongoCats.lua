-------------------------------------
-- Addon data.
-------------------------------------
ChristmasBongoCats = ChristmasBongoCats or {}
ChristmasBongoCats.version = 1
ChristmasBongoCats.variableVersion = 2
ChristmasBongoCats.Default = {
	Left = 20,
	Top = 20,
	}
ChristmasBongoCats.name = "ChristmasBongoCats"
ChristmasBongoCats.frameDurationMs = 300


-------------------------------------
-- Initialize the addon.
-------------------------------------
function ChristmasBongoCats.OnAddOnLoaded(event, addonName)
    if addonName == ChristmasBongoCats.name then
        ChristmasBongoCats:Initialize()

		
        EVENT_MANAGER:UnregisterForEvent(ChristmasBongoCats.name, EVENT_ADD_ON_LOADED)
    end
end

-------------------------------------
-- Save the position for the Bongo Cat.
------------------------------------
function ChristmasBongoCats.SavePosition()
    ChristmasBongoCats.savedVariables.Left = ChristmasBongoCatsWindow:GetLeft()
    ChristmasBongoCats.savedVariables.Top = ChristmasBongoCatsWindow:GetTop()
end

-------------------------------------
-- Load saved variables and register the event listeners.
-------------------------------------
function ChristmasBongoCats:Initialize()
ChristmasBongoCats.savedVariables = ZO_SavedVars:NewAccountWide("ChristmasBongoCatsVars", ChristmasBongoCats.variableVersion, nil, ChristmasBongoCats.Default)
ChristmasBongoCatsWindow:ClearAnchors()
		ChristmasBongoCatsWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ChristmasBongoCats.savedVariables.Left, ChristmasBongoCats.savedVariables.Top)
      
    ChristmasBongoCats.currentFrame = 0

    EVENT_MANAGER:RegisterForUpdate("ChristmasBongoCatsLoop", ChristmasBongoCats.frameDurationMs,
        function()
            ChristmasBongoCatsWindow:GetNamedChild('Img' .. tostring(ChristmasBongoCats.currentFrame)):SetHidden(true)
            ChristmasBongoCats.currentFrame = (ChristmasBongoCats.currentFrame + 1) % 4
            ChristmasBongoCatsWindow:GetNamedChild('Img' .. tostring(ChristmasBongoCats.currentFrame)):SetHidden(false)
        end)
end



-------------------------------------
-- Initialization Register.
------------------------------------
EVENT_MANAGER:RegisterForEvent(ChristmasBongoCats.name, EVENT_ADD_ON_LOADED, ChristmasBongoCats.OnAddOnLoaded)