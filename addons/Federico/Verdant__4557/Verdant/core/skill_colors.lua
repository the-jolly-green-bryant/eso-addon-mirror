Verdant = Verdant or {}
Verdant.SkillColors = {}
local M = Verdant.SkillColors

local api = Verdant.zenimax.api
local GetAbilityName                          = api.GetAbilityName
local GetAbilityIcon                          = api.GetAbilityIcon
local GetSpecificSkillAbilityKeysByAbilityId  = api.GetSpecificSkillAbilityKeysByAbilityId
local GetSkillLineId                          = api.GetSkillLineId
local string_find                             = string.find

-- One color per class / skill-line.
local GROUP_COLORS = {
  templar     = { r = 0.95, g = 0.75, b = 0.15, a = 0.95 },  -- amber gold
  arcanist    = { r = 0.50, g = 1.00, b = 0.00, a = 0.95 },  -- vivid green
  warden      = { r = 0.00, g = 0.75, b = 0.50, a = 0.95 },  -- sky cyan
  resto       = { r = 0.72, g = 0.50, b = 0.18, a = 0.95 },  -- warm brown
  destru      = { r = 0.75, g = 0.90, b = 1.00, a = 0.95 },  -- pale ice
  dk          = { r = 0.88, g = 0.28, b = 0.08, a = 0.95 },  -- rust orange
  sorc        = { r = 0.28, g = 0.38, b = 0.95, a = 0.95 },  -- electric blue
  nb          = { r = 0.82, g = 0.10, b = 0.18, a = 0.95 },  -- crimson
  necro       = { r = 0.65, g = 0.18, b = 0.82, a = 0.95 },  -- violet
  scribing    = { r = 0.20, g = 0.80, b = 1.00, a = 0.95 },  -- arcane blue
  undaunted   = { r = 0.42, g = 0.42, b = 0.18, a = 0.95 },  -- olive
  support     = { r = 0.42, g = 0.31, b = 0.68, a = 0.95 },  -- muted purple
  vampire     = { r = 0.55, g = 0.05, b = 0.10, a = 0.95 },  -- carmesi (blood)
  werewolf    = { r = 0.60, g = 0.28, b = 0.18, a = 0.95 },  -- blood-moon russet (World, sibling of vampire)
  psijic      = { r = 0.86, g = 0.80, b = 0.52, a = 0.95 },  -- astral gold (Psijic Order)
  mages_guild = { r = 0.10, g = 0.45, b = 0.65, a = 0.95 },  -- celeste oscuro
  item        = { r = 0.95, g = 0.20, b = 0.80, a = 0.95 },  -- magenta
  other       = { r = 0.55, g = 0.55, b = 0.55, a = 0.80 },  -- unknown (grey)
}


local GROUP_LABELS = {
  templar        = "Templar",
  dk             = "Dragonknight",
  sorc           = "Sorcerer",
  nb             = "Nightblade",
  warden         = "Warden",
  necro          = "Necromancer",
  arcanist       = "Arcanist",
  destru         = "Destruction Staff",
  resto          = "Restoration Staff",
  mages_guild    = "Mages Guild",
  undaunted      = "Undaunted",
  support        = "Alliance War",
  scribing       = "Scribing",
  psijic         = "Psijic Order",
  vampire        = "Vampire",
  werewolf       = "Werewolf",
  item           = "Item Set / Enchant",
  other          = "Unknown (grey)",
}


local GROUP_ORDER = {
  "templar", "dk", "sorc", "nb", "warden", "necro", "arcanist",
  "destru", "resto",
  "mages_guild", "undaunted", "support", "scribing", "psijic",
  "vampire", "werewolf",
  "item",
  "other",
}


