if not TQG then TQG = {} end
TQG.Overview = ZO_Object:Subclass()
local a = "TheQuestingGuide"
TQG.sceneNameQuestGuideOverview = "QuestGuideOverview"
TQG.Overview.minClassicLinks = 1;
TQG.Overview.maxClassicLinks = 2;
TQG.Overview.minDLCLinks = 1;
TQG.Overview.maxDLCLinks = 2;
local function b() return true end
function TQG:ToggleMenu()
    if not b() then return end
    if not TQG.MenuState then TQG.MenuState = 0 end
    if TQG.MenuHidden == nil then TQG.MenuHidden = true end
    local c = TQG.MenuState;
    local e = TQG.MenuHidden;
    local f = {
        [1] = TQG.sceneNameQuestGuideOverview,
        [2] = TQG.sceneNameQuestGuideClassic,
        [3] = TQG.sceneNameQuestGuideDLC,
        [4] = TQG.sceneNameQuestGuideGroup
    }
    if c == 0 then
        c = 1;
        e = false;
        TQGButtonsButton1.m_object:SetState(1)
        TQGButtonsButton1.m_object:SetLocked(true)
        SCENE_MANAGER:Show(f[1])
    elseif e == true then
        SCENE_MANAGER:Show(f[c])
        e = false
    elseif e == false then
        SCENE_MANAGER:Hide(f[c])
        e = true
    end
    TQG.MenuState = c;
    TQG.MenuHidden = e
end
function TQG:IsGuideHidden()
    local g = {
        TQG.sceneNameQuestGuideOverview, TQG.sceneNameQuestGuideClassic,
        TQG.sceneNameQuestGuideDLC, TQG.sceneNameQuestGuideGroup
    }
    for h, i in ipairs(g) do
        if SCENE_MANAGER:IsShowing(i) then return false end
    end
    return true
end
function TQG.Overview:Initialize(j)
    TQG.BACKGROUND_FRAGMENT =
        ZO_FadeSceneFragment:New(TQG_SharedRightBackground)
    local k = TQG.sceneNameQuestGuideOverview;
    TQG_OVERVIEW_ALMANAC_FRAGMENT = ZO_HUDFadeSceneFragment:New(TQG_TabOverview)
    TQG_SCENE_OVERVIEW = ZO_Scene:New(k, SCENE_MANAGER)
    TQG_SCENE_OVERVIEW:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    TQG_SCENE_OVERVIEW:AddFragmentGroup(
        FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    TQG_SCENE_OVERVIEW:AddFragmentGroup(
        FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    TQG_SCENE_OVERVIEW:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    TQG_SCENE_OVERVIEW:AddFragment(TQG.BACKGROUND_FRAGMENT)
    TQG_SCENE_OVERVIEW:AddFragment(TREE_UNDERLAY_FRAGMENT)
    TQG_SCENE_OVERVIEW:AddFragment(TITLE_FRAGMENT)
    TQG_SCENE_OVERVIEW:AddFragment(ZO_SetTitleFragment:New(TQG_MENU_JOURNAL))
    TQG_SCENE_OVERVIEW:AddFragment(CODEX_WINDOW_SOUNDS)
    TQG_SCENE_OVERVIEW:AddFragment(TQG_OVERVIEW_ALMANAC_FRAGMENT)
    SYSTEMS:RegisterKeyboardRootScene(k, TQG_SCENE_Overview)
    TQG_SCENE_OVERVIEW:RegisterCallback("StateChange", function(l, m)
        if m == SCENE_SHOWING then
            TQG.MenuState = 1;
            TQG.MenuHidden = false;
            TQGButtonsButton2.m_object:SetState(0)
            TQGButtonsButton2.m_object:SetLocked(false)
        elseif m == SCENE_HIDING then
            TQG.MenuHidden = true
        end
    end)
end
function TQG.Overview:New(j)
    TQG.Overview:Initialize(j)
    local n = ZO_Object.New(self)
    n.control = j;
    n.zoneInfoContainer = j:GetNamedChild("ZoneInfoContainer")
    n.zoneStepContainer = j:GetNamedChild("ZoneStepContainer")
    n.titleText = j:GetNamedChild("TitleText")
    n.descriptionText = j:GetNamedChild("DescriptionText")
    n.objectivesText = j:GetNamedChild("ObjectivesText")
    n.objectiveLinePool = ZO_ControlPool:New("TQG_TabOverview_ObjectiveLine", j,
                                             "Objective")
    local o, p, q, r, s, t, u = n.zoneInfoContainer:GetAnchor(0)
    local v, w, x, y, z, A, B = n.zoneInfoContainer:GetAnchor(1)
    n.zoneInfoContainer:ClearAnchors()
    n.zoneInfoContainer:SetAnchor(p, q, r, s, t)
    n.zoneInfoContainer:SetAnchor(w, x, y, s, 100)
    n.currentProgressionLevel = #TQG.TopLevelOverview;
    n:InitializeCategoryList(j)
    n:RefreshList()
    local function C() n:RefreshList() end
    j:RegisterForEvent(EVENT_QUEST_COMPLETE, C)
    return n
end
function TQG.Overview:InitializeCategoryList(j)
    self.navigationTree = ZO_Tree:New(j:GetNamedChild(
                                          "NavigationContainerScrollChild"), 60,
                                      -10, 300)
    local D = {
        [1] = {
            "esoui/art/progression/progression_indexicon_world_down.dds",
            "esoui/art/progression/progression_indexicon_world_up.dds",
            "esoui/art/progression/progression_indexicon_world_over.dds"
        }
    }
    local function E(F) if D[F] then return unpack(D[F]) end end
    local function G(H, j, F, I) local J = j:GetNamedChild("Text") end
    local function K(H, j, F, I)
        j.progressionLevel = F;
        j.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        j.text:SetText(TQG.TopLevelOverview[F])
        local L, M, N = E(F)
        j.icon:SetTexture(I and L or M)
        j.iconHighlight:SetTexture(N)
        ZO_IconHeader_Setup(j, I)
        H.selectionFunction = G(H, j, F, I)
    end
    self.navigationTree:AddTemplate("ZO_IconHeader", K, G, nil, nil, 0)
    local function O(H, j, P, I)
        j:SetText(zo_strformat(SI_CADWELL_QUEST_NAME_FORMAT, P.name))
        GetControl(j, "CompletedIcon"):SetHidden(not P.completed)
        j:SetSelected(false)
    end
    local function Q(j, P, R, S)
        j:SetSelected(R)
        if R and not S then
            self:RefreshDetails()
            if P.name ~= TQG.ZoneLevelOverview[1][1].name then
                for h = TQG.Overview.minClassicLinks, TQG.Overview
                    .maxClassicLinks do
                    notesWithLinks[1][h]:SetHidden(true)
                end
                for h = TQG.Overview.minDLCLinks, TQG.Overview.maxDLCLinks do
                    notesWithLinks[2][h]:SetHidden(false)
                end
            end
            if P.name ~= TQG.ZoneLevelOverview[1][2].name then
                for h = TQG.Overview.minClassicLinks, TQG.Overview
                    .maxClassicLinks do
                    notesWithLinks[1][h]:SetHidden(false)
                end
                for h = TQG.Overview.minDLCLinks, TQG.Overview.maxDLCLinks do
                    notesWithLinks[2][h]:SetHidden(true)
                end
            end
            if P.name == TQG.ZoneLevelOverview[1][3].name then
                for h = TQG.Overview.minClassicLinks, TQG.Overview
                    .maxClassicLinks do
                    notesWithLinks[1][h]:SetHidden(true)
                end
                for h = TQG.Overview.minDLCLinks, TQG.Overview.maxDLCLinks do
                    notesWithLinks[2][h]:SetHidden(true)
                end
            end
        end
    end
    local function T(U, V) return U.name == V.name end
    self.navigationTree:AddTemplate("ZO_CadwellNavigationEntry", O, Q, T)
    self.navigationTree:SetExclusive(true)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end
local function W(F, X)
    local Y = TQG.ZoneLevelOverview[F][X].name;
    local Z = TQG.ZoneLevelOverview[F][X].id;
    local a0 = X;
    return Y, Z, a0
end
local function a1(F, X, objectiveIndex)
    local a2 = true;
    local a3 = false;
    local a4 = TQG.ObjectiveLevelOverview[F][X][objectiveIndex].name;
    local a5 = TQG.ObjectiveLevelOverview[F][X][objectiveIndex].description;
    local a6 = TQG.ObjectiveLevelOverview[F][X][objectiveIndex].description;
    return a4, a5, a6, objectiveIndex, a2, a3
end
function TQG.Overview:RefreshList()
    if self.control:IsHidden() then
        self.dirty = true;
        return
    end
    self.navigationTree:Reset()
    local a7 = {}
    for F = 1, #TQG.TopLevelOverview do
        local a8 = #TQG.ZoneLevelOverview[F]
        if self.currentProgressionLevel < F then break end
        if a8 > 0 then
            local a9 = self.navigationTree:AddNode("ZO_IconHeader", F)
            for aa = 1, a8 do
                local Y, Z, a0 = W(F, aa)
                local ab = true;
                local ac = {}
                local ad = #TQG.ObjectiveLevelOverview[F][aa]
                for objectiveIndex = 1, ad do
                    local a4, ae, af, ag, ah, ai = a1(F, aa, objectiveIndex)
                    ab = ab and ai;
                    table.insert(ac, {
                        name = a4,
                        openingText = ae,
                        closingText = af,
                        order = ag,
                        discovered = ah,
                        completed = ai
                    })
                end
                table.sort(ac, ZO_CadwellSort)
                table.insert(a7, {
                    name = Y,
                    description = Z,
                    order = a0,
                    completed = ab,
                    objectives = ac,
                    parent = a9
                })
            end
        end
    end
    table.sort(a7, ZO_CadwellSort)
    for h = 1, #a7 do
        local aj = a7[h]
        local a9 = aj.parent;
        self.navigationTree:AddNode("ZO_CadwellNavigationEntry", aj, a9)
    end
    self.navigationTree:Commit()
    self:RefreshDetails()
end
function TQG.Overview:RefreshDetails()
    local self = TQG_ALMANAC_OVERVIEW;
    self.objectiveLinePool:ReleaseAllObjects()
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then
        self.zoneInfoContainer:SetHidden(true)
        self.zoneStepContainer:SetHidden(true)
        return
    else
        self.zoneInfoContainer:SetHidden(false)
        self.zoneStepContainer:SetHidden(false)
    end
    self.titleText:SetText(zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, ak.name))
    self.descriptionText:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT,
                                              ak.description))
    local al;
    for h = 1, #ak.objectives do
        local am = ak.objectives[h]
        local an = self.objectiveLinePool:AcquireObject()
        if am.discovered and not am.completed then
            an:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        elseif not am.discovered then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        else
            an:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(false)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.closingText))
        end
        if not al then
            an:SetAnchor(TOPLEFT, self.objectivesText, BOTTOMLEFT, 25, 15)
        else
            an:SetAnchor(TOPLEFT, al, BOTTOMLEFT, 0, 15)
        end
        al = an
    end
end
function TQG.Overview:OnShown()
    if self.dirty then
        self:RefreshList()
        self.dirty = false
    end
end
function TQG_TabOverview_OnShown() TQG_ALMANAC_OVERVIEW:OnShown() end
function TQG_TabOverview_Initialize(j) TQG_ALMANAC_OVERVIEW =
    TQG.Overview:New(j) end
