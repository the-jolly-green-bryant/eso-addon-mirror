--[[
  This file is part of Awesome Events.

  Author: Ze_Mi
  Filename: Skills.lua

  Copyright (c) 2017-2024 by Martin Unkel
  License : CreativeCommons CC BY-NC-SA 4.0 Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

  Please read the README file for further information.
  ]]

local CHAMPION_ATTRIBUTES = { ATTRIBUTE_HEALTH, ATTRIBUTE_STAMINA, ATTRIBUTE_MAGICKA }

local AE = Awesome_Events
local MOD = AE.module_factory({
    id = 'skills',
    title = GetString(SI_AWEMOD_SKILLS),
    hint = GetString(SI_AWEMOD_SKILLS_HINT),
    order = 20,
    debug = false
})

-- OVERRIDES

function MOD:Enable(options)
    self:d('Enable (in debug-mode)')
    self.data = {
        attributes = 0,
        championPoints = 0,
        skills = 0,
        hasUnspentPoints = false,
    }
    self:OnPointsChanged(0)
    self.hasUpdate = true
end

-- EVENT LISTENER
-- points (attribute- and skillpoints)
-- EVENT_SKILL_POINTS_CHANGED (integer eventCode,number pointsBefore, number pointsNow, number partialPointsBefore, number partialPointsNow)
-- EVENT_ATTRIBUTE_UPGRADE_UPDATED (number eventCode)
-- EVENT_LEVEL_UPDATE (integer eventCode,string unitTag, number level)
function MOD:GetEventListeners()
    return {
        {
            eventCode = EVENT_SKILL_POINTS_CHANGED,
            callback = function(eventCode, pointsBefore, pointsNow, partialPointsBefore, partialPointsNow)
                self:d("EVENT_SKILL_POINTS_CHANGED: ", pointsBefore .. '=>' .. pointsNow, partialPointsBefore .. '=>' .. partialPointsNow)
                MOD:OnPointsChanged(pointsNow - pointsBefore)
            end
        },
        {
            eventCode = EVENT_ATTRIBUTE_UPGRADE_UPDATED,
            callback = function(eventCode)
                self:d("EVENT_ATTRIBUTE_UPGRADE_UPDATED")
                MOD:OnPointsChanged(0)
            end
        },
        {
            eventCode = EVENT_UNSPENT_CHAMPION_POINTS_CHANGED,
            callback = function(eventCode)
                self:d("EVENT_UNSPENT_CHAMPION_POINTS_CHANGED")
                MOD:OnPointsChanged(0)
            end
        }
    }
end -- MOD:GetEventListeners

-- EVENT HANDLER

function MOD:OnPointsChanged(numChanged)
    self:d('OnSkillPointsChanged ' .. numChanged)
    local attributes, skills, championPoints = GetAttributeUnspentPoints(), GetAvailableSkillPoints(), GetPlayerChampionPointsEarned()

    local spentCP = 0
    for i = 1, GetNumChampionDisciplines() do
        for skill = 1, GetNumChampionDisciplineSkills(i) do
            local id = GetChampionSkillId(i, skill)
            spentCP = spentCP + GetNumPointsSpentOnChampionSkill(id)
        end
    end
    championPoints = championPoints - spentCP

    self:d(attributes, skills, championPoints)
    if (championPoints < 0) then
        championPoints = 0
    end

    if (attributes ~= self.data.attributes or championPoints ~= self.data.championPoints or skills ~= self.data.skills) then
        self.data.attributes = attributes
        self.data.championPoints = championPoints
        self.data.skills = skills
        self.data.hasUnspentPoints = (attributes + championPoints + skills) > 0

        self.hasUpdate = true
        self:d(' => hasUpdate')
    end
end -- MOD:OnPointsChanged

-- LABEL HANDLER

function MOD:Update(options)
    self:d('Update')
    local labelText = ''
    if (self.data.hasUnspentPoints) then
        if (self.data.attributes > 0) then
            labelText = MOD.Colorize(AE.const.COLOR_AVAILABLE, GetString(SI_AWEMOD_SKILLS_ATTRIBUTES_LABEL)) .. ': ' .. self.data.attributes
        end
        if (self.data.skills > 0) then
            if (labelText ~= '') then
                labelText = labelText .. MOD.Colorize(AE.const.COLOR_AVAILABLE, ' || ')
            end
            labelText = labelText .. MOD.Colorize(AE.const.COLOR_AVAILABLE, GetString(SI_AWEMOD_SKILLS_SKILLS_LABEL)) .. ': ' .. self.data.skills
        end
        if (self.data.championPoints > 0) then
            if (labelText ~= '') then
                labelText = labelText .. MOD.Colorize(AE.const.COLOR_AVAILABLE, ' || ')
            end
            labelText = labelText .. MOD.Colorize(AE.const.COLOR_AVAILABLE, GetString(SI_AWEMOD_SKILLS_CHAMPIONPOINTS_LABEL)) .. ': ' .. self.data.championPoints
        end
    end
    self.labels[1]:SetText(labelText)
end -- MOD:Update