--[[
    Bleakfiber's Maps - Forever
    Core/ConfigUI.lua - Standalone Master Configuration Window & BAC Embed UI
]]

local addonName, BFM = ...

local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

-- Reusable backdrop definitions matching Bleakfiber's Addon Config
local MAIN_WINDOW_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

local INSET_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}

-- UI Color Palette: Dark slate/iron with gold accents
local COLORS = {
    bgSlate      = { 0.08, 0.10, 0.13, 0.96 },
    sidebarBg    = { 0.06, 0.07, 0.09, 0.92 },
    contentBg    = { 0.05, 0.06, 0.08, 0.94 },
    goldBorder   = { 0.82, 0.68, 0.28, 1.00 },
    goldMuted    = { 0.50, 0.42, 0.20, 0.85 },
    goldText     = { 1.00, 0.82, 0.25 },       -- #FFD140
    whiteText    = { 0.90, 0.92, 0.94 },
    dimText      = { 0.55, 0.58, 0.63 },
    tabNormal    = { 0.12, 0.14, 0.17, 0.65 },
    tabHighlight = { 0.20, 0.22, 0.27, 0.80 },
    tabActive    = { 0.22, 0.19, 0.12, 0.95 },
}

BFM.tabButtons = {}
BFM.tabContainers = {}
BFM.currentTab = nil
local standaloneFrame

--[[-----------------------------------------------------------------------------
    Helper: Section Header
-------------------------------------------------------------------------------]]
local function CreateSectionHeader(parent, text, xOfs, yOfs)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", xOfs or 16, yOfs or -10)
    header:SetText(text)
    header:SetTextColor(COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])

    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    divider:SetPoint("RIGHT", parent, "RIGHT", -16, 0)
    divider:SetColorTexture(COLORS.goldMuted[1], COLORS.goldMuted[2], COLORS.goldMuted[3], 0.5)

    return header, divider
end

--[[-----------------------------------------------------------------------------
    Helper: Checkbox
-------------------------------------------------------------------------------]]
local function CreateStyledCheckbox(parent, labelText, tooltipText, getFunc, setFunc)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(22, 22)

    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", cb, "RIGHT", 6, 1)
    text:SetText(labelText)
    cb.Text = text

    if tooltipText then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(labelText, COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
            GameTooltip:AddLine(tooltipText, COLORS.whiteText[1], COLORS.whiteText[2], COLORS.whiteText[3], true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
        if setFunc then
            setFunc(checked)
        end
    end)

    cb.Sync = function()
        if getFunc then
            cb:SetChecked(getFunc() == true)
        end
    end

    return cb
end

--[[-----------------------------------------------------------------------------
    Helper: Slider
-------------------------------------------------------------------------------]]
local function CreateStyledSlider(parent, name, labelText, tooltipText, minVal, maxVal, step, getFunc, setFunc, formatStr)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetWidth(180)
    slider:SetHeight(16)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("BOTTOMLEFT", slider, "TOPLEFT", 0, 4)
    label:SetText(labelText)
    label:SetTextColor(COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
    slider.Label = label

    local lowText = _G[slider:GetName() .. "Low"]
    local highText = _G[slider:GetName() .. "High"]
    local valText = _G[slider:GetName() .. "Text"]

    if lowText then lowText:SetText(tostring(minVal)) end
    if highText then highText:SetText(tostring(maxVal)) end

    formatStr = formatStr or "%d"

    slider:SetScript("OnValueChanged", function(self, value)
        local steppedValue = math.floor((value / step) + 0.5) * step
        if valText then
            valText:SetText(string.format(formatStr, steppedValue))
        end
        if setFunc then
            setFunc(steppedValue)
        end
    end)

    if tooltipText then
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(labelText, COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
            GameTooltip:AddLine(tooltipText, COLORS.whiteText[1], COLORS.whiteText[2], COLORS.whiteText[3], true)
            GameTooltip:Show()
        end)
        slider:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    slider.Sync = function()
        if getFunc then
            local cur = getFunc() or minVal
            slider:SetValue(cur)
            if valText then
                valText:SetText(string.format(formatStr, cur))
            end
        end
    end

    return slider
end

--[[-----------------------------------------------------------------------------
    Helper: Button
-------------------------------------------------------------------------------]]
local function CreateStyledButton(parent, text, width, height, onClick, tooltipText)
    local btn = CreateFrame("Button", nil, parent, BACKDROP_TEMPLATE)
    btn:SetSize(width or 120, height or 22)
    btn:SetBackdrop(INSET_BACKDROP)
    btn:SetBackdropColor(unpack(COLORS.tabNormal))
    btn:SetBackdropBorderColor(unpack(COLORS.goldMuted))

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btnText:SetPoint("CENTER", btn, "CENTER", 0, 0)
    btnText:SetText(text)
    btn.Text = btnText

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(COLORS.tabHighlight))
        self:SetBackdropBorderColor(unpack(COLORS.goldBorder))
        if tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(text, COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
            GameTooltip:AddLine(tooltipText, COLORS.whiteText[1], COLORS.whiteText[2], COLORS.whiteText[3], true)
            GameTooltip:Show()
        end
    end)

    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(COLORS.tabNormal))
        self:SetBackdropBorderColor(unpack(COLORS.goldMuted))
        if tooltipText then
            GameTooltip:Hide()
        end
    end)

    btn:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856)
        if onClick then
            onClick(self)
        end
    end)

    return btn
