-- Turcja Hub v20.0 | ULTIMATE PROFESSIONAL | ALL FIXED
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v20.0 🔥 ULTIMATE",
   LoadingTitle = "Loading Pro Features...",
   LoadingSubtitle = "Professional Edition",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TurcjaHubV20"
   },
   KeySystem = false
})

-- SERVICES
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Camera = workspace.CurrentCamera,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    TweenService = game:GetService("TweenService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- STATE MANAGER
local State = {
    ESP = false,
    Fly = false,
    Noclip = false,
    FakeLag = false,
    FlingAll = false,
    SpinAll = false,
    JumpSpam = false,
    InfJump = false,
    selectedPlayer = "",
    playerList = {},
    flySpeed = 50
}

-- UTILITIES
local Utils = {}

function Utils.getPlayers()
    local players = {}
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(players, player.Name)
        end
    end
    table.sort(players)
    return players
end

function Utils.safeNotify(title, content, duration, image)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3,
        Image = image or 4483362458
    })
end

function Utils.findPlayer(name)
    return Services.Players:FindFirstChild(name)
end

function Utils.teleportToPlayer(targetName)
    local target = Utils.findPlayer(targetName)
    local localChar = LocalPlayer.Character
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and 
       localChar and localChar:FindFirstChild("HumanoidRootPart") then
        localChar.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, -3)
        return true
    end
    return false
end

State.playerList = Utils.getPlayers()

-- TABS
local Tabs = {
    Welcome = Window:CreateTab("🎉 Welcome", 4483362458),
    Main = Window:CreateTab("🏠 Main", 4483362458),
    Players = Window:CreateTab("👥 Players", 4483362458),
    Movement = Window:CreateTab("🚀 Movement", 4483362458),
    Visuals = Window:CreateTab("🎨 Visuals", 4483362458),
    Troll = Window:CreateTab("😂 Troll", 4483362458)
}

-- GAME SPECIFIC TAB
local gameId = game.PlaceId
local brookhavenId = 4924922222
local brookTab = (gameId == brookhavenId) and Window:CreateTab("🏘️ Brookhaven", 4483362458)

-- WELCOME TAB
Tabs.Welcome:CreateParagraph({Title="ℹ️ Info", Content="Only for real exploits (not CFeli)"})
Tabs.Welcome:CreateParagraph({Title="🎮 Supported", Content="Brookhaven | Arsenal | CaseParadise"})

Tabs.Welcome:CreateButton({
    Name = "📋 Copy Discord",
    Callback = function()
        setclipboard("turcja")
        Utils.safeNotify("Copied!", "turcja to clipboard", 2)
    end
})

-- MAIN TAB
Tabs.Main:CreateToggle({
    Name = "💎 Fullbright",
    CurrentValue = false,
    Flag = "FullbrightV20",
    Callback = function(value)
        Services.Lighting.Brightness = value and 3 or 1
        Services.Lighting.ClockTime = value and 14 or 12
        Services.Lighting.FogEnd = value and math.huge or 100000
        Services.Lighting.GlobalShadows = not value
    end
})

Tabs.Main:CreateButton({
    Name = "🔓 Unlock Everything",
    Callback = function()
        local unlocked = 0
        for _, obj in ipairs(Services.Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate")) then
                obj.CanCollide = false
                obj.Transparency = 0.8
                unlocked += 1
            end
        end
        Utils.safeNotify("Unlocked", unlocked .. " objects", 3)
    end
})

-- PLAYERS TAB
Tabs.Players:CreateButton({
    Name = "🔄 Refresh List",
    Callback = function()
        State.playerList = Utils.getPlayers()
        Utils.safeNotify("Refreshed", #State.playerList .. " players found")
    end
})

local tpSelect = Tabs.Players:CreateDropdown({
    Name = "👤 Select TP Target",
    Options = State.playerList,
    CurrentOption = {"None"},
    Flag = "TPTargetV20",
    Callback = function(option)
        State.selectedPlayer = option[1]
    end
})

Tabs.Players:CreateButton({
    Name = "⚡ Instant TP",
    Callback = function()
        if Utils.teleportToPlayer(State.selectedPlayer) then
            Utils.safeNotify("TP Success", "Teleported to " .. State.selectedPlayer)
        else
            Utils.safeNotify("TP Failed", "Player not found/offline", 4, 16711680)
        end
    end
})

local specSelect = Tabs.Players:CreateDropdown({
    Name = "👁️ Spectate Player",
    Options = State.playerList,
    CurrentOption = {"None"},
    Flag = "SpecTargetV20",
    Callback = function(option)
        local target = Utils.findPlayer(option[1])
        if target and target.Character then
            Services.Camera.CameraSubject = target.Character:FindFirstChild("Humanoid")
            Utils.safeNotify("Spectating", option[1])
        end
    end
})

-- MOVEMENT TAB
Tabs.Movement:CreateToggle({
    Name = "✈️ Perfect Fly (WASD+Space+Shift)",
    CurrentValue = false,
    Flag = "FlyV20",
    Callback = function(value)
        State.Fly = value
    end
})

Tabs.Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 10,
    CurrentValue = 50,
    Flag = "FlySpeedV20",
    Callback = function(value)
        State.flySpeed = value
    end
})

