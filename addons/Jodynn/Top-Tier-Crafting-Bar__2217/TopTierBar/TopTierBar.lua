local LAM = LibAddonMenu2

-- Addon Info {{{
TopTier = {}
local TopTier = TopTier

TopTier.name = "TopTierBar"
TopTier.version = 0.5
TopTier.displayName = "|c00ffffTop Tier Crafting Bar|r"
TopTier.settingsPanel = nil
TopTier.ready = false
-- }}}

-- Saved Vars {{{
TopTier.Defaults = {}
TopTier.Defaults.log = false
TopTier.Defaults.warningAmount = 500

TopTier.Defaults.ui = {
    ["iconSize"] = 25,
    ["offsetY"]  = 0,
    ["offsetX"]  = 0,
    ["point"]    = CENTER,
    ["relPoint"] = CENTER,
    ["show"]     = true,
    ["alpha"]    = 0.3,
    ["showRaw"]  = false,
    ["showHud"]  = true,
    ["showCrafting"]  = true,
}
--}}}

-- Structures {{{

TopTier.hide = false

TopTier.slots = { 64502, 64504, 64506, 64489, 135146 }
TopTier.rawSlots = { 71199, 71200, 71239, 71198, 135145 }

TopTier.slotNames = { "Wood", "Cloth", "Leather", "Metal", "Jewel" }
TopTier.rawSlotNames = { "RawWood", "RawCloth", "RawLeather", "RawMetal", "RawJewel" }

TopTier.slotUis = {
    TopTierWindowWood,
    TopTierWindowCloth,
    TopTierWindowLeather,
    TopTierWindowMetal,
    TopTierWindowJewel,
}

TopTier.rawSlotUis = {
    TopTierWindowRawWood,
    TopTierWindowRawCloth,
    TopTierWindowRawLeather,
    TopTierWindowRawMetal,
    TopTierWindowRawJewel,
}

TopTier.slotIcons = {
    TopTierWindowWoodIcon,
    TopTierWindowClothIcon,
    TopTierWindowLeatherIcon,
    TopTierWindowMetalIcon,
    TopTierWindowJewelIcon,
}

TopTier.rawSlotIcons = {
    TopTierWindowRawWoodIcon,
    TopTierWindowRawClothIcon,
    TopTierWindowRawLeatherIcon,
    TopTierWindowRawMetalIcon,
    TopTierWindowRawJewelIcon,
}

TopTier.slotTexts = {
    TopTierWindowWoodText,
    TopTierWindowClothText,
    TopTierWindowLeatherText,
    TopTierWindowMetalText,
    TopTierWindowJewelText,
}

TopTier.rawSlotTexts = {
    TopTierWindowRawWoodText,
    TopTierWindowRawClothText,
    TopTierWindowRawLeatherText,
    TopTierWindowRawMetalText,
    TopTierWindowRawJewelText,
}

--}}}

