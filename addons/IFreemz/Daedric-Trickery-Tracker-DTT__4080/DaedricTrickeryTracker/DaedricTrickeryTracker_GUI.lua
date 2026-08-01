local wm = WINDOW_MANAGER

local MIN_ICON_SIZE = 20; local MAX_ICON_SIZE = 100; local MIN_TIMER_FONT_SCALE = 0.2; local MAX_TIMER_FONT_SCALE = 0.8; local ACTIVE_BUFF_OFFSET = 2; local MAIN_ICON_MAX_ALPHA = 1.0;
local ACTIVE_BORDER_THICKNESS_DEFAULT = 4;

local MAIN_ICON_TEXTURE_PATH = "/esoui/art/icons/ability_dragonknight_013.dds"
local COLOR_BUFF_START_DEFAULT = { 0, 1, 0, 1 }; local COLOR_BUFF_END_DEFAULT = { 1, 0.5, 0, 1 }

local MAJOR_EXPEDITION = 61736
local MAJOR_VITALITY = 61713
local MAJOR_MENDING = 61711
local MAJOR_PROTECTION = 61722
local MAJOR_HEROISM = 61709

local SLOT_RIGHT = 1
local SLOT_LEFT = 2
local SLOT_BOTTOM = 3
local SLOT_TOP = 4
local SLOT_BOTTOM_RIGHT = 5

local PREFERRED_SLOTS = {
    [MAJOR_EXPEDITION] = SLOT_BOTTOM,
    [MAJOR_HEROISM] = SLOT_TOP,
    [MAJOR_VITALITY] = SLOT_LEFT,
    [MAJOR_MENDING] = SLOT_LEFT,
    [MAJOR_PROTECTION] = SLOT_RIGHT,
}

local function LerpColor(colorA, colorB, t) t = zo_clamp(t, 0, 1); return {colorA[1] + (colorB[1]-colorA[1])*t, colorA[2] + (colorB[2]-colorA[2])*t, colorA[3] + (colorB[3]-colorA[3])*t, colorA[4] + (colorB[4]-colorA[4])*t} end
local function GetSV(addonTable, key1, key2, key3, default) if not addonTable or type(addonTable) ~= "table" then return default end; local sv=addonTable.savedVariables; local v=sv; if v and key1 then v=v[key1] end; if v and key2 then v=v[key2] end; if v and key3 then v=v[key3] end; if v==nil then local d=addonTable.DefaultSettings and addonTable:DefaultSettings(); local dv=d; if dv and key1 then dv=dv[key1] end; if dv and key2 then dv=dv[key2] end; if dv and key3 then dv=dv[key3] end; return dv~=nil and dv or default end; return v end
local function FormatTime(ms, showDecimal) if ms <= 0 then return "" end; local s=ms/1000; if s<10 and showDecimal then return string.format("%.1f", s) else return tostring(zo_max(math.floor(s+0.01),0)) end end

