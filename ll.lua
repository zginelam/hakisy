-- Turcja Hub v15.0 | ULTIMATE PENTEST EDITION | GAME DETECTION + DROPDOWNS
print("=== Turcja Hub v15.0 ULTIMATE INITIALIZING ===")

-- SAFE Rayfield (Enterprise Stable)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v1.0",
   LoadingTitle = "Turcja hub",
   LoadingSubtitle = "Loading...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHubV15",
      FileName = "ultimate-config"
   },
   KeySystem = false
})

-- SERVICES (Safe & Fast)
local Services = {}
for _, service in pairs({"Players", "RunService", "UserInputService", "Workspace", "MarketplaceService", "ReplicatedStorage", "TeleportService", "Lighting", "TweenService", "Debris"}) do
   local success, s = pcall(game.GetService, game, service)
   Services[service] = success and s or nil
end

local Players, RunService, UserInputService, Workspace = Services.Players, Services.RunService, Services.UserInputService, Services.Workspace
local LocalPlayer, Camera = Players.LocalPlayer, Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

print("✅ Services initialized")

-- GAME DETECTION (Advanced)
local gameInfo = Services.MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Game)
local gameName = gameInfo.Name:lower()
local supportedGames = {
   brookhaven = 4924922222,
   ["case paradise"] = 8777340150,
   arsenal = 286090429,
   strongestbattlegrounds = 2561999019
}

local isBrookhaven = game.PlaceId == 4924922222
print("🎮 Detected: " .. gameInfo.Name .. " (ID: " .. game.PlaceId .. ")")

-- STATES
local States = {fly=false, noclip=false, esp=false, fling=false, fpsboost=false, godmode=false, infjump=false, fullbright=false, bhop=false, flyspeed=50, walkspeed=16, fov=70}
local Toggles = {}
local Connections = {}
local ESPObjects = {}
local notificationCooldown = 0

-- UTILS
local function notify(title, content, duration)
   if tick() - notificationCooldown < 3 then return end
   notificationCooldown = tick()
   pcall(function()
      Rayfield:Notify({Title=title, Content=content, Duration=duration or 4, Image=4483362458})
   end)
end

-- PLAYER LIST (Live Dropdown)
local function getPlayerList()
   local list = {}
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(list, player.Name)
      end
   end
   return list
end

-- FLY v7 (Perfect)
local function toggleFly(enabled)
   States.fly = enabled
   if Connections.Fly then Connections.Fly:Disconnect() end
   
   if enabled then
      Connections.Fly = RunService.Heartbeat:Connect(function()
         local char = LocalPlayer.Character
         if char and char:FindFirstChild("HumanoidRootPart") then
            local root = char.HumanoidRootPart
            local move = Vector3.new(0,0,0)
            local cam = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
            
            root.Velocity = move.Unit * States.flyspeed
         end
      end)
   end
end

-- NOCLIP v6
local function toggleNoclip(enabled)
   States.noclip = enabled
   if Connections.Noclip then Connections.Noclip:Disconnect() end
   if enabled then
      Connections.Noclip = RunService.Stepped:Connect(function()
         if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
               if part:IsA("BasePart") then part.CanCollide = false end
            end
         end
      end)
   end
end

-- ADVANCED ESP v3
local ESPhue = 0
local function toggleESP(enabled)
   States.esp = enabled
   if enabled then
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then
            -- Create ESP objects
            local esp = {
               box = Drawing.new("Square"), tracer = Drawing.new("Line"),
               name = Drawing.new("Text"), dist = Drawing.new("Text"), hp = Drawing.new("Text")
            }
            esp.box.Thickness = 2; esp.box.Filled = false
            esp.tracer.Thickness = 1
            esp.name.Size = 16; esp.name.Font = 2; esp.name.Outline = true
            esp.dist.Size = 14; esp.dist.Font = 2; esp.dist.Outline = true
            esp.hp.Size = 14; esp.hp.Font = 2; esp.hp.Outline = true
            ESPObjects[player] = esp
         end
      end
      Connections.ESP = RunService.RenderStepped:Connect(function()
         ESPhue = (ESPhue + 0.01) % 1
         local color = Color3.fromHSV(ESPhue, 1, 1)
         for player, esp in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local root = player.Character.HumanoidRootPart
               local hum = player.Character:FindFirstChild("Humanoid")
               local pos, onscreen = Camera:WorldToViewportPoint(root.Position)
               if onscreen and hum then
                  local size = 2000 / root.Position.Magnitude
                  local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                  
                  esp.box.Size = Vector2.new(size, size*2)
                  esp.box.Position = Vector2.new(pos.X-size/2, pos.Y-size)
                  esp.box.Color = color; esp.box.Visible = true
                  
                  esp.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                  esp.tracer.To = Vector2.new(pos.X, pos.Y); esp.tracer.Color = color; esp.tracer.Visible = true
                  
                  esp.name.Text = player.Name; esp.name.Position = Vector2.new(pos.X, pos.Y-size*1.2); esp.name.Color = color; esp.name.Visible = true
                  esp.dist.Text = math.floor(dist).."m"; esp.dist.Position = Vector2.new(pos.X, pos.Y-size); esp.dist.Color = color; esp.dist.Visible = true
                  esp.hp.Text = math.floor(hum.Health).."HP"; esp.hp.Position = Vector2.new(pos.X, pos.Y); esp.hp.Color = color; esp.hp.Visible = true
               else
                  for _, obj in pairs(esp) do obj.Visible = false end
               end
            end
         end
      end)
   else
      for _, esp in pairs(ESPObjects) do
         for _, obj in pairs(esp) do pcall(obj.Remove, obj) end
      end
      ESPObjects = {}
      if Connections.ESP then Connections.ESP:Disconnect() end
   end
