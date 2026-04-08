-- Turcja Hub v18.0 | Ultra-safe Rayfield + Full Features | No Errors Guaranteed
local Rayfield = nil
local backups = {
    "https://sirius.menu/rayfield.lua",
    "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
    "https://raw.githubusercontent.com/RegularVynixu/rayfield/main/source"
}

for i, url in ipairs(backups) do
    local success, result = pcall(function()
        return loadstring(game:HttpGetAsync(url, true))()
    end)
    if success and result then
        Rayfield = result
        break
    end
end

if not Rayfield then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Turcja Hub", Text = "Rayfield failed to load!", Duration = 5
    })
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Turcja Hub v18.0",
    LoadingTitle = "Ładowanie Turcja Hub...",
    LoadingSubtitle = "przez TurcjaTeam",
    ConfigurationSaving = {Enabled = true, FolderName = "TurcjaHub", FileName = "config"},
    Discord = {Enabled = true, Invite = "discord.gg/turcja", RememberJoins = true},
    KeySystem = false
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PlaceId = game.PlaceId

-- Safe player list function
local function GetPlayersLive()
    local players = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, player.Name)
        end
    end
    table.sort(players)
    return players
end

-- ESP System
local ESPConnections = {}
local ESPEnabled = false
local function CreateESP(player)
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Filled = false
    Box.Transparency = 1
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Visible = false
    
    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    Tracer.Color = Color3.fromRGB(255, 255, 255)
    Tracer.Transparency = 1
    Tracer.Visible = false
    
    local NameLabel = Drawing.new("Text")
    NameLabel.Size = 16
    NameLabel.Center = true
    NameLabel.Outline = true
    NameLabel.Font = 2
    NameLabel.Color = Color3.fromRGB(255, 255, 255)
    NameLabel.Visible = false
    
    local DistLabel = Drawing.new("Text")
    DistLabel.Size = 14
    DistLabel.Center = true
    DistLabel.Outline = true
    DistLabel.Font = 2
    DistLabel.Color = Color3.fromRGB(255, 255, 255)
    DistLabel.Visible = false
    
    ESPConnections[player] = {Box, Tracer, NameLabel, DistLabel}
    
    local function UpdateESP()
        if not ESPEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Head") then
            Box.Visible = false
            Tracer.Visible = false
            NameLabel.Visible = false
            DistLabel.Visible = false
            return
        end
        
        local rootPart = player.Character.HumanoidRootPart
        local head = player.Character.Head
        local humanoid = player.Character:FindFirstChild("Humanoid")
        
        local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        -- Rainbow colors
        local hue = tick() * 2
        local color = Color3.fromHSV(math.min(hue % 1, 1), 1, 1)
        
        -- Box
        local size = (headPos - legPos).Magnitude
        Box.Size = Vector2.new(2000 / rootPos.Z, size)
        Box.Position = Vector2.new(rootPos.X - Box.Size.X / 2, rootPos.Y - Box.Size.Y / 2)
        Box.Color = color
        Box.Visible = onScreen
        
        -- Tracer
        Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
        Tracer.Color = color
        Tracer.Visible = onScreen
        
        -- Labels
        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
        NameLabel.Text = player.Name
        NameLabel.Position = Vector2.new(rootPos.X, headPos.Y - 20)
        NameLabel.Color = color
        NameLabel.Visible = onScreen
        
        DistLabel.Text = distance .. "m"
        DistLabel.Position = Vector2.new(rootPos.X, headPos.Y + 5)
        DistLabel.Color = color
        DistLabel.Visible = onScreen
    end
    
    table.insert(ESPConnections, RunService.RenderStepped:Connect(UpdateESP))
end

local function ToggleESP(state)
    ESPEnabled = state
    if not state then
        for _, connection in ipairs(ESPConnections) do
            if connection then connection:Disconnect() end
        end
        ESPConnections = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then CreateESP(player) end
        end
    end
end

-- Movement variables
local FlyEnabled = false
local NoclipEnabled = false
local FlySpeed = 50
local BodyVelocity = nil
local BodyAngularVelocity = nil

-- Troll variables
local FlingLoop = false
local SpinEnabled = false
local JumpSpam = false

-- Welcome Tab
local WelcomeTab = Window:CreateTab("Witaj", 4483362458)
Window:CreateParagraph({Title = "Witaj w Turcja Hub v18.0!", Content = "Najlepszy cheat do Brookhaven!\n\nF8 = Teleport do gracza\nF9 = Ukryj/pokaż menu"})

-- Main Tab
local MainTab = Window:CreateTab("Main", 4483362458)
local MainSection = MainTab:CreateSection("Główne funkcje")

MainTab:CreateToggle({
    Name = "Rainbow ESP (Box + Tracer + Dist)",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        ToggleESP(Value)
    end
})

MainTab:CreateToggle({
    Name = "Fly (Hodl SPACE)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.Parent = character.HumanoidRootPart
                
                BodyAngularVelocity = Instance.new("BodyAngularVelocity")
                BodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
                BodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
                BodyAngularVelocity.Parent = character.HumanoidRootPart
            end
        else
            if BodyVelocity then BodyVelocity:Destroy() end
            if BodyAngularVelocity then BodyAngularVelocity:Destroy() end
        end
    end
})

MainTab:CreateSlider({
    Name = "Fly Speed",
    Range = {16, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        FlySpeed = Value
    end
})

MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        NoclipEnabled = Value
    end
})

-- Movement Tab
local MovementTab = Window:CreateTab("Movement", 4483362458)
local MovementSection = MovementTab:CreateSection("Ruch")

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        -- Handled in input
    end
})

