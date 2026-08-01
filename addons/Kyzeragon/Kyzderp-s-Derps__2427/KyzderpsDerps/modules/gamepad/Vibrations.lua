local KD = KyzderpsDerps

local function ColorNumber(motorValue)
    motorValue = motorValue or 0
    return string.format("|cFF%02x00%f|r", math.floor((1 - motorValue) * 255), motorValue)
end

local function MySetGamepadVibration(duration, firstMotor, secondMotor, thirdMotor, fourthMotor, debugSourceInfo)
    if (duration > 0) then
        KD:dbg(string.format("%d - %s %s %s %s - " .. tostring(debugSourceInfo),
            duration,
            ColorNumber(firstMotor),
            ColorNumber(secondMotor),
            ColorNumber(thirdMotor),
            ColorNumber(fourthMotor)))
    end
end

function KD.InitializeVibrations()
    if (KD.savedOptions.general.experimental) then
        ZO_PreHook("SetGamepadVibration", MySetGamepadVibration)
    end
end
