QuickMarker - Survey Map Distance Helper

DESCRIPTION
-----------
QuickMarker helps you find the optimal distance for resource pins to refresh when farming survey maps. Place 3D markers in the world to measure distances, automatically open survey containers, and track your survey farming statistics with profit/loss analysis.

NEW IN VERSION 1.6:
- Nirncrux tracking (Fortified and Potent) for Craglorn surveys
- Collapsible statistics view (click [+]/[-] to expand/collapse)
- Increased tracking range from 30m to 50m
- Faster node detection (1 second timeout)
- Better handling of rare low-quantity drops

NEW IN VERSION 1.5:
- Statistics tracking system (surveys used, materials collected)
- Statistics UI window with profit/loss analysis
- Arkadius Trade Tools integration for real market prices
- Fallback prices for users without ATT
- Commands: /qmstats, /qmclearstats or keybind

NEW IN VERSION 1.4:
- Survey count display above base markers (shows how many surveys you have)
- Multi-digit support for 10+ surveys
- Smart marker visibility (stays visible while collecting nodes)
- Fixed all jewelry survey detection

NEW IN VERSION 1.3:
- Survey location database with 200+ locations
- Node counter (tracks 6 nodes per survey)
- Automatic survey detection
- Markers only appear when you have the survey

NEW IN VERSION 1.1:
- Distance display on range markers (shows meters above marker)
- Automatic survey container opener (keybind or command)
- Improved performance with texture atlas system


HOW IT WORKS
------------
The addon uses two types of markers:

BASE MARKERS:
- Mark your starting position or survey node location
- Automatically detects nearby survey locations
- Shows survey count above marker (e.g., "15" for 15 surveys)
- Shows node counter below marker (6 → 0 as you collect)
- Color changes: WHITE (nodes remain) → BLUE (all collected)
- Only one base marker per survey location
- Visible up to 200 meters
- Only visible when you have the survey in inventory

RANGE MARKERS:
- Mark positions at various distances from your base
- Show distance to nearest base above the marker (e.g., "75m")
- Change color dynamically based on distance to nearest base:
  * GREEN (0-35m): Close range
  * YELLOW (35-70m): Medium range
  * RED (70-100m): Long range
  * PURPLE (100m+): Very long range
  * GRAY: No base within 300m
- Multiple range markers can be placed
- Linked to base marker survey

SURVEY FEATURES:
- Automatic node counting for all 6 craft types
- Survey count display (supports 1-999+ surveys)
- Smart visibility (markers stay visible while collecting)
- Works with: Alchemy, Blacksmithing, Clothier, Enchanting, Jewelry, Woodworking

STATISTICS TRACKING (NEW):
- Automatically tracks surveys used and materials collected
- Tracks Nirncrux (Fortified and Potent) from Craglorn surveys
- Shows profit/loss analysis per craft type
- Collapsible view: click [+] to expand, [-] to collapse each profession
- Displays real market prices from Arkadius Trade Tools (yellow)
- Fallback prices for users without ATT (gray)
- Filter by craft type, view totals, clear statistics
- Open with /qmstats or keybind
- 50m tracking range for better coverage

SURVEY CONTAINER OPENER:
- Automatically opens all Unidentified Survey Report containers
- Works with all craft types (Alchemist, Blacksmith, Clothier, Enchanter, Jewelry, Woodworker)
- Commands: /qmsurvey to start, /qmstop to stop


FEATURES
--------
- 3D markers visible in game world
- Markers scale with distance for better visibility
- Visible through walls and terrain
- Zone-specific - markers only appear in the zone where they were created
- Account-wide storage - markers persist across characters
- Easy deletion - remove nearest marker with a keybind
- Statistics tracking with profit/loss analysis


KEYBINDS
--------
Set up keybinds in ESO Settings > Controls > Quick Marker:
- Place Base - Create a base marker at current position
- Place Range - Create a range marker at current position
- Delete nearest marker - Remove the closest marker within 10m
- Open Survey Containers - Start opening all survey containers
- Show Statistics Window - Open statistics window (NEW)


COMMANDS
--------
/qmsurvey - Start opening all survey containers
/qmstop - Stop survey opening process
/qmstats - Open statistics window
/qmclearstats confirm - Clear all statistics
/qmdebug - Display debug information
/qmtest [base|range] - Create a test marker at your current position
/qmcoords - Get current world coordinates
/qmprices - Extract ATT prices (for developers)
/qmnames - Verify item names and IDs (for developers)


USE CASE EXAMPLE
----------------
1. Find a resource node from a survey map
2. Press your "Place Base" keybind to mark the node location
3. Run away in different directions
4. Press "Place Range" keybind at various distances
5. The markers will show you the exact distances with color coding
6. Find the optimal distance where resource pins refresh (typically 70-100m)
7. Check /qmstats to see your profit/loss from survey farming


TECHNICAL NOTES
---------------
- Markers are stored with world coordinates and zone ID
- Visibility range: 200 meters
- Tracking range for survey nodes: 50 meters (increased from 30m in v1.6)
- Search range for base detection: 300 meters
- Delete range: 10 meters
- Coordinates stored in centimeters (ESO standard)
- Updates every frame for smooth rendering
- Statistics stored in SavedVariables (account-wide)
- Optional integration with Arkadius Trade Tools for prices


DISCLAIMER
----------
I am not a professional coder. This addon is provided "as is" without any warranties or guarantees. It works for my needs, and I hope it helps you too. Use at your own risk.

