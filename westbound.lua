local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local StatsService = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local bag = localPlayer:WaitForChild("States"):WaitForChild("Bag")
local bagSizeLevel = localPlayer:WaitForChild("Stats"):WaitForChild("BagSizeLevel"):WaitForChild("CurrentAmount")
local robEvent = ReplicatedStorage:WaitForChild("GeneralEvents"):WaitForChild("Rob")
local targetPosition = CFrame.new(1636.62537, 104.349976, -1736.184)

-- Config variables that can be adjusted through UI
local config = {
    enabled = true, -- Toggle for the entire script
    teleportEnabled = true, -- Toggle for teleporting
    actionDelay = 0.1, -- Delay between actions
    autoSellWhenFull = true, -- Auto sell when bag is full
    safetyFeatures = true, -- Enable anti-detection features
    customDropoffPoint = targetPosition -- Default location for selling
}

-- Check if the script is already running and clean up if needed
if getgenv().AutoFarmV6Executed and CoreGui:FindFirstChild("AutoFarmUI_V6") then
    getgenv().AutoFarmV6Executed = false
    CoreGui.AutoFarmUI_V6:Destroy()
end

getgenv().AutoFarmV6Executed = true

-- Apply anti-detection measures
if humanoid and config.safetyFeatures then
    local clonedHumanoid = humanoid:Clone()
    clonedHumanoid.Parent = character
    localPlayer.Character = nil
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    clonedHumanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid:Destroy()
    localPlayer.Character = character
    local camera = Workspace.CurrentCamera
    camera.CameraSubject = clonedHumanoid
    camera.CFrame = camera.CFrame
    clonedHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    local animate = character:FindFirstChild("Animate")
    if animate then
        animate.Disabled = true
        task.wait(0.07)
        animate.Disabled = false
    end
    clonedHumanoid.Health = clonedHumanoid.MaxHealth
    humanoid = clonedHumanoid
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end

-- Anti-AFK
localPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Create UI
local AutoFarmUI = Instance.new("ScreenGui")
AutoFarmUI.Name = "AutoFarmUI_V6"
AutoFarmUI.Parent = CoreGui
AutoFarmUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Parent = AutoFarmUI
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Visible = false

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Text = "Money V.6 by Mentor"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Text = "X"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundTransparency = 1
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(0.92, 0, 0, 5)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Parent = MainFrame
MinimizeButton.Text = "-"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.TextColor3 = Color3.fromRGB(150, 150, 255)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(0.84, 0, 0, 5)

local StatsFrame = Instance.new("Frame")
StatsFrame.Parent = MainFrame
StatsFrame.BackgroundTransparency = 1
StatsFrame.Position = UDim2.new(0, 15, 0, 40)
StatsFrame.Size = UDim2.new(0.5, -20, 0, 150)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = StatsFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

local function createLabel(text, parent)
    local Label = Instance.new("TextLabel")
    Label.Parent = parent
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    return Label
end

-- Create toggle button function
local function createToggle(text, parent, defaultState, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Parent = parent
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Size = UDim2.new(1, 0, 0, 25)
    
    local label = Instance.new("TextLabel")
    label.Parent = toggleFrame
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Parent = toggleFrame
    toggleButton.Size = UDim2.new(0, 40, 0, 20)
    toggleButton.Position = UDim2.new(1, -40, 0.5, -10)
    toggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = toggleButton
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Parent = toggleButton
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = toggleCircle
    
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = toggleFrame
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    local state = defaultState
    
    clickArea.MouseButton1Click:Connect(function()
        state = not state
        
        local newPosition = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        local newColor = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = newPosition}):Play()
        TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
        
        callback(state)
    end)
    
    return toggleFrame
end

