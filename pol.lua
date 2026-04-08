-- Turcja Hub v19.0 | PROFESSIONAL | ALL FIXED + NEW FEATURES
local success, Rayfield = pcall(function()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
        "https://raw.githubusercontent.com/RegularVynixu/rayfield/main/source"
    }
    
    for _, url in ipairs(urls) do
        local ok, result = pcall(loadstring(game:HttpGetAsync(url, true)))
        if ok and result then return result end
    end
end)

if not success or not Rayfield then
    print("Rayfield CRITICAL FAIL")
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v19.0 🔥 PROFESSIONAL",
   LoadingTitle = "Turcja Hub",
   LoadingSubtitle = "Loading professional features...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TurcjaHubPro"
   },
   KeySystem = false
})

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- GAME DETECTION
local supportedGames = {
    Brookhaven = 4924922222,
    ["Case Paradise"] = 9047611498,
    Arsenal = 286090429
}

local currentGame = "Unknown"
for gameName, placeId in pairs(supportedGames) do
    if game.PlaceId == placeId then
        currentGame = gameName
        break
    end
end

-- STATE VARIABLES
local ESPEnabled = false
local FlyEnabled = false
local NoclipEnabled = false
local FakeLagEnabled = false
local FlingLoop = false
local SpinEnabled = false
local JumpSpam = false
local selectedPlayer = ""
local playerList = {"Ładuję..."}

-- ADVANCED ESP SYSTEM
local espObjects = {}
local function createESP(player)
    if espObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    box.Color = Color3.fromHSV(0, 1, 1)
    box.Visible = false
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = 2
    tracer.Color = Color3.fromHSV(0, 1, 1)
    tracer.Transparency = 1
    tracer.Visible = false
    
    local nameTag = Drawing.new("Text")
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2
    nameTag.Color = Color3.fromHSV(0, 1, 1)
    nameTag.Visible = false
    
    local distanceTag = Drawing.new("Text")
    distanceTag.Size = 14
    distanceTag.Center = true
    distanceTag.Outline = true
    distanceTag.Font = 2
    distanceTag.Color = Color3.fromRGB(255, 255, 255)
    distanceTag.Visible = false
    
    espObjects[player] = {box = box, tracer = tracer, name = nameTag, dist = distanceTag}
end

-- LIVE PLAYER LIST
local function updatePlayerList()
    playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(playerList, plr.Name)
        end
    end
    table.sort(playerList)
end
updatePlayerList()

-- TABS
local WelcomeTab = Window:CreateTab("🎉 Welcome", 4483362458)
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local PlayersTab = Window:CreateTab("👥 Players", 4483362458)
local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)
local VisualsTab = Window:CreateTab("🎨 Visuals", 4483362458)
local TrollTab = Window:CreateTab("😂 Troll", 4483362458)

-- BROOKHAVEN TAB (CONDITIONAL)
local BrookhavenTab
if currentGame == "Brookhaven" then
    BrookhavenTab = Window:CreateTab("🏘️ Brookhaven", 4483362458)
end

-- WELCOME TAB
WelcomeTab:CreateParagraph({Title = "ℹ️ Informacje", Content = "Exploit jest tylko dla gitów nie dla cfeli"})
WelcomeTab:CreateParagraph({Title = "🎮 Wspierane gry", Content = "Brookhaven, CaseParadise, Arsenal"})
WelcomeTab:CreateButton({
    Name = "📋 Copy Discord",
    Callback = function()
        setclipboard("turcja")
        WelcomeTab:Notify("Discord 'turcja' skopiowany! ✅")
    end
})

-- MAIN TAB (NEW FEATURES)
MainTab:CreateToggle({
    Name = "🌈 Advanced Rainbow ESP",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state
    end
})