Tabs.Movement:CreateToggle({
    Name = "👻 Noclip",
    CurrentValue = false,
    Flag = "NoclipV20",
    Callback = function(value)
        State.Noclip = value
    end
})

Tabs.Movement:CreateToggle({
    Name = "📈 Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpV20",
    Callback = function(value)
        State.InfJump = value
    end
})

Tabs.Movement:CreateToggle({
    Name = "🎭 Fake Lag",
    CurrentValue = false,
    Flag = "FakeLagV20",
    Callback = function(value)
        State.FakeLag = value
    end
})

-- VISUALS TAB
Tabs.Visuals:CreateToggle({
    Name = "🌈 ULTIMATE ESP (Box+Tracer+Name+Dist)",
    CurrentValue = false,
    Flag = "ESPV20",
    Callback = function(value)
        State.ESP = value
    end
})

-- TROLL TAB
Tabs.Troll:CreateToggle({
    Name = "💥 Fling Everyone",
    CurrentValue = false,
    Flag = "FlingV20",
    Callback = function(value)
        State.FlingAll = value
    end
})

Tabs.Troll:CreateToggle({
    Name = "⭕ Spin Everyone",
    CurrentValue = false,
    Flag = "SpinV20",
    Callback = function(value)
        State.SpinAll = value
    end
})

Tabs.Troll:CreateButton({
    Name = "🪑 Sit On Player Head",
    Callback = function()
        local target = Utils.findPlayer(State.selectedPlayer)
        local localChar = LocalPlayer.Character
        if target and target.Character and target.Character:FindFirstChild("Head") and localChar then
            localChar.HumanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 2.5, 0)
            Utils.safeNotify("Sitting", "On " .. State.selectedPlayer .. "'s head")
        end
    end
})

-- BROOKHAVEN TAB
if brookTab then
    brookTab:CreateButton({
        Name = "🏠 Get All Houses",
        Callback = function()
            pcall(function()
                Services.ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "Hause", "Recieve")
            end)
        end
    })
    
    brookTab:CreateButton({
        Name = "💰 $1,000,000",
        Callback = function()
            pcall(function()
                Services.ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "SetCash", 1000000)
            end)
        end
    })
    
    brookTab:CreateButton({
        Name = "🚗 Max Car Speed",
        Callback = function()
            for _, vehicle in ipairs(Services.Workspace:GetChildren()) do
                pcall(function()
                    local seat = vehicle:FindFirstChildOfClass("VehicleSeat")
                    if seat then
                        seat.MaxSpeed = 500
                        seat.Torque = 10000
                    end
                end)
            end
        end
    })
end

