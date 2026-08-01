-- Converts a transformed Lua table to a JSON string.
-- Depends on CDescriptor.JSON (lib/json.lua). No business logic here.
CDescriptor = CDescriptor or {}
local CDescriptor = CDescriptor

local M = {}

function M.serialize(data, prompt_text)
  local json = CDescriptor.JSON
  assert(json, "CDescriptor.JSON not loaded")
  local json_str = json.encode(data, true)
  if prompt_text and prompt_text ~= "" then
    return prompt_text .. "\n\n" .. json_str
  end
  return json_str
end

CDescriptor.Serializer = M
return M
