Better Buffs v0.3.11

Raid Effect Intelligence for ESO group PvE.
Created by BMGxSancho.

Core architecture:
ESO events -> Combat Context -> one Effect Runtime -> one canonical effect cache -> Analytics/API/UI.

v0.3.11 adds:
- Feeding Frenzy (131353)
- Sul-Xan's Torment candidate proc tracking (154737)
- Gear Sets settings category
- Analytics Stats Module: Current Pen, Crit Chance, Crit Damage
- Character-specific Stats Module position/scale/opacity
- Self / Group (Future) / Hidden visibility
- Yellow/green/red cap guidance

Current Pen accuracy rule:
Better Buffs never guesses a variable resistance-reduction magnitude. Fixed verified reductions are included when active on the current boss. If a variable tracked reduction such as Crusher or Roar of Alkosh is active, the displayed value receives an asterisk and remains yellow.
