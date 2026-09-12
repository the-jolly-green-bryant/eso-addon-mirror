TetsuCombatTools = TetsuCombatTools or {}
local T = TetsuCombatTools
local ADDON = "TetsuCombatToolsLink"

local HOLD_MS = 600
local HOLD_KEY = "UI_SHORTCUT_RIGHT_STICK"
local BAG = BAG_WORN or 0
local LINK_STYLE = LINK_STYLE_BRACKETS or 1

local SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_HAND or EQUIP_SLOT_HANDS,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_WRIST,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local group
local attached = false
local holding = false
local holdAt = 0

local function L(key, fallback)
    local loc = T.L or {}
    return loc[key] or fallback or key
end

local function Vars()
    return T.savedVars
end

local function LinkOn()
    local v = Vars()
    return v and v.linkEnabled ~= false
end

local function ForceGroup()
    local v = Vars()
    return not v or v.linkForceGroup ~= false
end

local function GoodLink(link)
    if type(link) ~= "string" or link == "" then
        return false
    end
    local open = link:find("|H", 1, true)
    local close = link:find("|h", 1, true)
    if not open or not close then
        return false
    end
    if not link:find("item:", 1, true) then
        return false
    end
    return true
end

local function SlotLink(slot)
    if slot == nil or not GetItemLink then
        return nil
    end
    local ok, link = pcall(GetItemLink, BAG, slot, LINK_STYLE)
    if ok and GoodLink(link) then
        return link
    end
    ok, link = pcall(GetItemLink, BAG, slot)
    if ok and GoodLink(link) then
        return link
    end
    return nil
end

local function BaseSetId(setId)
    setId = tonumber(setId) or 0
    if setId == 0 then
        return 0
    end
    if GetItemSetUnperfectedSetId then
        local ok, base = pcall(GetItemSetUnperfectedSetId, setId)
        if ok then
            base = tonumber(base) or 0
            if base > 0 then
                return base
            end
        end
    end
    return setId
end

local function SetInfo(link)
    if not link or not GetItemLinkSetInfo then
        return nil
    end
    local ok, hasSet, setName, _bonuses, _numNorm, maxEq, setId = pcall(GetItemLinkSetInfo, link, true)
    if not ok or not hasSet then
        return nil
    end
    setId = BaseSetId(setId)
    if setId == 0 then
        return nil
    end
    return {
        id = setId,
        name = setName,
        max = tonumber(maxEq) or 0,
    }
end

local function NameKey(name)
    if type(name) ~= "string" then
        return ""
    end
    return zo_strlower and zo_strlower(name) or string.lower(name)
end

