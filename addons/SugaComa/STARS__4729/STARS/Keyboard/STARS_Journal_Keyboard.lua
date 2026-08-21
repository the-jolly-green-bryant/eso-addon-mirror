local STARS = STARS
STARS.JOURNAL = STARS.JOURNAL or {}
local KeyboardJournal = STARS.JOURNAL.Keyboard or {}
STARS.JOURNAL.Keyboard = KeyboardJournal

local SCENE_NAME = "starsJournalKeyboard"
local PAGE_CAMPAIGN = 2
local PAGE_HISTORY = 3
local PAGE_LEGACY = 4
local PAGE_UNDERWORLD = 5
local PAGE_PRESTIGE = 6
local PAGE_CHRONICLE = 7

if ZO_CreateStringId then
    ZO_CreateStringId("SI_BINDING_NAME_STARS_TOGGLE_STATS_SHEET", "Open STARS Journal")
end

local KeyboardJournalScreen = STARS.JOURNAL.GamepadClass:Subclass()

function KeyboardJournalScreen:New(control)
    local object = ZO_Object.New(self)
    object:Initialize(control)
    return object
end

function KeyboardJournalScreen:Initialize(control)
    self.control = control
    self.contentFrame = control:GetNamedChild("ContentFrame")
    self.navigation = control:GetNamedChild("Navigation")
    self.chroniclePage = self.contentFrame and self.contentFrame:GetNamedChild("ChroniclePage")
    self.campaignPage = self.contentFrame and self.contentFrame:GetNamedChild("CampaignPage")
    self.historyPage = self.contentFrame and self.contentFrame:GetNamedChild("HistoryPage")
    self.legacyPage = self.contentFrame and self.contentFrame:GetNamedChild("LegacyPage")
    self.underworldPage = self.contentFrame and self.contentFrame:GetNamedChild("UnderworldPage")
    self.prestigePage = self.contentFrame and self.contentFrame:GetNamedChild("PrestigePage")
    self:InitializeMouseControls()

    KeyboardJournal.fragment = ZO_FadeSceneFragment:New(control)
    KeyboardJournal.fragment:RegisterCallback("StateChange", function(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            self:ApplyContentFrameAnchors()
            self.chroniclePageIndex = 1
            self:ShowPage(PAGE_PRESTIGE)
            self:RefreshChronicleButtons()
        end
    end)

    KeyboardJournal.scene = ZO_Scene:New(SCENE_NAME, SCENE_MANAGER)
    if FRAGMENT_GROUP and FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW then
        KeyboardJournal.scene:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    end
    if UI_SHORTCUTS_ACTION_LAYER_FRAGMENT then
        KeyboardJournal.scene:AddFragment(UI_SHORTCUTS_ACTION_LAYER_FRAGMENT)
    end
    KeyboardJournal.scene:AddFragment(KeyboardJournal.fragment)
end

function KeyboardJournalScreen:ApplyContentFrameAnchors()
    if not self.contentFrame or not GuiRoot then return end
    self.contentFrame:ClearAnchors()
    self.contentFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 330, 92)
    self.contentFrame:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, -40, -60)
    self:ApplyResponsiveLayout()
end

function KeyboardJournalScreen:SelectPage(pageId)
    if pageId == PAGE_CHRONICLE and self.currentPage ~= PAGE_CHRONICLE then
        self.chroniclePageIndex = 1
    end
    self:ShowPage(pageId)
    self:RefreshChronicleButtons()
end

function KeyboardJournalScreen:RefreshChronicleButtons()
    if not self.navigation then return end
    local previousButton = self.navigation:GetNamedChild("PreviousMemory")
    local nextButton = self.navigation:GetNamedChild("NextMemory")
    local show = self.currentPage == PAGE_CHRONICLE and self:GetChronicleMemoryCount() > 1
    if previousButton then previousButton:SetHidden(not show) end
    if nextButton then nextButton:SetHidden(not show) end
end

function KeyboardJournalScreen:ChangeKeyboardMemory(delta)
    self:ChangeChronicleMemory(delta)
    self:RefreshChronicleButtons()
end

function KeyboardJournalScreen:InitializeMouseControls()
    if not self.navigation then return end
    local pages = {
        MemoryBook = PAGE_PRESTIGE,
        Chronicle = PAGE_CHRONICLE,
        Veterancy = PAGE_CAMPAIGN,
        History = PAGE_HISTORY,
        PvpLegacy = PAGE_LEGACY,
        Underworld = PAGE_UNDERWORLD,
    }
    for controlName, pageId in pairs(pages) do
        local button = self.navigation:GetNamedChild(controlName)
        if button then
            button:SetHandler("OnClicked", function() self:SelectPage(pageId) end)
        end
    end

    local previousButton = self.navigation:GetNamedChild("PreviousMemory")
    local nextButton = self.navigation:GetNamedChild("NextMemory")
    local closeButton = self.navigation:GetNamedChild("Close")
    if previousButton then
        previousButton:SetHandler("OnClicked", function() self:ChangeKeyboardMemory(-1) end)
    end
    if nextButton then
        nextButton:SetHandler("OnClicked", function() self:ChangeKeyboardMemory(1) end)
    end
    if closeButton then
        closeButton:SetHandler("OnClicked", function()
            if SCENE_MANAGER and SCENE_MANAGER.HideCurrentScene then
                SCENE_MANAGER:HideCurrentScene()
            end
        end)
    end

    if self.contentFrame then
        self.contentFrame:SetMouseEnabled(true)
        self.contentFrame:SetHandler("OnMouseWheel", function(_, delta)
            if self.currentPage == PAGE_CHRONICLE and self:GetChronicleMemoryCount() > 1 then
                self:ChangeKeyboardMemory(delta > 0 and -1 or 1)
            end
        end)
    end
end

function KeyboardJournal:Initialize()
    if self.initialized then return end
    self.initialized = true
    if not STARSJournalKeyboard then
        d("[STARS] Keyboard Journal root control was not created.")
        return
    end
    KeyboardJournal.SCREEN = KeyboardJournalScreen:New(STARSJournalKeyboard)
    if SLASH_COMMANDS then
        SLASH_COMMANDS["/stars"] = STARS_ToggleStats
    end
end

local function IsSceneShowing(sceneName)
    return SCENE_MANAGER
        and type(SCENE_MANAGER.IsShowing) == "function"
        and SCENE_MANAGER:IsShowing(sceneName)
end

-- Final input-mode router. The gamepad implementation remains untouched; PC
-- keyboard mode opens its own mouse-driven scene and root control.
function STARS_ToggleStats()
    if not SCENE_MANAGER then return end
    if IsSceneShowing("starsJournalGamepad") or IsSceneShowing(SCENE_NAME) then
        if SCENE_MANAGER.HideCurrentScene then SCENE_MANAGER:HideCurrentScene() end
        return
    end
    if IsInGamepadPreferredMode and IsInGamepadPreferredMode() then
        SCENE_MANAGER:Show("starsJournalGamepad")
    else
        SCENE_MANAGER:Show(SCENE_NAME)
    end
end
