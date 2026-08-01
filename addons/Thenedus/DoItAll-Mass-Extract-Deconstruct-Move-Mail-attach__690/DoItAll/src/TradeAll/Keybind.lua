DoItAll = DoItAll or {}

local keystripDef = {
    name = "Trade All",
    keybind = "SC_BANK_ALL",
    callback = function() DoItAll.AddAll() end,
    alignment = KEYBIND_STRIP_ALIGN_LEFT,
	visible = function() return true end,
}
table.insert(TRADE.keybindStripDescriptor, keystripDef)

--[[ OLD
local function TradeSceneStateChanged(oldState, newState)
  if newState == SCENE_SHOWING then
    KEYBIND_STRIP:AddKeybindButtonGroup(keystripDef)
  elseif newState == SCENE_HIDDEN then
    KEYBIND_STRIP:RemoveKeybindButtonGroup(keystripDef)
  end
end
local tradeScene = SCENE_MANAGER:GetScene("trade")
tradeScene:RegisterCallback("StateChange", TradeSceneStateChanged)
]]

local function tradeFailed()
    --Remove the old keybind if there is still one activated
    if DoItAll.currentKeyStripDef ~= nil then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
    end
    --Reset the current keybind strip def
    DoItAll.currentKeyStripDef = nil
end

EVENT_MANAGER:RegisterForEvent("DoItAllTradeAccepted", EVENT_TRADE_INVITE_ACCEPTED, function()
    --Remove the old keybind if there is still one activated
    if DoItAll.currentKeyStripDef ~= nil then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(DoItAll.currentKeyStripDef)
    end
    --Add the keystrip def to the global vars so we can reach it from everywhere
    DoItAll.currentKeyStripDef = keystripDef
end)
EVENT_MANAGER:RegisterForEvent("DoItAllTradeFailed1", EVENT_TRADE_INVITE_CANCELED, function()
    tradeFailed()
end)
EVENT_MANAGER:RegisterForEvent("DoItAllTradeFailed2", EVENT_TRADE_INVITE_FAILED, function()
    tradeFailed()
end)