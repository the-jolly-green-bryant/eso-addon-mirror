if ShowMyChat == nil then ShowMyChat = {} end
ShowMyChat.addonName = "ShowMyChat"
ShowMyChat.addonVersion = 150

local LAM = LibAddonMenu2

ShowMyChat.defaults = {
    delay = 100,
    mode_store = "keep",
    mode_bank = "keep",
    mode_gbank = "keep",
    mode_gstore = "keep", 
    mode_crafting = "keep",
    mode_stables = "keep",
    mode_outfitting = "keep",
    mode_preview = "show",
    mode_armory = "keep",
    mode_scrying = "keep",
    mode_excavating = "keep",
    mode_tot = "keep",
    enable_store = true,
    enable_bank = true,
    enable_gbank = true,
    enable_gstore = true, 
    enable_crafting = true,
    enable_stables = true,
    enable_outfitting = true,
    enable_preview = true,
    enable_armory = true,
    enable_scrying = true,
    enable_excavating = true,
    enable_tot = true,
}

ShowMyChat.flag_interacting_with_armory_station = false

function ShowMyChat.Activate(self, mode, extra)
    extra = extra or 0
    self.prev_state = CHAT_SYSTEM.isMinimized
    if mode == "show" or mode == "keep" and self.prev_state == false then
        zo_callLater(function() CHAT_SYSTEM:Maximize() end, self.config.delay + extra)
    elseif mode == "hide" then
        zo_callLater(function() CHAT_SYSTEM:Minimize() end, self.config.delay + extra)
    end
end

function ShowMyChat.Deactivate(self, mode)
    if mode == "show" and self.prev_state == true or mode == "keep" and self.prev_state == true then
        zo_callLater(function() CHAT_SYSTEM:Minimize() end, self.config.delay)
    elseif mode == "hide"  and self.prev_state == false then
        zo_callLater(function() CHAT_SYSTEM:Maximize() end, self.config.delay)
    end
end

--
-- Vendors
function ShowMyChat.EvtBeginStore()
    ShowMyChat:Activate(ShowMyChat.config.mode_store)
end

function ShowMyChat.EvtEndStore()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_store)
end

--
-- Banks
function ShowMyChat.EvtBeginBank()
    ShowMyChat:Activate(ShowMyChat.config.mode_bank)
end

function ShowMyChat.EvtEndBank()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_bank)
end

--
-- Guild Banks
function ShowMyChat.EvtBeginGuildBank()
    ShowMyChat:Activate(ShowMyChat.config.mode_gbank)
end

function ShowMyChat.EvtEndGuildBank()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_gbank)
end

--
-- Guild Stores
function ShowMyChat.EvtBeginGuildStore()
    ShowMyChat:Activate(ShowMyChat.config.mode_gstore)
end

function ShowMyChat.EvtEndGuildStore()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_gstore)
end

--
-- Crafting stations
function ShowMyChat.EvtBeginCrafting()
    ShowMyChat:Activate(ShowMyChat.config.mode_crafting)
end

function ShowMyChat.EvtEndCrafting()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_crafting)
end

--
-- Stables
function ShowMyChat.EvtBeginStables()
    ShowMyChat:Activate(ShowMyChat.config.mode_stables)
end

function ShowMyChat.EvtEndStables()
    ShowMyChat:Deactivate(ShowMyChat.config.mode_stables)
end

--
-- Outfit and dye stations
function ShowMyChat.EvtBeginOutfitting(evtid, arg1, arg2)
    if arg2 == "Outfit Station" then
        ShowMyChat:Activate(ShowMyChat.config.mode_outfitting, 250)
    end
end

function ShowMyChat.EvtEndOutfitting(evtid, arg1, arg2)
    if arg1 == 31 then
        ShowMyChat:Deactivate(ShowMyChat.config.mode_outfitting)
    end
end

--
-- Preview menus
function ShowMyChat.EvtHandlePreview(evtid)
    if ShowMyChat.config.mode_preview == "show" then 
        zo_callLater(function() CHAT_SYSTEM:Maximize() end, ShowMyChat.config.delay)
    elseif ShowMyChat.config.mode_preview == "hide" then
        zo_callLater(function() CHAT_SYSTEM:Minimize() end, ShowMyChat.config.delay)
    end
end

--
-- Armory station and NPCs
function ShowMyChat.EvtBeginArmory(evtid, arg1, arg2)
    if arg2 == "Armory Station" then
        ShowMyChat.flag_interacting_with_armory_station = true
        ShowMyChat:Activate(ShowMyChat.config.mode_armory, 250)
    elseif evtid == EVENT_OPEN_ARMORY_MENU then
        if not ShowMyChat.flag_interacting_with_armory_station then
            ShowMyChat:Activate(ShowMyChat.config.mode_armory)
        end
    end
end

