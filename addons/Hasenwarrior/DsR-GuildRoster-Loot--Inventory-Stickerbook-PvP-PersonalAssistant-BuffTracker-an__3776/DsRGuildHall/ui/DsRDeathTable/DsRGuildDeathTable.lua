-- Create namespace
DsRGuildDeathTable = {}
local DsRGuildDeathTable = DsRGuildDeathTable  or {}

DsRGuildDeathTable.name = "DsRGuildDeathTable"

-------------------------------------------------------------------------------------------------------------------------------------------------
local function HideIfVisible()
    if DsRAutoINV.cfg.TablehiddenUI == false then
        DsRGuildDeathTableIndicator:SetHidden(true)
    end
end
 
-------------------------------------------------------------------------------------------------------------------------------------------------
local function ShowIfVisible()
    if DsRAutoINV.cfg.TablehiddenUI == false then
        DsRGuildDeathTableIndicator:SetHidden(false)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable:RestorePosition()
    DsRGuildDeathTableIndicator:ClearAnchors()
    DsRGuildDeathTableIndicator:SetHidden(DsRAutoINV.cfg.TablehiddenUI)
    DsRGuildDeathTableIndicator:SetTopmost(true)
    DsRGuildDeathTableIndicator:BringWindowToTop(true)
    DsRGuildDeathTableIndicator:SetAnchor(
        TOPLEFT,
        GuiRoot,
        TOPLEFT,
        DsRAutoINV.cfg.TableOffsetX,
        DsRAutoINV.cfg.TableOffsetY
    )
    if (DsRAutoINV.cfg.ColorTitle) then
        DsRGuildDeathTableIndicatorLabel:SetColor(unpack(DsRAutoINV.cfg.ColorTitle))
    end
    if DsRAutoINV.cfg.ColorPlayer then
        DsRGuildDeathTableIndicatorData:SetColor(unpack(DsRAutoINV.cfg.ColorPlayer))
    end
    if DsRAutoINV.cfg.ColorCount then
        DsRGuildDeathTableIndicatorData2:SetColor(unpack(DsRAutoINV.cfg.ColorCount))
    end
    
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable:SetColour()
    if (DsRAutoINV.cfg.ColorTitle) then
        DsRGuildDeathTableIndicatorLabel:SetColor(unpack(DsRAutoINV.cfg.ColorTitle))
    end
    if DsRAutoINV.cfg.ColorPlayer then
        DsRGuildDeathTableIndicatorData:SetColor(unpack(DsRAutoINV.cfg.ColorPlayer))
    end
    if DsRAutoINV.cfg.ColorCount then
        DsRGuildDeathTableIndicatorData2:SetColor(unpack(DsRAutoINV.cfg.ColorCount))
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable:SetAlpha()
    DsRGuildDeathTableIndicatorBg:SetAlpha(DsRAutoINV.cfg.DeathbgAlpha / 100)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function tablelength(T)
    local count = 0
    for _ in pairs(T) do
        count = count + 1
    end
    return count
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function settext(table2, col)
    list    = {}
    tbl     = {}
    output  = ""

    for name, value in pairs(table2) do
        list[#list + 1] = name
    end
    
    if table2 == nil then return end

    function byval(a, b)
        return table2[a].death > table2[b].death
    end
    table.sort(list, byval)
    
    for k = 1, #list do
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic("@"..list[k])
        local CustomName = LibCustomNames.Get("@"..list[k])
        local classIcon  = zo_iconFormat(ZO_GetClassIcon(table2[list[k]].class), 20, 20)

        if texturePath and CustomName then
            Icon = zo_iconFormat(texturePath, 21, 21)
            if col == "k" then -- Tablename
                output = output .. Icon .. CustomName .. "\n\r"
            elseif col == "all" then -- Post
                output = output .. (list[k]) .. ": " .. table2[list[k]].death .. " | "
            else -- Countzahl
                output = output .. table2[list[k]].death .. "\n\r"
            end
        else
            if col == "k" then -- Tablename
                output = output .. classIcon .. (list[k]) .. "\n\r"
            elseif col == "all" then -- Post
                output = output .. (list[k]) .. ": " .. table2[list[k]].death .. " | "
            else -- Countzahl
                output = output .. table2[list[k]].death .. "\n\r"
            end
        end
    end
    return output
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.resetTable()
    table1 = {}
    DsRGuildDeathTableIndicatorData:SetText(settext(table1, "k"))
    DsRGuildDeathTableIndicatorData2:SetText(settext(table1))
    DsRGuildDeathTableIndicatorBg:SetDimensions(260, 55)
    DsRGuildDeathTableIndicatorContainer:SetDimensions(230, 0)
    DsRAutoINV.cfg.Table = table1
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.printdeath(eventCode, unitTag, isDead)
    if isDead == true then
        if (unitTag == string.match(unitTag, "^group.*$") and unitTag ~= string.match(unitTag, "^group.companion.*$")) then
            username        = GetUnitDisplayName(unitTag)
            username        = username:gsub("^@", "")
            local tempcount = table1[username] and table1[username].death or 0
            local classId   = GetUnitClassId(unitTag)

            if tempcount == nil then
                table1[username] = {death=1, class=classId}
            else
                table1[username] = {death=tempcount + 1, class=classId}
            end
            tl = tablelength(table1)

            DsRGuildDeathTableIndicatorData:SetText(settext(table1, "k"))
            DsRGuildDeathTableIndicatorData2:SetText(settext(table1))
            DsRAutoINV.cfg.Table = table1
            if tl < DsRAutoINV.cfg.TableLenght then
                bglen = ((26 * tl) + 55 + 20)
                contlen = ((26 * tl) + 55 + 20)
            else
                bglen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 80)
                contlen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 20)
            end
            DsRGuildDeathTableIndicatorBg:SetDimensions(260, bglen)
            DsRGuildDeathTableIndicatorContainer:SetDimensions(230, contlen)
            DsRGuildDeathTableIndicatorData:SetDimensions(230, contlen)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.postDeath()
    local Message = settext(table1, "all")
    StartChatInput(Message, CHAT_CHANNEL_PARTY)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.loadTableToMem()
    if DsRAutoINV.cfg.Table ~= nil then
        table2 = {}
        table2 = DsRAutoINV.cfg.Table
        tl = tablelength(table2)
        DsRGuildDeathTableIndicatorData:SetText(settext(table2, "k"))
        DsRGuildDeathTableIndicatorData2:SetText(settext(table2))
        if tl == 0 then
            bglen = 55
            contlen = 0
        elseif tl < DsRAutoINV.cfg.TableLenght then
            bglen = ((26 * tl) + 55 + 20)
            contlen = ((26 * tl) + 55 + 20)
        else
            bglen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 80)
            contlen = ((26 * DsRAutoINV.cfg.TableLenght) + 55 + 20)
        end
        DsRGuildDeathTableIndicatorBg:SetDimensions(260, bglen)
        DsRGuildDeathTableIndicatorContainer:SetDimensions(230, contlen)
        table1 = table2
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.OnGroupChanged(eventId, memberName)
    local groupSize = GetGroupSize()
    local me        = GetUnitName("player")
    if groupSize >= 2 then
        if DsRAutoINV.cfg.ShowGroupJoin == true  then
            DsRAutoINV.cfg.TablehiddenUI = false
            DsRGuildDeathTableIndicator:SetHidden(false)
            DsRGuildDeathTableIndicator:SetTopmost(true)
            DsRGuildDeathTableIndicator:BringWindowToTop(true)
        end
        if string.match(memberName, me ..".*$" ) then
            if DsRAutoINV.cfg.ResetTable == true then
                DsRGuildDeathTable.resetTable()
            end
        end
    else
        if DsRAutoINV.cfg.HideGroupLeave == true then
            DsRAutoINV.cfg.TablehiddenUI = true
            DsRGuildDeathTableIndicator:SetHidden(true)
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.ToggleWindow()
    if not DsRAutoINV.cfg.TablehiddenUI == false then
        DsRAutoINV.cfg.TablehiddenUI = false
        DsRGuildDeathTableIndicator:SetHidden(false)
        DsRGuildDeathTableIndicator:SetTopmost(true)
        DsRGuildDeathTableIndicator:BringWindowToTop(true)
    else
        DsRAutoINV.cfg.TablehiddenUI = true
        DsRGuildDeathTableIndicator:SetHidden(true)
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable:Initialize()
    EVENT_MANAGER:RegisterForEvent(DsRGuildDeathTable.name, EVENT_UNIT_DEATH_STATE_CHANGED , DsRGuildDeathTable.printdeath)
    EVENT_MANAGER:RegisterForEvent(DsRGuildDeathTable.name, EVENT_PLAYER_ACTIVATED         , DsRGuildDeathTable.loadTableToMem)
    EVENT_MANAGER:RegisterForEvent(DsRGuildDeathTable.name, EVENT_GROUP_MEMBER_JOINED      , DsRGuildDeathTable.OnGroupChanged)
    EVENT_MANAGER:RegisterForEvent(DsRGuildDeathTable.name, EVENT_GROUP_MEMBER_LEFT        , DsRGuildDeathTable.OnGroupChanged)
   
    DsRGuildDeathTable:RestorePosition()
    DsRGuildDeathTable:SetAlpha()
    table1 = {}

    ZO_PreHookHandler(ZO_GameMenu_InGame     , "OnShow" , function() HideIfVisible() end)
    ZO_PreHookHandler(ZO_GameMenu_InGame     , "OnHide" , function() ShowIfVisible() end)
    ZO_PreHookHandler(ZO_InteractWindow      , "OnShow" , function() HideIfVisible() end)
    ZO_PreHookHandler(ZO_InteractWindow      , "OnHide" , function() ShowIfVisible() end)
    ZO_PreHookHandler(ZO_KeybindStripControl , "OnShow" , function() HideIfVisible() end)
    ZO_PreHookHandler(ZO_KeybindStripControl , "OnHide" , function() ShowIfVisible() end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar , "OnShow" , function() HideIfVisible() end)
    ZO_PreHookHandler(ZO_MainMenuCategoryBar , "OnHide" , function() ShowIfVisible() end)

   if not DsRAutoINV.cfg.TableLenght then
    DsRAutoINV.cfg.TableLenght = 10
   end
end

-------------------------------------------------------------------------------------------------------------------------------------------------
local function LogoutOrQuit()
	table1 = {}
    DsRAutoINV.cfg.Table = table1
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.OnAddOnLoaded(event, addonName)
    EVENT_MANAGER:UnregisterForEvent(DsRGuildDeathTable.name, EVENT_ADD_ON_LOADED)
    DsRGuildDeathTable:Initialize()

	ZO_PreHook("Logout", function() LogoutOrQuit() end)
	ZO_PreHook("Quit",   function() LogoutOrQuit() end)
end

-------------------------------------------------------------------------------------------------------------------------------------------------
function DsRGuildDeathTable.SaveLoc()
    DsRAutoINV.cfg.TableOffsetX = DsRGuildDeathTableIndicator:GetLeft()
    DsRAutoINV.cfg.TableOffsetY = DsRGuildDeathTableIndicator:GetTop()
end
