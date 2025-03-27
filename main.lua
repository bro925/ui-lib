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
    closeButton.Text = "X"
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

function DarkUI:SwitchTab(tabIndex, noAnimation)
    -- Update current tab
    self.currentTab = tabIndex
    local tab = self.config.tabs[tabIndex]
    
    -- Calculate the correct position for the indicator
    game:GetService("RunService").Heartbeat:Wait()
    local tabButton = self.tabButtonsInstances[tabIndex]
    local tabButtonPos = tabButton.AbsolutePosition.X - self.mainFrame.AbsolutePosition.X
    
    -- Animate the indicator
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
    
    -- Clear previous content by unparenting
    for _, child in ipairs(self.contentFrame:GetChildren()) do
        child.Parent = nil
    end
    
    -- Add new content if available
    if self.contents[tabIndex] then
        self.contents[tabIndex].Parent = self.contentFrame
    end
end

function DarkUI:SetTabContent(tabIndex, content)
    self.contents[tabIndex] = content
    content.Parent = nil
    
    -- Force refresh if it's the current tab
    if self.currentTab == tabIndex then
        self:SwitchTab(tabIndex, true)
    end
end

function DarkUI:CreateCheckbox(label, initialState, callback)
    local checkboxFrame = Instance.new("Frame")
    checkboxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    checkboxFrame.Size = UDim2.new(1, -5, 0, 32) -- Wider negative padding for centering
    checkboxFrame.Position = UDim2.new(0.5, 0, 0, 0) -- Centered horizontally
    checkboxFrame.AnchorPoint = Vector2.new(0.5, 0) -- Center anchor
    
    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = checkboxFrame
    
    -- Label (left aligned)
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.TextColor3 = Color3.fromRGB(220, 220, 220)
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.Size = UDim2.new(0.6, -10, 1, -10)
    labelText.Position = UDim2.new(0, 15, 0.5, -10)
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.BackgroundTransparency = 1
    labelText.Parent = checkboxFrame
    
    -- Toggle container (right aligned)
    local toggleContainer = Instance.new("Frame")
    toggleContainer.BackgroundTransparency = 1
    toggleContainer.Size = UDim2.new(0.4, 0, 1, 0)
    toggleContainer.Position = UDim2.new(1, -15, 0, 0)
    toggleContainer.AnchorPoint = Vector2.new(1, 0)
    toggleContainer.Parent = checkboxFrame
    
    -- Toggle background
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Size = UDim2.new(0, 40, 0, 20)
    toggleBackground.Position = UDim2.new(1, 0, 0.5, 0)
    toggleBackground.AnchorPoint = Vector2.new(1, 0.5)
    toggleBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    toggleBackground.Parent = toggleContainer
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = toggleBackground
    
    -- Toggle knob (always white)
    local toggleButton = Instance.new("Frame")
    toggleButton.Size = UDim2.new(0, 16, 0, 16)
    toggleButton.AnchorPoint = Vector2.new(0, 0.5)
    toggleButton.Position = initialState and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
    toggleButton.BackgroundColor3 = Color3.new(1, 1, 1) -- Always white
    toggleButton.Parent = toggleBackground
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(1, 0)
    buttonCorner.Parent = toggleButton
    
    local state = initialState or false
    local isHovered = false
    
    local function updateVisuals()
        local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        -- Animate knob position and background color
        if state then
            TweenService:Create(toggleButton, tweenInfo, {
                Position = UDim2.new(1, -18, 0.5, 0)
            }):Play()
            TweenService:Create(toggleBackground, tweenInfo, {
                BackgroundColor3 = Color3.fromRGB(70, 130, 200)
            }):Play()
        else
            TweenService:Create(toggleButton, tweenInfo, {
                Position = UDim2.new(0, 2, 0.5, 0)
            }):Play()
            TweenService:Create(toggleBackground, tweenInfo, {
                BackgroundColor3 = isHovered and Color3.fromRGB(70, 70, 80) or Color3.fromRGB(50, 50, 60)
            }):Play()
        end
    end
    
    local function toggle()
        state = not state
        updateVisuals()
        if callback then
            callback(state)
        end
    end
    
    -- Mouse interactions
    checkboxFrame.MouseEnter:Connect(function()
        isHovered = true
        updateVisuals()
    end)
    
    checkboxFrame.MouseLeave:Connect(function()
        isHovered = false
        updateVisuals()
    end)
    
    checkboxFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    updateVisuals()
    
    return {
        instance = checkboxFrame,
        GetState = function() return state end,
        SetState = function(newState)
            state = newState
            updateVisuals()
            if callback then
                callback(state)
            end
        end
    }
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
