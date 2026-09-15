-- ESO Adventurer Suite
-- Suite-native Group Finder Plus integration.
-- Reimplements the useful behavior from the user-provided GroupFinderPlus addon
-- while keeping the floating HUD listing browser independently optional.

local EPC = ESOProgressionCoach
if not EPC or not EVENT_MANAGER or not WINDOW_MANAGER then return end

EPC.GroupFinderPlus = EPC.GroupFinderPlus or {}
local GF = EPC.GroupFinderPlus
local EM, WM = EVENT_MANAGER, WINDOW_MANAGER
local NAME = (EPC.name or "ESOAdventurerSuite") .. "_GroupFinderPlus029669"

local DEFAULTS = {
    enabled = true,
    showHudOverlay = false,
    hideWTS = true,
    hideInsufficientCP = false,
    allowAllRoles = true,
    showInstanceTooltip = true,
    showModeButton = true,
    saveLastCategory = true,
    hideInInstances = false,
    lastBossHighlight = true,
    titleColor = "B000FF",
    descriptionColor = "8A2BE2",
    windowLeft = 20,
    windowTop = 180,
    lastCategory = nil,
    instanceMode = 2,
    categoriesEnabled = {},
    trialsEnabled = {},
    blacklist = {},
    savedListing = nil,
}

local TRIALS = {
    AA=638, AS=1000, CR=1051, HoF=975, HRC=636, SO=639, MoL=725,
    SS=1121, KA=1196, RG=1263, DSR=1344, SE=1427, LC=1478, OC=1548,
}
GF.Trials = TRIALS