function DTT_GUI_CreateTrackerWindow()
    if not DTT then d("!!! ERROR: Global DTT not found!") return false end
    local PrintDebug = DTT.PrintDebug and function(msg) DTT:PrintDebug(msg) end or function() end;
    local sv = DTT.savedVariables; if not sv then PrintDebug("CreateTrackerWindow: ERROR - SV not found."); return false end
    local name = DTT.name.."Window"; local win = DTT.trackerWindow or wm:CreateTopLevelWindow(name); if not win then PrintDebug("!!! FATAL ERROR creating TopLevelWindow"); return false end
    DTT.trackerWindow = win;
    win:SetClampedToScreen(true); local position = GetSV(DTT,"position",nil,nil,{left=300,top=300}); win:ClearAnchors(); win:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,position.left,position.top);
    win:SetHidden(true);
    win:SetHandler("OnMoveStop", function() if DTT.savedVariables and not DTT.savedVariables.locked then DTT.savedVariables.position={left=win:GetLeft(),top=win:GetTop()}; end end)

    local mainIconCtrl = win.mainIconCtrl or wm:CreateControl(name.."MainIconCtrl",win,CT_CONTROL);
    if mainIconCtrl then
        win.mainIconCtrl=mainIconCtrl; mainIconCtrl:SetAnchorFill(win); mainIconCtrl:SetDrawLevel(DL_CONTROL);

        local statusBorder = mainIconCtrl.statusBorder or wm:CreateControl(name.."MainStatusBorder",mainIconCtrl,CT_BACKDROP);
        if statusBorder then
             mainIconCtrl.statusBorder=statusBorder;
             local standbyColor = GetSV(DTT,"design","colors","standby",{0.5,0.5,0.5,1})
             statusBorder:SetCenterColor(standbyColor[1], standbyColor[2], standbyColor[3], standbyColor[4])
             statusBorder:SetAnchorFill(mainIconCtrl)
             statusBorder:SetDrawLevel(DL_BACKGROUND);
             statusBorder:SetHidden(false);
        else PrintDebug("!!! ERROR Status Border Backdrop") end;

        local iconTexture=mainIconCtrl.texture or wm:CreateControl(name.."MainIconTexture",mainIconCtrl,CT_TEXTURE);
        if iconTexture then
             mainIconCtrl.texture=iconTexture;
             iconTexture:SetTexture(MAIN_ICON_TEXTURE_PATH);
             iconTexture:SetDrawLevel(DL_BORDER);
        else PrintDebug("!!! ERROR Icon Texture") end

        local icdLabel = mainIconCtrl.icdLabel or wm:CreateControl(name.."MainICDLabel", mainIconCtrl, CT_LABEL)
        if icdLabel then
            mainIconCtrl.icdLabel = icdLabel; icdLabel:SetFont("ZoFontGameLargeBold"); icdLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER); icdLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER); icdLabel:SetColor(1,1,1,1); icdLabel:SetAnchorFill(mainIconCtrl);
            icdLabel:SetDrawLevel(DL_OVERLAY); icdLabel:SetDrawTier(DT_HIGH); icdLabel:SetHidden(true);
        else PrintDebug("!!! ERROR ICD Label") end
    else PrintDebug("!!! FATAL ERROR Main Icon Ctrl") end

    local defaultBuffBorderThickness = DTT:DefaultSettings().design.buffBorderThickness or 3
    local initialBuffBorderThickness = GetSV(DTT,"design","buffBorderThickness",nil,defaultBuffBorderThickness);
    win.activeBuffControls = win.activeBuffControls or {};
    for i=1,DTT.MAX_DISPLAY_BUFFS do
        if not win.activeBuffControls[i] then
            local buffControl=wm:CreateControl(name.."Buff"..i,win,CT_CONTROL);
            if buffControl then
                win.activeBuffControls[i]=buffControl;
                buffControl:SetHidden(true);
                buffControl:SetMouseEnabled(true);
                buffControl:SetDrawLevel(DL_HIGH);

                local buffFadingBorder=wm:CreateControl(name.."Buff"..i.."FadingBorder",buffControl,CT_BACKDROP);
                if buffFadingBorder then
                    buffControl.fadingBorder=buffFadingBorder;
                    buffFadingBorder:SetCenterColor(unpack(COLOR_BUFF_START_DEFAULT));
                    buffFadingBorder:ClearAnchors();
                    buffFadingBorder:SetAnchor(TOPLEFT, buffControl, TOPLEFT, -initialBuffBorderThickness, -initialBuffBorderThickness);
                    buffFadingBorder:SetAnchor(BOTTOMRIGHT, buffControl, BOTTOMRIGHT, initialBuffBorderThickness, initialBuffBorderThickness);
                    buffFadingBorder:SetDrawLevel(DL_BACKGROUND);
                    buffFadingBorder:SetHidden(true);
                end;

                local buffBackdrop=wm:CreateControl(name.."Buff"..i.."Backdrop",buffControl,CT_BACKDROP);
                if buffBackdrop then
                     buffControl.backdrop=buffBackdrop;
                     buffBackdrop:SetCenterColor(0,0,0,0);
                     buffBackdrop:SetAnchorFill(buffControl);
                     buffBackdrop:SetDrawLevel(DL_BACKGROUND+1);
                     buffBackdrop:SetHidden(true);
                end;

                local buffIcon=wm:CreateControl(name.."Buff"..i.."Icon",buffControl,CT_TEXTURE);
                if buffIcon then
                    buffControl.icon=buffIcon;
                    buffIcon:ClearAnchors();
                    buffIcon:SetAnchor(CENTER,buffControl,CENTER,0,0);
                    buffIcon:SetTexture("EsoUI/Art/icons/icon_missing.dds");
                    buffIcon:SetDrawLevel(DL_BORDER);
                end;

                local buffTimerLabel=wm:CreateControl(name.."Buff"..i.."Timer",buffControl,CT_LABEL);
                if buffTimerLabel then
                    buffControl.timerLabel=buffTimerLabel;
                    buffTimerLabel:SetFont("ZoFontGameSmall");
                    buffTimerLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER);
                    buffTimerLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER);
                    buffTimerLabel:SetColor(1,1,1,1);
                    buffTimerLabel:SetAnchorFill(buffControl);
                    buffTimerLabel:SetDrawLevel(DL_OVERLAY);
                    buffTimerLabel:SetHidden(true);
                end;
                buffControl:SetHandler("OnMouseEnter",function(c) ZO_Tooltips_ShowTextTooltip(c,TOP,c.tooltipText or "") end);
                buffControl:SetHandler("OnMouseExit",function(c) ZO_Tooltips_HideTextTooltip(c) end)
            else PrintDebug("!!! FATAL ERROR Buff Ctrl parent "..i) end
        end
    end;
    return true
