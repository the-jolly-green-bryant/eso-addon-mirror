CitizenAmIBlocking = {
    name = "CitizenAmIBlocking",
    CallbackManager = ZO_CallbackObject:New(),
    hideUi = false
}
local stamReg = 0
local magReg = 0
local oldBlock = false

--Am I actually Blocking?
---CitizenAmIBlocking.name .."Refresh", 100
local function Refresh()
    local blocking = false
    local running = IsShiftKeyDown() and IsPlayerMoving()
    local inCombat = IsUnitInCombat('player')

    if inCombat then
        stamReg = GetPlayerStat(STAT_STAMINA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
        magReg = GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, STAT_BONUS_OPTION_APPLY_BONUS)
    else
        stamReg = GetPlayerStat(STAT_STAMINA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
        magReg = GetPlayerStat(STAT_MAGICKA_REGEN_IDLE, STAT_BONUS_OPTION_APPLY_BONUS)
    end

    if IsBlockActive() and not running and (stamReg==0 or magReg==0) then
        blocking = true
    end

    CitizenAIB:SetHidden(not CitizenAmIBlocking.hideUi and not blocking)
    if not CitizenAIB:IsHidden() then
        CitizenAIB:SetMovable(true)
    end

    if oldBlock ~= blocking then
        CitizenAmIBlocking.CallbackManager:FireCallbacks(CitizenAmIBlocking.name .."BLOCKING_STATE_CHANGE", blocking)
        oldBlock = blocking
    end
end

function CitizenAmIBlocking.Start()
    local CitizenAIB = CreateControl("CitizenAIB", GuiRoot, CT_TOPLEVELCONTROL)
    CitizenAIB:SetDimensions(64, 64)
    CitizenAIB:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, CitizenAddon.combatOptions.amIBlocking.left, CitizenAddon.combatOptions.amIBlocking.top)
    CitizenAIB:SetMouseEnabled(true)
    CitizenAIB:SetMovable(false)
    CitizenAIB:SetClampedToScreen(true)
    CitizenAIB:SetDrawTier(DT_HIGH)
    CitizenAIB:SetHidden(true)
    CitizenAIB:SetHandler("OnMoveStop", function ()
        CitizenAddon.combatOptions.amIBlocking.left = CitizenAIB:GetLeft()
        CitizenAddon.combatOptions.amIBlocking.top = CitizenAIB:GetTop()
    end)
    -- Texture Control
    local texture = CreateControl("CitizenAIB_Texture", CitizenAIB, CT_TEXTURE)
    texture:SetTexture("/esoui/art/lfg/lfg_tank_down_64.dds")
    texture:SetDimensions(50, 50)
    texture:SetAnchor(CENTER, CitizenAIB, CENTER, 0, 0)

    EVENT_MANAGER:RegisterForUpdate(CitizenAmIBlocking.name .."Refresh", 100, Refresh)
end