-- ULTIMATE ESP SYSTEM
local ESPObjects = {}
Services.RunService.RenderStepped:Connect(function()
    if not State.ESP then
        for player, drawings in pairs(ESPObjects) do
            for _, drawing in pairs(drawings) do
                drawing.Visible = false
            end
        end
        return
    end
    
    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not ESPObjects[player] then
                ESPObjects[player] = {
                    box = Drawing.new("Square"),
                    tracer = Drawing.new("Line"),
                    name = Drawing.new("Text"),
                    distance = Drawing.new("Text")
                }
                
                for _, drawing in pairs(ESPObjects[player]) do
                    drawing.Visible = false
                    drawing.Thickness = 2
                end
                
                ESPObjects[player].name.Size = 16
                ESPObjects[player].name.Center = true
                ESPObjects[player].name.Outline = true
                ESPObjects[player].name.Font = 2
                
                ESPObjects[player].distance.Size = 14
                ESPObjects[player].distance.Center = true
                ESPObjects[player].distance.Outline = true
                ESPObjects[player].distance.Font = 2
            end
            
            local drawings = ESPObjects[player]
            local character = player.Character
            local rootPart = character.HumanoidRootPart
            local head = character:FindFirstChild("Head")
            
            if head then
                local headPos, headOnScreen = Services.Camera:WorldToViewportPoint(head.Position)
                local footPos = Services.Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 4, 0))
                
                if headOnScreen then
                    local boxHeight = math.max(math.abs(headPos.Y - footPos.Y), 30)
                    local boxWidth = boxHeight * 0.5
                    
                    local rainbowColor = Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
                    
                    -- Box ESP
                    drawings.box.Size = Vector2.new(boxWidth, boxHeight)
                    drawings.box.Position = Vector2.new(headPos.X - boxWidth/2, headPos.Y - boxHeight/2)
                    drawings.box.Color = rainbowColor
                    drawings.box.Visible = true
                    
                    -- Tracer
                    drawings.tracer.From = Vector2.new(Services.Camera.ViewportSize.X / 2, Services.Camera.ViewportSize.Y)
                    drawings.tracer.To = Vector2.new(headPos.X, headPos.Y + boxHeight/2)
                    drawings.tracer.Color = rainbowColor
                    drawings.tracer.Visible = true
                    
                    -- Name
                    drawings.name.Text = player.Name
                    drawings.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
                    drawings.name.Color = rainbowColor
                    drawings.name.Visible = true
                    
                    -- Distance
                    local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                    drawings.distance.Text = tostring(distance) .. "m"
                    drawings.distance.Position = Vector2.new(headPos.X, headPos.Y - 8)
                    drawings.distance.Color = Color3.new(1, 1, 1)
                    drawings.distance.Visible = true
                else
                    for _, drawing in pairs(drawings) do
                        drawing.Visible = false
                    end
                end
            end
        end
    end
end)

-- MAIN FEATURE LOOP
Services.RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    -- PERFECT FLY SYSTEM
    if State.Fly then
        local flyVelocity = humanoidRootPart:FindFirstChild("FlyVelocity")
        if not flyVelocity then
            flyVelocity = Instance.new("BodyVelocity")
            flyVelocity.Name = "FlyVelocity"
            flyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            flyVelocity.Parent = humanoidRootPart
        end
        
        local movement = Vector3.new()
        local cameraCFrame = Services.Camera.CFrame
        
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then
            movement += cameraCFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then
            movement -= cameraCFrame.LookVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then
            movement -= cameraCFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then
            movement += cameraCFrame.RightVector
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            movement += Vector3.new(0, 1, 0)
        end
        if Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            movement -= Vector3.new(0, 1, 0)
        end
        
        flyVelocity.Velocity = (movement.Magnitude > 0 and movement.Unit or Vector3.new()) * State.flySpeed
    elseif humanoidRootPart:FindFirstChild("FlyVelocity") then
        humanoidRootPart.FlyVelocity:Destroy()
    end
    
    -- NOCLIP
    if State.Noclip then
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- FAKE LAG
    if State.FakeLag then
        humanoidRootPart.Velocity *= 0.4
    end
    
    -- TROLL FEATURES
    if State.FlingAll then
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Velocity = Vector3.new(
                    math.random(-200, 200),
                    math.random(150, 300),
                    math.random(-200, 200)
                )
            end
        end
    end
    
    if State.SpinAll then
        for _, player in ipairs(Services.Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(60), 0)
            end
        end
    end
end)

-- INFINITE JUMP
Services.UserInputService.JumpRequest:Connect(function()
    if State.InfJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- CLEANUP
Services.Players.PlayerRemoving:Connect(function(player)
    if ESPObjects[player] then
        for _, drawing in pairs(ESPObjects[player]) do
            drawing:Remove()
        end
        ESPObjects[player] = nil
    end
end)

Utils.safeNotify("Turcja Hub v20.0", "ULTIMATE LOADED | All features working", 6)
print("🟢 Turcja Hub v20.0 ULTIMATE - PROFESSIONAL EDITION LOADED")