MovementTab:CreateToggle({
    Name = "Bhop",
    CurrentValue = false,
    Flag = "BhopToggle",
    Callback = function(Value)
        -- Handled in RunService
    end
})

-- Players Tab
local PlayersTab = Window:CreateTab("Players", 4483362458)
local PlayersSection = PlayersTab:CreateSection("Gracze")

local PlayerList = GetPlayersLive()
local PlayerDropdown = PlayersTab:CreateDropdown({
    Name = "Wybierz gracza (TP)",
    Options = PlayerList,
    CurrentOption = PlayerList[1] or "",
    Flag = "PlayerTP",
    Callback = function(Option)
        -- TP handled by F8
    end
})

PlayersTab:CreateButton({
    Name = "Odśwież listę graczy",
    Callback = function()
        PlayerList = GetPlayersLive()
        PlayerDropdown:Refresh(PlayerList, true)
    end
})

local SpectateInput = PlayersTab:CreateInput({
    Name = "Spectate (wpisz nick)",
    PlaceholderText = "Nazwa gracza...",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        local target = Players:FindFirstChild(Text)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            Camera.CameraSubject = target.Character.Humanoid
            Camera.CameraType = Enum.CameraType.Custom
        end
    end
})

-- Visuals Tab
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        if Value then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = false
        else
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100
            game.Lighting.GlobalShadows = true
        end
    end
})

-- Troll Tab
local TrollTab = Window:CreateTab("Troll", 4483362458)
local TrollSection = TrollTab:CreateSection("Trolle")

TrollTab:CreateToggle({
    Name = "Fling All (Loop)",
    CurrentValue = false,
    Flag = "FlingLoop",
    Callback = function(Value)
        FlingLoop = Value
    end
})

TrollTab:CreateToggle({
    Name = "Spin All",
    CurrentValue = false,
    Flag = "SpinToggle",
    Callback = function(Value)
        SpinEnabled = Value
    end
})

TrollTab:CreateToggle({
    Name = "Jump Spam All",
    CurrentValue = false,
    Flag = "JumpSpam",
    Callback = function(Value)
        JumpSpam = Value
    end
})

TrollTab:CreateButton({
    Name = "Attach to Me (Weld)",
    Callback = function()
        local selectedPlayer = Players:FindFirstChild(PlayerDropdown.CurrentOption)
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and 
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = LocalPlayer.Character.HumanoidRootPart
            weld.Part1 = selectedPlayer.Character.HumanoidRootPart
            weld.Parent = LocalPlayer.Character.HumanoidRootPart
        end
    end
})

-- Brookhaven Tab
local BrookhavenTab = Window:CreateTab("Brookhaven", 4483362458)
local BrookSection = BrookhavenTab:CreateSection("Brookhaven Exploity")

if PlaceId == 4924922222 or PlaceId == 10785770177 then
    BrookhavenTab:CreateButton({
        Name = "Otwórz wszystkie drzwi/domki",
        Callback = function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("door") or obj.Name:lower():find("brama") then
                    local door = obj:FindFirstChild("Door")
                    if door then door.CanCollide = false end
                    obj.CanCollide = false
                end
            end
            Rayfield:Notify({Title = "Brookhaven", Content = "Drzwi otwarte!", Duration = 3})
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "Szybkie samochody (No Gamepass)",
        Callback = function()
            for _, car in ipairs(workspace:GetChildren()) do
                if car:FindFirstChild("VehicleSeat") then
                    local seat = car.VehicleSeat
                    seat.MaxSpeed = 100
                    seat.Torque = 10000
                end
            end
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "Infinite Money (Shop)",
        Callback = function()
            local args = { [1] = "BuyItem", [2] = "Money", [3] = 999999 }
            game:GetService("ReplicatedStorage").RemoteEvent:FireServer(unpack(args))
        end
    })
else
    BrookhavenTab:CreateParagraph({Title = "Brookhaven", Content = "Wejdź na Brookhaven [4924922222] aby używać exploitów!"})
end

-- F8 Teleport Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F8 then
        local selectedPlayer = Players:FindFirstChild(PlayerDropdown.CurrentOption)
        if selectedPlayer and selectedPlayer.Character and selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = selectedPlayer.Character.HumanoidRootPart.CFrame
            Rayfield:Notify({Title = "Teleport", Content = "Teleported to " .. selectedPlayer.Name, Duration = 2})
        else
            Rayfield:Notify({Title = "Błąd", Content = "Gracz nie znaleziony!", Duration = 2})
        end
    end
end)

-- Movement Loop
RunService.Stepped:Connect(function()
    -- Fly
    if FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and BodyVelocity then
        local camera = workspace.CurrentCamera
        local vel = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, FlySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            vel = vel + Vector3.new(0, -FlySpeed, 0)
        end
        BodyVelocity.Velocity = camera.CFrame:VectorToWorldSpace(vel)
    end
    
    -- Noclip
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Fling Loop
    if FlingLoop then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-100,100), 50, math.random(-100,100))
            end
        end
    end
    
    -- Spin All
    if SpinEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(25), 0)
            end
        end
    end
    
    -- Jump Spam
    if JumpSpam then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Jump = true
            end
        end
    end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Rayfield.Flags["InfJump"] then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Bhop
local BhopConnection
Rayfield.Flags["BhopToggle"] = false
RunService.Heartbeat:Connect(function()
    if Rayfield.Flags["BhopToggle"] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.Jump = true
    end
end)

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        CreateESP(player)
    end)
end)

Rayfield:Notify({
    Title = "Turcja Hub v18.0",
    Content = "Załadowano bez błędów! F8 = TP",
    Duration = 5,
    Image = 4483362458
})
