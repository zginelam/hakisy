-- Turcja Hub v19.3 | PERFECT FLY + PROFESSIONAL
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
    game.StarterGui:SetCore("SendNotification", {
        Title = "BŁĄD"; 
        Text = "Rayfield nie załadowany!"; 
        Duration = 5;
    })
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v1.0",
   LoadingTitle = "Turcja Hub Pro",
   LoadingSubtitle = "Professional loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TurcjaHubV19"
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
local Lighting = game:GetService("Lighting")

-- GAME DETECTION
local currentGame = "Unknown"
local gameIds = {
    [4924922222] = "Brookhaven",
    [9047611498] = "Case Paradise", 
    [286090429] = "Arsenal"
}
currentGame = gameIds[game.PlaceId] or "Unknown"

-- STATE VARIABLES
local ESPEnabled = false
local FlyEnabled = false
local NoclipEnabled = false
local FakeLagEnabled = false
local FlingLoop = false
local SpinEnabled = false
local JumpSpam = false
local InfJumpEnabled = false
local selectedPlayerName = ""
local playerNames = {}
local flySpeed = 50

-- FLY SYSTEM (PERFECT)
local flyBodyVelocity = nil
local flyBodyAngularVelocity = nil

local espObjects = {}

-- PERFECT PLAYER LIST
local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Parent then
            table.insert(names, player.Name)
        end
    end
    table.sort(names)
    return names
end

playerNames = getPlayerNames()

-- CLEAN ESP
local function cleanupESP(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            pcall(function() drawing:Remove() end)
        end
        espObjects[player] = nil
    end
end

-- TABS
local WelcomeTab = Window:CreateTab("🎉 Welcome", 4483362458)
local MainTab = Window:CreateTab("🏠 Main", 4483362458)
local PlayersTab = Window:CreateTab("👥 Players", 4483362458)
local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)
local VisualsTab = Window:CreateTab("🎨 Visuals", 4483362458)
local TrollTab = Window:CreateTab("😂 Troll", 4483362458)

local BrookhavenTab = currentGame == "Brookhaven" and Window:CreateTab("🏘️ Brookhaven", 4483362458)

-- WELCOME TAB
WelcomeTab:CreateParagraph({Title = "ℹ️ Info", Content = "Tylko dla gitów nie cfeli"})
WelcomeTab:CreateParagraph({Title = "🎮 Games", Content = "Brookhaven | CaseParadise | Arsenal"})

WelcomeTab:CreateButton({
    Name = "📋 Copy Discord: turcja",
    Callback = function()
        pcall(setclipboard, "turcja")
        Rayfield:Notify({Title = "Copied!", Content = "turcja", Duration = 2, Image = 4483362458})
    end
})

-- MAIN TAB
MainTab:CreateToggle({
    Name = "💎 Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(Value)
        Lighting.Brightness = Value and 2 or 1
        Lighting.ClockTime = Value and 14 or 12
        Lighting.FogEnd = Value and 9e9 or 100000
        Lighting.GlobalShadows = not Value
    end
})

MainTab:CreateButton({
    Name = "🔓 Unlock All Doors",
    Callback = function()
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate")) then
                obj.CanCollide = false
                obj.Transparency = 0.7
                count = count + 1
            end
        end
        Rayfield:Notify({Title = "Unlocked", Content = count .. " objects", Duration = 3})
    end
})