local ICON_PATTERNS = {
  { "ability_grimoire_",         "scribing"    },
  { "ability_templar_",          "templar"     },
  { "ability_sorcerer_",         "sorc"        },
  { "ability_arcanist_",         "arcanist"    },
  { "ability_warden_",           "warden"      },
  { "ability_dragonknight_",     "dk"          },
  { "ability_necromancer_",      "necro"       },
  { "ability_nightblade_",       "nb"          },
  { "ability_restorationstaff_", "resto"       },
  { "ability_destructionstaff_", "destru"      },
  { "ability_ava_",              "support"     },
  { "ability_undaunted_",        "undaunted"   },
  { "ability_mageguild_",        "mages_guild" },
  { "ability_psijic_",           "psijic"      },
  -- Vampire current and legacy paths.
  { "ability_u26_vampire_",      "vampire"     },
  { "ability_vampire_",          "vampire"     },
  { "ability_werewolf_",         "werewolf"    },
}


local SKILL_LINE_TO_GROUP = {
  -- Class lines
  [22]  = "templar",  [27]  = "templar",  [28]  = "templar",
  [35]  = "dk",       [36]  = "dk",       [37]  = "dk",
  [38]  = "nb",       [39]  = "nb",       [40]  = "nb",
  [41]  = "sorc",     [42]  = "sorc",     [43]  = "sorc",
  [127] = "warden",   [128] = "warden",   [129] = "warden",
  [131] = "necro",    [132] = "necro",    [133] = "necro",
  [218] = "arcanist", [219] = "arcanist", [220] = "arcanist",
  -- Vengeance subclass lines (mirror their base class)
  [297] = "dk",       [298] = "dk",       [299] = "dk",
  [300] = "nb",       [301] = "nb",       [302] = "nb",
  [303] = "templar",  [304] = "templar",  [305] = "templar",
  [306] = "sorc",     [307] = "sorc",     [308] = "sorc",
  [309] = "warden",   [310] = "warden",   [311] = "warden",
  [312] = "necro",    [313] = "necro",    [314] = "necro",
  [315] = "arcanist", [316] = "arcanist", [317] = "arcanist",
  -- Weapons (only those that fire heal/shield events)
  [33]  = "destru",   [34]  = "resto",
  [323] = "destru",   [324] = "resto",
  -- Guilds
  [44]  = "mages_guild",
  [55]  = "undaunted",
  -- Alliance War
  [48]  = "support",  [67]  = "support",
  [325] = "support",  [326] = "support",
  -- Psijic Order (guild)
  [130] = "psijic",
  -- World
  [51]  = "vampire",
  [50]  = "werewolf",
}


local ABILITY_OVERRIDES = {
  -- example: [29483] = "resto",
  [186191] = "arcanist",
  [186243] = "arcanist",
  [186265] = "arcanist",
  [186267] = "arcanist",
  [186203] = "arcanist",
  [61506]  = "support",
  [33524]  = "templar",
  [217608] = "scribing",
  [22228]  = "templar",
  [44013]  = "resto",
  [45518]  = "undaunted",
  [176922] = "item",
  [217469] = "scribing",
  [69773]  = "destru",
  [26824] =  "templar",
  [44391] =  "templar",
  [55677] =  "undaunted",
  [63511] =  "undaunted",
  [184634] =  "item",
  [218784] =  "resto",
  [172055] =  "item",
  [218786] =  "resto",
  [218787] =  "resto",

}


local ability_cache = {}


local USER_OVERRIDES = {}


local unknown_log = {}

local function classify_by_icon(abilityId)
  local icon = GetAbilityIcon(abilityId)
  if not icon or icon == "" then return nil end
  for _, p in ipairs(ICON_PATTERNS) do
    if string_find(icon, p[1], 1, true) then
      return p[2]
    end
  end
  return nil
end

local function classify_by_skill_tree_api(abilityId)
  local skillType, lineIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
  if not skillType or skillType <= 0 then return nil end
  local skillLineId = GetSkillLineId(skillType, lineIndex)
  if not skillLineId then return nil end
  return SKILL_LINE_TO_GROUP[skillLineId]
