--[[
  This file is part of Aenathel's Lazy Riding Skill Trainer, licensed under
  The MIT License. See the LICENSE file of this project for more information.
--]]

ZO_CreateStringId("AELRST_ADDON_VERSION", "1.3.0")
ZO_CreateStringId("AELRST_ADDON_WEBSITE", "https://www.esoui.com/downloads/info2614-AenathelsLazyRidingSkillTrainer.html")

local template = "<<1>> - <<2>> - <<3>>"
local carry = GetString(SI_RIDINGTRAINTYPE2)
local speed = GetString(SI_RIDINGTRAINTYPE1)
local stamina = GetString(SI_RIDINGTRAINTYPE3)

ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_CARRY_SPEED_STAMINA", zo_strformat(template, carry, speed, stamina))
ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_CARRY_STAMINA_SPEED", zo_strformat(template, carry, stamina, speed))
ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_SPEED_CARRY_STAMINA", zo_strformat(template, speed, carry, stamina))
ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_SPEED_STAMINA_CARRY", zo_strformat(template, speed, stamina, carry))
ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_STAMINA_CARRY_SPEED", zo_strformat(template, stamina, carry, speed))
ZO_CreateStringId("AELRST_RIDING_SKILL_PRIORITY_STAMINA_SPEED_CARRY", zo_strformat(template, stamina, speed, carry))