local function ao(ap, aq, ar, as)
    local j = GetControl("TQG_TabOverviewZoneStepContainer")
    local at = "Click_MenuBar"
    local au = 200;
    local av = 28;
    local aw = 0;
    local ax = 10;
    if not notesWithLinks then
        notesWithLinks = {}
        notesWithLinks[1] = {}
        notesWithLinks[2] = {}
        notesWithLinks[3] = {}
    end
    notesWithLinks[ap][#notesWithLinks[ap] + 1] =
        CreateControlFromVirtual(aq, j, "ZO_DefaultButton")
    local ay = math.fmod(#notesWithLinks[ap], 3)
    if #notesWithLinks[ap] >= 2 and #notesWithLinks[ap] <= 3 then
        aw = (#notesWithLinks[ap] - 1) * 190
    elseif #notesWithLinks[ap] >= 4 then
        if ay ~= 1 then
            if ay == 0 then
                aw = 2 * 190
            else
                aw = (math.fmod(#notesWithLinks[ap], 3) - 1) * 190
            end
        end
        ax = (math.ceil(#notesWithLinks[ap] / 3) - 1) * (33 + ax)
    end
    notesWithLinks[ap][#notesWithLinks[ap]]:SetAnchor(LEFT, j, LEFT, aw, ax)
    notesWithLinks[ap][#notesWithLinks[ap]]:SetDimensions(au, av)
    notesWithLinks[ap][#notesWithLinks[ap]]:SetHandler("OnClicked", function()
        RequestOpenUnsafeURL(as)
    end)
    notesWithLinks[ap][#notesWithLinks[ap]]:SetText(ar)
end
DefaultValues = {
    ["en"] = {},
    ["de"] = {},
    ["fr"] = {},
    ["ru"] = {},
    ["ruMaps"] = {}
}
local function az(aA, aB)
    if aB ~= a then return end
    if not b() then return end
    TQG.DLC:SetupPins()
    TQG.Group:SetupPins()
    ao(1, "TQGNoteLink1.1", TQG.BtnQuestMap,
       "https://en.uesp.net/wiki/Online:Story_Quests#Quest_Map")
    ao(1, "TQGNoteLink1.2", TQG.BtnCraglorn,
       "https://en.uesp.net/wiki/Online:Craglorn#Quest_Map")
    ao(2, "TQGNoteLink2.1", TQG.BtnImperialCity,
       "https://en.uesp.net/wiki/Online:Imperial_City#Quests")
    ao(2, "TQGNoteLink2.2", TQG.BtnOrsinium,
       "https://en.uesp.net/wiki/Online:Wrothgar#Quest_Map")
    EVENT_MANAGER:UnregisterForEvent("TheQuestingGuide", EVENT_ADD_ON_LOADED)
end
EVENT_MANAGER:RegisterForEvent("TheQuestingGuide", EVENT_ADD_ON_LOADED, az)
local function aC() TQG:ToggleMenu() end
SLASH_COMMANDS["/tqg"] = aC;
if not TQG then TQG = {} end
TQG.Classic = ZO_Object:Subclass()
TQG.sceneNameQuestGuideClassic = "QuestGuideClassic"
TQG.selectedClassicZoneId = nil;
TQG.trackedClassicZoneId = nil;
TQG.ConfirmContinueClassicToEndingQuests = {
    mustChoose = false,
    title = {text = GetString(TQG_CONFIRM_QUEST_TITLE)},
    mainText = {text = GetString(TQG_CONFIRM_MAIN_TEXT)},
    buttons = {
        [1] = {
            keybind = "DIALOG_PRIMARY",
            text = GetString(TQG_CONFIRM_QUEST_ZONE_STORY),
            callback = function()
                TQG:TrackNextActivity(TQG.selectedClassicZoneId, nil)
                ZONE_STORIES_KEYBOARD:BuildZonesList()
                TQG.Classic:UpdateZoneStoryButtons()
            end
        },
        [2] = {
            keybind = "DIALOG_SECONDARY",
            text = GetString(TQG_CONFIRM_QUEST_POI),
            callback = function()
                TQG:TrackNextActivity(TQG.selectedClassicZoneId,
                                      ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST)
                ZONE_STORIES_KEYBOARD:BuildZonesList()
                TQG.Classic:UpdateZoneStoryButtons()
            end
        }
    }
}
ZO_Dialogs_RegisterCustomDialog("TQG_CONFIRM_CONTINUE_CLASSIC_ZONE_STORY",
                                TQG.ConfirmContinueClassicToEndingQuests)
local function aD()
    local F = 0;
    local X = 0;
    local aE = 1;
    for h = 1, #TQG.ZoneLevelClassic do
        while aE <= #TQG.ZoneLevelClassic[h] do
            if TQG.ZoneLevelClassic[h][aE].id == TQG.selectedClassicZoneId then
                F = h;
                X = aE;
                break
            end
            aE = aE + 1
        end
        if F > 0 then
            break
        else
            aE = 1
        end
    end
    return F, X
end
local function aF(F, X)
    if type(TQG.selectedDLCZoneId) ~= "number" then return end
    local aG, aH;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedClassicZoneId, ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST)
    local aI = aH - aG > 0;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedClassicZoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
    local aJ = aH - aG == TQG.ZoneLevelClassic[F][X].PreEndSideQuestCheck;
    return false, false
end
local function aK(F, X)
    local self = TQG_ALMANAC_CLASSIC;
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then return end
    local aL;
    if TQG.ObjectiveLevelClassic[F][X][0] then
        aL = TQG.ObjectiveLevelClassic[F][X][0].prologueQIds
    else
        aL = nil
    end
    if not aL then return false, false end
    for h = 1, aL do
        if ak.objectives[h].discovered == false then
            return true, false, h - 1
        elseif ak.objectives[h].completed == false then
            return true, true, h - 1
        end
    end
    return false, false
end
function TQG:TrackNextActivity(aM, aN)
    if aM and type(aM) == "number" then
        if ZO_ZoneStories_Shared.IsZoneCollectibleUnlocked(aM) then
            local aO = true;
            local aP = aN;
            TrackNextActivityForZoneStory(aM, aP, aO)
        else
            local aa = GetZoneIndex(aM)
            local aQ = GetCollectibleIdForZone(aa)
            local aR = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(aQ)
            local aS = aR:GetCategoryType()
            if aS == COLLECTIBLE_CATEGORY_TYPE_CHAPTER then
                ZO_ShowChapterUpgradePlatformScreen(
                    MARKET_OPEN_OPERATION_ZONE_STORIES)
            else
                local aT = zo_strformat(SI_CROWN_STORE_SEARCH_FORMAT_STRING,
                                        aR:GetName())
                ShowMarketAndSearch(aT, MARKET_OPEN_OPERATION_ZONE_STORIES)
            end
        end
    end
end
function TQG:GetPlayStoryButtonText(aM)
    if type(aM) == "number" then
        if not ZO_ZoneStories_Shared.IsZoneCollectibleUnlocked(aM) then
            return ZO_ZoneStories_Shared.GetZoneCollectibleUnlockText(aM)
        elseif ZO_ZoneStories_Manager.IsZoneComplete(aM) then
            return zo_strformat(SI_ZONE_STORY_ZONE_COMPLETE_ACTION)
        elseif ZO_ZoneStories_Manager.IsZoneCompletionTypeComplete(aM,
                                                                   ZONE_COMPLETION_TYPE_PRIORITY_QUESTS) or
            not CanZoneStoryContinueTrackingActivitiesForCompletionType(aM,
                                                                        ZONE_COMPLETION_TYPE_PRIORITY_QUESTS) then
            return zo_strformat(SI_ZONE_STORY_EXPLORE_ZONE_ACTION)
        elseif not IsZoneStoryStarted(aM) then
            return zo_strformat(SI_ZONE_STORY_START_STORY_ACTION)
        else
            return zo_strformat(SI_ZONE_STORY_CONTINUE_STORY_ACTION)
        end
    end
    return zo_strformat(SI_ZONE_STORY_CONTINUE_STORY_ACTION)
end
function TQG.Classic:PlayStory_OnClick()
    local F, X;
    local aI, aJ;
    local aU;
    F, X = aD()
    if F < 1 then return end
    aI, aJ = aF(F, X)
    local aU, aV, objectiveIndex = aK(F, X)
    if TQG.ZoneLevelClassic[F][X].SideQuestCheck and aI and aJ then
        ZO_Dialogs_ShowDialog("TQG_CONFIRM_CONTINUE_CLASSIC_ZONE_STORY")
    else
        TQG:TrackNextActivity(TQG.selectedClassicZoneId)
        ZONE_STORIES_KEYBOARD:BuildZonesList()
        self:UpdateZoneStoryButtons()
    end
end
function TQG.Classic:StopTracking_OnClick()
    ClearTrackedZoneStory()
    ZONE_STORIES_KEYBOARD:BuildZonesList()
    self:UpdateZoneStoryButtons()
end
function TQG.Classic:UpdateZoneStoryButtons(P)
    if P then
        for h = 1, #TQG.TopLevelClassic do
            for aE = 1, #TQG.ZoneLevelClassic[h] do
                if TQG.ZoneLevelClassic[h][aE].name == P.name then
                    TQG.selectedClassicZoneId = TQG.ZoneLevelClassic[h][aE].id;
                    break
                end
            end
        end
    end
    local aM = TQG.selectedClassicZoneId;
    local aW;
    local aX;
    if type(aM) == "string" then
        aW = false;
        aX = false
    else
        aW = ZO_ZoneStories_Manager.GetZoneAvailability(aM)
        aX = CanZoneStoryContinueTrackingActivities(aM)
    end
    TQG.Classic.playStoryButton:SetEnabled(aW and aX)
    TQG.Classic.playStoryButton:SetText(TQG:GetPlayStoryButtonText(aM))
    local aY = GetTrackedZoneStoryActivityInfo()
    TQG.Classic.stopTrackingButton:SetHidden(aY ~= aM)
end
function TQG.Classic:StoryButtonHook(aZ)
    local a_ = GetControl(aZ)
    local b0 = a_:GetNamedChild("ButtonContainer")
    TQG.Classic.playStoryButton = b0:GetNamedChild("PlayStoryButton")
    TQG.Classic.playStoryButton:SetClickSound(SOUNDS.ZONE_STORIES_TRACK_ACTIVITY)
    TQG.Classic.stopTrackingButton = b0:GetNamedChild("StopTrackingButton")
end
function TQG.Classic:Initialize(j)
    local b1 = TQG.sceneNameQuestGuideClassic;
    TQG_CLASSIC_ALMANAC_FRAGMENT = ZO_HUDFadeSceneFragment:New(TQG_TabClassic)
    TQG_SCENE_CLASSIC = ZO_Scene:New(b1, SCENE_MANAGER)
    TQG_SCENE_CLASSIC:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    TQG_SCENE_CLASSIC:AddFragmentGroup(
        FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    TQG_SCENE_CLASSIC:AddFragmentGroup(
        FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    TQG_SCENE_CLASSIC:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    TQG_SCENE_CLASSIC:AddFragment(TQG.BACKGROUND_FRAGMENT)
    TQG_SCENE_CLASSIC:AddFragment(TREE_UNDERLAY_FRAGMENT)
    TQG_SCENE_CLASSIC:AddFragment(TITLE_FRAGMENT)
    TQG_SCENE_CLASSIC:AddFragment(ZO_SetTitleFragment:New(TQG_MENU_JOURNAL))
    TQG_SCENE_CLASSIC:AddFragment(CODEX_WINDOW_SOUNDS)
    TQG_SCENE_CLASSIC:AddFragment(TQG_CLASSIC_ALMANAC_FRAGMENT)
    SYSTEMS:RegisterKeyboardRootScene(b1, TQG_SCENE_Classic)
    TQG_SCENE_CLASSIC:RegisterCallback("StateChange", function(l, m)
        if m == SCENE_SHOWING then
            TQG.MenuState = 2;
            TQG.MenuHidden = false;
            TQGButtonsButton1.m_object:SetState(0)
            TQGButtonsButton1.m_object:SetLocked(false)
            TQGButtonsButton3.m_object:SetState(0)
            TQGButtonsButton3.m_object:SetLocked(false)
            TQGButtonsButton4.m_object:SetState(0)
            TQGButtonsButton4.m_object:SetLocked(false)
        elseif m == SCENE_HIDING then
            TQG.MenuHidden = true
        end
    end)
    TQG.Classic:StoryButtonHook("TQG_TabClassic")
end
function TQG.Classic:New(j)
    TQG.Classic:Initialize(j)
    local n = ZO_Object.New(self)
    n.control = j;
    n.zoneInfoContainer = j:GetNamedChild("ZoneInfoContainer")
    n.zoneStepContainer = j:GetNamedChild("ZoneStepContainer")
    n.titleText = j:GetNamedChild("TitleText")
    n.descriptionText = j:GetNamedChild("DescriptionText")
    n.objectivesText = j:GetNamedChild("ObjectivesText")
    n.objectiveLinePool = ZO_ControlPool:New("TQG_TabClassic_ObjectiveLine", j,
                                             "Objective")
    n.currentProgressionLevel = #TQG.TopLevelClassic;
    n:InitializeCategoryList(j)
    n:RefreshList()
    local function b2() n:RefreshList() end
    local function C() n:RefreshList() end
    j:RegisterForEvent(EVENT_QUEST_ADDED, b2)
    j:RegisterForEvent(EVENT_QUEST_COMPLETE, C)
    return n
end
function TQG.Classic:InitializeCategoryList(j)
    self.navigationTree = ZO_Tree:New(j:GetNamedChild(
                                          "NavigationContainerScrollChild"), 60,
                                      -10, 300)
    local D = {
        [1] = {
            "esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
            "esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
            "esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds"
        },
        [2] = {
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_over.dds"
        },
        [3] = {
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_over.dds"
        },
        [4] = {
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_down.dds",
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_over.dds"
        },
        [5] = {
            "esoui/art/icons/progression_tabicon_fightersguild_down.dds",
            "esoui/art/icons/progression_tabicon_fightersguild_up.dds",
            "esoui/art/icons/progression_tabicon_fightersguild_over.dds"
        },
        [6] = {
            "esoui/art/icons/progression_tabicon_magesguild_down.dds",
            "esoui/art/icons/progression_tabicon_magesguild_up.dds",
            "esoui/art/icons/progression_tabicon_magesguild_over.dds"
        },
        [7] = {
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_down.dds",
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_up.dds",
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_over.dds"
        },
        [8] = {
            "esoui/art/treeicons/antiquities_tabicon_craglorn_down.dds",
            "esoui/art/treeicons/antiquities_tabicon_craglorn_up.dds",
            "esoui/art/treeicons/antiquities_tabicon_craglorn_over.dds"
        },
        [9] = {
            "EsoUI/Art/Campaign/campaign_tabIcon_browser_down.dds",
            "EsoUI/Art/Campaign/campaign_tabIcon_browser_up.dds",
            "EsoUI/Art/Campaign/campaign_tabIcon_browser_over.dds"
        }
    }
    local function E(F) if D[F] then return unpack(D[F]) end end
    local function G(H, j, F, I) local J = j:GetNamedChild("Text") end
    local function K(H, j, F, I)
        j.progressionLevel = F;
        j.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        j.text:SetText(TQG.TopLevelClassic[F])
        local L, M, N = E(F)
        j.icon:SetTexture(I and L or M)
        j.iconHighlight:SetTexture(N)
        ZO_IconHeader_Setup(j, I)
        H.selectionFunction = G(H, j, F, I)
    end
    self.navigationTree:AddTemplate("ZO_IconHeader", K, G, nil, nil, 0)
    local function O(H, j, P, I)
        j:SetText(zo_strformat(SI_CADWELL_QUEST_NAME_FORMAT, P.name))
        GetControl(j, "CompletedIcon"):SetHidden(not P.completed)
        j:SetSelected(false)
    end
    local function Q(j, P, R, S)
        j:SetSelected(R)
        if R and not S then
            TQG.Classic:UpdateZoneStoryButtons(P)
            self:RefreshDetails()
        end
    end
    local function T(U, V) return U.name == V.name end
    self.navigationTree:AddTemplate("ZO_CadwellNavigationEntry", O, Q, T)
    self.navigationTree:SetExclusive(true)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end
local function W(F, X)
    local a4 = TQG.ZoneLevelClassic[F][X].name;
    local b3 = TQG.ZoneLevelClassic[F][X].id;
    local Z = ""
    if type(a4) == "number" or a4 == "" then
        a4 = TQG.ZoneLevelClassic[F][X].name;
        a4 = "(" .. string.format("%.2f", a4) .. ")"
        local b4 = GetCVar("language.2")
        if b4 == "de" or b4 == "fr" or b4 == "ru" then
            a4 = string.gsub(a4, "%.", ",", 1)
        end
        local Y = GetZoneNameById(b3)
        TQG.ZoneLevelClassic[F][X].name = a4 .. " " .. Y
    end
    local Y = TQG.ZoneLevelClassic[F][X].name;
    if type(b3) == "string" then
        Z = b3
    else
        Z = GetZoneDescriptionById(b3)
    end
    local a0 = X;
    return b3, Y, Z, a0
end
function TQG.Classic:b7(F, X, objectiveIndex)
    local b4 = GetCVar("language.2")
    if b4 ~= "de" and b4 ~= "fr" and b4 ~= "ru" then b4 = "en" end
    local a3 = false;
    local ag = objectiveIndex;
    local a4, a5, a6, a2;
    local b5, b6, b7, b8;
    local aM = TQG.ZoneLevelClassic[F][X].id;
    local b9 = false;
    local ba = false;
    local bb = TQG.ObjectiveLevelClassic[F][X][objectiveIndex].overrideDetails;
    local bc = TQG.ObjectiveLevelClassic[F][X][objectiveIndex].internalId;
    if bb then
        local overrideName = TQG.ObjectiveLevelClassic[F][X][objectiveIndex]
                                 .overrideQName or nil;
        b5 = bc;
        a4 = GetQuestName(b5)
        if overrideName then a4 = overrideName end
    else
        local bd = TQG.ObjectiveLevelClassic[F][X][1].prologueQIds;
        if bd and objectiveIndex >= bd then
            ag = ag + bd - 1;
            objectiveIndex = objectiveIndex - (bd - 1)
        end
        a4 = GetZoneStoryActivityNameByActivityIndex(aM,
                                                     ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
                                                     objectiveIndex)
        b5 = GetZoneActivityIdForZoneCompletionType(aM,
                                                    ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
                                                    objectiveIndex)
        objectiveIndex = ag
    end
    if not b5 then
        for h, be in ipairs(TQG.MultiQuestIds[1]) do
            local bf = GetCompletedQuestInfo(be) or ""
            if bf == a4 then
                local b3 = 4704;
                b5 = b3;
                b8 = TQG.ObjectiveLevelClassic[F][X][objectiveIndex]
                         .overrideDescription;
                _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b5)
                if b6 == "" then b6 = nil end
                b9 = true;
                break
            end
        end
    end
    if not b5 then
        for h = 3, 10 do
            for aE, bg in ipairs(TQG.MultiQuestIds[h]) do
                local bf = GetCompletedQuestInfo(bg) or ""
                if bf == a4 then
                    b5 = TQG.ObjectiveLevelClassic[F][X][objectiveIndex]
                             .internalId;
                    b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
                    _, b6, b7 = nil, "", 0;
                    if b6 == "" then b6 = nil end
                    ba = true;
                    break
                end
            end
        end
    end
    if not b5 then
        for h, bh in pairs(LibUespQuestData.quests) do
            local b3 = tonumber(bh.internalId)
            local bf = GetCompletedQuestInfo(b3)
            if bf == "" or bf == nil then
                bf = GetCompletedQuestInfo(b3) or ""
            end
            if GetQuestName(b3) == a4 and not overrideName then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
                _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b5)
                if b6 == "" then b6 = nil end
                break
            elseif bf == a4 then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
                _, b6 = LibUespQuestData:GetUespQuestLocationInfo(b5)
                if b6 == "" then b6 = nil end
                if F == 2 and X == 2 then end
                break
            end
        end
        if F == 2 and X == 2 then end
    else
        b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
        _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b5)
        if b6 == "" then b6 = nil end
    end
    if type(aM) == "number" then
        a5 = b6 or GetZoneNameById(aM)
    else
        a5 = b6
    end
    if GetCompletedQuestInfo(b5) == "" and not b9 and not ba then
        a3 = false;
        for h = 1, GetNumJournalQuests() do
            if GetJournalQuestName(h) == a4 then
                a2 = true;
                _, a5 = GetJournalQuestInfo(h)
                break
            else
                a2 = false
            end
        end
        a6 = ""
    else
        a3 = true;
        a2 = true;
        a5 = ""
        a6 = b8
    end
    local function bi(bj, bk)
        if a4 == GetQuestName(bk) then
            bj = string.gsub(bj, " u2026.", "...")
        else
            bj = string.gsub(bj, " u2026", "...")
        end
        return bj
    end
    if b8 ~= "" and b8 then
        if a6 == b8 then
            a6 = bi(a6, 4296)
            a6 = bi(a6, -1)
            a6 = string.gsub(a6, "u2014", "—")
        elseif a5 == b8 then
            a5 = bi(a5, 4296)
            a5 = bi(a5, -1)
            a5 = string.gsub(a5, "u2014", "—")
        end
    end
    local bl = TQG.ObjectiveLevelClassic[F][X][objectiveIndex].overrideZone;
    if a5 == nil or a5 == "" or bl then
        a5 = bl;
        if a5 == nil or a5 == "" then
            a5 = GetString(TQG_DEFAULT_QUEST_INCOMPLETE)
        end
    end
    if a6 == nil or a6 == "" then a6 = GetString(TQG_DEFAULT_QUEST_COMPLETE) end
    local bm = TQG.ObjectiveLevelClassic[F][X][objectiveIndex].optional or false;
    return a4, a5, a6, ag, a2, a3, bm
end
function TQG.Classic:RefreshList()
    if self.control:IsHidden() then
        self.dirty = true;
        return
    end
    self.navigationTree:Reset()
    local a7 = {}
    for F = 1, #TQG.TopLevelClassic do
        local a8 = #TQG.ZoneLevelClassic[F]
        if self.currentProgressionLevel < F then break end
        if a8 > 0 then
            local a9 = self.navigationTree:AddNode("ZO_IconHeader", F)
            for aa = 1, a8 do
                local aM, Y, Z, a0 = W(F, aa)
                local bn = 0;
                local ab = true;
                local ac = {}
                local aG, aH, bo, bp;
                if type(aM) == "number" then
                    aG, aH, bo, bp =
                        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
                            aM, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                elseif type(aM) == "string" then
                    aG, aH, bo, bp = 0, 0, 0, 0
                end
                local ad = bo;
                local bq = false;
                if bp > 0 then
                    ad = ad + 1;
                    bq = true
                end
                if ad == 0 then
                    ad = #TQG.ObjectiveLevelClassic[F][aa]
                end
                local br = 1;
                if ad ~= #TQG.ObjectiveLevelClassic[F][aa] then
                    if TQG.ObjectiveLevelClassic[F][aa][0] then
                        br = 0;
                        local bd = TQG.ObjectiveLevelClassic[F][aa][0]
                                       .prologueQIds;
                        if bd and bd > 1 then
                            ad = ad + bd - 1
                        end
                    elseif TQG.ObjectiveLevelClassic[F][aa][ad + 1]
                        .overrideDetails then
                        ad = ad + #TQG.ObjectiveLevelClassic[F][aa] - ad
                    end
                end
                for objectiveIndex = br, ad do
                    local a4, ae, af, ag, ah, ai, bs;
                    if objectiveIndex == ad and bq == true then
                        a4 = "TBC"
                        ae, af = GetErrorString(bp)
                        ag = objectiveIndex;
                        ah = false;
                        ai = false;
                        bs = false
                    else
                        a4, ae, af, ag, ah, ai, bs =
                            TQG.Classic:b7(F, aa, objectiveIndex, aG)
                        ab = ab and (ai or bs)
                        if ai then bn = bn + 1 end
                    end
                    table.insert(ac, {
                        name = a4,
                        openingText = ae,
                        closingText = af,
                        order = ag,
                        discovered = ah,
                        completed = ai
                    })
                end
                table.sort(ac, ZO_CadwellSort)
                table.insert(a7, {
                    name = Y,
                    description = Z,
                    order = a0,
                    completed = ab and bn >= 1,
                    objectives = ac,
                    parent = a9
                })
            end
        end
    end
    table.sort(a7, ZO_CadwellSort)
    for h = 1, #a7 do
        local aj = a7[h]
        local a9 = aj.parent;
        self.navigationTree:AddNode("ZO_CadwellNavigationEntry", aj, a9)
    end
    self.navigationTree:Commit()
    self:RefreshDetails()
end
function TQG.Classic:RefreshDetails()
    local self = TQG_ALMANAC_CLASSIC;
    self.objectiveLinePool:ReleaseAllObjects()
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then
        self.zoneInfoContainer:SetHidden(true)
        self.zoneStepContainer:SetHidden(true)
        return
    else
        self.zoneInfoContainer:SetHidden(false)
        self.zoneStepContainer:SetHidden(false)
    end
    self.titleText:SetText(zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, ak.name))
    self.descriptionText:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT,
                                              ak.description))
    local al;
    for h = 1, #ak.objectives do
        local am = ak.objectives[h]
        local an = self.objectiveLinePool:AcquireObject()
        if am.name == "TBC" then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(am.openingText)
        elseif am.discovered and not am.completed then
            an:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        elseif not am.discovered then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        else
            an:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(false)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.closingText))
        end
        if not al then
            an:SetAnchor(TOPLEFT, self.objectivesText, BOTTOMLEFT, 25, 15)
        else
            an:SetAnchor(TOPLEFT, al, BOTTOMLEFT, 0, 15)
        end
        al = an
    end
end
function TQG.Classic:OnShown()
    if self.dirty then
        self:RefreshList()
        self.dirty = false
    end
end
function TQG_TabClassic_OnShown() TQG_ALMANAC_CLASSIC:OnShown() end
function TQG_TabClassic_Initialize(j) TQG_ALMANAC_CLASSIC = TQG.Classic:New(j) end
if not TQG then TQG = {} end
TQG.DLC = ZO_Object:Subclass()
TQG.sceneNameQuestGuideDLC = "QuestGuideDLC"
TQG.selectedDLCZoneId = nil;
TQG.trackedDLCPrologueQuestId = nil;
TQG.ConfirmContinueDLCToEndingQuests = {
    mustChoose = false,
    title = {text = GetString(TQG_CONFIRM_QUEST_TITLE)},
    mainText = {text = GetString(TQG_CONFIRM_MAIN_TEXT)},
    buttons = {
        [1] = {
            keybind = "DIALOG_PRIMARY",
            text = GetString(TQG_CONFIRM_QUEST_ZONE_STORY),
            callback = function()
                TQG:TrackNextActivity(TQG.selectedDLCZoneId, nil)
                ZONE_STORIES_KEYBOARD:BuildZonesList()
                TQG.DLC:UpdateStoryButtons()
            end
        },
        [2] = {
            keybind = "DIALOG_SECONDARY",
            text = GetString(TQG_CONFIRM_QUEST_POI),
            callback = function()
                TQG:TrackNextActivity(TQG.selectedDLCZoneId,
                                      ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST)
                ZONE_STORIES_KEYBOARD:BuildZonesList()
                TQG.DLC:UpdateStoryButtons()
            end
        }
    }
}
ZO_Dialogs_RegisterCustomDialog("TQG_CONFIRM_CONTINUE_CLASSIC_ZONE_STORY",
                                TQG.ConfirmContinueDLCToEndingQuests)
local function bt()
    local F = 0;
    local X = 0;
    local aE = 1;
    for h = 1, #TQG.ZoneLevelDLC do
        while aE <= #TQG.ZoneLevelDLC[h] do
            if TQG.ZoneLevelDLC[h][aE].id == TQG.selectedDLCZoneId then
                F = h;
                X = aE;
                break
            end
            aE = aE + 1
        end
        if F > 0 then
            break
        else
            aE = 1
        end
    end
    return F, X
end
local function bu(F, X)
    if type(TQG.selectedDLCZoneId) ~= "number" then return end
    local aG, aH;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedDLCZoneId, ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST)
    local aI = aH - aG > 0;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedDLCZoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
    local aJ = aH - aG == TQG.ZoneLevelDLC[F][X].PreEndSideQuestCheck;
    return false, false
end
local function bv(F, X)
    local self = TQG_ALMANAC_DLC;
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then return end
    local aL;
    if TQG.ObjectiveLevelDLC[F][X][0] then
        aL = TQG.ObjectiveLevelDLC[F][X][0].prologueQIds
    else
        aL = nil
    end
    if not aL then return false, false end
    for h = 1, aL do
        if ak.objectives[h].discovered == false then
            return true, false, h - 1
        elseif ak.objectives[h].completed == false then
            return true, true, h - 1
        end
    end
    return false, false
end
local b4 = GetCVar("language.2")
if b4 ~= "de" and b4 ~= "fr" then b4 = "en" end
local bw = "TQG_QuestsDLC"
local bx = {}
local function by()
    bx = {
        [5935] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(19))] = {
                {
                    0.5559,
                    0.5307,
                    0.012,
                    questId = 5935,
                    text = TQG.DLCQuestIdToTooltip[5935]
                }
            },
            [GetMapNameById(33)] = {
                {
                    0.465429,
                    0.154768,
                    0.05,
                    questId = 5935,
                    text = TQG.DLCQuestIdToTooltip[5935]
                }
            }
        },
        [6023] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
                {
                    0.567,
                    0.918,
                    0.012,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 1
                }
            },
            [GetMapNameById(243)] = {
                {
                    0.231,
                    0.5038,
                    0.05,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
                {
                    0.2746,
                    0.7435,
                    0.012,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 3
                }
            },
            [GetMapNameById(63)] = {
                {
                    0.479,
                    0.3914,
                    0.05,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 3
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.85845,
                    0.330827,
                    0.012,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 2
                }
            },
            [GetMapNameById(24)] = {
                {
                    0.491956,
                    0.434811,
                    0.05,
                    questId = 6023,
                    text = TQG.DLCQuestIdToTooltip[6023],
                    allianceId = 2
                }
            }
        },
        [6097] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
                {
                    0.567,
                    0.918,
                    0.012,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 1
                }
            },
            [GetMapNameById(243)] = {
                {
                    0.231,
                    0.5038,
                    0.05,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.85845,
                    0.330827,
                    0.012,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 2
                }
            },
            [GetMapNameById(24)] = {
                {
                    0.491956,
                    0.434811,
                    0.05,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 2
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
                {
                    0.2746,
                    0.7435,
                    0.012,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 3
                }
            },
            [GetMapNameById(63)] = {
                {
                    0.479,
                    0.3914,
                    0.05,
                    questId = 6097,
                    text = TQG.DLCQuestIdToTooltip[6097],
                    allianceId = 3
                }
            }
        },
        [6226] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(383))] = {
                {
                    0.5641,
                    0.4696,
                    0.012,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 1
                }
            },
            [GetMapNameById(445)] = {
                {
                    0.49595,
                    0.36798,
                    0.05,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.5688,
                    0.5339,
                    0.012,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 2
                }
            },
            [GetMapNameById(205)] = {
                {
                    0.58299,
                    0.76898,
                    0.05,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 2
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(19))] = {
                {
                    0.545,
                    0.534,
                    0.012,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 3
                }
            },
            [GetMapNameById(33)] = {
                {
                    0.4221,
                    0.16459,
                    0.05,
                    questId = 6226,
                    text = TQG.DLCQuestIdToTooltip[6226],
                    allianceId = 3
                }
            }
        },
        [6242] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(117))] = {
                {
                    0.5076,
                    0.2318,
                    0.012,
                    questId = 6242,
                    text = TQG.DLCQuestIdToTooltip[6242]
                }
            },
            [GetMapNameById(217)] = {
                {
                    0.8422,
                    0.2390,
                    0.05,
                    questId = 6242,
                    text = TQG.DLCQuestIdToTooltip[6242]
                }
            }
        },
        [6299] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
                {
                    0.6411,
                    0.8744,
                    0.012,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 1
                }
            },
            [GetMapNameById(243)] = {
                {
                    0.5971,
                    0.2883,
                    0.05,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.9120,
                    0.3982,
                    0.012,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 2
                }
            },
            [GetMapNameById(24)] = {
                {
                    0.7593,
                    0.7710,
                    0.05,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 2
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
                {
                    0.3422,
                    0.7472,
                    0.012,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 3
                }
            },
            [GetMapNameById(63)] = {
                {
                    0.8074,
                    0.40887,
                    0.05,
                    questId = 6299,
                    text = TQG.DLCQuestIdToTooltip[6299],
                    allianceId = 3
                }
            }
        },
        [6306] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(383))] = {
                {
                    0.5942,
                    0.1537,
                    0.012,
                    questId = 6306,
                    text = TQG.DLCQuestIdToTooltip[6306]
                }
            }
        },
        [6395] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
                {
                    0.63695,
                    0.93553,
                    0.012,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 1
                }
            },
            [GetMapNameById(243)] = {
                {
                    0.5766,
                    0.5903,
                    0.05,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.90468,
                    0.38861,
                    0.012,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 2
                }
            },
            [GetMapNameById(24)] = {
                {
                    0.7226,
                    0.7231,
                    0.05,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 2
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
                {
                    0.32298,
                    0.80255,
                    0.012,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 3
                }
            },
            [GetMapNameById(63)] = {
                {
                    0.7141,
                    0.6731,
                    0.05,
                    questId = 6395,
                    text = TQG.DLCQuestIdToTooltip[6395],
                    allianceId = 3
                }
            }
        },
        [6398] = {
            [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
                {
                    0.63695,
                    0.93553,
                    0.012,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 1
                }
            },
            [GetMapNameById(243)] = {
                {
                    0.5766,
                    0.5903,
                    0.05,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 1
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
                {
                    0.90468,
                    0.38861,
                    0.012,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 2
                }
            },
            [GetMapNameById(24)] = {
                {
                    0.7226,
                    0.7231,
                    0.05,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 2
                }
            },
            [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
                {
                    0.32298,
                    0.80255,
                    0.012,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 3
                }
            },
            [GetMapNameById(63)] = {
                {
                    0.7141,
                    0.6731,
                    0.05,
                    questId = 6398,
                    text = TQG.DLCQuestIdToTooltip[6398],
                    allianceId = 3
                }
            }
        }
    }
