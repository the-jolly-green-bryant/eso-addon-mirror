---@type number
local FULL_ALPHA_VALUE = 1;
---@type number
local FADED_ALPHA_VALUE = 0.4;

---@type number
KFS_BAR_TEXT_MODE_HIDDEN = 0;
---@type number
KFS_BAR_TEXT_MODE_MOUSE_OVER = 1;
---@type number
KFS_BAR_TEXT_MODE_SHOWN = 2;

---@type boolean
local FORCE_INIT = true;

---@type string
local GROUP_UNIT_FRAME = "KFS_GroupUnitFrame";
---@type string
local COMPANION_UNIT_FRAME = "KFS_CompanionUnitFrame";
---@type string
local RAID_UNIT_FRAME = "KFS_RaidUnitFrame";
---@type string
local COMPANION_RAID_UNIT_FRAME = "KFS_CompanionRaidUnitFrame";
---@type string
local TARGET_UNIT_FRAME = "KFS_TargetUnitFrame";
---@type string
local COMPANION_GROUP_UNIT_FRAME = "KFS_CompanionGroupUnitFrame";

---@type number
local NUM_SUBGROUPS = MAX_GROUP_SIZE_THRESHOLD / STANDARD_GROUP_SIZE_THRESHOLD;
---@type ZO_ColorDef[]
local COMPANION_HEALTH_GRADIENT = { ZO_ColorDef:New("00484F"); ZO_ColorDef:New("278F7B"); };
---@type ZO_ColorDef
local COMPANION_HEALTH_GRADIENT_LOSS = ZO_ColorDef:New("621018");
---@type ZO_ColorDef
local COMPANION_HEALTH_GRADIENT_GAIN = ZO_ColorDef:New("D0FFBC");

---@type number
KFS_NUM_SUBGROUPS = NUM_SUBGROUPS;

---@type table
local KhajiitFengShui_UnitFrames_SavedVariables;
---@type table
local LCA = LibCombatAlerts; -- LibCombatAlerts (required dependency)

---
---@param itemOrData any
---@param fallback any|nil
---@return any
local function KFS_LHASDropdownItemToStoredValue(itemOrData, fallback)
    if itemOrData == nil then
        return fallback;
    end;
    if type(itemOrData) == "table" then
        if itemOrData.data ~= nil then
            return itemOrData.data;
        end;
        if itemOrData.name ~= nil then
            return itemOrData.name;
        end;
        return fallback;
    end;
    return itemOrData;
end;

---
---@return string
local function KFS_GetPlatformOverrideStored()
    local v = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.platformOverride or "auto";
    v = KFS_LHASDropdownItemToStoredValue(v, "auto");
    if v == "Auto" then v = "auto"; end;
    if v == "Keyboard" then v = "keyboard"; end;
    if v == "Gamepad" then v = "gamepad"; end;
    if v ~= "keyboard" and v ~= "gamepad" then
        v = "auto";
    end;
    return v;
end;

local PLATFORM_OVERRIDE_DISPLAY_NAMES =
{
    auto = "Auto";
    keyboard = "Keyboard";
    gamepad = "Gamepad";
};

---
---@param mode any
---@return string|table
local function KFS_BarTextModeDropdownGet(mode)
    mode = KFS_LHASDropdownItemToStoredValue(mode, KFS_BAR_TEXT_MODE_HIDDEN);
    if type(mode) ~= "number" then
        mode = KFS_BAR_TEXT_MODE_HIDDEN;
    end;
    local name;
    if mode == KFS_BAR_TEXT_MODE_SHOWN then
        name = "Always On";
    elseif mode == KFS_BAR_TEXT_MODE_MOUSE_OVER then
        name = "Mouse Over";
    else
        name = "Hidden";
    end;
    if ZO_IsConsoleOrGameCoreUI() then
        return { data = mode; };
    end;
    return name;
end;

---
---@param item any
---@return number
local function KFS_BarTextModeDropdownSet(item)
    local mode = KFS_LHASDropdownItemToStoredValue(item, KFS_BAR_TEXT_MODE_HIDDEN);
    if type(mode) ~= "number" then
        mode = KFS_BAR_TEXT_MODE_HIDDEN;
    end;
    return mode;
end;

---
---@return boolean
local function KFS_IsGamepadPreferred()
    if not KhajiitFengShui_UnitFrames_SavedVariables then
        return IsInGamepadPreferredMode();
    end;
    local override = KFS_GetPlatformOverrideStored();
    if override == "gamepad" then return true; end;
    if override == "keyboard" then return false; end;
    return IsInGamepadPreferredMode();
end;

---
---@param contextKey string
---@return number
local function KFS_GetContextBarTextMode(contextKey)
    local ctx = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context[contextKey];
    local mode = ctx and ctx.barTextMode or 0;
    if mode == KFS_BAR_TEXT_MODE_MOUSE_OVER or mode == KFS_BAR_TEXT_MODE_SHOWN then
        return mode;
    end;
    return KFS_BAR_TEXT_MODE_HIDDEN;
end;


---
---@param baseTemplateName string
---@return string
local function KFS_GetPlatformTemplate(baseTemplateName)
    local suffix = KFS_IsGamepadPreferred() and "_Gamepad_Template" or "_Keyboard_Template";
    return baseTemplateName .. suffix;
end;

---@class KFS_ElectionIconInfo
---@field icon string
---@field color ZO_ColorDef

---@type table<number, KFS_ElectionIconInfo>
local SMALL_GROUP_ELECTION_ICON_INFO =
{
    [GROUP_VOTE_CHOICE_ABSTAIN] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_notYet.dds";
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED));
    };
    [GROUP_VOTE_CHOICE_FOR] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_yes.dds";
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED));
    };
    [GROUP_VOTE_CHOICE_AGAINST] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_no.dds";
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED));
    };
    [GROUP_VOTE_CHOICE_INVALID] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_notYet.dds";
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED));
    };
};

---@type table<number, KFS_ElectionIconInfo>
local LARGE_GROUP_ELECTION_ICON_INFO =
{
    [GROUP_VOTE_CHOICE_ABSTAIN] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_notYet.dds";
        color = ZO_NORMAL_TEXT;
    };
    [GROUP_VOTE_CHOICE_FOR] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_yes.dds";
        color = ZO_NORMAL_TEXT;
    };
    [GROUP_VOTE_CHOICE_AGAINST] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_no.dds";
        color = ZO_NORMAL_TEXT;
    };
    [GROUP_VOTE_CHOICE_INVALID] =
    {
        icon = "EsoUI/Art/UnitFrames/votedIcon_notYet.dds";
        color = ZO_NORMAL_TEXT;
    };
};

---@type KFS_ManagerSingleton
local KFS_ManagerSingleton;

---@type number
KFS_KEYBOARD_GROUP_FRAME_WIDTH = 288;
---@type number
KFS_KEYBOARD_GROUP_FRAME_HEIGHT = 80;
---@type number
KFS_KEYBOARD_RAID_FRAME_WIDTH = 120;
---@type number
KFS_KEYBOARD_RAID_FRAME_HEIGHT = 45;
---@type number
KFS_KEYBOARD_COMPANION_FRAME_WIDTH = 288;
---@type number
KFS_KEYBOARD_COMPANION_FRAME_HEIGHT = 80;
---@type number
KFS_KEYBOARD_GROUP_COMPANION_FRAME_WIDTH = 288;
---@type number
KFS_KEYBOARD_GROUP_COMPANION_FRAME_HEIGHT = 110;

---@class KFS_PlatformConstants
---@field GROUP_LEADER_ICON string
---@field GROUP_FRAMES_PER_COLUMN number
---@field NUM_COLUMNS number
---@field GROUP_STRIDE number
---@field GROUP_FRAME_BASE_OFFSET_X number
---@field GROUP_FRAME_BASE_OFFSET_Y number
---@field RAID_FRAME_BASE_OFFSET_X number
---@field RAID_FRAME_BASE_OFFSET_Y number
---@field GROUP_FRAME_SIZE_X number
---@field GROUP_FRAME_SIZE_Y number
---@field GROUP_COMPANION_FRAME_SIZE_X number
---@field GROUP_COMPANION_FRAME_SIZE_Y number
---@field GROUP_FRAME_PAD_X number
---@field GROUP_FRAME_PAD_Y number
---@field RAID_FRAME_SIZE_X number
---@field RAID_FRAME_SIZE_Y number
---@field RAID_FRAME_PAD_X number
---@field RAID_FRAME_PAD_Y number
---@field GROUP_BAR_FONT string
---@field RAID_BAR_FONT string
---@field SHOW_GROUP_LABELS boolean
---@field SHOW_BATTLEGROUND_TEAM boolean
---@field GROUP_FRAME_OFFSET_X number|nil
---@field GROUP_FRAME_OFFSET_Y number|nil
---@field GROUP_COMPANION_FRAME_OFFSET_X number|nil
---@field GROUP_COMPANION_FRAME_OFFSET_Y number|nil
---@field RAID_FRAME_OFFSET_X number|nil
---@field RAID_FRAME_OFFSET_Y number|nil
---@field RAID_FRAME_ANCHOR_CONTAINER_WIDTH number|nil
---@field RAID_FRAME_ANCHOR_CONTAINER_HEIGHT number|nil

---@type KFS_PlatformConstants
local KEYBOARD_CONSTANTS =
{
    GROUP_LEADER_ICON = "EsoUI/Art/UnitFrames/groupIcon_leader.dds";

    GROUP_FRAMES_PER_COLUMN = STANDARD_GROUP_SIZE_THRESHOLD;
    NUM_COLUMNS = NUM_SUBGROUPS;

    GROUP_STRIDE = NUM_SUBGROUPS;

    GROUP_FRAME_BASE_OFFSET_X = 28;
    GROUP_FRAME_BASE_OFFSET_Y = 100;

    RAID_FRAME_BASE_OFFSET_X = 28;
    RAID_FRAME_BASE_OFFSET_Y = 100;

    GROUP_FRAME_SIZE_X = KFS_KEYBOARD_GROUP_FRAME_WIDTH;
    GROUP_FRAME_SIZE_Y = KFS_KEYBOARD_GROUP_FRAME_HEIGHT;

    GROUP_COMPANION_FRAME_SIZE_X = KFS_KEYBOARD_GROUP_COMPANION_FRAME_WIDTH;
    GROUP_COMPANION_FRAME_SIZE_Y = KFS_KEYBOARD_GROUP_COMPANION_FRAME_HEIGHT;

    GROUP_FRAME_PAD_X = 2;
    GROUP_FRAME_PAD_Y = 0;

    RAID_FRAME_SIZE_X = KFS_KEYBOARD_RAID_FRAME_WIDTH;
    RAID_FRAME_SIZE_Y = KFS_KEYBOARD_RAID_FRAME_HEIGHT;

    RAID_FRAME_PAD_X = 2;
    RAID_FRAME_PAD_Y = 2;

    GROUP_BAR_FONT = "ZoFontGameOutline";
    RAID_BAR_FONT = "ZoFontGameOutline";

    SHOW_GROUP_LABELS = true;
    SHOW_BATTLEGROUND_TEAM = false;
};

---@type number
KFS_GAMEPAD_GROUP_FRAME_WIDTH = 160;
---@type number
KFS_GAMEPAD_GROUP_FRAME_HEIGHT = 70;
---@type number
KFS_GAMEPAD_RAID_FRAME_WIDTH = 207;
---@type number
KFS_GAMEPAD_RAID_FRAME_HEIGHT = 40;
---@type number
KFS_GAMEPAD_COMPANION_FRAME_WIDTH = 160;
---@type number
KFS_GAMEPAD_COMPANION_FRAME_HEIGHT = 70;
---@type number
KFS_GAMEPAD_GROUP_COMPANION_FRAME_WIDTH = 160;
---@type number
KFS_GAMEPAD_GROUP_COMPANION_FRAME_HEIGHT = 130;

internalassert(MAX_GROUP_SIZE_THRESHOLD == 24, "The max group size has changed, make sure that GROUP_FRAMES_PER_COLUMN and NUM_COLUMNS are updated accordingly");
---@type KFS_PlatformConstants
local GAMEPAD_CONSTANTS =
{
    GROUP_LEADER_ICON = "EsoUI/Art/UnitFrames/Gamepad/gp_Group_Leader.dds";

    GROUP_FRAMES_PER_COLUMN = 12;
    NUM_COLUMNS = MAX_GROUP_SIZE_THRESHOLD / 12; -- The denominator should be the same value as GROUP_FRAMES_PER_COLUMN

    GROUP_STRIDE = 3;

    GROUP_FRAME_BASE_OFFSET_X = 70;
    GROUP_FRAME_BASE_OFFSET_Y = 55;

    RAID_FRAME_BASE_OFFSET_X = 100;
    RAID_FRAME_BASE_OFFSET_Y = 50;

    GROUP_FRAME_SIZE_X = KFS_GAMEPAD_GROUP_FRAME_WIDTH;
    GROUP_FRAME_SIZE_Y = KFS_GAMEPAD_GROUP_FRAME_HEIGHT;

    GROUP_COMPANION_FRAME_SIZE_X = KFS_GAMEPAD_GROUP_COMPANION_FRAME_WIDTH;
    GROUP_COMPANION_FRAME_SIZE_Y = KFS_GAMEPAD_GROUP_COMPANION_FRAME_HEIGHT;

    GROUP_FRAME_PAD_X = 2;
    GROUP_FRAME_PAD_Y = 9;

    RAID_FRAME_SIZE_X = KFS_GAMEPAD_RAID_FRAME_WIDTH;
    RAID_FRAME_SIZE_Y = KFS_GAMEPAD_RAID_FRAME_HEIGHT;

    RAID_FRAME_PAD_X = 4;
    RAID_FRAME_PAD_Y = 2;

    GROUP_BAR_FONT = "ZoFontGamepad34";
    RAID_BAR_FONT = "ZoFontGamepad18";

    SHOW_GROUP_LABELS = false;
    SHOW_BATTLEGROUND_TEAM = true;
};

---
---@return KFS_PlatformConstants
function KFS_GetPlatformConstants()
    return (KFS_IsGamepadPreferred() and GAMEPAD_CONSTANTS) or KEYBOARD_CONSTANTS;
end;

---@type fun(): KFS_PlatformConstants
local GetPlatformConstants = KFS_GetPlatformConstants;

--- Playable raid member cap (12). MAX_GROUP_SIZE_THRESHOLD (24) reserves UI slots the game cannot fill.
local KFS_PLAYABLE_RAID_MEMBER_COUNT = 12;

---
--- Movable raid column count for layout (not NUM_SUBGROUPS anchor slots).
---@return number
local function KFS_GetRaidLayoutColumnCount()
    local constants = GetPlatformConstants();
    if KFS_IsGamepadPreferred() then
        return constants.NUM_COLUMNS;
    end;
    return zo_floor((KFS_PLAYABLE_RAID_MEMBER_COUNT - 1) / constants.GROUP_FRAMES_PER_COLUMN) + 1;
end;

---
--- Raid frames stacked in one layout column (12-player cap), not gamepad GROUP_FRAMES_PER_COLUMN (24-slot backend).
---@param constants KFS_PlatformConstants
---@return number
local function KFS_GetRaidFramesPerLayoutColumn(constants)
    if constants == GAMEPAD_CONSTANTS then
        return KFS_PLAYABLE_RAID_MEMBER_COUNT / constants.NUM_COLUMNS;
    end;
    return constants.GROUP_FRAMES_PER_COLUMN;
end;

---
---@return nil
local function CalculateDynamicPlatformConstants()
    ---@type KFS_PlatformConstants[]
    local allConstants = { KEYBOARD_CONSTANTS; GAMEPAD_CONSTANTS };

    for _, constants in ipairs(allConstants) do
        constants.GROUP_FRAME_OFFSET_X = constants.GROUP_FRAME_SIZE_X + constants.GROUP_FRAME_PAD_X;
        constants.GROUP_FRAME_OFFSET_Y = constants.GROUP_FRAME_SIZE_Y + constants.GROUP_FRAME_PAD_Y;

        constants.GROUP_COMPANION_FRAME_OFFSET_X = constants.GROUP_COMPANION_FRAME_SIZE_X + constants.GROUP_FRAME_PAD_X;
        constants.GROUP_COMPANION_FRAME_OFFSET_Y = constants.GROUP_COMPANION_FRAME_SIZE_Y + constants.GROUP_FRAME_PAD_Y;

        constants.RAID_FRAME_OFFSET_X = constants.RAID_FRAME_SIZE_X + constants.RAID_FRAME_PAD_X;
        constants.RAID_FRAME_OFFSET_Y = constants.RAID_FRAME_SIZE_Y + constants.RAID_FRAME_PAD_Y;

        constants.RAID_FRAME_ANCHOR_CONTAINER_WIDTH = constants.RAID_FRAME_SIZE_X;
        local raidFramesPerColumn = KFS_GetRaidFramesPerLayoutColumn(constants);
        constants.RAID_FRAME_ANCHOR_CONTAINER_HEIGHT = (constants.RAID_FRAME_SIZE_Y + constants.RAID_FRAME_PAD_Y) * raidFramesPerColumn;
    end;
end;

---
---@return string
local function GetPlatformBarFont()
    local groupSize = KFS_ManagerSingleton:GetCombinedGroupSize();
    local constants = GetPlatformConstants();
    if groupSize > STANDARD_GROUP_SIZE_THRESHOLD then
        return constants.RAID_BAR_FONT;
    else
        return constants.GROUP_BAR_FONT;
    end;
end;

---@type boolean
local UNIT_CHANGED = true;

---@type ZO_Anchor
local groupFrameAnchor = ZO_Anchor:New(TOPLEFT, GuiRoot, TOPLEFT, 0, 0);

---
---@param groupIndex number
---@param groupSize number|nil
---@param previousFrame KFS_Frame|nil
---@param previousCompanionFrame KFS_Frame|nil
---@return ZO_Anchor
local function GetGroupFrameAnchor(groupIndex, groupSize, previousFrame, previousCompanionFrame)
    local constants = GetPlatformConstants();

    groupSize = groupSize or KFS_ManagerSingleton:GetCombinedGroupSize();
    local column = zo_floor((groupIndex - 1) / constants.GROUP_FRAMES_PER_COLUMN);
    local row = zo_mod(groupIndex - 1, constants.GROUP_FRAMES_PER_COLUMN);

    if groupSize > STANDARD_GROUP_SIZE_THRESHOLD then
        if KFS_IsGamepadPreferred() then
            column = zo_mod(groupIndex - 1, constants.NUM_COLUMNS);
            row = zo_floor((groupIndex - 1) / 2);
        end;
        local scales = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.scales;
        local raidScale = (scales and scales.raid) or 1.0;
        groupFrameAnchor:SetTarget(GetControl("KFS_LargeGroupAnchorFrame" .. (column + 1)));
        groupFrameAnchor:SetOffsets(0, row * constants.RAID_FRAME_OFFSET_Y * raidScale);
        return groupFrameAnchor;
    else
        -- The Y offset for this anchor should be the total y offset of the previous frame + the size of the previous frame
        local previousOffsetY = 0;
        local previousSizeY = 0;
        if previousFrame then
            previousOffsetY = previousFrame.offsetY;
        end;

        if previousCompanionFrame then
            previousSizeY = (previousCompanionFrame.hasTarget or previousCompanionFrame.hasPendingTarget) and constants.GROUP_COMPANION_FRAME_OFFSET_Y or constants.GROUP_FRAME_OFFSET_Y;
        end;
        groupFrameAnchor:SetTarget(GetControl("KFS_SmallGroupAnchorFrame"));
        groupFrameAnchor:SetOffsets(0, previousOffsetY + previousSizeY);
        return groupFrameAnchor;
    end;
end;

---
---@param subgroupIndex number
---@param groupStride number|nil
---@param constants KFS_PlatformConstants
---@return number, number
local function GetGroupAnchorFrameOffsets(subgroupIndex, groupStride, constants)
    groupStride = groupStride or NUM_SUBGROUPS;
    local zeroBasedIndex = subgroupIndex - 1;
    local row = zo_floor(zeroBasedIndex / groupStride);
    local column = zeroBasedIndex - (row * groupStride);
    return constants.RAID_FRAME_BASE_OFFSET_X + (column * constants.RAID_FRAME_OFFSET_X), constants.RAID_FRAME_BASE_OFFSET_Y + (row * constants.RAID_FRAME_ANCHOR_CONTAINER_HEIGHT);
end;

---
---@param subgroupIndex number
---@param groupStride number|nil
---@param constants KFS_PlatformConstants
---@return number, number
function KFS_GetGroupAnchorFrameOffsets(subgroupIndex, groupStride, constants)
    return GetGroupAnchorFrameOffsets(subgroupIndex, groupStride, constants);
end;

---@generic T
---@param svKey `T`
---@return T
local function KFS_GetSavedAnchor(svKey)
    local positions = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.positions;
    return positions and positions[svKey];
end;

