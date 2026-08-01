LykeionsSpiritedAway = LykeionsSpiritedAway or {}
local LykeionsSpiritedAway = LykeionsSpiritedAway

LykeionsSpiritedAway.name     = "LykeionsSpiritedAway"
LykeionsSpiritedAway.EM       = GetEventManager()
LykeionsSpiritedAway.WM       = GetWindowManager()

local latinLangArr = {
	[GetString(SI_OFFICIALLANGUAGE0)] = true,
	[GetString(SI_OFFICIALLANGUAGE1)] = true,
	[GetString(SI_OFFICIALLANGUAGE2)] = true,
	[GetString(SI_OFFICIALLANGUAGE5)] = true,
}

local ingameTextBoxArr = {
	-- Seems that the operation of addons related to Crown Market will be suppressed?
	-- ZO_EsoPlusOffersTopLevel_KeyboardContentsSearchBox,
	-- ZO_KeyboardCrownStore_TopLevelContentsSearchBox,
	-- ZO_EndeavorSealStoreTopLevel_KeyboardContentsSearchBox,
	ZO_ChatWindowTextEntryEditBox, ZO_PlayerInventorySearchBox, ZO_PlayerBankSearchBox, ZO_HouseBankSearchBox, ZO_GuildBankSearchBox, ZO_CraftBagSearchBox, ZO_HelpSearchBox,
	ZO_AntiquityJournal_Keyboard_TopLevelContentsSearchBox, ZO_AchievementsContentsSearchBox,
	ZO_CollectionsBook_TopLevelSearchBox, ZO_OutfitStylesBook_Keyboard_TopLevelSearchBox, ZO_ItemSetsBook_Keyboard_TopLevelFiltersSearchBox, ZO_TributePatronBook_Keyboard_TopLevelFiltersSearchBox,
	ZO_KeyboardFriendsListSearchBox
}

function LykeionsSpiritedAway.ShowIMEC()
	if ZO_IMECandidates_TopLevel:GetAlpha() < 0.002 then
        ZO_IMECandidates_TopLevel:SetHidden(false)
		ZO_IMECandidates_TopLevel:SetAlpha(0.001)
		ZO_IMECandidates_TopLevel.anim = ANIMATION_MANAGER:CreateTimeline()
		ZO_IMECandidates_TopLevel.anim.alpha = ZO_IMECandidates_TopLevel.anim:InsertAnimation( ANIMATION_ALPHA, ZO_IMECandidates_TopLevel, 0 )
		ZO_IMECandidates_TopLevel.anim.alpha:SetDuration(300)
		ZO_IMECandidates_TopLevel.anim.alpha:SetEasingFunction(ZO_EaseOutQuintic)
		ZO_IMECandidates_TopLevel.anim.alpha:SetAlphaValues(0.001, 1)
		ZO_IMECandidates_TopLevel.anim:PlayFromStart()
	end
end

function LykeionsSpiritedAway.HideIMEC()
	if ZO_IMECandidates_TopLevel:GetAlpha() > 0.999 then
		ZO_IMECandidates_TopLevel:SetAlpha(1)
		ZO_IMECandidates_TopLevel.anim = ANIMATION_MANAGER:CreateTimeline()
		ZO_IMECandidates_TopLevel.anim.alpha = ZO_IMECandidates_TopLevel.anim:InsertAnimation( ANIMATION_ALPHA, ZO_IMECandidates_TopLevel, 0 )
		ZO_IMECandidates_TopLevel.anim.alpha:SetDuration(300)
		ZO_IMECandidates_TopLevel.anim.alpha:SetEasingFunction(ZO_EaseOutQuintic)
		ZO_IMECandidates_TopLevel.anim.alpha:SetAlphaValues(1, 0.001)
		ZO_IMECandidates_TopLevel.anim:PlayFromStart()
        zo_callLater(function()
            ZO_IMECandidates_TopLevel:SetHidden(true)
        end, 300)
        LykeionsSpiritedAway.EM:UnregisterForUpdate(LykeionsSpiritedAway.name)
	end
end

function LykeionsSpiritedAway.SceneCheck()
    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local name = currentScene.name
	if name == "hud" then
		LykeionsSpiritedAway.HideIMEC()
	end
end

function LykeionsSpiritedAway.OnAddonLoaded( event, addonName )
	if addonName ~= LykeionsSpiritedAway.name or IsConsoleUI() then
		return
	end

    LykeionsSpiritedAway.WM:SetHandler("OnIMECandidateListUpdated", function ()
		if not latinLangArr[GetKeyboardLayout()] then
			LykeionsSpiritedAway.ShowIMEC()
            LykeionsSpiritedAway.EM:RegisterForUpdate( LykeionsSpiritedAway.name, 200, function() LykeionsSpiritedAway.SceneCheck() end)
		end
	end, "LykeionsSpiritedAway_IME_UPDATE")

	for i = 1, #ingameTextBoxArr do
		ingameTextBoxArr[i]:SetHandler("OnFocusLost", function()
			LykeionsSpiritedAway.HideIMEC()
		end, "LykeionsSpiritedAway_FOCUS_LOST" .. i)


		ingameTextBoxArr[i]:SetHandler("OnTextChanged", function()
			LykeionsSpiritedAway.HideIMEC()
		end, "LykeionsSpiritedAway_TEXT_CHANGED" .. i)
	end
    
    
end
function LykeionsSpiritedAway.OnLanguageChanged( event )
	if latinLangArr[GetKeyboardLayout()] then
		LykeionsSpiritedAway.HideIMEC()
	end
end

