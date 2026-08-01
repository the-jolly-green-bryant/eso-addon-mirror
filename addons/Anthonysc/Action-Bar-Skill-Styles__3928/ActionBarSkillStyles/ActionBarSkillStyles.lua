ActionBarSkillStyles =
{
    name = "ActionBarSkillStyles";
    version = "0.0.4";
};

local MIN_INDEX = 3; -- first ability index
local MAX_INDEX = 7; -- last ability index
local ULT_INDEX = 8; -- ultimate slot index

local destroSkills =
{
    [28858] = { type = 1; morph = 1 }; -- wall of elements
    [28807] = { type = 1; morph = 1 }; -- fire
    [28849] = { type = 1; morph = 1 }; -- ice
    [28854] = { type = 1; morph = 1 }; -- shock

    [39011] = { type = 1; morph = 2 }; -- elemental blockade
    [39012] = { type = 1; morph = 2 }; -- fire
    [39028] = { type = 1; morph = 2 }; -- ice
    [39018] = { type = 1; morph = 2 }; -- shock

    [39052] = { type = 1; morph = 3 }; -- unstable wall of elements
    [39053] = { type = 1; morph = 3 }; -- fire
    [39067] = { type = 1; morph = 3 }; -- ice
    [39073] = { type = 1; morph = 3 }; -- shock

    [29091] = { type = 2; morph = 1 }; -- destructive touch
    [29073] = { type = 2; morph = 1 }; -- fire
    [29078] = { type = 2; morph = 1 }; -- ice
    [29089] = { type = 2; morph = 1 }; -- shock

    [38937] = { type = 2; morph = 2 }; -- destructive reach
    [38944] = { type = 2; morph = 2 }; -- fire
    [38970] = { type = 2; morph = 2 }; -- ice
    [38978] = { type = 2; morph = 2 }; -- shock

    [38984] = { type = 2; morph = 3 }; -- destructive clench
    [38985] = { type = 2; morph = 3 }; -- fire
    [38989] = { type = 2; morph = 3 }; -- ice
    [38993] = { type = 2; morph = 3 }; -- shock

    [28800] = { type = 3; morph = 1 }; -- impulse
    [28794] = { type = 3; morph = 1 }; -- fire
    [28798] = { type = 3; morph = 1 }; -- ice
    [28799] = { type = 3; morph = 1 }; -- shock

    [39143] = { type = 3; morph = 2 }; -- elemental ring
    [39145] = { type = 3; morph = 2 }; -- fire
    [39146] = { type = 3; morph = 2 }; -- ice
    [39147] = { type = 3; morph = 2 }; -- shock

    [39161] = { type = 3; morph = 3 }; -- pulsar
    [39162] = { type = 3; morph = 3 }; -- fire
    [39163] = { type = 3; morph = 3 }; -- ice
    [39167] = { type = 3; morph = 3 }; -- shock

    [83619] = { type = 4; morph = 1 }; -- elemental storm
    [83625] = { type = 4; morph = 1 }; -- fire
    [83628] = { type = 4; morph = 1 }; -- ice
    [83630] = { type = 4; morph = 1 }; -- shock

    [83642] = { type = 4; morph = 2 }; -- eye of the storm
    [83682] = { type = 4; morph = 2 }; -- fire
    [83684] = { type = 4; morph = 2 }; -- ice
    [83686] = { type = 4; morph = 2 }; -- shock

    [84434] = { type = 4; morph = 3 }; -- elemental rage
    [85126] = { type = 4; morph = 3 }; -- fire
    [85128] = { type = 4; morph = 3 }; -- ice
    [85130] = { type = 4; morph = 3 }; -- shock
};

local idsForStaff =
{
    [1] =
    {     -- wall morphs
        [1] =
        { -- wall of elements
            [WEAPONTYPE_NONE] = 28858;
        };
        [2] =
        { -- elemental blockade
            [WEAPONTYPE_NONE] = 39011;
        };
        [3] =
        { -- unstable wall of elements
            [WEAPONTYPE_NONE] = 39052;
        };
    };
    [2] =
    { -- touch / reach / clench
        [1] =
        {
            [WEAPONTYPE_NONE] = 29091;
        };
        [2] =
        {
            [WEAPONTYPE_NONE] = 38937;
        };
        [3] =
        {
            [WEAPONTYPE_NONE] = 38984;
        };
    };
    [3] =
    { -- impulse / ring / pulsar
        [1] =
        {
            [WEAPONTYPE_NONE] = 28800;
        };
        [2] =
        {
            [WEAPONTYPE_NONE] = 39143;
        };
        [3] =
        {
            [WEAPONTYPE_NONE] = 39161;
        };
    };
    [4] =
    { -- storm / eye / rage
        [1] =
        {
            [WEAPONTYPE_NONE] = 83619;
        };
        [2] =
        {
            [WEAPONTYPE_NONE] = 83642;
        };
        [3] =
        {
            [WEAPONTYPE_NONE] = 84434;
        };
    };
};

