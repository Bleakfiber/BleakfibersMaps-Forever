local addonName, BFM = ...

-- Expose global API
BleakfibersMapsForever = BleakfibersMapsForever or BFM
_G["BleakfibersMapsForever"] = BleakfibersMapsForever

BFM.Title = "Bleakfiber's Maps"
BFM.Version = "1.0.6"
BFM.modules = {}

function BFM:RegisterModule(name, module)
    self.modules[name] = module
end

-- Universal Minimap shape provider recognized by LibDBIcon and custom button frameworks
function GetMinimapShape()
    if BFM.db and BFM.db.minimap and BFM.db.minimap.squareIcons == false then
        return "ROUND"
    end
    return "SQUARE"
end

-- Public method to re-apply all visual settings in real time
function BleakfibersMapsForever:ApplySettings()
    local squareModule = self.modules["SquareMinimap"]
    if squareModule then
        if squareModule.UpdateBorder then squareModule:UpdateBorder() end
        if squareModule.UpdateDielFrame then squareModule:UpdateDielFrame() end
        if squareModule.ScanMinimapButtons then squareModule:ScanMinimapButtons() end
        if squareModule.SetMinimapSize and BFM.db and BFM.db.minimap and BFM.db.minimap.size then
            squareModule:SetMinimapSize(BFM.db.minimap.size)
        end
        if squareModule.UpdateMoveOverlay then squareModule:UpdateMoveOverlay() end
        if squareModule.UpdateQuestZoneIndicator then squareModule:UpdateQuestZoneIndicator() end
        if squareModule.PositionElements then squareModule:PositionElements() end
        if squareModule.PositionClock then squareModule:PositionClock() end
    end

    local coordsModule = self.modules["MinimapCoords"]
    if coordsModule then
        if coordsModule.UpdateVisibility then coordsModule:UpdateVisibility() end
        if coordsModule.UpdateLayout then coordsModule:UpdateLayout() end
    end

    local worldMapModule = self.modules["WorldMapCoords"]
    if worldMapModule and worldMapModule.UpdateVisibility then
        worldMapModule:UpdateVisibility()
    end

    local fogModule = self.modules["WorldMapFog"]
    if fogModule and fogModule.Refresh then
        fogModule:Refresh()
    end
end

function BleakfibersMapsForever:ResetPosition()
    local squareModule = self.modules["SquareMinimap"]
    if squareModule and squareModule.ResetPosition then
        squareModule:ResetPosition()
    end
end

--[[-----------------------------------------------------------------------------
    Unified Movers Contract
-------------------------------------------------------------------------------]]
function BleakfibersMapsForever:ToggleMovers(state)
    local squareModule = self.modules["SquareMinimap"]
    if squareModule and squareModule.ToggleMovers then
        return squareModule:ToggleMovers(state)
    end
    return false
end

function BleakfibersMapsForever:IsMoversUnlocked()
    local squareModule = self.modules["SquareMinimap"]
    if squareModule and squareModule.IsMoversUnlocked then
        return squareModule:IsMoversUnlocked()
    end
    return false
end

function BleakfibersMapsForever:ResetMovers()
    self:ResetPosition()
end

local function RegisterGlobalMovers()
    _G.Bleakfibers_MoversRegistry = _G.Bleakfibers_MoversRegistry or {}
    _G.Bleakfibers_MoversRegistry["BleakfibersMaps"] = {
        name = "Bleakfiber's Maps",
        sidebarName = "Maps",
        Toggle = function(state) return BleakfibersMapsForever:ToggleMovers(state) end,
        Reset = function() BleakfibersMapsForever:ResetMovers() end,
        IsUnlocked = function() return BleakfibersMapsForever:IsMoversUnlocked() end,
    }
end

