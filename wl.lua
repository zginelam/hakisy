-- Turcja Hub v15.1 | FIXED GUI | ULTIMATE PENTEST EDITION
print("=== Turcja Hub v15.1 GUI FIXED INITIALIZING ===")

-- CRITICAL: Fixed Rayfield loading + error handling
local success, Rayfield = pcall(function()
   return loadstring(game:HttpGetAsync('https://sirius.menu/rayfield'))()
end)

if not success then
   -- Backup Rayfield
   success, Rayfield = pcall(function()
      return loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/RegularVynixu/UI-Libs/main/Rayfield.lua'))()
   end)
end

if not success or not Rayfield then
   game:GetService("StarterGui"):SetCore("SendNotification", {
      Title = "Turcja Hub ERROR";
      Text = "Rayfield failed to load! Try again.";
      Duration = 5;
   })
   return
end

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v15.1 💎 ULTIMATE",
   LoadingTitle = "GUI Fixed - Loading...",
   LoadingSubtitle = "ID: jnrue-v15.1 | 100% Working",
   ConfigurationSaving = {Enabled = true, FolderName = "TurcjaHubV15", FileName = "fixed-config"},
   KeySystem = false
})

print("✅ Rayfield LOADED SUCCESSFULLY")

-- SAFE SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- GAME DETECTION
local MarketplaceService = game:GetService("MarketplaceService")
local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local isBrookhaven = game.PlaceId == 4924922222
print("🎮 Game: " .. gameInfo.Name .. " | Brookhaven: " .. tostring(isBrookhaven))

-- STATES
local States = {
   fly = false, noclip = false, esp = false, fling = false, 
   fpsboost = false, godmode = false, infjump = false, 
   fullbright = false, bhop = false, flyspeed = 50, 
   walkspeed = 16, fov = 70
}

local Connections = {}
local ESPObjects = {}
local PlayerList = {}

-- UPDATE PLAYER LIST
local function updatePlayerList()
   PlayerList = {}
   for _, player in pairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
         table.insert(PlayerList, player.Name)
      end
   end
end

updatePlayerList()

-- NOTIFY FUNCTION
local function notify(title, text)
   Rayfield:Notify({
      Title = title,
      Content = text,
      Duration = 3,
      Image = 4483362458
   })
end

-- FLY SCRIPT
local function toggleFly(value)
   States.fly = value
   if Connections.Fly then Connections.Fly:Disconnect() end
   
   if value then
      Connections.Fly = RunService.Heartbeat:Connect(function()
         local char = LocalPlayer.Character
         if char and char:FindFirstChild("HumanoidRootPart") then
            local HRP = char.HumanoidRootPart
            local moveVector = Vector3.new()
            local cam = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector + Vector3.new(0, -1, 0) end
            
            HRP.Velocity = moveVector.Unit * States.flyspeed
         end
      end)
   end
end

-- NOCLIP
local function toggleNoclip(value)
   States.noclip = value
   if Connections.Noclip then Connections.Noclip:Disconnect() end
   if value then
      Connections.Noclip = RunService.Stepped:Connect(function()
         if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end
      end)
   end
end

-- ESP
local ESPhue = 0
local function toggleESP(value)
   States.esp = value
   if value then
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character then
            local esp = {
               box = Drawing.new("Square"),
               line = Drawing.new("Line"),
               text = Drawing.new("Text")
            }
            esp.box.Filled = false
            esp.box.Thickness = 2
            esp.line.Thickness = 1
            esp.text.Size = 16
            esp.text.Font = 2
            esp.text.Outline = true
            ESPObjects[player] = esp
         end
      end
      
      Connections.ESP = RunService.RenderStepped:Connect(function()
         ESPhue = ESPhue + 0.01
         local color = Color3.fromHSV(ESPhue % 1, 1, 1)
         
         for player, esp in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
               local root = player.Character.HumanoidRootPart
               local pos, visible = Camera:WorldToViewportPoint(root.Position)
               local size = 1000 / root.Position.Magnitude
               
               if visible then
                  esp.box.Size = Vector2.new(size, size * 2)
                  esp.box.Position = Vector2.new(pos.X - size / 2, pos.Y - size)
                  esp.box.Color = color
                  esp.box.Visible = true
                  
                  esp.line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                  esp.line.To = Vector2.new(pos.X, pos.Y)
                  esp.line.Color = color
                  esp.line.Visible = true
                  
                  local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                  esp.text.Text = player.Name .. "\n" .. math.floor(dist) .. "m"
                  esp.text.Position = Vector2.new(pos.X, pos.Y - size / 2)
                  esp.text.Color = color
                  esp.text.Visible = true
               else
                  esp.box.Visible = false
                  esp.line.Visible = false
                  esp.text.Visible = false
               end
            end
         end
      end)
   else
      for player, esp in pairs(ESPObjects) do
         esp.box:Remove()
         esp.line:Remove()
         esp.text:Remove()
      end
      ESPObjects = {}
      if Connections.ESP then Connections.ESP:Disconnect() end
   end
end

-- FLING ALL
local function flingAll()
   for i = 1, 10 do
      spawn(function()
         for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
               local root = player.Character:FindFirstChild("HumanoidRootPart")
               if root then
                  local bv = Instance.new("BodyVelocity")
                  bv.MaxForce = Vector3.new(4000, 4000, 4000)
                  bv.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
                  bv.Parent = root
                  game:GetService("Debris"):AddItem(bv, 0.2)
               end
            end
         end
      end)
      wait(0.05)
   end