local styleFix =
{
    -- Arcanist, Stam Cost Abilities
    [193331] = 185805; -- Fatecarver
    [193398] = 186366; -- Pragmatic Fatecarver
    [193397] = 183122; -- Exhausting Fatecarver
    [198282] = 183261; -- Runemend
    [198288] = 186189; -- Evolving Runemend
    [198292] = 186191; -- Audacious Runemend
    [188658] = 185794; -- Runeblades
    [188780] = 182977; -- Escalating Runeblades
    [188787] = 185803; -- Writhing Runeblades

    -- Arcanist, Mag Cost Abilities
    [185805] = 185805; -- Fatecarver
    [186366] = 186366; -- Pragmatic Fatecarver
    [183122] = 183122; -- Exhausting Fatecarver
    [183261] = 183261; -- Runemend
    [186189] = 186189; -- Rvolving Runemend
    [186191] = 186191; -- audacious runemend
    [185794] = 185794; -- Runeblades
    [182977] = 182977; -- Escalating Runeblades
    [185803] = 185803; -- Writhing Runeblades
};

---@param index integer
---@param bar HotBarCategory
local function GetSlotBoundAbilityId(index, bar)
    bar = bar or GetActiveHotbarCategory();
    local id = GetSlotBoundId(index, bar);
    local actionType = GetSlotType(index, bar);
    if actionType == ACTION_TYPE_CRAFTED_ABILITY then
        id = GetAbilityIdForCraftedAbilityId(id);
    end;
    return id;
end;

---@param id integer
local function GetBaseIdForDestroSkill(id)
    local destroBaseId;
    local skill1 = destroSkills[id];
    local skill2 = idsForStaff[skill1.type][skill1.morph];

    if skill2[WEAPONTYPE_NONE]
    then
        destroBaseId = skill2[WEAPONTYPE_NONE];
    else
        destroBaseId = id;
    end;
    return destroBaseId;
end;

---@param abilityId integer
function GetSkillStyleIconForAbilityId(abilityId)
    if destroSkills[abilityId] then
        abilityId = GetBaseIdForDestroSkill(abilityId);
    elseif styleFix[abilityId] then
        abilityId = styleFix[abilityId];
    end;
    local skillType, skillLineIndex, skillIndex = GetSpecificSkillAbilityKeysByAbilityId(abilityId);
    local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex);
    local collectibleId = GetActiveProgressionSkillAbilityFxOverrideCollectibleId(progressionId);
    if not collectibleId or collectibleId == 0 then return nil; end;
    local collectibleIcon = GetCollectibleIcon(collectibleId);
    return collectibleIcon;
end;

-- * GetSlotTexture(*luaindex* _actionSlotIndex_, *[HotBarCategory|#HotBarCategory]:nilable* _hotbarCategory_)
-- ** _Returns:_ *string* _texture_, *string* _weapontexture_, *string* _activationAnimation_

local orgGetSlotTexture = GetSlotTexture;
---@param slotId integer
---@param hotbarCategory HotBarCategory
SecurePostHook("GetSlotTexture", function (slotId, hotbarCategory)
    if hotbarCategory then
        local slotBoundAbilityId = GetSlotBoundAbilityId(slotId, hotbarCategory);
        local collectibleOverrideTexture = GetSkillStyleIconForAbilityId(slotBoundAbilityId);
        local texture, weapontexture, activationAnimation = orgGetSlotTexture(slotId, hotbarCategory);
        if collectibleOverrideTexture then
            return collectibleOverrideTexture, weapontexture, activationAnimation;
        else
            return texture, weapontexture, activationAnimation;
        end;
    else
        return orgGetSlotTexture(slotId, hotbarCategory);
    end;
end);

function AssignSlotStyledAbilityIconTexture(_, slotId, hotbarCategory)
    local btn = ZO_ActionBar_GetButton(slotId);
    if btn then
        local abilityId = GetSlotBoundAbilityId(slotId, hotbarCategory);
        local icon = GetSkillStyleIconForAbilityId(abilityId) or GetAbilityIcon(abilityId);
        btn.icon:SetTexture(icon);
    end;
end;

local function SkillStyleCollectibleUpdated(_, collectibleId)
    for slot = MIN_INDEX, ULT_INDEX do
        AssignSlotStyledAbilityIconTexture(nil, slot, GetActiveHotbarCategory());
    end;
end;

local function OnAddOnLoaded(eventCode, addonName)
    if addonName == ActionBarSkillStyles.name then
        --EVENT_MANAGER:RegisterForEvent(NAME, EVENT_ACTION_SLOT_UPDATED, AssignSlotStyledAbilityIconTexture);
        EVENT_MANAGER:RegisterForEvent(ActionBarSkillStyles.name, EVENT_COLLECTIBLE_UPDATED, SkillStyleCollectibleUpdated);
        EVENT_MANAGER:UnregisterForEvent(ActionBarSkillStyles.name, EVENT_ADD_ON_LOADED);
    end;
end;

EVENT_MANAGER:RegisterForEvent(ActionBarSkillStyles.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded);
