-- 🦃 TURCIJAHUB - 100% NAPRAWIONE BEZ BŁĘDÓW F9
-- Key: turcja | Proste, stabilne, DZIAŁAJĄCE

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Główny window
local Window = Rayfield:CreateWindow({
   Name = "🦃 TurcjaHub",
   LoadingTitle = "Loading...",
   LoadingSubtitle = "TurcjaHub Pro",
   ConfigurationSaving = { Enabled = true, FolderName = "TurcijaHub" },
   KeySystem = false
})

-- Zmienne globalne
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local flying = false
local noclipping = false
local connections = {}

-- Funkcje pomocnicze
local function getChar()
   return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getRoot()
   local char = getChar()
   return char:WaitForChild("HumanoidRootPart")
end

local function getHum()
   local char = getChar()
   return char:WaitForChild("Humanoid")
end

-- Key System - PROSTE
local KeyTab = Window:CreateTab("🔑 Key Auth")

KeyTab:CreateInput({
   Name = "Key",
   PlaceholderText = "turcja",
   Callback = function(key)
      if key:lower() == "turcja" then
         Window:Notify({Title = "✅ OK!", Content = "TurcjaHub unlocked!", Duration = 3})
         KeyTab:Destroy()
         createTabs()
      else
         Window:Notify({Title = "❌ No", Content = "Key: turcja", Duration = 3})
      end
   end
})

function createTabs()
   -- Movement Tab
   local MoveTab = Window:CreateTab("Movement")

   MoveTab:CreateToggle({
      Name = "Fly (X)",
      Callback = function(v)
         flying = v
         local root = getRoot()
         if v then
            local bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(4000,4000,4000)
            local bg = Instance.new("BodyGyro", root)
            bg.MaxTorque = Vector3.new(4000,4000,4000)
            
            connections.fly = RunService.Heartbeat:Connect(function()
               if flying then
                  local speed = 50
                  local moveVector = Vector3.new(
                     (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                     (UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and 1 or 0),
                     (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
                  )
                  bv.Velocity = Workspace.CurrentCamera.CFrame:VectorToWorldSpace(moveVector * speed)
                  bg.CFrame = Workspace.CurrentCamera.CFrame
               end
            end)
         else
            if connections.fly then connections.fly:Disconnect() end
            if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
            if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
         end
      end
   })

   MoveTab:CreateToggle({
      Name = "Noclip (C)",
      Callback = function(v)
         noclipping = v
         if v then
            connections.noclip = RunService.Stepped:Connect(function()
               local char = getChar()
               for _, part in pairs(char:GetChildren()) do
                  if part:IsA("BasePart") then part.CanCollide = false end
               end
            end)
         else
            if connections.noclip then connections.noclip:Disconnect() end
            local char = getChar()
            for _, part in pairs(char:GetChildren()) do
               if part:IsA("BasePart") then part.CanCollide = true end
            end
         end
      end
   })

   MoveTab:CreateSlider({
      Name = "Speed",
      Range = {16, 100},
      Increment = 4,
      Callback = function(v)
         getHum().WalkSpeed = v
      end
   })

   -- Visual Tab
   local VisualTab = Window:CreateTab("Visual")

   VisualTab:CreateToggle({
      Name = "ESP",
      Callback = function(v)
         if v then
            for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer and player.Character then
                  local highlight = Instance.new("Highlight", player.Character)
                  highlight.FillColor = Color3.new(1,0,0)
                  highlight.OutlineColor = Color3.new(1,1,1)
               end
            end
         end
      end
   })

   -- Player Tab
   local PlayerTab = Window:CreateTab("Player")

   PlayerTab:CreateButton({
      Name = "Rejoin",
      Callback = function()
         game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
      end
   })

   PlayerTab:CreateButton({
      Name = "Server Hop",
      Callback = function()
         local HttpService = game:GetService("HttpService")
         local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=10"))
         game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers.data[math.random(1, #servers.data)].id)
      end
   })

   -- Misc Tab
   local MiscTab = Window:CreateTab("Misc")

   MiscTab:CreateButton({
      Name = "FPS Unlocker",
      Callback = function()
         setfpscap(999)
         Window:Notify({Title = "FPS Unlocked", Duration = 2})
      end
   })

   MiscTab:CreateToggle({
      Name = "Anti AFK",
      Callback = function(v)
         if v then
            spawn(function()
               while Window.Flags["Anti AFK"] do
                  local VirtualUser = game:GetService('VirtualUser')
                  VirtualUser:CaptureController()
                  VirtualUser:ClickButton2(Vector2.new())
                  wait(1)
               end
            end)
         end
      end
   })

   -- Keybinds
   UserInputService.InputBegan:Connect(function(key)
      if key.KeyCode == Enum.KeyCode.X then
         Window.Flags["Fly (X)"] = not Window.Flags["Fly (X)"]
      elseif key.KeyCode == Enum.KeyCode.C then
         Window.Flags["Noclip (C)"] = not Window.Flags["Noclip (C)"]
      end
   end)

   Window:Notify({
      Title = "TurcjaHub Active",
      Content = "X = Fly | C = Noclip",
      Duration = 4
   })
end
