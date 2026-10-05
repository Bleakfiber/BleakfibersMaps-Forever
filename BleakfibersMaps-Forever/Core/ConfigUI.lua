local addonName, BFM = ...

local configFrame

local function CreateCheckbox(parent, labelText, tooltipText, onClick)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)

    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    text:SetText(labelText)
    cb.Text = text

    if tooltipText then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(labelText, 1, 1, 1)
            GameTooltip:AddLine(tooltipText, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
        if onClick then
            onClick(checked)
        end
    end)

    return cb
end

function BFM:CreateConfigUI()
    if configFrame then return end

    configFrame = CreateFrame("Frame", "BFM_ConfigFrame", UIParent)
    configFrame:SetSize(420, 480)
    configFrame:SetPoint("CENTER")
    configFrame:SetFrameStrata("DIALOG")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:SetClampedToScreen(true)

    -- Background & Border
    local bg = configFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.08, 0.10, 0.95)

    local borderTop = configFrame:CreateTexture(nil, "BORDER")
    borderTop:SetPoint("TOPLEFT")
    borderTop:SetPoint("TOPRIGHT")
    borderTop:SetHeight(2)
    borderTop:SetColorTexture(0, 0.75, 1, 1)

    local borderBot = configFrame:CreateTexture(nil, "BORDER")
    borderBot:SetPoint("BOTTOMLEFT")
    borderBot:SetPoint("BOTTOMRIGHT")
    borderBot:SetHeight(1)
    borderBot:SetColorTexture(0.2, 0.2, 0.2, 1)

    local borderL = configFrame:CreateTexture(nil, "BORDER")
    borderL:SetPoint("TOPLEFT")
    borderL:SetPoint("BOTTOMLEFT")
    borderL:SetWidth(1)
    borderL:SetColorTexture(0.2, 0.2, 0.2, 1)

    local borderR = configFrame:CreateTexture(nil, "BORDER")
    borderR:SetPoint("TOPRIGHT")
    borderR:SetPoint("BOTTOMRIGHT")
    borderR:SetWidth(1)
    borderR:SetColorTexture(0.2, 0.2, 0.2, 1)

    -- Header Title
    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 16, -16)
    title:SetText("|cff00c0ffBleakfiber's Maps|r - |cffffd100Settings|r")

    local subtitle = configFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Configure square minimap, position, scaling, and quest indicators.")

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        configFrame:Hide()
    end)

    -- Checkboxes Layout
    local yOffset = -66

    -- 1. Unlock Minimap
    local cbUnlock = CreateCheckbox(configFrame, "Unlock Minimap (Click & Drag to Move)", "Allows clicking and dragging the minimap freely across the screen. Also supports Alt+Drag anytime.", function(checked)
        BFM.db.minimap.unlocked = checked
        BFM:NotifySettingsChanged("unlocked")
    end)
    cbUnlock:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 2. Square Quest Zone Indicator
    yOffset = yOffset - 34
    local cbQuest = CreateCheckbox(configFrame, "Square Quest Zone Indicator", "Conforms the quest objective boundary to the square bounds of the minimap, suppressing the round ring.", function(checked)
        BFM.db.minimap.questIndicator = checked
        BFM:NotifySettingsChanged("questIndicator")
    end)
    cbQuest:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 3. Square Icons
    yOffset = yOffset - 34
    local cbIcons = CreateCheckbox(configFrame, "Follow Square Minimap Perimeter", "Constrains addon buttons to the square edges of the minimap instead of orbiting circularly.", function(checked)
        BFM.db.minimap.squareIcons = checked
        BFM:NotifySettingsChanged("squareIcons")
    end)
    cbIcons:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 4. Hide DielFrame
    yOffset = yOffset - 34
    local cbDiel = CreateCheckbox(configFrame, "Hide Day/Night Cycle (DielFrame)", "Hides the sun and moon dial texture docked to the MinimapCluster.", function(checked)
        BFM.db.minimap.hideDielFrame = checked
        BFM:NotifySettingsChanged("hideDielFrame")
    end)
    cbDiel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 5. Show Minimap Coords & Zone Bar
    yOffset = yOffset - 34
    local cbMinimapCoords = CreateCheckbox(configFrame, "Show Minimap Coordinates & Subzone Bar", "Displays live player coordinates and reactive subzone text at the bottom of the minimap.", function(checked)
        BFM.db.minimap.showCoords = checked
        BFM:NotifySettingsChanged("showCoords")
    end)
    cbMinimapCoords:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 6. Mouse Wheel Zoom
    yOffset = yOffset - 34
    local cbZoom = CreateCheckbox(configFrame, "Enable Minimap Mouse Wheel Zoom", "Allows scrolling up and down on the minimap to zoom in and out with clamped boundaries.", function(checked)
        BFM.db.minimap.enableMouseWheelZoom = checked
    end)
    cbZoom:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- 7. World Map Coordinates
    yOffset = yOffset - 34
    local cbWorldCoords = CreateCheckbox(configFrame, "Show World Map Coordinate Overlay", "Displays live player and cursor-hover coordinates at the bottom of the World Map canvas.", function(checked)
        BFM.db.worldmap.showCoords = checked
        BFM:NotifySettingsChanged("worldMapCoords")
    end)
    cbWorldCoords:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)

    -- Sliders Section
    yOffset = yOffset - 42

    -- Minimap Size Slider
    local sizeLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sizeLabel:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 22, yOffset)
    sizeLabel:SetText("Minimap Size (Pixels):")

    local sizeSlider = CreateFrame("Slider", "BFM_MinimapSizeSlider", configFrame, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 4, -14)
    sizeSlider:SetWidth(170)
    sizeSlider:SetMinMaxValues(100, 260)
    sizeSlider:SetValueStep(5)
    sizeSlider:SetObeyStepOnDrag(true)
    _G[sizeSlider:GetName() .. "Low"]:SetText("100")
    _G[sizeSlider:GetName() .. "High"]:SetText("260")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(tostring(value))
        BFM.db.minimap.size = value
        BFM:NotifySettingsChanged("size")
    end)

    -- Border Thickness Slider
    local borderLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    borderLabel:SetPoint("LEFT", sizeLabel, "LEFT", 200, 0)
    borderLabel:SetText("Border Thickness:")

    local borderSlider = CreateFrame("Slider", "BFM_BorderThicknessSlider", configFrame, "OptionsSliderTemplate")
    borderSlider:SetPoint("TOPLEFT", borderLabel, "BOTTOMLEFT", 4, -14)
    borderSlider:SetWidth(150)
    borderSlider:SetMinMaxValues(1, 5)
    borderSlider:SetValueStep(1)
    borderSlider:SetObeyStepOnDrag(true)
    _G[borderSlider:GetName() .. "Low"]:SetText("1")
    _G[borderSlider:GetName() .. "High"]:SetText("5")
    borderSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(tostring(value))
        BFM.db.minimap.borderSize = value
        BFM:NotifySettingsChanged("borderSize")
    end)

    -- Reset Position Button
    local resetBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    resetBtn:SetSize(130, 22)
    resetBtn:SetPoint("BOTTOMLEFT", configFrame, "BOTTOMLEFT", 20, 16)
    resetBtn:SetText("Reset Position")
    resetBtn:SetScript("OnClick", function()
        local squareMod = BFM.modules["SquareMinimap"]
        if squareMod and squareMod.ResetPosition then
            squareMod:ResetPosition()
            print("|cff00c0ffBleakfiber's Maps|r: Minimap position reset to default.")
        end
    end)

    -- OnShow Value Synchronization
    configFrame:SetScript("OnShow", function()
        cbUnlock:SetChecked(BFM.db.minimap.unlocked == true)
        cbQuest:SetChecked(BFM.db.minimap.questIndicator ~= false)
        cbIcons:SetChecked(BFM.db.minimap.squareIcons ~= false)
        cbDiel:SetChecked(BFM.db.minimap.hideDielFrame ~= false)
        cbMinimapCoords:SetChecked(BFM.db.minimap.showCoords ~= false)
        cbZoom:SetChecked(BFM.db.minimap.enableMouseWheelZoom ~= false)
        cbWorldCoords:SetChecked(BFM.db.worldmap.showCoords ~= false)

        local currentSize = BFM.db.minimap.size or 140
        sizeSlider:SetValue(currentSize)
        _G[sizeSlider:GetName() .. "Text"]:SetText(tostring(currentSize))

        local currentBorder = BFM.db.minimap.borderSize or 1
        borderSlider:SetValue(currentBorder)
        _G[borderSlider:GetName() .. "Text"]:SetText(tostring(currentBorder))
    end)

    configFrame:Hide()
