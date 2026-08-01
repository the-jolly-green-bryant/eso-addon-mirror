-- CharacterMarkdown - Markdown Formatter
-- Redirects to the modular, unified markdown generation engine

local CM = CharacterMarkdown

CM.formatters = CM.formatters or {}

-- Redirect to generators/Markdown.lua to prevent split-brain behavior
CM.formatters.GenerateMarkdown = function(...)
    if CM.generators and CM.generators.GenerateMarkdown then
        return CM.generators.GenerateMarkdown(...)
    else
        CM.Error("Modular generator engine not loaded!")
        return ""
    end
end
