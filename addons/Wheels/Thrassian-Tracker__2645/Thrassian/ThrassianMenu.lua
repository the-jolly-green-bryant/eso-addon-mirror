Thrassian = Thrassian or { }
local t = Thrassian

function t.buildMenu()
	local LAM = LibAddonMenu2
	local lockUI = true

	local panelData = {
		type = "panel",
		name = t.name,
		displayName = "|cff8000T|rhrassian",
		author = "|cc2ff19Wheels|r",
		version = ""..t.version,
	}

	LAM:RegisterAddonPanel(t.name.."GeneralOptions", panelData)

	local generalOptions = {
		{
			type = "divider",
		},
		{
			type = "header",
			name = "General Display Options",
		},
		{
			type = "checkbox",
			name = "Lock Frame",
			tooltip = "Unlock to position frames in desired location",
			getFunc = function() return lockUI end,
			setFunc = function(value)
				if value then
					if t.checkEquipped() then
						t.UI.setDisplay(value)
					else
						t.UI.frame:SetHidden(true)
					end
					t.UI.frame:SetMouseEnabled(false)
					t.UI.frame:SetMovable(false)
				else
					t.UI.setDisplay(value, false)
					t.UI.frame:SetHidden(false)
					t.UI.frame:SetMouseEnabled(true)
					t.UI.frame:SetMovable(true)
				end
				lockUI = value
			end,
		},
		{
			type = "checkbox",
			name = "Show Group Stacks",
			tooltip = "Display the amount of Thrassian stacks group members have in the HodorReflexes damage share frame",
			disabled = HodorReflexes == nil,
			warning = "HodorReflexes must be installed to activate this",
			getFunc = function() return t.savedVars.groupStacks end,
			setFunc = function(value) t.savedVars.groupStacks = value end,
		},
	}

	LAM:RegisterOptionControls(t.name.."GeneralOptions", generalOptions)
end