function ShowMyChat.EvtEndArmory(evtid, arg1)
    if arg1 == 43 then 
        ShowMyChat.flag_interacting_with_armory_station = false
        ShowMyChat:Deactivate(ShowMyChat.config.mode_armory)
    end
end

--
-- Scrying
function ShowMyChat.EvtHandleScrying(evtid, arg1, arg2, arg3)
    if arg3 == "Scrying" then
        if arg2 == 0 then 
            ShowMyChat:Activate(ShowMyChat.config.mode_scrying)
        elseif arg2 == 1 then 
            ShowMyChat:Deactivate(ShowMyChat.config.mode_scrying)
        end
    end
end

function ShowMyChat.EvtEndScrying(evtid, arg1, arg2)
    if arg1 == true then
        ShowMyChat:Deactivate(ShowMyChat.config.mode_scrying)
    end
end

--
-- Excavating
function ShowMyChat.EvtBeginExcavating(evtid, arg1, arg2)
    if arg2 == "Dig Site" then
        if arg1 == 0 then
            ShowMyChat:Activate(ShowMyChat.config.mode_excavating, 1000)
        end
    end
end

function ShowMyChat.EvtEndExcavating(evtid)
    ShowMyChat:Deactivate(ShowMyChat.config.mode_excavating)
end

--
-- Tales of Tribute
function ShowMyChat.EvtHandleToT(evtid, arg1)
    if arg1 == 1 then
        ShowMyChat:Activate(ShowMyChat.config.mode_tot)
    elseif arg1 == 0 then 
        ShowMyChat:Deactivate(ShowMyChat.config.mode_tot)
    end
end

function ShowMyChat.Init(self)

    self.config = ZO_SavedVars:NewAccountWide("ShowMyChatVars", 1, nil, ShowMyChat.defaults)

    LAM:RegisterAddonPanel(self.addonName.."Panel", ShowMyChat.panel_addon)
    LAM:RegisterOptionControls(self.addonName.."Panel", ShowMyChat.panel_options)

    if self.config.enable_store then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_OPEN_STORE, self.EvtBeginStore)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_CLOSE_STORE, self.EvtEndStore)
    end

    if self.config.enable_bank then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_OPEN_BANK, self.EvtBeginBank)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_CLOSE_BANK, self.EvtEndBank)
    end

    if self.config.enable_gbank then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_OPEN_GUILD_BANK, self.EvtBeginGuildBank)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_CLOSE_GUILD_BANK, self.EvtEndGuildBank)
    end

    if self.config.enable_gstore then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_OPEN_TRADING_HOUSE, self.EvtBeginGuildStore)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_CLOSE_TRADING_HOUSE, self.EvtEndGuildStore)
    end

    if self.config.enable_stables then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_STABLE_INTERACT_START, self.EvtBeginStables)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_STABLE_INTERACT_STOP, self.EvtEndStables)
    end

    if self.config.enable_crafting then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_CRAFTING_STATION_INTERACT, self.EvtBeginCrafting)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_END_CRAFTING_STATION_INTERACT, self.EvtEndCrafting)
    end

    if self.config.enable_outfitting then
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Outfitting",  EVENT_CLIENT_INTERACT_RESULT, self.EvtBeginOutfitting)
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Outfitting",  EVENT_INTERACTION_ENDED, self.EvtEndOutfitting)
    end

    if self.config.enable_preview then 
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Preview",  EVENT_ITEM_PREVIEW_READY, self.EvtHandlePreview)
    end

    if self.config.enable_armory then
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Armory",  EVENT_CLIENT_INTERACT_RESULT, self.EvtBeginArmory)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_OPEN_ARMORY_MENU, self.EvtBeginArmory)
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Armory",  EVENT_INTERACTION_ENDED, self.EvtEndArmory)
    end

    if self.config.enable_scrying then
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Scrying",  EVENT_REMOTE_SCENE_REQUEST, self.EvtHandleScrying)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_SCRYING_EXIT_RESPONSE, self.EvtEndScrying)
    end

    if self.config.enable_excavating then
        EVENT_MANAGER:RegisterForEvent(self.addonName.."Excavating",  EVENT_CLIENT_INTERACT_RESULT, self.EvtBeginExcavating)
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_STOP_ANTIQUITY_DIGGING, self.EvtEndExcavating)
    end

    if self.config.enable_tot then
        EVENT_MANAGER:RegisterForEvent(self.addonName,  EVENT_TRIBUTE_GAME_FLOW_STATE_CHANGE, self.EvtHandleToT)
    end
    
end

function ShowMyChat.OnAddonLoaded(event, addonName)
    if addonName == ShowMyChat.addonName then
        EVENT_MANAGER:UnregisterForEvent(ShowMyChat.addonName, EVENT_ADD_ON_LOADED)
        ShowMyChat:Init()
    end
end

EVENT_MANAGER:RegisterForEvent(ShowMyChat.addonName, EVENT_ADD_ON_LOADED, ShowMyChat.OnAddonLoaded)