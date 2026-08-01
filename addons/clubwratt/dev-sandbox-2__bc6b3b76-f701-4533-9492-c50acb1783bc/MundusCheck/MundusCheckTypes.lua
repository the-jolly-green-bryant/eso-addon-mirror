---@meta MundusCheckTypes
---@diagnostic disable: duplicate-doc-field, duplicate-set-field
-- Lint-only type stubs; this file is intentionally NOT listed in the manifest.

---@type Control
GuiRoot = {}

---@class LabelControl:Control
---@field SetText fun(self: LabelControl, text: string)
---@field SetFont fun(self: LabelControl, font: string)
---@field SetColor fun(self: LabelControl, r: number, g: number, b: number, a: number)
---@field SetWrapMode fun(self: LabelControl, wrapMode: integer)
---@field SetHorizontalAlignment fun(self: LabelControl, alignment: integer)

-- The live API allows omitting casterUnitTag; the bundled stubs mark it required.
---@param abilityId integer
---@param casterUnitTag string|nil
---@return string abilityName
function GetAbilityName(abilityId, casterUnitTag) end
