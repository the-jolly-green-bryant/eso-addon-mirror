-- ESO Adventurer Suite
-- v0.29.669 Group Finder Plus interaction/color hardening.
local EPC = ESOProgressionCoach
local GF = EPC and EPC.GroupFinderPlus
if not GF then return end

-- The reference addon avoided three identical consecutive hex digits because
-- Group Finder text validation can reject/sanitize some color-code patterns.
local function safeHex(hex)
    hex = tostring(hex or "A020F0"):upper():gsub("[^0-9A-F]", "")
    if #hex ~= 6 then hex = "A020F0" end
    local out, previous, run = {}, nil, 0
    for i=1,#hex do
        local c=hex:sub(i,i)
        if c==previous then run=run+1 else run=1 end
        if run>2 then
            local n=tonumber(c,16) or 0
            c=string.format("%X",(n+1)%16)
            run=1
        end
        out[#out+1]=c
        previous=c
    end
    return table.concat(out)
end

local baseGetSV = GF.GetSV
function GF:GetSV()
    local sv = baseGetSV(self)
    if sv then
        if sv.titleColor==nil or sv.titleColor=="B000FF" then sv.titleColor="A020F0" end
        sv.titleColor=safeHex(sv.titleColor)
        sv.descriptionColor=safeHex(sv.descriptionColor or "8A2BE2")
    end
    return sv
end

function GF:ApplyColorToField(kind)
    local sv=self:GetSV(); if not sv or not WINDOW_MANAGER then return end
    local name=(kind=="description") and "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentDescriptionEdit" or "ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentGroupTitleBackdropEdit"
    local field=WINDOW_MANAGER:GetControlByName(name)
    if not field or type(field.GetText)~="function" or type(field.SetText)~="function" then return end
    local text=tostring(field:GetText() or ""):gsub("|c%x%x%x%x%x%x",""):gsub("|r","")
    text=text:gsub("^%s+",""):gsub("%s+$","")
    if text=="" then return end
    local hex=safeHex(kind=="description" and sv.descriptionColor or sv.titleColor)
    field:SetText("|c"..hex..text.."|r")
end

-- Rebuild the native helper controls lazily if Group Finder keyboard controls
-- were not instantiated yet at addon load. Each helper has its own guard.
function GF:CreateNativeEnhancementButtons()
    if not WINDOW_MANAGER then return end
    local WM=WINDOW_MANAGER
    local function ensureSwatch(controlName, kind)
        if self["native"..kind.."Button029669"] then return true end
        local field=WM:GetControlByName(controlName)
        if not field then return false end
        local c=WM:CreateControl("EAS_GroupFinderPlus_"..kind.."Color",field:GetParent(),CT_BUTTON)
        c:SetDimensions(30,24); c:SetFont("ZoFontGameBold"); c:SetText("■"); c:SetAnchor(RIGHT,field,LEFT,-6,0)
        c:SetHandler("OnMouseEnter",function(control) InitializeTooltip(InformationTooltip,control,RIGHT,4,0); SetTooltipText(InformationTooltip,"Choose "..kind.." text color") end)
        c:SetHandler("OnMouseExit",function() ClearTooltip(InformationTooltip) end)
        c:SetHandler("OnClicked",function() GF:ShowColorPicker(kind) end)
        self["native"..kind.."Button029669"]=c
        return true
    end
    ensureSwatch("ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentGroupTitleBackdropEdit","title")
    ensureSwatch("ZO_GroupFinder_Keyboard_TopLevelCreateGroupListingPanelContentDescriptionEdit","description")

    if not self.nativeRecreateButton029669 then
        local overview=WM:GetControlByName("ZO_GroupFinder_Keyboard_TopLevelOverview")
        local create=overview and overview:GetNamedChild("CreateGroupButton")
        if overview and create then
            local b=WM:CreateControl("EAS_GroupFinderPlus_RecreateButton",overview,CT_BUTTON)
            b:SetDimensions(105,30); b:SetFont("ZoFontGameSmall"); b:SetText("RECREATE"); b:SetAnchor(RIGHT,create,LEFT,-8,0)
            b:SetHandler("OnClicked",function() GF:RestoreSavedListing() end)
            self.nativeRecreateButton029669=b
        end
    end
end

-- Match the reference interaction: rows drag the HUD on single left click and
-- only apply to a listing on a deliberate double-click. Right-click keeps the
-- context menu.
local baseCreateRow = GF.CreateRow
function GF:CreateRow(index)
    local row=baseCreateRow(self,index)
    if not row or row.easGroupFinderGesture029669 then return row end
    row.easGroupFinderGesture029669=true
    row:SetHandler("OnMouseDown",function(control,button)
        if button==MOUSE_BUTTON_INDEX_LEFT and GF.window then GF.window:StartMoving() end
    end)
    row:SetHandler("OnMouseUp",function(control,button,upInside)
        if button==MOUSE_BUTTON_INDEX_LEFT and GF.window then GF.window:StopMovingOrResizing()
        elseif button==MOUSE_BUTTON_INDEX_RIGHT and upInside~=false then GF:ShowContextMenu(control) end
    end)
    row:SetHandler("OnMouseDoubleClick",function(control,button)
        if button==MOUSE_BUTTON_INDEX_LEFT then GF:ApplyToRow(control) end
    end)
    return row
end

-- Use the same keyboard application-dialog data contract ESO's Group Finder
-- expects so invite-code/manual-approval listings behave correctly.
function GF:ApplyToRow(row)
    if not row or not row.data then return end
    local data=row.data
    local index=tonumber(data.index)
    if not index then return end
    local joinResult=type(GetGroupFinderSearchListingJoinabilityResult)=="function" and GetGroupFinderSearchListingJoinabilityResult(index) or 0
    if joinResult==13 then
        if EPC and EPC.Print then EPC:Print("That listing does not accept your current role.") end
        return
    end
    local auto=type(DoesGroupFinderSearchListingAutoAcceptRequests)=="function" and DoesGroupFinderSearchListingAutoAcceptRequests(index)==true
    if auto then
        if type(RequestApplyToGroupListing)=="function" then pcall(RequestApplyToGroupListing,index,nil,nil) end
        return
    end
    if type(ZO_Dialogs_ShowDialog)=="function" then
        local session=data.session
        local dialogData={
            GetListingIndex=function()
                for _,listing in ipairs(GF.listings or {}) do if listing.session==session then return listing.index end end
                return index
            end,
            GetTitle=function() return data.title or "" end,
            DoesGroupAutoAcceptRequests=function() return auto end,
            DoesGroupRequireInviteCode=function()
                return type(DoesGroupFinderSearchListingRequireInviteCode)=="function" and DoesGroupFinderSearchListingRequireInviteCode(index)==true
            end,
        }
        pcall(ZO_Dialogs_ShowDialog,"GROUP_FINDER_APPLICATION_KEYBOARD",dialogData)
    elseif type(RequestApplyToGroupListing)=="function" then
        pcall(RequestApplyToGroupListing,index)
    end
end