-- 'HELP' -- {{{
function TopTier:GetItemText(bagId, slotId)
    local itemLink   = GetItemLink(bagId, slotId, LINK_STYLE_BRACKETS)
    local icon, _, _, _, _, _, _, _ = GetItemInfo(bagId, slotId)

    return "|t20:20:" .. icon .. "|t " .. itemLink
end

function TopTier:LogThis(message, error)
    if not TopTier.sv.log then return end

    function getMessage(str)
        local color = "99ff99"

        if error then
            color = "ff9999"
        end

        return "|t20:20:esoui/art/buttons/info_over.dds|t|c" .. tostring(color) .. tostring(str) .. "|r"
    end

    d ( getMessage(message ) )
end

function TopTier:ShowThis(control, link)
    control:SetHidden(false)
    -- control:SetDimensions(TopTier.sv.ui.iconSize * 2, TopTier.sv.ui.iconSize * 2)
    if link then
        control:SetHandler("OnMouseEnter", function (self)
            -- d ( "MouseEnter " .. control:GetName() )
            self.itemtool = ItemTooltip
            InitializeTooltip(self.itemtool, control, TOPLEFT, 0, 0, BOTTOMRIGHT)
            itemtool:SetLink(link)
        end)

        control:SetHandler("OnMouseExit", function (self)
            -- d ( "MouseExit " .. control:GetName() )
            if self.itemtool then
                ClearTooltip(self.itemtool)
            end
        end)
    end
end

function TopTier:HideThis(control)
    control:SetHidden(true)
    -- control:SetDimensions(0,0)
end

function TopTier:GetTextColor(curC, maxC, icon, itemLink, dee)
    local g = 0
    local r = 0

    if curC / maxC >= 1.5 then
        g = 255
        r = 2.0 - (curC / maxC)
        r = 510 * r
    else
        r = 255
        g = 255 - 510 * (1.5 - curC/maxC)
        local message = "You are running low on : |t20:20:" .. icon .. "|t " .. itemLink
        TopTier:LogThis(message, true)
    end

    if r < 0 then r = 0 end
    if g < 0 then g = 0 end

    r = math.min(255, r)
    g = math.min(255, g)

    r = string.format("%x", r )

    if string.len(r) < 2 then
        r = "0" .. r
    end

    g = string.format("%x", g )

    if string.len(g) < 2 then
        g = "0" .. g
    end

    local color =  r .. g  .. "00"
    if dee then
        d ( " :: |c" .. color .. " " .. color  .. "|r")
    end
    return color
end

function TopTier:Stackify(arr, count)
    local icon, stack, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, arr[1])

    for i=2, count do
        local i, s, _, _, _, _, _, _ = GetItemInfo(BAG_BACKPACK, arr[i])
        stack = s + stack
    end

    return icon, stack
end

function TopTier:ParseBag(mark) -- {{{
    if not ( mark or TopTier.isDirty ) then return end

    -- d ( "Parse Bag " )
    function LoopOver(slots, uis, icons, texts, warningAmount)
        for i, slotId in ipairs(slots) do
            local id = GetItemId(BAG_VIRTUAL, slotId)
            local name = GetItemName(BAG_VIRTUAL, slotId)

            -- d ( id .. " : : " .. name )

            local type = GetItemType(BAG_VIRTUAL, slotId)
            local link = GetItemLink(BAG_VIRTUAL, slotId, LINK_STYLE_DEFAULT)
            local icon, _, _, _, _, _, _, _ = GetItemInfo(BAG_VIRTUAL, slotId)
            local stack, maxStack = GetSlotStackSize(BAG_VIRTUAL, slotId)

            TopTier:ShowThis(uis[i], link)
            icons[i]:SetTexture(icon)
            texts[i]:SetText("|c"..TopTier:GetTextColor(stack, warningAmount, icon, link) .. stack .."|r")
        end
    end

    LoopOver(TopTier.slots, TopTier.slotUis, TopTier.slotIcons, TopTier.slotTexts, TopTier.sv.warningAmount);

    if TopTier.sv.showRaw then
        LoopOver(TopTier.rawSlots, TopTier.rawSlotUis, TopTier.rawSlotIcons, TopTier.rawSlotTexts, 0);
    end

    TopTier.isDirty = false
end -- }}}
-- }}}


-- 'UI'

