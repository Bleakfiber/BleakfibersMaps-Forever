# BleakfibersMaps-Forever Master Changelog

All notable changes to the **BleakfibersMaps-Forever** addon will be documented in this file.
The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

---

## Release Quick Links
- [v1.0.05 (2026-10-07)](#v1005---2026-10-07)
- [v1.0.04 (2026-10-05)](#v1004---2026-10-05)
- [v1.0.03 (2026-10-05)](#v1003---2026-10-05)
- [v1.0.02 (2026-10-05)](#v1002---2026-10-05)
- [v1.0.01 (2026-10-05)](#v1001---2026-10-05)

---

## [v1.0.05] - 2026-10-07

**Target Client:** World of Warcraft Forever (Interface 16001)  
**Detailed Notes:** [changelogs/v1.0.05.md](changelogs/v1.0.05.md)

### Added
- **Bleakfiber Addon Suite Design Guide Standardization**:
  - **Profile Management System (`Core/Config.lua`, `Core/ConfigUI.lua`)**: Multi-profile storage (`activeProfile`, `profiles`), dynamic switching, profile duplication/deletion/reset, and seamless backward-compatibility auto-migration for legacy flat databases.
  - **Unified Movers Contract (`Core/Init.lua`, `Modules/Minimap/SquareMinimap.lua`)**: `ToggleMovers`, `IsMoversUnlocked`, and `ResetMovers` standardized across the addon and registered into `_G.Bleakfibers_MoversRegistry["BleakfibersMaps"]`.
  - **Standalone Window Movers Button (`Core/ConfigUI.lua`)**: Added dedicated "Toggle Movers" button to the standalone configuration window title bar.
  - **Master Config Hub (`/bac`) Integration Upgrade**: Implemented synchronized profile callbacks (`GetCurrent`, `SetCurrent`, `List`, `Create`, `Delete`, `Copy`, `Reset`) and mover callbacks in module registration.
  - **Expanded Slash Commands**: Added `/bfm movers`, `/bfm profile <list|set|create|delete>`, and `/bfm reset`.
  - **Standardized Automated Packaging**: Root `package.ps1` script adhering to Suite guidelines.

---

## [v1.0.04] - 2026-10-05

**Target Client:** World of Warcraft Forever (Interface 16001)  
**Detailed Notes:** [changelogs/v1.0.04.md](changelogs/v1.0.04.md)

### Added
- **World Map Fog of War / Map Reveal (`Modules/WorldMap/WorldMapFog.lua`, `Modules/WorldMap/WorldMapFogData.lua`)**:
  - Implemented client-side map reveal module that removes parchment fog from undiscovered zones.
  - **WoW Forever MapArtID Dataset (`WorldMapFogData.lua`)**: Mapped authentic World of Warcraft Forever `MapArtID`s (e.g. Dun Morogh `[2151]`, Durotar `[2169]`, Elwynn `[2153]`, The Barrens `[2181]`, and Forever-specific zones Hyjal `[1997]`, Zephras Isle `[2031]`, Riverglades `[2054]`, Shen'dralas `[2132]`) using native coordinate dimension keys (`width:height:offsetX:offsetY`).
  - **MapCanvas Exploration Hooking**: Securely hooks `MapExplorationPinMixin:RefreshOverlays()` without tainting canvas logic or triggering protected action errors.
  - **Exploration Diffing Pipeline**: Compares full zone overlay sets against `C_MapExplorationInfo.GetExploredMapTextures(mapID)`, rendering only unexplored chunks with user-defined tint and opacity while keeping earned discoveries at 100% natural saturation.
  - **Customizable Appearance & Opacity**:
    - Unexplored Overlay Opacity slider configurable from 10% to 100%.
    - Full RGB Overlay Tint Color picker supporting arbitrary color customization.
    - Curated Visual Presets: `Soft Haze` (cool atmospheric tint), `Parchment Shadow` (classic antique paper tone), and `Full Visibility` (100% clear terrain view).
  - **Slash Command Integration**: Added `/bfm fog` and `/bfm reveal` shortcuts to toggle map fog removal in real time.
  - **Master Config Synchronization**: Fully registered with `BleakfibersAddonConfigForever` (`/bac`) with real-time setting application.

### Fixed
- **MapCanvas ScrollContainer ZoomLevel Crash (`WorldMapFog.lua`)**:
  - Resolved Lua error `MapCanvas_ScrollContainerMixin.lua:518: bad argument #1 to 'ipairs' (table expected, got nil)` when opening config windows (`/bac` or `/bfm`) while `WorldMapFrame` is closed.
  - Guarded `WorldMapFog:Refresh()` and `OnPinRefreshOverlays()` against hidden frames and uninitialized `ScrollContainer.zoomLevels`.
  - Added programmatic sync guard (`isSyncing`) in `ConfigUI.lua` sliders to prevent recursive `OnValueChanged` execution and redundant settings updates during tab navigation.
- **Fog of War MapArtID Mismatch (`WorldMapFogData.lua`, `WorldMapFog.lua`)**:
  - Replaced outdated legacy pre-BfA Mapster IDs with authentic WoW Forever `MapArtID` indices matching `C_Map.GetMapArtID(mapID)`.
  - Resolved issue where unexplored overlays failed to render on zone maps like Dun Morogh.

---

## [v1.0.03] - 2026-10-05

**Target Client:** World of Warcraft Forever (Interface 16001)  
**Detailed Notes:** [changelogs/v1.0.03.md](changelogs/v1.0.03.md)

### Added
- **Sub-Tab Navigation System (`Core/ConfigUI.lua`)**:
  - Restructured configuration UI into 3 dedicated sub-tabs matching the design language of `BleakfibersQuestTracker-Forever`:
    - **General Settings**: Master config integration status, comprehensive slash commands list, and factory defaults restoration.
    - **Minimap Settings**: Clean geometry controls, border styling, class-colored border, custom border & backdrop colors, button scaling, drag-to-move, clutter filters, and coordinates HUD bar.
    - **World Map Settings**: World Map coordinate overlays and map settings pane.
  - Implemented horizontal tab buttons with active gold indicator underline, bright gold border highlights, and dark slate inset content boxes.
  - Applied unified tabbed layout to both the Master Config (`/bac`) embed pane and the standalone (`/bfm`) window.

### Fixed
- **UI Control Overlap & Clipping (`Core/ConfigUI.lua`)**:
  - Resolved label and value percentage collisions on sliders (e.g., `Clock Button Scale` overlapping `150%`). Value strings are now anchored to the top-right of slider tracks while labels remain anchored to the top-left.
  - Increased vertical spacing between controls to 55px for slider rows, preventing lower value bounds from clipping into subsequent headers.
  - Decoupled `Reset Position` button positioning from the `Unlock Minimap` label to eliminate localized text collision.

---

## [v1.0.02] - 2026-10-05

**Target Client:** World of Warcraft Forever (Interface 16001)  
**Detailed Notes:** [changelogs/v1.0.02.md](changelogs/v1.0.02.md)

### Added
- **Master Addon Config Window Overhaul (`Core/ConfigUI.lua`)**: Redesigned the configuration UI to match the master design language of `BleakfibersAddonConfigForever` with beveled dark slate/iron backdrops, radiant gold borders, draggable title bar with map icon, interactive category sidebar (`Minimap Settings`, `Coordinates & HUD`, `About & Commands`), resizable window bounds (640x420 up to 1200x850), position persistence, and color picker support.
- **Robust BAC Panel Hooking (`Core/Init.lua`)**: Fixed integration with `BleakfibersAddonConfig-Forever` (`/bac`) across hyphenated/non-hyphenated folder names, multi-event registration lifecycle, sidebar hooks, and a full embedded configuration pane (`BFM:BuildEmbedUI`).
- **Minimap Resizing Up to 512x512**: Expanded dynamic scaling support allowing players to adjust the square minimap dimensions from 100px up to 512px via GUI sliders or `/bfm size <number>`. Auto-refreshes the C++ engine texture buffer instantly on resize without manual zoom.
- **Automatic Mover Overlay Dismissal**: Closing the configuration window (via close button, Escape key, `/bfm`, or closing the master config panel) automatically locks the minimap and hides the click-to-drag mover overlay.
- **Top Ceiling Clamp Removal**: Resolved the ceiling gap where `MinimapContainer`'s default `-30px` top offset prevented the minimap from reaching the top of the screen. Bound `MinimapContainer`, `Minimap`, and `MinimapCluster` bounds with synchronized layout hooks and a negative top clamp inset (`SetClampRectInsets(0, 0, -20, 0)`), allowing the minimap to sit flush against the top edge of the screen.
- **Click-to-Drag Movement**: Frame movement support allowing the minimap to be repositioned anywhere on screen. Features persistent coordinate saving, an unlock overlay (`/bfm unlock`), Alt-drag support, and a position reset button (`/bfm resetpos`).
- **Minimap Appearance & Border Customization (`SquareMinimap.lua`, `Config.lua`, `ConfigUI.lua`)**:
  - Implemented border styles matching Bleakfiber's Quest Tracker: `Flat (Modern Sleek 1px)`, `Blizzard Tooltip (Classic Rounded)`, `Blizzard Dialog (Classic Window)`, and `None (Borderless)`.
  - Added a **Class-Colored Border** option that dynamically tints the minimap border with the player's class color (`RAID_CLASS_COLORS` / `CUSTOM_CLASS_COLORS`).
  - Added color picker support for both **Custom Border Color & Opacity** and **Backdrop Color & Opacity**.
  - Added a border thickness slider (1px - 5px) for the flat border style.
- **Minimap Button Scaling (`SquareMinimap.lua`, `ConfigUI.lua`)**:
  - Added dedicated scaling sliders (50% - 150%) for the **Tracking Button** (`MinimapCluster.Tracking`), **Calendar Button** (`GameTimeFrame`), and **Clock Button** (`TimeManagerClockButton`).
  - Synced scale application in both the standalone configuration window and the master `/bac` config hub.
- **Bleakfiber's Quest Tracker Location Bar Integration (`MinimapCoords.lua`)**:
  - Added automatic detection and event hooking for `BleakfibersQuestTracker-Forever`'s Location DataBar (`BleakfiberQuestTrackerLocationBar`).
  - Automatically suppresses the built-in minimap coordinate and zone bar (`BFM_MinimapInfoBar`) when the Quest Tracker's location bar is active, and seamlessly restores it if the Quest Tracker's location bar is disabled or hidden.

### Fixed
- Fixed circular quest blob ring clipping within the square minimap mask.
- Resolved `SetUserPlaced()` runtime error when resetting minimap position.
- Resolved top screen boundary gap when dragging the minimap to the ceiling.

---

## [v1.0.01] - 2026-10-05

**Target Client:** World of Warcraft Forever (Interface 16001)  
**Detailed Notes:** [changelogs/v1.0.01.md](changelogs/v1.0.01.md)

### Added
- **Style-able Square Minimap Module (`SquareMinimap.lua`)**:
  - Replaced circular minimap mask with clean square mask (`WHITE8X8`).
  - Stripped default round borders (`MinimapBorder`, `MinimapBorderTop`), compass textures (`MinimapCompassTexture`), and zoom clutter.
  - Added configurable removal of `MinimapCluster.DielFrame` (day/night dial cycle indicator).
  - Square minimap button projection: addon icons follow the square perimeter via global `GetMinimapShape` and dynamic radial projection.
  - Added customizable pixel-perfect 4-edge border frame and backdrop supporting user-defined thickness, color, and opacity via `BleakfibersMapsDB`.
  - Implemented mouse wheel zooming with step boundary clamping.
  - Re-anchored tracking icon, mail indicator, and addon compartment button along the square perimeter.
- **Minimap Coordinates & Zone Bar (`MinimapCoords.lua`)**:
  - Integrated bottom information bar with throttled (0.1s) live player coordinates (`xx.x, yy.y`).
  - Dynamic zone and subzone display with faction/PVP reactive text coloring.
  - Interactive tooltip and click-to-toggle World Map functionality.
- **World Map Enhancements (`WorldMapCoords.lua`)**:
  - Integrated with `WorldMapFrame` using modern `MapCanvas` data provider architecture (`MapCanvasDataProviderMixin`).
  - Live **Player Coordinates** and hover **Cursor Coordinates** overlay bar attached to `WorldMapFrame.ScrollContainer`.
  - Coordinate normalization with automatic blanking when cursor leaves the map canvas.
- **Graphical Configuration & Slash Commands (`ConfigUI.lua`, `Config.lua`, `Init.lua`)**:
  - Interactive graphical configuration window accessible via `/bfm`, `/bfm config`, or `/bfm options`.
  - Slash command toggles (`/bfm diel`, `/bfm icons`, `/bfm coords`, `/bfm status`).
  - SavedVariables database schema (`BleakfibersMapsDB`) with automatic defaults population.

### Fixed
- Resolved nil value runtime error by implementing modern `C_PvP.GetZonePVPInfo` fallback wrapper.