end

--[[-----------------------------------------------------------------------------
    Helper: Color Picker
-------------------------------------------------------------------------------]]
local function OpenColorPicker(initialColor, onColorChanged)
    local r = initialColor and initialColor.r or 0
    local g = initialColor and initialColor.g or 0
    local b = initialColor and initialColor.b or 0
    local a = initialColor and initialColor.a or 1

    if ColorPickerFrame.SetupColorPickerAndShow then
        ColorPickerFrame:SetupColorPickerAndShow({
            r = r, g = g, b = b, opacity = a, hasOpacity = true,
            swatchFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local na = OpacitySliderFrame and OpacitySliderFrame:GetValue() or 1
                onColorChanged(nr, ng, nb, na)
            end,
            opacityFunc = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                local na = OpacitySliderFrame and OpacitySliderFrame:GetValue() or 1
                onColorChanged(nr, ng, nb, na)
            end,
            cancelFunc = function(prev)
                if prev then
                    onColorChanged(prev.r or r, prev.g or g, prev.b or b, prev.opacity or a)
                else
                    onColorChanged(r, g, b, a)
                end
            end,
        })
    else
        ColorPickerFrame.hasOpacity = true
        ColorPickerFrame.opacity = a
        ColorPickerFrame.func = function()
            local nr, ng, nb = ColorPickerFrame:GetColorRGB()
            local na = OpacitySliderFrame and OpacitySliderFrame:GetValue() or 1
            onColorChanged(nr, ng, nb, na)
        end
        ColorPickerFrame.opacityFunc = ColorPickerFrame.func
        ColorPickerFrame.cancelFunc = function()
            onColorChanged(r, g, b, a)
        end
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame:Show()
    end
end

