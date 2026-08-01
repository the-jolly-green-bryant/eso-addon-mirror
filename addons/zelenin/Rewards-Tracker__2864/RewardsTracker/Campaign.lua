local addon = ZO_InitializingObject:Subclass()
rewardsTrackerCampaign = addon

function addon:Initialize(owner)
    self.owner = owner
    self.name = string.format("%sCampaign", self.owner.name)
    self.data = LibSimpleSavedVars:NewInstallationWide(string.format("%sData", self.name), 1, {
        characters = {},
    })

    self.assaultIndex = 1
    self.supportIndex = 3

    self.updatePoints = true

    self.currentCharacterId = GetCurrentCharacterId()
    self:initCharacters()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function(eventCode, initial)
        QueryCampaignLeaderboardData()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ASSIGNED_CAMPAIGN_CHANGED, function(eventCode, newAssignedCampaignId)
        self:scanCampaign()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_CAMPAIGN_LEADERBOARD_DATA_RECEIVED, function(eventCode, campaignId, alliance)
        self:scanCampaign()
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_ALLIANCE_POINT_UPDATE, function(eventCode, alliancePoints, playSound, difference, reason)
        if not IsInCyrodiil() then
            return
        end

        local lastPoints = self.data.characters[self.currentCharacterId].points

        self.data.characters[self.currentCharacterId].points = self.data.characters[self.currentCharacterId].points + difference

        if self.owner.settings.data.apChatNotifications == true then
            self:notify(lastPoints)
        end
    end)

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SKILL_RANK_UPDATE, function(eventCode, skillType, skillIndex, rank)
        if skillType ~= SKILL_TYPE_AVA then
            return
        end
        if skillIndex ~= self.assaultIndex or skillIndex ~= self.supportIndex then
            return
        end

        self.data.characters[self.currentCharacterId].skillLines = self:getSkillLineRanks()
    end)

    self.control = RewardsTrackerCampaignContainer
    local fragment = ZO_HUDFadeSceneFragment:New(self.control)
    fragment:SetConditional(function()
        return self.owner.settings.data.allianceWarUi == true
    end)
    fragment:RegisterCallback("StateChange", function(oldState, newState)
        if newState == SCENE_SHOWING then
            self:resize()
            self:refresh()
            self.control:ClearAnchors()
            self.control:SetAnchor(TOPRIGHT, ZO_SharedRightBackground, TOPLEFT, -16, 0)
        end
    end)
    SCENE_MANAGER:GetScene("campaignBrowser"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("campaignOverview"):AddFragment(fragment)
    SCENE_MANAGER:GetScene("leaderboards"):AddFragment(fragment)

    self:createList()
end

function addon:notify(lastPoints)
    local currentPoints = self.data.characters[self.currentCharacterId].points
    if math.ceil(lastPoints / 1000) < math.ceil(currentPoints / 1000) then
        local fontSize = GetChatFontSize()
        CHAT_ROUTER:AddSystemMessage(string.format("|t%d:%d:esoui/art/currency/alliancepoints.dds|t %d", fontSize, fontSize, currentPoints))
    end
end

function addon:scanCampaign()
    LibHandler:Condition(
        function()
            local campaignId = GetAssignedCampaignId()
            return campaignId == 0 or GetNumCampaignLeaderboardEntries(campaignId) > 0
        end,
        function()
            local campaignId = GetAssignedCampaignId()
            local inLeaderboard = false
            if campaignId ~= 0 then
                for index = 1, GetNumCampaignLeaderboardEntries(campaignId) do
                    local isPlayer, rank, name, points, class, alliance, displayName = GetCampaignLeaderboardEntryInfo(campaignId, index)

                    if isPlayer then
                        local earnedTier, nextTierProgress, nextTierTotal = GetPlayerCampaignRewardTierInfo(campaignId)
                        self.data.characters[self.currentCharacterId].id = campaignId
                        self.data.characters[self.currentCharacterId].rank = rank
                        self.data.characters[self.currentCharacterId].tier = earnedTier
                        self.data.characters[self.currentCharacterId].skillLines = self:getSkillLineRanks()
                        if self.updatePoints then
                            self.data.characters[self.currentCharacterId].points = points
                            self.updatePoints = false
                        end
                        inLeaderboard = true
                    end
                end
            end

            if inLeaderboard == false then
                self.data.characters[self.currentCharacterId] = {
                    id = campaignId,
                    rank = 0,
                    points = 0,
                    tier = 0,
                    skillLines = self:getSkillLineRanks()
                }
            end
        end,
        2000
    )
end

function addon:initCharacters()
    for characterId, _ in pairs(self.data.characters) do
        if LibCharacter:Exists(characterId) == false then
            self.data.characters[characterId] = nil
        end
    end

    for _, character in ipairs(LibCharacter:GetCharacters()) do
        if self.data.characters[character.id] == nil then
            self.data.characters[character.id] = {
                id = 0,
                rank = 0,
                points = 0,
                tier = 0,
                skillLines = {
                    [self.assaultIndex] = 0,
                    [self.supportIndex] = 0,
                }
            }
        end

        if self.data.characters[character.id].skillLines == nil then
            self.data.characters[character.id].skillLines = {
                [self.assaultIndex] = 0,
                [self.supportIndex] = 0,
            }
        end
    end

    local campaignId = GetAssignedCampaignId()
    self.data.characters[self.currentCharacterId].id = campaignId
    self.data.characters[self.currentCharacterId].skillLines = self:getSkillLineRanks()
end

function addon:createList()
    self.rows = {}
    local headersControl = self.control:GetNamedChild("Headers")

    local colorValue = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_VALUE))
    local colorSelected = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SELECTED))
    local j = 1
    for index, character in ipairs(LibCharacter:GetCharacters(nil, LibCharacter.SORT_NAME)) do
        if self.owner.settings.data.characters[character.id] == true then
            local control = WINDOW_MANAGER:CreateControlFromVirtual("$(parent)Row", self.control, "RewardsTrackerCampaignListRow", character.id)
            if j == 1 then
                control:SetAnchor(TOPLEFT, headersControl, BOTTOMLEFT, 0, 0)
            else
                control:SetAnchor(TOPLEFT, self.rows[#self.rows], BOTTOMLEFT, 0, 0)
            end

            for i = 1, control:GetNumChildren() do
                local child = control:GetChild(i)
                if child and child:GetType() == CT_LABEL then
                    child:SetColor(colorValue:UnpackRGBA())
                end
            end

            control:GetNamedChild("Points"):SetColor(colorSelected:UnpackRGBA())

            table.insert(self.rows, control)
            j = j + 1
        end
    end
end

function addon:resize()
    --local headersWidth = self.control:GetNamedChild("Headers"):GetWidth()
    --
    --local controlHeight = 0
    --for i = 1, self.control:GetNumChildren() do
    --    controlHeight = controlHeight+ self.control:GetChild(i):GetHeight()
    --end
    --
    --self.control:SetWidth(16+headersWidth+16)
    --self.control:SetHeight(16+controlHeight+16)

    local rows = #self.rows

    local width = 200 + 200 + 150 + 50 + 100 + 100 + 16 * 2 + 16 * 5
    local height = 16 + 32 + 30 * rows + 16

    self.control:SetDimensions(width, height)
end

function addon:refresh()
    local i = 1
    for index, character in ipairs(LibCharacter:GetCharacters(nil, LibCharacter.SORT_NAME)) do
        if self.owner.settings.data.characters[character.id] == true then
            local control = self.rows[i]

            local data = self.data.characters[character.id]

            local name = self.currentCharacterId == character.id and string.format("> %s", character.name) or character.name

            local classColor = GetClassColor(character.classId)
            local allianceColor = GetAllianceColor(character.alliance)

            control:GetNamedChild("Name"):SetText(string.format("%s %s", allianceColor:Colorize(string.format('|t32:32:%s:inheritcolor|t', GetClassIcon(character.classId))), allianceColor:Colorize(name)))
            control:GetNamedChild("Rank"):SetText(string.format("[%02d] %s", character.avaRank, GetAvARankName(character.gender, character.avaRank)))
            if data.skillLines[self.assaultIndex] == data.skillLines[self.supportIndex] then
                control:GetNamedChild("SkillLines"):SetText(string.format("%d", data.skillLines[self.assaultIndex]))
            else
                control:GetNamedChild("SkillLines"):SetText(string.format("%d/%d", data.skillLines[self.assaultIndex], data.skillLines[self.supportIndex]))
            end
            control:GetNamedChild("Campaign"):SetText(GetCampaignName(data.id))
            control:GetNamedChild("Tier"):SetText(data.tier)
            control:GetNamedChild("Points"):SetText(data.points)

            i = i + 1
        end
    end
end

function addon:getSkillLineRanks()
    local ready = not (SKILLS_DATA_MANAGER == nil or not SKILLS_DATA_MANAGER:IsDataReady())
    return {
        [self.assaultIndex] = ready and SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_AVA, self.assaultIndex).currentRank or 0,
        [self.supportIndex] = ready and SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(SKILL_TYPE_AVA, self.supportIndex).currentRank or 0,
    }
end