end

function DTT_GUI_SetMovable(addonTable, movable) local PrintDebug=addonTable.PrintDebug and function(m) addonTable:PrintDebug(m) end or function() end; if addonTable.trackerWindow then local sM,eM=pcall(addonTable.trackerWindow.SetMovable, addonTable.trackerWindow, movable); local sMouse,eMouse=pcall(addonTable.trackerWindow.SetMouseEnabled, addonTable.trackerWindow, movable); if not (sM and sMouse) then PrintDebug("ERR set movable/mouse: "..tostring(eM).."/"..tostring(eMouse)) end else PrintDebug("ERR SetMovable: win nil") end end

function DTT_GUI_ApplyDesignSettings()
    if not DTT then return end; local PrintDebug = DTT.PrintDebug and function(msg) DTT:PrintDebug(msg) end or function() end; local win = DTT.trackerWindow;
    if not win or not DTT.savedVariables or not win.mainIconCtrl or not win.mainIconCtrl.texture or not win.mainIconCtrl.statusBorder or not win.activeBuffControls then return end;

    local mainIconSize = GetSV(DTT,"design","iconSize",nil,40);
    local mainBorderThickness = GetSV(DTT,"design","borderThickness",nil,ACTIVE_BORDER_THICKNESS_DEFAULT);
    local defaultBuffBorderThickness = DTT:DefaultSettings().design.buffBorderThickness or 3
    local actualBuffBorderThickness = GetSV(DTT,"design","buffBorderThickness",nil, defaultBuffBorderThickness);
    local buffIconScale = GetSV(DTT,"design","buffIconScale",nil,0.6);
    local buffTimerScale = GetSV(DTT,"design","buffTimerScale",nil,0.8);
    local mainTimerFontSizeScale = GetSV(DTT,"design","timerFontSizeScale", nil, 0.5);

    local clampedIconSize = zo_clamp(mainIconSize,MIN_ICON_SIZE,MAX_ICON_SIZE);
    win:SetDimensions(clampedIconSize,clampedIconSize);
    if win.mainIconCtrl.statusBorder then win.mainIconCtrl.statusBorder:SetAnchorFill(win.mainIconCtrl) end;
    local inset = mainBorderThickness;
    if win.mainIconCtrl.texture then win.mainIconCtrl.texture:ClearAnchors(); win.mainIconCtrl.texture:SetAnchor(TOPLEFT, win.mainIconCtrl, TOPLEFT, inset, inset); win.mainIconCtrl.texture:SetAnchor(BOTTOMRIGHT, win.mainIconCtrl, BOTTOMRIGHT, -inset, -inset); end;
    if win.mainIconCtrl.icdLabel then local mainTimerFontSize = math.floor(clampedIconSize * mainTimerFontSizeScale); local fontString = "ZoFontGameLargeBold|" .. mainTimerFontSize .. "|outline"; pcall(win.mainIconCtrl.icdLabel.SetFont, win.mainIconCtrl.icdLabel, fontString); end;

    local buffControlSize = math.floor(clampedIconSize*buffIconScale);
    local buffTimerFontSize = math.floor(buffControlSize*buffTimerScale);
    local actualBuffIconTextureSize = zo_max(1, buffControlSize - (2 * actualBuffBorderThickness));
    local extraClearance=2;
    local finalBuffOffset = ACTIVE_BUFF_OFFSET + actualBuffBorderThickness + extraClearance;

    for i,buffCtrl in ipairs(win.activeBuffControls) do
        if buffCtrl then
            buffCtrl:SetDimensions(buffControlSize,buffControlSize);
            buffCtrl:ClearAnchors();
            if i == SLOT_RIGHT then
                buffCtrl:SetAnchor(LEFT,win.mainIconCtrl,RIGHT, finalBuffOffset, 0)
            elseif i == SLOT_LEFT then
                buffCtrl:SetAnchor(RIGHT,win.mainIconCtrl,LEFT, -finalBuffOffset, 0)
            elseif i == SLOT_BOTTOM then
                 buffCtrl:SetAnchor(TOP,win.mainIconCtrl,BOTTOM, 0, finalBuffOffset)
            elseif i == SLOT_TOP then
                 buffCtrl:SetAnchor(BOTTOM,win.mainIconCtrl,TOP, 0, -finalBuffOffset)
            elseif i == SLOT_BOTTOM_RIGHT then
                 buffCtrl:SetAnchor(TOPLEFT, win.mainIconCtrl, BOTTOMRIGHT, finalBuffOffset/2, finalBuffOffset/2)
            end;

            if buffCtrl.icon then buffCtrl.icon:SetDimensions(actualBuffIconTextureSize,actualBuffIconTextureSize); buffCtrl.icon:ClearAnchors(); buffCtrl.icon:SetAnchor(CENTER,buffCtrl,CENTER,0,0); end;
            if buffCtrl.timerLabel then buffCtrl.timerLabel:SetFont("ZoFontGameSmall|" .. buffTimerFontSize .. "|outline"); end;
            if buffCtrl.fadingBorder then
                 buffCtrl.fadingBorder:ClearAnchors();
                 buffCtrl.fadingBorder:SetAnchor(TOPLEFT, buffCtrl, TOPLEFT, -actualBuffBorderThickness, -actualBuffBorderThickness);
                 buffCtrl.fadingBorder:SetAnchor(BOTTOMRIGHT, buffCtrl, BOTTOMRIGHT, actualBuffBorderThickness, actualBuffBorderThickness);
            end
        end
    end;
    DTT_GUI_UpdateGUIDisplay();
