-- Excalibur's Movable Inventory settings via LibAddonMenu 2.0
local EMI = ExcalibursMovableInventory or {}
ExcalibursMovableInventory = EMI

function EMI.InitializeSettings()
    local sv = EMI.sv

    local panel = {
        type = "panel",
        name = "Excalibur's Movable Inventory",
        displayName = "|c9f9fdfExcalibur's|r Movable Inventory",
        author = "_Excalibur_1969",
        version = EMI.version,
        registerForRefresh = true,
    }

    local optionsData = {
        [1] = {
            type = "checkbox",
            name = "Enable inventory repositioning",
            tooltip = "MASTER SWITCH. ON = addon moves/drags the vanilla inventory. OFF = inventory fully vanilla.",
            getFunc = function() return sv.movePanel end,
            setFunc = function(v) EMI.SetMovePanel(v) end,
            default = true,
        },
        [2] = {
            type = "dropdown",
            name = "Inventory Position",
            tooltip = "Preset position.",
            choices = { "center", "left", "right" },
            getFunc = function()
                if sv.offsetX < -100 then return "left"
                elseif sv.offsetX > 100 then return "right"
                else return "center" end
            end,
            setFunc = function(value)
                local halfW = GuiRoot:GetWidth() / 2
                if value == "left" then sv.offsetX = -halfW / 2
                elseif value == "right" then sv.offsetX = halfW / 2
                else sv.offsetX = 0 end
                sv.offsetY = 0
                EMI.ApplyPosition()
            end,
            default = "center",
        },
        [3] = { type = "slider", name = "Horizontal Offset", min = -800, max = 800, step = 5, getFunc = function() return sv.offsetX end, setFunc = function(v) sv.offsetX = v; EMI.ApplyPosition() end, default = 0 },
        [4] = { type = "slider", name = "Vertical Offset", min = -500, max = 500, step = 5, getFunc = function() return sv.offsetY end, setFunc = function(v) sv.offsetY = v; EMI.ApplyPosition() end, default = 0 },
        [5] = { type = "checkbox", name = "Show panel backdrop", tooltip = "OFF = hide dark panel art. ON = keep vanilla background.", getFunc = function() return sv.showBackdrop end, setFunc = function(v) sv.showBackdrop = v; EMI.ApplyPosition() end, default = false },
        [6] = { type = "checkbox", name = "Show tab icons (Items / Craft Bag / Junk)", tooltip = "Show the floating tab icon row above the panel.", getFunc = function() return sv.showMenuBar end, setFunc = function(v) sv.showMenuBar = v end, default = false },
        [7] = { type = "button", name = "Reset to Center", func = function() sv.offsetX, sv.offsetY = EMI.defaults.offsetX, EMI.defaults.offsetY; EMI.ApplyPosition() end },
    }

    LibAddonMenu2:RegisterAddonPanel("ExcalibursMovableInventoryPanel", panel)
    LibAddonMenu2:RegisterOptionControls("ExcalibursMovableInventoryPanel", optionsData)
end