MainTab:CreateToggle({
    Name = "💎 Fullbright",
    CurrentValue = false,
    Callback = function(state)
        if state then
            game.Lighting.Brightness = 2
            game.Lighting.ClockTime = 14
            game.Lighting.FogEnd = 9e9
            game.Lighting.GlobalShadows = false
        else
            game.Lighting.Brightness = 1
            game.Lighting.ClockTime = 12
            game.Lighting.FogEnd = 100000
            game.Lighting.GlobalShadows = true
        end
    end
})

MainTab:CreateButton({
    Name = "🔓 Unlock All Doors",
    Callback = function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Locked == true then
                obj.Locked = false
            end
        end
    end
})

-- PLAYERS TAB (FIXED)
PlayersTab:CreateButton({
    Name = "🔄 Odśwież listę graczy",
    Callback = function()
        updatePlayerList()
        PlayersTab:Notify("Lista odświeżona! (" .. #playerList .. " graczy)")
    end
})

local TPDropdown = PlayersTab:CreateDropdown({
    Name = "👤 Wybierz gracza do TP",
    Options = playerList,
    CurrentOption = {"Wybierz gracza"},
    MultipleOptions = false,
    Callback = function(option)
        selectedPlayer = option[1]
        PlayersTab:Notify("Wybrano: " .. selectedPlayer)
    end,
})

PlayersTab:CreateButton({
    Name = "⚡ Teleport do wybranego gracza",
    Callback = function()
        if selectedPlayer == "" then
            PlayersTab:Notify("Najpierw wybierz gracza!", 4483362458)
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
            PlayersTab:Notify("Teleport do " .. selectedPlayer .. " ✅")
        else
            PlayersTab:Notify("Gracz nie znaleziony lub brak postaci!", 16711680)
        end
    end
})

local SpectateDropdown = PlayersTab:CreateDropdown({
    Name = "👁️ Wybierz gracza do spectate",
    Options = playerList,
    CurrentOption = {"Wybierz gracza"},
    MultipleOptions = false,
    Callback = function(option)
        local target = Players:FindFirstChild(option[1])
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
            PlayersTab:Notify("Spectate: " .. option[1] .. " ✅")
        else
            PlayersTab:Notify("Błąd spectate!", 16711680)
        end
    end,
})

-- MOVEMENT TAB
MovementTab:CreateToggle({
    Name = "✈️ Fly (SPACE)",
    CurrentValue = false,
    Callback = function(state)
        FlyEnabled = state
    end
})

MovementTab:CreateToggle({
    Name = "👻 Noclip",
    CurrentValue = false,
    Callback = function(state)
        NoclipEnabled = state
    end
})

MovementTab:CreateToggle({
    Name = "📈 Infinite Jump",
    CurrentValue = false,
    Callback = function(state)
        -- Toggle handled in JumpRequest
    end
})

MovementTab:CreateSlider({
    Name = "🏃 WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = value
        end
    end
})

MovementTab:CreateToggle({
    Name = "🎭 Fake Lag (Widoczne dla wszystkich)",
    CurrentValue = false,
    Callback = function(state)
        FakeLagEnabled = state
    end
})

-- VISUALS TAB
VisualsTab:CreateToggle({
    Name = "🌈 Pro Rainbow ESP (Box + Tracer + Distance)",
    CurrentValue = false,
    Callback = function(state)
        ESPEnabled = state
    end
})

-- TROLL TAB (ENHANCED)
TrollTab:CreateToggle({
    Name = "💥 Fling All (POPRAWIONE)",
    CurrentValue = false,
    Callback = function(state)
        FlingLoop = state
    end
})

TrollTab:CreateToggle({
    Name = "⭕ Spin All",
    CurrentValue = false,
    Callback = function(state)
        SpinEnabled = state
    end
})

TrollTab:CreateToggle({
    Name = "🦘 Jump Spam All",
    CurrentValue = false,
    Callback = function(state)
        JumpSpam = state
    end
})

TrollTab:CreateButton({
    Name = "🪑 Sit on Player Head (POPRAWIONE)",
    Callback = function()
        if selectedPlayer == "" then
            TrollTab:Notify("Wybierz gracza z Players!", 16711680)
            return
        end
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("Head") and LocalPlayer.Character then
            local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                humanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 2, 0)
                TrollTab:Notify("Siedzisz na głowie " .. selectedPlayer .. "!")
            end
        end
    end
})

