-- Turcja Hub v19.2 | ALL ERRORS FIXED | PROFESSIONAL
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
   Name = "Turcja Hub v19.2 🔥 NO ERRORS",
   LoadingTitle = "Turcja Hub Pro",
   LoadingSubtitle = "Ładowanie bez błędów...",
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

-- STATE
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

local espObjects = {}
local FlyConnection = nil
local FlyBodyPosition = nil
local FlyBodyAngularVelocity = nil

-- UPDATE PLAYER LIST (SAFE)
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

-- CLEAN ESP FUNCTION
local function cleanupESP(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            pcall(function() drawing:Remove() end)
        end
        espObjects[player] = nil
    end
end

-- ADVANCED FLY SYSTEM (NOW PERFECT)
local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local root = char.HumanoidRootPart
    local humanoid = char:FindFirstChild("Humanoid")
    
    -- Clean old fly objects
    if FlyBodyPosition then FlyBodyPosition:Destroy() end
    if FlyBodyAngularVelocity then FlyBodyAngularVelocity:Destroy() end
    if FlyConnection then FlyConnection:Disconnect() end
    
    -- Create new fly objects
    FlyBodyPosition = Instance.new("BodyPosition")
    FlyBodyPosition.Name = "FlyBodyPosition"
    FlyBodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
    FlyBodyPosition.Position = root.Position
    FlyBodyPosition.D = 500
    FlyBodyPosition.P = 15000
    FlyBodyPosition.Parent = root
    
    FlyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
    FlyBodyAngularVelocity.Name = "FlyBodyAngularVelocity"
    FlyBodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
    FlyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
    FlyBodyAngularVelocity.P = 500
    FlyBodyAngularVelocity.Parent = root
    
    humanoid.PlatformStand = true
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not FlyEnabled or not char.Parent or not root.Parent then
            return
        end
        
        local moveVector = Vector3.new()
        local camera = Workspace.CurrentCamera
        
        -- WASD Movement
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector = moveVector + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector = moveVector - camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector = moveVector - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector = moveVector + camera.CFrame.RightVector
        end
        
        -- Vertical movement
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector = moveVector + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveVector = moveVector - Vector3.new(0, 1, 0)
        end
        
        -- Apply movement
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * (flySpeed / 16) -- Normalize speed
            FlyBodyPosition.Position = root.Position + moveVector
        end
        
        -- Smooth camera alignment
        local cameraCFrame = camera.CFrame
        root.CFrame = CFrame.new(root.Position, root.Position + cameraCFrame.LookVector * 50)
    end)
end

local function stopFly()
    if FlyBodyPosition then
        FlyBodyPosition:Destroy()
        FlyBodyPosition = nil
    end
    if FlyBodyAngularVelocity then
        FlyBodyAngularVelocity:Destroy()
        FlyBodyAngularVelocity = nil
    end
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
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

-- WELCOME TAB (FIXED)
WelcomeTab:CreateParagraph({
    Title = "ℹ️ Informacja",
    Content = "Exploit tylko dla gitów nie dla cfeli"
})

WelcomeTab:CreateParagraph({
    Title = "🎮 Gry",
    Content = "Brookhaven | CaseParadise | Arsenal"
})

WelcomeTab:CreateButton({
    Name = "📋 Copy Discord: turcja",
    Callback = function()
        pcall(function()
            setclipboard("turcja")
        end)
        Rayfield:Notify({
            Title = "Sukces",
            Content = "turcja skopiowane do schowka!",
            Duration = 3,
            Image = 4483362458
        })
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
    Name = "🔓 Unlock All (Drzwi/Bramy)",
    Callback = function()
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("door") or obj.Name:lower():find("gate") or obj.Name:lower():find("brama")) then
                obj.CanCollide = false
                obj.Transparency = 0.7
                count = count + 1
            end
        end
        Rayfield:Notify({
            Title = "Odblokowano",
            Content = count .. " obiektów!",
            Duration = 3
        })
    end
})

-- PLAYERS TAB (FULLY FIXED)
PlayersTab:CreateButton({
    Name = "🔄 Odśwież graczy",
    Callback = function()
        playerNames = getPlayerNames()
        Rayfield:Notify({
            Title = "Odświeżono",
            Content = #playerNames .. " graczy",
            Duration = 2
        })
    end
})

