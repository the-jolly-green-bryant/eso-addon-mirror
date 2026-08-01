--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.PlaySoundForSpecialItem(soundName, volumeLevel)

    -- In order to increase the volume level, play the sound multiple times in a row
    for i = 1, volumeLevel do

        PlaySound(SOUNDS[soundName])

    end

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.GetIndexOfSound(soundName)

    -- Using the sound name, locate the matching index value and return the result
    for i, name in ipairs(ItemAlert.Sounds) do

        if name == soundName then

            return i

        end

    end

    return 0

end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
function ItemAlert.UpdateSounds()

    if SOUNDS then

        for soundName, _ in pairs(SOUNDS) do

            if soundName ~= "NONE" then

                table.insert(ItemAlert.Sounds, soundName)

            end

        end

        if #ItemAlert.Sounds > 0 then

            table.sort(ItemAlert.Sounds)
            table.insert(ItemAlert.Sounds, 1, "NONE")

        end

    end

end