---
---@param control Control|nil
---@param svKey string
---@param defaultPoint AnchorPosition|nil
---@param defaultRelPoint AnchorPosition|nil
---@param defaultX number|nil
---@param defaultY number|nil
---@return nil
local function KFS_ApplySavedAnchor(control, svKey, defaultPoint, defaultRelPoint, defaultX, defaultY)
    if not control then return; end;
    control:ClearAnchors();
    local saved = KFS_GetSavedAnchor(svKey);
    if saved then
        -- Handle both formats: old anchor format (point, relPoint, x, y) and new position format (left, top)
        if saved.point and saved.relPoint then
            -- Old anchor format
            control:SetAnchor(saved.point or TOPLEFT, GuiRoot, saved.relPoint or TOPLEFT, saved.x or 0, saved.y or 0);
        elseif saved.left ~= nil or saved.top ~= nil then
            -- New position format from main addon - convert to anchor format
            -- The main addon applies anchors with TOPLEFT, TOPLEFT by default, so we use that
            local left = saved.left or 0;
            local top = saved.top or 0;
            control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top);
        else
            -- Fallback to defaults
            if defaultPoint then
                control:SetAnchor(defaultPoint, GuiRoot, defaultRelPoint or defaultPoint, defaultX or 0, defaultY or 0);
            end;
        end;
    elseif defaultPoint then
        control:SetAnchor(defaultPoint, GuiRoot, defaultRelPoint or defaultPoint, defaultX or 0, defaultY or 0);
    end;
end;

---
---@param svKey string
---@return number|nil
local function KFS_GetSavedScale(svKey)
    local scales = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.scales;
    return scales and (svKey == "raid" and scales.raid or scales[svKey]);
end;

---
---@param control Control|nil
---@param svKey string
---@param defaultScale number|nil
---@return nil
local function KFS_ApplySavedScale(control, svKey, defaultScale)
    if not control then return; end;
    local value = KFS_GetSavedScale(svKey) or defaultScale or 1.0;
    control:SetScale(value);
end;

---
---@param svKey string
---@param value number
---@return nil
local function KFS_SetScaleValue(svKey, value)
    KhajiitFengShui_UnitFrames_SavedVariables.general.scales = KhajiitFengShui_UnitFrames_SavedVariables.general.scales or {};
    if svKey == "raid" then
        KhajiitFengShui_UnitFrames_SavedVariables.general.scales.raid = value;
    else
        KhajiitFengShui_UnitFrames_SavedVariables.general.scales[svKey] = value;
    end;
end;

---
---@param style string
---@return number
local function KFS_GetScaleForStyle(style)
    local scales = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.scales or {};
    if style == GROUP_UNIT_FRAME or style == COMPANION_GROUP_UNIT_FRAME then
        return scales.smallGroup or 1.0;
    elseif style == RAID_UNIT_FRAME or style == COMPANION_RAID_UNIT_FRAME then
        return scales.raid or 1.0;
    elseif style == TARGET_UNIT_FRAME then
        return scales.target or 1.0;
    end;
    return 1.0;
end;

---
---@param unitFrame KFS_Frame|nil
---@return nil
local function KFS_ApplyScaleToFrame(unitFrame)
    if unitFrame and unitFrame.frame and unitFrame.style then
        unitFrame.frame:SetScale(KFS_GetScaleForStyle(unitFrame.style));
    end;
end;

---
---@param frames table<string, KFS_Frame>
---@return nil
local function KFS_ApplyScaleOnAllFrames(frames)
    for _, unitFrame in pairs(frames) do
        KFS_ApplyScaleToFrame(unitFrame);
    end;
end;



-- Maps unitframe panel IDs to their svKeys for saved variables
---@type table<string, string>
local UNITFRAME_PANEL_TO_SVKEY =
{
    unitFrameSmallGroup = "smallGroup";
    unitFrameRaid1 = "raid1";
    unitFrameRaid2 = "raid2";
    unitFrameRaid3 = "raid3";
    unitFrameTarget = "target";
};

-- Registers unitframes as panels with the main addon for individual movement
---
---@return nil
function KFS_RegisterUnitFramePanels()
    local mainAddon = KhajiitFengShui;
    if not mainAddon or not mainAddon.TryCreatePanel then
        return;
    end;

    local PanelDefinitions = KhajiitFengShui.PanelDefinitions;
    if not PanelDefinitions then
        return;
    end;

    -- Hook into main addon's OnMoveStop to save unitframe positions to unitframes saved vars
    local originalOnMoveStop = mainAddon.OnMoveStop;
    function mainAddon:OnMoveStop(panel, handler, newPos, isExplicitStop)
        -- Call original OnMoveStop first so the main addon applies the anchor
        originalOnMoveStop(self, panel, handler, newPos, isExplicitStop);

        -- After the main addon applies the anchor, save it to unitframes saved vars
        local svKey = panel and panel.definition and UNITFRAME_PANEL_TO_SVKEY[panel.definition.id];
        if svKey then
            local control = panel.control;
            if control and KhajiitFengShui_UnitFrames_SavedVariables then
                if not KhajiitFengShui_UnitFrames_SavedVariables.general.positions then
                    KhajiitFengShui_UnitFrames_SavedVariables.general.positions = {};
                end;

                -- Get the actual anchor from the control (already applied by main addon)
                -- and save it in the format unitframes expects (point, relPoint, x, y)
                local isValid, point, target, relPoint, offsetX, offsetY = control:GetAnchor(0);
                if isValid then
                    -- Save in anchor format so UpdateAnchorFrameVisuals can use it correctly
                    KhajiitFengShui_UnitFrames_SavedVariables.general.positions[svKey] =
                    {
                        point = point;
                        relPoint = relPoint;
                        x = offsetX;
                        y = offsetY;
                    };
                end;
            end;
        end;
    end;

    -- Hook into main addon's ApplySavedPosition to load unitframe positions from unitframes saved vars
    local originalApplySavedPosition = mainAddon.ApplySavedPosition;
    function mainAddon:ApplySavedPosition(panel)
        local svKey = panel and panel.definition and UNITFRAME_PANEL_TO_SVKEY[panel.definition.id];
        if svKey and KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general.positions then
            local savedPos = KhajiitFengShui_UnitFrames_SavedVariables.general.positions[svKey];
            if savedPos then
                -- Temporarily store in main addon's savedVars for ApplySavedPosition to use
                if not self.savedVars.positions then
                    self.savedVars.positions = {};
                end;

                -- Convert saved format to position format (left, top) for main addon
                local left, top;
                if savedPos.left ~= nil or savedPos.top ~= nil then
                    -- Position format (left, top)
                    left = savedPos.left;
                    top = savedPos.top;
                elseif savedPos.point and savedPos.relPoint then
                    -- Anchor format (point, relPoint, x, y) - convert to position format
                    -- The main addon uses TOPLEFT anchoring, so for TOPLEFT anchors:
                    -- x = left, y = top directly
                    if savedPos.point == TOPLEFT and savedPos.relPoint == TOPLEFT then
                        left = savedPos.x or 0;
                        top = savedPos.y or 0;
                    else
                        -- For other anchor points, use x/y as left/top for now
                        -- (This may need adjustment for other anchor configurations)
                        left = savedPos.x or 0;
                        top = savedPos.y or 0;
                    end;
                end;

                if left ~= nil or top ~= nil then
                    self.savedVars.positions[panel.definition.id] =
                    {
                        left = left;
                        top = top;
                    };
                end;
            end;
        end;

        -- Call original ApplySavedPosition
        originalApplySavedPosition(self, panel);

        -- Clean up temporary storage
        if svKey and self.savedVars.positions then
            self.savedVars.positions[panel.definition.id] = nil;
        end;
    end;

    -- Register small group panel
    local smallGroupDef =
    {
        id = "unitFrameSmallGroup";
        controlName = "KFS_SmallGroupAnchorFrame";
        label = KFS_LABEL_UNITFRAME_SMALL_GROUP;
        condition = function ()
            return GetControl("KFS_SmallGroupAnchorFrame") ~= nil;
        end;
    };

    mainAddon:TryCreatePanel(smallGroupDef);

    local maxRaidGroups = KFS_GetRaidLayoutColumnCount();
    local raidPanelLabels =
    {
        KFS_LABEL_UNITFRAME_RAID_1;
        KFS_LABEL_UNITFRAME_RAID_2;
        KFS_LABEL_UNITFRAME_RAID_3;
        KFS_LABEL_UNITFRAME_RAID_4;
        KFS_LABEL_UNITFRAME_RAID_5;
        KFS_LABEL_UNITFRAME_RAID_6;
    };
    for i = 1, maxRaidGroups do
        local raidId = string.format("unitFrameRaid%d", i);
        local raidDef =
        {
            id = raidId;
            controlName = string.format("KFS_LargeGroupAnchorFrame%d", i);
            label = raidPanelLabels[i];
            condition = function ()
                return GetControl(string.format("KFS_LargeGroupAnchorFrame%d", i)) ~= nil;
            end;
        };

        mainAddon:TryCreatePanel(raidDef);
    end;

    -- Register target panel
    local targetDef =
    {
        id = "unitFrameTarget";
        controlName = "KFS_TargetUnitFramereticleover";
        label = KFS_LABEL_UNITFRAME_TARGET;
        condition = function ()
            return GetControl("KFS_TargetUnitFramereticleover") ~= nil;
        end;
    };

    mainAddon:TryCreatePanel(targetDef);
end;

--[[
    UnitFrames container object.  Used to manage the ZO_UnitFrameObject objects according to UnitTags ("group1", "group4pet", etc...)
--]]
---@class KFS_Manager : ZO_InitializingObject
---@field groupFrames table<string, KFS_Frame>
---@field raidFrames table<string, KFS_Frame>
---@field companionRaidFrames table<string, KFS_Frame>
---@field staticFrames table<string, KFS_Frame>
---@field groupSize number
---@field companionGroupSize number
---@field targetOfTargetEnabled boolean
---@field groupAndRaidHiddenReasons ZO_HiddenReasons
---@field firstDirtyGroupIndex number|nil
---@field activeElection boolean|nil
---@field endElectionCallback number|nil
KFS_Manager = ZO_InitializingObject:Subclass();

---
---@return nil
function KFS_Manager:Initialize()
    self.groupFrames = {};
    self.raidFrames = {};
    self.companionRaidFrames = {};
    self.staticFrames = {};
    self.groupSize = GetGroupSize();
    self.targetOfTargetEnabled = true;
    self.groupAndRaidHiddenReasons = ZO_HiddenReasons:New();
    self.firstDirtyGroupIndex = nil;
    self:UpdateCompanionGroupSize();
end;

---
---@param frames table<string, KFS_Frame>
---@return nil
local function ApplyVisualStyleToAllFrames(frames)
    for _, unitFrame in pairs(frames) do
        unitFrame:ApplyVisualStyle();
    end;
end;

---
---@return nil
function KFS_Manager:ApplyVisualStyle()
    ApplyVisualStyleToAllFrames(self.staticFrames);
    ApplyVisualStyleToAllFrames(self.groupFrames);
    ApplyVisualStyleToAllFrames(self.raidFrames);
    ApplyVisualStyleToAllFrames(self.companionRaidFrames);
end;

---
---@param unitTag string|nil
---@return table<string, KFS_Frame>
function KFS_Manager:GetUnitFrameLookupTable(unitTag)
    if unitTag then
        local isGroupTag = ZO_Group_IsGroupUnitTag(unitTag);
        local isCompanionTag = IsGroupCompanionUnitTag(unitTag);

        if isGroupTag or isCompanionTag then
            if self:GetCombinedGroupSize() <= STANDARD_GROUP_SIZE_THRESHOLD then
                return self.groupFrames;
            else
                return isCompanionTag and self.companionRaidFrames or self.raidFrames;
            end;
        end;
    end;

    return self.staticFrames;
end;

---
---@param unitTag string
---@return KFS_Frame|nil
function KFS_Manager:GetFrame(unitTag)
    local unitFrameTable = self:GetUnitFrameLookupTable(unitTag);

    if unitFrameTable then
        return unitFrameTable[unitTag];
    end;
end;

---
---@param unitTag string
---@param anchors ZO_Anchor|ZO_Anchor[]
---@param barTextMode number
---@param style string
---@param templateName string|nil
---@param visualizerSetupFunction function|nil
---@return KFS_Frame
function KFS_Manager:CreateFrame(unitTag, anchors, barTextMode, style, templateName, visualizerSetupFunction)
    local unitFrame = self:GetFrame(unitTag);
    if unitFrame == nil then
        local unitFrameTable = self:GetUnitFrameLookupTable(unitTag);
        unitFrame = KFS_Frame:New(unitTag, anchors, barTextMode, style, templateName);

        if type(visualizerSetupFunction) == "function" then
            visualizerSetupFunction(unitFrame);
        end;

        if unitFrameTable then
            unitFrameTable[unitTag] = unitFrame;
        end;
    else
        -- Frame already existed, but may need to be reanchored.
        unitFrame:SetAnchor(anchors);
    end;

    return unitFrame;
end;

---
---@param unitTag string
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Manager:SetFrameHiddenForReason(unitTag, reason, hidden)
    local unitFrame = self:GetFrame(unitTag);

    if unitFrame then
        unitFrame:SetHiddenForReason(reason, hidden);
    end;
end;

---
---@param groupSize number|nil
---@return nil
function KFS_Manager:SetGroupSize(groupSize)
    self.groupSize = groupSize or GetGroupSize();
end;

---
---@return nil
function KFS_Manager:UpdateCompanionGroupSize()
    self.companionGroupSize = GetNumCompanionsInGroup();
end;

---
---@return number
function KFS_Manager:GetCompanionGroupSize()
    return self.companionGroupSize;
end;

---
---@return number
function KFS_Manager:GetCombinedGroupSize()
    return self.groupSize + self.companionGroupSize;
end;

---
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Manager:SetGroupFramesHiddenForReason(reason, hidden)
    for unitTag, frame in pairs(self.groupFrames) do
        frame:SetHiddenForReason(reason, hidden);
    end;
end;

---
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Manager:SetRaidFramesHiddenForReason(reason, hidden)
    for unitTag, frame in pairs(self.raidFrames) do
        frame:SetHiddenForReason(reason, hidden);
    end;
end;

---
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Manager:SetCompanionRaidFramesHiddenForReason(reason, hidden)
    for unitTag, frame in pairs(self.companionRaidFrames) do
        frame:SetHiddenForReason(reason, hidden);
    end;
end;

---
---@param frames table<string, KFS_Frame>
---@param animate boolean
---@return nil
local function SetAnimateOnAllFrames(frames, animate)
    for _, unitFrame in pairs(frames) do
        unitFrame:SetAnimateShowHide(animate);
    end;
end;

---
---@param animate boolean
---@return nil
function KFS_Manager:SetAnimateShowHide(animate)
    SetAnimateOnAllFrames(self.staticFrames, animate);
    SetAnimateOnAllFrames(self.groupFrames, animate);
    SetAnimateOnAllFrames(self.raidFrames, animate);
    SetAnimateOnAllFrames(self.companionRaidFrames, animate);
end;

---
---@return number|nil
function KFS_Manager:GetFirstDirtyGroupIndex()
    return self.firstDirtyGroupIndex;
end;

---
---@return boolean
function KFS_Manager:GetIsDirty()
    return self.firstDirtyGroupIndex ~= nil;
end;

---
---@param groupIndex number
---@return nil
function KFS_Manager:SetGroupIndexDirty(groupIndex)
    -- The update we call will update all unit frames after and including the one being modified
    -- So we really just need to know what is the smallest groupIndex that is being changed
    if not self.firstDirtyGroupIndex or groupIndex < self.firstDirtyGroupIndex then
        self.firstDirtyGroupIndex = groupIndex;
    end;
end;

---
---@return nil
function KFS_Manager:ClearDirty()
    self.firstDirtyGroupIndex = nil;
end;

---
---@return nil
function KFS_Manager:DisableCompanionRaidFrames()
    for _, unitFrame in pairs(self.companionRaidFrames) do
        unitFrame:SetHiddenForReason("disabled", true);
    end;
end;

---
---@return nil
function KFS_Manager:DisableGroupAndRaidFrames()
    -- Disable the raid frames
    for _, unitFrame in pairs(self.raidFrames) do
        unitFrame:SetHiddenForReason("disabled", true);
    end;

    -- Disable the group frames
    for _, unitFrame in pairs(self.groupFrames) do
        unitFrame:SetHiddenForReason("disabled", true);
    end;

    self:DisableCompanionRaidFrames();
end;

---
---@return nil
function KFS_Manager:DisableLocalCompanionFrame()
    local companionFrame = self:GetFrame("companion");
    if companionFrame then
        companionFrame:SetHiddenForReason("disabled", true);
    end;
end;

---
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Manager:SetGroupAndRaidFramesHiddenForReason(reason, hidden)
    KFS_UNIT_FRAMES_FRAGMENT:SetHiddenForReason(reason, hidden);
    self.groupAndRaidHiddenReasons:SetHiddenForReason(reason, hidden);
end;

---
---@return nil
function KFS_Manager:UpdateGroupAnchorFrames()
    -- Only the raid frame anchors need updates for now and it's only for whether or not the group name labels are showing and which one is highlighted
    if self:GetCombinedGroupSize() <= STANDARD_GROUP_SIZE_THRESHOLD or self.groupAndRaidHiddenReasons:IsHidden() then
        -- Small groups never show the raid frame anchors
        for subgroupIndex = 1, NUM_SUBGROUPS do
            GetControl("KFS_LargeGroupAnchorFrame" .. subgroupIndex):SetHidden(true);
        end;
    else
        local groupSizeWithCompanions = self:GetCombinedGroupSize();
        local layoutColumnCount = KFS_GetRaidLayoutColumnCount();
        for subgroupIndex = 1, NUM_SUBGROUPS do
            local frameIsHidden;
            if KFS_IsGamepadPreferred() then
                frameIsHidden = subgroupIndex > layoutColumnCount;
            else
                local subgroupThreshold = (subgroupIndex - 1) * STANDARD_GROUP_SIZE_THRESHOLD;
                frameIsHidden = groupSizeWithCompanions <= subgroupThreshold;
            end;

            local anchorFrame = GetControl("KFS_LargeGroupAnchorFrame" .. subgroupIndex);
            anchorFrame:SetHidden(frameIsHidden);
        end;
    end;
end;

---
---@return boolean
function KFS_Manager:IsTargetOfTargetEnabled()
    return self.targetOfTargetEnabled;
end;

---
---@param enableFlag boolean
---@return nil
function KFS_Manager:SetEnableTargetOfTarget(enableFlag)
    if enableFlag ~= self.targetOfTargetEnabled then
        self.targetOfTargetEnabled = enableFlag;
        CALLBACK_MANAGER:FireCallbacks("TargetOfTargetEnabledChanged", enableFlag);
    end;
end;

---
---@return nil
function KFS_Manager:BeginGroupElection()
    local electionType, _, descriptor = GetGroupElectionInfo();

    if ZO_IsGroupElectionTypeCustom(electionType) and descriptor == ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
        self.activeElection = true;

        if self.endElectionCallback then
            zo_removeCallLater(self.endElectionCallback);
        end;

        self:UpdateElectionIcons();
    end;
end;

---
---@param resultType number|nil
---@return nil
function KFS_Manager:UpdateElectionInfo(resultType)
    local electionType, timeRemainingSeconds, descriptor, targetUnitTag, initiatorUnitTag = GetGroupElectionInfo();
    self.activeElection = timeRemainingSeconds > 0;
    if self.activeElection and ZO_IsGroupElectionTypeCustom(electionType) then
        if descriptor == ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
            self:UpdateElectionIcons();
        end;
    elseif ZO_IsGroupElectionTypeCustom(electionType) then
        -- Time remaining <= 0.
        resultType = resultType or GROUP_ELECTION_RESULT_NOT_APPLICABLE;
        self:EndGroupElection(resultType);
    end;
end;

---
---@param resultType number|nil
---@return nil
function KFS_Manager:EndGroupElection(resultType)
    self.activeElection = false;

    if resultType ~= GROUP_ELECTION_RESULT_ABANDONED and resultType ~= GROUP_ELECTION_RESULT_NOT_APPLICABLE then
        local ELECTION_WON_DELAY_MS = 3000;
        local ELECTION_LOST_DELAY_MS = 5000;
        local postElectionDelayMS = resultType == GROUP_ELECTION_RESULT_ELECTION_WON and ELECTION_WON_DELAY_MS or ELECTION_LOST_DELAY_MS;
        local function OnEndElection()
            self:HideElectionIcons();
            self.endElectionCallback = nil;
        end;
        self.endElectionCallback = zo_callLater(OnEndElection, postElectionDelayMS);
    end;

    self:UpdateElectionIcons();
end;

---
---@return nil
function KFS_Manager:HideElectionIcons()
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);
        local unitFrame = unitTag and self:GetFrame(unitTag);

        if unitFrame then
            unitFrame.electionIcon:SetHidden(true);
        end;
    end;
end;

---
---@return nil
function KFS_Manager:UpdateElectionIcons()
    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);
        local unitFrame = unitTag and self:GetFrame(unitTag);

        if unitFrame then
            unitFrame:RefreshElectionIcon();
        end;
    end;
end;

---
---@return nil
function KFS_Manager:UpdateNames()
    local localCompanionFrame = self:GetFrame("companion");
    if localCompanionFrame then
        localCompanionFrame:UpdateName();
    end;

    local targetFrame = self:GetFrame("reticleover");
    if targetFrame then
        targetFrame:UpdateName();
    end;

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);
        local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag);
        local unitFrame = unitTag and self:GetFrame(unitTag);
        local companionUnitFrame = companionTag and self:GetFrame(companionTag);

        if unitFrame then
            unitFrame:UpdateName();
        end;
        if companionUnitFrame then
            companionUnitFrame:UpdateName();
        end;
    end;
end;