end
function TQG.DLC:SetupPins()
    by()
    local function bz(bA)
        local bB = GetMapName()
        local b5 = TQG.trackedDLCPrologueQuestId;
        if bx[b5] == nil then return end
        if bx[b5][bB] == nil then return end
        local bC = bx[b5][bB]
        for _, bD in ipairs(bC) do bA:CreatePin(_G[bw], bD, bD[1], bD[2]) end
    end
    local bE = bz;
    local bF = nil;
    pinLayoutData = {
        showsPinAndArea = true,
        level = 10,
        minSize = 100,
        texture = "EsoUI/Art/MapPins/MapAutoNavigationPing.dds",
        isAnimated = true,
        framesWide = 32,
        framesHigh = 1,
        framesPerSecond = 32
    }
    local bG = {
        creator = function(bH)
            local bI, ar;
            local bB = GetMapName()
            local b5 = TQG.trackedDLCPrologueQuestId;
            if bx[b5] == nil then return end
            if bx[b5][bB] == nil then return end
            local bC = bx[b5][bB]
            for _, bD in ipairs(bC) do
                if bD[4] == bH.m_PinTag[4] then
                    bI = GetQuestName(bD.questId)
                    ar = bD.text;
                    break
                end
            end
            InformationTooltip:AddLine(bI, "ZoFontGameOutline",
                                       ZO_SELECTED_TEXT:UnpackRGB())
            ZO_Tooltip_AddDivider(InformationTooltip)
            InformationTooltip:AddLine(ar, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        end,
        tooltip = 1
    }
    ZO_WorldMap_AddCustomPin(bw, bE, bF, pinLayoutData, bG)
    ZO_WorldMap_SetCustomPinEnabled(_G[bw], true)
    ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
end
local function bJ(bK, bL, bM, b6)
    local bB = GetMapName()
    local b5 = TQG.trackedDLCPrologueQuestId;
    if bx[b5] == nil or bx[b5][bB] == nil then return end
    local bC = bx[b5][bB]
    for _, bD in ipairs(bC) do
        if bM == GetQuestName(bD.questId) then
            ZO_WorldMap_SetCustomPinEnabled(_G[bw], false)
            ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
            EVENT_MANAGER:UnregisterForEvent("TheQuestingGuide",
                                             EVENT_QUEST_ADDED)
            break
        end
    end
end
function TQG.DLC:PlayStory_OnClick()
    local F, X;
    local aI, aJ;
    local bN;
    local bO;
    F, X = bt()
    if F < 1 then return end
    aI, aJ = bu(F, X)
    bN, bO, objectiveIndex = bv(F, X)
    if TQG.ZoneLevelDLC[F][X].SideQuestCheck and aI and aJ then
        ZO_Dialogs_ShowDialog("TQG_CONFIRM_CONTINUE_CLASSIC_ZONE_STORY")
    elseif bN and objectiveIndex then
        local b5 = TQG.ObjectiveLevelDLC[F][X][objectiveIndex].internalId;
        local bw = bw;
        local bP = TQG.ObjectiveLevelDLC[F][X][objectiveIndex].mapIndex;
        local bB = GetMapNameByIndex(bP)
        TQG.trackedDLCPrologueQuestId = b5;
        if bO then
            for h = 1, GetNumJournalQuests() do
                local bM;
                if TQG.ObjectiveLevelDLC[F][X][objectiveIndex].overrideQName then
                    bM = TQG.ObjectiveLevelDLC[F][X][objectiveIndex]
                             .overrideQName
                else
                    bM = GetQuestName(b5)
                end
                if GetJournalQuestName(h) == bM then
                    local bQ = h;
                    ZO_WorldMap_ShowQuestOnMap(bQ)
                    return
                end
            end
        end
        if bx[b5] == nil then return end
        if bx[b5][bB] == nil then return end
        local bC = bx[b5][bB]
        local bR, bS;
        for _, bD in ipairs(bC) do
            if bD.questId == b5 then
                bR = bD[1]
                bS = bD[2]
                break
            end
        end
        ZO_WorldMap_SetCustomPinEnabled(_G[bw], true)
        ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
        ZO_WorldMap_ShowWorldMap()
        zo_callLater(function() ZO_WorldMap_SetMapByIndex(bP) end, 1000)
        zo_callLater(function()
            ZO_WorldMap_PanToNormalizedPosition(bR, bS)
        end, 1750)
        EVENT_MANAGER:RegisterForEvent("TheQuestingGuide", EVENT_QUEST_ADDED, bJ)
    else
        TQG:TrackNextActivity(TQG.selectedDLCZoneId)
        ZONE_STORIES_KEYBOARD:BuildZonesList()
        self:UpdateStoryButtons()
    end
end
function TQG.DLC:StopTracking_OnClick()
    ClearTrackedZoneStory()
    ZONE_STORIES_KEYBOARD:BuildZonesList()
    self:UpdateStoryButtons()
end
function TQG.DLC:OnQuestAcceptClicked(self)
    d(DLC_BOOK_KEYBOARD.navigationTree:GetSelectedData())
end
function TQG.DLC:UpdateStoryButtons(P)
    local bT = false;
    if P then
        for h = 1, #TQG.TopLevelDLC do
            for aE = 1, #TQG.ZoneLevelDLC[h] do
                if TQG.ZoneLevelDLC[h][aE].name == P.name then
                    TQG.selectedDLCZoneId = TQG.ZoneLevelDLC[h][aE].id;
                    bT = TQG.ZoneLevelDLC[h][aE].isDungeonDLC;
                    break
                end
            end
        end
    end
    local aM = TQG.selectedDLCZoneId;
    local aW;
    local aX;
    if type(aM) == "string" then
        aW = false;
        aX = false
    else
        aW = ZO_ZoneStories_Manager.GetZoneAvailability(aM)
        aX = CanZoneStoryContinueTrackingActivities(aM)
    end
    TQG.DLC.playStoryButton:SetEnabled(aW and aX)
    TQG.DLC.playStoryButton:SetText(TQG:GetPlayStoryButtonText(aM))
    TQG.DLC.playStoryButton:SetHidden(bT)
    local aY = GetTrackedZoneStoryActivityInfo()
    TQG.DLC.stopTrackingButton:SetHidden(aY ~= aM)
    local bU;
    local bV;
    local bW;
    if type(aM) == "number" then
        bU = GetCollectibleIdForZone(GetZoneIndex(aM))
        bV = not IsCollectibleUnlocked(bU)
        bW = IsCollectibleActive(bU)
    else
        bU = 0;
        bV = true;
        bW = false
    end
    TQG.DLC.dungeonQuestAcceptButton:SetHidden(true)
    local bX = bW and SI_DLC_BOOK_ACTION_QUEST_ACCEPTED or
                   SI_DLC_BOOK_ACTION_ACCEPT_QUEST;
    TQG.DLC.dungeonQuestAcceptButton:SetText(GetString(bX))
    TQG.DLC.dungeonQuestAcceptButton:SetEnabled(not (bV or bW))
end
function TQG.DLC:StoryButtonHooks(aZ)
    local a_ = GetControl(aZ)
    local b0 = a_:GetNamedChild("ButtonContainer")
    TQG.DLC.playStoryButton = b0:GetNamedChild("PlayStoryButton")
    TQG.DLC.playStoryButton:SetClickSound(SOUNDS.ZONE_STORIES_TRACK_ACTIVITY)
    TQG.DLC.stopTrackingButton = b0:GetNamedChild("StopTrackingButton")
    TQG.DLC.dungeonQuestAcceptButton = b0:GetNamedChild("QuestAccept")
end
function TQG.DLC:Initialize(j)
    local bY = TQG.sceneNameQuestGuideDLC;
    TQG_DLC_ALMANAC_FRAGMENT = ZO_HUDFadeSceneFragment:New(TQG_TabDLC)
    TQG_SCENE_DLC = ZO_Scene:New(bY, SCENE_MANAGER)
    TQG_SCENE_DLC:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    TQG_SCENE_DLC:AddFragmentGroup(
        FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    TQG_SCENE_DLC:AddFragmentGroup(
        FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    TQG_SCENE_DLC:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    TQG_SCENE_DLC:AddFragment(TQG.BACKGROUND_FRAGMENT)
    TQG_SCENE_DLC:AddFragment(TREE_UNDERLAY_FRAGMENT)
    TQG_SCENE_DLC:AddFragment(TITLE_FRAGMENT)
    TQG_SCENE_DLC:AddFragment(ZO_SetTitleFragment:New(TQG_MENU_JOURNAL))
    TQG_SCENE_DLC:AddFragment(CODEX_WINDOW_SOUNDS)
    TQG_SCENE_DLC:AddFragment(TQG_DLC_ALMANAC_FRAGMENT)
    SYSTEMS:RegisterKeyboardRootScene(bY, TQG_SCENE_DLC)
    TQG_SCENE_DLC:RegisterCallback("StateChange", function(l, m)
        if m == SCENE_SHOWING then
            TQG.MenuState = 3;
            TQG.MenuHidden = false;
            TQGButtonsButton1.m_object:SetState(0)
            TQGButtonsButton1.m_object:SetLocked(false)
            TQGButtonsButton2.m_object:SetState(0)
            TQGButtonsButton2.m_object:SetLocked(false)
            TQGButtonsButton4.m_object:SetState(0)
            TQGButtonsButton4.m_object:SetLocked(false)
        elseif m == SCENE_HIDING then
            TQG.MenuHidden = true
        end
    end)
    TQG.DLC:StoryButtonHooks("TQG_TabDLC")
end
function TQG.DLC:New(j)
    TQG.DLC:Initialize(j)
    local n = ZO_Object.New(self)
    n.control = j;
    n.zoneInfoContainer = j:GetNamedChild("ZoneInfoContainer")
    n.zoneStepContainer = j:GetNamedChild("ZoneStepContainer")
    n.titleText = j:GetNamedChild("TitleText")
    n.descriptionText = j:GetNamedChild("DescriptionText")
    n.objectivesText = j:GetNamedChild("ObjectivesText")
    n.objectiveLinePool = ZO_ControlPool:New("TQG_TabDLC_ObjectiveLine", j,
                                             "Objective")
    n.currentProgressionLevel = #TQG.TopLevelDLC;
    n:InitializeCategoryList(j)
    n:RefreshList()
    local function b2() n:RefreshList() end
    local function bZ(bK, b_, bL, bM, aa, b7, b5) n:RefreshList() end
    local function C() n:RefreshList() end
    j:RegisterForEvent(EVENT_QUEST_ADDED, b2)
    j:RegisterForEvent(EVENT_QUEST_REMOVED, bZ)
    j:RegisterForEvent(EVENT_QUEST_COMPLETE, C)
    return n
end
function TQG.DLC:InitializeCategoryList(j)
    self.navigationTree = ZO_Tree:New(j:GetNamedChild(
                                          "NavigationContainerScrollChild"), 60,
                                      -10, 300)
    local D = {
        [1] = {
            "/esoui/art/treeicons/store_indexicon_dlc_down.dds",
            "/esoui/art/treeicons/store_indexicon_dlc_up.dds",
            "/esoui/art/treeicons/store_indexicon_dlc_over.dds"
        },
        [2] = {
            "/esoui/art/icons/progression_tabicon_daedricconjuration_down.dds",
            "/esoui/art/icons/progression_tabicon_daedricconjuration_up.dds",
            "/esoui/art/icons/progression_tabicon_daedricconjuration_over.dds"
        },
        [3] = {
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_over.dds"
        },
        [4] = {
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_over.dds"
        },
        [5] = {
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_down.dds",
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds",
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_over.dds"
        },
        [6] = {
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_over.dds"
        },
        [7] = {
            "/esoui/art/charactercreate/charactercreate_bretonicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_bretonicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_bretonicon_over.dds"
        },
        [8] = {
            "/esoui/art/charactercreate/charactercreate_arcanisticon_down.dds",
            "/esoui/art/charactercreate//charactercreate_arcanisticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_arcanisticon_over.dds"
        },
        [9] = {
            "/esoui/art/charactercreate/charactercreate_arcanisticon_down.dds",
            "/esoui/art/charactercreate/charactercreate_arcanisticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_arcanisticon_over.dds"
        },
        [10] = {
            "/esoui/art/help/u46_helpcategory_update46_down.dds",
            "/esoui/art/help/u46_helpcategory_update46_up.dds",
            "/esoui/art/help/u46_helpcategory_update46_over.dds"
        }
    }
    local function E(F) if D[F] then return unpack(D[F]) end end
    local function K(H, j, F, I)
        j.progressionLevel = F;
        j.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        j.text:SetText(TQG.TopLevelDLC[F])
        local L, M, N = E(F)
        j.icon:SetTexture(I and L or M)
        j.iconHighlight:SetTexture(N)
        ZO_IconHeader_Setup(j, I)
    end
    self.navigationTree:AddTemplate("ZO_IconHeader", K, nil, nil, nil, 0)
    local function O(H, j, P, I)
        j:SetText(zo_strformat(SI_CADWELL_QUEST_NAME_FORMAT, P.name))
        GetControl(j, "CompletedIcon"):SetHidden(not P.completed)
        j:SetSelected(false)
    end
    local function Q(j, P, R, S)
        j:SetSelected(R)
        if R and not S then
            TQG.DLC:UpdateStoryButtons(P)
            self:RefreshDetails()
        end
    end
    local function T(U, V) return U.name == V.name end
    self.navigationTree:AddTemplate("ZO_CadwellNavigationEntry", O, Q, T)
    self.navigationTree:SetExclusive(true)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end
local function W(F, X)
    local a4 = TQG.ZoneLevelDLC[F][X].name;
    local b3 = TQG.ZoneLevelDLC[F][X].id;
    local Z = ""
    if type(a4) == "number" or a4 == "" then
        a4 = TQG.ZoneLevelDLC[F][X].name;
        a4 = "(" .. string.format("%.2f", a4) .. ")"
        local b4 = GetCVar("language.2")
        if b4 == "de" or b4 == "fr" or b4 == "ru" then
            a4 = string.gsub(a4, "%.", ",", 1)
        end
        local Y = GetZoneNameById(b3)
        TQG.ZoneLevelDLC[F][X].name = a4 .. " " .. Y
    end
    local Y = TQG.ZoneLevelDLC[F][X].name;
    if type(b3) == "string" then
        Z = b3
    else
        Z = GetZoneDescriptionById(b3)
    end
    local a0 = X;
    return b3, Y, Z, a0
end
function TQG.DLC:b7(F, X, objectiveIndex, aG)
    local b4 = GetCVar("language.2")
    if b4 ~= "de" and b4 ~= "fr" and b4 ~= "ru" then b4 = "en" end
    local a3 = false;
    local ag = objectiveIndex;
    local a4, a5, a6, a2;
    local b5, b6, b7, b8;
    local aM = TQG.ZoneLevelDLC[F][X].id;
    local c0 = false;
    if TQG.ObjectiveLevelDLC[F][X][objectiveIndex].overrideDetails then
        local overrideName = TQG.ObjectiveLevelDLC[F][X][objectiveIndex]
                                 .overrideQName or nil;
        b5 = TQG.ObjectiveLevelDLC[F][X][objectiveIndex].internalId;
        a4 = GetQuestName(b5)
        if overrideName then a4 = overrideName end
    else
        local bd = TQG.ObjectiveLevelDLC[F][X][1].prologueQIds;
        if bd and objectiveIndex >= bd then
            ag = ag + bd - 1;
            objectiveIndex = objectiveIndex - (bd - 1)
        end
        a4 = GetZoneStoryActivityNameByActivityIndex(aM,
                                                     ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
                                                     objectiveIndex)
        b5 = GetZoneActivityIdForZoneCompletionType(aM,
                                                    ZONE_COMPLETION_TYPE_PRIORITY_QUESTS,
                                                    objectiveIndex)
        objectiveIndex = ag
    end
    if not b5 then
        for h, c1 in ipairs(TQG.MultiQuestIds[2]) do
            local bf = GetCompletedQuestInfo(c1) or ""
            if bf == a4 then
                local b3 = 5602;
                b5 = b3;
                b8 = TQG.ObjectiveLevelDLC[F][X][objectiveIndex]
                         .overrideDescription;
                _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b3)
                if b6 == "" then b6 = nil end
                c0 = true;
                break
            end
        end
    end
    if not b5 then
        for h, bh in pairs(LibUespQuestData.quests) do
            local b3 = tonumber(bh.internalId)
            local bf = ""
            bf = GetCompletedQuestInfo(b3)
            if bf == "" or bf == nil then
                bf = GetCompletedQuestInfo(b3) or ""
            end
            if GetQuestName(b3) == a4 and not overrideName then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b3)
                _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b3)
                if b6 == "" then b6 = nil end
                break
            elseif bf == a4 then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b3)
                local b6 = ""
                _, b6 = LibUespQuestData:GetUespQuestLocationInfo(b3)
                if b6 == "" then b6 = nil end
                break
            end
        end
    elseif not c0 then
        b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
        _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b5)
        if b6 == "" then b6 = nil end
    end
    if type(aM) == "number" then
        a5 = b6 or GetZoneNameById(aM)
    else
        a5 = b6
    end
    if GetCompletedQuestInfo(b5) == "" and not c0 then
        a3 = false;
        for h = 1, GetNumJournalQuests() do
            if GetJournalQuestName(h) == a4 then
                a2 = true;
                _, a5 = GetJournalQuestInfo(h)
                break
            else
                a2 = false
            end
        end
        a6 = ""
    else
        a3 = true;
        a2 = true;
        a5 = ""
        a6 = b8
    end
    local function bi(bj, bk)
        if a4 == GetQuestName(bk) then
            bj = string.gsub(bj, " u2026.", "...")
        else
            bj = string.gsub(bj, " u2026", "...")
        end
        return bj
    end
    if b8 ~= "" and b8 then
        if a6 == b8 then
            a6 = bi(a6, 4296)
            a6 = bi(a6, -1)
            a6 = string.gsub(a6, "u2014", "—")
        elseif a5 == b8 then
            a5 = bi(a5, 4296)
            a5 = bi(a5, -1)
            a5 = string.gsub(a5, "u2014", "—")
        end
    end
    local bl = TQG.ObjectiveLevelDLC[F][X][objectiveIndex].overrideZone;
    if a5 == nil or a5 == "" or bl then
        a5 = bl;
        if a5 == nil or a5 == "" then
            a5 = GetString(TQG_DEFAULT_QUEST_INCOMPLETE)
        end
    end
    if a6 == nil or a6 == "" then a6 = GetString(TQG_DEFAULT_QUEST_COMPLETE) end
    local bm = TQG.ObjectiveLevelDLC[F][X][objectiveIndex].optional or false;
    return a4, a5, a6, ag, a2, a3, bm
