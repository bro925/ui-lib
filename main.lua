local UI = {}
local UserInputService = game:GetService("UserInputService")

function UI.Create(title)
    title = title
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ModernUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 400, 0, 300)
    Main.Position = UDim2.new(0.5, -200, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    -- Draggable Feature
    local Drag = Instance.new("Frame")
    Drag.Name = "Drag"
    Drag.Size = UDim2.new(1, 0, 0, 30)
    Drag.BackgroundTransparency = 1
    Drag.Parent = Main

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 200, 0, 20)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = title -- Use the provided title here
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Drag

    local Minimize = Instance.new("TextButton")
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.new(0, 20, 0, 20)
    Minimize.Position = UDim2.new(1, -50, 0, 5)
    Minimize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Minimize.TextColor3 = Color3.new(1, 1, 1)
    Minimize.Text = "_"
    Minimize.Font = Enum.Font.GothamBold
    Minimize.Parent = Drag

    local Close = Instance.new("TextButton")
    Close.Name = "Close"
    Close.Size = UDim2.new(0, 20, 0, 20)
    Close.Position = UDim2.new(1, -25, 0, 5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Close.TextColor3 = Color3.new(1, 1, 1)
    Close.Text = "X"
    Close.Font = Enum.Font.GothamBold
    Close.Parent = Drag

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 30)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Main

    local TabContent = Instance.new("Frame")
    TabContent.Name = "TabContent"
    TabContent.Size = UDim2.new(1, -20, 1, -70)
    TabContent.Position = UDim2.new(0, 10, 0, 60)
    TabContent.BackgroundTransparency = 1
    TabContent.Parent = Main

    local Tabs = {}
    local currentTab

    local dragging
    local dragInput
    local dragStart
    local startPos

    local function Update(input)
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X,
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end

    Drag.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Drag.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)

    -- Window Controls
    Minimize.MouseButton1Click:Connect(function()
        TabContent.Visible = not TabContent.Visible
        Main.Size = TabContent.Visible and UDim2.new(0, 400, 0, 300) or UDim2.new(0, 400, 0, 30)
    end)

    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Tab System
    function Tabs.AddTab(name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.new(1, 1, 1)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 12
        TabButton.Parent = TabContainer

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Name = name
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.BackgroundTransparency = 1
        TabFrame.Visible = false
        TabFrame.Parent = TabContent
        TabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabFrame.ScrollBarThickness = 5

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = TabFrame
        Layout.Padding = UDim.new(0, 5)

        TabButton.MouseButton1Click:Connect(function()
            if currentTab then
                currentTab.Visible = false
            end
            TabFrame.Visible = true
            currentTab = TabFrame
        end)

        local Tab = {}
        
        function Tab.AddSection(title)
            local Section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            
            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -10, 0, 20)
            SectionTitle.Position = UDim2.new(0, 5, 0, 5)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = title
            SectionTitle.TextColor3 = Color3.new(1, 1, 1)
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextSize = 12
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectionTitle.Parent = SectionFrame
            
            local Content = Instance.new("Frame")
            Content.Name = "Content"
            Content.Size = UDim2.new(1, -10, 1, -30)
            Content.Position = UDim2.new(0, 5, 0, 25)
            Content.BackgroundTransparency = 1
            Content.Parent = SectionFrame
            
            local Layout = Instance.new("UIListLayout")
            Layout.Parent = Content
            Layout.Padding = UDim.new(0, 5)
            
            SectionFrame.Parent = TabFrame
            
            function Section.AddLabel(text)
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Content
            end
            
            function Section.AddCheckbox(text, callback)
                local Checkbox = Instance.new("TextButton")
                Checkbox.Name = "Checkbox"
                Checkbox.Size = UDim2.new(1, 0, 0, 20)
                Checkbox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Checkbox.AutoButtonColor = false
                
                local Check = Instance.new("Frame")
                Check.Name = "Check"
                Check.Size = UDim2.new(0, 15, 0, 15)
                Check.Position = UDim2.new(1, -20, 0.5, -7)
                Check.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Check.BorderSizePixel = 0
                Check.Parent = Checkbox
                
                local Checked = Instance.new("Frame")
                Checked.Name = "Checked"
                Checked.Size = UDim2.new(0, 11, 0, 11)
                Checked.Position = UDim2.new(0.5, -5, 0.5, -5)
                Checked.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Checked.Visible = false
                Checked.Parent = Check
                
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Checkbox
                
                local state = false
                
                Checkbox.MouseButton1Click:Connect(function()
                    state = not state
                    Checked.Visible = state
                    callback(state)
                end)
                
                Checkbox.Parent = Content
            end
            
            function Section.AddSlider(text, min, max, callback)
                local Slider = Instance.new("Frame")
                Slider.Name = "Slider"
                Slider.Size = UDim2.new(1, 0, 0, 40)
                Slider.BackgroundTransparency = 1
                
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, 0, 0, 20)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Slider
                
                local Track = Instance.new("Frame")
                Track.Name = "Track"
                Track.Size = UDim2.new(1, 0, 0, 5)
                Track.Position = UDim2.new(0, 0, 0, 25)
                Track.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Track.Parent = Slider
                
                local Fill = Instance.new("Frame")
                Fill.Name = "Fill"
                Fill.Size = UDim2.new(0.5, 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
                Fill.Parent = Track
                
                local Value = Instance.new("TextLabel")
                Value.Name = "Value"
                Value.Size = UDim2.new(0, 50, 0, 20)
                Value.Position = UDim2.new(1, 5, 0, 0)
                Value.BackgroundTransparency = 1
                Value.Text = tostring(math.floor((min + max)/2))
                Value.TextColor3 = Color3.new(1, 1, 1)
                Value.Font = Enum.Font.Gotham
                Value.TextSize = 12
                Value.Parent = Track
                
                local dragging = false
                local current = (min + max)/2
                
                local function Update(input)
                    local x = (input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X
                    x = math.clamp(x, 0, 1)
                    Fill.Size = UDim2.new(x, 0, 1, 0)
                    current = math.floor(min + (max - min) * x)
                    Value.Text = tostring(current)
                    callback(current)
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Update(input)
                    end
                end)
                
                Track.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
                
                Slider.Parent = Content
            end
            
            function Section.AddCombobox(text, options, callback)
                local Combobox = Instance.new("TextButton")
                Combobox.Name = "Combobox"
                Combobox.Size = UDim2.new(1, 0, 0, 20)
                Combobox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Combobox.AutoButtonColor = false
                
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Size = UDim2.new(1, -20, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Text = text
                Label.TextColor3 = Color3.new(1, 1, 1)
                Label.Font = Enum.Font.Gotham
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Combobox
                
                local Arrow = Instance.new("TextLabel")
                Arrow.Name = "Arrow"
                Arrow.Size = UDim2.new(0, 20, 1, 0)
                Arrow.Position = UDim2.new(1, -20, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "▼"
                Arrow.TextColor3 = Color3.new(1, 1, 1)
                Arrow.Font = Enum.Font.Gotham
                Arrow.TextSize = 12
                Arrow.Parent = Combobox
                
                local Dropdown = Instance.new("Frame")
                Dropdown.Name = "Dropdown"
                Dropdown.Size = UDim2.new(1, 0, 0, 0)
                Dropdown.Position = UDim2.new(0, 0, 1, 5)
                Dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Dropdown.Visible = false
                Dropdown.Parent = Combobox
                
                local Layout = Instance.new("UIListLayout")
                Layout.Parent = Dropdown
                
                local opened = false
                
                Combobox.MouseButton1Click:Connect(function()
                    opened = not opened
                    Dropdown.Visible = opened
                    Dropdown.Size = UDim2.new(1, 0, 0, opened and (#options * 20 + (#options - 1) * 5) or 0)
                end)
                
                for _, option in pairs(options) do
                    local OptionButton = Instance.new("TextButton")
                    OptionButton.Name = option
                    OptionButton.Size = UDim2.new(1, 0, 0, 20)
                    OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    OptionButton.Text = option
                    OptionButton.TextColor3 = Color3.new(1, 1, 1)
                    OptionButton.Font = Enum.Font.Gotham
                    OptionButton.TextSize = 12
                    OptionButton.Parent = Dropdown
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Label.Text = text..": "..option
                        callback(option)
                        opened = false
                        Dropdown.Visible = false
                        Dropdown.Size = UDim2.new(1, 0, 0, 0)
                    end)
                end
                
                Combobox.Parent = Content
            end
            
            return Section
        end
        
        return Tab
    end

    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    return Tabs
end

return UI