--[[
    ZO_UnitFrameBar class...defines one bar in the unit frame, including background/glass textures, statusbar and text
--]]

---@type boolean
local ANY_POWER_TYPE = true; -- A special flag that essentially acts like a wild card, accepting any mechanic

---@type table<string, table<number, table>>
local UNITFRAME_BAR_STYLES =
{
    [TARGET_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            textAnchors =
            {
                ZO_Anchor:New(TOP, nil, BOTTOM, 0, -22);
            };
            centered = true;
        };
    };

    [GROUP_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            keyboard =
            {
                template = "KFS_GroupUnitFrameStatus";
                barHeight = 9;
                barWidth = 170;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 42) };
            };

            gamepad =
            {
                template = "KFS_GroupUnitFrameStatus";
                barHeight = 8;
                barWidth = KFS_GAMEPAD_GROUP_FRAME_WIDTH;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 45) };
                hideBgIfOffline = true;
            };
        };
    };

    [RAID_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            keyboard =
            {
                template = "KFS_UnitFrameStatus";
                barHeight = 39;
                barWidth = 114;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 2, 2) };
            };

            gamepad =
            {
                template = "KFS_UnitFrameStatus";
                barHeight = KFS_GAMEPAD_RAID_FRAME_HEIGHT - 2;
                barWidth = KFS_GAMEPAD_RAID_FRAME_WIDTH - 2;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 1, 1) };
            };
        };
    };
    [COMPANION_RAID_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            keyboard =
            {
                template = "KFS_UnitFrameStatus";
                barHeight = 39;
                barWidth = 114;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 2, 2) };
            };

            gamepad =
            {
                template = "KFS_UnitFrameStatus";
                barHeight = KFS_GAMEPAD_RAID_FRAME_HEIGHT - 2;
                barWidth = KFS_GAMEPAD_RAID_FRAME_WIDTH - 2;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 1, 1) };
            };
        };
    };
    [COMPANION_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            keyboard =
            {
                template = "KFS_CompanionUnitFrameStatus";
                barHeight = 9;
                barWidth = 170;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 42) };
            };

            gamepad =
            {
                template = "KFS_CompanionUnitFrameStatus";
                barHeight = 8;
                barWidth = KFS_GAMEPAD_COMPANION_FRAME_WIDTH;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 45) };
            };
        };
    };
    [COMPANION_GROUP_UNIT_FRAME] =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] =
        {
            keyboard =
            {
                template = "KFS_CompanionUnitFrameStatus";
                barHeight = 9;
                barWidth = 120;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 82) };
            };

            gamepad =
            {
                template = "KFS_CompanionUnitFrameStatus";
                barHeight = 8;
                barWidth = 120;
                barAnchors = { ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 97) };
            };
        };
    };
};

---
---@param style string
---@param powerType number
---@return table
local function GetPlatformBarStyle(style, powerType)
    local styleData = UNITFRAME_BAR_STYLES[style] or UNITFRAME_BAR_STYLES.default;
    local barData = styleData[powerType] or styleData[ANY_POWER_TYPE];

    -- Note: It is assumed that either all platforms are defined, or no platforms are defined.
    local platformKey = KFS_IsGamepadPreferred() and "gamepad" or "keyboard";
    return barData[platformKey] or barData;
end;

---
---@param style string
---@param powerType number
---@return boolean
local function IsValidBarStyle(style, powerType)
    local styleData = UNITFRAME_BAR_STYLES[style] or UNITFRAME_BAR_STYLES.default;
    return styleData and (styleData[powerType] ~= nil or styleData[ANY_POWER_TYPE] ~= nil);
end;

---
---@param baseBarName string
---@param parent Control
---@param style string
---@param mechanic number
---@return Control[]|nil
local function CreateBarStatusControl(baseBarName, parent, style, mechanic)
    local barData = GetPlatformBarStyle(style, mechanic);
    if barData then
        if barData.template then
            local barAnchor1, barAnchor2 = barData.barAnchors[1], barData.barAnchors[2];

            if barData.centered then
                local leftBar = CreateControlFromVirtual(baseBarName .. "Left", parent, barData.template);
                local rightBar = CreateControlFromVirtual(baseBarName .. "Right", parent, barData.template);

                if barAnchor1 then
                    barAnchor1:Set(leftBar);
                end;

                if barAnchor2 then
                    barAnchor2:Set(rightBar);
                end;

                leftBar:SetBarAlignment(BAR_ALIGNMENT_REVERSE);
                local gloss = leftBar:GetNamedChild("Gloss");
                if gloss then
                    gloss:SetBarAlignment(BAR_ALIGNMENT_REVERSE);
                end;

                if barData.barWidth then
                    leftBar:SetWidth(barData.barWidth / 2);
                    rightBar:SetWidth(barData.barWidth / 2);
                end;

                if barData.barHeight then
                    leftBar:SetHeight(barData.barHeight);
                    rightBar:SetHeight(barData.barHeight);
                end;

                rightBar:SetAnchor(TOPLEFT, leftBar, TOPRIGHT, 0, 0);

                return { leftBar; rightBar };
            else
                local statusBar = CreateControlFromVirtual(baseBarName, parent, barData.template);
                if barData.barWidth then
                    statusBar:SetWidth(barData.barWidth);
                end;

                if barData.barHeight then
                    statusBar:SetHeight(barData.barHeight);
                end;

                if barAnchor1 then
                    barAnchor1:Set(statusBar);
                end;

                if barAnchor2 then
                    barAnchor2:AddToControl(statusBar);
                end;

                return { statusBar };
            end;
        else
            -- attempt to find the controls from XML
            local bar = parent:GetNamedChild("Bar");
            if bar then
                return { bar };
            end;
            local barLeft = parent:GetNamedChild("BarLeft");
            local barRight = parent:GetNamedChild("BarRight");
            if barLeft and barRight then
                return { barLeft; barRight };
            end;
        end;
    end;
    return nil;
end;

---
---@param baseBarName string
---@param parent Control
---@param style string
---@param mechanic number
---@return Control|nil, Control|nil
local function CreateBarTextControls(baseBarName, parent, style, mechanic)
    local barData = GetPlatformBarStyle(style, mechanic);
    if not barData or not barData.textAnchors then
        return nil, nil;
    end;
    local textAnchors = barData.textAnchors;
    local textAnchor1 = textAnchors and textAnchors[1];
    local textAnchor2 = textAnchors and textAnchors[2];

    local text1, text2;
    local textTemplate = barData.textTemplate or "KFS_UnitFrameBarText";

    if textAnchor1 then
        text1 = CreateControlFromVirtual(baseBarName .. "Text1", parent, textTemplate);
        text1:SetFont(GetPlatformBarFont());
        textAnchor1:Set(text1);
    end;

    if textAnchor2 then
        text2 = CreateControlFromVirtual(baseBarName .. "Text2", parent, textTemplate);
        text2:SetFont(GetPlatformBarFont());
        textAnchor2:Set(text2);
    end;

    return text1, text2;
end;

---@class KFS_Bar : KFS_Manager
---@field barControls Control[]
---@field barTextMode number
---@field style string
---@field mechanic number
---@field resourceNumbersLabel Control|nil
---@field leftText Control|nil
---@field rightText Control|nil
---@field currentValue number|nil
---@field maxValue number|nil
---@field barType number|nil
---@field barTypeName string|nil
---@field isMouseInside boolean|nil
KFS_Bar = KFS_Manager:Subclass();

---
---@param baseBarName string
---@param parent Control
---@param barTextMode number
---@param style string
---@param mechanic number
---@return nil
function KFS_Bar:Initialize(baseBarName, parent, barTextMode, style, mechanic)
    local barControls = CreateBarStatusControl(baseBarName, parent, style, mechanic);
    self.barControls = barControls;
    self.barTextMode = barTextMode;
    self.style = style;
    self.mechanic = mechanic;
    self.resourceNumbersLabel = parent:GetNamedChild("ResourceNumbers");

    -- Target frame already has its own resource number display; do not overlay our bar text there
    if barTextMode ~= KFS_BAR_TEXT_MODE_HIDDEN and style ~= TARGET_UNIT_FRAME then
        self.leftText, self.rightText = CreateBarTextControls(baseBarName, parent, style, mechanic);
    end;
end;

---
---@param barType number
---@param cur number
---@param max number
---@param forceInit boolean|nil
---@return nil
function KFS_Bar:Update(barType, cur, max, forceInit)
    local barCur = cur;
    local barMax = max;

    if #self.barControls == 2 then
        barCur = cur / 2;
        barMax = max / 2;
    end;

    for i = 1, #self.barControls do
        ZO_StatusBar_SmoothTransition(self.barControls[i], barCur, barMax, forceInit);
    end;

    local updateBarType = false;
    local updateValue = cur ~= self.currentValue or self.maxValue ~= max;
    self.currentValue = cur;
    self.maxValue = max;

    if barType ~= self.barType then
        updateBarType = true;
        self.barType = barType;
        self.barTypeName = GetString("SI_COMBATMECHANICFLAGS", self.barType);
    end;

    self:UpdateText(updateBarType, updateValue);
end;

---
---@param self KFS_Bar
---@return boolean
local function GetVisibility(self)
    if self.barTextMode == KFS_BAR_TEXT_MODE_MOUSE_OVER then
        return self.isMouseInside;
    end;
    return true;
end;

---
---@param updateBarType boolean
---@param updateValue boolean
---@return nil
function KFS_Bar:UpdateText(updateBarType, updateValue)
    if self.barTextMode == KFS_BAR_TEXT_MODE_SHOWN or self.barTextMode == KFS_BAR_TEXT_MODE_MOUSE_OVER then
        local visible = GetVisibility(self);
        if self.leftText and self.rightText then
            self.leftText:SetHidden(not visible);
            self.rightText:SetHidden(not visible);
            if visible then
                if updateBarType then
                    self.leftText:SetText(zo_strformat(SI_UNIT_FRAME_BARTYPE, self.barTypeName));
                end;
                if updateValue then
                    self.rightText:SetText(zo_strformat(SI_UNIT_FRAME_BARVALUE, self.currentValue, self.maxValue));
                end;
            end;
        elseif self.leftText then
            if visible then
                self.leftText:SetHidden(false);
                if updateValue then
                    self.leftText:SetText(zo_strformat(SI_UNIT_FRAME_BARVALUE, self.currentValue, self.maxValue));
                end;
            else
                self.leftText:SetHidden(true);
            end;
        end;
    end;

    if self.resourceNumbersLabel then
        self.resourceNumbersLabel:SetText(ZO_FormatResourceBarCurrentAndMax(self.currentValue, self.maxValue));
    end;
end;

---
---@param inside boolean
---@return nil
function KFS_Bar:SetMouseInside(inside)
    self.isMouseInside = inside;

    if self.barTextMode == KFS_BAR_TEXT_MODE_MOUSE_OVER then
        local UPDATE_BAR_TYPE, UPDATE_VALUE = true, true;
        self:UpdateText(UPDATE_BAR_TYPE, UPDATE_VALUE);
    end;
end;

---
---@param barType number
---@param overrideGradient ZO_ColorDef[]|nil
---@param overrideLoss ZO_ColorDef|nil
---@param overrideGain ZO_ColorDef|nil
---@return nil
function KFS_Bar:SetColor(barType, overrideGradient, overrideLoss, overrideGain)
    local gradient = overrideGradient or ZO_POWER_BAR_GRADIENT_COLORS[barType];
    for i = 1, #self.barControls do
        ZO_StatusBar_SetGradientColor(self.barControls[i], gradient);
        if overrideLoss then
            self.barControls[i]:SetFadeOutLossColor(overrideLoss:UnpackRGBA());
        else
            self.barControls[i]:SetFadeOutLossColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_OUT, barType));
        end;

        if overrideGain then
            self.barControls[i]:SetFadeOutGainColor(overrideGain:UnpackRGBA());
        else
            self.barControls[i]:SetFadeOutGainColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_FADE_IN, barType));
        end;
    end;
end;

---
---@param hidden boolean
---@return nil
function KFS_Bar:Hide(hidden)
    for i = 1, #self.barControls do
        self.barControls[i]:SetHidden(hidden);
    end;
end;

---
---@param alpha number
---@return nil
function KFS_Bar:SetAlpha(alpha)
    for i = 1, #self.barControls do
        self.barControls[i]:SetAlpha(alpha);
    end;

    if self.leftText then
        self.leftText:SetAlpha(alpha);
    end;

    if self.rightText then
        self.rightText:SetAlpha(alpha);
    end;
end;

---
---@return Control[]
function KFS_Bar:GetBarControls()
    return self.barControls;
end;

---
---@param alwaysShow number
---@return nil
function KFS_Bar:SetBarTextMode(alwaysShow)
    self.barTextMode = alwaysShow;
    local UPDATE_BAR_TYPE, UPDATE_VALUE = true, true;
    self:UpdateText(UPDATE_BAR_TYPE, UPDATE_VALUE);
end;

--[[
    ZO_UnitFrameObject main class and update functions
--]]

---@type table<string, table>
local UNITFRAME_LAYOUT_DATA =
{
    [GROUP_UNIT_FRAME] =
    {
        keyboard =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 35, 19);
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;

            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 42); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, -140, 42); height = 0; };

            leaderIconData = { width = 16; height = 16; offsetX = 5; offsetY = 5 };

            electionIconData = { offsetX = -45; offsetY = 6 };
        };

        gamepad =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 1);
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;

            indentedNameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 25, 3);

            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 0); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, 0, 35); height = 0; };
            hideHealthBgIfOffline = true;
            baseMinX = 150;
            baseMaxX = 215;
            -- Indented constraints are base constraints minus the width of the leader icon.
            indentedMinX = 125;
            indentedMaxX = 190;
            leaderIconData = { width = 25; height = 25; offsetX = 0; offsetY = 12 };

            electionIconData = { offsetX = 27; offsetY = -13 };
        };
    };

    [RAID_UNIT_FRAME] =
    {
        keyboard =
        {
            highPriorityBuffHighlight =
            {
                left = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_left.dds"; width = 64; height = 64; };
                right = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_right.dds"; width = 32; height = 64; };
                icon = { width = 14; height = 14; customAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 76, 15) };
            };

            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 5, 4);
            nameWidth = 86;

            indentedNameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 19, 4);
            indentedNameWidth = 75;

            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 5, 20); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, -4, 20); height = 15; };

            leaderIconData = { width = 16; height = 16; offsetX = 5; offsetY = 5 }
        };

        gamepad =
        {
            highPriorityBuffHighlight =
            {
                left = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_left.dds"; width = 54; height = 44; };
                right = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_right.dds"; width = 32; height = 44; };
                icon = { width = 14; height = 14; customAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 66, 7) };
            };

            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 6, 3);
            nameWidth = KFS_GAMEPAD_RAID_FRAME_WIDTH - 40;
            indentedNameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 20, 3);
            indentedNameWidth = KFS_GAMEPAD_RAID_FRAME_WIDTH - 52 - 2;
            anchorNameToRight = true;

            leaderIconData = { width = 18; height = 18; offsetX = 2; offsetY = 7 }
        };
    };

    [COMPANION_RAID_UNIT_FRAME] =
    {
        keyboard =
        {
            highPriorityBuffHighlight =
            {
                left = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_left.dds"; width = 64; height = 64; };
                right = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_right.dds"; width = 32; height = 64; };
                icon = { width = 14; height = 14; customAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 76, 15) };
            };

            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 5, 4);
            nameWidth = 86;

            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 5, 20); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, -4, 20); height = 15; };
        };

        gamepad =
        {
            highPriorityBuffHighlight =
            {
                left = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_left.dds"; width = 54; height = 44; };
                right = { texture = "EsoUI/Art/UnitFrames/unitframe_raid_outline_right.dds"; width = 32; height = 44; };
                icon = { width = 14; height = 14; customAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 66, 7) };
            };

            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 6, 2);
            nameWidth = KFS_GAMEPAD_RAID_FRAME_WIDTH - 6;
        };
    };

    [TARGET_UNIT_FRAME] =
    {
        neverHideStatusBar = true;
        showStatusInName = true;
        captionControlName = "Caption";
    };

    [COMPANION_UNIT_FRAME] =
    {
        keyboard =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 35, 19);
            nameWidth = 215;
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;
            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 42); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, -140, 42); height = 0; };
        };

        gamepad =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 1);
            nameWidth = 306;
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;
            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 0); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, 0, 35); height = 0; };
        };
    };
    [COMPANION_GROUP_UNIT_FRAME] =
    {
        keyboard =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 35, 59);
            nameWidth = 215;
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;
            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 36, 82); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, -140, 82); height = 0; };
        };

        gamepad =
        {
            nameAnchor = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 66);
            nameWidth = 306;
            nameWrapMode = TEXT_WRAP_MODE_ELLIPSIS;
            statusData = { anchor1 = ZO_Anchor:New(TOPLEFT, nil, TOPLEFT, 0, 60); anchor2 = ZO_Anchor:New(TOPRIGHT, nil, TOPRIGHT, 0, 88); height = 0; };
        };
    };
};

---
---@param style string
---@return table
local function GetPlatformLayoutData(style)
    local layoutData = UNITFRAME_LAYOUT_DATA[style];
    -- Note: It is assumed that either all platforms are defined, or no platforms are defined.
    local platformKey = KFS_IsGamepadPreferred() and "gamepad" or "keyboard";
    return layoutData[platformKey] or layoutData;
end;

---@type boolean
local FORCE_SHOW = true;
---@type boolean
local PREVENT_SHOW = false;

---
---@param frame Control|nil
---@param styleData table|nil
---@param showOption boolean|nil
---@return nil
local function SetUnitFrameTexture(frame, styleData, showOption)
    if frame and styleData then
        frame:SetTexture(styleData.texture);
        frame:SetDimensions(styleData.width, styleData.height);

        if styleData.customAnchor then
            styleData.customAnchor:Set(frame);
        end;

        if showOption == FORCE_SHOW then
            frame:SetHidden(false); -- never toggles, this is the only chance this frame has of being shown
        end;
    end;
end;

---
---@param statusLabel Control|nil
---@param statusData table|nil
---@return nil
local function LayoutUnitFrameStatus(statusLabel, statusData)
    if statusLabel then
        if statusData then
            statusData.anchor1:Set(statusLabel);
            statusData.anchor2:AddToControl(statusLabel);
            statusLabel:SetHeight(statusData.height);
        end;
        statusLabel:SetHidden(not statusData);
    end;
end;

---
---@param nameLabel Control|nil
---@param layoutData table|nil
---@param indented boolean|nil
---@return nil
local function LayoutUnitFrameName(nameLabel, layoutData, indented)
    if nameLabel and layoutData then
        if layoutData.nameAnchor and not indented then
            layoutData.nameAnchor:Set(nameLabel);
        elseif layoutData.indentedNameAnchor and indented then
            layoutData.indentedNameAnchor:Set(nameLabel);
        end;

        local electionIconControl = nameLabel:GetParent():GetNamedChild("ElectionIcon");
        if electionIconControl then
            if layoutData.anchorNameToRight then
                nameLabel:SetAnchor(RIGHT, electionIconControl, LEFT, 0, 0, ANCHOR_CONSTRAINS_X);
            elseif layoutData.electionIconData then
                electionIconControl:SetAnchor(RIGHT, nil, RIGHT, layoutData.electionIconData.offsetX, layoutData.electionIconData.offsetY);
            end;
        end;

        nameLabel:SetWrapMode(layoutData.nameWrapMode or TEXT_WRAP_MODE_TRUNCATE);

        local nameWidth = layoutData.nameWidth or 0;

        if indented then
            nameLabel:SetWidth(layoutData.indentedNameWidth or nameWidth);
            if layoutData.baseMinX then
                nameLabel:SetDimensionConstraints(layoutData.indentedMinX, 0, layoutData.indentedMaxX, 0);
            end;
        else
            nameLabel:SetWidth(nameWidth);
            if layoutData.indentedMinX then
                nameLabel:SetDimensionConstraints(layoutData.baseMinX, 0, layoutData.baseMaxX, 0);
            end;
        end;
    end;
end;

---
---@param unitFrame KFS_Frame
---@param style string
---@return nil
local function DoUnitFrameLayout(unitFrame, style)
    local layoutData = GetPlatformLayoutData(style);
    if layoutData then
        unitFrame.neverHideStatusBar = layoutData.neverHideStatusBar;

        if layoutData.highPriorityBuffHighlight then
            SetUnitFrameTexture(unitFrame.frame:GetNamedChild("HighPriorityBuffHighlight"), layoutData.highPriorityBuffHighlight.left, PREVENT_SHOW);
            SetUnitFrameTexture(unitFrame.frame:GetNamedChild("HighPriorityBuffHighlightRight"), layoutData.highPriorityBuffHighlight.right, PREVENT_SHOW);
            SetUnitFrameTexture(unitFrame.frame:GetNamedChild("HighPriorityBuffHighlightIcon"), layoutData.highPriorityBuffHighlight.icon, PREVENT_SHOW);

            -- These can't be created in XML because the OnInitialized handler doesn't run until the next frame, just initialize the animations here.
            ZO_AlphaAnimation:New(unitFrame.frame:GetNamedChild("HighPriorityBuffHighlight"));
            ZO_AlphaAnimation:New(unitFrame.frame:GetNamedChild("HighPriorityBuffHighlightIcon"));
        end;

        LayoutUnitFrameName(unitFrame.nameLabel, layoutData);
        LayoutUnitFrameStatus(unitFrame.statusLabel, layoutData.statusData);

        -- NOTE: Level label is always custom and doesn't need to be managed with this anchoring system
    end;
