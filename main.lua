local DarkUI = {}
DarkUI.__index = DarkUI

-- Library dependencies
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function DarkUI.new(config)
    local self = setmetatable({}, DarkUI)
    
    -- Default configuration
    self.config = {
        title = config.title or "Dark UI",
        size = config.size or UDim2.new(0, 400, 0, 300),
        position = config.position or UDim2.new(0.3, 0, 0.3, 0),
        anchorPoint = config.anchorPoint or Vector2.new(0.5, 0.5),
        tabs = config.tabs or {
            {name = "Home", color = Color3.fromRGB(70, 130, 200)},
            {name = "Settings", color = Color3.fromRGB(200, 130, 70)},
            {name = "About", color = Color3.fromRGB(130, 200, 70)}
        },
        resetOnSpawn = config.resetOnSpawn or false
    }
    
    self.currentTab = 1
    self.tabButtonsInstances = {}
    self.contents = {}
    self.minimized = false
    
    self:Initialize()
    return self
end

function DarkUI:Initialize()
    -- Create the main GUI
    local player = game:GetService("Players").LocalPlayer
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "SmoothDarkUI"
    self.gui.ResetOnSpawn = self.config.resetOnSpawn
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.gui.Parent = player:WaitForChild("PlayerGui")

    -- Main Frame
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    self.mainFrame.BorderSizePixel = 0
    self.mainFrame.Position = self.config.position
    self.mainFrame.Size = UDim2.new(0, 0, 0, 0) -- Start at 0 for spawn animation
    self.mainFrame.AnchorPoint = self.config.anchorPoint
    self.mainFrame.ClipsDescendants = true

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = self.mainFrame

    -- Drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Parent = self.mainFrame
    shadow.ZIndex = -1

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = self.mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    -- Title Text
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = self.config.title
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.TextSize = 14
    title.Font = Enum.Font.Gotham
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 100, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.Gotham
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 1, 0)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Parent = titleBar

    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Text = "─"
    minimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
    minimizeButton.TextSize = 14
    minimizeButton.Font = Enum.Font.Gotham
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Size = UDim2.new(0, 30, 1, 0)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.Parent = titleBar

    -- Tab Bar
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    tabBar.BorderSizePixel = 0
    tabBar.Size = UDim2.new(1, 0, 0, 30)
    tabBar.Position = UDim2.new(0, 0, 0, 30)
    tabBar.Parent = self.mainFrame

    -- Tab Buttons Container
    local tabButtons = Instance.new("Frame")
    tabButtons.Name = "TabButtons"
    tabButtons.BackgroundTransparency = 1
    tabButtons.Size = UDim2.new(1, 0, 1, 0)
    tabButtons.Position = UDim2.new(0, 0, 0, 0)
    tabButtons.Parent = tabBar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Horizontal
    tabListLayout.Padding = UDim.new(0, 0)
    tabListLayout.Parent = tabButtons

    -- Tab Indicator
    self.tabIndicator = Instance.new("Frame")
    self.tabIndicator.Name = "TabIndicator"
    self.tabIndicator.BackgroundColor3 = self.config.tabs[1].color
    self.tabIndicator.BorderSizePixel = 0
    self.tabIndicator.Size = UDim2.new(0, 80, 0, 2)
    self.tabIndicator.Position = UDim2.new(0, 0, 1, -2)
    self.tabIndicator.AnchorPoint = Vector2.new(0, 1)
    self.tabIndicator.Parent = tabBar

    local tabIndicatorCorner = Instance.new("UICorner")
    tabIndicatorCorner.CornerRadius = UDim.new(0, 2)
    tabIndicatorCorner.Parent = self.tabIndicator

    -- Content Area
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    self.contentFrame.BorderSizePixel = 0
    self.contentFrame.Size = UDim2.new(1, 0, 1, -60)
    self.contentFrame.Position = UDim2.new(0, 0, 0, 60)
    self.contentFrame.Parent = self.mainFrame

    -- Create tab buttons
    for i, tab in ipairs(self.config.tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tab.name
        tabButton.Text = tab.name
        tabButton.TextColor3 = i == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
        tabButton.TextSize = 12
        tabButton.Font = Enum.Font.Gotham
        tabButton.BackgroundTransparency = 1
        tabButton.Size = UDim2.new(0, 80, 1, 0)
        tabButton.Parent = tabButtons
        
        -- Store reference to tab button
        self.tabButtonsInstances[i] = tabButton
        
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(i)
        end)
    end

    -- Initialize first tab
    self:SwitchTab(1, true)

    -- Dragging functionality
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        self.mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Close and minimize functionality
    closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)

    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    -- Hover effects for buttons
    local function setupButtonHover(button)
        button.MouseEnter:Connect(function()
            if button == closeButton then
                button.TextColor3 = Color3.fromRGB(255, 100, 100)
            else
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)
        
        button.MouseLeave:Connect(function()
            if button == closeButton then
                button.TextColor3 = Color3.fromRGB(220, 220, 220)
            else
                button.TextColor3 = Color3.fromRGB(220, 220, 220)
            end
        end)
    end

    setupButtonHover(closeButton)
    setupButtonHover(minimizeButton)

    -- Final setup
    self.mainFrame.Parent = self.gui

    -- Animation on spawn
    local spawnTween = TweenService:Create(self.mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = self.config.size
    })
    spawnTween:Play()