local function Collect()
    local byId = {}
    local byName = {}
    for i = 1, #SLOTS do
        local link = SlotLink(SLOTS[i])
        if link then
            local info = SetInfo(link)
            if info then
                local nk = NameKey(info.name)
                local row = byId[info.id]
                if not row and nk ~= "" then
                    row = byName[nk]
                end
                if not row then
                    row = {
                        id = info.id,
                        name = info.name,
                        max = info.max,
                        n = 0,
                        link = link,
                    }
                    byId[info.id] = row
                    if nk ~= "" then
                        byName[nk] = row
                    end
                end
                row.n = row.n + 1
                if info.max > row.max then
                    row.max = info.max
                end
                if GoodLink(link) and (not GoodLink(row.link) or (row.max ~= 1 and info.max == 1)) then
                    row.link = link
                end
            end
        end
    end
    local list = {}
    local seen = {}
    for _, row in pairs(byId) do
        if not seen[row] then
            seen[row] = true
            if (row.max == 1 or row.n >= 2) and GoodLink(row.link) then
                list[#list + 1] = row
            end
        end
    end
    table.sort(list, function(a, b)
        local am = a.max == 1 and 0 or a.max
        local bm = b.max == 1 and 0 or b.max
        if am ~= bm then
            return am > bm
        end
        return a.id < b.id
    end)
    return list
end

local function BuildText()
    local list = Collect()
    if #list == 0 then
        return "", 0
    end
    local parts = {}
    for i = 1, #list do
        parts[#parts + 1] = list[i].link
    end
    return table.concat(parts, " "), #list
end

local function PartyChannel()
    if IsUnitGrouped and IsUnitGrouped("player") then
        if IsPlayerInRaid and IsPlayerInRaid() and CHAT_CHANNEL_RAID then
            return CHAT_CHANNEL_RAID
        end
        if CHAT_CHANNEL_PARTY then
            return CHAT_CHANNEL_PARTY
        end
    end
    return CHAT_CHANNEL_SAY
end

local function LocalNote(msg)
    if CHAT_SYSTEM and CHAT_SYSTEM.AddMessage then
        pcall(function()
            CHAT_SYSTEM:AddMessage(msg)
        end)
    elseif d then
        d(msg)
    end
end

local function ChatSys()
    if ZO_GetChatSystem then
        local ok, sys = pcall(ZO_GetChatSystem)
        if ok and sys then
            return sys
        end
    end
    return CHAT_SYSTEM
end

local function ApplyGroupChannel()
    local ch = PartyChannel()
    local sys = ChatSys()
    if sys and sys.SetChannel then
        pcall(function()
            sys:SetChannel(ch)
        end)
    end
    if CHAT_SYSTEM and CHAT_SYSTEM.SetChannel and CHAT_SYSTEM ~= sys then
        pcall(function()
            CHAT_SYSTEM:SetChannel(ch)
        end)
    end
    return ch
end

local function PutInChat(text)
    local force = ForceGroup()
    local channel = nil
    if force then
        channel = ApplyGroupChannel()
    end

    -- Always replace. Append turned leftovers into duplicate / broken links.
    if CHAT_MENU_GAMEPAD and CHAT_MENU_GAMEPAD.textEdit and CHAT_MENU_GAMEPAD.textEdit.SetText then
        local ok = pcall(function()
            CHAT_MENU_GAMEPAD.textEdit:SetText(text)
        end)
        if ok then
            return true
        end
    end
    local sys = ChatSys()
    if sys and sys.StartTextEntry then
        local ok = pcall(function()
            if force then
                sys:StartTextEntry(text, channel or PartyChannel(), nil, true)
            else
                sys:StartTextEntry(text)
            end
        end)
        if ok then
            return true
        end
    end
    return false
end

function T.LinkBuild()
    if not LinkOn() then
        return
    end
    local text, n = BuildText()
    if n == 0 or text == "" then
        LocalNote(L("LINK_EMPTY", "No sets to link."))
        return
    end
    if not PutInChat(text) then
        LocalNote(text)
    end
end

local function StopHold()
    holding = false
    holdAt = 0
    EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Hold")
end

local function TickHold()
    if not holding then
        StopHold()
        return
    end
    if GetFrameTimeMilliseconds() - holdAt >= HOLD_MS then
        StopHold()
        T.LinkBuild()
    end
end

local function OnHoldDown()
    if not LinkOn() then
        return
    end
    holding = true
    holdAt = GetFrameTimeMilliseconds()
    EVENT_MANAGER:UnregisterForUpdate(ADDON .. "Hold")
    EVENT_MANAGER:RegisterForUpdate(ADDON .. "Hold", 50, TickHold)
end

local function MakeGroup()
    group = {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        {
            name = function()
                return L("LINK_HOLD", "Hold R3: sets")
            end,
            keybind = HOLD_KEY,
            order = 500,
            visible = function()
                return LinkOn()
            end,
            enabled = function()
                return LinkOn()
            end,
            callback = OnHoldDown,
        },
    }
end

local function StripAdd()
    if not group or not KEYBIND_STRIP then
        return
    end
    pcall(function()
        KEYBIND_STRIP:AddKeybindButtonGroup(group)
    end)
end

local function StripRemove()
    StopHold()
    if not group or not KEYBIND_STRIP then
        return
    end
    pcall(function()
        KEYBIND_STRIP:RemoveKeybindButtonGroup(group)
    end)
end

local function HookScene(scene)
    if not scene or not scene.RegisterCallback then
        return
    end
    scene:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_SHOWING then
            if LinkOn() then
                StripAdd()
            end
        elseif newState == SCENE_HIDING or newState == SCENE_HIDDEN then
            StripRemove()
        end
    end)
end

function T.LinkRefresh()
    if not LinkOn() then
        StripRemove()
    end
end

function T.LinkStart()
    if attached then
        return
    end
    attached = true
    MakeGroup()
    if SCENE_MANAGER and SCENE_MANAGER.GetScene then
        HookScene(SCENE_MANAGER:GetScene("gamepadChatMenu"))
    end
    if CHAT_MENU_GAMEPAD_SCENE then
        HookScene(CHAT_MENU_GAMEPAD_SCENE)
    end
end