end;

---@class KFS_Frame : KFS_Manager
---@field frame Control
---@field style string
---@field templateName string
---@field hasTarget boolean
---@field hasPendingTarget boolean|nil
---@field unitTag string
---@field dirty boolean|nil
---@field animateShowHide boolean
---@field fadeComponents Control[]
---@field hiddenReasons ZO_HiddenReasons
---@field nameLabel Control|nil
---@field levelLabel Control|nil
---@field captionLabel Control|nil
---@field statusLabel Control|nil
---@field rankIcon Control|nil
---@field assignmentIcon Control|nil
---@field championIcon Control|nil
---@field leftBracket Control|nil
---@field leftBracketGlow Control|nil
---@field leftBracketUnderlay Control|nil
---@field rightBracket Control|nil
---@field rightBracketGlow Control|nil
---@field rightBracketUnderlay Control|nil
---@field barTextMode number
---@field healthBar KFS_Bar
---@field resourceBars table<number, KFS_Bar>
---@field powerBars table<number, KFS_Bar>
---@field lastPowerType number
---@field electionIcon Control|nil
---@field buffTracker table|nil
---@field attributeVisualizer ZO_UnitAttributeVisualizer|nil
---@field hidden boolean|nil
---@field showHideTimeline AnimationTimeline|nil
---@field offsetY number|nil
---@field neverHideStatusBar boolean|nil
---@field cachedHealth number|nil
---@field cachedMaxHealth number|nil
---@field cachedPowers table|nil
---@field cachedNameText string|nil
---@field castBar table|nil
KFS_Frame = KFS_Manager:Subclass();

---
---@param unitTag string
---@param anchors ZO_Anchor|ZO_Anchor[]
---@param barTextMode number
---@param style string
---@param templateName string|nil
---@return nil
function KFS_Frame:Initialize(unitTag, anchors, barTextMode, style, templateName)
    templateName = templateName or style;
    local baseWindowName = templateName .. unitTag;
    local parent = KFS_UnitFrames;

    if ZO_Group_IsGroupUnitTag(unitTag) or IsGroupCompanionUnitTag(unitTag) or unitTag == "companion" then
        parent = KFS_UnitFramesGroups;
    end;

    local layoutData = GetPlatformLayoutData(style);
    if not layoutData then
        return;
    end;

    self.frame = CreateControlFromVirtual(baseWindowName, parent, templateName);
    self.style = style;
    self.templateName = templateName;
    self.hasTarget = false;
    self.unitTag = unitTag;
    self.dirty = true;
    self.animateShowHide = false;
    self.fadeComponents = {};
    self.hiddenReasons = ZO_HiddenReasons:New();

    local nameControlName = layoutData.nameControlName or "Name";
    self.nameLabel = self:AddFadeComponent(nameControlName);

    self.levelLabel = self:AddFadeComponent("Level");

    if layoutData.captionControlName then
        self.captionLabel = self:AddFadeComponent(layoutData.captionControlName);
    end;

    local statusControlName = layoutData.statusControlName or "Status";
    self.statusLabel = self:AddFadeComponent(statusControlName);

    local DONT_COLOR_RANK_ICON = false;
    self.rankIcon = self:AddFadeComponent("RankIcon", DONT_COLOR_RANK_ICON);
    self.assignmentIcon = self:AddFadeComponent("AssignmentIcon", DONT_COLOR_RANK_ICON);
    self.championIcon = self:AddFadeComponent("ChampionIcon");
    self.veterancyRankIcon = self:AddFadeComponent("VeterancyRankIcon");
    self.leftBracket = self:AddFadeComponent("LeftBracket");
    self.leftBracketGlow = self.frame:GetNamedChild("LeftBracketGlow");
    self.leftBracketUnderlay = self.frame:GetNamedChild("LeftBracketUnderlay");
    self.rightBracket = self:AddFadeComponent("RightBracket");
    self.rightBracketGlow = self.frame:GetNamedChild("RightBracketGlow");
    self.rightBracketUnderlay = self.frame:GetNamedChild("RightBracketUnderlay");

    self.barTextMode = barTextMode;

    self.healthBar = KFS_Bar:New(baseWindowName .. "Hp", self.frame, barTextMode, style, COMBAT_MECHANIC_FLAGS_HEALTH);

    if style == COMPANION_RAID_UNIT_FRAME then
        self.healthBar:SetColor(COMBAT_MECHANIC_FLAGS_HEALTH, COMPANION_HEALTH_GRADIENT, COMPANION_HEALTH_GRADIENT_LOSS, COMPANION_HEALTH_GRADIENT_GAIN);
    else
        self.healthBar:SetColor(COMBAT_MECHANIC_FLAGS_HEALTH);
    end;

    self.resourceBars = {};
    self.resourceBars[COMBAT_MECHANIC_FLAGS_HEALTH] = self.healthBar;

    self.powerBars = {};
    self.lastPowerType = 0;
    self.frame.m_unitTag = unitTag;

    self.electionIcon = self.frame:GetNamedChild("ElectionIcon");

    self:SetAnchor(anchors);
    self:ApplyVisualStyle();
    self:RefreshVisible();
end;

---
---@return nil
function KFS_Frame:ApplyVisualStyle()
    DoUnitFrameLayout(self, self.style);
    local frameTemplate = KFS_GetPlatformTemplate(self.templateName);
    ApplyTemplateToControl(self.frame, frameTemplate);

    -- Apply per-style scale to the actual frame, not just anchors
    if KFS_GetScaleForStyle then
        self.frame:SetScale(KFS_GetScaleForStyle(self.style));
    end;

    local isOnline = IsUnitOnline(self.unitTag);
    self:DoAlphaUpdate(IsUnitInGroupSupportRange(self.unitTag));
    self:UpdateDifficulty();

    local healthBar = self.healthBar;
    local barData = GetPlatformBarStyle(healthBar.style, healthBar.mechanic);
    if barData.template then
        local barWidth = barData.centered and barData.barWidth / 2 or barData.barWidth;
        for i, control in ipairs(healthBar.barControls) do
            if self.style ~= TARGET_UNIT_FRAME then
                ApplyTemplateToControl(control, KFS_GetPlatformTemplate(barData.template));
            end;

            barData.barAnchors[i]:Set(control);
            control:SetWidth(barWidth);
            control:SetHeight(barData.barHeight);
        end;

        if #healthBar.barControls == 1 then
            local barAnchor2 = barData.barAnchors[2];
            if barAnchor2 then
                barAnchor2:AddToControl(healthBar.barControls[1]);
            end;
        end;
    end;
    local statusBackground = self.frame:GetNamedChild("Background1");
    if statusBackground then
        statusBackground:SetHidden(not isOnline and barData.hideBgIfOffline);
    end;

    local font = GetPlatformBarFont();
    if healthBar.leftText then
        healthBar.leftText:SetFont(font);
    end;
    if healthBar.rightText then
        healthBar.rightText:SetFont(font);
    end;

    if self.attributeVisualizer then
        self.attributeVisualizer:ApplyPlatformStyle();
    end;

    self:RefreshControls();
end;

---
---@param animate boolean
---@return nil
function KFS_Frame:SetAnimateShowHide(animate)
    self.animateShowHide = animate;
end;

---
---@param name string
---@param setColor boolean|nil
---@return Control|nil
function KFS_Frame:AddFadeComponent(name, setColor)
    local control = self.frame:GetNamedChild(name);
    if control then
        control.setColor = setColor ~= false;
        table.insert(self.fadeComponents, control);
    end;
    return control;
end;

---
---@param isIndented boolean
---@return nil
function KFS_Frame:SetTextIndented(isIndented)
    local layoutData = GetPlatformLayoutData(self.style);
    if layoutData then
        LayoutUnitFrameName(self.nameLabel, layoutData, isIndented);
        LayoutUnitFrameStatus(self.statusLabel, layoutData.statusData);
    end;
end;

---
---@param anchors ZO_Anchor|ZO_Anchor[]
---@return nil
function KFS_Frame:SetAnchor(anchors)
    self.frame:ClearAnchors();
    self.offsetY = anchors:GetOffsetY();

    if type(anchors) == "table" and #anchors >= 2 then
        anchors[1]:Set(self.frame);
        anchors[2]:AddToControl(self.frame);
    else
        anchors:Set(self.frame);
    end;
end;

---
---@param buffTracker table
---@return nil
function KFS_Frame:SetBuffTracker(buffTracker)
    self.buffTracker = buffTracker;
end;

---
---@param reason string
---@param hidden boolean
---@return nil
function KFS_Frame:SetHiddenForReason(reason, hidden)
    if self.hiddenReasons:SetHiddenForReason(reason, hidden) then
        local INSTANT = true;
        self:RefreshVisible(INSTANT);
    end;
end;

---
---@param hasTarget boolean
---@param hasPendingTarget boolean|nil
---@return nil
function KFS_Frame:SetHasTarget(hasTarget, hasPendingTarget)
    self.hasTarget = hasTarget;
    self.hasPendingTarget = hasPendingTarget;
    local ANIMATED = false;
    self:RefreshVisible(ANIMATED);
end;

---
---@return boolean
function KFS_Frame:ComputeHidden()
    if not self.hasTarget and not self.hasPendingTarget then
        return true;
    end;

    return self.hiddenReasons:IsHidden();
end;

---
---@param instant boolean|nil
---@return nil
function KFS_Frame:RefreshVisible(instant)
    local hidden = self:ComputeHidden();
    if hidden ~= self.hidden then
        self.hidden = hidden;
        if not hidden and self.dirty then
            self.dirty = nil;
            self:RefreshControls();
        end;

        if self.animateShowHide and not instant then
            if not self.showHideTimeline then
                self.showHideTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("KFS_UnitFrameFadeAnimation", self.frame);
            end;
            if hidden then
                if self.showHideTimeline:IsPlaying() then
                    self.showHideTimeline:PlayBackward();
                else
                    self.showHideTimeline:PlayFromEnd();
                end;
            else
                if self.showHideTimeline:IsPlaying() then
                    self.showHideTimeline:PlayForward();
                else
                    self.showHideTimeline:PlayFromStart();
                end;
            end;
        else
            if self.showHideTimeline then
                self.showHideTimeline:Stop();
            end;
            self.frame:SetHidden(hidden);
        end;

        if self.buffTracker then
            self.buffTracker:SetDisabled(hidden);
        end;
    end;
end;

---@return integer current
---@return integer max
---@return integer effectiveMax
function KFS_Frame:GetHealth()
    return GetUnitPower(self.unitTag, COMBAT_MECHANIC_FLAGS_HEALTH);
end;

---
---@return nil
function KFS_Frame:RefreshControls()
    if self.hidden then
        self.dirty = true;
    else
        if self.hasTarget then
            self:UpdateName();
            self:UpdateUnitReaction();
            self:UpdateLevel();
            self:UpdateCaption();
            self:RefreshElectionIcon();

            local useCached = false;
            if self.unitTag == "reticleover" then
                local keep = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode;
                useCached = keep and IsReticleHidden();
            elseif self.unitTag == "reticleovertarget" then
                local keep = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode;
                useCached = keep and IsReticleHidden();
            end;

            local health, maxHealth;
            if useCached and self.cachedHealth and self.cachedMaxHealth then
                health, maxHealth = self.cachedHealth, self.cachedMaxHealth;
            else
                health, maxHealth = self:GetHealth();
                self.cachedHealth, self.cachedMaxHealth = health, maxHealth;
            end;
            self.healthBar:Update(COMBAT_MECHANIC_FLAGS_HEALTH, health, maxHealth, FORCE_INIT);

            if useCached and self.cachedPowers then
                for index, data in pairs(self.cachedPowers) do
                    self:UpdatePowerBar(index, data.powerType, data.cur, data.max, FORCE_INIT);
                end;
            else
                self.cachedPowers = self.cachedPowers or {};
                for i = 1, COMBAT_MECHANIC_FLAGS_MAX_INDEX do
                    local powerType, cur, max = GetUnitPowerInfo(self.unitTag, i);
                    self.cachedPowers[i] = { powerType = powerType; cur = cur; max = max };
                    self:UpdatePowerBar(i, powerType, cur, max, FORCE_INIT);
                end;
            end;

            -- Since we have a target, there is nothing pending
            local NOT_PENDING = false;
            self:UpdateStatus(IsUnitDead(self.unitTag), IsUnitOnline(self.unitTag), NOT_PENDING);
            self:UpdateBackground();
            self:UpdateRank();
            self:UpdateAssignment();
            self:UpdateDifficulty();
            self:DoAlphaUpdate(IsUnitInGroupSupportRange(self.unitTag));
        elseif self.hasPendingTarget then
            self:UpdateName();

            -- Since there is technically no unit yet, we need to pretend there is one that is not dead and is online
            local IS_ONLINE = true;
            local NOT_DEAD = false;

            -- Large groups will behave differently than small groups when a companion is pending
            if self.style == COMPANION_RAID_UNIT_FRAME then
                -- Since we don't want large group frames to show any status text, pretend we aren't pending
                local IS_NOT_PENDING = false;
                local NOT_NEARBY = false;
                self:UpdateStatus(NOT_DEAD, IS_ONLINE, IS_NOT_PENDING);
                self:DoAlphaUpdate(NOT_NEARBY);
            else
                local IS_NEARBY = true;
                self:UpdateStatus(NOT_DEAD, IS_ONLINE, self.hasPendingTarget);
                self:DoAlphaUpdate(IS_NEARBY);
            end;
        end;
    end;
end;

---
---@param unitChanged boolean|nil
---@return nil
function KFS_Frame:RefreshUnit(unitChanged)
    local validTarget = DoesUnitExist(self.unitTag);
    local hasPendingTarget = false;
    if self.unitTag == "companion" then
        hasPendingTarget = HasPendingCompanion();
    elseif IsGroupCompanionUnitTag(self.unitTag) then
        local playerGroupTag = GetLocalPlayerGroupUnitTag();
        local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag);
        hasPendingTarget = self.unitTag == playerCompanionTag and HasPendingCompanion();
    end;

    if validTarget then
        if self.unitTag == "reticleovertarget" then
            local localPlayerIsTarget = AreUnitsEqual("player", "reticleover");
            validTarget = KFS_ManagerSingleton:IsTargetOfTargetEnabled() and not localPlayerIsTarget;
        end;
    end;

    -- Keep reticle-related frames visible during cursor/UI mode if user requested
    local keepReticle = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode;
    local keepToT = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode;
    if (self.unitTag == "reticleover" and keepReticle) or (self.unitTag == "reticleovertarget" and keepToT) then
        if IsReticleHidden() then
            -- Preserve previous visibility and data while cursor mode is active
            validTarget = self.hasTarget or validTarget;
        end;
    end;

    if unitChanged or self.hasTarget ~= validTarget then
        MenuOwnerClosed(self.frame);

        if self.castBar then
            self.castBar:UpdateAfterUnitChange();
        end;
    end;

    self:SetHasTarget(validTarget, hasPendingTarget);
end;

---
---@param hidden boolean
---@return nil
function KFS_Frame:SetBarsHidden(hidden)
    self.healthBar:Hide(hidden);
end;

---
---@return boolean|nil
function KFS_Frame:IsHidden()
    return self.hidden;
end;

---
---@return string
function KFS_Frame:GetUnitTag()
    return self.frame.m_unitTag;
end;

---
---@return Control
function KFS_Frame:GetPrimaryControl()
    return self.frame;
end;

---
---@param isNearby boolean
---@return nil
function KFS_Frame:DoAlphaUpdate(isNearby)
    -- Don't fade out just the frame, because that needs to appear correctly (along with BG, etc...)
    -- Just make the status bars and any text on the frame fade out.
    local color;
    if self.unitTag == "reticleover" then
        color = ZO_SELECTED_TEXT;
    else
        color = ZO_HIGHLIGHT_TEXT;
    end;

    local alphaValue = isNearby and FULL_ALPHA_VALUE or FADED_ALPHA_VALUE;
    self.healthBar:SetAlpha(alphaValue);

    for i = 1, #self.fadeComponents do
        local fadeComponent = self.fadeComponents[i];
        if fadeComponent.setColor then
            fadeComponent:SetColor(color:UnpackRGBA());
        end;
        fadeComponent:SetAlpha(alphaValue);
    end;

    if self.attributeVisualizer then
        self.attributeVisualizer:DoAlphaUpdate(isNearby);
    end;
end;

---
---@return table|nil
function KFS_Frame:GetBuffTracker()
    return self.buffTracker;
end;

---
---@param index number
---@param powerType number
---@param cur number
---@param max number
---@param forceInit boolean|nil
---@return nil
function KFS_Frame:UpdatePowerBar(index, powerType, cur, max, forceInit)
    -- Should this bar type ever be displayed?
    if not IsValidBarStyle(self.style, powerType) then
        return;
    end;

    local currentBar = self.powerBars[index];

    if currentBar == nil then
        self.powerBars[index] = KFS_Bar:New(self.frame:GetName() .. "PowerBar" .. index, self.frame, self.barTextMode, self.style, powerType);
        currentBar = self.powerBars[index];

        if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and self.style == COMPANION_RAID_UNIT_FRAME then
            currentBar:SetColor(powerType, COMPANION_HEALTH_GRADIENT, COMPANION_HEALTH_GRADIENT_LOSS, COMPANION_HEALTH_GRADIENT_GAIN);
        else
            currentBar:SetColor(powerType);
        end;
        self.resourceBars[powerType] = currentBar;
    end;

    if currentBar ~= nil then
        currentBar:Update(powerType, cur, max, forceInit);

        currentBar:Hide(powerType == COMBAT_MECHANIC_FLAGS_INVALID);
    end;
end;

-- Global to allow for outside manipulation
---@type table<number, boolean>
KFS_UNIT_FRAMES_SHOW_LEVEL_REACTIONS =
{
    [UNIT_REACTION_PLAYER_ALLY] = true;
};

---@type table<number, boolean>
local HIDE_LEVEL_TYPES =
{
    [UNIT_TYPE_SIEGEWEAPON] = true;
    [UNIT_TYPE_INTERACTFIXTURE] = true;
    [UNIT_TYPE_INTERACTOBJ] = true;
    [UNIT_TYPE_SIMPLEINTERACTFIXTURE] = true;
    [UNIT_TYPE_SIMPLEINTERACTOBJ] = true;
};

---
---@return boolean
function KFS_Frame:ShouldShowLevel()
    -- Show level for players and units with reactions in the show list
    local unitTag = self:GetUnitTag();

    -- Always show level for players
    if IsUnitPlayer(unitTag) then
        return true;
    end;

    -- Never show level for invulnerable guards
    if IsUnitInvulnerableGuard(unitTag) then
        return false;
    end;

    -- Never show level for certain unit types
    local unitType = GetUnitType(unitTag);
    if HIDE_LEVEL_TYPES[unitType] then
        return false;
    end;

    -- Show level if unit reaction is in the show list
    local unitReaction = GetUnitReaction(unitTag);
    if KFS_UNIT_FRAMES_SHOW_LEVEL_REACTIONS[unitReaction] then
        return true;
    end;

    -- Default to not showing level
    return false;
end;

---
---@return boolean
function KFS_Frame:ShouldShowVeterancyInfo()
    -- Show info for remote players when in Veterancy areas
    local unitTag = self:GetUnitTag();
    return IsUnitPlayer(unitTag) and IsVeterancySeasonActive() and IsInVeterancyProgressionZone();
end;

---
---@return nil
function KFS_Frame:UpdateLevel()
    local showLevel = self:ShouldShowLevel();
    local shouldShowVeterancyInfo = self:ShouldShowVeterancyInfo();
    local unitTag = self:GetUnitTag();
    local isChampion = IsUnitChampion(unitTag);
    local unitLevel;
    local veterancyRankData;

    if shouldShowVeterancyInfo then
        unitLevel = GetUnitVeterancyRank(unitTag);
        veterancyRankData = ZO_VeterancyRankData:New(unitLevel);
    elseif isChampion then
        unitLevel = GetUnitEffectiveChampionPoints(unitTag);
    else
        unitLevel = GetUnitLevel(unitTag);
    end;

    if self.levelLabel then
        if showLevel and (veterancyRankData or unitLevel > 0) then
            self.levelLabel:SetHidden(false);
            self.nameLabel:SetAnchor(TOPLEFT, self.levelLabel, TOPRIGHT, 10, 0);
            if veterancyRankData then
                self.levelLabel:SetText(zo_strformat(SI_VETERANCY_RANK_AND_TITLE_FORMATTER, unitLevel, veterancyRankData:GetName()));
            else
                self.levelLabel:SetText(unitLevel);
            end;
        else
            self.levelLabel:SetHidden(true);
            self.nameLabel:SetAnchor(TOPLEFT);
        end;
    end;

    if self.veterancyRankIcon and veterancyRankData then
        self.championIcon:SetHidden(true);
        if unitLevel >= ZO_VETERANCY_MANAGER:GetNumRanks() then
            veterancyRankData = ZO_VeterancyRankData:New(ZO_VETERANCY_MANAGER:GetNumRanks());
        end;
        self.veterancyRankIcon:SetTexture(veterancyRankData:GetIcon());
        self.veterancyRankIcon:SetHidden(false);
    elseif self.championIcon then
        if self.veterancyRankIcon then
            self.veterancyRankIcon:SetHidden(true);
        end;

        if showLevel and isChampion then
            self.championIcon:SetHidden(false);
        else
            self.championIcon:SetHidden(true);
        end;
    end;
