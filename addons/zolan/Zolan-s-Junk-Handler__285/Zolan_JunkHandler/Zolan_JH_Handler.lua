--------------------------------------------------------------------------------
--                   Zolan's Junk Handler (Handlers)
--------------------------------------------------------------------------------
local ZJH       = Zolan_JH
local AddonMenu = ZJH.AddonMenu
local BagCache  = ZJH.BagCache
local Handler   = ZJH.Handler
local Junker    = ZJH.Junker
local Seller    = ZJH.Seller
local ZL        = ZJH.ZL

-- ZO
local EVENT_ADD_ON_LOADED                = EVENT_ADD_ON_LOADED
local EVENT_GAME_CAMERA_UI_MODE_CHANGED  = EVENT_GAME_CAMERA_UI_MODE_CHANGED
local EVENT_INVENTORY_SINGLE_SLOT_UPDATE = EVENT_INVENTORY_SINGLE_SLOT_UPDATE
local EVENT_MANAGER                      = EVENT_MANAGER
local EVENT_OPEN_STORE                   = EVENT_OPEN_STORE
local EVENT_PLAYER_ACTIVATED             = EVENT_PLAYER_ACTIVATED
local d                                  = d
-- Lua
local string                             = string

function Handler:handleOnAddOnLoad(event, addonName)
    if not ZJH.loaded then ZJH:loadVariables() end
    if addonName ~= ZJH.addonName then return  end

    d("Zolan's Junk Handler: Loaded")

    AddonMenu:initializeAddonMenu()
    BagCache:refresh()

    EVENT_MANAGER:UnregisterForEvent("ZJH_OnLoad", EVENT_ADD_ON_LOADED)
    self:loadEventHandlers()
end

function Handler:handleOpenStore()
    ZL:debug("Handler -> handleOpenStore")

    Seller:sellAllJunk()
end

function Handler:handleOpenFence(_,canSell)
    ZL:debug("Handler -> handleOpenFence, can sell: "..tostring(canSell))
	if not canSell then return end

    Seller:sellAllJunk(true)
end

function Handler:handleSingleSlotUpdate(eventID, bagID, slotID, isNew, itemSoundCategory, updateReason)
    ZL:debug("Handler -> handleSingleSlotUpdate")

    Junker:scanSlotForJunk(bagID, slotID, isNew)
end

function Handler:handleGameCameraUIModeChanged()
    ZL:debug("Handler -> handleGameCameraUIModeChanged")

    Junker:scanBackpackForJunk()
end

local function handleGameCameraUIModeChanged()
    Handler:handleGameCameraUIModeChanged()
end

function Handler:handlePlayerActivated()
    ZL:debug("Handler -> handlePlayerActivated")

    ZL:sendMessageToChat(string.format(
        "%s%s Version %s%s%s Loaded.",
        ZJH.Vars.outputHeader,
        ZJH.Vars.defaultColor,
        ZJH.Vars.currencyColor,
        ZJH.appVersion,
        ZJH.Vars.defaultColor
    ), true)

    EVENT_MANAGER:UnregisterForEvent("ZJH_PlayerActivated", EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForEvent("ZJH_GameCameraUIModeChanged", EVENT_GAME_CAMERA_UI_MODE_CHANGED,  handleGameCameraUIModeChanged)
end

local function handleOnAddOnLoad(event, addonName)
    Handler:handleOnAddOnLoad(event, addonName)
end

local function handleOpenStore()
    Handler:handleOpenStore()
end

local function handleOpenFence(...)
    Handler:handleOpenFence(...)
end

local function handleSingleSlotUpdate(eventID, bagID, slotID, isNew, itemSoundCategory, updateReason)
    Handler:handleSingleSlotUpdate(eventID, bagID, slotID, isNew, itemSoundCategory, updateReason)
end

local function handlePlayerActivated()
    Handler:handlePlayerActivated()
end

function Handler:loadEventHandlers()
    EVENT_MANAGER:RegisterForEvent("ZJH_OpenStore",               EVENT_OPEN_STORE,                   handleOpenStore)
	EVENT_MANAGER:RegisterForEvent("ZJH_OpenFence",               EVENT_OPEN_FENCE,                   handleOpenFence)
    EVENT_MANAGER:RegisterForEvent("ZJH_SingleSlotUpdate",        EVENT_INVENTORY_SINGLE_SLOT_UPDATE, handleSingleSlotUpdate)
    EVENT_MANAGER:RegisterForEvent("ZJH_PlayerActivated",         EVENT_PLAYER_ACTIVATED,             handlePlayerActivated)
end

EVENT_MANAGER:RegisterForEvent("ZJH_OnAddOnLoad", EVENT_ADD_ON_LOADED, handleOnAddOnLoad)
