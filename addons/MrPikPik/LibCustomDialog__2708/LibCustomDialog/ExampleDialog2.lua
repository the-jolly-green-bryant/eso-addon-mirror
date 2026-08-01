LibCustomDialog.TEST_DIALOG_2 = {
    speaker = "Optionspanel",
    text = "Welcome to the configuration panel. What do you want to configure?",
    options = {
        [1] = {
            text = "General Settings",
            nextDialog = {
                speaker = "General Settings",
                text = "Please select the number you want for this setting.",
                options = {
                    [1] = {
                        text = "1",
                        callback = function()
                            --MyAddon.SetSetting(1)
                        end,
                        endDialog = true,
                    },
                    [2] = {
                        text = "2",
                        callback = function()
                            --MyAddon.SetSetting(2)
                        end,
                        endDialog = true,
                    },
                    [3] = {
                        text = "4",
                        callback = function()
                            --MyAddon.SetSetting(4)
                        end,
                        endDialog = true,
                    },
                },
            },
        },
        [2] = {
            text = "All Settings",
            callback = function() 
                --MyAddon.WreckSettings()
            end,
            nextDialog = {
                speaker = "Mad Machine",
                text = "Nope, I reset your settings for that",
            }
        },
        [3] = {
            text = "Setup yourself >:C",
            decorator = LibCustomDialog.DECORATOR_INTIMIDATE,
            important = true,
            nextDialog = {
                speaker = "Optionspanel",
                text = "Wow...",
            }
        },
        [4] = {
            text = "Tell me a joke",
            decorator = LibCustomDialog.DECORATOR_PERSUADE,
            important = true,
            nextDialog = {
                speaker = "Joker",
                text = "Fine.\n\nKnock knock...",
                options = {
                    [1] = {
                        text = "Who's there?",
                        important = true,
                        nextDialog = {
                            speaker = "Joker",
                            text = "Tank.",
                            options = {
                                [1] = {
                                    text = "Tank who?",
                                    nextDialog = {
                                        speaker = "Joker",
                                        text = "You're welcome.\n\nHa. Got em!",
                                    }
                                },
                                [2] = {
                                    text = "Thank you",
                                    decorator = LibCustomDialog.DECORATOR_INTIMIDATE,
                                    endDialog = true,
                                },
                            }
                        },
                    },
                    [2] = {
                        text = "We're not buying.",
                        important = true,
                        decorator = LibCustomDialog.DECORATOR_PERSUADE,
                        endDialog = true,
                    },
                },
            }
        },
    },
}