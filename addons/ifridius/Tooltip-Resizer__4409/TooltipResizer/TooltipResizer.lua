local ADDON_NAME = "TooltipResizer"

-- Defaults (loaded into SV)
local defaults = {
    minWidth = 800,     -- Width (higher = wider, e.g. 650)
    maxHeight = -1,     -- Height (-1=unlimited/fix for addons like Inventory Insight)
    scale = 0.80        -- Overall size (lower = smaller, e.g. 0.88)
}

local SV           -- Saved vars (set in OnAddOnLoaded)
local tooltips = { -- All relevant tooltips
    ItemTooltip,
    PopupTooltip,
    ComparativeTooltip1,
    ComparativeTooltip2
}

local function ResizeTooltips()
    if not SV then return end
    local minW = SV.minWidth
    local maxH = SV.maxHeight
    local s    = SV.scale
    
    for _, tt in pairs(tooltips) do
        if tt then
            tt:SetDimensionConstraints(minW, 0, minW, maxH)
            tt:SetScale(s)
        end
    end
    d(string.format("|c00FF00%s|r: minW=%d | maxH=%d | scale=%.2f", ADDON_NAME, minW, maxH, s))
end

local function OnAddOnLoaded(event, name)
    if name ~= ADDON_NAME then return end
    
    -- Load saved vars (account-wide, auto-defaults)
    SV = ZO_SavedVars:NewAccountWide("TooltipResizerSavedVariables", 1, nil, defaults)
    
    -- Delay resize for full UI load
    zo_callLater(ResizeTooltips, 1000)
    
    -- LibAddonMenu setup
    local LAM = LibAddonMenu2
    if LAM then
        local panelName = "TooltipResizerPanel"
        local panelData = {
            type = "panel",
            name = "Tooltip Resizer",
            displayName = "Tooltip Resizer Settings\n|cC0C0C0Live changes apply instantly|r",
            author = "DanScallion",
            version = "2.2",
            slashCommand = "/tooltipresizer"
        }
        LAM:RegisterAddonPanel(panelName, panelData)
        
		local optionsData = {
			{
				type = "header",
				name = "Tooltip Dimensions & Scale"
			},
			{
				type = "description",
				text = "|cCCCCCCDrag sliders while hovering an item tooltip for live preview!|r"
			},
			{
				type = "slider",
				name = "Width (min/max)",
				tooltip = "Makes tooltips wider (less text wrapping). |cFFFF00Vanilla ~400px → try 550-700 (+30-75%)|r",
				min = 300, max = 1000, step = 10,
				decimals = 0,  -- Rounds to integer (no .000001)
				getFunc = function() return SV.minWidth end,
				setFunc = function(value)
					SV.minWidth = value
					ResizeTooltips()
				end
			},
			{
				type = "slider",
				name = "Max Height (-1)",
				tooltip = "|cFFFF00-1=unlimited (prevents clipping with Inventory Insight and other addons that add to tooltip.)|r\nTry 600-900 for shorter tooltips.",
				min = -1, max = 1200, step = 50,
				decimals = 0,  -- Integer only
				getFunc = function() return SV.maxHeight end,
				setFunc = function(value)
					SV.maxHeight = value
					ResizeTooltips()
				end
			},
			{
				type = "slider",
				name = "Scale (Size)",
				tooltip = "Shrinks/grows entire tooltip. |cFFFF000.80=tiny | 0.92=compact | 1.0=vanilla|r",
				min = 0.70, max = 1.20, step = 0.01,
				decimals = 2,  -- Caps at 2 decimals (0.80, not 0.80000111111)
				getFunc = function() return SV.scale end,
				setFunc = function(value)
					SV.scale = value
					ResizeTooltips()
				end
			},
			{
				type = "button",
				name = "|cFFAA00Reset to Defaults|r",
				tooltip = "Restores starting values",
				func = function()
					SV.minWidth  = defaults.minWidth
					SV.maxHeight = defaults.maxHeight
					SV.scale     = defaults.scale
					ResizeTooltips()
					d("|c00FF00TooltipResizer: Reset complete!|r")
				end
			}
		}
        LAM:RegisterOptionControls(panelName, optionsData)
        d("|c00FF00TooltipResizer: Menu loaded (|cFFFF00/tr|r or Esc→AddOns→Tooltip Resizer)|r")
    else
        d("|cFF0000TooltipResizer: |cFFFFFFLibAddonMenu-2.0 missing! Install from ESOUI.|r")
    end
    
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS["/TOOLTIPRESIZER"] = function() 
    local LAM = LibAddonMenu2
    if LAM then LAM.ShowAddonOptions("TooltipResizerPanel") end
end
SLASH_COMMANDS["/TR"] = SLASH_COMMANDS["/TOOLTIPRESIZER"]