--[[-----------------------------------------------------------------------------
    Master Config Addon Registration
-------------------------------------------------------------------------------]]
function BleakfibersMapsForever:RegisterWithMasterConfig()
    local BAC = _G["BleakfibersAddonConfigForever"] or _G["BleakfibersAddonConfig"]
    if not (BAC and type(BAC.RegisterModule) == "function") then
        return false
    end

    local moduleData = {
        id = "BleakfibersMaps",
        name = "Bleakfiber's Maps",
        sidebarName = "Maps",
        version = BFM.Version or "1.0.05",
        author = "Bleakfiber",
        isBleakfiber = true,
        description = "Modular square minimap and world map suite featuring custom borders and Fog of War reveal.",
        db = _G["BleakfibersMapsDB"] or BFM.db,
        getDB = function() return _G["BleakfibersMapsDB"] or BFM.db end,

        -- Synchronized Profiles Contract
        profiles = {
            GetCurrent    = function() return BFM:GetActiveProfile() end,
            SetCurrent    = function(profileKey) BFM:SetActiveProfile(profileKey) end,
            SaveCurrentAs = function(profileKey) BFM:SaveCurrentAs(profileKey) end,
            List          = function() return BFM:GetProfiles() end,
            Create        = function(profileKey, from) BFM:CreateProfile(profileKey, from) end,
            Delete        = function(profileKey) BFM:DeleteProfile(profileKey) end,
            Copy          = function(fromKey, toKey) BFM:CopyProfile(fromKey, toKey) end,
            Reset         = function(profileKey) BFM:ResetProfile(profileKey) end,
        },

        -- Unified Movers Contract
        toggleMovers = function(state) return BleakfibersMapsForever:ToggleMovers(state) end,
        resetMovers  = function() BleakfibersMapsForever:ResetMovers() end,
        isMoversUnlocked = function() return BleakfibersMapsForever:IsMoversUnlocked() end,

        refresh = function()
            BleakfibersMapsForever:ApplySettings()
        end,
        openStandalone = function()
            BFM:ShowConfigUI()
        end,
        buildUI = function(parentContainer, isMasterHub)
            if BFM.BuildEmbedUI then
                BFM:BuildEmbedUI(parentContainer, isMasterHub)
            end
        end,
    }

    local success = BAC:RegisterModule("BleakfibersMaps", moduleData)
    if success and BAC.modules and not BAC.modules["BleakfibersMapsForever"] then
        BAC.modules["BleakfibersMapsForever"] = moduleData
    end
    return success
end

local function HookBAC()
    local BAC = _G["BleakfibersAddonConfigForever"] or _G["BleakfibersAddonConfig"]
    if BAC and not BFM.hasHookedBAC then
        BFM.hasHookedBAC = true
        if BAC.RefreshSidebar then
            hooksecurefunc(BAC, "RefreshSidebar", function()
                if not BAC.modules or not BAC.modules["BleakfibersMaps"] then
                    BleakfibersMapsForever:RegisterWithMasterConfig()
                end
            end)
        end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("VARIABLES_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            BFM:InitDB()
            _G["BleakfibersMapsDB"] = BleakfibersMapsDB
            RegisterGlobalMovers()
            for _, module in pairs(BFM.modules) do
                if type(module.OnInitialize) == "function" then
                    module:OnInitialize()
                end
            end
            BleakfibersMapsForever:RegisterWithMasterConfig()
            HookBAC()
        elseif arg1 == "BleakfibersAddonConfig-Forever" or arg1 == "BleakfibersAddonConfigForever" then
            RegisterGlobalMovers()
            BleakfibersMapsForever:RegisterWithMasterConfig()
            HookBAC()
        end
    elseif event == "VARIABLES_LOADED" then
        RegisterGlobalMovers()
        BleakfibersMapsForever:RegisterWithMasterConfig()
        HookBAC()
    elseif event == "PLAYER_LOGIN" then
        RegisterGlobalMovers()
        for _, module in pairs(BFM.modules) do
            if type(module.OnEnable) == "function" then
                module:OnEnable()
            end
        end
        BleakfibersMapsForever:RegisterWithMasterConfig()
        HookBAC()
        if _G["SlashCmdList"] and SlashCmdList["BLEAKFIBERSCONFIG"] then
            hooksecurefunc(SlashCmdList, "BLEAKFIBERSCONFIG", function()
                BleakfibersMapsForever:RegisterWithMasterConfig()
            end)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        RegisterGlobalMovers()
        BleakfibersMapsForever:RegisterWithMasterConfig()
        HookBAC()
    end
end)