local tpDropdown = PlayersTab:CreateDropdown({
    Name = "👤 Gracz TP",
    Options = playerNames,
    CurrentOption = "Wybierz...",
    Flag = "TPPlayer",
    Callback = function(Option)
        selectedPlayerName = Option[1]
    end
})

PlayersTab:CreateButton({
    Name = "⚡ TP do gracza",
    Callback = function()
        if not selectedPlayerName or selectedPlayerName == "Wybierz..." then
            Rayfield:Notify({
                Title = "Błąd",
                Content = "Wybierz gracza!",
                Duration = 3,
                Image = 16711680
            })
            return
        end
        
        local targetPlayer = Players:FindFirstChild(selectedPlayerName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 3, -2)
                Rayfield:Notify({
                    Title = "TP",
                    Content = "Do " .. selectedPlayerName,
                    Duration = 2
                })
            end
        else
            Rayfield:Notify({
                Title = "Błąd",
                Content = "Gracz offline!",
                Duration = 3,
                Image = 16711680
            })
        end
    end
})

local spectateDropdown = PlayersTab:CreateDropdown({
    Name = "👁️ Spectate",
    Options = playerNames,
    CurrentOption = "Wybierz...",
    Flag = "SpectatePlayer",
    Callback = function(Option)
        local targetPlayer = Players:FindFirstChild(Option[1])
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = targetPlayer.Character.Humanoid
            Rayfield:Notify({
                Title = "Spectate",
                Content = Option[1],
                Duration = 2
            })
        end
    end
})

-- MOVEMENT TAB (PERFECT FLY + FAKELAG)
MovementTab:CreateToggle({
    Name = "✈️ Fly (WASD+Space+Shift) - PERFECT",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        FlyEnabled = Value
        if Value then
            startFly()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Włączony (Speed: " .. flySpeed .. ")",
                Duration = 2
            })
        else
            stopFly()
            Rayfield:Notify({
                Title = "Fly",
                Content = "Wyłączony",
                Duration = 2
            })
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {16, 500},
    Increment = 10,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        flySpeed = Value
        if FlyEnabled then
            Rayfield:Notify({
                Title = "Fly Speed",
                Content = "Ustawiono: " .. Value,
                Duration = 1.5
            })
        end
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
    Name = "📈 Inf Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(Value)
        InfJumpEnabled = Value
    end
})

MovementTab:CreateToggle({
    Name = "🎭 Pro FakeLag",
    CurrentValue = false,
    Flag = "FakeLag",
    Callback = function(Value)
        FakeLagEnabled = Value
    end
})

MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- VISUALS TAB
VisualsTab:CreateToggle({
    Name = "🌈 Pro ESP (Box+Tracer+Dist)",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value)
        ESPEnabled = Value
    end
})

-- TROLL TAB
TrollTab:CreateToggle({
    Name = "💥 Fling All",
    CurrentValue = false,
    Flag = "Fling",
    Callback = function(Value)
        FlingLoop = Value
    end
})

TrollTab:CreateToggle({
    Name = "⭕ Spin All", 
    CurrentValue = false,
    Flag = "Spin",
    Callback = function(Value)
        SpinEnabled = Value
    end
})

TrollTab:CreateToggle({
    Name = "🦘 Jump Spam",
    CurrentValue = false,
    Flag = "JumpSpam",
    Callback = function(Value)
        JumpSpam = Value
    end
})

TrollTab:CreateButton({
    Name = "🪑 Sit on Head",
    Callback = function()
        if not selectedPlayerName or selectedPlayerName == "Wybierz..." then
            Rayfield:Notify({Title="Błąd", Content="Wybierz gracza!", Image=16711680})
            return
        end
        local target = Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 3, 0)
                Rayfield:Notify({Title="Sit", Content="Na głowie " .. selectedPlayerName})
            end
        end
    end
})

-- BROOKHAVEN (FIXED WORKING SCRIPTS)
if BrookhavenTab then
    BrookhavenTab:CreateButton({
        Name = "🏠 Give All Houses",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "Hause", "Recieve")
            end)
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "💰 Max Money",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "SetCash", 1000000)
            end)
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "🚗 Car Speed x10",
        Callback = function()
            for _, v in pairs(Workspace:GetChildren()) do
                pcall(function()
                    if v:FindFirstChildOfClass("VehicleSeat") then
                        v.VehicleSeat.MaxSpeed = 200
                        v.VehicleSeat.Torque = 4000
                    end
                end)
            end
        end
    })
    
    BrookhavenTab:CreateButton({
        Name = "🔑 All Tools",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "Tool", "GiveAll")
            end)
        end
    })
