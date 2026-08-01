eso-extGroupLeader
==================

extGroupLeader is a plugin for Elder Scrolls Online that allows you to track your group leader.

Settings
--------

**Modes**

 * **Mode: Elastic Reticle Arrows:** Your target reticle will have two additional arrows, one on the left and one on the right. The arrow indicating the direction you need to turn to face the leader will move away from the reticle.
 * **Mode: Satnav:** Similar to a car navigation system. A movable frame that points in the direction that you need to turn in order to see the group leader.
 * **Mode: Reticle Satnav:** Similar to the "Satnav" mode, however, the arrow will also rotate around the reticle.

**Colors**

 * **Color: Always White:** The arrows will remain white.
 * **Color: White-Orange-Red:** As you turn away from the leader the arrows will move from white, then orange, then red.
 * **Color: Green-Orange-Red:** As you turn away from the leader the arrows will move from green, then orange, then red.

**Settings**

 * **Setting: Targetted Opacity:** The arrows will be this opaque (as a percentage) when you are facing the leader.
 * **Setting: Behind Opacity:** The arrows will be this opaque (as a percentage) when the leader is directly behind you.
 * **Setting: Targetted Size:** The arrows will be this size when you are facing the leader.
 * **Setting: Behind Size:** The arrows will be this size when the leader is directly behind you.
 * **Setting: Targetted Distance:** The arrows will be this distance from the reticle when you are facing the leader.
 * **Setting: Behind Distance:** The arrows will be this distance from the reticle when the leader is directly behind you.
 * **Setting: Only in Cyrodiil:** This will automatically disable the arrows in PvE areas.
 * **Setting: Mimic Reticle:** This will automatically disable the arrows if the game reticle is not visible.
 * **Setting: Arrow Size:** This will control the arrow size according to the leader distance, instead of relative angle.
 * **Setting: Arrow Distance:** This will control the arrow distance according to the leader distance, instead of relative angle.

**Keybindings**

* **General - Targeting - Set Group Leader:** Will set the group leader to the person you are current targeting. *Note, this only works with group members.*

**Slash-Commands**

* **Command: /glset** Clears any custom leader.
* **Command: /glset <player name>** Sets the custom leader to the specified player name.

Contributing: Getting started
-----------------------------

**Getting started with Git and GitHub**

 * People new to GitHub should consider using [GitHub for Windows](http://windows.github.com/).
 * If you decide not to use GHFW you will need to:
  1. [Set up Git and connect to GitHub](http://help.github.com/win-set-up-git/)
  2. [Fork the DiffLib repository](http://help.github.com/fork-a-repo/)
 * Finally you should look into [git - the simple guide](http://rogerdudler.github.com/git-guide/)

**Rules for Our Git Repository**

 * We use ["A successful Git branching model"](http://nvie.com/posts/a-successful-git-branching-model/). What this means is that:
   * You need to branch off of the when creating new features or non-critical bug fixes.
   * Each logical unit of work must come from a single and unique branch:
     * A logical unit of work could be a set of related bugs or a feature.
     * You should wait for us to accept the pull request (or you can cancel it) before committing to that branch again.
   
Contributing: License
---------------------

eso-extGroupLeader uses the BSD 2-clause license, which can be found in LICENSE.txt.

**Additional Restrictions**

 * We only accept code that is compatible with the BSD license (essentially, MIT and Public Domain).
 * Copying copy-left (GPL-style) code is strictly forbidden.