end
function TQG.DLC:RefreshList()
    if self.control:IsHidden() then
        self.dirty = true;
        return
    end
    self.navigationTree:Reset()
    local a7 = {}
    for F = 1, #TQG.TopLevelDLC do
        local a8 = #TQG.ZoneLevelDLC[F]
        if self.currentProgressionLevel < F then break end
        if a8 > 0 then
            local a9 = self.navigationTree:AddNode("ZO_IconHeader", F)
            for aa = 1, a8 do
                local aM, Y, Z, a0 = W(F, aa)
                local bn = 0;
                local ab = true;
                local ac = {}
                local aG, aH, bo, bp;
                if type(aM) == "number" then
                    aG, aH, bo, bp =
                        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
                            aM, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
                elseif type(aM) == "string" then
                    aG, aH, bo, bp = 0, 0, 0, 0
                end
                local ad = bo;
                local bq = false;
                if bp > 0 then
                    ad = ad + 1;
                    bq = true
                end
                if ad == 0 then
                    ad = #TQG.ObjectiveLevelDLC[F][aa]
                end
                local br = 1;
                if ad ~= #TQG.ObjectiveLevelDLC[F][aa] then
                    if TQG.ObjectiveLevelDLC[F][aa][0] then
                        br = 0;
                        local bd = TQG.ObjectiveLevelDLC[F][aa][0].prologueQIds;
                        if bd and bd > 1 then
                            ad = ad + bd - 1
                        end
                    elseif TQG.ObjectiveLevelDLC[F][aa][ad + 1].overrideDetails then
                        ad = ad + #TQG.ObjectiveLevelDLC[F][aa] - ad
                    end
                end
                for objectiveIndex = br, ad do
                    local a4, ae, af, ag, ah, ai, bs;
                    if objectiveIndex == ad and bq == true then
                        a4 = "TBC"
                        ae, af = GetErrorString(bp)
                        ag = objectiveIndex;
                        ah = false;
                        ai = false;
                        bs = false
                    else
                        a4, ae, af, ag, ah, ai, bs = TQG.DLC:b7(F, aa,
                                                                objectiveIndex,
                                                                aG)
                        ab = ab and (ai or bs)
                        if ai then bn = bn + 1 end
                    end
                    table.insert(ac, {
                        name = a4,
                        openingText = ae,
                        closingText = af,
                        order = ag,
                        discovered = ah,
                        completed = ai
                    })
                end
                table.sort(ac, ZO_CadwellSort)
                table.insert(a7, {
                    name = Y,
                    description = Z,
                    order = a0,
                    completed = ab and bn >= 1,
                    objectives = ac,
                    parent = a9
                })
            end
        end
    end
    table.sort(a7, ZO_CadwellSort)
    for h = 1, #a7 do
        local aj = a7[h]
        local a9 = aj.parent;
        self.navigationTree:AddNode("ZO_CadwellNavigationEntry", aj, a9)
    end
    self.navigationTree:Commit()
    self:RefreshDetails()