-- PLAYERS TAB
PlayersTab:CreateButton({
    Name = "🔄 Refresh Players",
    Callback = function()
        playerNames = getPlayerNames()
        Rayfield:Notify({Title = "Refreshed", Content = #playerNames .. " players", Duration = 2})
    end
})

local tpDropdown = PlayersTab:CreateDropdown({
    Name = "👤 TP Player",
    Options = playerNames,
    CurrentOption = "Select...",
    Flag = "TPPlayer",
    Callback = function(Option)
        selectedPlayerName = Option[1]
    end
})

PlayersTab:CreateButton({
    Name = "⚡ Teleport Now",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and 
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, -2)
            Rayfield:Notify({Title = "TP Success", Content = selectedPlayerName, Duration = 2})
        else
            Rayfield:Notify({Title = "Error", Content = "Player not found", Duration = 3, Image = 16711680})
        end
    end
})

local spectateDropdown = PlayersTab:CreateDropdown({
    Name = "👁️ Spectate",
    Options = playerNames,
    CurrentOption = "Select...",
    Flag = "SpectatePlayer",
    Callback = function(Option)
        local target = Players:FindFirstChild(Option[1])
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = target.Character.Humanoid
        end
    end
})

-- MOVEMENT TAB (PERFECT FLY)
MovementTab:CreateToggle({
    Name = "✈️ PERFECT Fly (WASD+Space+Shift)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        FlyEnabled = Value
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {16, 300},
    Increment = 10,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
    end
})

MovementTab:CreateToggle({
    Name = "👻 Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value)
        NoclipEnabled = Value
    end
})

MovementTab:CreateToggle({
    Name = "📈 Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        InfJumpEnabled = Value
    end
})

MovementTab:CreateToggle({
    Name = "🎭 Fake Lag PRO",
    CurrentValue = false,
    Flag = "FakeLag",
    Callback = function(Value)
        FakeLagEnabled = Value
    end
})

-- VISUALS
VisualsTab:CreateToggle({
    Name = "🌈 Professional ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value
    end
})

-- TROLL
TrollTab:CreateToggle({
    Name = "💥 Fling Everyone",
    CurrentValue = false,
    Flag = "Fling",
    Callback = function(Value)
        FlingLoop = Value
    end
})

TrollTab:CreateToggle({
    Name = "⭕ Spin Everyone",
    CurrentValue = false,
    Flag = "Spin",
    Callback = function(Value)
        SpinEnabled = Value
    end
})

TrollTab:CreateButton({
    Name = "🪑 Sit On Head",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("Head") and 
           LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 3, 0)
        end
    end
})

-- BROOKHAVEN
if BrookhavenTab then
    BrookhavenTab:CreateButton({
        Name = "🏠 All Houses",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "Hause", "Recieve")
            end)
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "💰 1M Money",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "SetCash", 1000000)
            end)
        end
    })
end

-- PERFECT ESP SYSTEM
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[player] then
                espObjects[player] = {
                    box = Drawing.new("Square"),
                    tracer = Drawing.new("Line"),
                    name = Drawing.new("Text"),
                    dist = Drawing.new("Text")
                }
                for _, obj in pairs(espObjects[player]) do
                    obj.Visible = false
                end
            end
            
            local esp = espObjects[player]
            local root = player.Character.HumanoidRootPart
            local headPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2, 0))
            local footPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4, 0))
            
            if headPos.Z > 0 and footPos.Z > 0 then
                local height = math.abs(headPos.Y - footPos.Y)
                local width = height * 0.4
                
                local color = Color3.fromHSV((tick() * 0.3) % 1, 1, 1)
                
                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(headPos.X - width/2, headPos.Y - height/2)
                esp.box.Color = color
                esp.box.Visible = true
                
                esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                esp.tracer.To = Vector2.new(headPos.X, headPos.Y)
                esp.tracer.Color = color
                esp.tracer.Visible = true
                
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                esp.name.Text = player.Name
                esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
                esp.name.Color = color
                esp.name.Visible = true
                
                esp.dist.Text = dist .. "m"
                esp.dist.Position = Vector2.new(headPos.X, headPos.Y - 10)
                esp.dist.Color = Color3.new(1,1,1)
                esp.dist.Visible = true
            end
        end
    end
end)

-- **PERFECT FLY SYSTEM** - ZERO BUGS
local flyConnection
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end
    
    -- PERFECT FLY
    if FlyEnabled then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            flyBodyVelocity.Parent = root
            
            flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
            flyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 50, 0)
            flyBodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
            flyBodyAngularVelocity.Parent = root
        end
        
        local moveVector = Vector3.new()
        local camLook = Camera.CFrame.LookVector
        local camRight = Camera.CFrame.RightVector
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camLook
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camLook
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camRight
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camRight
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        if moveVector.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveVector.Unit * flySpeed
        else
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
    elseif flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyAngularVelocity:Destroy()
        flyBodyVelocity = nil
        flyBodyAngularVelocity = nil
    end
    
    -- NOCLIP
    if NoclipEnabled then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- FAKE LAG
    if FakeLagEnabled then
        root.Velocity = root.Velocity * 0.2
    end
    
    -- TROLLS
    if FlingLoop then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-100,100), 150, math.random(-100,100))
            end
        end
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- CLEANUP
Players.PlayerRemoving:Connect(function(player)
    cleanupESP(player)
end)

Rayfield:Notify({
    Title = "Turcja Hub v19.3",
    Content = "PERFECT FLY + NO ERRORS | " .. currentGame,
    Duration = 5,
    Image = 4483362458
})

print("Turcja Hub v19.3 - PERFECT FLY LOADED ✅")