end

-- FLING
local function flingAll()
   for i = 1, 15 do
      task.spawn(function()
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
               local root = player.Character:FindFirstChild("HumanoidRootPart")
               if root then
                  local bv = Instance.new("BodyVelocity", root)
                  bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                  bv.Velocity = Vector3.new(math.random(-100,100), 200, math.random(-100,100))
                  Services.Debris:AddItem(bv, 0.3)
               end
            end
         end
      end)
      task.wait(0.05)
   end
end

-- FPS BOOSTER
local function toggleFPSBoost(enabled)
   States.fpsboost = enabled
   if enabled then
      setfpscap(144)
      settings().Rendering.QualityLevel = "Level01"
      Services.Lighting.GlobalShadows = false
      Services.Lighting.FogEnd = 9e9
      for _, obj in pairs(Services.Lighting:GetChildren()) do
         if obj:IsA("PostEffect") then obj.Enabled = false end
      end
   else
      settings().Rendering.QualityLevel = "Automatic"
   end
end

-- BROOKHAVEN SCRIPTS (From GitHub)
local brookHavenScripts = {
   troll = [[-- Brookhaven Troll by Turcja
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function trollHouse()
   for _, house in pairs(workspace.Houses:GetChildren()) do
      if house:FindFirstChild("Owner") then
         local owner = Players:FindFirstChild(house.Owner.Value)
         if owner and owner ~= LocalPlayer then
            house.MainDoor.Transparency = 1
            house.MainDoor.CanCollide = false
         end
      end
   end
end

spawn(function() while wait(1) do trollHouse() end end)
]],
   
   housefly = [[-- Brookhaven House Fly
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

for i,v in pairs(workspace.Houses:GetChildren()) do
   if v:FindFirstChild("SpawnLocation") then
      player.Character.HumanoidRootPart.CFrame = v.SpawnLocation.CFrame + Vector3.new(0,50,0)
      break
   end
end]],
   
   speed = [[-- Brookhaven Speed
game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
game.Players.LocalPlayer.Character.Humanoid.JumpPower = 100
]]
}

-- TABS
local WelcomeTab = Window:CreateTab("🎉 Welcome", 4483362458)

WelcomeTab:CreateParagraph({Title = "ℹ️ Informacje", Content = "Exploit jest tylko dla gitów nie dla cfeli\n\nSkrypt wspiera gry takie jak:\n• Brookhaven\n• CaseParadise\n• Arsenal\n• Strongest Battlegrounds"})
WelcomeTab:CreateButton({Name = "📋 Copy Discord", Callback = function()
   setclipboard("turcja")
   notify("Discord", "Skopiowano: turcja", 2)
end})

-- Universal Tabs
local MainTab = Window:CreateTab("🎯 MAIN", 4483362458)
local MovementTab = Window:CreateTab("🚀 MOVEMENT", 4483362458)
local CombatTab = Window:CreateTab("⚔️ COMBAT", 4483362458)
local VisualsTab = Window:CreateTab("👁️ VISUALS", 4483362458)
local PlayersTab = Window:CreateTab("👥 PLAYERS", 4483362458)