end
function TQG.DLC:RefreshDetails()
    local self = TQG_ALMANAC_DLC;
    self.objectiveLinePool:ReleaseAllObjects()
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then
        self.zoneInfoContainer:SetHidden(true)
        self.zoneStepContainer:SetHidden(true)
        return
    else
        self.zoneInfoContainer:SetHidden(false)
        self.zoneStepContainer:SetHidden(false)
    end
    self.titleText:SetText(zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, ak.name))
    self.descriptionText:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT,
                                              ak.description))
    local al;
    for h = 1, #ak.objectives do
        local am = ak.objectives[h]
        local an = self.objectiveLinePool:AcquireObject()
        if am.name == "TBC" then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(am.openingText)
        elseif am.discovered and not am.completed then
            an:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        elseif not am.discovered then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        else
            an:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(false)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.closingText))
        end
        if not al then
            an:SetAnchor(TOPLEFT, self.objectivesText, BOTTOMLEFT, 25, 15)
        else
            an:SetAnchor(TOPLEFT, al, BOTTOMLEFT, 0, 15)
        end
        al = an
    end
end
function TQG.DLC:OnShown()
    if self.dirty then
        self:RefreshList()
        self.dirty = false
    end
end
function TQG_TabDLC_OnShown() TQG_ALMANAC_DLC:OnShown() end
function TQG_TabDLC_Initialize(j) TQG_ALMANAC_DLC = TQG.DLC:New(j) end
if not TQG then TQG = {} end
TQG.Group = ZO_Object:Subclass()
TQG.sceneNameQuestGuideGroup = "QuestGuideGroup"
TQG.selectedGroupZoneId = nil;
TQG.trackedGroupQuestId = nil;
TQG.trackedGroupObjectiveIndex = nil;
function TQG.ButtonSetup(j)
    local at = "Click_MenuBar"
    local c2 = {
        categoryName = TQG.OverviewTabName,
        descriptor = "The Questing Guide: Overview",
        normal = "esoui/art/progression/progression_indexicon_world_up.dds",
        pressed = "esoui/art/progression/progression_indexicon_world_down.dds",
        highlight = "esoui/art/progression/progression_indexicon_world_over.dds",
        callback = function(c3)
            PlaySound(at)
            SCENE_MANAGER:Show(TQG.sceneNameQuestGuideOverview)
        end
    }
    local c4 = {
        categoryName = TQG.ClassicTabName,
        descriptor = "The Questing Guide: Classic",
        normal = "esoui/art/campaign/campaignbrowser_indexicon_specialevents_up.dds",
        pressed = "esoui/art/campaign/campaignbrowser_indexicon_specialevents_down.dds",
        highlight = "esoui/art/campaign/campaignbrowser_indexicon_specialevents_over.dds",
        callback = function(c3)
            PlaySound(at)
            SCENE_MANAGER:Show(TQG.sceneNameQuestGuideClassic)
        end
    }
    local c5 = {
        categoryName = TQG.DLCTabName,
        descriptor = "The Questing Guide: DLC",
        normal = "esoui/art/treeicons/store_indexicon_dlc_up.dds",
        pressed = "esoui/art/treeicons/store_indexicon_dlc_down.dds",
        highlight = "esoui/art/treeicons/store_indexicon_dlc_over.dds",
        callback = function(c3)
            PlaySound(at)
            SCENE_MANAGER:Show(TQG.sceneNameQuestGuideDLC)
        end
    }
    local c6 = {
        categoryName = TQG.GroupTabName,
        descriptor = "The Questing Guide: Group",
        normal = "esoui/art/icons/achievements_indexicon_dungeons_up.dds",
        pressed = "esoui/art/icons/achievements_indexicon_dungeons_down.dds",
        highlight = "esoui/art/icons/achievements_indexicon_dungeons_over.dds",
        callback = function(c3)
            PlaySound(at)
            SCENE_MANAGER:Show(TQG.sceneNameQuestGuideGroup)
        end
    }
    local c7 = CreateControlFromVirtual("TQGButtons", TQG_SharedRightBackground,
                                        "ZO_LabelButtonBar")
    c7:SetAnchor(TOPRIGHT, TQG_SharedRightBackground, TOPRIGHT, -450, 1)
    local c8 = {
        buttonPadding = 16,
        normalSize = 51,
        downSize = 64,
        animationDuration = DEFAULT_SCENE_TRANSITION_TIME,
        buttonTemplate = "ZO_MenuBarTooltipButton"
    }
    ZO_MenuBar_SetData(c7, c8)
    local c9 = ZO_MenuBar_AddButton(c7, c2)
    local ca = ZO_MenuBar_AddButton(c7, c4)
    local cb = ZO_MenuBar_AddButton(c7, c5)
    local cc = ZO_MenuBar_AddButton(c7, c6)
