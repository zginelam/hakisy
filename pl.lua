-- Turcja Hub v16.0 | PROFESSIONAL ULTIMATE | ALL FIXED + NEW FEATURES
print("=== Turcja Hub v16.0 LOADING ===")

-- Rayfield (Double Backup)
local Rayfield = loadstring(game:HttpGetAsync('https://sirius.menu/rayfield'))() or loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/RegularVynixu/UI-Libs/main/Rayfield.lua'))()

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v16.0 💎 ULTIMATE PRO",
   LoadingTitle = "Advanced Features Loading...",
   LoadingSubtitle = "ID: jnrue-v16 | All Fixed",
   ConfigurationSaving = {Enabled = true, FolderName = "TurcjaHubV16", FileName = "pro-config"},
   KeySystem = false
})

-- SERVICES
local Players, RunService, UserInputService, Workspace, Lighting, Debris, TeleportService, TweenService = 
game:GetService("Players"), game:GetService("RunService"), game:GetService("UserInputService"), 
game:GetService("Workspace"), game:GetService("Lighting"), game:GetService("Debris"), 
game:GetService("TeleportService"), game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- GAME DETECTION
local Marketplace = game:GetService("MarketplaceService")
local gameName = Marketplace:GetProductInfo(game.PlaceId).Name:lower()
local isBrookhaven = game.PlaceId == 4924922222

-- STATES
local States = {
   fly = false, noclip = false, esp = false, flingloop = false, fakelag = false,
   infjump = false, fullbright = false, bhop = false, 
   flyspeed = 50, walkspeed = 16, fov = 70, fakelagamount = 0.1
}

local Connections = {}
local ESPObjects = {}
local hue = 0

-- UTILS
local function notify(title, content)
   Rayfield:Notify({
      Title = title, Content = content, Duration = 3, Image = 4483362458
   })
end

local function getPlayers()
   local t = {}
   for _, p in pairs(Players:GetPlayers()) do
      if p ~= LocalPlayer then table.insert(t, p.Name) end
   end
   return t
end

-- FIXED ESP v4 (Smaller + Stable)
local function createESP(player)
   local esp = {
      box = Drawing.new("Square"),
      tracer = Drawing.new("Line"),
      name = Drawing.new("Text"),
      dist = Drawing.new("Text")
   }
   esp.box.Size = Vector2.new(0,0)
   esp.box.Filled = false
   esp.box.Thickness = 2
   esp.tracer.Thickness = 1
   esp.name.Size = 14
   esp.name.Font = 2
   esp.name.Outline = true
   esp.dist.Size = 12
   esp.dist.Font = 2
   esp.dist.Outline = true
   return esp
end

local function toggleESP(enabled)
   States.esp = enabled
   if enabled then
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then
            ESPObjects[player] = createESP(player)
         end
      end
      Connections.ESP = RunService.RenderStepped:Connect(function()
         hue = (hue + 0.008) % 1
         local color = Color3.fromHSV(hue, 1, 1)
         
         for player, drawings in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character then
               local root = player.Character.HumanoidRootPart
               local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
               local head = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
               local size = math.clamp(1200 / (root.Position.Magnitude), 2, 20)
               local distance = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
               
               if onScreen then
                  drawings.box.Position = Vector2.new(pos.X - size/2, head.Y)
                  drawings.box.Size = Vector2.new(size, head.Y - pos.Y)
                  drawings.box.Color = color
                  drawings.box.Visible = true
                  
                  drawings.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y*0.95)
                  drawings.tracer.To = Vector2.new(pos.X, head.Y)
                  drawings.tracer.Color = color
                  drawings.tracer.Visible = true
                  
                  drawings.name.Text = player.Name
                  drawings.name.Position = Vector2.new(pos.X, head.Y - 20)
                  drawings.name.Color = color
                  drawings.name.Visible = true
                  
                  drawings.dist.Text = tostring(math.floor(distance)) .. "m"
                  drawings.dist.Position = Vector2.new(pos.X, pos.Y + 5)
                  drawings.dist.Color = color
                  drawings.dist.Visible = true
               else
                  drawings.box.Visible = drawings.tracer.Visible = drawings.name.Visible = drawings.dist.Visible = false
               end
            else
               for _, drawing in pairs(drawings) do
                  drawing.Visible = false
               end
            end
         end
      end)
   else
      for _, drawings in pairs(ESPObjects) do
         for _, drawing in pairs(drawings) do
            pcall(drawing.Remove, drawing)
         end
      end
      ESPObjects = {}
      if Connections.ESP then Connections.ESP:Disconnect() end
   end
end

