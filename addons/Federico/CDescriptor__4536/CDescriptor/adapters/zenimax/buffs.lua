CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

CDescriptor.Adapters = CDescriptor.Adapters or {}

local GetGameTimeMilliseconds     = GetGameTimeMilliseconds
local GetNumBuffs                 = GetNumBuffs
local GetUnitBuffInfo             = GetUnitBuffInfo
local GetAbilityDescription       = GetAbilityDescription
local GetAbilityEffectDescription = GetAbilityEffectDescription
local math_floor                  = math.floor

local M = {}

function M.get_active_buffs()
  local buffs = {}
  local now = GetGameTimeMilliseconds() / 1000
  local count = GetNumBuffs("player")

  for i = 1, count do
    local name, time_started, time_ending, buff_slot, stack_count,
          icon, _, effect_type, ability_type, _, ability_id, _, cast_by_player =
      GetUnitBuffInfo("player", i)

    if name and name ~= "" and effect_type == BUFF_EFFECT_TYPE_BUFF then
      local duration_remaining = nil
      if time_ending > 0 then
        local secs = math_floor(time_ending - now)
        if secs > 0 then duration_remaining = secs end
      end

      local description = nil
      if ability_id and ability_id ~= 0 then
        description = GetAbilityDescription(ability_id, nil, "player") or nil
        if description == "" then description = nil end
      end
      if not description and buff_slot and buff_slot ~= 0 then
        local effect_desc = GetAbilityEffectDescription(buff_slot) or nil
        if effect_desc ~= "" then description = effect_desc end
      end

      buffs[#buffs + 1] = {
        name               = name,
        description        = description,
        ability_id         = ability_id,
        duration_remaining = duration_remaining,
        stacks             = stack_count > 1 and stack_count or nil,
        cast_by_player     = cast_by_player,
      }
    end
  end

  return buffs
end

CDescriptor.Adapters.Buffs = M