end
local function cd()
    local F = 0;
    local X = 0;
    local aE = 1;
    for h = 1, #TQG.ZoneLevelGroup do
        while aE <= #TQG.ZoneLevelGroup[h] do
            if TQG.ZoneLevelGroup[h][aE].id == TQG.selectedGroupZoneId then
                F = h;
                X = aE;
                break
            end
            aE = aE + 1
        end
        if F > 0 then
            break
        else
            aE = 1
        end
    end
    return F, X
end
local function ce(F, X)
    local aG, aH;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedGroupZoneId, ZONE_COMPLETION_TYPE_POINTS_OF_INTEREST)
    local aI = aH - aG > 0;
    aG, aH, _, _ =
        ZO_ZoneStories_Manager.GetActivityCompletionProgressValuesAndText(
            TQG.selectedGroupZoneId, ZONE_COMPLETION_TYPE_PRIORITY_QUESTS)
    local aJ = aH - aG == TQG.ZoneLevelGroup[F][X].PreEndSideQuestCheck;
    return false, false
end
local function cf(F, X)
    local self = TQG_ALMANAC_GROUP;
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then return end
    local cg = #TQG.ObjectiveLevelGroup[F][X]
    if not cg then return false, false end
    for h = 1, cg do
        if ak.objectives[h].discovered == false then
            return true, false
        elseif ak.objectives[h].completed == false then
            return true, true
        end
    end
    return false, false