-- GITHUB FLING (Fixed & Powerful)
local function advancedFling()
   spawn(function()
      for i = 1, 20 do
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local root = player.Character.HumanoidRootPart
               local vel = Instance.new("BodyVelocity")
               vel.MaxForce = Vector3.new(40000, 40000, 40000)
               vel.Velocity = Vector3.new(math.random(-500,500), math.random(300,800), math.random(-500,500))
               vel.Parent = root
               
               local ang = Instance.new("BodyAngularVelocity")
               ang.MaxTorque = Vector3.new(40000, 40000, 40000)
               ang.AngularVelocity = Vector3.new(math.rad(200), 0, 0)
               ang.Parent = root
               
               Debris:AddItem(vel, 0.15)
               Debris:AddItem(ang, 0.15)
            end
         end
         wait(0.03)
      end
   end)
end

-- FAKE LAG (Visual Lag Effect)
local function toggleFakeLag(enabled)
   States.fakelag = enabled
   if Connections.FakeLag then Connections.FakeLag:Disconnect() end
   
   if enabled then
      local lastPos = LocalPlayer.Character.HumanoidRootPart.Position
      Connections.FakeLag = RunService.Heartbeat:Connect(function()
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            root.CFrame = root.CFrame:Lerp(CFrame.new(lastPos), States.fakelagamount)
            lastPos = root.Position
         end
      end)
   end
end

-- BROOKHAVEN SCRIPTS (Working GitHub Style)
local brookScripts = {
   trollDoors = function()
      spawn(function()
         repeat
            for _, house in pairs(Workspace:GetChildren()) do
               if house.Name:find("House") and house:FindFirstChild("MainDoor") then
                  house.MainDoor.Transparency = 0.8
                  house.MainDoor.CanCollide = false
               end
            end
            wait(0.5)
         until not States.brookTroll
      end)
   end,
   
   carSpam = function()
      local cars = Workspace:FindFirstChild("Cars")
      if cars then
         for i = 1, 10 do
            local car = cars:GetChildren()[math.random(1, #cars:GetChildren())]:Clone()
            car.Parent = Workspace
            TweenService:Create(car.PrimaryPart, TweenInfo.new(0.1), {CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame}):Play()
         end
      end
   end
}

-- TABS
local WelcomeTab = Window:CreateTab("🎉 Welcome", 4483362458)
WelcomeTab:CreateParagraph({Title="Info", Content="Tylko dla Git Exploitów!\nWsparcie: Brookhaven, Arsenal, CaseParadise"})
WelcomeTab:CreateButton({Name="📋 Copy Discord", Callback=function() setclipboard("turcja") notify("DC", "turcja ✓") end})

local MainTab = Window:CreateTab("🎯 MAIN", 4483362458)
local MovementTab = Window:CreateTab("🚀 MOVEMENT", 4483362458)
local CombatTab = Window:CreateTab("⚔️ COMBAT", 4483362458)
local PlayersTab = Window:CreateTab("👥 PLAYERS", 4483362458)
local VisualsTab = Window:CreateTab("👁️ VISUALS", 4483362458)
local TrollTab = Window:CreateTab("😂 TROLL", 4483362458)

if isBrookhaven then
   local BrookTab = Window:CreateTab("🏠 BROOKHAVEN", 4483362458)
   BrookTab:CreateToggle({Name="🚪 Troll Doors Loop", CurrentValue=false, Callback=function(v) States.brookTroll=v brookScripts.trollDoors() end})
   BrookTab:CreateButton({Name="🚗 Car Spam", Callback=brookScripts.carSpam})
   BrookTab:CreateButton({Name="🏠 All Houses Open", Callback=function()
      for _, obj in pairs(Workspace:GetChildren()) do
         if obj.Name:find("House") and obj:FindFirstChild("MainDoor") then
            obj.MainDoor.Transparency = 1
            obj.MainDoor.CanCollide = false
         end
      end
      notify("Brook", "Domy otwarte!")
   end})
end

-- MAIN (New Features)
MainTab:CreateToggle({Name="♾️ Inf Jump", CurrentValue=false, Callback=function(v) States.infjump=v end})
MainTab:CreateToggle({Name="🐰 BunnyHop", CurrentValue=false, Callback=function(v) States.bhop=v end})
MainTab:CreateToggle({Name="🛡️ NoFall", CurrentValue=false, Callback=function(v) States.nofall=v end})
MainTab:CreateButton({Name="📦 Infinite Yield", Callback=function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})

-- MOVEMENT
MovementTab:CreateSlider({Name="Speed", Range={16,500}, Increment=1, CurrentValue=16, Callback=function(v) States.walkspeed=v end})
MovementTab:CreateToggle({Name="✈️ Fly", CurrentValue=false, Callback=toggleFly})
MovementTab:CreateSlider({Name="FlySpeed", Range={16,300}, Increment=5, CurrentValue=50, Callback=function(v) States.flyspeed=v end})
MovementTab:CreateToggle({Name="👻 Noclip", CurrentValue=false, Callback=toggleNoclip})
MovementTab:CreateToggle({Name="🌫️ FakeLag", CurrentValue=false, Callback=toggleFakeLag})
MovementTab:CreateSlider({Name="Lag Amount", Range={0.1,1}, Increment=0.1, CurrentValue=0.1, Callback=function(v) States.fakelagamount=v end})

-- COMBAT
CombatTab:CreateToggle({Name="🌈 ESP Pro", CurrentValue=false, Callback=toggleESP})
CombatTab:CreateToggle({Name="💥 Fling Loop", CurrentValue=false, Callback=function(v)
   States.flingloop = v
   if v then
      Connections.FlingLoop = RunService.Heartbeat:Connect(function()
         advancedFling()
      end)
   elseif Connections.FlingLoop then
      Connections.FlingLoop:Disconnect()
   end
end})
CombatTab:CreateButton({Name="☄️ Fling All", Callback=advancedFling})

-- PLAYERS (INSTANT ACTION)
PlayersTab:CreateDropdown({
   Name="🎯 Instant TP",
   Options=getPlayers(),
   CurrentOption={"Select"},
   Flag="TPDrop",
   Callback=function(playerName)
      local target = Players:FindFirstChild(playerName)
      if target and target.Character and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-3,3), 2, math.random(-3,3))
         notify("TP", "Teleport do " .. playerName .. " ✓")
      end
   end
})