if isBrookhaven then
   local BrookTab = Window:CreateTab("🏠 BROOKHAVEN", 4483362458)
   BrookTab:CreateButton({Name = "👹 Troll Houses", Callback = function() loadstring(brookHavenScripts.troll)() end})
   BrookTab:CreateButton({Name = "✈️ House Fly", Callback = function() loadstring(brookHavenScripts.housefly)() end})
   BrookTab:CreateButton({Name = "⚡ Max Speed", Callback = function() loadstring(brookHavenScripts.speed)() end})
end

-- MAIN TAB
MainTab:CreateToggle({Name = "🛡️ God Mode", CurrentValue = false, Callback = function(v)
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Humanoid") then
      char.Humanoid.MaxHealth = v and math.huge or 100
      char.Humanoid.Health = v and math.huge or 100
   end
end})

MainTab:CreateToggle({Name = "♾️ Infinite Jump", CurrentValue = false, Callback = function(v) Toggles.infjump = v end})
MainTab:CreateToggle({Name = "🐰 Bunny Hop", CurrentValue = false, Callback = function(v) States.bhop = v end})

-- MOVEMENT
MovementTab:CreateSlider({Name = "Walk Speed", Range = {16, 500}, Increment = 1, Suffix = " spd", CurrentValue = 16, Callback = function(v) States.walkspeed = v end})
MovementTab:CreateToggle({Name = "✈️ Fly", CurrentValue = false, Callback = toggleFly})
MovementTab:CreateSlider({Name = "Fly Speed", Range = {16, 300}, Increment = 5, Suffix = " spd", CurrentValue = 50, Callback = function(v) States.flyspeed = v end})
MovementTab:CreateToggle({Name = "👻 Noclip", CurrentValue = false, Callback = toggleNoclip})

-- COMBAT
CombatTab:CreateToggle({Name = "🌈 ESP (Advanced)", CurrentValue = false, Callback = toggleESP})
CombatTab:CreateToggle({Name = "💥 Fling Loop", CurrentValue = false, Callback = function(v)
   States.fling = v
   if v then
      Connections.FlingLoop = RunService.Heartbeat:Connect(flingAll)
   elseif Connections.FlingLoop then
      Connections.FlingLoop:Disconnect()
   end
end})
CombatTab:CreateButton({Name = "☄️ Fling All", Callback = flingAll})

-- VISUALS
VisualsTab:CreateSlider({Name = "FOV", Range = {30, 120}, Increment = 1, Suffix = "°", CurrentValue = 70, Callback = function(v) States.fov = v end})
VisualsTab:CreateToggle({Name = "💡 Fullbright", CurrentValue = false, Callback = function(v)
   Services.Lighting.Brightness = v and 5 or 2
   Services.Lighting.GlobalShadows = not v
end})
VisualsTab:CreateToggle({Name = "⚡ FPS Boost", CurrentValue = false, Callback = toggleFPSBoost})

-- PLAYERS (Dropdowns!)
PlayersTab:CreateDropdown({Name = "🎯 Teleport to Player", Options = getPlayerList(), CurrentOption = "None", MultipleOptions = false, Flag = "TPPlayer", Callback = function(playerName)
   local target = Players:FindFirstChild(playerName)
   if target and target.Character and LocalPlayer.Character then
      LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,3,0)
      notify("TP", "Teleported to " .. playerName, 2)
   end
end})

PlayersTab:CreateDropdown({Name = "👁️ Spectate Player", Options = getPlayerList(), CurrentOption = "None", MultipleOptions = false, Flag = "SpecPlayer", Callback = function(playerName)
   local target = Players:FindFirstChild(playerName)
   if target and target.Character then
      Camera.CameraSubject = target.Character.Humanoid
      notify("Spectate", "Spectating " .. playerName, 2)
   end
end})

PlayersTab:CreateButton({Name = "🔄 Refresh Players", Callback = function()
   Rayfield:LoadConfiguration()
   notify("Players", "Lista odświeżona!", 2)
end})

-- GLOBAL LOOP
spawn(function()
   while task.wait() do
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.WalkSpeed = States.walkspeed
         Camera.FieldOfView = States.fov
         
         if Toggles.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            char.Humanoid:ChangeState("Jumping")
         end
      end
   end
end)

-- F8 TP
UserInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.F8 then
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
      end
   end
end)

-- CLEANUP
Players.PlayerRemoving:Connect(function(player)
   if ESPObjects[player] then
      for _, obj in pairs(ESPObjects[player]) do
         pcall(function() obj:Remove() end)
      end
      ESPObjects[player] = nil
   end
end)

notify("Turcja Hub v1.0", "Powered by turcja\nGame: " .. gameInfo.Name, 6)
print("Powered by turcja")