-- Create slider function
local function createSlider(text, parent, min, max, defaultValue, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = parent
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Size = UDim2.new(1, 0, 0, 40)
    
    local label = Instance.new("TextLabel")
    label.Parent = sliderFrame
    label.Text = text .. ": " .. defaultValue
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local sliderBG = Instance.new("Frame")
    sliderBG.Parent = sliderFrame
    sliderBG.Size = UDim2.new(1, 0, 0, 6)
    sliderBG.Position = UDim2.new(0, 0, 0.7, 0)
    sliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = sliderBG
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBG
    sliderFill.Size = UDim2.new((defaultValue - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(1, 0)
    UICorner2.Parent = sliderFill
    
    local sliderKnob = Instance.new("Frame")
    sliderKnob.Parent = sliderBG
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.Position = UDim2.new((defaultValue - min) / (max - min), -8, 0.5, -8)
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.ZIndex = 2
    
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(1, 0)
    UICorner3.Parent = sliderKnob
    
    local clickArea = Instance.new("TextButton")
    clickArea.Parent = sliderFrame
    clickArea.Size = UDim2.new(1, 0, 0.8, 0)
    clickArea.Position = UDim2.new(0, 0, 0.2, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    
    local value = defaultValue
    local dragging = false
    
    local function updateValue(xPos)
        local relativePos = math.clamp((xPos - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relativePos
        
        -- Round to 2 decimal places for display
        local displayValue = math.floor(value * 100) / 100
        label.Text = text .. ": " .. displayValue
        
        sliderFill.Size = UDim2.new(relativePos, 0, 1, 0)
        sliderKnob.Position = UDim2.new(relativePos, -8, 0.5, -8)
        
        callback(value)
    end
    
    clickArea.MouseButton1Down:Connect(function(mouseX)
        dragging = true
        updateValue(mouseX)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    return sliderFrame
end

-- Stats
local PingLabel = createLabel("Ping: Calculating...", StatsFrame)
local CashLabel = createLabel("Earnings: $0", StatsFrame)
local FPSLabel = createLabel("FPS: Calculating...", StatsFrame)
local TimerLabel = createLabel("Time: 00:00:00", StatsFrame)
local BagLabel = createLabel("Bag: 0/0", StatsFrame)

-- Controls Frame
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Parent = MainFrame
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Position = UDim2.new(0.5, 5, 0, 40)
ControlsFrame.Size = UDim2.new(0.5, -20, 0, 200)

local UIListLayout2 = Instance.new("UIListLayout")
UIListLayout2.Parent = ControlsFrame
UIListLayout2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout2.Padding = UDim.new(0, 8)

-- Add toggle buttons
local mainToggle = createToggle("Enable Script", ControlsFrame, config.enabled, function(state)
    config.enabled = state
end)

local teleportToggle = createToggle("Enable Teleport", ControlsFrame, config.teleportEnabled, function(state)
    config.teleportEnabled = state
end)

local autoSellToggle = createToggle("Auto Sell", ControlsFrame, config.autoSellWhenFull, function(state)
    config.autoSellWhenFull = state
end)

local safetyToggle = createToggle("Safety Features", ControlsFrame, config.safetyFeatures, function(state)
    config.safetyFeatures = state
end)

-- Add sliders
local delaySlider = createSlider("Action Delay", ControlsFrame, 0.01, 1, config.actionDelay, function(value)
    config.actionDelay = value
end)

-- Status bar
local StatusBar = Instance.new("Frame")
StatusBar.Parent = MainFrame
StatusBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.Size = UDim2.new(1, 0, 0, 30)

local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0, 12)
UICorner4.Parent = StatusBar

local StatusText = Instance.new("TextLabel")
StatusText.Parent = StatusBar
StatusText.Text = "Status: Running"
StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 14
StatusText.Size = UDim2.new(1, -20, 1, 0)
StatusText.Position = UDim2.new(0, 10, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.TextXAlignment = Enum.TextXAlignment.Left

-- Animation for opening UI
local function openUI()
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 250, 0, 200)
    MainFrame.BackgroundTransparency = 1
    
    local fadeIn = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 250),
        BackgroundTransparency = 0.2
    })
    fadeIn:Play()
end

local function closeUI()
    local fadeOut = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 250, 0, 200),
        BackgroundTransparency = 1
    })
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        AutoFarmUI:Destroy()
        getgenv().AutoFarmV6Executed = false
    end)
end

-- Minimize functionality
local minimized = false
local minimizedSize = UDim2.new(0, 300, 0, 35)
local expandedSize = UDim2.new(0, 300, 0, 250)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    local targetSize = minimized and minimizedSize or expandedSize
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = targetSize
    }):Play()
    
    StatsFrame.Visible = not minimized
    ControlsFrame.Visible = not minimized
    StatusBar.Visible = not minimized
    MinimizeButton.Text = minimized and "+" or "-"
end)

CloseButton.MouseButton1Click:Connect(closeUI)

openUI()

-- Dragging functionality
local dragging, dragStart, startPos
local currentTween

local function updateDrag(input)
    local delta = input.Position - dragStart
    local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    
    if currentTween then
        currentTween:Cancel()
    end
    
    currentTween = TweenService:Create(MainFrame, TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = targetPos})
    currentTween:Play()
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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

MainFrame.InputChanged:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
        updateDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Performance monitoring
task.spawn(function()
    while task.wait(0.7) and getgenv().AutoFarmV6Executed do
        local dt = RunService.RenderStepped:Wait()
        FPSLabel.Text = "FPS: " .. tostring(math.floor(1 / dt))
    end
end)

task.spawn(function()
    while task.wait(0.7) and getgenv().AutoFarmV6Executed do
        local perfStats = StatsService:FindFirstChild("PerformanceStats")
        if perfStats and perfStats:FindFirstChild("Ping") then
            PingLabel.Text = "Ping: " .. tostring(math.floor(perfStats.Ping:GetValue())) .. "ms"
        end
    end
end)

-- Timer
local seconds, minutes, hours = 0, 0, 0