function TopTier:UpdateUI(updateIconSize) -- {{{
    function handleChildren(parent)
        for i=1, parent:GetNumChildren() do
            local child = parent:GetChild(i)
            local x,y = child:GetDimensions()
            if x ~= 0 and y ~= 0 then
                child:SetDimensions(TopTier.sv.ui.iconSize * 2, TopTier.sv.ui.iconSize )

                for v=1, child:GetNumChildren() do
                    local grandchild = child:GetChild(v)
                    if grandchild.SetFont then
                        grandchild:SetDimensions(TopTier.sv.ui.iconSize * 2, TopTier.sv.ui.iconSize)
                        if TopTier.sv.ui.iconSize < 20 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_12)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize < 25 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize < 30 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_16)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize < 35 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_18)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize < 40 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_20)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize < 50 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_22)|soft-shadow-thin")
                        elseif TopTier.sv.ui.iconSize == 50 then
                            grandchild:SetFont("$(MEDIUM_FONT)|$(KB_24)|soft-shadow-thin")
                        end
                    else
                        grandchild:SetDimensions(TopTier.sv.ui.iconSize , TopTier.sv.ui.iconSize)
                    end
                end
            elseif i ~= 1 and i < 6 then
                local valid, point, _, relPoint, offsetX, offsetY = child:GetAnchor(0)
                child:SetAnchor(point, parent, relPoint, iconSize / 2, 0)
            end
        end
    end

    if updateIconSize ~= nil then
        handleChildren(TopTierWindow)
    end

    TopTierWindow:SetHidden(TopTier.hide or not TopTier.sv.ui.show)

    local totalSize = 0
    local Y = TopTier.sv.ui.iconSize * 1.3

    if TopTier.sv.showRaw then
        Y = 2 * Y
    end

    for _, x in ipairs(TopTier.rawSlotUis) do
        x:SetHidden(not TopTier.sv.showRaw)
    end

    if TopTier.sv.ui.show then
        local size = TopTier.sv.ui.iconSize * 6 * 2 * math.min(1.15, math.max(1, 23.0 / TopTier.sv.ui.iconSize))
        TopTierWindow:SetDimensions(size, Y)
        totalSize = totalSize + size
    else
        TopTierWindow:SetDimensions(0,0)
    end

    if TopTier.sv.ui.show then
        TopTierWindow:SetMovable(true)
        TopTierWindow:SetAlpha(1)
        TopTierWindow:SetAnchor(TopTier.sv.ui.point, GuiRoot, TopTier.sv.ui.relPoint, TopTier.sv.ui.offsetX, TopTier.sv.ui.offsetY)
        TopTierWindow:SetCenterColor(0,0,0,TopTier.sv.ui.alpha)
        TopTierWindow:SetEdgeColor(0,0,0,TopTier.sv.ui.alpha)

        TopTierWindow:SetHandler("OnMoveStop", function (self)
            local valid, point, _, relPoint, offsetX, offsetY = self:GetAnchor(0)
            if valid then
                TopTier.sv.ui.point = point
                TopTier.sv.ui.relPoint = relPoint
                TopTier.sv.ui.offsetX = offsetX
                TopTier.sv.ui.offsetY = offsetY
            end
            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end)

        TopTierWindow:SetHandler("OnMouseEnter", function (self)
            self:SetCenterColor(0,1,1,0.3)
            self:SetEdgeColor(0,1,1,0.4)

            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
        end)

        TopTierWindow:SetHandler("OnMouseExit", function (self)
            self:SetCenterColor(0,0,0,TopTier.sv.ui.alpha)
            self:SetEdgeColor(0,0,0,TopTier.sv.ui.alpha)

            WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
        end)
    end

    -- d ( "Update UI" )
end -- }}}

