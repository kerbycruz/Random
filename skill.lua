if getgenv().SkidHubGUI then
    getgenv().SkidHubGUI:Destroy()
    getgenv().SkidHubGUI = nil
end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkidHub"
ScreenGui.Parent = CoreGui
getgenv().SkidHubGUI = ScreenGui

-- Create Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Parent = ScreenGui

-- Make Frame draggable
local dragging = false
local dragInput, dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Text = "SkidHub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

-- Button
local Button = Instance.new("TextButton")
Button.Size = UDim2.new(1, -20, 0, 40)
Button.Position = UDim2.new(0, 10, 0, 45)
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.Text = "Inf SP: OFF"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextSize = 16
Button.Font = Enum.Font.SourceSansBold
Button.Parent = Frame

-- Toggle logic
local Enabled = false
local Connection

local function Toggle()
    Enabled = not Enabled
    Button.Text = Enabled and "Inf SP: ON" or "Inf SP: OFF"

    if Enabled then
        Connection = game:GetService("RunService").Stepped:Connect(function()
            local args = {
                {
                    "Magic Damage",
                    -999999999999999999999999999999999999999999999999
                }
            }
            workspace:WaitForChild("__THINGS"):WaitForChild("__REMOTES"):WaitForChild("update_stats"):FireServer(unpack(args))
        end)
    else
        if Connection then
            Connection:Disconnect()
            Connection = nil
        end
    end
end

Button.MouseButton1Click:Connect(Toggle)

-- Hide/Show toggle (RightControl key)
local hidden = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        hidden = not hidden
        Frame.Visible = not hidden
    end
end)