--[[-----------------------------------------------------------------------------
    Tab 1: Minimap Settings
-------------------------------------------------------------------------------]]
function BFM:BuildMinimapTab(parent)
    local scrollFrame = CreateFrame("ScrollFrame", "BFM_MinimapTabScroll", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 0)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(490, 480)
    scrollFrame:SetScrollChild(content)

    local syncList = {}
    local yOfs = -10

    -- Section 1: Sizing & Geometry
    CreateSectionHeader(content, "SIZING & GEOMETRY", 12, yOfs)
    yOfs = yOfs - 36

    local sizeSlider = CreateStyledSlider(content, "BFM_Slider_MinimapSize", "Minimap Size (Pixels):",
        "Adjusts the dimensions of the square minimap in pixels (100 - 512px). Automatically re-projects map tiles instantly.",
        100, 512, 5,
        function() return BFM.db.minimap.size or 140 end,
        function(val)
            BFM.db.minimap.size = val
            BFM:ApplySettings()
        end
    )
    sizeSlider:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, sizeSlider)

    local borderSlider = CreateStyledSlider(content, "BFM_Slider_BorderSize", "Border Thickness:",
        "Controls the pixel thickness of the square minimap border.",
        1, 5, 1,
        function() return BFM.db.minimap.borderSize or 1 end,
        function(val)
            BFM.db.minimap.borderSize = val
            BFM:ApplySettings()
        end
    )
    borderSlider:SetPoint("LEFT", sizeSlider, "RIGHT", 40, 0)
    table.insert(syncList, borderSlider)

    yOfs = yOfs - 50

    -- Border Color Swatch Button
    local colorBtn = CreateStyledButton(content, "Border Color", 120, 22, function()
        local cur = BFM.db.minimap.borderColor or { r = 0, g = 0, b = 0, a = 1 }
        OpenColorPicker(cur, function(r, g, b, a)
            BFM.db.minimap.borderColor = { r = r, g = g, b = b, a = a }
            BFM:ApplySettings()
        end)
    end, "Choose a custom color and opacity for the square minimap border.")
    colorBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)

    yOfs = yOfs - 40

    -- Section 2: Movement & Positioning
    CreateSectionHeader(content, "MOVEMENT & POSITIONING", 12, yOfs)
    yOfs = yOfs - 34

    local cbUnlock = CreateStyledCheckbox(content, "Unlock Minimap (Click & Drag)",
        "Enables dragging the minimap freely across the screen. You can also hold Alt + Left Click to drag at any time.",
        function() return BFM.db.minimap.unlocked == true end,
        function(checked)
            BFM.db.minimap.unlocked = checked
            BFM:ApplySettings()
        end
    )
    cbUnlock:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbUnlock)

    local resetBtn = CreateStyledButton(content, "Reset Position", 110, 22, function()
        BleakfibersMapsForever:ResetPosition()
        print("|cFFFFD100Bleakfiber's Maps|r: Minimap position reset to default.")
    end, "Restores the minimap to its default top-right anchor position.")
    resetBtn:SetPoint("LEFT", cbUnlock.Text, "RIGHT", 30, 0)

    yOfs = yOfs - 40

    -- Section 3: Features & Clutter
    CreateSectionHeader(content, "FEATURES & CLUTTER", 12, yOfs)
    yOfs = yOfs - 34

    local cbQuest = CreateStyledCheckbox(content, "Square Quest Zone Indicator",
        "Conforms active quest objective boundaries to the square minimap perimeter, replacing the default circular quest blob rings.",
        function() return BFM.db.minimap.questIndicator ~= false end,
        function(checked)
            BFM.db.minimap.questIndicator = checked
            BFM:ApplySettings()
        end
    )
    cbQuest:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbQuest)

    yOfs = yOfs - 28

    local cbIcons = CreateStyledCheckbox(content, "Follow Square Minimap Perimeter",
        "Constrains addon minimap buttons along the square perimeter rather than orbiting in a circle.",
        function() return BFM.db.minimap.squareIcons ~= false end,
        function(checked)
            BFM.db.minimap.squareIcons = checked
            BFM:ApplySettings()
        end
    )
    cbIcons:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbIcons)

    yOfs = yOfs - 28

    local cbDiel = CreateStyledCheckbox(content, "Hide Day/Night Cycle (DielFrame)",
        "Hides the sun and moon dial texture docked to the MinimapCluster.",
        function() return BFM.db.minimap.hideDielFrame ~= false end,
        function(checked)
            BFM.db.minimap.hideDielFrame = checked
            BFM:ApplySettings()
        end
    )
    cbDiel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbDiel)

    yOfs = yOfs - 28

    local cbZoom = CreateStyledCheckbox(content, "Enable Mouse Wheel Zoom",
        "Allows scrolling the mouse wheel up and down on the minimap to zoom in and out with clamped boundaries.",
        function() return BFM.db.minimap.enableMouseWheelZoom ~= false end,
        function(checked)
            BFM.db.minimap.enableMouseWheelZoom = checked
            BFM:ApplySettings()
        end
    )
    cbZoom:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbZoom)

    yOfs = yOfs - 35
    content:SetHeight(math.abs(yOfs))

    parent.Sync = function()
        for _, widget in ipairs(syncList) do
            if widget.Sync then widget:Sync() end
        end
    end

    return parent
end

--[[-----------------------------------------------------------------------------
    Tab 2: Coordinates & Overlays
-------------------------------------------------------------------------------]]
function BFM:BuildCoordinatesTab(parent)
    local scrollFrame = CreateFrame("ScrollFrame", "BFM_CoordsTabScroll", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 0)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(490, 360)
    scrollFrame:SetScrollChild(content)

    local syncList = {}
    local yOfs = -10

    -- Section 1: Minimap Coordinates HUD
    CreateSectionHeader(content, "MINIMAP COORDINATES HUD", 12, yOfs)
    yOfs = yOfs - 34

    local cbMinimapCoords = CreateStyledCheckbox(content, "Show Minimap Coordinates & Subzone Bar",
        "Displays live player coordinates (xx.x, yy.y) and reactive subzone text docked at the bottom of the minimap.",
        function() return BFM.db.minimap.showCoords ~= false end,
        function(checked)
            BFM.db.minimap.showCoords = checked
            BFM:ApplySettings()
        end
    )
    cbMinimapCoords:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbMinimapCoords)

    local note1 = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note1:SetPoint("TOPLEFT", cbMinimapCoords, "BOTTOMLEFT", 26, -4)
    note1:SetText("Updates at a throttled 0.1s tick rate. Left-click to toggle World Map.")
    note1:SetTextColor(COLORS.dimText[1], COLORS.dimText[2], COLORS.dimText[3])

    yOfs = yOfs - 50

    -- Section 2: World Map Overlay
    CreateSectionHeader(content, "WORLD MAP CANVAS OVERLAY", 12, yOfs)
    yOfs = yOfs - 34

    local cbWorldCoords = CreateStyledCheckbox(content, "Show World Map Coordinate Overlay",
        "Displays live player coordinates and cursor-hover coordinates docked at the bottom of the World Map canvas.",
        function() return BFM.db.worldmap.showCoords ~= false end,
        function(checked)
            BFM.db.worldmap.showCoords = checked
            BFM:ApplySettings()
        end
    )
    cbWorldCoords:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbWorldCoords)

    local note2 = content:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note2:SetPoint("TOPLEFT", cbWorldCoords, "BOTTOMLEFT", 26, -4)
    note2:SetText("Uses modern MapCanvasDataProviderMixin architecture with normalized canvas projection.")
    note2:SetTextColor(COLORS.dimText[1], COLORS.dimText[2], COLORS.dimText[3])

    yOfs = yOfs - 50
    content:SetHeight(math.abs(yOfs))

    parent.Sync = function()
        for _, widget in ipairs(syncList) do
            if widget.Sync then widget:Sync() end
        end
    end

    return parent