function TopTier:CreateSettingsWindow() -- {{{
    local settingsWindowData = {
        type = "panel",
        name = TopTier.displayName,
        author = "|cff00ffJodynn|r",
        version = TopTier.version .. "",
        registerForRefresh = true,
        registerForDefaults = true,
        slashCommand = "/toptiersettings"
    }

    local settingsOptionsData = {
        -- submenu
        {
            type = "header",
            name = "UI",
        },

        {
            type = "checkbox",
            name = "Show Resources HUD",
            default = TopTier.Defaults.ui.show,
            getFunc = function() return TopTier.sv.ui.show end,
            setFunc = function(newValue) TopTier.sv.ui.show = newValue; TopTier.hide = false; TopTier:UpdateUI() end,
        },

        {
            type = "slider",
            name = "HUD Alpha",
            min = 0,
            max = 100,
            step = 1,
            default = TopTier.Defaults.ui.alpha,
            getFunc = function() return TopTier.sv.ui.alpha * 100 end,
            setFunc = function(newValue) TopTier.sv.ui.alpha = newValue / 100; TopTier.hide = false ; TopTier:UpdateUI() end,
        },

        {
            type = "checkbox",
            name = "Show Raw Mats",
            tooltip = "Show the raw materials below the actual mats.",
            default = TopTier.Defaults.showRaw,
            getFunc = function() return TopTier.sv.showRaw end,
            setFunc = function(newValue) TopTier.sv.showRaw = newValue; TopTier.isDirty=true; TopTier:ParseBag(); TopTier:UpdateUI(1) end,
        },

        {
            type = "slider",
            name = "Icon Size",
            min = 15,
            max = 50,
            step = 1,
            default = TopTier.Defaults.ui.iconSize,
            getFunc = function() return TopTier.sv.ui.iconSize end,
            setFunc = function(newValue) TopTier.sv.ui.iconSize = newValue; TopTier.hide = false; TopTier:UpdateUI(1) end,
        },

        {
            type = "slider",
            name = "Warning Amount",
            tooltip = "It will change the text color based on how close you get to it. It will begin warning you if logging is turned on if it reaches warningAmount * 1.5.",
            min = 0,
            max = 5000,
            step = 50,
            default = TopTier.Defaults.warningAmount,
            getFunc = function() return TopTier.sv.warningAmount end,
            setFunc = function(newValue) TopTier.sv.warningAmount = newValue; TopTier.hide = false; TopTier.isDirty=true; TopTier:ParseBag(); TopTier:UpdateUI(1) end,
        },

        -- submenu
        {
            type = "header",
            name = "Scenes",
        },

        {
            type = "checkbox",
            name = "HUD ( Walking around )",
            default = TopTier.Defaults.ui.showHud,
            getFunc = function() return TopTier.sv.ui.showHud end,
            setFunc = function(newValue)
                TopTier.sv.ui.showHud = newValue
                TopTier.hide = not newValue
                TopTier:UpdateUI()
            end,
        },

        {
            type = "checkbox",
            name = "Crafting",
            default = TopTier.Defaults.ui.showCrafting,
            getFunc = function() return TopTier.sv.ui.showCrafting end,
            setFunc = function(newValue) TopTier.sv.ui.showCrafting = newValue; end,
        },

        -- submenu
        {
            type = "header",
            name = "Log",
        },

        {
            type = "checkbox",
            name = "Log Messages",
            tooltip = "Log messages of what happens, in a pretty format.",
            default = TopTier.Defaults.log,
            getFunc = function() return TopTier.sv.log end,
            setFunc = function(newValue) TopTier.sv.log = newValue end,
        },


    }

    TopTier.settingsPanel = LAM:RegisterAddonPanel(TopTier.name.."_LAM", settingsWindowData)
    LAM:RegisterOptionControls(TopTier.name.."_LAM", settingsOptionsData)
end -- }}}

function TopTier:Init() -- {{{
    TopTier.sv = ZO_SavedVars:NewAccountWide("TopTier_sv", 1, nil, TopTier.Defaults)

    local scenes= { "hud", "hudui", "gamepad_smithing_root", "smithing" }

    for _, scene in ipairs(scenes) do
        local sceneObj = SCENE_MANAGER:GetScene(scene)

        sceneObj:RegisterCallback("StateChange", function(oldState, newState)
            -- d ( scene .. " :: " .. tostring(oldState) .. " -> " .. tostring(newState) )
            TopTier.hide = not ( newState and ( newState == "showing" or newState == "shown" ) )
            TopTier.hide = TopTier.hide or ( ( ( scene == "hud" or scene == "hudui" ) and not TopTier.sv.ui.showHud ) or ( ( scene == "gamepad_smithing_root" or scene == "smithing") and not TopTier.sv.ui.showCrafting ) )
            TopTier:UpdateUI()
        end)
    end
end -- }}}


-- ' EVENTS '
EVENT_MANAGER:RegisterForEvent(TopTier.name, EVENT_ADD_ON_LOADED, function (event, addonName) -- {{{
    if addonName == TopTier.name then
        TopTier:Init()
        EVENT_MANAGER:UnregisterForEvent(TopTier.name, EVENT_ADD_ON_LOADED)
    end
end) -- }}}

EVENT_MANAGER:RegisterForEvent(TopTier.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange) -- {{{
    if not TopTier.ready then return end
    TopTier.isDirty = true

    local isTopTier = false
    for _, x in ipairs(TopTier.slots) do
        if x == slotId then
            isTopTier = true
            break
        end
    end

    if isTopTier then
        if inventoryUpdateReason == INVENTORY_UPDATE_REASON_DEFAULT then
            if bagId == BAG_VIRTUAL then
                TopTier:ParseBag()
            end
        end
    end

end) -- }}}

EVENT_MANAGER:RegisterForEvent(TopTier.name, EVENT_PLAYER_ACTIVATED , function(eventCode, initial) -- {{{
    TopTier.isDirty = true

    TopTier:ParseBag()

    if TopTier.settingsPanel then
        -- d()
    else
        TopTier:CreateSettingsWindow()
    end

    TopTier:UpdateUI(1)

    TopTier.ready = true
end) -- }}}
