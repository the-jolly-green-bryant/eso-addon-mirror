HideHousePreview = {}
 
HideHousePreview.name = "HideHousePreview"
HideHousePreview.version = "3.0.25"
HideHousePreview.default_vars = { HideHousePreview = true }

local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")

origGetFastTravelNodeInfo = nil

ZO_CreateStringId("SI_BINDING_NAME_MAP_TOGGLE_HOUSES", "Toggle Houses")

local current_house_state

function HideHousePreview:Initialize()
    HideHousePreview.savedVariables = ZO_SavedVars:NewAccountWide("HideHousePreview_SavedVariables", HideHousePreview.version, nil, HideHousePreview.default_vars)

    HideHousePreview.CreateOptionsWindow()

    origGetFastTravelNodeInfo = GetFastTravelNodeInfo

    GetFastTravelNodeInfo = function (node)
        local known, name, x, y, icon, glow, poi_type, current, locked = origGetFastTravelNodeInfo(node)

        if SCENE_MANAGER and SCENE_MANAGER.currentScene and SCENE_MANAGER.currentScene.GetName and SCENE_MANAGER.currentScene:GetName() == "worldMap" and current_house_state ~= nil then
            if poi_type == POI_TYPE_HOUSE then
                if current_house_state == "show_all" then
                    known = true
                elseif current_house_state == "hide_preview" then
                    if not HasCompletedFastTravelNodePOI(node) then
                        known = false
                    end
                elseif current_house_state == "hide_all" then
                    known = false
                end
            end
        else
            if poi_type == POI_TYPE_HOUSE and not HasCompletedFastTravelNodePOI(node) then
                if HideHousePreview.savedVariables.TamrielOnly then
                    if ZO_WorldMap_GetMapTitle() == "Tamriel" then
                        known = false
                    end
                else
                    if HideHousePreview.savedVariables.HideHousePreview then
                        known = false
                    end
                end
            end
        end

        -- Bypass ugly icon issue
        if name:match("Grand Topal") then
            known = false
        end

        return known, name, x, y, icon, glow, poi_type, current, locked
    end

    HideHousePreview.AddKeybind()
end

function get_next_house_state ()
    if current_house_state == "show_all" then
        return "hide_preview"
    elseif current_house_state == "hide_preview" then
        return "hide_all"
    elseif current_house_state == "hide_all" or current_house_state == nil then
        return "show_all"
    end
end

function state_to_label (state)
    if state == nil then
        return ""
    elseif state == "show_all" then
        return ": All Shown"
    elseif state == "hide_preview" then
        return ": Previews Hidden"
    elseif state == "hide_all" then
        return ": All Hidden"
    end
end

-- this is pretty nasty
-- i'm sure there's a better way to do it
local function update_text ()
    local new_text = "Toggle Houses" .. state_to_label(current_house_state)

    local ks = KEYBIND_STRIP.keybinds["MAP_TOGGLE_HOUSES"]

    if ks ~= nil then
        local label = ks:GetNamedChild("NameLabel")

        if label ~= nil then
            label:SetText(new_text)
        end
    end
end

function HideHousePreview.ToggleHouses ()
    -- advance the next state
    current_house_state = get_next_house_state()

    update_text()

    ZO_WorldMap_UpdateMap()
end

function HideHousePreview.AddKeybind()
    local strip = {
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        {
            -- I've never figured out if making name a function results in it being
            -- called every frame/regularly updated or just once. One of these days
            -- I'll test it.
            name = "Toggle Houses" .. state_to_label(current_house_state),
            keybind = "MAP_TOGGLE_HOUSES",
            order = 100,
            callback = HideHousePreview.ToggleHouses,
        },
    }
      
    WORLD_MAP_FRAGMENT:RegisterCallback("StateChange", function (oldState, newState)
        -- This should resolve any issues where the worldmap fragment is being used
        -- outside of the worldmap scene. We only care about showing the buttons in
        -- the world map scene!
        if SCENE_MANAGER.currentScene:GetName() == "worldMap" and not HideHousePreview.savedVariables.HideButton then
            if newState == SCENE_SHOWN then
                KEYBIND_STRIP:AddKeybindButtonGroup(strip)
                update_text()
            elseif newState == SCENE_HIDING then
                KEYBIND_STRIP:RemoveKeybindButtonGroup(strip)
            end
        end
    end)
end
 
function HideHousePreview.CreateOptionsWindow()
    local panel = {
        type = "panel",
        name = "HideHousePreview",
        author = "@nooblybear",
        version = HideHousePreview.version,
        slashCommand = "/hhp",
        registerForRefresh = true,
    }

    local options = {
    {
        type = "checkbox",
        name = "Hide unpurchased houses",
        tooltip = "Prevent unpurchased houses from being displayed on the world map.",
        getFunc = function () return HideHousePreview.savedVariables.HideHousePreview end,
        setFunc = function (value) HideHousePreview.savedVariables.HideHousePreview = value
            ZO_WorldMap_UpdateMap()
            end,
        default = true,
        disabled = function () return HideHousePreview.savedVariables.TamrielOnly end,
    },
    {
        type = "checkbox",
        name = "Hide only on Tamriel map",
        tooltip = "Prevent unpurchased houses from being displayed on the main Tamriel map, but allow them on zone and local maps.",
        getFunc = function () return HideHousePreview.savedVariables.TamrielOnly end,
        setFunc = function (value) HideHousePreview.savedVariables.TamrielOnly = value
            ZO_WorldMap_UpdateMap()
            end,
        default = false,
    },
    {
        type = "checkbox",
        name = "Hide map button",
        tooltip = "Prevent the keybind strip button from appearing while in the world map. This button allows you to toggle the visibility of houses between all shown, unowned hidden and all hidden.",
        getFunc = function () return HideHousePreview.savedVariables.HideButton end,
        setFunc = function (value) HideHousePreview.savedVariables.HideButton = value end,
        default = false,
    }
    }

    LAM:RegisterAddonPanel("HideHousePreviewOptionsPanel", panel)
    LAM:RegisterOptionControls("HideHousePreviewOptionsPanel", options)
end

function HideHousePreview.OnAddOnLoaded(event, addonName)
    if addonName == HideHousePreview.name then
        HideHousePreview:Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(HideHousePreview.name, EVENT_ADD_ON_LOADED, HideHousePreview.OnAddOnLoaded)


