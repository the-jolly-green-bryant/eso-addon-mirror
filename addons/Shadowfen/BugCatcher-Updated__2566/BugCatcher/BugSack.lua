BugCatcher.bugSack = true

local LAM = LibAddonMenu2
local SF = LibSFUtils
local BC_Colors = BugCatcher.colors
local L = GetString

local red = BC_Colors.red
local yellow = BC_Colors.yellow
local white = BC_Colors.white
local grey = BC_Colors.grey

function BugCatcher.SavePosition()
   local x, y
   local win = BugCatcher.frame

   y = win:GetTop()
   x = win:GetLeft()

   if x < 0 then x = 0 end
   if y < 0 then y = 0 end
   BugCatcher.saved.offsetx = x
   BugCatcher.saved.offsety = y
end

-- currently unused
function BugCatcher.ResetPosition()
   BugCatcher.saved.offsetx = 15
   BugCatcher.saved.offsety = 15
end

function BugCatcher.lockWindow()
    if BugCatcher.saved.locked == true  then
        BugCatcher.frame:SetMovable(false)
    else
        BugCatcher.frame:SetMovable(true)
    end
end

function BugCatcher.setPosition()
    local saved = BugCatcher.saved
    BugCatcher.frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, saved.offsetx, saved.offsety)
end

function BugCatcher.createBugSack()

    BugCatcher.frame   = GetWindowManager():CreateTopLevelWindow("BugCatcher_Sack")
    local frame = BugCatcher.frame
    BugCatcher.texture = GetWindowManager():CreateControl("BugCatcher_Sack_Icon", frame, CT_TEXTURE)

    frame:SetDimensions(30, 30)
    frame:SetMouseEnabled(true)
    frame:SetHandler("OnMouseUp",    BugCatcher.clickHandler)
    frame:SetHandler("OnMouseEnter", function() BugCatcher.tooltipHandler(true)  end)
    frame:SetHandler("OnMouseExit",  function() BugCatcher.tooltipHandler(false) end)
    --frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 15, 15)
    BugCatcher.setPosition()
    frame:SetHandler("OnMoveStop", BugCatcher.SavePosition)
    frame:SetAlpha(0.5)
    frame:SetHidden(true)
    frame:SetMovable(not BugCatcher.saved.locked)


    BugCatcher.texture:SetDimensions(30, 30)
    BugCatcher.texture:SetAnchor(LEFT, frame, LEFT, 0, 0)
    BugCatcher.texture:SetTexture("/esoui/art/tooltips/icon_bag.dds")

    BugCatcher.evtmgr:registerEvt(EVENT_ACTION_LAYER_PUSHED, BugCatcher.showSack)
    BugCatcher.evtmgr:registerEvt(EVENT_ACTION_LAYER_POPPED, BugCatcher.hideSack)

    BugCatcher.iconHandler(BugCatcher_Panel)

    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", BugCatcher.iconHandler)
end

function BugCatcher.iconHandler(panel)
    if panel ~= BugCatcher_Panel then return end

    BugCatcher.frame:SetAlpha((#BugCatcherDB > 0) and 1.0 or 0.5)

    if BugCatcher.tipVisible then
        BugCatcher.tooltipHandler()
    end
end

function BugCatcher.tooltipHandler(state)
    if state == false then
        ZO_Tooltips_HideTextTooltip()

        BugCatcher.tipVisible = nil

        return
    end

    InitializeTooltip(InformationTooltip, BugCatcher.frame, TOP, 0, 5)
    InformationTooltip:AddLine(red("BugCatcher"), "ZoFontTooltipTitle")

    ZO_Tooltip_AddDivider(InformationTooltip)

    InformationTooltip:AddLine(SF.str(yellow("Click"), white(SF.str(": ", L(SI_BUGCATCHER_SHOW_LOG)))))
    InformationTooltip:AddLine(SF.str(yellow("Alt Click"), white(SF.str(": ", L(SI_BUGCATCHER_WIPE_BUGS)))))

    ZO_Tooltip_AddDivider(InformationTooltip)

    InformationTooltip:AddLine(grey(SI_BUGCATCHER_HAVE_NO_BUGS))
    InformationTooltip:AddLine(grey(SI_BUGCATCHER_HAVE_BUGS))

    ZO_Tooltip_AddDivider(InformationTooltip)

    if #BugCatcherDB == 30 then
        InformationTooltip:AddLine(L(SI_BUGCATCHER_FULL), "", grey:UnpackRGB())

    else
        InformationTooltip:AddLine(zo_strformat(L(SI_BUGCATCHER_TOTAL_BUGS),
            #BugCatcherDB, (#BugCatcherDB == 1 and "" or "s")), "", grey:UnpackRGB())
    end

    BugCatcher.tipVisible = true
end

function BugCatcher.clickHandler()
    if IsAltKeyDown() then
        BugCatcher.wipeBugs()

    else
        LAM:OpenToPanel(BugCatcher_Panel)
    end
end

function BugCatcher.showSack()
    if not ZO_GameMenu_InGameNavigationContainer:IsHidden() then
        BugCatcher.frame:SetHidden(false)
    end
end

function BugCatcher.hideSack()
    BugCatcher.frame:SetHidden(true)
end