LykeionsSpiritedAway.EM:RegisterForEvent( LykeionsSpiritedAway.name, EVENT_ADD_ON_LOADED, LykeionsSpiritedAway.OnAddonLoaded )
LykeionsSpiritedAway.EM:RegisterForEvent( LykeionsSpiritedAway.name, EVENT_INPUT_LANGUAGE_CHANGED, LykeionsSpiritedAway.OnLanguageChanged )

-- Override the ingame function
function ZO_IMECandidates:RefreshListContents()
    self.candidateRowPool:ReleaseAllObjects()
    self.height = 0
    self.highlightBackdrop:SetHidden(true)

    local windowManager = GetWindowManager()
    local numCandidates = windowManager:GetNumIMECandidates()
   
    if numCandidates > 0 then
        self.control:SetHidden(false)

        --Init this to ZO_IME_CANDIDATES_MIN_WIDTH so we have at least that much space in the final control
        local maxWidth = ZO_IME_CANDIDATES_MIN_WIDTH
    
        local selectedIndex, pageStartIndex, pageSize = windowManager:GetIMECandidatePageInfo()
        local inCandidateWindow = windowManager:IsChoosingIMECandidate()
        
        --We usually get a number of pages with a fixed page size and on the last page the page size becomes smaller if we don't have enough to fill it.
        --Instead of shrinking the view on the last page we lay it out to be as big as the other, just with empty space filling the rest.
        if pageSize > self.maxPageSize then
            self.maxPageSize = pageSize
        end

        local previousRow
        local candidateTextHeight
        local getMoreCandidatesEntryIndex
		-- Lykeion@Limit the candidates number to avoid game freezing
		if numCandidates > 10 then
			numCandidates = 10
		end

        for i = 1, numCandidates do
            local candidate = windowManager:GetIMECandidate(i)
            candidate = i % 10 .. ". " .. candidate
            
            --An entry of " " is included in the list where there should be an arrow indicating more results below
            if candidate == " " then
                getMoreCandidatesEntryIndex = i
            end

            local candidateRow = self.candidateRowPool:AcquireObject()
            local textLabel = candidateRow:GetNamedChild("Text")
            textLabel:SetText(candidate)

            candidateRow:ClearAnchors()
            if previousRow then
                candidateRow:SetAnchor(TOPLEFT, previousRow, BOTTOMLEFT, 0, 0)
            else
                candidateRow:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
            end
            local textWidth, textHeight = textLabel:GetTextDimensions() 
            if not candidateTextHeight then
                candidateTextHeight = textHeight
            end
            candidateRow:SetHeight(textHeight)

            if i == selectedIndex then
                --Only apply the highlight if the candidate list is active
                if inCandidateWindow then
                    self.highlightBackdrop:SetHidden(false)
                    self.highlightBackdrop:ClearAnchors()
                    self.highlightBackdrop:SetAnchorFill(candidateRow)
                end
            end
            
            maxWidth = zo_max(maxWidth, textWidth)            
            previousRow = candidateRow
        end
        
        --Make all the rows the same width so the highlight is uniform across all of them
        for _, candidateRow in pairs(self.candidateRowPool:GetActiveObjects()) do
            candidateRow:SetWidth(maxWidth)
        end
                
        if getMoreCandidatesEntryIndex then
            self.moreCandidatesRow:SetHidden(false)
            self.moreCandidatesRow:SetDimensions(maxWidth, candidateTextHeight)
            self.moreCandidatesRow:ClearAnchors()
            self.moreCandidatesRow:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, candidateTextHeight * (getMoreCandidatesEntryIndex - 1))
        else
            self.moreCandidatesRow:SetHidden(true)
        end

        local pageStartOffset
        --How many entries to show additionally on a scrollable edge. If you can scroll up and down and this value was 1 you'd see one additional entry above the page start and one after the page end
        local NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE = 0.65

        self.scrollChild:SetResizeToFitPadding(0, 0)
        if numCandidates <= self.maxPageSize then
            --if we don't have enough candidates to fill even one page it doesn't scroll so just start at the top
            pageStartOffset = 0
            self.height = self.maxPageSize * candidateTextHeight
        else
            --if we have enough to scroll figure out in which directions we can scroll and add the proper space
            local numExtraEntries
            if pageStartIndex == 1 then
                --Page 1, can only scroll down
                numExtraEntries = NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE
                pageStartOffset = 0 
            elseif (pageStartIndex + pageSize - 1) == numCandidates then
                --Last page, can only scroll up
                numExtraEntries = NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE
                pageStartOffset = -NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE
            else
                --Middle page, can scroll up or down
                numExtraEntries = NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE * 2
                pageStartOffset = -NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE
            end
            self.height = (self.maxPageSize + numExtraEntries) * candidateTextHeight
            local numRowsOnLastPage = numCandidates % self.maxPageSize
            if numRowsOnLastPage > 0 then
                --Pad out the scroll child to fill a full page
                self.scrollChild:SetResizeToFitPadding(0, candidateTextHeight * (self.maxPageSize - numRowsOnLastPage))
            end
        end
                
        local SCROLL_BAR_WIDTH = 16
        self.control:SetDimensions(maxWidth + SCROLL_BAR_WIDTH, self.height)
        
        ZO_Scroll_SetMaxFadeDistance(self.pane, candidateTextHeight * NUM_EXTRA_ENTRIES_ON_SCROLLABLE_EDGE)
        --Scroll to put the page top in view taking into account one line of scroll fade
        ZO_Scroll_ScrollAbsolute(self.pane, (pageStartIndex - 1 + pageStartOffset) * candidateTextHeight)
    else
        self.maxPageSize = 0
        self.height = 0
        self.control:SetHidden(true)
    end
end