end
local b4 = GetCVar("language.2")
if b4 ~= "de" and b4 ~= "fr" then b4 = "en" end
local bw = "TQG_QuestsGroup"
local bx = {
    [4107] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
            {
                0.3161,
                0.1054,
                0.012,
                questId = 4107,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4107],
                allianceId = 1
            }
        }
    },
    [4597] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(381))] = {
            {
                0.3161,
                0.1054,
                0.012,
                questId = 4597,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4597],
                allianceId = 1
            }
        }
    },
    [4336] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(383))] = {
            {
                0.5268,
                0.4841,
                0.012,
                questId = 4336,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4336],
                allianceId = 1
            }
        }
    },
    [4675] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(383))] = {
            {
                0.5268,
                0.4841,
                0.012,
                questId = 4675,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4675],
                allianceId = 1
            }
        }
    },
    [4778] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(108))] = {
            {
                0.6585,
                0.3000,
                0.012,
                questId = 4778,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4778],
                allianceId = 1
            }
        }
    },
    [5120] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(108))] = {
            {
                0.6585,
                0.3000,
                0.012,
                questId = 5120,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5120],
                allianceId = 1
            }
        }
    },
    [4538] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(58))] = {
            {
                0.7142,
                0.3371,
                0.012,
                questId = 4538,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4538],
                allianceId = 1
            }
        }
    },
    [4733] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(382))] = {
            {
                0.2063,
                0.7974,
                0.012,
                questId = 4733,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4733],
                allianceId = 1
            }
        }
    },
    [4054] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
            {
                0.7146,
                0.3372,
                0.012,
                questId = 4054,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4054],
                allianceId = 1
            }
        }
    },
    [4555] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(3))] = {
            {
                0.7146,
                0.3372,
                0.012,
                questId = 4555,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4555],
                allianceId = 1
            }
        }
    },
    [4246] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(19))] = {
            {
                0.5620,
                0.5772,
                0.012,
                questId = 4246,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4246],
                allianceId = 1
            }
        }
    },
    [4813] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(19))] = {
            {
                0.5620,
                0.5772,
                0.012,
                questId = 4813,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4813],
                allianceId = 1
            }
        }
    },
    [4379] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(20))] = {
            {
                0.7222,
                0.7363,
                0.012,
                questId = 4379,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4379],
                allianceId = 1
            }
        }
    },
    [5113] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(20))] = {
            {
                0.7222,
                0.7363,
                0.012,
                questId = 5113,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5113],
                allianceId = 1
            }
        }
    },
    [4432] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(104))] = {
            {
                0.8733,
                0.4636,
                0.012,
                questId = 4432,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4432],
                allianceId = 1
            }
        }
    },
    [4589] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(92))] = {
            {
                0.3718,
                0.2773,
                0.012,
                questId = 4589,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4589],
                allianceId = 1
            }
        }
    },
    [3993] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
            {
                0.0960,
                0.4483,
                0.012,
                questId = 3993,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[3993],
                allianceId = 1
            }
        }
    },
    [4303] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(41))] = {
            {
                0.0960,
                0.4483,
                0.012,
                questId = 4303,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4303],
                allianceId = 1
            }
        }
    },
    [4145] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(57))] = {
            {
                0.7906,
                0.5859,
                0.012,
                questId = 4145,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4145],
                allianceId = 1
            }
        }
    },
    [4641] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(57))] = {
            {
                0.7906,
                0.5859,
                0.012,
                questId = 4641,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4641],
                allianceId = 1
            }
        }
    },
    [4202] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(117))] = {
            {
                0.1663,
                0.5852,
                0.012,
                questId = 4202,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4202],
                allianceId = 1
            }
        }
    },
    [4346] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(101))] = {
            {
                0.7367,
                0.7031,
                0.012,
                questId = 4346,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4346],
                allianceId = 1
            }
        }
    },
    [4469] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(103))] = {
            {
                0.8909,
                0.6468,
                0.012,
                questId = 4469,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4469],
                allianceId = 1
            }
        }
    },
    [4822] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(347))] = {
            {
                0.5793,
                0.4849,
                0.012,
                questId = 4822,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[4822],
                allianceId = 1
            }
        }
    },
    [5102] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(888))] = {
            {
                0.8759,
                0.6057,
                0.012,
                questId = 5102,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5102],
                allianceId = 1
            }
        }
    },
    [5087] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(888))] = {
            {
                0.2375,
                0.6214,
                0.012,
                questId = 5087,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5087],
                allianceId = 1
            }
        }
    },
    [5743] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(888))] = {
            {
                0.3859,
                0.2602,
                0.012,
                questId = 5743,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5743],
                allianceId = 1
            }
        }
    },
    [5136] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(181))] = {
            {
                0.4979,
                0.3912,
                0.012,
                questId = 5136,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5136],
                allianceId = 1
            }
        }
    },
    [5342] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(181))] = {
            {
                0.4979,
                0.3912,
                0.012,
                questId = 5342,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5342],
                allianceId = 1
            }
        }
    },
    [5448] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(684))] = {
            {
                0.9305,
                0.3627,
                0.012,
                questId = 5448,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5448],
                allianceId = 1
            }
        }
    },
    [5554] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(816))] = {
            {
                0.6170,
                0.4737,
                0.012,
                questId = 5554,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5554],
                allianceId = 1
            }
        }
    },
    [5352] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(382))] = {
            {
                0.2259,
                0.7442,
                0.012,
                questId = 5352,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5352],
                allianceId = 1
            }
        }
    },
    [6000] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(849))] = {
            {
                0.4833,
                0.9006,
                0.012,
                questId = 6000,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6000],
                allianceId = 1
            }
        }
    },
    [5894] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(849))] = {
            {
                0.7686,
                0.5844,
                0.012,
                questId = 5894,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5894],
                allianceId = 1
            }
        }
    },
    [6090] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(980))] = {
            {
                0.3634,
                0.3471,
                0.012,
                questId = 6090,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6090],
                allianceId = 1
            }
        }
    },
    [6193] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1011))] = {
            {
                0.2729,
                0.6150,
                0.012,
                questId = 6193,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6193],
                allianceId = 1
            }
        }
    },
    [6192] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1011))] = {
            {
                0.4228,
                0.3593,
                0.012,
                questId = 6192,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6192],
                allianceId = 1
            }
        }
    },
    [6269] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(726))] = {
            {
                0.3092,
                0.5398,
                0.012,
                questId = 6269,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6269],
                allianceId = 1
            }
        }
    },
    [6354] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1086))] = {
            {
                0.7781,
                0.3152,
                0.012,
                questId = 6354,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6354],
                allianceId = 1
            }
        }
    },
    [6353] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1086))] = {
            {
                0.3426,
                0.7417,
                0.012,
                questId = 6353,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6353],
                allianceId = 1
            }
        }
    },
    [6504] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1160))] = {
            {
                0.5375,
                0.4224,
                0.012,
                questId = 6504,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6504],
                allianceId = 1
            }
        }
    },
    [6503] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1160))] = {
            {
                0.4303,
                0.2448,
                0.012,
                questId = 6503,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6503],
                allianceId = 1
            }
        }
    },
    [6597] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1207))] = {
            {
                0.3118,
                0.5128,
                0.012,
                questId = 6597,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6597],
                allianceId = 1
            }
        }
    },
    [6610] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1207))] = {
            {
                0.4730,
                0.7487,
                0.012,
                questId = 6610,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6610],
                allianceId = 1
            }
        }
    },
    [6655] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1261))] = {
            {
                0.28188,
                0.53917,
                0.012,
                questId = 6655,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6655],
                allianceId = 1
            }
        }
    },
    [6654] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1261))] = {
            {
                0.75500,
                0.92706,
                0.012,
                questId = 6654,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6654],
                allianceId = 1
            }
        }
    },
    [6784] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1318))] = {
            {
                0.48328,
                0.88854,
                0.012,
                questId = 6784,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6784],
                allianceId = 1
            }
        }
    },
    [6783] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1318))] = {
            {
                0.19378,
                0.37612,
                0.012,
                questId = 6783,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6783],
                allianceId = 1
            }
        }
    },
    [7032] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1414))] = {
            {
                0.78294,
                0.34610,
                0.012,
                questId = 7032,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[7032],
                allianceId = 1
            }
        }
    },
    [7031] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(1414))] = {
            {
                0.38972,
                0.83360,
                0.012,
                questId = 7031,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[7031],
                allianceId = 1
            }
        }
    },
    [5403] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(117))] = {
            {
                0.21648,
                0.23329,
                0.012,
                questId = 5403,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5403],
                allianceId = 1
            }
        }
    },
    [5702] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(117))] = {
            {
                0.28198,
                0.38172,
                0.012,
                questId = 5702,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5702],
                allianceId = 1
            }
        }
    },
    [5891] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(888))] = {
            {
                0.89980,
                0.65183,
                0.012,
                questId = 5891,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5891],
                allianceId = 1
            }
        }
    },
    [5889] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(888))] = {
            {
                0.70413,
                0.69973,
                0.012,
                questId = 5889,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[5889],
                allianceId = 1
            }
        }
    },
    [6065] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(19))] = {
            {
                0.67209,
                0.35404,
                0.012,
                questId = 6065,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6065],
                allianceId = 1
            }
        }
    },
    [6064] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(92))] = {
            {
                0.71808,
                0.17719,
                0.012,
                questId = 6064,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6064],
                allianceId = 1
            }
        }
    },
    [6186] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(382))] = {
            {
                0.47209,
                0.66281,
                0.012,
                questId = 6186,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6186],
                allianceId = 1
            }
        }
    },
    [6188] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(108))] = {
            {
                0.24661,
                0.54223,
                0.012,
                questId = 6188,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[6188],
                allianceId = 1
            }
        }
    },
    [0] = {
        [GetMapNameByIndex(GetMapIndexByZoneId(0))] = {
            {
                0.0000,
                0.0000,
                0.012,
                questId = 0,
                heading = "",
                text = TQG.GroupQuestIdToTooltip[0],
                allianceId = 1
            }
        }
    }
}
function TQG.Group:SetupPins()
    local function bz(bA)
        local bB = GetMapName()
        local b5 = TQG.trackedGroupQuestId;
        if bx[b5] == nil then return end
        if bx[b5][bB] == nil then return end
        local bC = bx[b5][bB]
        for _, bD in ipairs(bC) do bA:CreatePin(_G[bw], bD, bD[1], bD[2]) end
    end
    local bE = bz;
    local bF = nil;
    pinLayoutData = {
        showsPinAndArea = true,
        level = 10,
        minSize = 100,
        texture = "EsoUI/Art/MapPins/MapAutoNavigationPing.dds",
        isAnimated = true,
        framesWide = 32,
        framesHigh = 1,
        framesPerSecond = 32
    }
    local bG = {
        creator = function(bH)
            local bI, ar;
            local bB = GetMapName()
            local b5 = TQG.trackedGroupQuestId;
            if bx[b5] == nil then return end
            if bx[b5][bB] == nil then return end
            local bC = bx[b5][bB]
            for _, bD in ipairs(bC) do
                if bD[4] == bH.m_PinTag[4] then
                    bI = GetQuestName(bD.questId)
                    ar = zo_strformat("<<1>>", bD.text)
                    break
                end
            end
            InformationTooltip:AddLine(bI, "ZoFontGameOutline",
                                       ZO_SELECTED_TEXT:UnpackRGB())
            ZO_Tooltip_AddDivider(InformationTooltip)
            InformationTooltip:AddLine(ar, "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
        end,
        tooltip = 1
    }
    ZO_WorldMap_AddCustomPin(bw, bE, bF, pinLayoutData, bG)
    ZO_WorldMap_SetCustomPinEnabled(_G[bw], true)
    ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
end
local function bJ(bK, bL, bM, b6)
    local bB = GetMapName()
    local b5 = TQG.trackedGroupQuestId;
    if bx[b5][bB] == nil then return end
    local bC = bx[b5][bB]
    for _, bD in ipairs(bC) do
        if bM == GetQuestName(bD.questId) then
            ZO_WorldMap_SetCustomPinEnabled(_G[bw], false)
            ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
            EVENT_MANAGER:UnregisterForEvent("TheQuestingGuide",
                                             EVENT_QUEST_ADDED)
            break
        end
    end
end
function TQG.Group:PlayStory_OnClick()
    local F, X, objectiveIndex;
    F, X = cd()
    objectiveIndex = TQG.trackedGroupObjectiveIndex;
    if F < 1 then return end
    questForGroupIncomplete, questForGroupInProgress = cf(F, X)
    if objectiveIndex then
        local b5 = TQG.ObjectiveLevelGroup[F][X][objectiveIndex].internalId;
        local bw = bw;
        local bP = TQG.ObjectiveLevelGroup[F][X][objectiveIndex].mapIndex;
        local bB = GetMapNameByIndex(bP)
        TQG.trackedGroupQuestId = b5;
        if questForGroupInProgress then
            for h = 1, GetNumJournalQuests() do
                if GetJournalQuestName(h) == GetQuestName(b5) then
                    local bQ = h;
                    ZO_WorldMap_ShowQuestOnMap(bQ)
                    return
                end
            end
        end
        if bx[b5][bB] == nil then return end
        local bC = bx[b5][bB]
        local bR, bS;
        for _, bD in ipairs(bC) do
            if bD.questId == b5 then
                bR = bD[1]
                bS = bD[2]
                break
            end
        end
        ZO_WorldMap_SetCustomPinEnabled(_G[bw], true)
        ZO_WorldMap_RefreshCustomPinsOfType(_G[bw])
        ZO_WorldMap_ShowWorldMap()
        zo_callLater(function() ZO_WorldMap_SetMapByIndex(bP) end, 1000)
        zo_callLater(function()
            ZO_WorldMap_PanToNormalizedPosition(bR, bS)
        end, 1750)
        EVENT_MANAGER:RegisterForEvent("TheQuestingGuide", EVENT_QUEST_ADDED, bJ)
    end
end
function TQG.Group:UpdateStoryButtons(P)
    TQG.Group.dungeonQuestAcceptButton:SetEnabled(false)
    TQG.Group.dungeonQuestAcceptButton:SetHidden(true)
    local F, X;
    if P then
        for h = 1, #TQG.TopLevelGroup do
            for aE = 1, #TQG.ZoneLevelGroup[h] do
                local _, ch = P.name:find(".dds", 8, false)
                local ci = ch + 4;
                if TQG.ZoneLevelGroup[h][aE].zoneName == P.name:sub(ci) then
                    F = h;
                    X = aE;
                    TQG.selectedGroupZoneId = TQG.ZoneLevelGroup[h][aE].id;
                    break
                end
            end
        end
    end
    if not F or not X then
        TQG.Group.playStoryButton:SetEnabled(false)
        TQG.Group.playStoryButton:SetText("")
        TQG.Group.playStoryButton:SetHidden(false)
        return
    end
    for h = 1, #TQG.ObjectiveLevelGroup[F][X] do
        local b5 = TQG.ObjectiveLevelGroup[F][X][h].internalId;
        if GetCompletedQuestInfo(b5) ~= "" and GetCompletedQuestInfo(b5) ~= nil then
            TQG.Group.playStoryButton:SetEnabled(false)
            TQG.Group.playStoryButton:SetText(GetString(
                                                  TQG_DEFAULT_QUEST_COMPLETE))
            TQG.Group.playStoryButton:SetHidden(false)
            TQG.trackedGroupObjectiveIndex = h
        else
            TQG.Group.playStoryButton:SetEnabled(true)
            TQG.Group.playStoryButton:SetText("Show Quest")
            TQG.Group.playStoryButton:SetHidden(false)
            TQG.trackedGroupObjectiveIndex = h;
            break
        end
    end
end
function TQG.Group:StoryButtonHooks(aZ)
    local a_ = GetControl(aZ)
    local b0 = a_:GetNamedChild("ButtonContainer")
    TQG.Group.playStoryButton = b0:GetNamedChild("PlayStoryButton")
    TQG.Group.playStoryButton:SetClickSound(SOUNDS.ZONE_STORIES_TRACK_ACTIVITY)
    TQG.Group.dungeonQuestAcceptButton = b0:GetNamedChild("QuestAccept")
end
function TQG.Group:Initialize(j)
    local cj = TQG.sceneNameQuestGuideGroup;
    TQG_GROUP_ALMANAC_FRAGMENT = ZO_HUDFadeSceneFragment:New(TQG_TabGroup)
    TQG_SCENE_GROUP = ZO_Scene:New(cj, SCENE_MANAGER)
    TQG_SCENE_GROUP:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    TQG_SCENE_GROUP:AddFragmentGroup(
        FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    TQG_SCENE_GROUP:AddFragmentGroup(
        FRAGMENT_GROUP.PLAYER_PROGRESS_BAR_KEYBOARD_CURRENT)
    TQG_SCENE_GROUP:AddFragment(FRAME_EMOTE_FRAGMENT_JOURNAL)
    TQG_SCENE_GROUP:AddFragment(TQG.BACKGROUND_FRAGMENT)
    TQG_SCENE_GROUP:AddFragment(TREE_UNDERLAY_FRAGMENT)
    TQG_SCENE_GROUP:AddFragment(TITLE_FRAGMENT)
    TQG_SCENE_GROUP:AddFragment(ZO_SetTitleFragment:New(TQG_MENU_JOURNAL))
    TQG_SCENE_GROUP:AddFragment(CODEX_WINDOW_SOUNDS)
    TQG_SCENE_GROUP:AddFragment(TQG_GROUP_ALMANAC_FRAGMENT)
    SYSTEMS:RegisterKeyboardRootScene(cj, TQG_SCENE_GROUP)
    TQG_SCENE_GROUP:RegisterCallback("StateChange", function(l, m)
        if m == SCENE_SHOWING then
            TQG.MenuState = 4;
            TQG.MenuHidden = false;
            TQGButtonsButton1.m_object:SetState(0)
            TQGButtonsButton1.m_object:SetLocked(false)
            TQGButtonsButton2.m_object:SetState(0)
            TQGButtonsButton2.m_object:SetLocked(false)
            TQGButtonsButton3.m_object:SetState(0)
            TQGButtonsButton3.m_object:SetLocked(false)
        elseif m == SCENE_HIDING then
            TQG.MenuHidden = true
        end
    end)
    TQG.ButtonSetup(j)
    TQG.Group:StoryButtonHooks("TQG_TabGroup")
end
function TQG.Group:New(j)
    TQG.Group:Initialize(j)
    local n = ZO_Object.New(self)
    n.control = j;
    n.zoneInfoContainer = j:GetNamedChild("ZoneInfoContainer")
    n.zoneStepContainer = j:GetNamedChild("ZoneStepContainer")
    n.titleText = j:GetNamedChild("TitleText")
    n.descriptionText = j:GetNamedChild("DescriptionText")
    n.objectivesText = j:GetNamedChild("ObjectivesText")
    n.objectiveLinePool = ZO_ControlPool:New("TQG_TabGroup_ObjectiveLine", j,
                                             "Objective")
    n.currentProgressionLevel = #TQG.TopLevelGroup;
    n:InitializeCategoryList(j)
    n:RefreshList()
    local function b2() n:RefreshList() end
    local function bZ() n:RefreshList() end
    local function C() n:RefreshList() end
    j:RegisterForEvent(EVENT_QUEST_ADDED, b2)
    j:RegisterForEvent(EVENT_QUEST_REMOVED, bZ)
    j:RegisterForEvent(EVENT_QUEST_COMPLETE, C)
    return n
end
function TQG.Group:InitializeCategoryList(j)
    self.navigationTree = ZO_Tree:New(j:GetNamedChild(
                                          "NavigationContainerScrollChild"), 60,
                                      -10, 300)
    local D = {
        [1] = {
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_aldmeriicon_over.dds"
        },
        [2] = {
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_daggerfallicon_over.dds"
        },
        [3] = {
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_down.dds",
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_ebonhearticon_over.dds"
        },
        [4] = {
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_down.dds",
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_up.dds",
            "esoui/art/treeicons/antiquities_tabicon_coldharbour_over.dds"
        },
        [5] = {
            "esoui/art/treeicons/antiquities_tabicon_craglorn_down.dds",
            "esoui/art/treeicons/antiquities_tabicon_craglorn_up.dds",
            "esoui/art/treeicons/antiquities_tabicon_craglorn_over.dds"
        },
        [6] = {
            "esoui/art/treeicons/store_indexicon_dlc_down.dds",
            "esoui/art/treeicons/store_indexicon_dlc_up.dds",
            "esoui/art/treeicons/store_indexicon_dlc_over.dds"
        },
        [7] = {
            "esoui/art/icons/progression_tabicon_daedricconjuration_down.dds",
            "esoui/art/icons/progression_tabicon_daedricconjuration_up.dds",
            "esoui/art/icons/progression_tabicon_daedricconjuration_over.dds"
        },
        [8] = {
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_murkmire_over.dds"
        },
        [9] = {
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_elsweyr_over.dds"
        },
        [10] = {
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_down.dds",
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_up.dds",
            "/esoui/art/treeicons/tutorial_indexicon_greymoor_over.dds"
        },
        [11] = {
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_down.dds",
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_up.dds",
            "/esoui/art/treeicons/tutorial_idexicon_deadlands_over.dds"
        },
        [12] = {
            "/esoui/art/charactercreate/charactercreate_bretonicon_down.dds",
            "/esoui/art/charactercreate/charactercreate_bretonicon_up.dds",
            "/esoui/art/charactercreate/charactercreate_bretonicon_over.dds"
        },
        [13] = {
            "/esoui/art/charactercreate/charactercreate_arcanisticon_down.dds",
            "/esoui/art/charactercreate//charactercreate_arcanisticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_arcanisticon_over.dds"
        },
        [14] = {
            "/esoui/art/charactercreate/charactercreate_arcanisticon_down.dds",
            "/esoui/art/charactercreate//charactercreate_arcanisticon_up.dds",
            "/esoui/art/charactercreate/charactercreate_arcanisticon_over.dds"
        },
        [15] = {
            "esoui/art/treeicons/reconstruction_tabicon_dungeon_down.dds",
            "esoui/art/treeicons/reconstruction_tabicon_dungeon_up.dds",
            "esoui/art/treeicons/reconstruction_tabicon_dungeon_over.dds"
        }
    }
    local function E(F) if D[F] then return unpack(D[F]) end end
    local function K(H, j, F, I)
        j.progressionLevel = F;
        j.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        j.text:SetText(TQG.TopLevelGroup[F])
        local L, M, N = E(F)
        j.icon:SetTexture(I and L or M)
        j.iconHighlight:SetTexture(N)
        ZO_IconHeader_Setup(j, I)
    end
    self.navigationTree:AddTemplate("ZO_IconHeader", K, nil, nil, nil, 0)
    local function O(H, j, P, I)
        j:SetText(zo_strformat(SI_CADWELL_QUEST_NAME_FORMAT, P.name))
        GetControl(j, "CompletedIcon"):SetHidden(not P.completed)
        j:SetSelected(false)
    end
    local function Q(j, P, R, S)
        j:SetSelected(R)
        if R and not S then
            TQG.Group:UpdateStoryButtons(P)
            self:RefreshDetails()
        end
    end
    local function T(U, V) return U.name == V.name end
    self.navigationTree:AddTemplate("ZO_CadwellNavigationEntry", O, Q, T)
    self.navigationTree:SetExclusive(true)
    self.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end
local function W(F, X)
    local a4 = TQG.ZoneLevelGroup[F][X].name;
    local b3 = TQG.ZoneLevelGroup[F][X].id;
    local Z = ""
    local Y;
    if type(a4) == "number" or a4 == "" then
        a4 = TQG.ZoneLevelGroup[F][X].name;
        a4 = "(" .. string.format("%.2f", a4) .. ")"
        local b4 = GetCVar("language.2")
        if b4 == "de" or b4 == "fr" or b4 == "ru" then
            a4 = string.gsub(a4, "%.", ",", 1)
        end
        local ck = TQG.ZoneLevelGroup[F][X].zoneName;
        Y = ck or GetZoneNameById(b3)
        local cl = TQG.ZoneLevelGroup[F][X].type;
        if cl == "Dungeon" or cl == "Arena" then
            Y = string.format("%s |t32:32:%s|t %s", a4,
                              "/esoui/art/icons/poi/poi_groupinstance_complete.dds",
                              Y)
        elseif cl == "Trial" or cl == "Maelstrom Arena" then
            Y = string.format("%s |t32:32:%s|t %s", a4,
                              "/esoui/art/icons/poi/poi_raiddungeon_complete.dds",
                              Y)
        end
    end
    if type(b3) == "string" then
        Z = b3
    else
        Z = GetZoneDescriptionById(b3)
    end
    local a0 = X;
    return b3, Y, Z, a0
end
function TQG.Group:b7(F, X, objectiveIndex, aG)
    local b4 = GetCVar("language.2")
    if b4 ~= "de" and b4 ~= "fr" and b4 ~= "ru" then b4 = "en" end
    local a3 = false;
    local ag = objectiveIndex;
    local a4, a5, a6, a2;
    local b5, b6, b7, b8;
    local aM = TQG.ZoneLevelGroup[F][X].id;
    local cm = false;
    local overrideName = TQG.ObjectiveLevelGroup[F][X][objectiveIndex]
                             .overrideQName or nil;
    b5 = TQG.ObjectiveLevelGroup[F][X][objectiveIndex].internalId;
    a4 = GetQuestName(b5)
    if overrideName then a4 = overrideName end
    if b5 == 5743 then
        for h, cn in ipairs(TQG.MultiQuestIds[11]) do
            local co, cp;
            if b4 == "fr" then
                co = "Le fantôme aîné"
                cp = "L'aîné des fantômes"
            end
            local bf = GetCompletedQuestInfo(cn) or ""
            if bf == a4 or bf == co or bf == langTwo then
                local b3 = cn;
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b3)
                cm = true;
                break
            end
        end
    end
    if not b5 then
        for h, bh in pairs(LibUespQuestData.quests) do
            local b3 = tonumber(bh.internalId)
            local bf = ""
            bf = GetCompletedQuestInfo(b3)
            if bf == "" or bf == nil then
                bf = GetCompletedQuestInfo(b3) or ""
            end
            if GetQuestName(b3) == a4 and not overrideName then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b3)
                _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b3)
                if b6 == "" then b6 = nil end
                break
            elseif bf == a4 then
                b5 = b3;
                b8 = LibUespQuestData:GetUespQuestBackgroundText(b3)
                _, b6 = LibUespQuestData:GetUespQuestLocationInfo(b3)
            end
            if b6 == "" then
                b6 = nil;
                break
            end
        end
    elseif not cm then
        b8 = LibUespQuestData:GetUespQuestBackgroundText(b5)
        _, b6, b7 = LibUespQuestData:GetUespQuestLocationInfo(b5)
        if b6 == "" then b6 = nil end
    end
    if type(aM) == "string" then
        local cq, _ = aM:find(":", 1, true)
        a5 = b6 or aM:sub(1, cq - 1)
    else
        a5 = nil
    end
    if GetCompletedQuestInfo(b5) == "" and not cm then
        a3 = false;
        for h = 1, GetNumJournalQuests() do
            if GetJournalQuestName(h) == a4 then
                a2 = true;
                _, a5 = GetJournalQuestInfo(h)
                break
            else
                a2 = false
            end
        end
        a6 = ""
    else
        a3 = true;
        a2 = true;
        a5 = ""
        a6 = b8
    end
    local function bi(bj, bk)
        if a4 == GetQuestName(bk) then
            bj = string.gsub(bj, " u2026.", "...")
        else
            bj = string.gsub(bj, " u2026", "...")
        end
        return bj
    end
    if b8 ~= "" and b8 then
        if a6 == b8 then
            a6 = bi(a6, 4296)
            a6 = bi(a6, -1)
            a6 = string.gsub(a6, "u2014", "—")
        elseif a5 == b8 then
            a5 = bi(a5, 4296)
            a5 = bi(a5, -1)
            a5 = string.gsub(a5, "u2014", "—")
        end
    end
    local bl = TQG.ObjectiveLevelGroup[F][X][objectiveIndex].overrideZone;
    if a5 == nil or a5 == "" or bl then
        a5 = bl;
        if a5 == nil or a5 == "" then
            a5 = GetString(TQG_DEFAULT_QUEST_INCOMPLETE)
        end
    end
    if a6 == nil or a6 == "" then a6 = GetString(TQG_DEFAULT_QUEST_COMPLETE) end
    local bm = TQG.ObjectiveLevelGroup[F][X][objectiveIndex].optional or false;
    return a4, a5, a6, ag, a2, a3, bm
