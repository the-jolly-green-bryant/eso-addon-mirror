local strings = {
    HELLOTAMRIEL_HELLO = "Hello, {name}! Welcome to The Elder Scrolls Online.",
    HELLOTAMRIEL_ZONE_WELCOME = "Welcome to {zone}, {name}!",
    HELLOTAMRIEL_GUILD_GREETING_EXAMPLE = "Good evening guild members, how are we today?",
    HELLOTAMRIEL_RECRUITER_EXAMPLE = "Looking for a guild? Whisper me for an invite!",
    HELLOTAMRIEL_CUSTOM1_EXAMPLE = "Hello from Custom Guild Message 1!",
    HELLOTAMRIEL_CUSTOM2_EXAMPLE = "Hello from Custom Guild Message 2!",
    HELLOTAMRIEL_CUSTOM3_EXAMPLE = "Hello from Custom Guild Message 3!",

    HELLOTAMRIEL_USE_CHARACTER = "Use Character Specific Settings",
    HELLOTAMRIEL_USE_CHARACTER_TIP = "Enable to use settings only for this character. Disable to use account-wide settings.",
    HELLOTAMRIEL_ENABLE_GREETING = "Enable Greeting",
    HELLOTAMRIEL_ENABLE_GREETING_TIP = "Toggle the greeting message on login.",
    HELLOTAMRIEL_WELCOME_MSG = "Welcome Message",
    HELLOTAMRIEL_WELCOME_MSG_TIP = "Set your custom welcome message. Use {name} for your character's name and {zone} for the current zone.",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME = "Enable Zone Welcome Message",
    HELLOTAMRIEL_ENABLE_ZONE_WELCOME_TIP = "Toggle the welcome message when entering a new zone.",
    HELLOTAMRIEL_ZONE_WELCOME_MSG = "Zone Welcome Message",
    HELLOTAMRIEL_ZONE_WELCOME_MSG_TIP = "Set your custom zone welcome message. Use {name} for your character's name and {zone} for the new zone.",

    HELLOTAMRIEL_AUTO_FILL_GREETING = "Auto-Fill Guild Greeting",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING = "Enable Auto-Fill Guild Greeting",
    HELLOTAMRIEL_ENABLE_AUTO_FILL_GREETING_TIP = "If enabled, automatically fills your chat box with a configurable message to the selected guild when you log in, but only if enough time has passed since last use.",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG = "Auto-Fill Guild Greeting Message",
    HELLOTAMRIEL_AUTO_FILL_GREETING_MSG_TIP = "Message to auto-fill in chat. Example: Good evening guild members, how are we today?",
    HELLOTAMRIEL_AUTO_FILL_MINUTES = "Minimum Minutes Between Auto-Fills",
    HELLOTAMRIEL_AUTO_FILL_MINUTES_TIP = "Minimum interval in minutes before the chat greeting will fill again (default: 1440 = 24 hours).",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL = "Select Guild for Auto-Fill",
    HELLOTAMRIEL_SELECT_GUILD_AUTO_FILL_TIP = "Select the guild you would like to auto populate to. This will only auto fill the first selected guild when you log in or reload. Use the up arrow in chat to quickly repeat the message to additional guilds.",

    HELLOTAMRIEL_GUILD_SLOT = "Guild Slot",

    HELLOTAMRIEL_GUILD_RECRUITER = "Guild Recruiter",
    HELLOTAMRIEL_ENABLE_RECRUITER = "Enable Guild Recruiter Mode",
    HELLOTAMRIEL_ENABLE_RECRUITER_TIP = "When enabled (or by typing /guildrecruiter), your recruitment message will auto-fill the zone chat box every time you enter a new zone.",
    HELLOTAMRIEL_RECRUITER_MSG = "Recruiter Message",
    HELLOTAMRIEL_RECRUITER_MSG_TIP = "The message to auto-fill when entering a zone. Example: Looking for a guild? Whisper me for an invite!",
    HELLOTAMRIEL_RECRUITER_ENABLED = "Guild Recruiter mode ENABLED. Your recruitment message will auto-fill each time you change zones.",
    HELLOTAMRIEL_RECRUITER_DISABLED = "Guild Recruiter mode DISABLED.",

    HELLOTAMRIEL_CUSTOM_GUILD_MESSAGES = "Custom Guild Whisper Messages",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM = "Select Guild For Custom Whisper Messages",
    HELLOTAMRIEL_SELECT_GUILD_CUSTOM_TIP = "Only members of this guild will trigger the custom whisper messages when you whisper them from the roster.",

    HELLOTAMRIEL_ENABLE_CUSTOM1 = "Enable Custom Guild Message 1",
    HELLOTAMRIEL_ENABLE_CUSTOM1_TIP = "Enable to auto-fill your whisper message with this text when whispering to a guild member. Toggle with /guildcustom1.",
    HELLOTAMRIEL_CUSTOM1_MSG = "Custom Guild Message 1",
    HELLOTAMRIEL_CUSTOM1_MSG_TIP = "The message to auto-fill (1).",
    HELLOTAMRIEL_CUSTOM1_STATUS = "Custom Guild Message 1 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM2 = "Enable Custom Guild Message 2",
    HELLOTAMRIEL_ENABLE_CUSTOM2_TIP = "Enable to auto-fill your whisper message with this text when whispering to a guild member. Toggle with /guildcustom2.",
    HELLOTAMRIEL_CUSTOM2_MSG = "Custom Guild Message 2",
    HELLOTAMRIEL_CUSTOM2_MSG_TIP = "The message to auto-fill (2).",
    HELLOTAMRIEL_CUSTOM2_STATUS = "Custom Guild Message 2 %s",

    HELLOTAMRIEL_ENABLE_CUSTOM3 = "Enable Custom Guild Message 3",
    HELLOTAMRIEL_ENABLE_CUSTOM3_TIP = "Enable to auto-fill your whisper message with this text when whispering to a guild member. Toggle with /guildcustom3.",
    HELLOTAMRIEL_CUSTOM3_MSG = "Custom Guild Message 3",
    HELLOTAMRIEL_CUSTOM3_MSG_TIP = "The message to auto-fill (3).",
    HELLOTAMRIEL_CUSTOM3_STATUS = "Custom Guild Message 3 %s",

    HELLOTAMRIEL_ENABLED = "ENABLED",
    HELLOTAMRIEL_DISABLED = "DISABLED",
}
for id, value in pairs(strings) do
    ZO_CreateStringId(id, value)
end