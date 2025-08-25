local OrionLib = loadstring(game:HttpGet(
                                ('https://raw.githubusercontent.com/ionlyusegithubformcmods/1-Line-Scripts/main/Mobile%20Friendly%20Orion')))()

local Window = OrionLib:MakeWindow({
    Name = "Buchinyan Hub | Every second add +1 skill point",
    HidePremium = true,
    IntroEnabled = false,
    SaveConfig = false,
    ConfigFolder = "OrionTest"
})

local Tab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})
game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)

local Section = Tab:AddSection({Name = "Sword and punch"})

Tab:AddToggle({
    Name = "Hit all dummies by sword or punch",
    Default = false,
    Callback = function(Value)
        ooj = Value
        while ooj and game:GetService("RunService").RenderStepped:Wait() do
            local LP = game:GetService("Players").LocalPlayer
            local tool = LP.Character and
                             LP.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Handle") then
                tool:Activate()
                for i, v in next, workspace:GetDescendants() do
                    if v:IsA("Humanoid") and
                        not game:GetService("Players")
                            :GetPlayerFromCharacter(v.Parent) then
                        for i, d in next, v.Parent:GetDescendants() do
                            if d:IsA("BasePart") then
                                coroutine.wrap(function()
                                    firetouchinterest(tool.Handle, d, 0)
                                    firetouchinterest(tool.Handle, d, 1)
                                end)()
                            end
                        end
                    end
                end
            end
        end
    end
})

Tab:AddToggle({
    Name = "Hit all players by sword or punch",
    Default = false,
    Callback = function(Value)
        oojh = Value
        local LP = game.Players.LocalPlayer
        while oojh and game:GetService("RunService").RenderStepped:Wait() do
            local p = game.Players:GetPlayers()
            for i = 2, #p do
                local v = p[i].Character
                local tool = LP.Character and
                                 LP.Character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                    for i, v in next, v:GetChildren() do
                        if v:IsA("BasePart") then
                            firetouchinterest(tool.Handle, v, 0)
                            firetouchinterest(tool.Handle, v, 1)
                        end
                    end
                end
            end
        end
    end
})

local iehh = false
Tab:AddToggle({
    Name = "Instant sword kill nearest dummies",
    Default = false,
    Callback = function(Value)
        iehh = Value
        while iehh and task.wait() do
            if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    :FindFirstChild("Handle") then
                local humanoids = {}
                for _, part in next,
                               game.Workspace:GetPartBoundsInRadius(
                                   game.Players.LocalPlayer.Character
                                       .HumanoidRootPart.Position, 40) do
                    if part.Parent:IsA("Model") and
                        part.Parent:FindFirstChildOfClass("Humanoid") and
                        not part:IsDescendantOf(
                            game.Players.LocalPlayer.Character) then
                        if not table.find(humanoids,
                                          part.Parent:FindFirstChildOfClass(
                                              "Humanoid")) then
                            table.insert(humanoids,
                                         part.Parent:FindFirstChildOfClass(
                                             "Humanoid"))
                        end
                    end
                end

                for _, humanoid in next, humanoids do
                    coroutine.wrap(function()
                        firetouchinterest(
                            game.Players.LocalPlayer.Character.HumanoidRootPart,
                            humanoid.RootPart, 0)
                        for _, part in next, humanoid.Parent:GetDescendants() do
                            if part:IsA("BasePart") then
                                firetouchinterest(
                                    game.Players.LocalPlayer.Character:FindFirstChildOfClass(
                                        "Tool").Handle, part, 0)
                            end
                        end

                        coroutine.wrap(function()
                            game.Players.LocalPlayer.SimulationRadius =
                                math.huge
                            sethiddenproperty(game.Players.LocalPlayer,
                                              "MaxSimulationRadius", math.huge)
                            settings().Network.IncomingReplicationLag = 0
                            game:GetService("TestService").IsSleepAllowed =
                                false
                        end)()

                        humanoid.Health = 0
                        humanoid:TakeDamage(math.huge)
                        humanoid:ChangeState("Dead")
                    end)()
                end
            end
        end
    end
})

Tab:AddToggle({
    Name = "Teleport to boss torso at instant sword kill",
    Default = false,
    Callback = function(Value)
        pei = Value
        while pei and task.wait() do
            if iehh == true and
                game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                local humanoids = {}
                for _, part in next,
                               workspace:GetPartBoundsInRadius(
                                   game.Players.LocalPlayer.Character
                                       .HumanoidRootPart.Position, 100) do
                    if part.Parent:IsA("Model") and
                        part.Parent:FindFirstChildOfClass("Humanoid") and
                        not part:IsDescendantOf(
                            game.Players.LocalPlayer.Character) and
                        part.Parent:IsDescendantOf(game.Workspace.mobs.BOSS) and
                        part.Parent:FindFirstChildOfClass("Humanoid"):GetState() ~=
                        "Dead" and
                        part.Parent:FindFirstChildOfClass("Humanoid").Health > 0 then
                        if not table.find(humanoids,
                                          part.Parent:FindFirstChildOfClass(
                                              "Humanoid")) then
                            table.insert(humanoids,
                                         part.Parent:FindFirstChildOfClass(
                                             "Humanoid"))
                        end
                    end
                end

                for _, humanoid in next, humanoids do
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
                        humanoid.RootPart.CFrame *
                            CFrame.new(0, humanoid.RootPart.Size.Y, 0)
                end
            end
        end
    end
})

local Section = Tab:AddSection({Name = "Teleports"})

local Dropdown = Tab:AddDropdown({
    Name = "To boss",
    Default = "",
    Options = {
        "The Duck?", "Huge Snail", "Mountain Golem", "Lava Wolf",
        "Machine Snowman", "Pharaoh", "Huge Goblin", "Sun God", "Ice Witch",
        "Poseidon", "Siren", "Red Dragon", "Lava General", "Panda Master",
        "Smurf Cat", "Golden Skeleton", "Shadow Demon", "Santa", "Clock Tower",
        "Zeus", "Medieval Colonel", "Priest", "Sand Worm", "Technoblade",
        "Napoleon", "MrBeast", "Red Samurai", "Guan Yu", "Lu Bu", "Dark Leaf",
        "Master Ku", "Ba Jei", "Earth Golem", "Error Cat", "Traveller"
    },
    Callback = function(Value)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
            game.Workspace.mobs.BOSS:FindFirstChild(Value).WorldPivot *
                CFrame.new(0, 0, -50)
    end
})