end

--[[-----------------------------------------------------------------------------
    Tab 3: About & Commands
-------------------------------------------------------------------------------]]
function BFM:BuildAboutTab(parent)
    local scrollFrame = CreateFrame("ScrollFrame", "BFM_AboutTabScroll", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 0)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(490, 420)
    scrollFrame:SetScrollChild(content)

    local yOfs = -10

    -- Section 1: Addon Info
    CreateSectionHeader(content, "ABOUT BLEAKFIBER'S MAPS", 12, yOfs)
    yOfs = yOfs - 34

    local desc = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    desc:SetWidth(460)
    desc:SetJustifyH("LEFT")
    desc:SetText("Bleakfiber's Maps is a lightweight, modular square minimap and coordinates suite built specifically for World of Warcraft Forever (Interface 16001).")
    desc:SetTextColor(COLORS.whiteText[1], COLORS.whiteText[2], COLORS.whiteText[3])

    yOfs = yOfs - 45

    local authorInfo = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    authorInfo:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    authorInfo:SetText(string.format("|cFFFFD100Author:|r Bleakfiber    |cFFFFD100Version:|r %s    |cFFFFD100Interface:|r 16001", BFM.Version or "1.0.02"))

    yOfs = yOfs - 22

    local masterStatus = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    masterStatus:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    local bacLoaded = _G["BleakfibersAddonConfigForever"] ~= nil
    masterStatus:SetText(string.format("|cFFFFD100Master Config Hub:|r %s", bacLoaded and "|cFF00FF00Connected (/bac)|r" or "|cFF8899A6Standalone Mode|r"))

    yOfs = yOfs - 35

    -- Section 2: Slash Commands
    CreateSectionHeader(content, "SLASH COMMANDS", 12, yOfs)
    yOfs = yOfs - 34

    local commands = {
        { cmd = "/bfm", desc = "Open this configuration window" },
        { cmd = "/bfm unlock", desc = "Toggle click-to-drag minimap movement" },
        { cmd = "/bfm size <100-512>", desc = "Adjust minimap pixel size" },
        { cmd = "/bfm resetpos", desc = "Restore default top-right minimap position" },
        { cmd = "/bfm quest", desc = "Toggle square quest zone indicator" },
        { cmd = "/bfm diel", desc = "Toggle day/night cycle dial (DielFrame)" },
        { cmd = "/bfm icons", desc = "Toggle square minimap icon perimeter" },
        { cmd = "/bfm coords", desc = "Toggle minimap coordinate & subzone bar" },
        { cmd = "/bfm status", desc = "Print current active settings to chat" },
    }

    for _, entry in ipairs(commands) do
        local line = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        line:SetPoint("TOPLEFT", content, "TOPLEFT", 20, yOfs)
        line:SetText(string.format("|cFFFFD100%s|r  -  %s", entry.cmd, entry.desc))
        yOfs = yOfs - 18
    end

    yOfs = yOfs - 10
    content:SetHeight(math.abs(yOfs))

    return parent
end

