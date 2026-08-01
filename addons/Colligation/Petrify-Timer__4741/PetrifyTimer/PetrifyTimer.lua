--------------------------------------------------
-- Petrify Timer
-- Version: 4.0
-- Author: @Hardmodes
--
-- MIT License
-- Copyright (c) 2026 @Hardmodes
--------------------------------------------------

d("[PetrifyTimer] LUA FILE LOADED")


PetrifyTimer = {}
PetrifyTimer.name = "PetrifyTimer"


--------------------------------------------------
-- CC ABILITY IDS
--------------------------------------------------

local TARGET_IDS =
{
    [259138] = "Petrify",
    [54931]  = "Fossilize",
    [32678]  = "Shattering Rocks",
}


--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local DODGE_TIME = 1.0


--------------------------------------------------
-- VARIABLES
--------------------------------------------------

PetrifyTimer.control = nil
PetrifyTimer.label = nil
PetrifyTimer.icon = nil
PetrifyTimer.border = nil

PetrifyTimer.saved = nil

PetrifyTimer.locked = false
PetrifyTimer.editMode = false


PetrifyTimer.stats =
{
    totalCC = 0,
}


--------------------------------------------------
-- CREATE UI
--------------------------------------------------

function PetrifyTimer:CreateUI()

    local wm = WINDOW_MANAGER


    self.control =
        wm:CreateTopLevelWindow("PetrifyTimerUI")


    self.control:SetDimensions(
        320,
        80
    )


    self.control:SetScale(
        self.saved.scale
    )


    self.control:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        self.saved.x,
        self.saved.y
    )


    self.control:SetHidden(true)


    self.control:SetMovable(true)
    self.control:SetMouseEnabled(true)
    self.control:SetClampedToScreen(true)



    self.control:SetHandler(
        "OnMouseDown",
        function(_,button)

            if button == MOUSE_BUTTON_INDEX_LEFT
            and not self.locked then

                self.control:StartMoving()

            end

        end
    )



    self.control:SetHandler(
        "OnMouseUp",
        function(_,button)

            if button == MOUSE_BUTTON_INDEX_LEFT
            and not self.locked then

                self.control:StopMoving()


                local x,y =
                    self.control:GetCenter()


                local ux,uy =
                    GuiRoot:GetCenter()


                self.saved.x = x - ux
                self.saved.y = y - uy

            end

        end
    )



    --------------------------------------------------
    -- BACKGROUND
    --------------------------------------------------

    local bg =
        wm:CreateControl(
            nil,
            self.control,
            CT_BACKDROP
        )


    bg:SetAnchorFill()


    bg:SetCenterColor(
        0,
        0,
        0,
        0.85
    )


    --------------------------------------------------
    -- RED FLASH BORDER
    --------------------------------------------------

    self.border =
        wm:CreateControl(
            nil,
            self.control,
            CT_BACKDROP
        )


    self.border:SetAnchorFill()


    self.border:SetCenterColor(
        0,
        0,
        0,
        0
    )


    self.border:SetEdgeColor(
        1,
        0,
        0,
        1
    )



    --------------------------------------------------
    -- PETRIFY ICON
    --------------------------------------------------

    self.icon =
        wm:CreateControl(
            nil,
            self.control,
            CT_TEXTURE
        )


    self.icon:SetDimensions(
        55,
        55
    )


    self.icon:SetAnchor(
        LEFT,
        self.control,
        LEFT,
        10,
        0
    )


    self.icon:SetTexture(
        "/esoui/art/icons/ability_earth_03.dds"
    )



    --------------------------------------------------
    -- TEXT
    --------------------------------------------------

    self.label =
        wm:CreateControl(
            nil,
            self.control,
            CT_LABEL
        )


    self.label:SetFont(
        "ZoFontWinH1"
    )


    self.label:SetAnchor(
        LEFT,
        self.icon,
        RIGHT,
        15,
        0
    )


    self.label:SetText(
        "ROLL NOW FN"
    )


end



--------------------------------------------------
-- ANIMATIONS
--------------------------------------------------

function PetrifyTimer:StartAnimations()


    EVENT_MANAGER:RegisterForUpdate(
        self.name.."IconPulse",
        50,
        function()


            if self.icon then

                local scale =
                    1 +
                    (math.sin(GetFrameTimeSeconds()*6)*0.15)


                self.icon:SetScale(
                    scale
                )

            end

        end
    )



    EVENT_MANAGER:RegisterForUpdate(
        self.name.."BorderFlash",
        50,
        function()


            if self.border then

                local alpha =
                    math.abs(
                        math.sin(
                            GetFrameTimeSeconds()*5
                        )
                    )


                self.border:SetEdgeColor(
                    1,
                    0,
                    0,
                    alpha
                )

            end

        end
    )

end



function PetrifyTimer:StopAnimations()


    EVENT_MANAGER:UnregisterForUpdate(
        self.name.."IconPulse"
    )


    EVENT_MANAGER:UnregisterForUpdate(
        self.name.."BorderFlash"
    )


    if self.icon then
        self.icon:SetScale(1)
    end


    if self.border then
        self.border:SetEdgeColor(
            1,
            0,
            0,
            1
        )
    end


end
--------------------------------------------------
-- CC IMMUNITY CHECK
--------------------------------------------------

local function HasCCImmunity(unitTag)

    for i = 1, 40 do

        local name,
        icon,
        timeStarted,
        timeEnding,
        stackCount,
        buffType,
        effectSlot,
        abilityType,
        statusEffectType,
        abilityId =
            GetUnitBuffInfo(unitTag, i)


        if not abilityId then
            break
        end


        -- Generic CC immunity detection
        if buffType == BUFF_TYPE_BENEFICIAL then

            if statusEffectType == STATUS_EFFECT_TYPE_CC_IMMUNITY then
                return true
            end

        end

    end


    return false