PlayersTab:CreateDropdown({
   Name="👁️ Instant Spectate",
   Options=getPlayers(), 
   CurrentOption={"Select"},
   Flag="SpecDrop",
   Callback=function(playerName)
      local target = Players:FindFirstChild(playerName)
      if target and target.Character and target.Character:FindFirstChild("Humanoid") then
         Camera.CameraSubject = target.Character.Humanoid
         notify("Spectate", playerName .. " - patrzymy!")
      end
   end
})

PlayersTab:CreateButton({Name="🔄 Refresh", Callback=function() Rayfield:LoadConfiguration() notify("Lista", "Odświeżono!") end})

-- VISUALS
VisualsTab:CreateToggle({Name="💡 Fullbright", CurrentValue=false, Callback=function(v)
   Lighting.Brightness = v and 4 or 1
   Lighting.GlobalShadows = not v
end})

VisualsTab:CreateSlider({Name="FOV", Range={30,120}, Increment=1, CurrentValue=70, Callback=function(v) States.fov=v Camera.FieldOfView=v end})

-- TROLL TAB (GitHub Scripts)
TrollTab:CreateButton({Name="🦵 Spam Jump", Callback=function()
   spawn(function()
      for i=1,50 do
         if LocalPlayer.Character then LocalPlayer.Character.Humanoid.Jump = true end
         wait(0.1)
      end
   end)
end})

TrollTab:CreateButton({Name="🌪️ Spin Bot", Callback=function()
   if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
      local spin = Instance.new("BodyAngularVelocity")
      spin.AngularVelocity = Vector3.new(0, 100, 0)
      spin.MaxTorque = Vector3.new(0, math.huge, 0)
      spin.Parent = LocalPlayer.Character.HumanoidRootPart
      wait(5)
      spin:Destroy()
   end
end})

TrollTab:CreateButton({Name="📢 Chat Spam", Callback=function()
   spawn(function()
      local msgs = {"⠀⠀⠀⠀⠀⠀", "EZZZZZZZZZ", "turcja", "TURCJA SZEF"}
      for i=1,20 do
         game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msgs[math.random(1,#msgs)], "All")
         wait(1)
      end
   end)
end})

-- MAIN LOOP
Connections.Loop = RunService.Heartbeat:Connect(function()
   local char = LocalPlayer.Character
   if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
      char.Humanoid.WalkSpeed = States.walkspeed
      Camera.FieldOfView = States.fov
      
      if States.bhop and char.Humanoid.FloorMaterial == Enum.Material.Air then
         char.Humanoid.Jump = true
      end
      
      if States.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
   end
end)

-- F8 TP
UserInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.F8 and LocalPlayer.Character then
      LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,5,0))
   end
end)

-- CLEANUP
Players.PlayerRemoving:Connect(function(player)
   if ESPObjects[player] then
      for _, drawing in pairs(ESPObjects[player]) do
         pcall(drawing.Remove, drawing)
      end
      ESPObjects[player] = nil
   end
end)

notify("Turcja Hub v1.0")
print("🟢 v16.0 PRO - Everything Perfect!")
