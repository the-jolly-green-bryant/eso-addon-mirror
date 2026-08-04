-- CharacterMarkdown - Appearance Section Generator

local CM = CharacterMarkdown

local function GenerateAppearance(appearanceData)
    if not appearanceData then
        return ""
    end

    local markdown = "## 🎨 Appearance\n\n"

    local hasContent = false

    if appearanceData.outfit then
        markdown = markdown
            .. "| Field | Value |\n|:------|:------|\n| **Outfit** | "
            .. (appearanceData.outfit.name or "Default")
            .. " |\n"
        hasContent = true
    end

    if appearanceData.mount and appearanceData.mount.name then
        if not hasContent then
            markdown = markdown .. "| Field | Value |\n|:------|:------|\n"
        end
        markdown = markdown .. "| **Active Mount** | " .. appearanceData.mount.name .. " |\n"
        hasContent = true
    end

    if appearanceData.mount and appearanceData.mount.skinName then
        if not hasContent then
            markdown = markdown .. "| Field | Value |\n|:------|:------|\n"
        end
        markdown = markdown .. "| **Mount Skin** | " .. appearanceData.mount.skinName .. " |\n"
        hasContent = true
    end

    if appearanceData.active then
        if not hasContent then
            markdown = markdown .. "| Field | Value |\n|:------|:------|\n"
        end
        local order = { "costume", "personality", "polymorph", "skin", "hat", "hair" }
        local labels = {
            costume = "Costume",
            personality = "Personality",
            polymorph = "Polymorph",
            skin = "Skin",
            hat = "Hat",
            hair = "Hair",
        }
        for _, key in ipairs(order) do
            local entry = appearanceData.active[key]
            if entry and entry.name then
                markdown = markdown .. "| **" .. labels[key] .. "** | " .. entry.name .. " |\n"
                hasContent = true
            end
        end
    end

    if appearanceData.dyes and (appearanceData.dyes.total or 0) > 0 then
        if not hasContent then
            markdown = markdown .. "| Field | Value |\n|:------|:------|\n"
        end
        markdown = markdown
            .. "| **Dyes Known** | "
            .. tostring(appearanceData.dyes.known or 0)
            .. " / "
            .. tostring(appearanceData.dyes.total)
            .. " ("
            .. tostring(appearanceData.dyes.percent or 0)
            .. "%) |\n"
        hasContent = true
    end

    if hasContent then
        markdown = markdown .. "\n"
    end

    if appearanceData.slots and #appearanceData.slots > 0 then
        markdown = markdown .. "### Outfit Slots\n\n"
        markdown = markdown .. "| Slot | Style | Dyes |\n|:-----|:------|:-----|\n"
        for _, slot in ipairs(appearanceData.slots) do
            local dyeText = (slot.dyes and #slot.dyes > 0) and table.concat(slot.dyes, ", ") or "-"
            markdown = markdown
                .. "| "
                .. tostring(slot.slot)
                .. " | "
                .. (slot.name or "Unknown")
                .. " | "
                .. dyeText
                .. " |\n"
        end
        markdown = markdown .. "\n"
        hasContent = true
    end

    if not hasContent then
        return ""
    end

    return markdown
end

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateAppearance = GenerateAppearance