end



--------------------------------------------------
-- TIMER
--------------------------------------------------

--------------------------------------------------
-- TIMER
--------------------------------------------------

function PetrifyTimer:StartTimer(ccName)


    local endTime =
        GetFrameTimeSeconds()
        + DODGE_TIME


    self.control:SetHidden(false)


    self:StartAnimations()



    EVENT_MANAGER:RegisterForUpdate(
        self.name.."Timer",
        10,
        function()


            local remaining =
                endTime - GetFrameTimeSeconds()



            if remaining <= 0 then


                self.control:SetHidden(true)


                self:StopAnimations()


                EVENT_MANAGER:UnregisterForUpdate(
                    self.name.."Timer"
                )


            else


                self.label:SetText(
                    "ROLL NOW FN"
                )


            end


        end
    )

end



--------------------------------------------------
-- COMBAT EVENT
--------------------------------------------------

function PetrifyTimer:CombatEvent(
    eventCode,
    result,
    isError,
    abilityName,
    abilityGraphic,
    abilityActionSlotType,
    sourceName,
    sourceType,
    targetName,
    targetType,
    hitValue,
    powerType,
    damageType,
    log,
    sourceUnitId,
    targetUnitId,
    abilityId
)


    if targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end



    local ccName =
        TARGET_IDS[abilityId]



    if not ccName then
        return
    end



    if result == ACTION_RESULT_BEGIN
    or result == ACTION_RESULT_EFFECT_GAINED
    or result == ACTION_RESULT_APPLIED then



        -- Ignore CC when immune
        if HasCCImmunity("player") then
            return
        end



        self.stats.totalCC =
            self.stats.totalCC + 1



        ZO_Alert(
            UI_ALERT_CATEGORY_ERROR,
            SOUNDS.ABILITY_FAILED,
            ccName
        )


        self:StartTimer(
            ccName
        )


    end

end



--------------------------------------------------
-- COMMANDS
--------------------------------------------------

SLASH_COMMANDS["/petrifytest"] = function()

    PetrifyTimer:StartTimer(
        "TEST"
    )

    d(
        "[PetrifyTimer] Test Activated"
    )

end



SLASH_COMMANDS["/petrifystats"] = function()

    d(
        "|c00FF00Petrify Stats|r"
    )


    d(
        "Total CC Hits: "
        .. PetrifyTimer.stats.totalCC
    )

end



SLASH_COMMANDS["/petrifyhelp"] = function()

    d(
        "|cFF0000Petrify Timer Commands|r"
    )

    d("/petrifytest")
    d("/petrifystats")
    d("/petrifyedit")
    d("/petrifyscale 1.5")
    d("/petrifylock")
    d("/petrifyunlock")
    d("/petrifyreset")

end



SLASH_COMMANDS["/petrifyedit"] = function()


    PetrifyTimer.editMode =
        not PetrifyTimer.editMode



    PetrifyTimer.control:SetHidden(
        not PetrifyTimer.editMode
    )


    PetrifyTimer.label:SetText(
        "MOVE ME"
    )


    d(
        "[PetrifyTimer] Edit Mode"
    )

end



SLASH_COMMANDS["/petrifyscale"] = function(value)


    local scale =
        tonumber(value)



    if scale then


        PetrifyTimer.saved.scale =
            scale


        PetrifyTimer.control:SetScale(
            scale
        )


        d(
            "[PetrifyTimer] Scale "..scale
        )

    end


end



SLASH_COMMANDS["/petrifylock"] = function()

    PetrifyTimer.locked = true

    PetrifyTimer.saved.locked = true


    d(
        "[PetrifyTimer] Locked"
    )

end



SLASH_COMMANDS["/petrifyunlock"] = function()

    PetrifyTimer.locked = false

    PetrifyTimer.saved.locked = false


    d(
        "[PetrifyTimer] Unlocked"
    )

end



SLASH_COMMANDS["/petrifyreset"] = function()


    PetrifyTimer.saved.x = 0
    PetrifyTimer.saved.y = 200
    PetrifyTimer.saved.scale = 1



    PetrifyTimer.control:SetScale(1)


    PetrifyTimer.control:SetAnchor(
        CENTER,
        GuiRoot,
        CENTER,
        0,
        200
    )


    d(
        "[PetrifyTimer] Reset"
    )

end



--------------------------------------------------
-- LOAD
--------------------------------------------------

local function OnAddonLoaded(
    event,
    addonName
)


    if addonName ~= PetrifyTimer.name then
        return
    end



    EVENT_MANAGER:UnregisterForEvent(
        PetrifyTimer.name,
        EVENT_ADD_ON_LOADED
    )



    PetrifyTimer.saved =
        ZO_SavedVars:NewAccountWide(
            "PetrifyTimerSaved",
            1,
            nil,
            {

                x = 0,
                y = 200,

                scale = 1,

                locked = false,

                totalCC = 0,

            }
        )



    PetrifyTimer.locked =
        PetrifyTimer.saved.locked



    PetrifyTimer.stats.totalCC =
        PetrifyTimer.saved.totalCC



    PetrifyTimer:CreateUI()



    EVENT_MANAGER:RegisterForEvent(
        PetrifyTimer.name,
        EVENT_COMBAT_EVENT,
        function(...)
            PetrifyTimer:CombatEvent(...)
        end
    )



    d(
        "[PetrifyTimer] Loaded Successfully"
    )

end



EVENT_MANAGER:RegisterForEvent(
    PetrifyTimer.name,
    EVENT_ADD_ON_LOADED,
    OnAddonLoaded
)