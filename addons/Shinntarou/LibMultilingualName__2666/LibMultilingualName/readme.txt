InGame-Name-Data files for languages.(en, de, fr, jp, ru, es), and PowerShell script file that build them from your ESO client.
Please choose languages what you need at in-game "ADD-ONS" menu.

Your client's current language of the LIB for the language is required in a few cases.
(It means if you are English player, please activate LibMultilingual_en at least.)

The Lib is a simple huge LUA table files created by dump data from EsoExtractData.
You can create and update dump files manually using setup.ps1 in the lib directory.

Get**** methods just only to get from the table.
Search**** methods have own data processing.
Correctness of these results are not guaranteed, especially Search**** methods.

[b]methods overview[/b]

ItemName
SetItemName
SkillName(abilityName)
AbilityDescription
QuestName
QuestTaskName
ZoneName
SetItemIDtoAbilityID (not dumped data. manually created and tweaked.)

[b]usage[/b]

The LIB has two interface pattern.

1. GetRaw****Name(langCode, id)

it simply return "gamedata/**.csv"'s value as-is including special chars.

[CODE]
[44955]="pauldron^p",[44956]="sabatons^p",
[/CODE]
if NotFound, parameter is Invalid, then return bool false.

2. Get****Name(langCode, id)

(I wish) it return formatted value depending on what value it is.

[CODE]
    local name = LIB.GetRawItemName(langCode, id)
    if name then
        return ZO_CachedStrFormat("<<C:1>>", name)
    else 
        return "NotFound. Lang Code ".. langCode .. " Id " .. id
    end
[/CODE]
If NotFound etc, then return some strings by any means possible.

3. SearchSetItemBonus(langCode, id, itemLink): string description, bool isMatched

!!! BETA

1. the AddOn search abilities which has same name as the set gears. (It's \Raw\SetItemIdToAbilityIds.lua)
2. itemLink has a correct description.(but, It's in your current langCode)
3. SearchMethod compares 1 with 2. if matched, then return the matched abilities.
4. if not matched, SearchMethod return all abilities (= 1), and also return itMatched is FALSE as secound returned value.


[b]Powershell Scripts[/b]

setup.ps1

For addon developers and players having fair knowledge of PowerShell.
This one build up all GetRaw****_**.lua files.
please read console message so it is a dialogue script.

fakeLang.ps1

to create ESO user-defined language code(files) from existing lang code.
a user-defined lang code can be used in game.
e.g) /script SetCVar('language.2','ja')

addonLangFilesReproducer.ps1

to copy new langFiles from your existing add-ons.
e.g) if there is a file Addons/SomeAddon/en.lua , the batch reproduce Addons/SomeAddon/jp.lua from en.lua.


[b]external libaries[/b]

# EsoExtractData
# @see https://www.esoui.com/downloads/info1258-EsoExtractData.html

# ESO - Japanese Localization (reference data)
# @see https://www.esoui.com/downloads/info2154-ESO-JapaneseLocalization.html