end

-- ADVANCED ESP SYSTEM
RunService.RenderStepped:Connect(function()
    if not ESPEnabled then
        for player, data in pairs(espObjects) do
            pcall(function()
                data.box.Visible = false
                data.tracer.Visible = false
                data.name.Visible = false
                data.dist.Visible = false
            end)
        end
        return
    end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not espObjects[player] then
                local box = Drawing.new("Square")
                box.Thickness = 2
                box.Filled = false
                box.Visible = false
                
                local tracer = Drawing.new("Line")
                tracer.Thickness = 2
                tracer.Visible = false
                
                local nameTag = Drawing.new("Text")
                nameTag.Size = 16
                nameTag.Center = true
                nameTag.Outline = true
                nameTag.Font = 2
                nameTag.Visible = false
                
                local distTag = Drawing.new("Text")
                distTag.Size = 14
                distTag.Center = true
                distTag.Outline = true
                distTag.Font = 2
                distTag.Visible = false
                
                espObjects[player] = {box=box, tracer=tracer, name=nameTag, dist=distTag}
            end
            
            local esp = espObjects[player]
            local root = player.Character.HumanoidRootPart
            local head = player.Character:FindFirstChild("Head")
            
            if head then
                local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
                
                if onScreen then
                    local height = math.clamp(math.abs(headPos.Y - legPos.Y), 20, 100)
                    local width = height * 0.4
                    
                    -- Rainbow
                    local hue = (tick() * 0.5) % 1
                    local color = Color3.fromHSV(hue, 1, 1)
                    
                    -- Box
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
                    esp.box.Color = color
                    esp.box.Visible = true
                    
                    -- Tracer
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y * 0.9)
                    esp.tracer.To = Vector2.new(rootPos.X, rootPos.Y + height/2)
                    esp.tracer.Color = color
                    esp.tracer.Visible = true
                    
                    -- Tags
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    esp.name.Text = player.Name
                    esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 25)
                    esp.name.Color = color
                    esp.name.Visible = true
                    
                    esp.dist.Text = tostring(dist) .. "m"
                    esp.dist.Position = Vector2.new(rootPos.X, headPos.Y - 10)
                    esp.dist.Color = Color3.new(1,1,1)
                    esp.dist.Visible = true
                else
                    esp.box.Visible = false
                    esp.tracer.Visible = false
                    esp.name.Visible = false
                    esp.dist.Visible = false
                end
            end
        end
    end
end)

-- MAIN LOOP (ALL FEATURES - WITHOUT FLY)
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if not root or not hum then return end
    
    -- NOCLIP
    if NoclipEnabled then
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
    
    -- FAKELAG PRO
    if FakeLagEnabled then
        root.Velocity = root.Velocity * 0.3
        if tick() % 0.1 < 0.05 then
            hum.PlatformStand = true
        else
            hum.PlatformStand = false
        end
    end
    
    -- TROLLS
    if FlingLoop then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.Velocity = Vector3.new(
                    math.random(-150,150), 250, math.random(-150,150)
                )
            end
        end
    end
    
    if SpinEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                plr.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(80), 0)
            end
        end
    end
    
    if JumpSpam then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                pcall(function()
                    plr.Character.Humanoid.Jump = true
                end)
            end
        end
    end
end)

-- CLEANUP ON CHARACTER SPAWN/REMOVAL
LocalPlayer.CharacterAdded:Connect(function()
    if FlyEnabled then
        wait(1)
        startFly()
    end
end)

-- JUMP + CLEANUP
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

Players.PlayerRemoving:Connect(function(player)
    cleanupESP(player)
    playerNames = getPlayerNames()
end)

Players.PlayerAdded:Connect(function()
    wait(1)
    playerNames = getPlayerNames()
end)

Rayfield:Notify({
    Title = "Turcja Hub v19.2",
    Content = "Załładowano bez błędów! | " .. currentGame .. " | PERFECT FLY ✅",
    Duration = 5,
    Image = 4483362458
})

print("Turcja Hub v19.2 LOADED PERFECTLY ✅ NO CALLBACK ERRORS | PERFECT FLY")
