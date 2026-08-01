-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
Dice = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
Dice.name = "Dice"

-- Next we create a function that will initialize our addon
function Dice:Initialize()
    SLASH_COMMANDS['/roll'] = Dice.Roll
end

function Dice.OnAddOnLoaded(event, addonName)
  if addonName == Dice.name then
    Dice:Initialize()
  end
end

function Dice.Roll(extra)
    d("You rolled "..math.max(1, math.floor((math.random()*extra)+0.5)));
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(Dice.name, EVENT_ADD_ON_LOADED, Dice.OnAddOnLoaded)