end
function TQG.Group:RefreshList()
    if self.control:IsHidden() then
        self.dirty = true;
        return
    end
    self.navigationTree:Reset()
    local a7 = {}
    for F = 1, #TQG.TopLevelGroup do
        local a8 = #TQG.ZoneLevelGroup[F]
        if self.currentProgressionLevel < F then break end
        if a8 > 0 then
            local a9 = self.navigationTree:AddNode("ZO_IconHeader", F)
            for aa = 1, a8 do
                local aM, Y, Z, a0 = W(F, aa)
                local bn = 0;
                local ab = true;
                local ac = {}
                local aG, aH, bo, bp;
                aG, aH, bo, bp = 0, 0, 0, 0;
                local ad = bo;
                local bq = false;
                if bp > 0 then
                    ad = ad + 1;
                    bq = true
                end
                if ad == 0 then
                    ad = #TQG.ObjectiveLevelGroup[F][aa]
                end
                local br = 1;
                if ad ~= #TQG.ObjectiveLevelGroup[F][aa] then
                    if TQG.ObjectiveLevelGroup[F][aa][0] then
                        br = 0;
                        local bd = TQG.ObjectiveLevelGroup[F][aa][0]
                                       .prologueQIds;
                        if bd and bd > 1 then
                            ad = ad + bd - 1
                        end
                    elseif TQG.ObjectiveLevelGroup[F][aa][ad + 1]
                        .overrideDetails then
                        ad = ad + #TQG.ObjectiveLevelGroup[F][aa] - ad
                    end
                end
                for objectiveIndex = br, ad do
                    local a4, ae, af, ag, ah, ai, bs;
                    if objectiveIndex == ad and bq == true then
                        a4 = "TBC"
                        ae, af = GetErrorString(bp)
                        ag = objectiveIndex;
                        ah = false;
                        ai = false;
                        bs = false
                    else
                        a4, ae, af, ag, ah, ai, bs = TQG.Group:b7(F, aa,
                                                                  objectiveIndex,
                                                                  aG)
                        ab = ab and (ai or bs)
                        if ai then bn = bn + 1 end
                    end
                    table.insert(ac, {
                        name = a4,
                        openingText = ae,
                        closingText = af,
                        order = ag,
                        discovered = ah,
                        completed = ai
                    })
                end
                table.sort(ac, ZO_CadwellSort)
                table.insert(a7, {
                    name = Y,
                    description = Z,
                    order = a0,
                    completed = ab and bn >= 1,
                    objectives = ac,
                    parent = a9
                })
            end
        end
    end
    table.sort(a7, ZO_CadwellSort)
    for h = 1, #a7 do
        local aj = a7[h]
        local a9 = aj.parent;
        self.navigationTree:AddNode("ZO_CadwellNavigationEntry", aj, a9)
    end
    self.navigationTree:Commit()
    self:RefreshDetails()
end
function TQG.Group:RefreshDetails()
    local self = TQG_ALMANAC_GROUP;
    self.objectiveLinePool:ReleaseAllObjects()
    local ak = self.navigationTree:GetSelectedData()
    if not ak or not ak.objectives then
        self.zoneInfoContainer:SetHidden(true)
        self.zoneStepContainer:SetHidden(true)
        return
    else
        self.zoneInfoContainer:SetHidden(false)
        self.zoneStepContainer:SetHidden(false)
    end
    local cr = zo_strformat(SI_CADWELL_ZONE_NAME_FORMAT, ak.name)
    self.titleText:SetText(cr)
    self.descriptionText:SetText(zo_strformat(SI_CADWELL_ZONE_DESC_FORMAT,
                                              ak.description))
    local al;
    for h = 1, #ak.objectives do
        local am = ak.objectives[h]
        local an = self.objectiveLinePool:AcquireObject()
        if am.name == "TBC" then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(am.openingText)
        elseif am.discovered and not am.completed then
            an:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        elseif not am.discovered then
            an:SetColor(ZO_DISABLED_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(true)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.openingText))
        else
            an:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
            GetControl(an, "Check"):SetHidden(false)
            an:SetText(zo_strformat(SI_CADWELL_OBJECTIVE_FORMAT, am.name,
                                    am.closingText))
        end
        if not al then
            an:SetAnchor(TOPLEFT, self.objectivesText, BOTTOMLEFT, 25, 15)
        else
            an:SetAnchor(TOPLEFT, al, BOTTOMLEFT, 0, 15)
        end
        al = an
    end
end
function TQG.Group:OnShown()
    if self.dirty then
        self:RefreshList()
        self.dirty = false
    end
end
function TQG_TabGroup_OnShown() TQG_ALMANAC_GROUP:OnShown() end
function TQG_TabGroup_Initialize(j) TQG_ALMANAC_GROUP = TQG.Group:New(j) end