end;

---
---@return nil
function KFS_Frame:UpdateRank()
    if self.rankIcon then
        local unitTag = self:GetUnitTag();
        local rank = GetUnitAvARank(unitTag);

        local showRank = rank ~= 0 or IsUnitPlayer(unitTag);
        if showRank then
            local rankIconFile = GetAvARankIcon(rank);
            self.rankIcon:SetTexture(rankIconFile);

            local alliance = GetUnitAlliance(unitTag);
            self.rankIcon:SetColor(GetAllianceColor(alliance):UnpackRGBA());
        end;
        self.rankIcon:SetHidden(not showRank);
    end;
end;

---
---@return nil
function KFS_Frame:UpdateAssignment()
    if self.assignmentIcon then
        local unitTag = self:GetUnitTag();
        local assignmentTexture = nil;
        if IsActiveWorldBattleground() then
            local battlegroundTeam = GetUnitBattlegroundTeam(unitTag);
            if battlegroundTeam ~= BATTLEGROUND_TEAM_INVALID then
                assignmentTexture = ZO_GetBattlegroundTeamIcon(battlegroundTeam);
            end;
        else
            local selectedRole = GetGroupMemberSelectedRole(unitTag);
            if selectedRole ~= LFG_ROLE_INVALID then
                assignmentTexture = ZO_GetRoleIcon(selectedRole);
            end;
        end;

        if assignmentTexture then
            self.assignmentIcon:SetTexture(assignmentTexture);
        end;
        self.assignmentIcon:SetHidden(assignmentTexture == nil);
    end;
end;

---@type table<number, string>
local DIFFICULTY_BRACKET_LEFT_TEXTURE =
{
    [MONSTER_DIFFICULTY_NORMAL] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level2_left.dds";
    [MONSTER_DIFFICULTY_HARD] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level3_left.dds";
    [MONSTER_DIFFICULTY_DEADLY] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level4_left.dds";
};

---@type table<number, string>
local DIFFICULTY_BRACKET_RIGHT_TEXTURE =
{
    [MONSTER_DIFFICULTY_NORMAL] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level2_right.dds";
    [MONSTER_DIFFICULTY_HARD] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level3_right.dds";
    [MONSTER_DIFFICULTY_DEADLY] = "EsoUI/Art/UnitFrames/targetUnitFrame_bracket_level4_right.dds";
};

---@type table<number, string>
local DIFFICULTY_BRACKET_GLOW_LEFT_TEXTURE =
{
    [MONSTER_DIFFICULTY_NORMAL] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level2_left.dds";
    [MONSTER_DIFFICULTY_HARD] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level3_left.dds";
    [MONSTER_DIFFICULTY_DEADLY] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level4_left.dds";
};

---@type table<number, string>
local DIFFICULTY_BRACKET_GLOW_RIGHT_TEXTURE =
{
    [MONSTER_DIFFICULTY_NORMAL] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level2_right.dds";
    [MONSTER_DIFFICULTY_HARD] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level3_right.dds";
    [MONSTER_DIFFICULTY_DEADLY] = "EsoUI/Art/UnitFrames/targetUnitFrame_glowOverlay_level4_right.dds";
};

---@type table<number, string>
local GAMEPAD_DIFFICULTY_BRACKET_TEXTURE =
{
    [MONSTER_DIFFICULTY_NORMAL] = "EsoUI/Art/UnitFrames/Gamepad/gp_targetUnitFrame_bracket_level2.dds";
    [MONSTER_DIFFICULTY_HARD] = "EsoUI/Art/UnitFrames/Gamepad/gp_targetUnitFrame_bracket_level3.dds";
    [MONSTER_DIFFICULTY_DEADLY] = "EsoUI/Art/UnitFrames/Gamepad/gp_targetUnitFrame_bracket_level4.dds";
};

---
---@param difficulty number
---@return nil
function KFS_Frame:SetPlatformDifficultyTextures(difficulty)
    if KFS_IsGamepadPreferred() then
        local texture = GAMEPAD_DIFFICULTY_BRACKET_TEXTURE[difficulty];
        self.leftBracket:SetTexture(texture);
        self.rightBracket:SetTexture(texture);
        self.leftBracketGlow:SetHidden(true);
        self.rightBracketGlow:SetHidden(true);
    else
        self.leftBracket:SetTexture(DIFFICULTY_BRACKET_LEFT_TEXTURE[difficulty]);
        self.rightBracket:SetTexture(DIFFICULTY_BRACKET_RIGHT_TEXTURE[difficulty]);
        self.leftBracketGlow:SetTexture(DIFFICULTY_BRACKET_GLOW_LEFT_TEXTURE[difficulty]);
        self.rightBracketGlow:SetTexture(DIFFICULTY_BRACKET_GLOW_RIGHT_TEXTURE[difficulty]);
        self.leftBracketGlow:SetHidden(false);
        self.rightBracketGlow:SetHidden(false);
    end;
end;

---@type table<number, string>
local CHALLENGE_DIFFICULTY_NAME_LOOKUP =
{
    [OVERLAND_DIFFICULTY_TYPE_BASEGAME] = "basegame";
    [OVERLAND_DIFFICULTY_TYPE_JOURNEYMAN] = "journeyman";
    [OVERLAND_DIFFICULTY_TYPE_ADVENTURER] = "adventurer";
    [OVERLAND_DIFFICULTY_TYPE_VETERAN] = "veteran";
};

---
---@param difficulty number
---@return nil
function KFS_Frame:SetPlatformChallengeDifficultyTextures(difficulty)
    local difficultyName = CHALLENGE_DIFFICULTY_NAME_LOOKUP[difficulty];
    if KFS_IsGamepadPreferred() then
        local texture = string.format("EsoUI/Art/UnitFrames/Gamepad/gp_targetUnitFrame_challengeDifficulty_%s.dds", difficultyName);
        self.leftBracket:SetTexture(texture);
        self.rightBracket:SetTexture(texture);
        self.leftBracketGlow:SetHidden(true);
        self.rightBracketGlow:SetHidden(true);
    else
        self.leftBracket:SetTexture(string.format("EsoUI/Art/UnitFrames/targetUnitFrame_challengeDifficulty_%s_left.dds", difficultyName));
        self.rightBracket:SetTexture(string.format("EsoUI/Art/UnitFrames/targetUnitFrame_challengeDifficulty_%s_right.dds", difficultyName));
        self.leftBracketGlow:SetHidden(true);
        self.rightBracketGlow:SetHidden(true);
    end;
end;

---
---@return nil
function KFS_Frame:UpdateDifficulty()
    if self.leftBracket then
        local unitTag = self:GetUnitTag();
        local isUnitPlayer = IsUnitPlayer(unitTag);
        local difficulty = isUnitPlayer and GetUnitOverlandDifficulty(unitTag) or GetUnitDifficulty(unitTag);

        -- Show difficulty for neutral and hostile NPCs
        local unitReaction = GetUnitReaction(unitTag);
        local showsDifficulty = false;
        if isUnitPlayer and difficulty > OVERLAND_DIFFICULTY_TYPE_BASEGAME then
            showsDifficulty = true;
        elseif (difficulty > MONSTER_DIFFICULTY_EASY) and (unitReaction == UNIT_REACTION_NEUTRAL or unitReaction == UNIT_REACTION_HOSTILE) then
            showsDifficulty = true;
        end;

        self.leftBracket:SetHidden(not showsDifficulty);
        self.rightBracket:SetHidden(not showsDifficulty);
        self.leftBracketUnderlay:SetHidden(true);
        self.rightBracketUnderlay:SetHidden(true);

        if showsDifficulty then
            if isUnitPlayer then
                self:SetPlatformChallengeDifficultyTextures(difficulty);
            else
                self:SetPlatformDifficultyTextures(difficulty);

                if difficulty == MONSTER_DIFFICULTY_DEADLY and not KFS_IsGamepadPreferred() then
                    self.leftBracketUnderlay:SetHidden(false);
                    self.rightBracketUnderlay:SetHidden(false);
                end;

                if unitReaction == UNIT_REACTION_HOSTILE then
                    TriggerTutorial(TUTORIAL_TRIGGER_COMBAT_MONSTER_DIFFICULTY);
                end;
            end;
        end;
    end;
end;

---
---@return nil
function KFS_Frame:UpdateUnitReaction()
    local unitTag = self:GetUnitTag();

    if self.nameLabel then
        if ZO_Group_IsGroupUnitTag(unitTag) then
            local currentNameAlpha = self.nameLabel:GetControlAlpha();
            local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_HIGHLIGHT);
            self.nameLabel:SetColor(r, g, b, currentNameAlpha);
        end;
    end;
end;

---
---@return nil
function KFS_Frame:UpdateName()
    if self.nameLabel then
        -- If user wants to keep reticle frames visible in cursor mode, use cached name while reticle is hidden
        local useCached = false;
        if self.unitTag == "reticleover" then
            local keep = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode;
            useCached = keep and IsReticleHidden();
        elseif self.unitTag == "reticleovertarget" then
            local keep = KhajiitFengShui_UnitFrames_SavedVariables and KhajiitFengShui_UnitFrames_SavedVariables.general and KhajiitFengShui_UnitFrames_SavedVariables.general.context and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget and KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode;
            useCached = keep and IsReticleHidden();
        end;
        if useCached and self.cachedNameText then
            self.nameLabel:SetText(self.cachedNameText);
            return;
        end;

        local name;
        local tag = self.unitTag;
        local pendingCompanionName;
        if self.unitTag == "companion" and HasPendingCompanion() then
            pendingCompanionName = GetCompanionName(GetPendingCompanionDefId());
            name = zo_strformat(SI_COMPANION_NAME_FORMATTER, pendingCompanionName);
        elseif IsGroupCompanionUnitTag(tag) then
            local playerGroupTag = GetLocalPlayerGroupUnitTag();
            local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag);
            if playerCompanionTag == tag and HasPendingCompanion() then
                pendingCompanionName = GetCompanionName(GetPendingCompanionDefId());
                name = zo_strformat(SI_COMPANION_NAME_FORMATTER, pendingCompanionName);
            else
                if self.style == COMPANION_GROUP_UNIT_FRAME and playerCompanionTag ~= tag then
                    name = GetString(SI_UNIT_FRAME_NAME_COMPANION);
                else
                    name = GetUnitName(tag);
                end;
            end;
        elseif IsUnitPlayer(tag) then
            name = ZO_GetPrimaryPlayerNameFromUnitTag(tag);

            local unitDifficulty = GetUnitOverlandDifficulty(tag);
            if unitDifficulty > OVERLAND_DIFFICULTY_TYPE_BASEGAME and GetOverlandDifficultyDisabledReason() == OVERLAND_DIFFICULTY_DISABLED_REASON_NONE then
                -- Both UIs use the gamepad icons in this context.
                local iconPath = ZO_CHALLENGE_DIFFICULTY_ICONS_GAMEPAD[unitDifficulty];
                name = zo_iconTextFormatNoSpaceAlignedRight(iconPath, "115%", "115%", name);
            end;
        else
            name = GetUnitName(tag);

            local playerDifficulty = GetOverlandDifficulty();
            if playerDifficulty > OVERLAND_DIFFICULTY_TYPE_BASEGAME
                and IsUnitMonster(tag)
                and IsUnitAttackable(tag)
                and GetOverlandDifficultyDisabledReason() == OVERLAND_DIFFICULTY_DISABLED_REASON_NONE then
                -- Both UIs use the gamepad icons in this context.
                local iconPath = ZO_CHALLENGE_DIFFICULTY_ICONS_GAMEPAD[playerDifficulty];
                name = zo_iconTextFormatNoSpaceAlignedRight(iconPath, "115%", "115%", name);
            end;
        end;

        local nameText;
        local targetMarkerType = GetUnitTargetMarkerType(tag);
        if targetMarkerType ~= TARGET_MARKER_TYPE_NONE then
            local iconPath = ZO_GetPlatformTargetMarkerIcon(targetMarkerType);
            if self.style == TARGET_UNIT_FRAME then
                nameText = zo_iconTextFormatNoSpaceAlignedRight(iconPath, 20, 20, name);
            else
                nameText = zo_iconTextFormatNoSpace(iconPath, 20, 20, name);
            end;
        else
            nameText = name;
        end;
        self.nameLabel:SetText(nameText);
        self.cachedNameText = nameText;
    end;
end;

---
---@return nil
function KFS_Frame:UpdateBackground()
    if self.style == GROUP_UNIT_FRAME and ZO_Group_IsGroupUnitTag(self.unitTag) then
        local companionTag = GetCompanionUnitTagByGroupUnitTag(self.unitTag);
        local playerGroupTag = GetLocalPlayerGroupUnitTag();
        local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag);
        local isSummoningPlayerCompanion = companionTag == playerCompanionTag and HasPendingCompanion();
        if KFS_IsGamepadPreferred() then
            self.frame:GetNamedChild("Background2"):SetHidden(DoesUnitExist(companionTag) or isSummoningPlayerCompanion);
        else
            self.frame:GetNamedChild("Background1"):SetHidden(DoesUnitExist(companionTag) or isSummoningPlayerCompanion);
        end;
    end;
end;

---
---@return nil
function KFS_Frame:UpdateCaption()
    local captionLabel = self.captionLabel;
    if captionLabel then
        local caption = "";
        local unitTag = self:GetUnitTag();
        if IsUnitPlayer(unitTag) then
            caption = ZO_GetSecondaryPlayerNameWithTitleFromUnitTag(unitTag);
        else
            local unitCaption = GetUnitCaption(unitTag);
            if unitCaption then
                caption = zo_strformat(SI_TOOLTIP_UNIT_CAPTION, unitCaption);
            end;
        end;

        local hideCaption = caption == "";
        captionLabel:SetHidden(hideCaption);
        captionLabel:SetText(caption); -- still set the caption text when empty so we collapse the label for anything anchoring off the bottom of it
    end;
end;

---
---@param isDead boolean
---@param isOnline boolean
---@param isPending boolean
---@return nil
function KFS_Frame:UpdateStatus(isDead, isOnline, isPending)
    local statusLabel = self.statusLabel;
    if statusLabel then
        local hideBars = (isOnline == false) or (isDead == true) or isPending;
        self:SetBarsHidden(hideBars and not self.neverHideStatusBar);
        local layoutData = GetPlatformLayoutData(self.style);
        statusLabel:SetHidden(not hideBars or not layoutData.statusData);

        local statusBackground = self.frame:GetNamedChild("Background1");
        if statusBackground then
            statusBackground:SetHidden(not isOnline and layoutData.hideHealthBgIfOffline);
        end;

        if layoutData and layoutData.showStatusInName then
            if not isOnline then
                statusLabel:SetText("(" .. GetString(SI_UNIT_FRAME_STATUS_OFFLINE) .. ")");
            elseif isDead then
                statusLabel:SetText("(" .. GetString(SI_UNIT_FRAME_STATUS_DEAD) .. ")");
            elseif isPending then
                statusLabel:SetText("(" .. GetString(SI_UNIT_FRAME_STATUS_SUMMONING) .. ")");
            else
                statusLabel:SetText("");
            end;
        else
            if not isOnline then
                statusLabel:SetText(GetString(SI_UNIT_FRAME_STATUS_OFFLINE));
            elseif isDead then
                statusLabel:SetText(GetString(SI_UNIT_FRAME_STATUS_DEAD));
            elseif isPending then
                statusLabel:SetText(GetString(SI_UNIT_FRAME_STATUS_SUMMONING));
            else
                statusLabel:SetText("");
            end;
        end;
    end;
end;

---
---@param inside boolean
---@return nil
function KFS_Frame:SetBarMouseInside(inside)
    self.healthBar:SetMouseInside(inside);
    for _, powerBar in pairs(self.powerBars) do
        powerBar:SetMouseInside(inside);
    end;
end;

---
---@return nil
function KFS_Frame:HandleMouseEnter()
    self:SetBarMouseInside(true);
end;

---
---@return nil
function KFS_Frame:HandleMouseExit()
    self:SetBarMouseInside(false);
end;

---
---@param alwaysShow number
---@return nil
function KFS_Frame:SetBarTextMode(alwaysShow)
    self.healthBar:SetBarTextMode(alwaysShow);
    for _, powerBar in pairs(self.powerBars) do
        powerBar:SetBarTextMode(alwaysShow);
    end;
end;

---
---@param soundTable table
---@return ZO_UnitAttributeVisualizer
function KFS_Frame:CreateAttributeVisualizer(soundTable)
    if not self.attributeVisualizer then
        self.frame.barControls = self.healthBar:GetBarControls();
        self.attributeVisualizer = ZO_UnitAttributeVisualizer:New(self:GetUnitTag(), soundTable, self.frame);
    end;
    return self.attributeVisualizer;
end;

---
---@return nil
function KFS_Frame:RefreshElectionIcon()
    local electionIcon = self.electionIcon;
    if electionIcon then
        if IsUnitOnline(self.unitTag) then
            if not KFS_ManagerSingleton.activeElection and not KFS_ManagerSingleton.endElectionCallback then
                electionIcon:SetHidden(true);
            else
                local electionIconInfo = KFS_ManagerSingleton:GetCombinedGroupSize() > STANDARD_GROUP_SIZE_THRESHOLD and LARGE_GROUP_ELECTION_ICON_INFO or SMALL_GROUP_ELECTION_ICON_INFO;
                local vote = GetGroupElectionVoteByUnitTag(self.unitTag);
                if vote ~= GROUP_VOTE_CHOICE_FOR and not KFS_ManagerSingleton.activeElection then
                    vote = GROUP_VOTE_CHOICE_AGAINST;
                end;
                local voteIconInfo = electionIconInfo[vote];

                electionIcon:SetTexture(voteIconInfo.icon);
                electionIcon:SetColor(voteIconInfo.color:UnpackRGBA());
                electionIcon:SetHidden(false);
            end;
        else
            electionIcon:SetHidden(true);
        end;
    end;
end;

--[[
    UnitFrame Utility functions
--]]

---
---@param unitTag string
---@param unitChanged boolean|nil
---@return nil
function KFS_UpdateWindow(unitTag, unitChanged)
    local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);
    if unitFrame then
        unitFrame:RefreshUnit(unitChanged);
        unitFrame:RefreshControls();
    end;
end;

---
---@return nil
local function CreateGroupAnchorFrames()
    local constants = GetPlatformConstants();

    -- Create small group anchor frame
    local smallFrame = CreateControlFromVirtual("KFS_SmallGroupAnchorFrame", KFS_UnitFramesGroups, "KFS_GroupFrameAnchor");
    smallFrame:SetDimensions(constants.GROUP_FRAME_SIZE_X, (constants.GROUP_FRAME_SIZE_Y + constants.GROUP_FRAME_PAD_Y) * STANDARD_GROUP_SIZE_THRESHOLD);
    KFS_ApplySavedAnchor(smallFrame, "smallGroup", TOPLEFT, TOPLEFT, constants.GROUP_FRAME_BASE_OFFSET_X, constants.GROUP_FRAME_BASE_OFFSET_Y);
    KFS_ApplySavedScale(smallFrame, "smallGroup", 1.0);

    -- Create raid group anchor frames, these are positioned at the default locations
    for i = 1, NUM_SUBGROUPS do
        local raidFrame = CreateControlFromVirtual("KFS_LargeGroupAnchorFrame" .. i, KFS_UnitFramesGroups, "KFS_RaidFrameAnchor");
        raidFrame:SetDimensions(constants.RAID_FRAME_ANCHOR_CONTAINER_WIDTH, constants.RAID_FRAME_ANCHOR_CONTAINER_HEIGHT);

        local groupNameLabel = raidFrame:GetNamedChild("GroupName");
        local battlegroundIconTexture = raidFrame:GetNamedChild("BattlegroundTeam");
        local groupName = zo_strformat(SI_GROUP_SUBGROUP_LABEL, i);
        local assignmentTexture = nil;
        if IsActiveWorldBattleground() then
            local battlegroundTeam = GetUnitBattlegroundTeam("player");
            if battlegroundTeam ~= BATTLEGROUND_TEAM_INVALID then
                assignmentTexture = ZO_GetBattlegroundTeamIcon(battlegroundTeam);
            end;
        end;

        if assignmentTexture then
            groupNameLabel:SetText(zo_iconTextFormat(assignmentTexture, "100%", "100%", groupName));
            battlegroundIconTexture:SetTexture(assignmentTexture);
        else
            groupNameLabel:SetText(groupName);
        end;

        local x, y = GetGroupAnchorFrameOffsets(i, constants.GROUP_STRIDE, constants);
        KFS_ApplySavedAnchor(raidFrame, "raid" .. i, TOPLEFT, TOPLEFT, x, y);
        raidFrame:SetScale(1);
    end;
end;

---
---@return nil
local function UpdateLeaderIndicator()
    KFS_Leader:SetHidden(true);

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);
        local unitFrame = unitTag and KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            if IsUnitGroupLeader(unitTag) then
                KFS_Leader:ClearAnchors();
                local layoutData = GetPlatformLayoutData(unitFrame.style);
                if layoutData.leaderIconData then
                    local data = layoutData.leaderIconData;
                    KFS_Leader:SetDimensions(data.width, data.height);
                    KFS_Leader:SetAnchor(TOPLEFT, unitFrame.frame, TOPLEFT, data.offsetX, data.offsetY);
                    unitFrame:SetTextIndented(true);
                else
                    unitFrame:SetTextIndented(false);
                end;

                KFS_Leader:SetParent(unitFrame.frame);
                KFS_Leader:SetHidden(not layoutData.leaderIconData);
            else
                unitFrame:SetTextIndented(false);
            end;

            unitFrame:UpdateUnitReaction();
        end;
    end;