--[[-----------------------------------------------------------------------------
    Standalone Master Frame Initialization
-------------------------------------------------------------------------------]]
function BFM:CreateStandaloneConfigFrame()
    if standaloneFrame then return standaloneFrame end

    local db = (BFM.db and BFM.db.configWindow) or {}
    local width = db.width or 760
    local height = db.height or 520
    local point = db.point or "CENTER"
    local relPoint = db.relativePoint or "CENTER"
    local xOfs = db.xOfs or 0
    local yOfs = db.yOfs or 0

    local f = CreateFrame("Frame", "BleakfibersMapsConfigFrame", UIParent, BACKDROP_TEMPLATE)
    f:SetSize(width, height)
    f:SetPoint(point, UIParent, relPoint, xOfs, yOfs)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetResizable(true)

    tinsert(UISpecialFrames, "BleakfibersMapsConfigFrame")

    if f.SetResizeBounds then
        f:SetResizeBounds(640, 420, 1200, 850)
    else
        f:SetMinResize(640, 420)
        f:SetMaxResize(1200, 850)
    end

    f:SetBackdrop(MAIN_WINDOW_BACKDROP)
    f:SetBackdropColor(unpack(COLORS.bgSlate))
    f:SetBackdropBorderColor(unpack(COLORS.goldBorder))

    -- Title Bar Area (Draggable)
    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetHeight(32)
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 6, -6)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -32, -6)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")

    titleBar:SetScript("OnDragStart", function()
        f:StartMoving()
    end)

    titleBar:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local pt, _, relPt, x, y = f:GetPoint()
        if BFM.db then
            BFM.db.configWindow = BFM.db.configWindow or {}
            BFM.db.configWindow.point = pt
            BFM.db.configWindow.relativePoint = relPt or pt
            BFM.db.configWindow.xOfs = math.floor(x + 0.5)
            BFM.db.configWindow.yOfs = math.floor(y + 0.5)
        end
    end)

    -- Title Icon / Emblem
    local titleIcon = titleBar:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(18, 18)
    titleIcon:SetPoint("LEFT", titleBar, "LEFT", 6, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
    titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Title Text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    titleText:SetText("|cFFFFD100Bleakfiber's Maps|r  |cFF8899A6Forever|r")

    -- Version Subtitle
    local versionText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    versionText:SetPoint("LEFT", titleText, "RIGHT", 8, -1)
    versionText:SetText("v" .. (BFM.Version or "1.0.02"))

    -- Gold Divider below Title Bar
    local titleDivider = f:CreateTexture(nil, "ARTWORK")
    titleDivider:SetHeight(1)
    titleDivider:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -36)
    titleDivider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -36)
    titleDivider:SetColorTexture(COLORS.goldBorder[1], COLORS.goldBorder[2], COLORS.goldBorder[3], 0.6)

    -- Close Button
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function()
        f:Hide()
    end)

    -- Bottom-right Resize Grip
    local resizeGrip = CreateFrame("Button", nil, f)
    resizeGrip:SetSize(16, 16)
    resizeGrip:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -4, 4)
    resizeGrip:EnableMouse(true)

    local gripTex = resizeGrip:CreateTexture(nil, "ARTWORK")
    gripTex:SetAllPoints(resizeGrip)
    gripTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    resizeGrip:SetScript("OnEnter", function()
        gripTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    end)
    resizeGrip:SetScript("OnLeave", function()
        gripTex:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    end)
    resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            f:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
        if BFM.db then
            BFM.db.configWindow = BFM.db.configWindow or {}
            BFM.db.configWindow.width = math.floor(f:GetWidth() + 0.5)
            BFM.db.configWindow.height = math.floor(f:GetHeight() + 0.5)
        end
    end)

    -- Footer hint text
    local footerText = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    footerText:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 12, 8)
    footerText:SetText("|cFF667788Use /bfm or /bleakfibersmaps to toggle this window|r")

    -- Left Sidebar Frame
    local sidebar = CreateFrame("Frame", nil, f, BACKDROP_TEMPLATE)
    sidebar:SetWidth(190)
    sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 10, -44)
    sidebar:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 24)
    sidebar:SetBackdrop(INSET_BACKDROP)
    sidebar:SetBackdropColor(unpack(COLORS.sidebarBg))
    sidebar:SetBackdropBorderColor(unpack(COLORS.goldMuted))
    f.sidebar = sidebar

    -- Sidebar Header
    CreateSectionHeader(sidebar, "CATEGORIES", 12, -10)

    -- Sidebar Scrollable Frame
    local sidebarScroll = CreateFrame("ScrollFrame", "BFM_SidebarScrollFrame", sidebar, "UIPanelScrollFrameTemplate")
    sidebarScroll:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 6, -30)
    sidebarScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -26, 8)

    local scrollChild = CreateFrame("Frame", nil, sidebarScroll)
    scrollChild:SetSize(155, 1)
    sidebarScroll:SetScrollChild(scrollChild)
    f.sidebarScrollChild = scrollChild

    -- Right Content Pane
    local contentPane = CreateFrame("Frame", nil, f, BACKDROP_TEMPLATE)
    contentPane:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 8, 0)
    contentPane:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 24)
    contentPane:SetBackdrop(INSET_BACKDROP)
    contentPane:SetBackdropColor(unpack(COLORS.contentBg))
    contentPane:SetBackdropBorderColor(unpack(COLORS.goldMuted))
    f.contentPane = contentPane

    -- Content Header Bar
    local contentHeader = CreateFrame("Frame", nil, contentPane)
    contentHeader:SetHeight(32)
    contentHeader:SetPoint("TOPLEFT", contentPane, "TOPLEFT", 12, -6)
    contentHeader:SetPoint("TOPRIGHT", contentPane, "TOPRIGHT", -12, -6)
    f.contentHeader = contentHeader

    local contentTitle = contentHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentTitle:SetPoint("LEFT", contentHeader, "LEFT", 0, 0)
    contentTitle:SetText("")
    contentTitle:SetTextColor(COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
    f.contentTitle = contentTitle

    -- Refresh Button in Content Header
    local refreshBtn = CreateStyledButton(contentHeader, "Refresh", 75, 22, function()
        BleakfibersMapsForever:ApplySettings()
        if f.contentArea and BFM.currentTab and BFM.tabContainers[BFM.currentTab] then
            local active = BFM.tabContainers[BFM.currentTab]
            if active.Sync then active:Sync() end
        end
        print("|cFFFFD100Bleakfiber's Maps|r: Settings refreshed.")
    end, "Reapplies all visual settings and refreshes map projections.")
    refreshBtn:SetPoint("RIGHT", contentHeader, "RIGHT", 0, 0)
    f.refreshBtn = refreshBtn

    -- Content Header Divider
    local contentDivider = contentPane:CreateTexture(nil, "ARTWORK")
    contentDivider:SetHeight(1)
    contentDivider:SetPoint("TOPLEFT", contentPane, "TOPLEFT", 10, -38)
    contentDivider:SetPoint("TOPRIGHT", contentPane, "TOPRIGHT", -10, -38)
    contentDivider:SetColorTexture(COLORS.goldMuted[1], COLORS.goldMuted[2], COLORS.goldMuted[3], 0.5)
    f.contentDivider = contentDivider

    -- Content Container Area
    local contentArea = CreateFrame("Frame", nil, contentPane)
    contentArea:SetPoint("TOPLEFT", contentPane, "TOPLEFT", 10, -42)
    contentArea:SetPoint("BOTTOMRIGHT", contentPane, "BOTTOMRIGHT", -10, 10)
    f.contentArea = contentArea

    -- Build Category Tabs
    local tabs = {
        { id = "minimap", name = "Minimap Settings", builder = BFM.BuildMinimapTab },
        { id = "coordinates", name = "Coordinates & HUD", builder = BFM.BuildCoordinatesTab },
        { id = "about", name = "About & Commands", builder = BFM.BuildAboutTab },
    }

    local tabHeight = 32
    local tabSpacing = 4
    local currentY = 0

    for _, tabData in ipairs(tabs) do
        local tabID = tabData.id

        -- Create Tab Button in Sidebar
        local btn = CreateFrame("Button", nil, scrollChild, BACKDROP_TEMPLATE)
        btn:SetHeight(tabHeight)
        btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -currentY)
        btn:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, -currentY)
        btn:SetBackdrop(INSET_BACKDROP)

        btn.title = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.title:SetPoint("LEFT", btn, "LEFT", 10, 0)
        btn.title:SetPoint("RIGHT", btn, "RIGHT", -10, 0)
        btn.title:SetJustifyH("LEFT")
        btn.title:SetText(tabData.name)

        btn.activeIndicator = btn:CreateTexture(nil, "OVERLAY")
        btn.activeIndicator:SetWidth(3)
        btn.activeIndicator:SetPoint("TOPLEFT", btn, "TOPLEFT", 2, -2)
        btn.activeIndicator:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 2, 2)
        btn.activeIndicator:SetColorTexture(COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3], 1.0)
        btn.activeIndicator:Hide()

        btn:SetScript("OnClick", function()
            BFM:SelectTab(tabID)
        end)

        btn:SetScript("OnEnter", function(tab)
            if BFM.currentTab ~= tabID then
                tab:SetBackdropColor(unpack(COLORS.tabHighlight))
                tab:SetBackdropBorderColor(unpack(COLORS.goldBorder))
            end
        end)

        btn:SetScript("OnLeave", function(tab)
            if BFM.currentTab ~= tabID then
                tab:SetBackdropColor(unpack(COLORS.tabNormal))
                tab:SetBackdropBorderColor(unpack(COLORS.goldMuted))
            end
        end)

        BFM.tabButtons[tabID] = btn

        -- Create Category Container
        local container = CreateFrame("Frame", "BFM_Container_" .. tabID, contentArea)
        container:SetAllPoints(contentArea)
        tabData.builder(BFM, container)
        container:Hide()
        BFM.tabContainers[tabID] = container

        currentY = currentY + tabHeight + tabSpacing
    end

    scrollChild:SetHeight(math.max(currentY, 1))

    f:SetScript("OnShow", function()
        local lastTab = (BFM.db and BFM.db.configWindow and BFM.db.configWindow.lastTab) or "minimap"
        BFM:SelectTab(lastTab)
    end)

    f:SetScript("OnHide", function()
        if BFM.db and BFM.db.minimap and BFM.db.minimap.unlocked then
            BFM.db.minimap.unlocked = false
            BFM:ApplySettings()
        end
    end)

    standaloneFrame = f
    return f
