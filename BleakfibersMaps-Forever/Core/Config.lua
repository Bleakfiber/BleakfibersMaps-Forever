local addonName, BFM = ...

local defaultSettings = {
    minimap = {
        square = true,
        squareIcons = true,
        hideDielFrame = true,
        borderSize = 1,
        borderColor = { r = 0, g = 0, b = 0, a = 1 },
        backdropColor = { r = 0, g = 0, b = 0, a = 0.8 },
        size = 140,
        unlocked = false,
        position = nil,
        questIndicator = true,
        enableMouseWheelZoom = true,
        showCoords = true,
        showZone = true,
        infoBarHeight = 18,
    },
    worldmap = {
        showCoords = true,
        overlayHeight = 22,
        backdropColor = { r = 0, g = 0, b = 0, a = 0.65 },
    },
}

function BFM:InitDB()
    if type(BleakfibersMapsDB) ~= "table" then
        BleakfibersMapsDB = {}
    end

    local function CopyDefaults(src, dst)
        for k, v in pairs(src) do
            if type(v) == "table" then
                if type(dst[k]) ~= "table" then
                    dst[k] = {}
                end
                CopyDefaults(v, dst[k])
            elseif dst[k] == nil then
                dst[k] = v
            end
        end
    end

    CopyDefaults(defaultSettings, BleakfibersMapsDB)
    BFM.db = BleakfibersMapsDB
end

function BFM:NotifySettingsChanged(settingName)
    local squareModule = BFM.modules["SquareMinimap"]
    if squareModule then
        if settingName == "borderSize" or settingName == "borderColor" or settingName == "backdropColor" then
            squareModule:UpdateBorder()
        elseif settingName == "hideDielFrame" then
            squareModule:UpdateDielFrame()
        elseif settingName == "squareIcons" then
            squareModule:ScanMinimapButtons()
        elseif settingName == "size" then
            squareModule:SetMinimapSize(BFM.db.minimap.size)
        elseif settingName == "unlocked" then
            squareModule:UpdateMoveOverlay()
        elseif settingName == "questIndicator" then
            squareModule:UpdateQuestZoneIndicator()
        end
    end

    local coordsModule = BFM.modules["MinimapCoords"]
    if coordsModule and (settingName == "showCoords" or settingName == "showZone") then
        if coordsModule.UpdateVisibility then
            coordsModule:UpdateVisibility()
        end
    end

    local worldMapModule = BFM.modules["WorldMapCoords"]
    if worldMapModule and settingName == "worldMapCoords" then
        if worldMapModule.UpdateVisibility then
            worldMapModule:UpdateVisibility()
        end
    end
end