end

function DarkUI:CreateSettingsContainer()
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "SettingsContainer"
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = scrollFrame
    
    return scrollFrame
end

function DarkUI:CreateLabel(text, parent)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Parent = parent
    
    return label
end

function DarkUI:AddCheckbox(settingsTab, config)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Parent = settingsTab
    
    local label = self:CreateLabel(config.text or "Checkbox", container)
    label.Position = UDim2.new(0, 0, 0, 5)
    
    local checkbox = Instance.new("TextButton")
    checkbox.Name = "Checkbox"
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(1, -20, 0, 5)
    checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    checkbox.AutoButtonColor = false
    checkbox.Text = ""
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = checkbox
    
    local checkmark = Instance.new("ImageLabel")
    checkmark.Name = "Checkmark"
    checkmark.Image = "rbxassetid://7072716642" -- White checkmark icon
    checkmark.Size = UDim2.new(0, 16, 0, 16)
    checkmark.Position = UDim2.new(0, 2, 0, 2)
    checkmark.BackgroundTransparency = 1
    checkmark.Visible = config.default or false
    checkmark.Parent = checkbox
    
    checkbox.Parent = container
    
    -- Store the setting
    local setting = {
        value = config.default or false,
        onChange = config.onChange or function() end
    }
    self.settings[config.id] = setting
    
    -- Toggle functionality
    checkbox.MouseButton1Click:Connect(function()
        setting.value = not setting.value
        checkmark.Visible = setting.value
        setting.onChange(setting.value)
    end)
    
    return {
        SetValue = function(value)
            setting.value = value
            checkmark.Visible = value
            setting.onChange(value)
        end,
        GetValue = function()
            return setting.value
        end
    }
end

function DarkUI:AddSlider(settingsTab, config)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 50)
    container.Parent = settingsTab
    
    local label = self:CreateLabel(config.text or "Slider", container)
    label.Position = UDim2.new(0, 0, 0, 0)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(config.default or config.min or 0)
    valueLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 0)
    valueLabel.Parent = container
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Name = "Track"
    sliderTrack.Size = UDim2.new(1, 0, 0, 6)
    sliderTrack.Position = UDim2.new(0, 0, 0, 25)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    sliderTrack.BorderSizePixel = 0
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Name = "Fill"
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
    sliderFill.BorderSizePixel = 0
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    local sliderThumb = Instance.new("TextButton")
    sliderThumb.Name = "Thumb"
    sliderThumb.Size = UDim2.new(0, 16, 0, 16)
    sliderThumb.Position = UDim2.new(0.5, -8, 0, -5)
    sliderThumb.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    sliderThumb.Text = ""
    sliderThumb.AutoButtonColor = false
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = sliderThumb
    
    sliderFill.Parent = sliderTrack
    sliderThumb.Parent = sliderTrack
    sliderTrack.Parent = container
    
    -- Store the setting
    local min = config.min or 0
    local max = config.max or 100
    local step = config.step or 1
    local defaultValue = config.default or min
    
    local setting = {
        value = defaultValue,
        onChange = config.onChange or function() end
    }
    self.settings[config.id] = setting
    
    -- Update visual position
    local function updateSlider(value)
        local normalized = (value - min) / (max - min)
        sliderFill.Size = UDim2.new(normalized, 0, 1, 0)
        sliderThumb.Position = UDim2.new(normalized, -8, 0, -5)
        valueLabel.Text = string.format(config.format or "%d", value)
    end
    
    -- Initialize
    updateSlider(defaultValue)
    
    -- Dragging functionality
    local dragging = false
    
    local function updateValue(input)
        local relativeX = input.Position.X - sliderTrack.AbsolutePosition.X
        local normalized = math.clamp(relativeX / sliderTrack.AbsoluteSize.X, 0, 1)
        local steppedValue = min + math.floor((normalized * (max - min) / step + 0.5) * step
        steppedValue = math.clamp(steppedValue, min, max)
        
        if steppedValue ~= setting.value then
            setting.value = steppedValue
            updateSlider(steppedValue)
            setting.onChange(steppedValue)
        end
    end
    
    sliderThumb.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)
    
    sliderTrack.MouseButton1Down:Connect(function(input)
        updateValue(input)
    end)
    
    return {
        SetValue = function(value)
            local clamped = math.clamp(value, min, max)
            setting.value = clamped
            updateSlider(clamped)
            setting.onChange(clamped)
        end,
        GetValue = function()
            return setting.value
        end
    }
end