-- Slash Commands
SLASH_BLEAKFIBERSMAPS1 = "/bfm"
SLASH_BLEAKFIBERSMAPS2 = "/bleakfibersmaps"
SlashCmdList["BLEAKFIBERSMAPS"] = function(msg)
    local rawMsg = string.trim(msg or "")
    local cmd, arg = string.match(rawMsg, "^(%S+)%s*(.*)$")
    cmd = string.lower(cmd or "")
    arg = string.lower(arg or "")
    local prefix = "|cff00c0ffBleakfiber's Maps|r:"

    if cmd == "" or cmd == "config" or cmd == "options" or cmd == "menu" then
        BFM:ToggleConfigUI()
    elseif cmd == "unlock" or cmd == "move" or cmd == "movers" then
        local newState = BleakfibersMapsForever:ToggleMovers()
        print(string.format("%s Minimap Movers set to %s", prefix, newState and "|cFF00FF00Unlocked|r" or "|cFFFF0000Locked|r"))
    elseif cmd == "resetpos" then
        BleakfibersMapsForever:ResetPosition()
        print(string.format("%s Minimap position reset to default.", prefix))
    elseif cmd == "reset" then
        BFM:ResetProfile()
        print(string.format("%s Current profile ('%s') reset to defaults.", prefix, BFM:GetActiveProfile()))
    elseif cmd == "profile" then
        local subCmd, pName = string.match(arg or "", "^(%S+)%s*(.*)$")
        subCmd = string.lower(subCmd or "")
        pName = string.trim(pName or "")
        if subCmd == "list" or subCmd == "" then
            local list = BFM:GetProfiles()
            local cur = BFM:GetActiveProfile()
            print(string.format("%s Profiles: %s (Active: |cFFFFD100%s|r)", prefix, table.concat(list, ", "), cur))
        elseif (subCmd == "set" or subCmd == "use") and pName ~= "" then
            BFM:SetActiveProfile(pName)
            print(string.format("%s Active profile switched to '%s'.", prefix, pName))
        elseif subCmd == "create" and pName ~= "" then
            BFM:CreateProfile(pName)
            print(string.format("%s Profile '%s' created and activated.", prefix, pName))
        elseif subCmd == "delete" and pName ~= "" then
            if pName == "Default" then
                print(string.format("%s Cannot delete the 'Default' profile.", prefix))
            else
                BFM:DeleteProfile(pName)
                print(string.format("%s Profile '%s' deleted.", prefix, pName))
            end
        else
            print(string.format("%s Usage: /bfm profile [list | set <name> | create <name> | delete <name>]", prefix))
        end
    elseif cmd == "size" then
        local num = tonumber(arg)
        if num and num >= 80 and num <= 512 then
            BFM.db.minimap.size = num
            BFM:NotifySettingsChanged("size")
            print(string.format("%s Minimap size set to %d px", prefix, num))
        else
            print(string.format("%s Usage: /bfm size <100-512>", prefix))
        end
    elseif cmd == "quest" or cmd == "questindicator" then
        BFM.db.minimap.questIndicator = not BFM.db.minimap.questIndicator
        BFM:NotifySettingsChanged("questIndicator")
        print(string.format("%s Square Quest Zone Indicator set to %s", prefix, tostring(BFM.db.minimap.questIndicator)))
    elseif cmd == "diel" or cmd == "dielframe" then
        BFM.db.minimap.hideDielFrame = not BFM.db.minimap.hideDielFrame
        BFM:NotifySettingsChanged("hideDielFrame")
        print(string.format("%s Hide Day/Night Cycle (DielFrame) set to %s", prefix, tostring(BFM.db.minimap.hideDielFrame)))
    elseif cmd == "icons" or cmd == "squareicons" then
        BFM.db.minimap.squareIcons = not BFM.db.minimap.squareIcons
        BFM:NotifySettingsChanged("squareIcons")
        print(string.format("%s Square Minimap Icons set to %s", prefix, tostring(BFM.db.minimap.squareIcons)))
    elseif cmd == "coords" then
        BFM.db.minimap.showCoords = not BFM.db.minimap.showCoords
        BFM:NotifySettingsChanged("showCoords")
        print(string.format("%s Minimap Coordinates set to %s", prefix, tostring(BFM.db.minimap.showCoords)))
    elseif cmd == "fog" or cmd == "fogofwar" or cmd == "reveal" then
        BFM.db.worldmap.fogClear = not BFM.db.worldmap.fogClear
        BFM:NotifySettingsChanged("fogClear")
        print(string.format("%s World Map Fog of War Reveal set to %s", prefix, tostring(BFM.db.worldmap.fogClear)))
    elseif cmd == "status" then
        print(string.format("%s v%s Status (Profile: |cFFFFD100%s|r):", prefix, BFM.Version, BFM:GetActiveProfile()))
        print(string.format(" - Minimap Size: %d px", BFM.db.minimap.size or 140))
        print(string.format(" - Movers Unlocked: %s", tostring(BFM.db.minimap.unlocked == true)))
        print(string.format(" - Square Quest Indicator: %s", tostring(BFM.db.minimap.questIndicator ~= false)))
        print(string.format(" - Follow Square Perimeter: %s", tostring(BFM.db.minimap.squareIcons ~= false)))
        print(string.format(" - Hide DielFrame: %s", tostring(BFM.db.minimap.hideDielFrame ~= false)))
        print(string.format(" - Minimap Coords: %s", tostring(BFM.db.minimap.showCoords ~= false)))
        print(string.format(" - World Map Coords: %s", tostring(BFM.db.worldmap.showCoords ~= false)))
        print(string.format(" - World Map Reveal (Fog): %s", tostring(BFM.db.worldmap.fogClear ~= false)))
        print(string.format(" - Border Size: %d px", BFM.db.minimap.borderSize or 1))
    else
        print(string.format("%s Commands: /bfm (settings GUI), /bfm movers, /bfm profile <list|set>, /bfm size <num>, /bfm resetpos, /bfm reset, /bfm fog, /bfm status", prefix))
    end
end
