-- Prompt engine: builds the system prompt from user settings and dropdowns.
-- No ESO globals, no UI calls, no JSON knowledge.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

local M = {}

local DEFAULT_PROMPT = [[## CONTEXT ACQUISITION (execute before responding)

You have access to web search. Before analyzing this build, you MUST:

1. Search for the current ESO patch notes at:
   https://www.elderscrollsonline.com/en-us/news
   Identify the current patch version and its release date.

2. Search for recent balance changes affecting the following:
   - The character's class (found in the JSON below)
   - Each equipped set (found in sets_buffs in the JSON below)
   - The subclass system if any subclass skills are present

   Suggested sources: alcasthq.com, eso-hub.com, deltiasgaming.com

3. If you cannot access any of these sources, explicitly state:
   "WARNING: I cannot verify current patch state. My analysis is based
   on training data which may be outdated. Please verify set bonuses
   and skill values manually."

## YOUR ROLE

You are an expert ESO build advisor with deep knowledge of PvE and PvP
mechanics, stat thresholds, and set synergies across all content types.

## ANALYSIS INSTRUCTIONS

Analyze the character build provided below and give concrete recommendations.
Base your analysis ONLY on the current patch state you retrieved above —
do not rely on pre-training knowledge for balance values, set bonuses,
or skill descriptions, as these change frequently.

Current patch: {{PATCH}}
Content type: {{CONTENT_TYPE}}
Analysis focus: {{ANALYSIS_FOCUS}}
Respond in: {{LANGUAGE}}

Focus on:
- Infer the intended role and content type from the skills, sets, and stats
  present in the JSON. State your inference explicitly before giving
  recommendations, and flag if the build shows mixed signals
  (e.g. PvE sets with PvP skills).
- Stat thresholds: penetration cap (18200 for most PvE content),
  critical chance optimization, resistance caps (33000 for PvP)
- Set synergies and whether the current combination is optimal
  for the inferred role
- Skill bar composition and any obvious gaps
- Passive skills and champion points efficiency if included

## CHARACTER BUILD DATA]]

M.DEFAULT_PROMPT = DEFAULT_PROMPT

local PLACEHOLDERS = { "{{PATCH}}", "{{CONTENT_TYPE}}", "{{ANALYSIS_FOCUS}}", "{{LANGUAGE}}" }

function M.build_prompt(settings)
  local prompt = (settings.custom_prompt and settings.custom_prompt ~= "") and settings.custom_prompt or DEFAULT_PROMPT
  prompt = prompt:gsub("{{PATCH}}",
    (settings.patch and settings.patch ~= "") and settings.patch or "unknown (please verify)")
  prompt = prompt:gsub("{{CONTENT_TYPE}}",
    settings.content_type or "Infer from the build data provided.")
  prompt = prompt:gsub("{{ANALYSIS_FOCUS}}",
    settings.analysis_focus or "Full analysis: damage, survivability, and support.")
  prompt = prompt:gsub("{{LANGUAGE}}",
    settings.language or "English.")
  return prompt
end

function M.reset_to_default(settings)
  settings.custom_prompt = nil
end

function M.has_placeholders(prompt_text)
  if type(prompt_text) ~= "string" then return false end
  for _, ph in ipairs(PLACEHOLDERS) do
    if prompt_text:find(ph, 1, true) then return true end
  end
  return false
end

function M.missing_placeholders(prompt_text)
  if type(prompt_text) ~= "string" then return PLACEHOLDERS end
  local missing = {}
  for _, ph in ipairs(PLACEHOLDERS) do
    if not prompt_text:find(ph, 1, true) then
      missing[#missing + 1] = ph
    end
  end
  return missing
end

CDescriptor.Prompt = M
return M