end

function BFM:ToggleConfigUI()
    if not configFrame then
        BFM:CreateConfigUI()
    end
    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

function BFM:BuildEmbedUI(parent)
    if not parent then return end

    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parent, "TOPLEFT", 16, -16)
    title:SetText("|cff00c0ffBleakfiber's Maps|r Settings")

    local subtitle = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    subtitle:SetText("Configure square minimap, position, scaling, and quest indicators.")

    local yOffset = -56

    local cbUnlock = CreateCheckbox(parent, "Unlock Minimap (Click & Drag to Move)", "Allows clicking and dragging the minimap freely across the screen. Also supports Alt+Drag anytime.", function(checked)
        BFM.db.minimap.unlocked = checked
        BFM:ApplySettings()
    end)
    cbUnlock:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbQuest = CreateCheckbox(parent, "Square Quest Zone Indicator", "Conforms the quest objective boundary to the square bounds of the minimap, suppressing the round ring.", function(checked)
        BFM.db.minimap.questIndicator = checked
        BFM:ApplySettings()
    end)
    cbQuest:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbIcons = CreateCheckbox(parent, "Follow Square Minimap Perimeter", "Constrains addon buttons to the square edges of the minimap instead of orbiting circularly.", function(checked)
        BFM.db.minimap.squareIcons = checked
        BFM:ApplySettings()
    end)
    cbIcons:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbDiel = CreateCheckbox(parent, "Hide Day/Night Cycle (DielFrame)", "Hides the sun and moon dial texture docked to the MinimapCluster.", function(checked)
        BFM.db.minimap.hideDielFrame = checked
        BFM:ApplySettings()
    end)
    cbDiel:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbMinimapCoords = CreateCheckbox(parent, "Show Minimap Coordinates & Subzone Bar", "Displays live player coordinates and reactive subzone text at the bottom of the minimap.", function(checked)
        BFM.db.minimap.showCoords = checked
        BFM:ApplySettings()
    end)
    cbMinimapCoords:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbZoom = CreateCheckbox(parent, "Enable Minimap Mouse Wheel Zoom", "Allows scrolling up and down on the minimap to zoom in and out with clamped boundaries.", function(checked)
        BFM.db.minimap.enableMouseWheelZoom = checked
        BFM:ApplySettings()
    end)
    cbZoom:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 32
    local cbWorldCoords = CreateCheckbox(parent, "Show World Map Coordinate Overlay", "Displays live player and cursor-hover coordinates at the bottom of the World Map canvas.", function(checked)
        BFM.db.worldmap.showCoords = checked
        BFM:ApplySettings()
    end)
    cbWorldCoords:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, yOffset)

    yOffset = yOffset - 40
    local sizeLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sizeLabel:SetPoint("TOPLEFT", parent, "TOPLEFT", 22, yOffset)
    sizeLabel:SetText("Minimap Size (Pixels):")

    local sizeSlider = CreateFrame("Slider", "BFM_MasterMinimapSizeSlider", parent, "OptionsSliderTemplate")
    sizeSlider:SetPoint("TOPLEFT", sizeLabel, "BOTTOMLEFT", 4, -14)
    sizeSlider:SetWidth(170)
    sizeSlider:SetMinMaxValues(100, 260)
    sizeSlider:SetValueStep(5)
    sizeSlider:SetObeyStepOnDrag(true)
    _G[sizeSlider:GetName() .. "Low"]:SetText("100")
    _G[sizeSlider:GetName() .. "High"]:SetText("260")
    sizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(tostring(value))
        BFM.db.minimap.size = value
        BFM:ApplySettings()
    end)

    local borderLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    borderLabel:SetPoint("LEFT", sizeLabel, "LEFT", 200, 0)
    borderLabel:SetText("Border Thickness:")

    local borderSlider = CreateFrame("Slider", "BFM_MasterBorderThicknessSlider", parent, "OptionsSliderTemplate")
    borderSlider:SetPoint("TOPLEFT", borderLabel, "BOTTOMLEFT", 4, -14)
    borderSlider:SetWidth(150)
    borderSlider:SetMinMaxValues(1, 5)
    borderSlider:SetValueStep(1)
    borderSlider:SetObeyStepOnDrag(true)
    _G[borderSlider:GetName() .. "Low"]:SetText("1")
    _G[borderSlider:GetName() .. "High"]:SetText("5")
    borderSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        _G[self:GetName() .. "Text"]:SetText(tostring(value))
        BFM.db.minimap.borderSize = value
        BFM:ApplySettings()
    end)

    local resetBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    resetBtn:SetSize(130, 22)
    resetBtn:SetPoint("TOPLEFT", sizeSlider, "BOTTOMLEFT", 0, -20)
    resetBtn:SetText("Reset Position")
    resetBtn:SetScript("OnClick", function()
        BFM:ResetPosition()
        print("|cff00c0ffBleakfiber's Maps|r: Minimap position reset to default.")
    end)

    local function SyncValues()
        cbUnlock:SetChecked(BFM.db.minimap.unlocked == true)
        cbQuest:SetChecked(BFM.db.minimap.questIndicator ~= false)
        cbIcons:SetChecked(BFM.db.minimap.squareIcons ~= false)
        cbDiel:SetChecked(BFM.db.minimap.hideDielFrame ~= false)
        cbMinimapCoords:SetChecked(BFM.db.minimap.showCoords ~= false)
        cbZoom:SetChecked(BFM.db.minimap.enableMouseWheelZoom ~= false)
        cbWorldCoords:SetChecked(BFM.db.worldmap.showCoords ~= false)
        local curS = BFM.db.minimap.size or 140
        sizeSlider:SetValue(curS)
        _G[sizeSlider:GetName() .. "Text"]:SetText(tostring(curS))
        local curB = BFM.db.minimap.borderSize or 1
        borderSlider:SetValue(curB)
        _G[borderSlider:GetName() .. "Text"]:SetText(tostring(curB))
    end

    SyncValues()
    parent:HookScript("OnShow", SyncValues)
    parent.refresh = SyncValues
end