function DarkUI:AddCombobox(settingsTab, config)
    local container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Parent = settingsTab
    
    local label = self:CreateLabel(config.text or "Combobox", container)
    label.Position = UDim2.new(0, 0, 0, 5)
    
    local button = Instance.new("TextButton")
    button.Name = "ComboboxButton"
    button.Size = UDim2.new(0, 120, 0, 25)
    button.Position = UDim2.new(1, -120, 0, 2)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    button.TextColor3 = Color3.fromRGB(220, 220, 220)
    button.TextSize = 12
    button.Font = Enum.Font.Gotham
    button.Text = config.options[config.default or 1] or "Select"
    button.AutoButtonColor = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    local dropdown = Instance.new("Frame")
    dropdown.Name = "Dropdown"
    dropdown.Size = UDim2.new(1, 0, 0, 0)
    dropdown.Position = UDim2.new(0, 0, 1, 2)
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    dropdown.Visible = false
    dropdown.ClipsDescendants = true
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 4)
    dropdownCorner.Parent = dropdown
    
    local dropdownLayout = Instance.new("UIListLayout")
    dropdownLayout.Parent = dropdown
    
    -- Create options
    for i, option in ipairs(config.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(220, 220, 220)
        optionButton.TextSize = 12
        optionButton.Font = Enum.Font.Gotham
        optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.AutoButtonColor = false
        optionButton.Parent = dropdown
        
        optionButton.MouseButton1Click:Connect(function()
            button.Text = option
            dropdown.Visible = false
            setting.value = i
            setting.onChange(i, option)
        end)
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        end)
    end
    
    dropdown.Parent = button
    button.Parent = container
    
    -- Store the setting
    local setting = {
        value = config.default or 1,
        onChange = config.onChange or function() end
    }
    self.settings[config.id] = setting
    
    -- Toggle dropdown
    button.MouseButton1Click:Connect(function()
        dropdown.Visible = not dropdown.Visible
        if dropdown.Visible then
            dropdown.Size = UDim2.new(1, 0, 0, #config.options * 25)
        else
            dropdown.Size = UDim2.new(1, 0, 0, 0)
        end
    end)
    
    -- Close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dropdown.Visible then
            if not button:IsDescendantOf(input.Parent) then
                dropdown.Visible = false
                dropdown.Size = UDim2.new(1, 0, 0, 0)
            end
        end
    end)
    
    return {
        SetValue = function(index)
            if index >= 1 and index <= #config.options then
                button.Text = config.options[index]
                setting.value = index
                setting.onChange(index, config.options[index])
            end
        end,
        GetValue = function()
            return setting.value, config.options[setting.value]
        end
    }
end

function DarkUI:SwitchTab(tabIndex, noAnimation)
    if self.currentTab == tabIndex then return end -- Skip if already on this tab
    
    -- Update current tab
    self.currentTab = tabIndex
    local tab = self.config.tabs[tabIndex]
    
    -- Calculate the correct position for the indicator
    game:GetService("RunService").Heartbeat:Wait()
    local tabButton = self.tabButtonsInstances[tabIndex]
    local tabButtonPos = tabButton.AbsolutePosition.X - self.mainFrame.AbsolutePosition.X
    
    -- Animate the indicator to the correct position
    if noAnimation then
        self.tabIndicator.Position = UDim2.new(0, tabButtonPos, 1, -2)
        self.tabIndicator.BackgroundColor3 = tab.color
    else
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.tabIndicator, tweenInfo, {
            Position = UDim2.new(0, tabButtonPos, 1, -2),
            BackgroundColor3 = tab.color
        })
        tween:Play()
    end
    
    -- Update tab button colors
    for _, btn in pairs(self.tabButtonsInstances) do
        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
    tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Update content if content was set for this tab
    if self.contents[tabIndex] then
        -- Clear previous content
        for _, child in ipairs(self.contentFrame:GetChildren()) do
            child:Destroy()
        end
        
        -- Add the stored content
        self.contents[tabIndex].Parent = self.contentFrame
    end
end

function DarkUI:SetTabContent(tabIndex, content)
    -- Store the content for this tab
    self.contents[tabIndex] = content
    content.Parent = nil -- Remove from hierarchy for now
    
    -- If this is the current tab, show it immediately
    if self.currentTab == tabIndex then
        self:SwitchTab(tabIndex, true)
    end
end

function DarkUI:ToggleMinimize()
    self.minimized = not self.minimized
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    if self.minimized then
        local tween = TweenService:Create(self.mainFrame, tweenInfo, {
            Size = UDim2.new(self.mainFrame.Size.X.Scale, self.mainFrame.Size.X.Offset, 0, 60)
        })
        tween:Play()
    else
        local tween = TweenService:Create(self.mainFrame, tweenInfo, {
            Size = self.config.size
        })
        tween:Play()
    end
end

function DarkUI:Close()
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(self.mainFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    tween:Play()
    tween.Completed:Wait()
    self.gui:Destroy()
    self.closed = true
end

function DarkUI:IsClosed()
    return self.closed or not self.gui or not self.gui.Parent
end

return DarkUI