end

-- TABS - FIXED CREATION
local WelcomeTab = Window:CreateTab("🎉 Welcome", 4483362458)

WelcomeTab:CreateParagraph({Title = "ℹ️ Informacja", Content = "Exploit jest tylko dla gitów nie dla cfeli\n\nWspierane gry:\n• Brookhaven\n• CaseParadise\n• Arsenal"})

WelcomeTab:CreateButton({
   Name = "📋 Copy Discord",
   Callback = function()
      setclipboard("turcja")
      notify("Discord", "turcja - skopiowano!")
   end
})

local MainTab = Window:CreateTab("🎯 MAIN", 4483362458)
local MovementTab = Window:CreateTab("🚀 MOVEMENT", 4483362458)
local CombatTab = Window:CreateTab("⚔️ COMBAT", 4483362458)
local PlayersTab = Window:CreateTab("👥 PLAYERS", 4483362458)
local VisualsTab = Window:CreateTab("👁️ VISUALS", 4483362458)

-- BROOKHAVEN TAB (only if in game)
if isBrookhaven then
   local BrookTab = Window:CreateTab("🏠 BROOKHAVEN", 4483362458)
   
   BrookTab:CreateButton({
      Name = "🚪 Troll Doors",
      Callback = function()
         for _, house in pairs(Workspace:FindFirstChild("Houses"):GetChildren()) do
            if house:FindFirstChild("MainDoor") then
               house.MainDoor.Transparency = 1
               house.MainDoor.CanCollide = false
            end
         end
         notify("Brookhaven", "Wszystkie drzwi otwarte!")
      end
   })
   
   BrookTab:CreateButton({
      Name = "✈️ Fly to Houses",
      Callback = function()
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = Workspace.Houses:GetChildren()[1].SpawnLocation.CFrame + Vector3.new(0, 20, 0)
         end
      end
   })
end

-- MAIN TAB
MainTab:CreateToggle({
   Name = "🛡️ Godmode",
   CurrentValue = false,
   Callback = function(value)
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.MaxHealth = value and math.huge or 100
         char.Humanoid.Health = value and math.huge or 100
      end
   end
})

MainTab:CreateToggle({
   Name = "♾️ Infinite Jump", 
   CurrentValue = false,
   Callback = function(value) States.infjump = value end
})

-- MOVEMENT TAB
MovementTab:CreateSlider({
   Name = "Walkspeed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(value)
      States.walkspeed = value
   end
})

MovementTab:CreateToggle({
   Name = "✈️ Fly",
   CurrentValue = false,
   Callback = toggleFly
})

MovementTab:CreateSlider({
   Name = "Fly Speed",
   Range = {16, 200},
   Increment = 5,
   CurrentValue = 50,
   Callback = function(value)
      States.flyspeed = value
   end
})

MovementTab:CreateToggle({
   Name = "👻 Noclip",
   CurrentValue = false,
   Callback = toggleNoclip
})

-- COMBAT TAB
CombatTab:CreateToggle({
   Name = "🌈 ESP",
   CurrentValue = false,
   Callback = toggleESP
})

CombatTab:CreateButton({
   Name = "💥 Fling All",
   Callback = flingAll
})

-- PLAYERS TAB - DROPDOWN FIXED
PlayersTab:CreateDropdown({
   Name = "🎯 TP Player",
   Options = PlayerList,
   CurrentOption = {"None"},
   Flag = "TPDropdown",
   Callback = function(playerName)
      local target = Players:FindFirstChild(playerName)
      if target and target.Character and LocalPlayer.Character then
         LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0)
         notify("Teleport", "TP do " .. playerName)
      end
   end
})

PlayersTab:CreateDropdown({
   Name = "👁️ Spectate",
   Options = PlayerList,
   CurrentOption = {"None"},
   Flag = "SpecDropdown", 
   Callback = function(playerName)
      local target = Players:FindFirstChild(playerName)
      if target and target.Character then
         Camera.CameraSubject = target.Character.Humanoid
         notify("Spectate", playerName .. " - kamera")
      end
   end
})

PlayersTab:CreateButton({
   Name = "🔄 Refresh List",
   Callback = function()
      updatePlayerList()
      notify("Lista", "Gracze odświeżeni!")
   end
})

-- VISUALS
VisualsTab:CreateToggle({
   Name = "💡 Fullbright",
   CurrentValue = false,
   Callback = function(value)
      Lighting.Brightness = value and 3 or 1
      Lighting.GlobalShadows = not value
   end
})

-- MAIN LOOP
spawn(function()
   while wait() do
      local char = LocalPlayer.Character
      if char and char:FindFirstChild("Humanoid") then
         char.Humanoid.WalkSpeed = States.walkspeed
      end
      
      if States.infjump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
         char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
      end
   end
end)

-- F8 TELEPORT
UserInputService.InputBegan:Connect(function(key)
   if key.KeyCode == Enum.KeyCode.F8 then
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
         LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 5, 0))
      end
   end
end)

notify("Turcja Hub v15.1", "GUI FIXED - Wszystko działa!")
print("🟢 v15.1 LOADED - GUI 100% WORKING")