local function copyDefaults(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                dst[k] = {}
                copyDefaults(dst[k], v)
            else
                dst[k] = v
            end
        elseif type(v) == "table" and type(dst[k]) == "table" then
            copyDefaults(dst[k], v)
        end
    end
end

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a,b,c,d,e,f,g,h = pcall(fn, ...)
    if not ok or a == nil then return fallback end
    return a,b,c,d,e,f,g,h
end

local function clean(text)
    text = tostring(text or "")
    text = text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    return text:gsub("^%s+", ""):gsub("%s+$", "")
end

local function lower(text) return string.lower(clean(text)) end

local function normalizeHex(hex, fallback)
    hex = tostring(hex or fallback or "FFFFFF"):upper():gsub("[^0-9A-F]", "")
    if #hex ~= 6 then return fallback or "FFFFFF" end
    return hex
end

local function colorize(text, hex)
    text = clean(text)
    if text == "" then return "" end
    return "|c" .. normalizeHex(hex, "FFFFFF") .. text .. "|r"
end

local function notify(text)
    if EPC and type(EPC.Print) == "function" then EPC:Print(text)
    elseif type(d) == "function" then d("[EAS] " .. tostring(text)) end
end

function GF:GetSV()
    if not EPC.saved then return nil end
    EPC.saved.groupFinderPlus029669 = EPC.saved.groupFinderPlus029669 or {}
    copyDefaults(EPC.saved.groupFinderPlus029669, DEFAULTS)
    local sv = EPC.saved.groupFinderPlus029669
    for short in pairs(TRIALS) do
        if sv.trialsEnabled[short] == nil then sv.trialsEnabled[short] = true end
    end
    return sv
end

local function categories()
    local out = {}
    local function add(id, name, icon)
        if id ~= nil then out[#out+1] = { id=id, name=name, icon=icon } end
    end
    add(rawget(_G,"GROUP_FINDER_CATEGORY_TRIAL"), "Trials", "esoui/art/icons/mapkey/mapkey_raiddungeon.dds")
    add(rawget(_G,"GROUP_FINDER_CATEGORY_DUNGEON"), "Dungeons", "esoui/art/icons/mapkey/mapkey_groupinstance.dds")
    add(rawget(_G,"GROUP_FINDER_CATEGORY_ARENA"), "Arenas", "esoui/art/icons/mapkey/mapkey_groupdelve.dds")
    add(rawget(_G,"GROUP_FINDER_CATEGORY_ENDLESS_DUNGEON"), "Infinite Archive", "esoui/art/leaderboards/gamepad/gp_leaderboards_menuicon_endlessdungeon_duo.dds")
    add(rawget(_G,"GROUP_FINDER_CATEGORY_ZONE"), "Zone", "esoui/art/armory/buildicons/buildicon_47.dds")
    if rawget(_G,"GROUP_FINDER_CATEGORY_ADVENTURE_ZONE") and safe(IsGroupFinderCategoryAvailable, false, GROUP_FINDER_CATEGORY_ADVENTURE_ZONE) then
        add(GROUP_FINDER_CATEGORY_ADVENTURE_ZONE, "Event Zone", "esoui/art/treeicons/gamepad/gp_nightmarket.dds")
    end
    add(rawget(_G,"GROUP_FINDER_CATEGORY_CUSTOM"), "Custom", "esoui/art/guildfinder/gamepad/gp_guildrecruitment_menuicon_applications.dds")
    return out
end

function GF:GetCategories()
    self.categoryList = categories()
    local sv = self:GetSV()
    for _, c in ipairs(self.categoryList) do
        if sv and sv.categoriesEnabled[c.id] == nil then sv.categoriesEnabled[c.id] = true end
    end
    return self.categoryList
end

function GF:CurrentCategory()
    local list, sv = self:GetCategories(), self:GetSV()
    if #list == 0 then return nil end
    local wanted = sv and sv.lastCategory
    for i,c in ipairs(list) do
        if c.id == wanted and (not sv or sv.categoriesEnabled[c.id] ~= false) then
            self.categoryIndex = i
            return c
        end
    end
    for i,c in ipairs(list) do
        if not sv or sv.categoriesEnabled[c.id] ~= false then
            self.categoryIndex = i
            if sv then sv.lastCategory = c.id end
            return c
        end
    end
    self.categoryIndex = 1
    return list[1]
end

function GF:CycleCategory()
    local list, sv = self:GetCategories(), self:GetSV()
    if #list == 0 or not sv then return end
    local start = tonumber(self.categoryIndex) or 1
    local i = start
    repeat
        i = i + 1
        if i > #list then i = 1 end
        if sv.categoriesEnabled[list[i].id] ~= false then break end
    until i == start
    self.categoryIndex = i
    sv.lastCategory = list[i].id
    self:UpdateHeader()
    self:RequestSearch(true)
end

function GF:SwitchMode()
    local sv = self:GetSV(); if not sv then return end
    sv.instanceMode = tonumber(sv.instanceMode) == 1 and 2 or 1
    self:UpdateHeader()
    self:RequestSearch(true)
end

local function trialShortFromText(text)
    local t = string.upper(clean(text))
    local aliases = {
        HRC={"HRC","HEL RA"}, SO={"SO","SANCTUM OPHIDIA"}, AA={"AA","AETHERIAN ARCHIVE"},
        MoL={"MOL","MAW OF LORKHAJ"}, HoF={"HOF","HALLS OF FABRICATION"}, AS={"AS","ASYLUM SANCTORIUM"},
        CR={"CR","CLOUDREST"}, SS={"SS","SUNSPIRE"}, KA={"KA","KYNE'S AEGIS"}, RG={"RG","ROCKGROVE"},
        DSR={"DSR","DREADSAIL REEF"}, SE={"SE","SANITY'S EDGE"}, LC={"LC","LUCENT CITADEL"}, OC={"OC","OSSEIN CAGE"},
    }
    for short, names in pairs(aliases) do
        for _, token in ipairs(names) do
            if t:find(token, 1, true) then return short end
        end
    end
    return nil
end

local function isLastBoss(title, desc)
    local t = lower(title) .. " " .. lower(desc)
    return t:find("last boss",1,true) ~= nil or t:find("final boss",1,true) ~= nil or t:find("end boss",1,true) ~= nil
end

local ROLE_ICONS = {
    [LFG_ROLE_TANK] = "esoui/art/lfg/lfg_icon_tank.dds",
    [LFG_ROLE_HEAL] = "esoui/art/lfg/lfg_icon_healer.dds",
    [LFG_ROLE_DPS] = "esoui/art/lfg/lfg_icon_dps.dds",
}

function GF:ReadListings()
    self.listings = {}
    local sv = self:GetSV(); if not sv then return end
    local count = tonumber(safe(GetGroupFinderSearchNumListings, 0)) or 0
    local custom = rawget(_G,"GROUP_FINDER_CATEGORY_CUSTOM")
    local current = self:CurrentCategory()
    local currentId = current and current.id
    local playerCP = tonumber(safe(GetUnitChampionPoints, 0, "player")) or 0
    for i=1,count do
        local title = tostring(safe(GetGroupFinderSearchListingTitleByIndex, "", i) or "")
        local desc = tostring(safe(GetGroupFinderSearchListingDescriptionByIndex, "", i) or "")
        local leader = tostring(safe(GetGroupFinderSearchListingLeaderDisplayNameByIndex, "", i) or "")
        local hideWts = sv.hideWTS == true and currentId ~= custom and lower(title):find("wts",1,true) ~= nil
        local required = tonumber(safe(GetGroupFinderSearchListingChampionPointsByIndex, 0, i)) or 0
        local requires = safe(DoesGroupFinderSearchListingRequireChampion, false, i) == true
        local hideCP = sv.hideInsufficientCP == true and requires and playerCP < required
        local session = leader .. "|" .. clean(title)
        local short = currentId == rawget(_G,"GROUP_FINDER_CATEGORY_TRIAL") and trialShortFromText(title .. " " .. desc) or nil
        local hideTrial = short and sv.trialsEnabled[short] == false
        if not hideWts and not hideCP and not hideTrial and not (self.hiddenSession and self.hiddenSession[session]) and not sv.blacklist[leader] then
            local roles = {}
            for _, role in ipairs({LFG_ROLE_TANK,LFG_ROLE_HEAL,LFG_ROLE_DPS}) do
                local requested, present = safe(GetGroupFinderSearchListingRoleStatusCount, 0, i, role)
                roles[role] = { requested=tonumber(requested) or 0, current=tonumber(present) or 0 }
            end
            self.listings[#self.listings+1] = {
                index=i, title=title, desc=desc, leader=leader, session=session, short=short,
                pending=safe(IsGroupFinderSearchListingActiveApplication,false,i)==true,
                joinResult=safe(GetGroupFinderSearchListingJoinabilityResult,0,i),
                requiresCP=requires, requiredCP=required, roles=roles,
                enforcesRoles=safe(DoesGroupFinderSearchListingEnforceRoles,false,i)==true,
                lastBoss=isLastBoss(title,desc),
            }
        end
    end
end

function GF:CreateRow(index)
    self.rows = self.rows or {}
    if self.rows[index] then return self.rows[index] end
    local row = WM:CreateControl("EAS_GroupFinderPlus_Row"..tostring(index), self.window, CT_CONTROL)
    row:SetHeight(28); row:SetMouseEnabled(true)
    local bg = WM:CreateControl(nil,row,CT_BACKDROP); bg:SetAnchorFill(row); bg:SetCenterColor(.06,.06,.08,.70); bg:SetEdgeColor(.18,.18,.22,.9); bg:SetEdgeTexture(nil,1,1,1)
    local label = WM:CreateControl(nil,row,CT_LABEL); label:SetAnchor(LEFT,row,LEFT,6,0); label:SetFont("ZoFontGame"); label:SetColor(1,1,1,1)
    local roleBox = WM:CreateControl(nil,row,CT_CONTROL); roleBox:SetAnchor(RIGHT,row,RIGHT,-6,0); roleBox:SetDimensions(122,26)
    row.roleControls = {}
    local prev
    for _, role in ipairs({LFG_ROLE_TANK,LFG_ROLE_HEAL,LFG_ROLE_DPS}) do
        local icon = WM:CreateControl(nil,roleBox,CT_TEXTURE); icon:SetDimensions(18,18); icon:SetTexture(ROLE_ICONS[role]); icon:SetAnchor(LEFT,prev or roleBox,prev and RIGHT or LEFT,prev and 7 or 0,0)
        local txt = WM:CreateControl(nil,roleBox,CT_LABEL); txt:SetDimensions(20,18); txt:SetFont("ZoFontGameSmall"); txt:SetAnchor(LEFT,icon,RIGHT,1,0); txt:SetText("0"); prev=txt
        row.roleControls[role]={icon=icon,text=txt}
    end
    row.bg,row.label,row.roleBox=bg,label,roleBox
    row:SetHandler("OnMouseEnter",function(r) r.bg:SetCenterColor(.22,.22,.26,.78); GF:ShowRowTooltip(r) end)
    row:SetHandler("OnMouseExit",function(r) GF:HideRowTooltip(); GF:ApplyRowColor(r) end)
    row:SetHandler("OnMouseUp",function(r,button,upInside)
        if upInside==false then return end
        if button==MOUSE_BUTTON_INDEX_RIGHT then GF:ShowContextMenu(r)
        elseif button==MOUSE_BUTTON_INDEX_LEFT then GF:ApplyToRow(r) end
    end)
    self.rows[index]=row
    return row
end

function GF:ApplyRowColor(row)
    if not row or not row.bg then return end
    if row.data and row.data.pending then row.bg:SetCenterColor(.55,.50,.10,.48)
    elseif row.data and row.data.joinResult == 4 then row.bg:SetCenterColor(.10,.42,.12,.45)
    elseif row.data and row.data.lastBoss and self:GetSV().lastBossHighlight then row.bg:SetCenterColor(.36,.08,.48,.52)
    else row.bg:SetCenterColor(.06,.06,.08,.70) end
end

function GF:ShowRowTooltip(row)
    local sv = self:GetSV(); if not sv or not row or not row.data then return end
    InitializeTooltip(InformationTooltip,row,RIGHT,8,0)
    local d=row.data
    InformationTooltip:AddLine(clean(d.title),"ZoFontWinH3",1,.85,.35)
    InformationTooltip:AddLine(d.leader,"ZoFontGame",.7,.9,1)
    if clean(d.desc)~="" then InformationTooltip:AddLine(clean(d.desc),"ZoFontGame",1,1,1) end
    if d.requiresCP then InformationTooltip:AddLine("Required CP: "..tostring(d.requiredCP),"ZoFontGameSmall",1,.55,.2) end
end
function GF:HideRowTooltip() ClearTooltip(InformationTooltip) end

function GF:CreateWindow()
    if self.window then return end
    local sv=self:GetSV(); if not sv then return end
    local w=WM:CreateTopLevelWindow("EAS_GroupFinderPlus_HUD")
    w:SetDimensions(430,120); w:SetMovable(true); w:SetMouseEnabled(true); w:SetClampedToScreen(true); w:SetDrawLayer(DL_OVERLAY); w:SetDrawTier(DT_MEDIUM); w:SetHidden(true)
    w:SetAnchor(TOPLEFT,GuiRoot,TOPLEFT,tonumber(sv.windowLeft) or 20,tonumber(sv.windowTop) or 180)
    w:SetHandler("OnMoveStop",function(c) sv.windowLeft=c:GetLeft(); sv.windowTop=c:GetTop() end)
    local header=WM:CreateControl(nil,w,CT_BACKDROP); header:SetAnchor(TOPLEFT,w,TOPLEFT,0,0); header:SetAnchor(TOPRIGHT,w,TOPRIGHT,0,0); header:SetHeight(34); header:SetCenterColor(.015,.018,.028,.92); header:SetEdgeColor(.70,.52,.18,.95); header:SetEdgeTexture(nil,1,1,1)
    header:SetMouseEnabled(true); header:SetHandler("OnMouseDown",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StartMoving() end end); header:SetHandler("OnMouseUp",function(_,b) if b==MOUSE_BUTTON_INDEX_LEFT then w:StopMovingOrResizing() end end)
    local cat=WM:CreateControl(nil,header,CT_BUTTON); cat:SetAnchor(LEFT,header,LEFT,8,0); cat:SetDimensions(210,28); cat:SetFont("ZoFontGameBold"); cat:SetHorizontalAlignment(TEXT_ALIGN_LEFT); cat:SetHandler("OnClicked",function() GF:CycleCategory() end)
    local mode=WM:CreateControl(nil,header,CT_BUTTON); mode:SetAnchor(RIGHT,header,RIGHT,-8,0); mode:SetDimensions(90,26); mode:SetFont("ZoFontGameSmall"); mode:SetHandler("OnClicked",function() GF:SwitchMode() end)
    local status=WM:CreateControl(nil,w,CT_LABEL); status:SetAnchor(TOPLEFT,header,BOTTOMLEFT,6,4); status:SetDimensions(410,24); status:SetFont("ZoFontGameSmall"); status:SetHorizontalAlignment(TEXT_ALIGN_CENTER); status:SetColor(.65,.65,.68,1)
    self.window,self.header,self.categoryButton,self.modeButton,self.status=w,header,cat,mode,status
    self.fragment=ZO_HUDFadeSceneFragment:New(w)
    self:UpdateHeader()
end

function GF:UpdateHeader()
    if not self.window then return end
    local sv=self:GetSV(); local c=self:CurrentCategory()
    self.categoryButton:SetText(c and ("Group Finder: "..c.name.."  ▶") or "Group Finder")
    self.modeButton:SetHidden(not sv.showModeButton)
    self.modeButton:SetText((tonumber(sv.instanceMode)==1) and "NORMAL" or "VETERAN")
end

function GF:RefreshRows()
    if not self.window then return end
    self:ReadListings()
    local y=62
    for i,data in ipairs(self.listings or {}) do
        local row=self:CreateRow(i); row.data=data; row:ClearAnchors(); row:SetAnchor(TOPLEFT,self.window,TOPLEFT,0,y); row:SetAnchor(TOPRIGHT,self.window,TOPRIGHT,0,y); y=y+28
        local prefix=data.short and ("["..data.short.."] ") or ""
        row.label:SetText(prefix..clean(data.title)); row.label:SetWidth(math.max(190,self.window:GetWidth()-150))
        for _,role in ipairs({LFG_ROLE_TANK,LFG_ROLE_HEAL,LFG_ROLE_DPS}) do
            local rd=data.roles[role]; row.roleControls[role].text:SetText(tostring(rd and rd.current or 0))
            local alpha=(data.enforcesRoles and rd and rd.requested==0) and .25 or 1
            row.roleControls[role].icon:SetAlpha(alpha); row.roleControls[role].text:SetAlpha(alpha)
        end
        self:ApplyRowColor(row); row:SetHidden(false)
    end
    for i=#(self.listings or {})+1,#(self.rows or {}) do self.rows[i]:SetHidden(true) end
    if #(self.listings or {})==0 then self.status:SetText("No matching listings") else self.status:SetText(tostring(#self.listings).." matching listing"..(#self.listings==1 and "" or "s")) end
    self.window:SetHeight(math.max(92,66+(#(self.listings or {})*28)))
end

function GF:IsOverlayAllowed()
    local sv=self:GetSV(); if not sv or not sv.enabled or not sv.showHudOverlay then return false end
    if tonumber(safe(GetUnitLevel,50,"player")) < 10 then return false end
    if safe(IsActiveWorldBattleground,false) then return false end
    if safe(GetCurrentGroupFinderUserType,0)==1 then return false end
    if sv.hideInInstances and safe(IsUnitInDungeon,false,"player") and not safe(IsInAdventureZone,false) then return false end
    return true
end

function GF:RefreshVisibility()
    self:CreateWindow(); if not self.window then return end
    local show=self:IsOverlayAllowed()
    if show then
        HUD_SCENE:AddFragment(self.fragment); HUD_UI_SCENE:AddFragment(self.fragment)
        self:UpdateHeader(); self:RequestSearch(false)
    else
        HUD_SCENE:RemoveFragment(self.fragment); HUD_UI_SCENE:RemoveFragment(self.fragment); self.window:SetHidden(true)
    end
end

function GF:RequestSearch(force)
    if not self:IsOverlayAllowed() then return end
    local c=self:CurrentCategory(); if not c then return end
    local sv=self:GetSV()
    if type(SetGroupFinderFilterCategory)=="function" then pcall(SetGroupFinderFilterCategory,c.id,true) end
    if (c.id==rawget(_G,"GROUP_FINDER_CATEGORY_TRIAL") or c.id==rawget(_G,"GROUP_FINDER_CATEGORY_DUNGEON") or c.id==rawget(_G,"GROUP_FINDER_CATEGORY_ARENA")) and type(SetGroupFinderFilterPrimaryOptionByIndex)=="function" then
        pcall(SetGroupFinderFilterPrimaryOptionByIndex,tonumber(sv.instanceMode) or 2,true)
    end
    if sv.allowAllRoles and type(SetGroupFinderFilterEnforceRoles)=="function" then pcall(SetGroupFinderFilterEnforceRoles,false) end
    if force or safe(IsGroupFinderSearchOnCooldown,false)~=true then
        self.status:SetText("Searching…")
        if type(RequestGroupFinderSearch)=="function" then pcall(RequestGroupFinderSearch) end
    end
end

function GF:ApplyToRow(row)
    if not row or not row.data then return end
    local idx=row.data.index
    if safe(DoesGroupFinderSearchListingAutoAcceptRequests,false,idx) then pcall(RequestApplyToGroupListing,idx)
    else
        local dialogData={listingIndex=idx,DoesGroupAutoAcceptRequests=function() return false end}
        if ZO_Dialogs_ShowDialog then pcall(ZO_Dialogs_ShowDialog,"GROUP_FINDER_APPLICATION_KEYBOARD",dialogData) else pcall(RequestApplyToGroupListing,idx) end
    end
end

function GF:ShowContextMenu(row)
    if not row or not row.data then return end
    ClearMenu(); local d=row.data
    AddCustomMenuItem("Apply to Group",function() GF:ApplyToRow(row) end)
    AddCustomMenuItem("Whisper Leader",function() if type(StartChatInput)=="function" then StartChatInput("/w "..d.leader.." ") end end)
    AddCustomMenuItem("Hide This Listing (Session)",function() GF.hiddenSession[d.session]=true GF:RefreshRows() end)
    AddCustomMenuItem("Blacklist "..d.leader,function() local sv=GF:GetSV(); sv.blacklist[d.leader]=true GF:RefreshRows(); notify("Blacklisted "..d.leader.." from Group Finder Plus.") end)
    ShowMenu(row)
end

function GF:GetBlacklistChoices()
    local sv=self:GetSV(); local out={}
    if sv then for name,v in pairs(sv.blacklist) do if v then out[#out+1]=name end end end
    table.sort(out); return out
end
function GF:Unblacklist(name)
    local sv=self:GetSV(); if sv and name and name~="" then sv.blacklist[name]=nil self:RefreshRows() end
end

function GF:ApplyColorToField(kind)
    local sv=self:GetSV(); if not sv then return end
    local name=(kind=="description") and "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentDescriptionEdit" or "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentGroupTitleBackdropEdit"
    local field=WM:GetControlByName(name); if not field or type(field.GetText)~="function" then return end
    local raw=clean(field:GetText()); if raw=="" then return end
    field:SetText(colorize(raw,kind=="description" and sv.descriptionColor or sv.titleColor))
end

function GF:ShowColorPicker(kind)
    local sv=self:GetSV(); if not sv or not COLOR_PICKER then return end
    local hex=kind=="description" and sv.descriptionColor or sv.titleColor
    local def=ZO_ColorDef:New(normalizeHex(hex,"FFFFFF"))
    COLOR_PICKER:Show(function(r,g,b)
        local h=ZO_ColorDef:New(r,g,b):ToHex():upper():sub(1,6)
        if kind=="description" then sv.descriptionColor=h else sv.titleColor=h end
        GF:ApplyColorToField(kind)
    end,def:UnpackRGB())
end

function GF:CreateNativeEnhancementButtons()
    if self.nativeButtonsDone then return end
    local title=WM:GetControlByName("ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentGroupTitleBackdropEdit")
    local desc=WM:GetControlByName("ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentDescriptionEdit")
    local function swatch(field,kind)
        if not field then return end
        local c=WM:CreateControl("EAS_GroupFinderPlus_"..kind.."Color",field:GetParent(),CT_BUTTON)
        c:SetDimensions(30,24); c:SetFont("ZoFontGameBold"); c:SetText("■"); c:SetAnchor(RIGHT,field,LEFT,-6,0)
        c:SetHandler("OnMouseEnter",function(self) InitializeTooltip(InformationTooltip,self,RIGHT,4,0); SetTooltipText(InformationTooltip,"Choose "..kind.." text color") end)
        c:SetHandler("OnMouseExit",function() ClearTooltip(InformationTooltip) end)
        c:SetHandler("OnClicked",function() GF:ShowColorPicker(kind) end)
    end
    swatch(title,"title"); swatch(desc,"description")
    local overview=WM:GetControlByName("ZO_GroupFinder_Keyboard_TopLevelOverview")
    if overview then
        local create=overview:GetNamedChild("CreateGroupButton")
        if create then
            local b=WM:CreateControl("EAS_GroupFinderPlus_RecreateButton",overview,CT_BUTTON); b:SetDimensions(105,30); b:SetFont("ZoFontGameSmall"); b:SetText("RECREATE"); b:SetAnchor(RIGHT,create,LEFT,-8,0); b:SetHandler("OnClicked",function() GF:RestoreSavedListing() end)
        end
    end
    self.nativeButtonsDone=true
end

function GF:SelectedOptionIndex(userType,primary)
    local count=primary and safe(GetGroupFinderUserTypeGroupListingNumPrimaryOptions,0,userType) or safe(GetGroupFinderUserTypeGroupListingNumSecondaryOptions,0,userType)
    for i=1,tonumber(count) or 0 do
        local _,setState
        if primary then _,setState=safe(GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex,nil,userType,i) else _,setState=safe(GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex,nil,userType,i) end
        if setState then return i end
    end
end

function GF:SaveCurrentListing()
    local sv=self:GetSV(); if not sv then return end
    local ut=rawget(_G,"GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING") or 1
    sv.savedListing={
        title=safe(GetGroupFinderUserTypeGroupListingTitle,"",ut), description=safe(GetGroupFinderUserTypeGroupListingDescription,"",ut),
        category=safe(GetGroupFinderUserTypeGroupListingCategory,nil,ut), mode=self:SelectedOptionIndex(ut,true), target=self:SelectedOptionIndex(ut,false),
        groupSize=safe(GetGroupFinderUserTypeGroupListingGroupSize,nil,ut), playstyle=safe(GetGroupFinderUserTypeGroupListingPlaystyle,nil,ut),
        requiresChampion=safe(DoesGroupFinderUserTypeGroupListingRequireChampion,false,ut), cp=safe(GetGroupFinderCreateGroupListingChampionPoints,0,ut),
        requiresVOIP=safe(DoesGroupFinderUserTypeGroupListingRequireVOIP,false,ut), requiresCode=safe(DoesGroupFinderUserTypeGroupListingRequireInviteCode,false,ut), code=safe(GetGroupFinderUserTypeGroupListingInviteCode,"",ut),
        autoAccept=safe(DoesGroupFinderUserTypeGroupListingAutoAcceptRequests,false,ut), enforceRoles=safe(DoesGroupFinderUserTypeGroupListingEnforceRoles,false,ut),
        tank=safe(GetGroupFinderUserTypeGroupListingDesiredRoleCount,0,ut,LFG_ROLE_TANK), heal=safe(GetGroupFinderUserTypeGroupListingDesiredRoleCount,0,ut,LFG_ROLE_HEAL), dps=safe(GetGroupFinderUserTypeGroupListingDesiredRoleCount,0,ut,LFG_ROLE_DPS),
    }
end

function GF:RestoreSavedListing()
    local sv=self:GetSV(); local d=sv and sv.savedListing
    if not d then notify("No saved Group Finder listing yet.") return end
    if safe(HasGroupListingForUserType,false,rawget(_G,"GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING") or 1) then notify("A Group Finder listing is already active.") return end
    local ut=rawget(_G,"GROUP_FINDER_GROUP_LISTING_USER_TYPE_CREATED_GROUP_LISTING") or 1
    local calls={{SetGroupFinderUserTypeGroupListingCategory,d.category},{SetGroupFinderUserTypeGroupListingPrimaryOption,d.mode},{SetGroupFinderUserTypeGroupListingSecondaryOption,d.target},{SetGroupFinderUserTypeGroupListingGroupSize,d.groupSize},{SetGroupFinderUserTypeGroupListingPlaystyle,d.playstyle},{SetGroupFinderUserTypeGroupListingRequiresChampion,d.requiresChampion},{SetGroupFinderUserTypeGroupListingChampionPoints,d.cp},{SetGroupFinderUserTypeGroupListingRequiresVOIP,d.requiresVOIP},{SetGroupFinderUserTypeGroupListingRequiresInviteCode,d.requiresCode},{SetGroupFinderUserTypeGroupListingInviteCode,d.code},{SetGroupFinderUserTypeGroupListingAutoAcceptRequests,d.autoAccept},{SetGroupFinderUserTypeGroupListingEnforceRoles,d.enforceRoles}}
    for _,x in ipairs(calls) do if type(x[1])=="function" and x[2]~=nil then pcall(x[1],ut,x[2]) end end
    if type(SetGroupFinderUserTypeGroupListingRoleCount)=="function" then pcall(SetGroupFinderUserTypeGroupListingRoleCount,ut,LFG_ROLE_TANK,d.tank or 0); pcall(SetGroupFinderUserTypeGroupListingRoleCount,ut,LFG_ROLE_HEAL,d.heal or 0); pcall(SetGroupFinderUserTypeGroupListingRoleCount,ut,LFG_ROLE_DPS,d.dps or 0) end
    if type(SetGroupFinderUserTypeGroupListingTitle)=="function" then pcall(SetGroupFinderUserTypeGroupListingTitle,ut,d.title or "") end
    if type(SetGroupFinderUserTypeGroupListingDescription)=="function" then pcall(SetGroupFinderUserTypeGroupListingDescription,ut,d.description or "") end
    if type(RequestCreateGroupListing)=="function" then pcall(RequestCreateGroupListing) end
end

function GF:InstallAllowAllRolesHook()
    if self.rolesHookDone or not GROUP_FINDER_SEARCH_MANAGER or type(ZO_PreHook)~="function" then return end
    self.rolesHookDone=true
    ZO_PreHook(GROUP_FINDER_SEARCH_MANAGER,"ExecuteSearch",function()
        local sv=GF:GetSV(); if sv and sv.enabled and sv.allowAllRoles and type(SetGroupFinderFilterEnforceRoles)=="function" then pcall(SetGroupFinderFilterEnforceRoles,false) end
    end)
end

function GF:Initialize()
    if self.initialized then return end
    self.initialized=true; self.hiddenSession={}; self.rows={}; self.listings={}
    self:GetSV(); self:InstallAllowAllRolesHook(); self:CreateWindow(); self:CreateNativeEnhancementButtons(); self:RefreshVisibility()
    EM:RegisterForEvent(NAME.."_Search",EVENT_GROUP_FINDER_SEARCH_COMPLETE,function(_,result) if result==GROUP_FINDER_ACTION_RESULT_SUCCESS and GF:IsOverlayAllowed() then GF:RefreshRows() end end)
    if rawget(_G,"EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT") then EM:RegisterForEvent(NAME.."_Create",EVENT_GROUP_FINDER_CREATE_GROUP_LISTING_RESULT,function(_,result) if result==GROUP_FINDER_ACTION_RESULT_SUCCESS then zo_callLater(function() GF:SaveCurrentListing(); GF:RefreshVisibility() end,400) end end) end
    if rawget(_G,"EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT") then EM:RegisterForEvent(NAME.."_Update",EVENT_GROUP_FINDER_UPDATE_GROUP_LISTING_RESULT,function() zo_callLater(function() GF:SaveCurrentListing() end,400) end) end
    if rawget(_G,"EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT") then EM:RegisterForEvent(NAME.."_Remove",EVENT_GROUP_FINDER_REMOVE_GROUP_LISTING_RESULT,function() GF:RefreshVisibility() end) end
    EM:RegisterForEvent(NAME.."_Activated",EVENT_PLAYER_ACTIVATED,function() GF:CreateNativeEnhancementButtons(); GF:RefreshVisibility() end)
    SLASH_COMMANDS=SLASH_COMMANDS or {}
    SLASH_COMMANDS["/easgf"]=function(arg)
        arg=lower(arg)
        local sv=GF:GetSV()
        if arg=="overlay" then sv.showHudOverlay=not sv.showHudOverlay GF:RefreshVisibility(); notify("Group Finder HUD overlay "..(sv.showHudOverlay and "enabled" or "disabled")..".")
        elseif arg=="recreate" then GF:RestoreSavedListing()
        elseif arg=="search" then GF:RequestSearch(true)
        else notify("/easgf overlay | recreate | search") end
    end
end

function ESOAdventurerSuite_GroupFinderPlusToggleOverlay()
    local sv=GF:GetSV(); if not sv then return end
    sv.showHudOverlay=not sv.showHudOverlay; GF:RefreshVisibility()
end
function ESOAdventurerSuite_GroupFinderPlusCycleCategory() GF:CycleCategory() end
function ESOAdventurerSuite_GroupFinderPlusSwitchMode() GF:SwitchMode() end
function ESOAdventurerSuite_GroupFinderPlusRecreate() GF:RestoreSavedListing() end

if type(ZO_CreateStringId)=="function" then
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_GF_OVERLAY","Toggle Group Finder HUD Overlay")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_GF_CATEGORY","Next Group Finder Category")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_GF_MODE","Switch Group Finder Normal / Veteran")
    ZO_CreateStringId("SI_BINDING_NAME_ESO_ADVENTURER_SUITE_GF_RECREATE","Recreate Last Group Finder Listing")
end

EM:RegisterForEvent(NAME.."_Loaded",EVENT_ADD_ON_LOADED,function(_,addonName)
    if addonName~=(EPC.name or "ESOAdventurerSuite") then return end
    EM:UnregisterForEvent(NAME.."_Loaded",EVENT_ADD_ON_LOADED)
    if type(zo_callLater)=="function" then zo_callLater(function() GF:Initialize() end,0) else GF:Initialize() end
end)