end

--[[-----------------------------------------------------------------------------
    Tab Selection & Highlights
-------------------------------------------------------------------------------]]
function BFM:SelectTab(tabID)
    if not standaloneFrame then
        self:CreateStandaloneConfigFrame()
    end

    if not self.tabContainers[tabID] then
        tabID = "minimap"
    end

    self.currentTab = tabID

    if BFM.db then
        BFM.db.configWindow = BFM.db.configWindow or {}
        BFM.db.configWindow.lastTab = tabID
    end

    local tabTitles = {
        minimap = "Minimap Settings",
        coordinates = "Coordinates & Overlays",
        about = "About Bleakfiber's Maps",
    }
    standaloneFrame.contentTitle:SetText(tabTitles[tabID] or "Settings")

    for id, container in pairs(self.tabContainers) do
        if id == tabID then
            container:Show()
            if container.Sync then container:Sync() end
        else
            container:Hide()
        end
    end

    for id, btn in pairs(self.tabButtons) do
        if id == tabID then
            btn:SetBackdropColor(unpack(COLORS.tabActive))
            btn:SetBackdropBorderColor(unpack(COLORS.goldBorder))
            btn.title:SetTextColor(COLORS.goldText[1], COLORS.goldText[2], COLORS.goldText[3])
            btn.activeIndicator:Show()
        else
            btn:SetBackdropColor(unpack(COLORS.tabNormal))
            btn:SetBackdropBorderColor(unpack(COLORS.goldMuted))
            btn.title:SetTextColor(COLORS.whiteText[1], COLORS.whiteText[2], COLORS.whiteText[3])
            btn.activeIndicator:Hide()
        end
    end
