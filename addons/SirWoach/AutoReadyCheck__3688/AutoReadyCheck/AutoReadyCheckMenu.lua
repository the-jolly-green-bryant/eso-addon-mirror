AutoReadyCheck = AutoReadyCheck or {}
local LAM = LibAddonMenu2

local function description(tag)
    return { type = "description", title = "|cf5e042" .. GetString(tag) .. "|r" }
end

local function checkbox(tag, Setter, Getter)
    return { type = "checkbox", name = GetString(tag),  getFunc = Getter, setFunc = Setter }
end

function AutoReadyCheck:BuildMenu()
    if not LAM then return end

    local panelName = self.name .. "SettingsPanel"
    local panelData = {
        type = "panel",
        name = GetString(ARC_MENU_TITLE),
        author = self.author
    }

    local options = {
        description(SI_NOTIFICATIONTYPE13),
        checkbox(SI_QUESTTYPE7, self.SetAvA, self.GetAvA),
        checkbox(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS, self.SetBattleGrounds, self.GetBattleGrounds),
        checkbox(SI_ENDLESS_DUNGEON_HUD_TRACKER_TITLE, self.SetEndlessDungeon, self.GetEndlessDungeon),
        checkbox(ARC_NORMAL_DUNGEON, self.SetDungeon, self.GetDungeon),
        checkbox(ARC_VETERAN_DUNGEON, self.SetVetDungeon, self.GetVetDungeon),
        checkbox(SI_HOUSETOURLISTINGTAG1, self.SetArena, self.GetArena),
        checkbox(SI_RAIDCATEGORY0, self.SetTrial, self.GetTrial),
        checkbox(ARC_TRIBUTE_COMP, self.SetTributeComp, self.GetTributeComp),
        checkbox(ARC_TRIBUTE_CASUAL, self.SetTributeCasual, self.GetTributeCasual),
        checkbox(SI_LFGACTIVITY6, self.SetHomeShow, self.GetHomeShow),
        description(SI_INSTANCETYPE2),
        checkbox(SI_ACTIVITYFINDERSTATUS4, self.SetGroupElection, self.GetGroupElection),
        description(SI_ITEMTYPEDISPLAYCATEGORY7),
        checkbox(ARC_MENU_MESSAGE_TOGGLE, self.SetMessagesEnabled, self.GetMessagesEnabled)     ,   
    }

    self.panel = LAM:RegisterAddonPanel(panelName, panelData)
    LAM:RegisterOptionControls(panelName, options)
end

-- Open Addon Settings Panel
function AutoReadyCheck.OpenPanel()
    LAM:OpenToPanel(AutoReadyCheck.panel)
end
