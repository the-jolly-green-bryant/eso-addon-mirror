
## WeaponSprintSensitivityFix

By bluebuiy.

This is an eso addon.

### Description

There's a feature in eso where camera look sensitivity is reduced while sprinting with weapons unsheathed/equipped.  This addon fixes this feature.

It only works if your sprint button is shift.  Alt, Control, and Caps Lock are possible but not implemented.  Cannot work for gamepad.

There is one limitation.  The IsWeaponSheathed api does not align exactly to when the sensitivity changes are applied by the game, so when sheathing while sprinting the sensitivity will be lower than it should be while the animation plays.

