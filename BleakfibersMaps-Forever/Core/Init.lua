local addonName, BFM = ...

-- Expose global API
BleakfibersMapsForever = BleakfibersMapsForever or BFM
_G["BleakfibersMapsForever"] = BleakfibersMapsForever

BFM.Title = "Bleakfiber's Maps"
BFM.Version = "1.0.02"
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
end

function BleakfibersMapsForever:ResetPosition()
    local squareModule = self.modules["SquareMinimap"]
    if squareModule and squareModule.ResetPosition then
        squareModule:ResetPosition()
    end
end

-- Master Config Addon Registration
function BleakfibersMapsForever:RegisterWithMasterConfig()
    if BleakfibersAddonConfigForever and type(BleakfibersAddonConfigForever.RegisterModule) == "function" then
        BleakfibersAddonConfigForever:RegisterModule("BleakfibersMapsForever", {
            name = "Bleakfiber's Maps",
            db = BleakfibersMapsDB,
            refresh = function()
                BleakfibersMapsForever:ApplySettings()
            end,
            buildUI = function(parentContainer)
                if BFM.BuildEmbedUI then
                    BFM:BuildEmbedUI(parentContainer)
                end
            end,
        })
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then
            BFM:InitDB()
            _G["BleakfibersMapsDB"] = BleakfibersMapsDB
            for _, module in pairs(BFM.modules) do
                if type(module.OnInitialize) == "function" then
                    module:OnInitialize()
                end
            end
            BleakfibersMapsForever:RegisterWithMasterConfig()
        elseif arg1 == "BleakfibersAddonConfigForever" then
            BleakfibersMapsForever:RegisterWithMasterConfig()
        end
    elseif event == "PLAYER_LOGIN" then
        for _, module in pairs(BFM.modules) do
            if type(module.OnEnable) == "function" then
                module:OnEnable()
            end
        end
        BleakfibersMapsForever:RegisterWithMasterConfig()
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
        if BleakfibersAddonConfigForever and type(BleakfibersAddonConfigForever.OpenModule) == "function" then
            BleakfibersAddonConfigForever:OpenModule("BleakfibersMapsForever")
        elseif BleakfibersAddonConfigForever and type(BleakfibersAddonConfigForever.Open) == "function" then
            BleakfibersAddonConfigForever:Open("BleakfibersMapsForever")
        else
            BFM:ToggleConfigUI()
        end
    elseif cmd == "unlock" or cmd == "move" then
        BFM.db.minimap.unlocked = not BFM.db.minimap.unlocked
        BFM:NotifySettingsChanged("unlocked")
        print(string.format("%s Minimap Unlocked (Click & Drag) set to %s", prefix, tostring(BFM.db.minimap.unlocked)))
    elseif cmd == "resetpos" then
        BleakfibersMapsForever:ResetPosition()
        print(string.format("%s Minimap position reset to default.", prefix))
    elseif cmd == "size" then
        local num = tonumber(arg)
        if num and num >= 80 and num <= 300 then
            BFM.db.minimap.size = num
            BFM:NotifySettingsChanged("size")
            print(string.format("%s Minimap size set to %d px", prefix, num))
        else
            print(string.format("%s Usage: /bfm size <100-260>", prefix))
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
    elseif cmd == "status" then
        print(string.format("%s v%s Status:", prefix, BFM.Version))
        print(string.format(" - Minimap Size: %d px", BFM.db.minimap.size or 140))
        print(string.format(" - Unlocked (Draggable): %s", tostring(BFM.db.minimap.unlocked == true)))
        print(string.format(" - Square Quest Indicator: %s", tostring(BFM.db.minimap.questIndicator ~= false)))
        print(string.format(" - Follow Square Perimeter: %s", tostring(BFM.db.minimap.squareIcons ~= false)))
        print(string.format(" - Hide DielFrame: %s", tostring(BFM.db.minimap.hideDielFrame ~= false)))
        print(string.format(" - Minimap Coords: %s", tostring(BFM.db.minimap.showCoords ~= false)))
        print(string.format(" - World Map Coords: %s", tostring(BFM.db.worldmap.showCoords ~= false)))
        print(string.format(" - Border Size: %d px", BFM.db.minimap.borderSize or 1))
    else
        print(string.format("%s Commands: /bfm (settings GUI), /bfm unlock, /bfm size <num>, /bfm resetpos, /bfm quest, /bfm diel, /bfm icons, /bfm status", prefix))
    end
end