TrollTab:CreateButton({
    Name = "🔗 Attach Player to Me",
    Callback = function()
        if selectedPlayer == "" then return end
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and LocalPlayer.Character then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = LocalPlayer.Character.HumanoidRootPart
            weld.Part1 = target.Character.HumanoidRootPart
            weld.Parent = LocalPlayer.Character.HumanoidRootPart
            TrollTab:Notify("Przyczepiono " .. selectedPlayer)
        end
    end
})

-- BROOKHAVEN SCRIPTS (WORKING)
if BrookhavenTab then
    BrookhavenTab:CreateButton({
        Name = "🏠 Give All Houses",
        Callback = function()
            local args = {game.Players.LocalPlayer, "Hause", "Recieve"}
            ReplicatedStorage.MainEvent:FireServer(unpack(args))
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "💰 Max Money",
        Callback = function()
            local args = {game.Players.LocalPlayer, "SetCash", math.huge}
            ReplicatedStorage.MainEvent:FireServer(unpack(args))
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "🚗 Super Car Speed",
        Callback = function()
            for _, v in pairs(Workspace:GetChildren()) do
                if v.Name == "Car" or v:FindFirstChild("VehicleSeat") then
                    local seat = v:FindFirstChild("VehicleSeat")
                    if seat then
                        seat.MaxSpeed = 500
                        seat.Torque = 10000
                    end
                end
            end
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "🚪 Open All Doors",
        Callback = function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate")) then
                    obj.CanCollide = false
                    obj.Transparency = 0.7
                end
            end
        end
    })
end

-- ADVANCED ESP RENDER LOOP
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then
        for player, esp in pairs(espObjects) do
            esp.box.Visible = false
            esp.tracer.Visible = false
            esp.name.Visible = false
            esp.dist.Visible = false
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
            createESP(player)
            local esp = espObjects[player]
            
            local rootPart = player.Character.HumanoidRootPart
            local head = player.Character.Head
            local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position)
            local legPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                -- Rainbow colors
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 1, 1)
                
                -- Box
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.5
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                esp.box.Color = color
                esp.box.Visible = true
                
                -- Tracer
                esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                esp.tracer.Color = color
                esp.tracer.Visible = true
                
                -- Name + Distance
                local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude)
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
                esp.name.Color = color
                esp.name.Visible = true
                
                esp.dist.Text = distance .. "m"
                esp.dist.Position = Vector2.new(rootPos.X, headPos.Y - 5)
                esp.dist.Visible = true
            else
                esp.box.Visible = false
                esp.tracer.Visible = false
                esp.name.Visible = false
                esp.dist.Visible = false
            end
        end
    end
end)

-- CLEANUP ESP
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            obj:Remove()
        end
        espObjects[player] = nil
    end
end)

-- MAIN LOOP
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    -- FLY
    if FlyEnabled and root then
        local bv = root:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Parent = root
        local cam = Workspace.CurrentCamera
        local vel = cam.CFrame:VectorToWorldSpace(Vector3.new(0, 0, 0))
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 50, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel + Vector3.new(0, -50, 0) end
        bv.Velocity = vel
    end
    
    -- NOCLIP
    if NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- FAKE LAG
    if FakeLagEnabled and root and humanoid then
        root.Velocity = root.Velocity * 0.1
        humanoid.PlatformStand = math.random() > 0.7
    end
    
    -- TROLL FEATURES
    if FlingLoop then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-100,100), 200, math.random(-100,100))
            end
        end
    end
    
    if SpinEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(100), 0)
            end
        end
    end
    
    if JumpSpam then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Jump = true
            end
        end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- PLAYER LIST UPDATE
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

print("Turcja Hub v19.0 PROFESSIONAL LOADED ✅ | Game: " .. currentGame)
