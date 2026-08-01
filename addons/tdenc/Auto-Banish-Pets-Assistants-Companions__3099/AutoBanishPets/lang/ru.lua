local stringsRU = {
    -- Name
    ABP_FENCE_NAME = "Скупщик краденого",
    ABP_RETRAIT_STATION_NAME = "Аппарат для трансмутации",
    ABP_THIEVESTROVE_NAME = "Воровской клад",
    -- Tooltip
    --ABP_BANK_TOOLTIP = "When you open a bank",
    --ABP_GUILD_BANK_TOOLTIP = "When you open a guild bank",
    --ABP_STORE_TOOLTIP = "When you open a store",
    --ABP_GUILD_STORE_TOOLTIP = "When you open a guild store",
    --ABP_FENCE_TOOLTIP = "When you open a fence",
    --ABP_CRAFT_STATION_TOOLTIP = "When you interact with a craft station",
    --ABP_RETRAIT_STATION_TOOLTIP = "When you interact with a retrait station",
    --ABP_DYEING_STATION_TOOLTIP = "When you interact with a dyeing station",
    --ABP_WAYSHRINE_TOOLTIP = "When you interact with a wayshrine",
    --ABP_THIEVESTROVE_TOOLTIP = "When you interact with a thieves trove",
    --ABP_STEAL_TOOLTIP = "When you steal",
    --ABP_VAMPIRE_TOOLTIP = "When you transform into vampire",
    --ABP_WEREWOLF_TOOLTIP = "When you transform into werewolf",
    --ABP_ARRESTED_TOOLTIP = "When you are arrested",
    --ABP_TORCHBUG_TOOLTIP = "When you interact with a torchbug",
    --ABP_QUEST_TOOLTIP = "When you recieve/complete a daily quest",
    --ABP_STEALTH_TOOLTIP = "When you crouch",
    --ABP_BEFORE_COMBAT_TOOLTIP = "When you go into combat",
    --ABP_AFTER_COMBAT_TOOLTIP = "When you finish combat",
    --ABP_LOGOUT_TOOLTIP = "When you logout",
    --ABP_EXIT_TOOLTIP = "When you exit",
    --ABP_NO_PETS_ALLOWED_NAME = "Disable your combat pets in all situations",
    -- Setting
    --ABP_NOTIFICATION_PETS = "Your combat pets were banished!",
    --ABP_NOTIFICATION_VANITY_PETS = "Your non-combat pets were banished!",
    --ABP_NOTIFICATION_ASSISTANTS = "Your assistants were banished!",
    --ABP_NOTIFICATION_COMPANIONS = "Your companions were banished!",
    --ABP_NOTIFICATION_RESUMMON_VANITY_PETS = "Your non-combat pets are back!",
    --ABP_NOTIFICATION_RESUMMON_ASSISTANTS = "Your assistants are back!",
    -- Keybind
    --SI_BINDING_NAME_BANISH_ALL = "Banish all",
    --SI_BINDING_NAME_BANISH_PETS = "Banish combat pets",
    --SI_BINDING_NAME_BANISH_VANITY_PETS = "Banish non-combat pets",
    --SI_BINDING_NAME_BANISH_ASSISTANTS = "Banish assistants",
    --SI_BINDING_NAME_BANISH_COMPANIONS = "Banish companions",
    --SI_BINDING_NAME_NO_PETS_ALLOWED = "Toggle 'NO-PETS-ALLOWED'",
}

for stringId, stringValue in pairs(stringsRU) do
    SafeAddString(_G[stringId], stringValue, 1)
end