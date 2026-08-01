local LTF = LibTextFormat

LTF.CoreProtocols = LTF.CoreProtocols or { ["v1"] = {} }

LTF.ProtocolMeta = LTF.ProtocolMeta or {
    tocsv = { consumes = "table", produces = "string" },
    fromcsv = { consumes = "string", produces = "table" },
}

LTF.CoreProtocols["v1"]["tocsv"] = function(ctx, value, part)
  value = value or ctx.scope:Get(part)

  assert(value, LTF.error(" Value passed with the tocsv key is either empty or there is no tocsv key."))
  assert(type(value) == "table", LTF.error(" Value passed to the tocsv key is not a table."))

  -- Empty values are permitted
  if LTF.IsEmpty(value) then
    return {}
  end

  local sep = ctx.scope:Get("pathSep") or ","
  local recordSep = ctx.scope:Get("recordSep") or "\n"

  local out = ""

  if #value > 0 then
    for i = 1, #value do
      local record = table.concat(value[i], sep)
      out = out..recordSep..record
    end
  end
  return out
end

LTF.CoreProtocols["v1"]["fromcsv"] = function(ctx, text, part)
    text = text or ctx.scope:Get(part)

    assert(text, LTF.error(" No variable with fromcsv key detected."))
    assert(type(text) == "string", LTF.error(" Value passed to the fromcsv key is not a string."))

    -- Empty values are permitted
    if LTF.IsEmpty(text) then
      return {}
    end

    local sep = ctx.scope:Get("pathSep") or ","
    local recordSep = ctx.scope:Get("recordSep") or "\n"

    -- split text into records
    local records = {}
    local pos = 1

    while pos <= #text do
        local rsep_pos = text:find(recordSep, pos, true)
        if rsep_pos then
            table.insert(records, text:sub(pos, rsep_pos - 1))
            pos = rsep_pos + #recordSep
        else
            table.insert(records, text:sub(pos))
            break
        end
    end

    -- parse each record into fields
    local result = {}
    for _, record in ipairs(records) do
        table.insert(result, parseFields(record, sep))
    end

    return result
end