end;

---
---@return nil
local function UpdateAnchorFrameVisuals()
    local constants = GetPlatformConstants();

    -- Note: Small group anchor frame is currently the same for all platforms.
    local groupFrame = GetControl("KFS_SmallGroupAnchorFrame");
    groupFrame:SetDimensions(constants.GROUP_FRAME_SIZE_X, (constants.GROUP_FRAME_SIZE_Y + constants.GROUP_FRAME_PAD_Y) * STANDARD_GROUP_SIZE_THRESHOLD);
    KFS_ApplySavedAnchor(groupFrame, "smallGroup", TOPLEFT, TOPLEFT, constants.GROUP_FRAME_BASE_OFFSET_X, constants.GROUP_FRAME_BASE_OFFSET_Y);
    KFS_ApplySavedScale(groupFrame, "smallGroup", 1.0);

    -- Raid group anchor frames.
    local raidTemplate = ZO_GetPlatformTemplate("KFS_RaidFrameAnchor");
    for i = 1, NUM_SUBGROUPS do
        local raidFrame = GetControl("KFS_LargeGroupAnchorFrame" .. i);
        ApplyTemplateToControl(raidFrame, raidTemplate);

        -- For some reason, the ModifyTextType attribute on the template isn't being applied to the existing text on the label.
        -- Clearing and setting the text again seems to reapply the ModifyTextType attribute.
        local groupNameControl = raidFrame:GetNamedChild("GroupName");
        groupNameControl:SetText("");

        -- Update the group text if it is supposed to be showing
        if constants.SHOW_GROUP_LABELS then
            local groupName = zo_strformat(SI_GROUP_SUBGROUP_LABEL, i);
            local assignmentTexture = nil;
            if IsActiveWorldBattleground() then
                local battlegroundTeam = GetUnitBattlegroundTeam("player");
                if battlegroundTeam ~= BATTLEGROUND_TEAM_INVALID then
                    assignmentTexture = ZO_GetBattlegroundTeamIcon(battlegroundTeam);
                end;
            end;

            if assignmentTexture then
                groupNameControl:SetText(zo_iconTextFormat(assignmentTexture, "100%", "100%", groupName));
            else
                groupNameControl:SetText(groupName);
            end;
        end;

        -- Update the battleground team icon if it is supposed to be showing
        local battlegroundTeamIcon = raidFrame:GetNamedChild("BattlegroundTeam");
        battlegroundTeamIcon:SetHidden(true);
        if constants.SHOW_BATTLEGROUND_TEAM then
            if i == 1 and IsActiveWorldBattleground() then
                local battlegroundTeam = GetUnitBattlegroundTeam("player");
                if battlegroundTeam ~= BATTLEGROUND_TEAM_INVALID then
                    local assignmentTexture = ZO_GetBattlegroundTeamIcon(battlegroundTeam);
                    if assignmentTexture then
                        battlegroundTeamIcon:SetTexture(assignmentTexture);
                        battlegroundTeamIcon:SetHidden(false);
                    end;
                end;
            end;
        end;

        raidFrame:SetDimensions(constants.RAID_FRAME_ANCHOR_CONTAINER_WIDTH, constants.RAID_FRAME_ANCHOR_CONTAINER_HEIGHT);
        local offsetX, offsetY = GetGroupAnchorFrameOffsets(i, constants.GROUP_STRIDE, constants);
        KFS_ApplySavedAnchor(raidFrame, "raid" .. i, TOPLEFT, TOPLEFT, offsetX, offsetY);
        raidFrame:SetScale(1);
    end;

    CALLBACK_MANAGER:FireCallbacks("OnUnitFrameAnchorsUpdated");
end;

---
---@return nil
local function DoGroupUpdate()
    UpdateLeaderIndicator();
    KFS_ManagerSingleton:UpdateGroupAnchorFrames();
    UpdateAnchorFrameVisuals();
end;

---@type table  <[DerivedStats], table<number, string>>
local TARGET_ATTRIBUTE_VISUALIZER_SOUNDS =
{
    [STAT_HEALTH_MAX] =
    {
        [ATTRIBUTE_BAR_STATE_NORMAL]   = SOUNDS.UAV_MAX_HEALTH_NORMAL_TARGET;
        [ATTRIBUTE_BAR_STATE_EXPANDED] = SOUNDS.UAV_MAX_HEALTH_INCREASED_TARGET;
        [ATTRIBUTE_BAR_STATE_SHRUNK]   = SOUNDS.UAV_MAX_HEALTH_DECREASED_TARGET;
    };
    [STAT_MAGICKA_MAX] =
    {
        [ATTRIBUTE_BAR_STATE_NORMAL]   = SOUNDS.UAV_MAX_MAGICKA_NORMAL_TARGET;
        [ATTRIBUTE_BAR_STATE_EXPANDED] = SOUNDS.UAV_MAX_MAGICKA_INCREASED_TARGET;
        [ATTRIBUTE_BAR_STATE_SHRUNK]   = SOUNDS.UAV_MAX_MAGICKA_DECREASED_TARGET;
    };
    [STAT_STAMINA_MAX] =
    {
        [ATTRIBUTE_BAR_STATE_NORMAL]   = SOUNDS.UAV_MAX_STAMINA_NORMAL_TARGET;
        [ATTRIBUTE_BAR_STATE_EXPANDED] = SOUNDS.UAV_MAX_STAMINA_INCREASED_TARGET;
        [ATTRIBUTE_BAR_STATE_SHRUNK]   = SOUNDS.UAV_MAX_STAMINA_DECREASED_TARGET;
    };
    [STAT_HEALTH_REGEN_COMBAT] =
    {
        [STAT_STATE_INCREASE_GAINED] = SOUNDS.UAV_INCREASED_HEALTH_REGEN_ADDED_TARGET;
        [STAT_STATE_INCREASE_LOST]   = SOUNDS.UAV_INCREASED_HEALTH_REGEN_LOST_TARGET;
        [STAT_STATE_DECREASE_GAINED] = SOUNDS.UAV_DECREASED_HEALTH_REGEN_ADDED_TARGET;
        [STAT_STATE_DECREASE_LOST]   = SOUNDS.UAV_DECREASED_HEALTH_REGEN_LOST_TARGET;
    };
    [STAT_MAGICKA_REGEN_COMBAT] =
    {
        [STAT_STATE_INCREASE_GAINED] = SOUNDS.UAV_INCREASED_MAGICKA_REGEN_ADDED_TARGET;
        [STAT_STATE_INCREASE_LOST]   = SOUNDS.UAV_INCREASED_MAGICKA_REGEN_LOST_TARGET;
        [STAT_STATE_DECREASE_GAINED] = SOUNDS.UAV_DECREASED_MAGICKA_REGEN_ADDED_TARGET;
        [STAT_STATE_DECREASE_LOST]   = SOUNDS.UAV_DECREASED_MAGICKA_REGEN_LOST_TARGET;
    };
    [STAT_STAMINA_REGEN_COMBAT] =
    {
        [STAT_STATE_INCREASE_GAINED] = SOUNDS.UAV_INCREASED_STAMINA_REGEN_ADDED_TARGET;
        [STAT_STATE_INCREASE_LOST]   = SOUNDS.UAV_INCREASED_STAMINA_REGEN_LOST_TARGET;
        [STAT_STATE_DECREASE_GAINED] = SOUNDS.UAV_DECREASED_STAMINA_REGEN_ADDED_TARGET;
        [STAT_STATE_DECREASE_LOST]   = SOUNDS.UAV_DECREASED_STAMINA_REGEN_LOST_TARGET;
    };
    [STAT_ARMOR_RATING] =
    {
        [STAT_STATE_INCREASE_GAINED] = SOUNDS.UAV_INCREASED_ARMOR_ADDED_TARGET;
        [STAT_STATE_INCREASE_LOST]   = SOUNDS.UAV_INCREASED_ARMOR_LOST_TARGET;
        [STAT_STATE_DECREASE_GAINED] = SOUNDS.UAV_DECREASED_ARMOR_ADDED_TARGET;
        [STAT_STATE_DECREASE_LOST]   = SOUNDS.UAV_DECREASED_ARMOR_LOST_TARGET;
    };
    [STAT_POWER] =
    {
        [STAT_STATE_INCREASE_GAINED] = SOUNDS.UAV_INCREASED_POWER_ADDED_TARGET;
        [STAT_STATE_INCREASE_LOST]   = SOUNDS.UAV_INCREASED_POWER_LOST_TARGET;
        [STAT_STATE_DECREASE_GAINED] = SOUNDS.UAV_DECREASED_POWER_ADDED_TARGET;
        [STAT_STATE_DECREASE_LOST]   = SOUNDS.UAV_DECREASED_POWER_LOST_TARGET;
    };
    [STAT_MITIGATION] =
    {
        [STAT_STATE_IMMUNITY_GAINED]    = SOUNDS.UAV_IMMUNITY_ADDED_TARGET;
        [STAT_STATE_IMMUNITY_LOST]      = SOUNDS.UAV_IMMUNITY_LOST_TARGET;
        [STAT_STATE_SHIELD_GAINED]      = SOUNDS.UAV_DAMAGE_SHIELD_ADDED_TARGET;
        [STAT_STATE_SHIELD_LOST]        = SOUNDS.UAV_DAMAGE_SHIELD_LOST_TARGET;
        [STAT_STATE_POSSESSION_APPLIED] = SOUNDS.UAV_POSSESSION_APPLIED_TARGET;
        [STAT_STATE_POSSESSION_REMOVED] = SOUNDS.UAV_POSSESSION_REMOVED_TARGET;
        [STAT_STATE_TRAUMA_GAINED]      = SOUNDS.UAV_TRAUMA_ADDED_TARGET;
        [STAT_STATE_TRAUMA_LOST]        = SOUNDS.UAV_TRAUMA_LOST_TARGET;
    };
};

---
---@param frame KFS_Frame
---@return nil
local function CreateTargetFrameVisualizer(frame)
    local visualizer = frame:CreateAttributeVisualizer(TARGET_ATTRIBUTE_VISUALIZER_SOUNDS);

    visualizer:AddModule(ZO_UnitVisualizer_ArrowRegenerationModule:New());

    ---@type number
    VISUALIZER_ANGLE_NORMAL_WIDTH = 281;
    ---@type number
    VISUALIZER_ANGLE_EXPANDED_WIDTH = 362;
    ---@type number
    VISUALIZER_ANGLE_SHRUNK_WIDTH = 180;
    visualizer:AddModule(ZO_UnitVisualizer_ShrinkExpandModule:New(VISUALIZER_ANGLE_NORMAL_WIDTH, VISUALIZER_ANGLE_EXPANDED_WIDTH, VISUALIZER_ANGLE_SHRUNK_WIDTH));

    ---@type table
    VISUALIZER_ANGLE_ARMOR_DAMAGE_LAYOUT_DATA =
    {
        type = "Angle";
        increasedArmorBgContainerTemplate = "KFS_IncreasedArmorBgContainerAngle";
        increasedArmorFrameContainerTemplate = "KFS_IncreasedArmorFrameContainerAngle";
        decreasedArmorOverlayContainerTemplate = "KFS_DecreasedArmorOverlayContainerAngle";
        increasedPowerGlowTemplate = "KFS_IncreasedPowerGlowAngle";
        increasedArmorOffsets =
        {
            keyboard =
            {
                top = -7;
                bottom = 8;
                left = -15;
                right = 15;
            };
            gamepad =
            {
                top = -8;
                bottom = 9;
                left = -12;
                right = 12;
            }
        }
    };

    visualizer:AddModule(ZO_UnitVisualizer_ArmorDamage:New(VISUALIZER_ANGLE_ARMOR_DAMAGE_LAYOUT_DATA));

    ---@type table
    VISUALIZER_ANGLE_UNWAVERING_LAYOUT_DATA =
    {
        overlayContainerTemplate = "KFS_UnwaveringOverlayContainerAngle";
        overlayOffsets =
        {
            keyboard =
            {
                top = 2;
                bottom = -3;
                left = 6;
                right = -7;
            };
            gamepad =
            {
                top = 4;
                bottom = -2;
                left = 8;
                right = -8;
            }
        }

    };
    visualizer:AddModule(ZO_UnitVisualizer_UnwaveringModule:New(VISUALIZER_ANGLE_UNWAVERING_LAYOUT_DATA));

    ---@type table
    VISUALIZER_ANGLE_POSSESSION_LAYOUT_DATA =
    {
        type                       = "Angle";
        overlayContainerTemplate   = "KFS_PossessionOverlayContainerAngle";
        possessionHaloGlowTemplate = "KFS_PossessionHaloGlowAngle";
        overlayLeftOffset          = 8;
        overlayTopOffset           = 3;
        overlayRightOffset         = -8;
        overlayBottomOffset        = -3;
    };
    visualizer:AddModule(ZO_UnitVisualizer_PossessionModule:New(VISUALIZER_ANGLE_POSSESSION_LAYOUT_DATA));

    ---@type table
    VISUALIZER_ANGLE_POWER_SHIELD_LAYOUT_DATA =
    {
        barLeftOverlayTemplate = "KFS_PowerShieldBarLeftOverlayAngle";
        barRightOverlayTemplate = "KFS_PowerShieldBarRightOverlayAngle";
    };
    visualizer:AddModule(ZO_UnitVisualizer_PowerShieldModule:New(VISUALIZER_ANGLE_POWER_SHIELD_LAYOUT_DATA));
end;

---
---@param frame KFS_Frame
---@param template string
---@param noHealingGradientOverride ZO_ColorDef[]|nil
---@param fakeHealthGradientOverride ZO_ColorDef[]|nil
---@return nil
local function CreateGroupFrameVisualizer(frame, template, noHealingGradientOverride, fakeHealthGradientOverride)
    local visualizer = frame:CreateAttributeVisualizer(TARGET_ATTRIBUTE_VISUALIZER_SOUNDS);

    ---@type table
    local VISUALIZER_POWER_SHIELD_LAYOUT_DATA =
    {
        barLeftOverlayTemplate = template;
        noHealingGradientOverride = noHealingGradientOverride;
        fakeHealthGradientOverride = fakeHealthGradientOverride;
    };
    visualizer:AddModule(ZO_UnitVisualizer_PowerShieldModule:New(VISUALIZER_POWER_SHIELD_LAYOUT_DATA));
end;

---
---@return nil
local function CreateTargetFrame()
    local targetFrameAnchor = ZO_Anchor:New(TOP, GuiRoot, TOP, 0, 88);
    local NO_TEMPLATE = nil;
    local targetFrame = KFS_ManagerSingleton:CreateFrame("reticleover", targetFrameAnchor, KFS_GetContextBarTextMode("reticleover"), "KFS_TargetUnitFrame", NO_TEMPLATE, CreateTargetFrameVisualizer);
    -- Respect user toggle for reticle over/target of target
    KFS_ManagerSingleton:SetFrameHiddenForReason("reticleover", "userDisabled", not KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.enabled);
    KFS_ManagerSingleton:SetFrameHiddenForReason("reticleovertarget", "userDisabled", not KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.enabled);
    targetFrame:SetAnimateShowHide(true);
    local targetControl = targetFrame:GetPrimaryControl();
    KFS_ApplySavedAnchor(targetControl, "target", TOP, TOP, 0, 88);
    -- Scale for target now handled by ApplyVisualStyle/UpdateScaleState; keep initial application for first frame visibility
    KFS_ApplySavedScale(targetControl, "target", 1.0);

    KFS_UpdateWindow("reticleover", UNIT_CHANGED);

    CALLBACK_MANAGER:FireCallbacks("TargetFrameCreated", targetFrame);
end;

---
---@param frame KFS_Frame
---@return nil
local function CreateCompanionGroupFrameVisualizer(frame)
    CreateGroupFrameVisualizer(frame, "KFS_PowerShieldBarGroupFrameOverlay");
end;

---
---@return nil
local function CreateLocalCompanion()
    if not HasActiveCompanion() and not HasPendingCompanion() then
        return;
    end;
    local COMPANION_FRAME_ANCHOR = ZO_Anchor:New(TOPLEFT, GetControl("KFS_SmallGroupAnchorFrame"), TOPLEFT, 0, 0);
    local NO_TEMPLATE = nil;
    local frame = KFS_ManagerSingleton:CreateFrame("companion", COMPANION_FRAME_ANCHOR, KFS_GetContextBarTextMode("companion"), COMPANION_UNIT_FRAME, NO_TEMPLATE, CreateCompanionGroupFrameVisualizer);
    frame:SetHiddenForReason("disabled", IsUnitGrouped("player"));
    KFS_UpdateWindow("companion", UNIT_CHANGED);
end;

---
---@param frameIndex number|nil
---@param unitTag string
---@param groupSize number
---@return nil
local function CreateGroupMember(frameIndex, unitTag, groupSize)
    if frameIndex == nil then
        return;
    end;

    local frameStyle = GROUP_UNIT_FRAME;
    local visualizerTemplate = "KFS_PowerShieldBarGroupFrameOverlay";
    local noHealingGradientOverride;
    if groupSize > STANDARD_GROUP_SIZE_THRESHOLD then
        frameStyle = RAID_UNIT_FRAME;
        visualizerTemplate = "KFS_PowerShieldBarRaidFrameOverlay";
        noHealingGradientOverride = { ZO_ColorDef:New("1D0000"); ZO_ColorDef:New("722323"); };
    end;

    local previousGroupTag = GetGroupUnitTagByIndex(frameIndex - 1);
    local previousCompanionTag = GetCompanionUnitTagByGroupUnitTag(previousGroupTag);
    local anchor = GetGroupFrameAnchor(frameIndex, groupSize, KFS_ManagerSingleton:GetFrame(previousGroupTag), KFS_ManagerSingleton:GetFrame(previousCompanionTag));
    local NO_TEMPLATE = nil;
    ---@param frame KFS_Frame
    local function visualizerSetupFunction(frame)
        CreateGroupFrameVisualizer(frame, visualizerTemplate, noHealingGradientOverride);
    end;

    local frame = KFS_ManagerSingleton:CreateFrame(unitTag, anchor, KFS_GetContextBarTextMode("group"), frameStyle, NO_TEMPLATE, visualizerSetupFunction);

    -- Create the corresponding companion frame for this group member
    local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag);
    if companionTag and frameStyle == GROUP_UNIT_FRAME then
        local companionFrame = KFS_ManagerSingleton:CreateFrame(companionTag, anchor, KFS_GetContextBarTextMode("companion"), COMPANION_GROUP_UNIT_FRAME, NO_TEMPLATE, visualizerSetupFunction);
        companionFrame:SetHiddenForReason("disabled", false);
    end;
    frame:SetHiddenForReason("disabled", false);

    KFS_UpdateWindow(unitTag, UNIT_CHANGED);
    KFS_UpdateWindow(companionTag, UNIT_CHANGED);
end;

---
---@param startIndex number
---@return nil
local function CreateGroupsAfter(startIndex)
    local groupSize = GetGroupSize();
    local combinedGroupSize = KFS_ManagerSingleton:GetCombinedGroupSize();

    for i = startIndex, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);

        if unitTag then
            CreateGroupMember(i, unitTag, combinedGroupSize);
        end;
    end;

    if combinedGroupSize > STANDARD_GROUP_SIZE_THRESHOLD then
        local numCompanionFrames = 0;
        local maxCompanionFrames = zo_min(KFS_ManagerSingleton:GetCompanionGroupSize(), MAX_GROUP_SIZE_THRESHOLD - groupSize);
        if maxCompanionFrames > 0 then
            local noHealingGradientOverride = { ZO_ColorDef:New("1D0000"); ZO_ColorDef:New("722323"); };
            local fakeHealthGradientOverride;
            local visualizerTemplate = "KFS_PowerShieldBarRaidFrameOverlay";
            local function visualizerSetupFunction(frame)
                CreateGroupFrameVisualizer(frame, visualizerTemplate, noHealingGradientOverride, fakeHealthGradientOverride);
            end;

            -- We want to prioritize showing the local player's companion, so do that one first
            local playerGroupTag = GetLocalPlayerGroupUnitTag();
            local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag);
            if playerCompanionTag and (DoesUnitExist(playerCompanionTag) or HasPendingCompanion()) then
                numCompanionFrames = numCompanionFrames + 1;
                local anchor = GetGroupFrameAnchor(groupSize + numCompanionFrames, combinedGroupSize);
                fakeHealthGradientOverride = COMPANION_HEALTH_GRADIENT;
                local NO_TEMPLATE = nil;
                local frame = KFS_ManagerSingleton:CreateFrame(playerCompanionTag, anchor, KFS_GetContextBarTextMode("companion"), COMPANION_RAID_UNIT_FRAME, NO_TEMPLATE, visualizerSetupFunction);
                frame:SetHiddenForReason("disabled", false);
                KFS_UpdateWindow(playerCompanionTag, UNIT_CHANGED);
            end;

            for i = 1, groupSize do
                -- At this point we've either hit the companion frame limit or we've created a frame for every companion. So no need to continue looping
                if numCompanionFrames >= maxCompanionFrames then
                    break;
                end;

                local unitTag = GetGroupUnitTagByIndex(i);
                local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag);
                if companionTag and companionTag ~= playerCompanionTag and DoesUnitExist(companionTag) then
                    numCompanionFrames = numCompanionFrames + 1;
                    local anchor = GetGroupFrameAnchor(groupSize + numCompanionFrames, combinedGroupSize);
                    local NO_TEMPLATE = nil;
                    local frame = KFS_ManagerSingleton:CreateFrame(companionTag, anchor, KFS_GetContextBarTextMode("companion"), COMPANION_RAID_UNIT_FRAME, NO_TEMPLATE, visualizerSetupFunction);
                    frame:SetHiddenForReason("disabled", false);
                    KFS_UpdateWindow(companionTag, UNIT_CHANGED);
                end;
            end;
        end;
    end;

    DoGroupUpdate();