end

function DTT_GUI_UpdateGUIDisplay()
   if not DTT then return end
   local PrintDebug = DTT.PrintDebug and function(msg) DTT:PrintDebug(msg) end or function() end
   local win = DTT.trackerWindow

   if not win or not win.mainIconCtrl or not win.mainIconCtrl.texture or not win.mainIconCtrl.statusBorder or not win.mainIconCtrl.icdLabel or not win.activeBuffControls or not DTT.savedVariables or not DTT.activeBuffs or not DTT.BUFF_DATA or not DTT.DefaultSettings then return end

   local defaultSettings = DTT:DefaultSettings().design.colors
   local colors = GetSV(DTT, "design", "colors", nil, {})
   local colorActive = colors.active or defaultSettings.active
   local colorCooldown = colors.cooldown or defaultSettings.cooldown
   local colorStandby = colors.standby or defaultSettings.standby

   local standbyOpacityPercent = GetSV(DTT, "design", "standbyOpacity", nil, 100)
   local standbyOpacity = zo_clamp(standbyOpacityPercent / 100, 0, 1)
   local showBuffTimerText = GetSV(DTT, "design", "showTimerText", nil, true)
   local showDecimal = GetSV(DTT, "design", "showDecimal", nil, true)
   local showMainTimerText = GetSV(DTT, "design", "showTimerText", nil, true)

   local now = GetGameTimeMilliseconds()
   local numActiveBuffs = DTT:GetActiveBuffCount()
   local isIcdActive = (DTT.currentIcdEndTime > 0 and DTT.currentIcdEndTime > now)
   local remainingIcdTime = isIcdActive and (DTT.currentIcdEndTime - now) or 0

   local mainStateColor = {unpack(colorStandby)}; local mainAlpha = MAIN_ICON_MAX_ALPHA * standbyOpacity;
   if isIcdActive then mainStateColor = {unpack(colorCooldown)}; mainAlpha = MAIN_ICON_MAX_ALPHA * (mainStateColor[4] or 1.0);
   else mainStateColor = {unpack(colorActive)}; if numActiveBuffs == 0 then mainAlpha = MAIN_ICON_MAX_ALPHA * standbyOpacity * (mainStateColor[4] or 1.0); else mainAlpha = MAIN_ICON_MAX_ALPHA * (mainStateColor[4] or 1.0); end end

   if win.mainIconCtrl.texture then win.mainIconCtrl.texture:SetAlpha(mainAlpha) end
   if win.mainIconCtrl.statusBorder then win.mainIconCtrl.statusBorder:SetCenterColor(mainStateColor[1], mainStateColor[2], mainStateColor[3], mainAlpha) end

   if win.mainIconCtrl.icdLabel then
        if isIcdActive and showMainTimerText then
            local formattedTime = FormatTime(remainingIcdTime, showDecimal)
            win.mainIconCtrl.icdLabel:SetText(formattedTime)
            win.mainIconCtrl.icdLabel:SetColor(1, 0, 0, 1); win.mainIconCtrl.icdLabel:SetHidden(false);
        else
            win.mainIconCtrl.icdLabel:SetHidden(true); win.mainIconCtrl.icdLabel:SetColor(1, 1, 1, 1);
        end
   end

    local activeBuffDetails = {}
    if DTT.activeBuffs then
        for id, endTime in pairs(DTT.activeBuffs) do
            if type(endTime) == "number" and endTime > now then
                table.insert(activeBuffDetails, { id = id, remaining = endTime - now })
            end
        end
    end

    table.sort(activeBuffDetails, function(a,b) return a.id < b.id end)

    local assignedSlots = {}
    local slotAssignments = {}
    local availableSlots = {}
    for i=1, DTT.MAX_DISPLAY_BUFFS do availableSlots[i] = true end

    local vitalityMendingConflict = false
    local vitalityOrMendingOnLeft = nil
    for _, buffInfo in ipairs(activeBuffDetails) do
        local buffId = buffInfo.id
        local preferredSlot = PREFERRED_SLOTS[buffId]

        if preferredSlot then
            if (buffId == MAJOR_VITALITY or buffId == MAJOR_MENDING) and preferredSlot == SLOT_LEFT then
                if availableSlots[SLOT_LEFT] and not vitalityOrMendingOnLeft then
                    assignedSlots[SLOT_LEFT] = buffId
                    slotAssignments[buffId] = SLOT_LEFT
                    availableSlots[SLOT_LEFT] = false
                    vitalityOrMendingOnLeft = buffId
                elseif availableSlots[SLOT_RIGHT] and (assignedSlots[SLOT_RIGHT] == nil or PREFERRED_SLOTS[assignedSlots[SLOT_RIGHT]] ~= SLOT_RIGHT) then
                    assignedSlots[SLOT_RIGHT] = buffId
                    slotAssignments[buffId] = SLOT_RIGHT
                    availableSlots[SLOT_RIGHT] = false
                    vitalityMendingConflict = true
                else
                end
            elseif availableSlots[preferredSlot] and assignedSlots[preferredSlot] == nil then
                assignedSlots[preferredSlot] = buffId
                slotAssignments[buffId] = preferredSlot
                availableSlots[preferredSlot] = false
            end
        end
    end

    local nextAvailableSlotIndex = 1
    for _, buffInfo in ipairs(activeBuffDetails) do
        local buffId = buffInfo.id
        if not slotAssignments[buffId] then
            local assigned = false
            while nextAvailableSlotIndex <= DTT.MAX_DISPLAY_BUFFS do
                if availableSlots[nextAvailableSlotIndex] then
                    assignedSlots[nextAvailableSlotIndex] = buffId
                    slotAssignments[buffId] = nextAvailableSlotIndex
                    availableSlots[nextAvailableSlotIndex] = false
                    assigned = true
                    break
                end
                nextAvailableSlotIndex = nextAvailableSlotIndex + 1
            end
            if not assigned then
                PrintDebug("WARN: Could not find an available slot for buff " .. buffId)
            end
        end
    end

    local usedSlotsVisual = {}
    if slotAssignments then
        for buffId, slotIndex in pairs(slotAssignments) do
            if slotIndex and slotIndex >= 1 and slotIndex <= DTT.MAX_DISPLAY_BUFFS then
                 local buffCtrl = win.activeBuffControls[slotIndex]
                 local remainingDuration = DTT.activeBuffs[buffId] and (DTT.activeBuffs[buffId] - now) or 0

                 if buffCtrl and buffCtrl.icon and buffCtrl.timerLabel and buffCtrl.fadingBorder and DTT.BUFF_DATA[buffId] and remainingDuration > 0 then
                    usedSlotsVisual[slotIndex] = true

                    local totalDurationForColor = DTT.DAEDRIC_TRICKERY_BUFF_DURATION_MS;
                    local progress = (remainingDuration > 0 and totalDurationForColor > 0) and zo_clamp(remainingDuration / totalDurationForColor, 0, 1) or 0;
                    buffCtrl.icon:SetTexture(DTT.BUFF_DATA[buffId].icon);
                    buffCtrl.icon:SetDesaturation(0);
                    buffCtrl.tooltipText = DTT.BUFF_DATA[buffId].name.." ("..FormatTime(remainingDuration, showDecimal).."s)";

                    local currentBuffColor = LerpColor(COLOR_BUFF_END_DEFAULT, COLOR_BUFF_START_DEFAULT, progress);
                    local bdr_r_buff, bdr_g_buff, bdr_b_buff, bdr_a_buff = unpack(currentBuffColor);
                    buffCtrl.fadingBorder:SetCenterColor(bdr_r_buff, bdr_g_buff, bdr_b_buff, bdr_a_buff);
                    buffCtrl.fadingBorder:SetHidden(false);

                    if showBuffTimerText and remainingDuration > 0 then
                        buffCtrl.timerLabel:SetText(FormatTime(remainingDuration, showDecimal));
                        buffCtrl.timerLabel:SetColor(1,1,1,1);
                        buffCtrl.timerLabel:SetHidden(false);
                    else
                        buffCtrl.timerLabel:SetHidden(true);
                    end;
                    buffCtrl:SetHidden(false);
                 else
                     if buffCtrl then buffCtrl:SetHidden(true); end
                 end
            end
        end
    end

    for i = 1, DTT.MAX_DISPLAY_BUFFS do
        if not usedSlotsVisual[i] then
            local buffCtrl = win.activeBuffControls[i];
            if buffCtrl then
                 buffCtrl:SetHidden(true);
                 if buffCtrl.fadingBorder then buffCtrl.fadingBorder:SetHidden(true) end;
            end
        end
    end
end