task.spawn(function()
    while task.wait(1) and getgenv().AutoFarmV6Executed do
        seconds = seconds + 1
        if seconds >= 60 then
            seconds = 0
            minutes = minutes + 1
        end
        if minutes >= 60 then
            minutes = 0
            hours = hours + 1
        end
        TimerLabel.Text = string.format("Time: %02d:%02d:%02d", hours, minutes, seconds)
    end
end)

-- Bag status monitor
task.spawn(function()
    while task.wait(0.5) and getgenv().AutoFarmV6Executed do
        BagLabel.Text = string.format("Bag: %d/%d", bag.Value, bagSizeLevel.Value)
    end
end)

-- Formatters
local function formatNumber(n)
    local formatted = tostring(n)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Movement function
local function moveToTarget(position)
    if humanoidRootPart and config.teleportEnabled then
        humanoidRootPart.CFrame = position
    end
end

-- Initialize caches
local cashRegisters = {}
local safes = {}

local function updateCaches()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Model") then
            if child.Name == "CashRegister" then
                table.insert(cashRegisters, child)
            elseif child.Name == "Safe" then
                table.insert(safes, child)
            end
        end
    end
end

updateCaches()

-- Update caches when objects are added/removed
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        if child.Name == "CashRegister" then
            table.insert(cashRegisters, child)
        elseif child.Name == "Safe" then
            table.insert(safes, child)
        end
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if child:IsA("Model") then
        if child.Name == "CashRegister" then
            for i = #cashRegisters, 1, -1 do
                if cashRegisters[i] == child then
                    table.remove(cashRegisters, i)
                end
            end
        elseif child.Name == "Safe" then
            for i = #safes, 1, -1 do
                if safes[i] == child then
                    table.remove(safes, i)
                end
            end
        end
    end
end)

-- Rob cash registers
local function checkCashRegister()
    if not config.enabled then return false end
    
    if bag.Value >= bagSizeLevel.Value and config.autoSellWhenFull then
        StatusText.Text = "Status: Selling Items"
        StatusText.TextColor3 = Color3.fromRGB(0, 200, 255)
        moveToTarget(config.customDropoffPoint)
        return false
    end
    
    for i = 1, #cashRegisters do
        local item = cashRegisters[i]
        local openPart = item:FindFirstChild("Open")
        if openPart then
            StatusText.Text = "Status: Robbing Register"
            StatusText.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            if config.teleportEnabled then
                moveToTarget(openPart.CFrame)
            end
            
            robEvent:FireServer("Register", {
                Part = item:FindFirstChild("Union"),
                OpenPart = openPart,
                ActiveValue = item:FindFirstChild("Active"),
                Active = true
            })
            
            task.wait(config.actionDelay)
            return true
        end
    end
    return false
end

-- Rob safes
local function checkSafe()
    if not config.enabled then return false end
    
    if bag.Value >= bagSizeLevel.Value and config.autoSellWhenFull then
        StatusText.Text = "Status: Selling Items"
        StatusText.TextColor3 = Color3.fromRGB(0, 200, 255)
        moveToTarget(config.customDropoffPoint)
        return false
    end
    
    for i = 1, #safes do
        local item = safes[i]
        if item:FindFirstChild("Amount") and item.Amount.Value > 0 then
            local safePart = item:FindFirstChild("Safe")
            if safePart then
                StatusText.Text = "Status: Robbing Safe"
                StatusText.TextColor3 = Color3.fromRGB(255, 200, 0)
                
                if config.teleportEnabled then
                    moveToTarget(safePart.CFrame)
                end
                
                local openFlag = item:FindFirstChild("Open")
                if openFlag and openFlag.Value then
                    robEvent:FireServer("Safe", item)
                else
                    local openSafe = item:FindFirstChild("OpenSafe")
                    if openSafe then
                        openSafe:FireServer("Completed")
                    end
                    robEvent:FireServer("Safe", item)
                end
                
                task.wait(config.actionDelay)
                return true
            end
        end
    end
    return false
end

-- Implement a key press to quickly hide/show the UI
local toggleUIVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
        toggleUIVisible = not toggleUIVisible
        MainFrame.Visible = toggleUIVisible
    end
end)

-- Main loop
task.spawn(function()
    while task.wait() and getgenv().AutoFarmV6Executed do
        if config.enabled then
            if not checkCashRegister() then
                checkSafe()
            end
        else
            StatusText.Text = "Status: Paused"
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(1)
        end
    end
end)

-- Earnings tracker
local leaderstats = localPlayer:WaitForChild("leaderstats")
local cashStat = leaderstats:WaitForChild("$$")
local initialCash = cashStat.Value

task.spawn(function()
    while task.wait(0.7) and getgenv().AutoFarmV6Executed do
        local earned = cashStat.Value - initialCash
        CashLabel.Text = "Earnings: $" .. formatNumber(earned)
    end
end)

-- Keybind help message
task.spawn(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Money Dupe V.6";
        Text = "Press Right Ctrl to toggle UI visibility";
        Duration = 5;
    })
end)