end

local function lookup_group(abilityId)
  if not abilityId or abilityId <= 0 then return "other" end

  local g = ability_cache[abilityId]
  if g then return g end


  g = USER_OVERRIDES[abilityId]
  if g then
    ability_cache[abilityId] = g
    return g
  end


  g = ABILITY_OVERRIDES[abilityId]
  if g then
    ability_cache[abilityId] = g
    return g
  end


  g = classify_by_icon(abilityId)
  if g then
    ability_cache[abilityId] = g
    return g
  end


  g = classify_by_skill_tree_api(abilityId)
  if g then
    ability_cache[abilityId] = g
    return g
  end


  local name = GetAbilityName(abilityId) or "?"
  local icon = GetAbilityIcon(abilityId) or "?"
  unknown_log[abilityId] = name .. "  | icon=" .. icon
  ability_cache[abilityId] = "other"
  return "other"
end


function M.print_unknown()
  local lines  = {}
  local count  = 0
  for id, info in pairs(unknown_log) do
    lines[#lines + 1] = string.format("  [%d] = \"?\",  -- %s", id, info)
    count = count + 1
  end
  if count == 0 then
    d("[skill_colors] No unclassified heal/shield abilities seen yet.")
    return
  end
  table.sort(lines)
  local header = "[skill_colors] Unclassified abilities (" .. count .. ") — add to ABILITY_OVERRIDES:"
  if Verdant.Constants.DEBUG and Verdant.CopyBox then
    Verdant.CopyBox.show("Verdant /skills", header .. "\n" .. table.concat(lines, "\n"))
  else
    d(header)
    for _, line in ipairs(lines) do d(line) end
  end
end


function M.unknown_lines()
  local lines = {}
  for id, info in pairs(unknown_log) do
    lines[#lines + 1] = string.format("  [%d] = \"?\",  -- %s", id, info)
  end
  if #lines == 0 then return { "(none — all heal/shield abilities classified)" } end
  table.sort(lines)
  table.insert(lines, 1, "add to ABILITY_OVERRIDES:")
  return lines
end

local FALLBACK = GROUP_COLORS.other

function M.has_explicit_override(abilityId)
  return USER_OVERRIDES[abilityId] ~= nil or ABILITY_OVERRIDES[abilityId] ~= nil
end

function M.get_color(abilityId)
  return GROUP_COLORS[lookup_group(abilityId)] or FALLBACK
end

function M.group_of(abilityId)
  return lookup_group(abilityId)
end

function M.group_color(group)
  return GROUP_COLORS[group] or FALLBACK
end

function M.group_names()
  local out = {}
  for k in pairs(GROUP_COLORS) do out[#out + 1] = k end
  table.sort(out)
  return out
end

function M.is_group(group)
  return GROUP_COLORS[group] ~= nil
end

function M.group_label(key)
  return GROUP_LABELS[key] or key
end


function M.groups_ordered()
  local out = {}
  for _, key in ipairs(GROUP_ORDER) do
    local c = GROUP_COLORS[key] or FALLBACK
    out[#out + 1] = { key = key, label = GROUP_LABELS[key] or key, r = c.r, g = c.g, b = c.b, a = c.a }
  end
  return out
end


function M.get_unknowns()
  local out = {}
  for id in pairs(unknown_log) do
    out[#out + 1] = { id = id, name = GetAbilityName(id) or ("#" .. id), icon = GetAbilityIcon(id) or "" }
  end
  table.sort(out, function(a, b) return a.id < b.id end)
  return out
end

function M.unknown_count()
  local n = 0
  for _ in pairs(unknown_log) do n = n + 1 end
  return n
end

function M.set_override(abilityId, group)
  if not abilityId or abilityId <= 0 or not GROUP_COLORS[group] then return false end
  USER_OVERRIDES[abilityId] = group
  ability_cache[abilityId]  = group
  unknown_log[abilityId]    = nil
  return true
end


function M.load_persisted(sv)
  if not sv then return end
  if type(sv.skill_overrides) == "table" then
    for id, group in pairs(sv.skill_overrides) do
      if type(id) == "number" then M.set_override(id, group) end
    end
  end
end


function M.group_shares(buf, now_ms, predicate)
  buf:trim(now_ms)
  local buckets = {}
  local total   = 0
  for i = buf.head, buf.tail do
    local e   = buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 and (not predicate or predicate(e)) then
      local key = lookup_group(e.ability_id)
      buckets[key] = (buckets[key] or 0) + amt
      total = total + amt
    end
  end
  if total <= 0 then return {} end
  local out = {}
  for g, amt in pairs(buckets) do
    local c = GROUP_COLORS[g] or FALLBACK
    out[#out + 1] = { r = c.r, g = c.g, b = c.b, a = c.a, share = amt / total }
  end
  table.sort(out, function(a, b) return a.share > b.share end)
  return out
end

local gs_buckets = {}

function M.group_shares_into(out, buf, now_ms, predicate)
  buf:trim(now_ms)
  for k in pairs(gs_buckets) do gs_buckets[k] = nil end
  local total = 0
  for i = buf.head, buf.tail do
    local e   = buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 and (not predicate or predicate(e)) then
      local key = lookup_group(e.ability_id)
      gs_buckets[key] = (gs_buckets[key] or 0) + amt
      total = total + amt
    end
  end
  if total <= 0 then
    out.count = 0
    return out
  end
  local n = 0
  for g, amt in pairs(gs_buckets) do
    n = n + 1
    local slot = out[n]
    if slot == nil then slot = {}; out[n] = slot end
    local c = GROUP_COLORS[g] or FALLBACK
    slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
    slot.share = amt / total
    slot.key = g   -- stable group id (string) for the hover highlight + card name
  end

  for i = 2, n do
    local key = out[i]
    local ks  = key.share
    local j   = i - 1
    while j >= 1 and out[j].share < ks do
      out[j + 1] = out[j]
      j = j - 1
    end
    out[j + 1] = key
  end
  out.count = n
  return out
end

local ab_amt = {}
local ab_grp = {}

function M.ability_shares_into(out, buf, now_ms, predicate)
  buf:trim(now_ms)
  for k in pairs(ab_amt) do ab_amt[k] = nil end
  for k in pairs(ab_grp) do ab_grp[k] = nil end
  local total = 0
  for i = buf.head, buf.tail do
    local e   = buf.entries[i]
    local amt = e.amount or 0
    if amt > 0 and (not predicate or predicate(e)) then
      local id = e.ability_id or 0
      ab_amt[id] = (ab_amt[id] or 0) + amt
      if ab_grp[id] == nil then ab_grp[id] = lookup_group(id) end
      total = total + amt
    end
  end
  if total <= 0 then
    out.count = 0
    return out
  end
  local n = 0
  for id, amt in pairs(ab_amt) do
    n = n + 1
    local slot = out[n]
    if slot == nil then slot = {}; out[n] = slot end
    local g = ab_grp[id] or "other"
    local c = GROUP_COLORS[g] or FALLBACK
    slot.id    = id
    slot.share = amt / total
    slot.key   = g
    slot.r = c.r; slot.g = c.g; slot.b = c.b; slot.a = c.a
  end
  for i = 2, n do
    local key = out[i]
    local ks  = key.share
    local j   = i - 1
    while j >= 1 and out[j].share < ks do
      out[j + 1] = out[j]
      j = j - 1
    end
    out[j + 1] = key
  end
  out.count = n
  return out
end

function M.ability_icon(id) return GetAbilityIcon(id) or "" end
function M.ability_name(id) return GetAbilityName(id) or ("#" .. tostring(id)) end