end;

---
---@return nil
local function CreateGroups()
    CreateGroupsAfter(1);
end;

-- Utility to update the style of the current group frames creating a new frame for the unitTag if necessary,
-- hiding frames that are no longer applicable, and creating new frames of the correct style if the group size
-- goes above or below the "small group" or "raid group" thresholds.
---
---@param groupIndex number|nil
---@return nil
local function UpdateGroupFrameStyle(groupIndex)
    local groupSize = GetGroupSize();
    local oldCombinedGroupSize = KFS_ManagerSingleton:GetCombinedGroupSize();

    KFS_ManagerSingleton:SetGroupSize(groupSize);
    KFS_ManagerSingleton:UpdateCompanionGroupSize();

    local combinedGroupSize = KFS_ManagerSingleton:GetCombinedGroupSize();

    local oldLargeGroup = (oldCombinedGroupSize ~= nil) and (oldCombinedGroupSize > STANDARD_GROUP_SIZE_THRESHOLD);
    local newLargeGroup = combinedGroupSize > STANDARD_GROUP_SIZE_THRESHOLD;

    -- In cases where no UI has been setup, the group changes between large and small group sizes, or when
    -- members are removed, we need to run a full update of the UI. These could also be optimized to only
    -- run partial updates if more performance is needed.
    if oldLargeGroup ~= newLargeGroup or oldCombinedGroupSize > combinedGroupSize then
        -- Create all the appropriate frames for the new group member, or in the case of a unit_destroyed
        -- create the small group versions.
        KFS_ManagerSingleton:DisableGroupAndRaidFrames();
        CreateGroups();
    else
        -- Only update the frames of the unit being changed, and those after it in the list for performance
        -- reasons.
        KFS_ManagerSingleton:DisableCompanionRaidFrames();
        CreateGroupsAfter(groupIndex);
    end;
end;

---
---@param unitTag string
---@return nil
local function ReportUnitChanged(unitTag)
    local groupIndex = GetGroupIndexByUnitTag(unitTag);
    KFS_ManagerSingleton:SetGroupIndexDirty(groupIndex);
end;

---
---@return nil
local function UpdateGroupFramesVisualStyle()
    local constants = GetPlatformConstants();

    UpdateAnchorFrameVisuals();

    -- Update all UnitFrame anchors.
    local groupSize = GetGroupSize();
    local combinedGroupSize = KFS_ManagerSingleton:GetCombinedGroupSize();
    local previousUnitTag = nil;
    local previousCompanionTag = nil;
    local numCompanionFrames = 0;
    local maxCompanionFrames = zo_min(KFS_ManagerSingleton:GetCompanionGroupSize(), MAX_GROUP_SIZE_THRESHOLD - groupSize);
    local playerGroupTag = GetLocalPlayerGroupUnitTag();
    local playerCompanionTag = GetCompanionUnitTagByGroupUnitTag(playerGroupTag);
    -- If we are in a large group, make sure we prioritize sorting the player's local companion to the front
    if combinedGroupSize > STANDARD_GROUP_SIZE_THRESHOLD and numCompanionFrames < maxCompanionFrames then
        if playerCompanionTag and (DoesUnitExist(playerCompanionTag) or HasPendingCompanion()) then
            numCompanionFrames = numCompanionFrames + 1;
            local companionUnitFrame = KFS_ManagerSingleton:GetFrame(playerCompanionTag);
            local companionAnchor = GetGroupFrameAnchor(groupSize + numCompanionFrames, combinedGroupSize);
            if companionUnitFrame then
                companionUnitFrame:SetAnchor(companionAnchor);
            end;
        end;
    end;

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = GetGroupUnitTagByIndex(i);
        local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag);
        if unitTag then
            local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);
            local companionUnitFrame = KFS_ManagerSingleton:GetFrame(companionTag);
            local groupUnitAnchor = GetGroupFrameAnchor(i, combinedGroupSize, KFS_ManagerSingleton:GetFrame(previousUnitTag), KFS_ManagerSingleton:GetFrame(previousCompanionTag));
            if unitFrame then
                unitFrame:SetAnchor(groupUnitAnchor);
            end;
            if combinedGroupSize > STANDARD_GROUP_SIZE_THRESHOLD then
                if companionTag ~= playerCompanionTag and numCompanionFrames < maxCompanionFrames and DoesUnitExist(companionTag) then
                    numCompanionFrames = numCompanionFrames + 1;
                    local companionAnchor = GetGroupFrameAnchor(groupSize + numCompanionFrames, combinedGroupSize);
                    if companionUnitFrame then
                        companionUnitFrame:SetAnchor(companionAnchor);
                    end;
                end;
            else
                if companionUnitFrame then
                    companionUnitFrame:SetAnchor(groupUnitAnchor);
                end;
            end;
        end;
        previousUnitTag = unitTag;
        previousCompanionTag = companionTag;
    end;

    -- Update the Group Leader Icon Texture
    KFS_LeaderIcon:SetTexture(constants.GROUP_LEADER_ICON);
end;

---
---@param frame Control
---@return nil
function KFS_HandleMouseReceiveDrag(frame)
    if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
        CallSecureProtected("PlaceInUnitFrame", frame.m_unitTag);
    end;
end;

---
---@param frame Control
---@param button number
---@return nil
function KFS_HandleMouseUp(frame, button)
    local unitTag = frame.m_unitTag;

    if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
        -- dropped something with left click
        if button == MOUSE_BUTTON_INDEX_LEFT then
            CallSecureProtected("PlaceInUnitFrame", unitTag);
        else
            ClearCursor();
        end;

        -- Same deal here...no unitFrame related clicks like targeting or context menus should take place at this point
        return;
    end;
end;

---
---@param frame Control
---@return nil
function KFS_HandleMouseEnter(frame)
    local unitFrame = KFS_ManagerSingleton:GetFrame(frame.m_unitTag);
    if unitFrame then
        unitFrame:HandleMouseEnter();
    end;
end;

---
---@param frame Control
---@return nil
function KFS_HandleMouseExit(frame)
    local unitFrame = KFS_ManagerSingleton:GetFrame(frame.m_unitTag);
    if unitFrame then
        unitFrame:HandleMouseExit();
    end;
end;

---@param ... any
---@return nil
local function RefreshGroups(...)
    DoGroupUpdate();

    for i = 1, MAX_GROUP_SIZE_THRESHOLD do
        local unitTag = ZO_Group_GetUnitTagForGroupIndex(i);
        local companionTag = GetCompanionUnitTagByGroupUnitTag(unitTag);
        KFS_UpdateWindow(unitTag);
        KFS_UpdateWindow(companionTag);
    end;
end;

---
---@return nil
local function RefreshLocalCompanion()
    KFS_ManagerSingleton:SetFrameHiddenForReason("companion", "disabled", IsUnitGrouped("player"));
    KFS_UpdateWindow("companion", UNIT_CHANGED);
end;

---
---@param unitTag string
---@param isDead boolean
---@param isOnline boolean
---@return nil
local function UpdateStatus(unitTag, isDead, isOnline)
    local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);
    if unitFrame then
        unitFrame:UpdateStatus(isDead, isOnline, false);
        unitFrame:DoAlphaUpdate(IsUnitInGroupSupportRange(unitTag));
    end;

    if AreUnitsEqual(unitTag, "reticleover") then
        unitFrame = KFS_ManagerSingleton:GetFrame("reticleover");
        if unitFrame then
            unitFrame:UpdateStatus(isDead, isOnline, false);
        end;
    end;
end;

---
---@param unitTag string
---@return KFS_Frame|nil
function KFS_GetUnitFrame(unitTag)
    return KFS_ManagerSingleton:GetFrame(unitTag);
end;

---
---@param enabled boolean
---@return nil
function KFS_SetEnableTargetOfTarget(enabled)
    KFS_ManagerSingleton:SetEnableTargetOfTarget(enabled);
end;

---
---@return boolean
function KFS_IsTargetOfTargetEnabled()
    return KFS_ManagerSingleton:IsTargetOfTargetEnabled();
end;

---
---@return nil
local function RegisterForEvents()
    --- @param eventId integer
    --- @param unitTag string
    local function OnTargetChanged(eventId, unitTag)
        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);
    end;

    --- @param eventId integer
    --- @param unitTag string
    local function OnUnitCharacterNameChanged(eventId, unitTag)
        KFS_UpdateWindow(unitTag);
    end;

    --- @param eventId integer
    local function OnReticleTargetChanged(eventId)
        KFS_UpdateWindow("reticleover", UNIT_CHANGED);
        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);
    end;

    --- @param unitTag string
    --- @param powerPoolIndex luaindex
    --- @param powerType CombatMechanicFlags
    --- @param powerPool integer
    --- @param powerPoolMax integer
    --- @return nil
    local function PowerUpdateHandlerFunction(unitTag, powerPoolIndex, powerType, powerPool, powerPoolMax)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);
        if unitFrame then
            if powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
                local oldHealth = unitFrame.healthBar.currentValue;
                unitFrame.healthBar:Update(COMBAT_MECHANIC_FLAGS_HEALTH, powerPool, powerPoolMax);
                unitFrame.cachedHealth = powerPool;
                unitFrame.cachedMaxHealth = powerPoolMax;

                if oldHealth ~= nil and oldHealth == 0 then
                    -- Unit went from dead to non dead...update reaction
                    unitFrame:UpdateUnitReaction();
                end;
            else
                unitFrame:UpdatePowerBar(powerPoolIndex, powerType, powerPool, powerPoolMax);
                unitFrame.cachedPowers = unitFrame.cachedPowers or {};
                unitFrame.cachedPowers[powerPoolIndex] = { powerType = powerType; cur = powerPool; max = powerPoolMax };
            end;
        end;
    end;
    ZO_MostRecentPowerUpdateHandler:New("KFS_UnitFrames", PowerUpdateHandlerFunction);

    --- @param eventId integer
    --- @param unitTag string
    local function OnUnitCreated(eventId, unitTag)
        if ZO_Group_IsGroupUnitTag(unitTag) then
            ReportUnitChanged(unitTag);
        elseif IsGroupCompanionUnitTag(unitTag) then
            -- If a group companion unit has been created, mark the corresponding group member dirty
            ReportUnitChanged(GetGroupUnitTagByCompanionUnitTag(unitTag));
        else
            KFS_UpdateWindow(unitTag, UNIT_CHANGED);
        end;
    end;

    --- @param eventId integer
    ---@param unitTag string
    local function OnUnitDestroyed(eventId, unitTag)
        if ZO_Group_IsGroupUnitTag(unitTag) then
            ReportUnitChanged(unitTag);
        elseif IsGroupCompanionUnitTag(unitTag) then
            -- If a group companion unit has been destroyed, mark the corresponding group member dirty
            ReportUnitChanged(GetGroupUnitTagByCompanionUnitTag(unitTag));
        else
            KFS_UpdateWindow(unitTag);
        end;
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param level integer
    local function OnLevelUpdate(eventId, unitTag, level)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:UpdateLevel();
        end;
    end;
    --- @param eventId integer
    --- @param leaderTag string
    local function OnLeaderUpdate(eventId, leaderTag)
        UpdateLeaderIndicator();
    end;

    --- @param eventId integer
    --- @param unitTag string
    local function OnDispositionUpdate(eventId, unitTag)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:UpdateUnitReaction();
        end;
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param status boolean
    local function OnGroupSupportRangeUpdate(eventId, unitTag, status)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:DoAlphaUpdate(status);
            if AreUnitsEqual(unitTag, "reticleover") then
                KFS_ManagerSingleton:GetFrame("reticleover"):DoAlphaUpdate(status);
            end;

            if AreUnitsEqual(unitTag, "reticleovertarget") then
                local targetOfTarget = KFS_ManagerSingleton:GetFrame("reticleovertarget");
                if targetOfTarget then
                    targetOfTarget:DoAlphaUpdate(status);
                end;
            end;
        end;
    end;

    --- - **EVENT_GROUP_UPDATE**
    ---
    --- @param eventId integer
    local function OnGroupUpdate(eventId)
        -- Pretty much anything can happen on a full group update so refresh everything
        KFS_ManagerSingleton:SetGroupSize(GetGroupSize());
        KFS_ManagerSingleton:UpdateCompanionGroupSize();
        KFS_ManagerSingleton:DisableGroupAndRaidFrames();
        CreateGroups();
        KFS_ManagerSingleton:ClearDirty();
    end;

    ---@param eventId integer
    ---@param memberCharacterName string
    ---@param memberDisplayName string
    ---@param isLocalPlayer boolean
    local function OnGroupMemberJoined(eventId, memberCharacterName, memberDisplayName, isLocalPlayer)
        if isLocalPlayer then
            KFS_ManagerSingleton:DisableLocalCompanionFrame();
        end;
        KFS_ManagerSingleton:EndGroupElection(GROUP_ELECTION_RESULT_ABANDONED);
    end;

    --- @param eventId integer
    --- @param memberCharacterName string
    --- @param reason GroupLeaveReason
    --- @param isLocalPlayer boolean
    --- @param isLeader boolean
    --- @param memberDisplayName string
    --- @param actionRequiredVote boolean
    local function OnGroupMemberLeft(eventId, memberCharacterName, reason, isLocalPlayer, isLeader, memberDisplayName, actionRequiredVote)
        if isLocalPlayer then
            RefreshGroups();
            RefreshLocalCompanion();
        end;
        KFS_ManagerSingleton:EndGroupElection(GROUP_ELECTION_RESULT_ABANDONED);
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param isOnline boolean
    local function OnGroupMemberConnectedStateChanged(eventId, unitTag, isOnline)
        UpdateStatus(unitTag, IsUnitDead(unitTag), isOnline);
        KFS_ManagerSingleton:EndGroupElection(GROUP_ELECTION_RESULT_ABANDONED);
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param newRole LFGRole
    local function OnGroupMemberRoleChanged(eventId, unitTag, newRole)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);
        if unitFrame then
            unitFrame:UpdateAssignment();
        end;
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param isDead boolean
    local function OnUnitDeathStateChanged(eventId, unitTag, isDead)
        UpdateStatus(unitTag, isDead, IsUnitOnline(unitTag));
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param rankPoints integer
    --- @param difference integer
    local function OnRankPointUpdate(eventId, unitTag, rankPoints, difference)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:UpdateRank();
        end;
    end;

    --- @param eventId integer
    --- @param unitTag string
    --- @param oldChampionPoints integer
    --- @param currentChampionPoints integer
    local function OnChampionPointsUpdate(eventId, unitTag, oldChampionPoints, currentChampionPoints)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:UpdateLevel();
        end;
    end;

    --- @param eventId integer
    --- @param unitTag string
    local function OnTitleUpdated(eventId, unitTag)
        local unitFrame = KFS_ManagerSingleton:GetFrame(unitTag);

        if unitFrame then
            unitFrame:UpdateCaption();
        end;
    end;

    -- Prevent base ZO_UnitFrames from doing duplicate work alongside KFS
    ---@return nil
    local function KFS_UnregisterDefaultUnitFrames()
        local ev = ZO_UnitFrames;
        ev:UnregisterForEvent(EVENT_TARGET_CHANGED);

        ev:UnregisterForEvent(EVENT_UNIT_CHARACTER_NAME_CHANGED);

        ev:UnregisterForEvent(EVENT_RETICLE_TARGET_CHANGED);
        ev:UnregisterForEvent(EVENT_UNIT_CREATED);
        ev:UnregisterForEvent(EVENT_UNIT_DESTROYED);
        ev:UnregisterForEvent(EVENT_LEVEL_UPDATE);
        ev:UnregisterForEvent(EVENT_LEADER_UPDATE);
        ev:UnregisterForEvent(EVENT_DISPOSITION_UPDATE);
        ev:UnregisterForEvent(EVENT_GROUP_SUPPORT_RANGE_UPDATE);
        ev:UnregisterForEvent(EVENT_GROUP_UPDATE);
        ev:UnregisterForEvent(EVENT_GROUP_MEMBER_JOINED);
        ev:UnregisterForEvent(EVENT_GROUP_MEMBER_LEFT);
        ev:UnregisterForEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS);
        ev:UnregisterForEvent(EVENT_GROUP_MEMBER_ROLE_CHANGED);
        ev:UnregisterForEvent(EVENT_ACTIVE_COMPANION_STATE_CHANGED);
        ev:UnregisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED);
        ev:UnregisterForEvent(EVENT_RANK_POINT_UPDATE);
        ev:UnregisterForEvent(EVENT_CHAMPION_POINT_UPDATE);
        ev:UnregisterForEvent(EVENT_TITLE_UPDATE);
        ev:UnregisterForEvent(EVENT_PLAYER_ACTIVATED);
        ev:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED);
        ev:UnregisterForEvent(EVENT_GUILD_NAME_AVAILABLE);
        ev:UnregisterForEvent(EVENT_GUILD_ID_CHANGED);

        ev:UnregisterForEvent(EVENT_GROUP_ELECTION_REQUESTED);
        ev:UnregisterForEvent(EVENT_GROUP_ELECTION_NOTIFICATION_ADDED);
        ev:UnregisterForEvent(EVENT_GROUP_ELECTION_PROGRESS_UPDATED);
        ev:UnregisterForEvent(EVENT_GROUP_ELECTION_RESULT);
        ev:UnregisterForEvent(EVENT_TARGET_MARKER_UPDATE);
    end;

    -- Aggressive: NOP base initialize and hide/remove base frames
    ---@return nil
    local function KFS_NukeBaseUnitFrames()
        ---@diagnostic disable-next-line: missing-global-doc
        ZO_UnitFrames_Initialize = function () end;
        KFS_UnregisterDefaultUnitFrames();
        if UNIT_FRAMES_FRAGMENT then
            if HUD_SCENE then HUD_SCENE:RemoveFragment(UNIT_FRAMES_FRAGMENT); end;
            if HUD_UI_SCENE then HUD_UI_SCENE:RemoveFragment(UNIT_FRAMES_FRAGMENT); end;
            if SCENE_MANAGER and SCENE_MANAGER.scenes then
                local hud = SCENE_MANAGER.scenes["hud"];
                local hudui = SCENE_MANAGER.scenes["hudui"];
                if hud then hud:RemoveFragment(UNIT_FRAMES_FRAGMENT); end;
                if hudui then hudui:RemoveFragment(UNIT_FRAMES_FRAGMENT); end;
            end;
        end;
        if _G["ZO_UnitFrames"] and _G["ZO_UnitFrames"].SetHidden then
            _G["ZO_UnitFrames"]:SetHidden(true);
        end;
        if _G["ZO_UnitFramesGroups"] and _G["ZO_UnitFramesGroups"].SetHidden then
            _G["ZO_UnitFramesGroups"]:SetHidden(true);
        end;
    end;
    --- @param eventId integer
    --- @param initial boolean
    local function OnPlayerActivated(eventId, initial)
        KFS_NukeBaseUnitFrames();
        KFS_UpdateWindow("reticleover", UNIT_CHANGED);
        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);

        -- do a full update because we probably missed events while loading
        KFS_ManagerSingleton:SetGroupSize();
        KFS_ManagerSingleton:UpdateCompanionGroupSize();
        KFS_ManagerSingleton:DisableGroupAndRaidFrames();
        KFS_ManagerSingleton:DisableLocalCompanionFrame();
        CreateGroups();
        CreateLocalCompanion();
        if KFS_ManagerSingleton.UpdateScaleState then
            KFS_ManagerSingleton:UpdateScaleState();
        end;
    end;

    local INACTIVE_COMPANION_STATES =
    {
        [COMPANION_STATE_INACTIVE] = true;
        [COMPANION_STATE_BLOCKED_PERMANENT] = true;
        [COMPANION_STATE_BLOCKED_TEMPORARY] = true;
        [COMPANION_STATE_HIDDEN] = true;
        [COMPANION_STATE_INITIALIZING] = true;
    };

    local PENDING_COMPANION_STATES =
    {
        [COMPANION_STATE_PENDING] = true;
        [COMPANION_STATE_INITIALIZED_PENDING] = true;
    };

    local ACTIVE_COMPANION_STATES =
    {
        [COMPANION_STATE_ACTIVE] = true;
    };

    -- If this triggers, we will want to make sure the new state is handled in the OnCompanionStateChanged function
    assert(COMPANION_STATE_MAX_VALUE == 7, "A new companion state has been added. Please add it to one of the state tables.");
    --- @param eventId integer
    --- @param newState CompanionState
    --- @param oldState CompanionState
    local function OnCompanionStateChanged(eventId, newState, oldState)
        if INACTIVE_COMPANION_STATES[newState] then
            -- If we are going straight from pending to inactive, we need to manually mark the player unit as having changed since this won't trigger the normal UNIT_DESTROYED event
            if PENDING_COMPANION_STATES[oldState] and IsUnitGrouped("player") then
                ReportUnitChanged(GetLocalPlayerGroupUnitTag());
            end;
            RefreshLocalCompanion();
        elseif PENDING_COMPANION_STATES[newState] then
            if IsUnitGrouped("player") then
                ReportUnitChanged(GetLocalPlayerGroupUnitTag());
            end;
            KFS_ManagerSingleton:DisableLocalCompanionFrame();
            CreateLocalCompanion();
        elseif ACTIVE_COMPANION_STATES[newState] then
            -- We only need to handle the local companion frame here, as the group frames are handled with the UNIT_CREATED event
            KFS_ManagerSingleton:DisableLocalCompanionFrame();
            CreateLocalCompanion();
        else
            assert(false, "Unhandled companion state");
        end;
    end;

    local function OnTargetOfTargetEnabledChanged()
        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);
    end;
    --- @param eventId integer
    --- @param settingSystemType SettingSystemType
    --- @param settingId integer
    local function OnInterfaceSettingChanged(eventId, settingSystemType, settingId)
        -- Groups do not update every frame (they wait for events), so refresh if the primary name option may have changed
        RefreshGroups(eventId);
    end;
    --- @param eventId integer
    local function OnGuildNameAvailable(eventId)
        -- only reticle over can show a guild name in a caption
        local unitFrame = KFS_ManagerSingleton:GetFrame("reticleover");
        if unitFrame then
            unitFrame:UpdateCaption();
        end;
    end;
    --- @param eventId integer
    --- @param unitTag string
    --- @param oldGuildId integer
    --- @param newGuildId integer
    local function OnGuildIdChanged(eventId, unitTag, oldGuildId, newGuildId)
        -- this is filtered to only fire on reticle over unit tag
        local unitFrame = KFS_ManagerSingleton:GetFrame("reticleover");
        if unitFrame then
            unitFrame:UpdateCaption();
        end;
    end;
    --- @param eventId integer
    --- @param descriptor string
    local function OnGroupElectionStarted(eventId, descriptor)
        KFS_ManagerSingleton:BeginGroupElection();
    end;
    --- @param eventId integer
    --- @param electionResult GroupElectionResult
    --- @param descriptor string
    local function OnGroupElectionUpdate(eventId, electionResult, descriptor)
        KFS_ManagerSingleton:UpdateElectionInfo(electionResult);
    end;

    local function OnTargetMarkerUpdate()
        KFS_ManagerSingleton:UpdateNames();
    end;

    KFS_UnitFrames:RegisterForEvent(EVENT_TARGET_CHANGED, OnTargetChanged);
    KFS_UnitFrames:AddFilterForEvent(EVENT_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover");
    KFS_UnitFrames:RegisterForEvent(EVENT_UNIT_CHARACTER_NAME_CHANGED, OnUnitCharacterNameChanged);
    KFS_UnitFrames:AddFilterForEvent(EVENT_UNIT_CHARACTER_NAME_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover");
    KFS_UnitFrames:RegisterForEvent(EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_UNIT_CREATED, OnUnitCreated);
    KFS_UnitFrames:RegisterForEvent(EVENT_UNIT_DESTROYED, OnUnitDestroyed);
    KFS_UnitFrames:RegisterForEvent(EVENT_LEVEL_UPDATE, OnLevelUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_LEADER_UPDATE, OnLeaderUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_DISPOSITION_UPDATE, OnDispositionUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_SUPPORT_RANGE_UPDATE, OnGroupSupportRangeUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_UPDATE, OnGroupUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_MEMBER_CONNECTED_STATUS, OnGroupMemberConnectedStateChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_MEMBER_ROLE_CHANGED, OnGroupMemberRoleChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_ACTIVE_COMPANION_STATE_CHANGED, OnCompanionStateChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, OnUnitDeathStateChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_RANK_POINT_UPDATE, OnRankPointUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_CHAMPION_POINT_UPDATE, OnChampionPointsUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_TITLE_UPDATE, OnTitleUpdated);
    KFS_UnitFrames:RegisterForEvent(EVENT_PLAYER_ACTIVATED, OnPlayerActivated);
    KFS_UnitFrames:RegisterForEvent(EVENT_INTERFACE_SETTING_CHANGED, OnInterfaceSettingChanged);
    KFS_UnitFrames:RegisterForEvent(EVENT_GUILD_NAME_AVAILABLE, OnGuildNameAvailable);
    KFS_UnitFrames:RegisterForEvent(EVENT_GUILD_ID_CHANGED, OnGuildIdChanged);
    KFS_UnitFrames:AddFilterForEvent(EVENT_GUILD_ID_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover");
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_ELECTION_REQUESTED, OnGroupElectionStarted);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, OnGroupElectionStarted);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_ELECTION_PROGRESS_UPDATED, OnGroupElectionUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_GROUP_ELECTION_RESULT, OnGroupElectionUpdate);
    KFS_UnitFrames:RegisterForEvent(EVENT_TARGET_MARKER_UPDATE, OnTargetMarkerUpdate);

    CALLBACK_MANAGER:RegisterCallback("TargetOfTargetEnabledChanged", OnTargetOfTargetEnabledChanged);
