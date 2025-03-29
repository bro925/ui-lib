local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library.new(titleText)
    local lib = {}
    local elements = {}
    local tabCount = 0
    local minimized = false
    
    -- Main GUI
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local TitleBar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local MinimizeButton = Instance.new("TextButton")
    local TabsContainer = Instance.new("Frame")
    local UIListLayout = Instance.new("UIListLayout")
    local ContentContainer = Instance.new("Frame")
    
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Name = "ModernUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.ClipsDescendants = true
    
    -- Draggable functionality
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.Gotham
    Title.Text = titleText or "Modern UI"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Font = Enum.Font.Gotham
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Parent = TitleBar
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
    MinimizeButton.Size = UDim2.new(0, 20, 0, 20)
    MinimizeButton.Font = Enum.Font.Gotham
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 14
    MinimizeButton.AutoButtonColor = false
    
    -- Animation function
    local function tween(obj, props, duration, style)
        local tweenInfo = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad)
        local tween = TweenService:Create(obj, tweenInfo, props)
        tween:Play()
        return tween
    end
    
    -- Draggable GUI
    local function updateInput(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input.Position
        end
    end
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Close button
    CloseButton.MouseButton1Click:Connect(function()
        tween(MainFrame, {Size = UDim2.new(0, 450, 0, 0)}, 0.2):Play()
        wait(0.2)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}, 0.1)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}, 0.1)
    end)
    
    -- Minimize button
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        local newSize = minimized and UDim2.new(0, 450, 0, 30) or UDim2.new(0, 450, 0, 300)
        tween(MainFrame, {Size = newSize}, 0.2)
    end)
    
    -- Tabs container
    TabsContainer.Name = "TabsContainer"
    TabsContainer.Parent = MainFrame
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.Position = UDim2.new(0, 10, 0, 40)
    TabsContainer.Size = UDim2.new(1, -20, 0, 30)
    
    UIListLayout.Parent = TabsContainer
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    
    -- Content container
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Position = UDim2.new(0, 10, 0, 80)
    ContentContainer.Size = UDim2.new(1, -20, 1, -90)
    
    function lib:AddTab(tabName)
        tabCount += 1
        local tab = {}
        
        -- Tab button
        local TabButton = Instance.new("TextButton")
        local TabContainer = Instance.new("ScrollingFrame")
        
        TabButton.Name = tabName
        TabButton.Parent = TabsContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(0, 100, 1, 0)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false
        
        TabContainer.Name = tabName
        TabContainer.Parent = ContentContainer
        TabContainer.Active = true
        TabContainer.BackgroundTransparency = 1
        TabContainer.Size = UDim2.new(1, 0, 1, 0)
        TabContainer.Visible = tabCount == 1
        TabContainer.ScrollBarThickness = 5
        
        local layout = Instance.new("UIListLayout")
        layout.Parent = TabContainer
        layout.Padding = UDim.new(0, 10)
        
        -- Tab switching
        TabButton.MouseButton1Click:Connect(function()
            for _, child in ipairs(ContentContainer:GetChildren()) do
                if child:IsA("ScrollingFrame") then
                    child.Visible = false
                end
            end
            TabContainer.Visible = true
            tween(TabButton, {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}, 0.1)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if not TabContainer.Visible then
                tween(TabButton, {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}, 0.1)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not TabContainer.Visible then
                tween(TabButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}, 0.1)
            end
        end)
        
        if tabCount == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end
        
        -- Tab methods
        function tab:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Parent = TabContainer
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Font = Enum.Font.Gotham
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 14
            label.TextXAlignment = Enum.TextXAlignment.Left
            return label
        end
        
        function tab:AddSection(titleText)
            local section = Instance.new("Frame")
            local sectionLayout = Instance.new("UIListLayout")
            local sectionTitle = Instance.new("TextLabel")
            local divider = Instance.new("Frame")
            
            section.Name = "Section"
            section.Parent = TabContainer
            section.BackgroundTransparency = 1
            section.Size = UDim2.new(1, 0, 0, 20)
            
            sectionLayout.Parent = section
            sectionLayout.FillDirection = Enum.FillDirection.Horizontal
            sectionLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            sectionLayout.Padding = UDim.new(0, 5)
            
            sectionTitle.Name = "Title"
            sectionTitle.Parent = section
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Size = UDim2.new(0, 0, 0, 20)
            sectionTitle.AutomaticSize = Enum.AutomaticSize.X
            sectionTitle.Font = Enum.Font.Gotham
            sectionTitle.Text = titleText
            sectionTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
            sectionTitle.TextSize = 12
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            divider.Name = "Divider"
            divider.Parent = section
            divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            divider.BorderSizePixel = 0
            divider.Size = UDim2.new(1, 0, 0, 1)
            
            return section
        end
        
        function tab:AddCheckbox(text, callback)
            local checkbox = Instance.new("TextButton")
            local box = Instance.new("Frame")
            local check = Instance.new("ImageLabel")
            
            checkbox.Name = "Checkbox"
            checkbox.Parent = TabContainer
            checkbox.BackgroundTransparency = 1
            checkbox.Size = UDim2.new(1, 0, 0, 30)
            checkbox.Font = Enum.Font.Gotham
            checkbox.Text = "  " .. text
            checkbox.TextColor3 = Color3.fromRGB(200, 200, 200)
            checkbox.TextSize = 14
            checkbox.TextXAlignment = Enum.TextXAlignment.Left
            checkbox.AutoButtonColor = false
            
            box.Name = "Box"
            box.Parent = checkbox
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            box.BorderSizePixel = 0
            box.Position = UDim2.new(1, 0, 0.5, 0)
            box.Size = UDim2.new(0, 20, 0, 20)
            
            local corner = Instance.new("UICorner")
            corner.Parent = box
            
            check.Name = "Check"
            check.Parent = box
            check.AnchorPoint = Vector2.new(0.5, 0.5)
            check.BackgroundTransparency = 1
            check.Position = UDim2.new(0.5, 0, 0.5, 0)
            check.Size = UDim2.new(0, 14, 0, 14)
            check.Image = "rbxassetid://3570695787"
            check.ImageColor3 = Color3.fromRGB(50, 200, 50)
            check.Visible = false
            
            local state = false
            
            checkbox.MouseButton1Click:Connect(function()
                state = not state
                check.Visible = state
                tween(box, {BackgroundColor3 = state and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(50, 50, 50)}, 0.1)
                if callback then callback(state) end
            end)
            
            return {
                SetState = function(s, value)
                    state = value
                    check.Visible = value
                end
            }
        end
        
        function tab:AddSlider(text, min, max, callback)
            local slider = Instance.new("Frame")
            local title = Instance.new("TextLabel")
            local track = Instance.new("Frame")
            local thumb = Instance.new("TextButton")
            local valueLabel = Instance.new("TextLabel")
            
            slider.Name = "Slider"
            slider.Parent = TabContainer
            slider.BackgroundTransparency = 1
            slider.Size = UDim2.new(1, 0, 0, 50)
            
            title.Name = "Title"
            title.Parent = slider
            title.BackgroundTransparency = 1
            title.Size = UDim2.new(1, 0, 0, 20)
            title.Font = Enum.Font.Gotham
            title.Text = text
            title.TextColor3 = Color3.fromRGB(200, 200, 200)
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            
            track.Name = "Track"
            track.Parent = slider
            track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            track.BorderSizePixel = 0
            track.Position = UDim2.new(0, 0, 0, 30)
            track.Size = UDim2.new(1, 0, 0, 5)
            
            thumb.Name = "Thumb"
            thumb.Parent = track
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Changed to white
            thumb.BorderSizePixel = 0
            thumb.Position = UDim2.new(0, 0, -1, 0)
            thumb.Size = UDim2.new(0, 15, 2, 0)
            thumb.AutoButtonColor = false
            
            valueLabel.Name = "Value"
            valueLabel.Parent = slider
            valueLabel.BackgroundTransparency = 1
            valueLabel.Position = UDim2.new(1, -50, 0, 0)
            valueLabel.Size = UDim2.new(0, 50, 0, 20)
            valueLabel.Font = Enum.Font.Gotham
            valueLabel.Text = tostring(min)
            valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            valueLabel.TextSize = 14
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local connection
            local currentValue = min
            local dragging = false -- Added drag state tracking
    
            local function updateValue(input)
                if not dragging then return end
                local x = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                x = math.clamp(x, 0, 1)
                local value = math.floor(min + (max - min) * x)
                
                if value ~= currentValue then
                    currentValue = value
                    valueLabel.Text = tostring(value)
                    thumb.Position = UDim2.new(x, -7, -1, 0)
                    if callback then callback(value) end
                end
            end
            
            thumb.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateValue(input)
                    connection = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                            connection:Disconnect()
                        end
                    end)
                end
            end)
            
            thumb.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateValue(input)
                end
            end)
            
            return {
                SetValue = function(s, value)
                    currentValue = math.clamp(value, min, max)
                    valueLabel.Text = tostring(currentValue)
                    local x = (currentValue - min) / (max - min)
                    thumb.Position = UDim2.new(x, -7, -1, 0)
                end
            }
        end
        
        function tab:AddCombobox(text, options, callback)
            local combobox = Instance.new("Frame")
            local button = Instance.new("TextButton")
            local dropdown = Instance.new("ScrollingFrame")
            local layout = Instance.new("UIListLayout")
            
            combobox.Name = "Combobox"
            combobox.Parent = TabContainer
            combobox.BackgroundTransparency = 1
            combobox.Size = UDim2.new(1, 0, 0, 30)
            
            button.Name = "Button"
            button.Parent = combobox
            button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            button.BorderSizePixel = 0
            button.Size = UDim2.new(1, 0, 0, 30)
            button.Font = Enum.Font.Gotham
            button.Text = "  " .. text
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 14
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.AutoButtonColor = false
            
            dropdown.Name = "Dropdown"
            dropdown.Parent = combobox
            dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            dropdown.BorderSizePixel = 0
            dropdown.Position = UDim2.new(0, 0, 1, 5)
            dropdown.Size = UDim2.new(1, 0, 0, 0)
            dropdown.Visible = false
            dropdown.ScrollBarThickness = 5
            
            layout.Parent = dropdown
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 2)
            
            local isOpen = false
            
            local function toggleDropdown()
                isOpen = not isOpen
                dropdown.Visible = isOpen
                tween(dropdown, {Size = isOpen and UDim2.new(1, 0, 0, #options * 30) or UDim2.new(1, 0, 0, 0)}, 0.2)
            end
            
            button.MouseButton1Click:Connect(toggleDropdown)
            
            for i, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = option
                optionButton.Parent = dropdown
                optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                optionButton.BorderSizePixel = 0
                optionButton.Size = UDim2.new(1, 0, 0, 28)
                optionButton.Font = Enum.Font.Gotham
                optionButton.Text = "  " .. option
                optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                optionButton.TextSize = 14
                optionButton.TextXAlignment = Enum.TextXAlignment.Left
                optionButton.AutoButtonColor = false
                
                optionButton.MouseButton1Click:Connect(function()
                    button.Text = "  " .. option
                    if callback then callback(option) end
                    toggleDropdown()
                end)
            end
            
            return {
                SetOptions = function(s, newOptions)
                    options = newOptions
                    for _, child in ipairs(dropdown:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for i, option in ipairs(newOptions) do
                        -- Recreate option buttons
                    end
                end
            }
        end
        
        return tab
    end
    
    return lib
end

return Library