end

--[[-----------------------------------------------------------------------------
    Standalone Toggle & Show
-------------------------------------------------------------------------------]]
function BFM:ToggleConfigUI()
    local f = self:CreateStandaloneConfigFrame()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

function BFM:ShowConfigUI()
    local f = self:CreateStandaloneConfigFrame()
    f:Show()
end

--[[-----------------------------------------------------------------------------
    Master Config (BAC) Embed UI Builder
-------------------------------------------------------------------------------]]
function BFM:BuildEmbedUI(parent)
    if not parent then return end

    local scrollFrame = CreateFrame("ScrollFrame", "BFM_BACEmbedScrollFrame", parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 0)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(parent:GetWidth() > 30 and (parent:GetWidth() - 25) or 480, 560)
    scrollFrame:SetScrollChild(content)

    local syncList = {}
    local yOfs = -10

    -- Section 1: Sizing & Geometry
    CreateSectionHeader(content, "MINIMAP SIZING & GEOMETRY", 12, yOfs)
    yOfs = yOfs - 36

    local sizeSlider = CreateStyledSlider(content, "BFM_BAC_MinimapSize", "Minimap Size (Pixels):",
        "Adjusts the dimensions of the square minimap in pixels (100 - 512px).",
        100, 512, 5,
        function() return BFM.db.minimap.size or 140 end,
        function(val)
            BFM.db.minimap.size = val
            BFM:ApplySettings()
        end
    )
    sizeSlider:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, sizeSlider)

    local borderSlider = CreateStyledSlider(content, "BFM_BAC_BorderSize", "Border Thickness:",
        "Controls the pixel thickness of the square minimap border.",
        1, 5, 1,
        function() return BFM.db.minimap.borderSize or 1 end,
        function(val)
            BFM.db.minimap.borderSize = val
            BFM:ApplySettings()
        end
    )
    borderSlider:SetPoint("LEFT", sizeSlider, "RIGHT", 40, 0)
    table.insert(syncList, borderSlider)

    yOfs = yOfs - 50

    local colorBtn = CreateStyledButton(content, "Border Color", 120, 22, function()
        local cur = BFM.db.minimap.borderColor or { r = 0, g = 0, b = 0, a = 1 }
        OpenColorPicker(cur, function(r, g, b, a)
            BFM.db.minimap.borderColor = { r = r, g = g, b = b, a = a }
            BFM:ApplySettings()
        end)
    end, "Choose a custom color and opacity for the square minimap border.")
    colorBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)

    yOfs = yOfs - 40

    -- Section 2: Movement & Positioning
    CreateSectionHeader(content, "MOVEMENT & POSITIONING", 12, yOfs)
    yOfs = yOfs - 34

    local cbUnlock = CreateStyledCheckbox(content, "Unlock Minimap (Click & Drag)",
        "Enables dragging the minimap freely across the screen. You can also hold Alt + Left Click to drag at any time.",
        function() return BFM.db.minimap.unlocked == true end,
        function(checked)
            BFM.db.minimap.unlocked = checked
            BFM:ApplySettings()
        end
    )
    cbUnlock:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbUnlock)

    local resetBtn = CreateStyledButton(content, "Reset Position", 110, 22, function()
        BleakfibersMapsForever:ResetPosition()
        print("|cFFFFD100Bleakfiber's Maps|r: Minimap position reset to default.")
    end, "Restores the minimap to its default top-right anchor position.")
    resetBtn:SetPoint("LEFT", cbUnlock.Text, "RIGHT", 30, 0)

    yOfs = yOfs - 40

    -- Section 3: Features & Clutter
    CreateSectionHeader(content, "FEATURES & CLUTTER", 12, yOfs)
    yOfs = yOfs - 34

    local cbQuest = CreateStyledCheckbox(content, "Square Quest Zone Indicator",
        "Conforms quest objective boundaries to the square minimap perimeter, replacing the default circular quest blob rings.",
        function() return BFM.db.minimap.questIndicator ~= false end,
        function(checked)
            BFM.db.minimap.questIndicator = checked
            BFM:ApplySettings()
        end
    )
    cbQuest:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbQuest)

    yOfs = yOfs - 28

    local cbIcons = CreateStyledCheckbox(content, "Follow Square Minimap Perimeter",
        "Constrains addon minimap buttons along the square perimeter rather than orbiting in a circle.",
        function() return BFM.db.minimap.squareIcons ~= false end,
        function(checked)
            BFM.db.minimap.squareIcons = checked
            BFM:ApplySettings()
        end
    )
    cbIcons:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbIcons)

    yOfs = yOfs - 28

    local cbDiel = CreateStyledCheckbox(content, "Hide Day/Night Cycle (DielFrame)",
        "Hides the sun and moon dial texture docked to the MinimapCluster.",
        function() return BFM.db.minimap.hideDielFrame ~= false end,
        function(checked)
            BFM.db.minimap.hideDielFrame = checked
            BFM:ApplySettings()
        end
    )
    cbDiel:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbDiel)

    yOfs = yOfs - 28

    local cbZoom = CreateStyledCheckbox(content, "Enable Mouse Wheel Zoom",
        "Allows scrolling the mouse wheel up and down on the minimap to zoom in and out with clamped boundaries.",
        function() return BFM.db.minimap.enableMouseWheelZoom ~= false end,
        function(checked)
            BFM.db.minimap.enableMouseWheelZoom = checked
            BFM:ApplySettings()
        end
    )
    cbZoom:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbZoom)

    yOfs = yOfs - 40

    -- Section 4: Coordinates & HUD
    CreateSectionHeader(content, "COORDINATES & HUD OVERLAYS", 12, yOfs)
    yOfs = yOfs - 34

    local cbMinimapCoords = CreateStyledCheckbox(content, "Show Minimap Coordinates & Subzone Bar",
        "Displays live player coordinates (xx.x, yy.y) and reactive subzone text docked at the bottom of the minimap.",
        function() return BFM.db.minimap.showCoords ~= false end,
        function(checked)
            BFM.db.minimap.showCoords = checked
            BFM:ApplySettings()
        end
    )
    cbMinimapCoords:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbMinimapCoords)

    yOfs = yOfs - 28

    local cbWorldCoords = CreateStyledCheckbox(content, "Show World Map Coordinate Overlay",
        "Displays live player coordinates and cursor-hover coordinates docked at the bottom of the World Map canvas.",
        function() return BFM.db.worldmap.showCoords ~= false end,
        function(checked)
            BFM.db.worldmap.showCoords = checked
            BFM:ApplySettings()
        end
    )
    cbWorldCoords:SetPoint("TOPLEFT", content, "TOPLEFT", 16, yOfs)
    table.insert(syncList, cbWorldCoords)

    yOfs = yOfs - 35
    content:SetHeight(math.abs(yOfs))

    local function SyncAll()
        for _, widget in ipairs(syncList) do
            if widget.Sync then widget:Sync() end
        end
    end

    SyncAll()
    parent:HookScript("OnShow", SyncAll)
    parent:HookScript("OnHide", function()
        if BFM.db and BFM.db.minimap and BFM.db.minimap.unlocked then
            BFM.db.minimap.unlocked = false
            BFM:ApplySettings()
        end
    end)
    parent.refresh = SyncAll

    return parent
end