end;

-- Saved variables defaults
local KFS_DEFAULTS =
{
    general =
    {
        lockFrames = true;
        positions = {};
        scales = { smallGroup = 1.0; raid = 1.0; target = 1.0 };
        animateShowHide = false;
        alphaNear = 1.0;
        alphaFar = 0.5;
        platformOverride = "auto"; -- "auto" | "keyboard" | "gamepad"
        context =
        {
            reticleover = { enabled = true; barTextMode = 0; keepVisibleInCursorMode = false };
            reticleovertarget = { enabled = true; barTextMode = 0; keepVisibleInCursorMode = false };
            group = { enabled = true; barTextMode = 0 };
            raid = { enabled = true; barTextMode = 0 };
            companion = { enabled = true; barTextMode = 0 };
        };
    };
};

---
---@return boolean shouldInitialize
local function GetEnabledState()
    if LUIE and LUIE.UnitFrames.Enabled == true then
        return false;
    end
    local shouldInitialize = true;
    local savedVars = KhajiitFengShui_SavedVariables;
    if not savedVars or not savedVars["Default"] then
        return shouldInitialize;
    end;

    local accountEntry = savedVars["Default"][GetDisplayName()];
    if not accountEntry then
        return shouldInitialize;
    end;

    local accountWide = accountEntry["$AccountWide"];
    local characterEntry = accountEntry[GetCurrentCharacterId()];

    local profileMode = (accountWide and accountWide.profileMode) or "account";
    -- character profile mode can override if explicitly set
    if characterEntry and characterEntry.profileMode == "character" then
        profileMode = "character";
    end;

    local function interpret(value)
        if value == nil then
            return nil;
        end;
        return value ~= false;
    end;

    if profileMode == "character" then
        local characterEnabled = characterEntry and interpret(characterEntry.unitframesEnabled);
        if characterEnabled ~= nil then
            return characterEnabled;
        end;
    end;

    local accountEnabled = accountWide and interpret(accountWide.unitframesEnabled);
    if accountEnabled ~= nil then
        return accountEnabled;
    end;

    local fallbackCharacterEnabled = characterEntry and interpret(characterEntry.unitframesEnabled);
    if fallbackCharacterEnabled ~= nil then
        return fallbackCharacterEnabled;
    end;

    return shouldInitialize;
end;

--- Init frames
function KFS_Initialize()
    local function OnAddOnLoaded(eventId, name)
        if name == "KhajiitFengShui" then
            local shouldInitialize = GetEnabledState();

            if not shouldInitialize then
                return;
            end;

            CalculateDynamicPlatformConstants();

            -- SavedVars (account-wide)
            KhajiitFengShui_UnitFrames_SavedVariables = ZO_SavedVars:NewAccountWide("KhajiitFengShui_UnitFrames_SavedVariables", 1, nil, KFS_DEFAULTS);
            KhajiitFengShui_UnitFrames_SavedVariables.general.platformOverride = KFS_GetPlatformOverrideStored();

            ---@class KFS_ManagerSingleton : KFS_Manager
            KFS_ManagerSingleton = KFS_Manager:New();
            KFS_UNIT_FRAMES = KFS_ManagerSingleton;

            CreateGroupAnchorFrames();
            RegisterForEvents();

            CreateTargetFrame();
            CreateLocalCompanion();
            CreateGroups();

            -- Apply saved animateShowHide setting to all frames
            KFS_ManagerSingleton:SetAnimateShowHide(KhajiitFengShui_UnitFrames_SavedVariables.general.animateShowHide);

            -- Register unitframes as panels with the main addon for individual movement
            zo_callLater(function ()
                             KFS_RegisterUnitFramePanels();
                         end, 100);

            local function OnGamepadPreferredModeChanged()
                KFS_ManagerSingleton:ApplyVisualStyle();
                UpdateGroupFramesVisualStyle();
                UpdateLeaderIndicator();
            end;
            function KFS_ManagerSingleton:UpdateScaleState()
                if not KFS_ManagerSingleton then return; end;
                KFS_ApplyScaleOnAllFrames(KFS_ManagerSingleton.staticFrames);
                KFS_ApplyScaleOnAllFrames(KFS_ManagerSingleton.groupFrames);
                KFS_ApplyScaleOnAllFrames(KFS_ManagerSingleton.raidFrames);
                KFS_ApplyScaleOnAllFrames(KFS_ManagerSingleton.companionRaidFrames);
                -- Re-evaluate anchor dims/offsets to match new scales
                UpdateGroupFramesVisualStyle();
            end;

            KFS_ManagerSingleton:UpdateScaleState();
            ZO_PlatformStyle:New(OnGamepadPreferredModeChanged);

            -- LibHarvensAddonSettings settings panel (required dependency)
            local settings = LibHarvensAddonSettings:AddAddon("Khajiit Feng Shui UnitFrames",
                                                              {
                                                                  allowDefaults = true;
                                                                  defaultsFunction = function ()
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.platformOverride = KFS_DEFAULTS.general.platformOverride;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.barTextMode = KFS_DEFAULTS.general.context.reticleover.barTextMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.animateShowHide = KFS_DEFAULTS.general.animateShowHide;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.alphaNear = KFS_DEFAULTS.general.alphaNear;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.alphaFar = KFS_DEFAULTS.general.alphaFar;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.scales.smallGroup = KFS_DEFAULTS.general.scales.smallGroup;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.scales.raid = KFS_DEFAULTS.general.scales.raid;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.scales.target = KFS_DEFAULTS.general.scales.target;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.enabled = KFS_DEFAULTS.general.context.reticleover.enabled;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode = KFS_DEFAULTS.general.context.reticleover.keepVisibleInCursorMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.enabled = KFS_DEFAULTS.general.context.reticleovertarget.enabled;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.barTextMode = KFS_DEFAULTS.general.context.reticleovertarget.barTextMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode = KFS_DEFAULTS.general.context.reticleovertarget.keepVisibleInCursorMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.enabled = KFS_DEFAULTS.general.context.group.enabled;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.barTextMode = KFS_DEFAULTS.general.context.group.barTextMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.enabled = KFS_DEFAULTS.general.context.raid.enabled;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.barTextMode = KFS_DEFAULTS.general.context.raid.barTextMode;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.enabled = KFS_DEFAULTS.general.context.companion.enabled;
                                                                      KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.barTextMode = KFS_DEFAULTS.general.context.companion.barTextMode;
                                                                      KFS_ManagerSingleton:ApplyVisualStyle();
                                                                      UpdateGroupFramesVisualStyle();
                                                                      UpdateLeaderIndicator();
                                                                      KFS_ManagerSingleton:UpdateScaleState();
                                                                  end;
                                                              });

            local controls = {};
            local controlCount = 1;

            -- General section
            controls[controlCount] =
            {
                type = LibHarvensAddonSettings.ST_SECTION;
                label = "General";
            };
            controlCount = controlCount + 1;

            -- Platform Layout dropdown only for non-console (console can't access keyboard code paths)
            if not IsConsoleUI() then
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Platform Layout";
                    items =
                    {
                        { name = "Auto";     data = "auto";     };
                        { name = "Keyboard"; data = "keyboard"; };
                        { name = "Gamepad";  data = "gamepad";  };
                    };
                    getFunction = function ()
                        local v = KFS_GetPlatformOverrideStored();
                        if ZO_IsConsoleOrGameCoreUI() then
                            return { data = v; };
                        end;
                        return PLATFORM_OVERRIDE_DISPLAY_NAMES[v] or "Auto";
                    end;
                    setFunction = function (_, _itemName, item)
                        if not KhajiitFengShui_UnitFrames_SavedVariables.general then
                            KhajiitFengShui_UnitFrames_SavedVariables.general = {};
                        end;
                        local stored = KFS_LHASDropdownItemToStoredValue(item, "auto");
                        if stored == "Auto" then stored = "auto"; end;
                        if stored == "Keyboard" then stored = "keyboard"; end;
                        if stored == "Gamepad" then stored = "gamepad"; end;
                        if stored ~= "keyboard" and stored ~= "gamepad" then
                            stored = "auto";
                        end;
                        KhajiitFengShui_UnitFrames_SavedVariables.general.platformOverride = stored;
                        KFS_ManagerSingleton:ApplyVisualStyle();
                        UpdateGroupFramesVisualStyle();
                        UpdateLeaderIndicator();
                    end;
                    default = "Auto";
                };
                controlCount = controlCount + 1;
            end;

            -- Bar Text Mode only for keyboard (doesn't refresh properly on console)
            if not IsConsoleUI() then
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Bar Text Mode";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;
            end;

            controls[controlCount] =
            {
                type = LibHarvensAddonSettings.ST_CHECKBOX;
                label = "Animate Show/Hide";
                getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.animateShowHide; end;
                setFunction = function (value)
                    KhajiitFengShui_UnitFrames_SavedVariables.general.animateShowHide = value;
                    KFS_ManagerSingleton:SetAnimateShowHide(value);
                end;
                default = KFS_DEFAULTS.general.animateShowHide;
            };
            controlCount = controlCount + 1;
            -- Per-Context section (only for keyboard, not console)
            if not IsConsoleUI() then
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_SLIDER;
                    label = "Alpha Near (In Range)";
                    min = 0;
                    max = 1;
                    step = 0.05;
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.alphaNear; end;
                    setFunction = function (value)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.alphaNear = value;
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = KFS_DEFAULTS.general.alphaNear;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_SLIDER;
                    label = "Alpha Far (Out of Range)";
                    min = 0;
                    max = 1;
                    step = 0.05;
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.alphaFar; end;
                    setFunction = function (value)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.alphaFar = value;
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = KFS_DEFAULTS.general.alphaFar;
                };
                controlCount = controlCount + 1;
            end;
            controls[controlCount] =
            {
                type = LibHarvensAddonSettings.ST_SLIDER;
                label = "Group Scale";
                min = 0.5;
                max = 2.0;
                step = 0.05;
                getFunction = function ()
                    return (KhajiitFengShui_UnitFrames_SavedVariables.general.scales and KhajiitFengShui_UnitFrames_SavedVariables.general.scales.smallGroup) or 1.0;
                end;
                setFunction = function (value)
                    KFS_SetScaleValue("smallGroup", value);
                    KFS_ManagerSingleton:UpdateScaleState();
                end;
                default = KFS_DEFAULTS.general.scales.smallGroup;
            };
            controlCount = controlCount + 1;

            controls[controlCount] =
            {
                type = LibHarvensAddonSettings.ST_SLIDER;
                label = "Raid Scale";
                min = 0.5;
                max = 2.0;
                step = 0.05;
                getFunction = function ()
                    return (KhajiitFengShui_UnitFrames_SavedVariables.general.scales and KhajiitFengShui_UnitFrames_SavedVariables.general.scales.raid) or 1.0;
                end;
                setFunction = function (value)
                    KFS_SetScaleValue("raid", value);
                    KFS_ManagerSingleton:UpdateScaleState();
                end;
                default = KFS_DEFAULTS.general.scales.raid;
            };
            controlCount = controlCount + 1;

            controls[controlCount] =
            {
                type = LibHarvensAddonSettings.ST_SLIDER;
                label = "Target Scale";
                min = 0.5;
                max = 2.0;
                step = 0.05;
                getFunction = function ()
                    return (KhajiitFengShui_UnitFrames_SavedVariables.general.scales and KhajiitFengShui_UnitFrames_SavedVariables.general.scales.target) or 1.0;
                end;
                setFunction = function (value)
                    KFS_SetScaleValue("target", value);
                    KFS_ManagerSingleton:UpdateScaleState();
                end;
                default = KFS_DEFAULTS.general.scales.target;
            };
            controlCount = controlCount + 1;

            -- Per-Context section (only for keyboard, not console)
            if not IsConsoleUI() then
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_SECTION;
                    label = "Per-Context";
                };
                controlCount = controlCount + 1;

                -- Reticle Over
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_LABEL;
                    label = "Reticle Over";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Enable Reticle Over";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.enabled; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.enabled = v;
                        KFS_ManagerSingleton:SetFrameHiddenForReason("reticleover", "userDisabled", not v);
                    end;
                    default = KFS_DEFAULTS.general.context.reticleover.enabled;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Reticle Over Bar Text";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Keep Reticle Over Visible in Cursor Mode";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleover.keepVisibleInCursorMode = v;
                    end;
                    default = KFS_DEFAULTS.general.context.reticleover.keepVisibleInCursorMode;
                };
                controlCount = controlCount + 1;

                -- Target of Target
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_LABEL;
                    label = "Target of Target";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Enable Target of Target";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.enabled; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.enabled = v;
                        KFS_ManagerSingleton:SetFrameHiddenForReason("reticleovertarget", "userDisabled", not v);
                        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);
                    end;
                    default = KFS_DEFAULTS.general.context.reticleovertarget.enabled;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Target of Target Bar Text";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Keep Target of Target Visible in Cursor Mode";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.reticleovertarget.keepVisibleInCursorMode = v;
                        KFS_UpdateWindow("reticleovertarget", UNIT_CHANGED);
                    end;
                    default = KFS_DEFAULTS.general.context.reticleovertarget.keepVisibleInCursorMode;
                };
                controlCount = controlCount + 1;

                -- Group
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_LABEL;
                    label = "Group";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Enable Group Frames";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.enabled; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.enabled = v;
                        KFS_ManagerSingleton:SetGroupFramesHiddenForReason("userDisabled", not v);
                    end;
                    default = KFS_DEFAULTS.general.context.group.enabled;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Group Bar Text";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.group.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;

                -- Raid
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_LABEL;
                    label = "Raid";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Enable Raid Frames";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.enabled; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.enabled = v;
                        KFS_ManagerSingleton:SetRaidFramesHiddenForReason("userDisabled", not v);
                    end;
                    default = KFS_DEFAULTS.general.context.raid.enabled;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Raid Bar Text";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.raid.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;

                -- Companion
                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_LABEL;
                    label = "Companion";
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_CHECKBOX;
                    label = "Enable Companion Frames";
                    getFunction = function () return KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.enabled; end;
                    setFunction = function (v)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.enabled = v;
                        KFS_ManagerSingleton:SetCompanionRaidFramesHiddenForReason("userDisabled", not v);
                        RefreshLocalCompanion();
                        CreateLocalCompanion();
                    end;
                    default = KFS_DEFAULTS.general.context.companion.enabled;
                };
                controlCount = controlCount + 1;

                controls[controlCount] =
                {
                    type = LibHarvensAddonSettings.ST_DROPDOWN;
                    label = "Companion Bar Text";
                    items =
                    {
                        { name = "Hidden";     data = KFS_BAR_TEXT_MODE_HIDDEN;     };
                        { name = "Mouse Over"; data = KFS_BAR_TEXT_MODE_MOUSE_OVER; };
                        { name = "Always On";  data = KFS_BAR_TEXT_MODE_SHOWN;      };
                    };
                    getFunction = function ()
                        return KFS_BarTextModeDropdownGet(KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.barTextMode);
                    end;
                    setFunction = function (_, _itemName, item)
                        KhajiitFengShui_UnitFrames_SavedVariables.general.context.companion.barTextMode = KFS_BarTextModeDropdownSet(item);
                        KFS_ManagerSingleton:ApplyVisualStyle();
                    end;
                    default = "Hidden";
                };
                controlCount = controlCount + 1;
            end; -- End IsConsoleUI() check for Per-Context settings

            settings:AddSettings(controls);

            CALLBACK_MANAGER:FireCallbacks("KFS_UnitFramesCreated");
            KFS_UNIT_FRAMES_FRAGMENT = ZO_HUDFadeSceneFragment:New(KFS_UnitFrames);
            HUD_SCENE:AddFragment(KFS_UNIT_FRAMES_FRAGMENT);
            HUD_UI_SCENE:AddFragment(KFS_UNIT_FRAMES_FRAGMENT);
            EVENT_MANAGER:UnregisterForEvent("KFS_OnAddOnLoaded", EVENT_ADD_ON_LOADED);
        end;
    end;

    EVENT_MANAGER:RegisterForEvent("KFS_OnAddOnLoaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded);
end;

---Called from XML
function KFS_OnUpdate()
    if KFS_ManagerSingleton and KFS_ManagerSingleton:GetIsDirty() then
        UpdateGroupFrameStyle(KFS_ManagerSingleton:GetFirstDirtyGroupIndex());
        KFS_ManagerSingleton:ClearDirty();
    end;
end;
