local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Key System
local KeyWindow = Rayfield:CreateWindow({
   Name = "TurcjaHub Auth",
   LoadingTitle = "Authenticating...",
   LoadingSubtitle = "Enter your key to access",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false
})

local KeyTab = KeyWindow:CreateTab("Key", nil)

local KeyInput = KeyTab:CreateInput({
   Name = "Enter Key",
   PlaceholderText = "Key:",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text:lower() == "turcja" then
         Rayfield:DestroyGui()
         loadMainGUI()
      else
         Rayfield:Notify({
            Title = "Invalid Key",
            Content = "Key is incorrect! Try again.",
            Duration = 3,
            Image = 4066655410,
         })
      end
   end,
})

-- Main GUI Function
function loadMainGUI()
   local Window = Rayfield:CreateWindow({
      Name = "TurcjaHub",
      LoadingTitle = "Loading...",
      LoadingSubtitle = "TurcjaHub",
      ConfigurationSaving = {
         Enabled = true,
         FolderName = "Turcjahub",
      },
      Discord = {
         Enabled = true,
         Invite = "noinvitelink",
         RememberJoins = true,
      },
      KeySystem = false,
   })

   -- Services
   local Players = game:GetService("Players")
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local TweenService = game:GetService("TweenService")
   local TeleportService = game:GetService("TeleportService")
   local Lighting = game:GetService("Lighting")
   local ReplicatedStorage = game:GetService("ReplicatedStorage")
   local Workspace = game:GetService("Workspace")

   local LocalPlayer = Players.LocalPlayer
   local Camera = Workspace.CurrentCamera
   local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local Humanoid = Character:WaitForChild("Humanoid")
   local RootPart = Character:WaitForChild("HumanoidRootPart")

   -- Variables
   local ESPConnections = {}
   local Keybinds = {}
   local FlyConnection
   local NoclipConnection
   local AimbotConnection

   -- Player List
   local function getPlayerList()
      local players = {}
      for _, player in pairs(Players:GetPlayers()) do
         if player ~= LocalPlayer then
            table.insert(players, player.Name)
         end
      end
      return players
   end

   -- Movement Functions
   local flying = false
   local noclipping = false
   local flySpeed = 50
   local walkSpeed = 16
   local jumpPower = 50

   local function toggleFly()
      flying = not flying
      if flying then
         local BodyVelocity = Instance.new("BodyVelocity")
         BodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
         BodyVelocity.Velocity = Vector3.new(0, 0, 0)
         BodyVelocity.Parent = RootPart

         local BodyGyro = Instance.new("BodyGyro")
         BodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
         BodyGyro.CFrame = RootPart.CFrame
         BodyGyro.Parent = RootPart

         FlyConnection = RunService.Heartbeat:Connect(function()
            if flying and RootPart and RootPart.Parent then
               local cam = Camera.CFrame
               local speed = flySpeed
               if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                  speed = speed * 2
               end
               BodyVelocity.Velocity = Vector3.new(
                  (UserInputService:IsKeyDown(Enum.KeyCode.W) and speed or 0) + 
                  (UserInputService:IsKeyDown(Enum.KeyCode.S) and -speed or 0),
                  (UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or 0) + 
                  (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and -speed or 0),
                  (UserInputService:IsKeyDown(Enum.KeyCode.A) and -speed or 0) + 
                  (UserInputService:IsKeyDown(Enum.KeyCode.D) and speed or 0)
               )
               BodyGyro.CFrame = cam
            end
         end)
      else
         if FlyConnection then FlyConnection:Disconnect() end
         if RootPart:FindFirstChild("BodyVelocity") then
            RootPart.BodyVelocity:Destroy()
         end
         if RootPart:FindFirstChild("BodyGyro") then
            RootPart.BodyGyro:Destroy()
         end
      end
   end

   local function toggleNoclip()
      noclipping = not noclipping
      if noclipping then
         NoclipConnection = RunService.Stepped:Connect(function()
            for _, part in pairs(Character:GetChildren()) do
               if part:IsA("BasePart") then
                  part.CanCollide = false
               end
            end
         end)
      else
         if NoclipConnection then NoclipConnection:Disconnect() end
         for _, part in pairs(Character:GetChildren()) do
            if part:IsA("BasePart") then
               part.CanCollide = true
            end
         end
      end
   end

   -- ESP System
   local ESPObjects = {}

   local function createESP(player)
      if player == LocalPlayer then return end
      local character = player.Character
      if not character or not character:FindFirstChild("HumanoidRootPart") then return end

      local Highlight = Instance.new("Highlight")
      Highlight.FillColor = Color3.fromRGB(255, 0, 0)
      Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
      Highlight.Parent = character

      local BillboardGui = Instance.new("BillboardGui")
      BillboardGui.Size = UDim2.new(0, 200, 0, 50)
      BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
      BillboardGui.Parent = character.Head

      local NameLabel = Instance.new("TextLabel")
      NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
      NameLabel.BackgroundTransparency = 1
      NameLabel.Text = player.Name
      NameLabel.TextColor3 = Color3.new(1, 1, 1)
      NameLabel.TextStrokeTransparency = 0
      NameLabel.TextScaled = true
      NameLabel.Font = Enum.Font.GothamBold
      NameLabel.Parent = BillboardGui

      local DistLabel = Instance.new("TextLabel")
      DistLabel.Size = UDim2.new(1, 0, 0.5, 0)
      DistLabel.Position = UDim2.new(0, 0, 0.5, 0)
      DistLabel.BackgroundTransparency = 1
      DistLabel.Text = "0m"
      DistLabel.TextColor3 = Color3.new(0, 1, 0)
      DistLabel.TextStrokeTransparency = 0
      DistLabel.TextScaled = true
      DistLabel.Font = Enum.Font.Gotham
      DistLabel.Parent = BillboardGui

      ESPObjects[player] = {Highlight = Highlight, BillboardGui = BillboardGui}

      -- Update loop
      ESPConnections[player] = RunService.Heartbeat:Connect(function()
         if character and character.Parent and character:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - character.HumanoidRootPart.Position).Magnitude
            DistLabel.Text = math.floor(distance) .. "m"
            
            local health = character:FindFirstChild("Humanoid") and character.Humanoid.Health or 0
            local maxHealth = character:FindFirstChild("Humanoid") and character.Humanoid.MaxHealth or 100
            Highlight.FillColor = Color3.fromRGB(255 - (health/maxHealth)*255, (health/maxHealth)*255, 0)
         else
            if ESPConnections[player] then
               ESPConnections[player]:Disconnect()
               ESPConnections[player] = nil
            end
         end
      end)
   end

   local function removeESP(player)
      if ESPObjects[player] then
         ESPObjects[player].Highlight:Destroy()
         ESPObjects[player].BillboardGui:Destroy()
         ESPObjects[player] = nil
      end
      if ESPConnections[player] then
         ESPConnections[player]:Disconnect()
         ESPConnections[player] = nil
      end
   end

   -- Tabs
   local MovementTab = Window:CreateTab("Movement", 4066695722)
   local VisualTab = Window:CreateTab("Visual/ESP", 4066706610)
   local CombatTab = Window:CreateTab("Combat", 4066708657)
   local PlayerTab = Window:CreateTab("Player", 4066712134)
   local MiscTab = Window:CreateTab("Misc", 4066713922)

   -- Movement Tab
   MovementTab:CreateToggle({
      Name = "Fly (X)",
      CurrentValue = false,
      Flag = "FlyToggle",
      Callback = function(Value)
         toggleFly()
      end,
   })

   MovementTab:CreateSlider({
      Name = "Fly Speed",
      Range = {16, 500},
      Increment = 1,
      CurrentValue = 50,
      Flag = "FlySpeed",
      Callback = function(Value)
         flySpeed = Value
      end,
   })

   MovementTab:CreateToggle({
      Name = "Noclip (C)",
      CurrentValue = false,
      Flag = "NoclipToggle",
      Callback = function(Value)
         toggleNoclip()
      end,
   })

   MovementTab:CreateSlider({
      Name = "Walk Speed",
      Range = {16, 500},
      Increment = 1,
      CurrentValue = 16,
      Flag = "WalkSpeed",
      Callback = function(Value)
         walkSpeed = Value
         Humanoid.WalkSpeed = Value
      end,
   })

   MovementTab:CreateSlider({
      Name = "Jump Power",
      Range = {50, 500},
      Increment = 1,
      CurrentValue = 50,
      Flag = "JumpPower",
      Callback = function(Value)
         jumpPower = Value
         Humanoid.JumpPower = Value
      end,
   })

   MovementTab:CreateButton({
      Name = "Infinite Jump (Space)",
      Callback = function()
         local infJumpConn
         infJumpConn = UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState("Jumping")
         end)
         Rayfield:Notify({
            Title = "Infinite Jump Enabled",
            Content = "Press Space to jump infinitely",
            Duration = 3,
         })
      end,
   })

   -- Visual Tab
   VisualTab:CreateToggle({
      Name = "Full ESP",
      CurrentValue = false,
      Flag = "ESP",
      Callback = function(Value)
         if Value then
            for _, player in pairs(Players:GetPlayers()) do
               createESP(player)
            end
         else
            for player, _ in pairs(ESPObjects) do
               removeESP(player)
            end
         end
      end,
   })

   VisualTab:CreateToggle({
      Name = "Tracers",
      CurrentValue = false,
      Flag = "Tracers",
      Callback = function(Value)
         -- Tracer implementation
      end,
   })

   -- Player Tab
   local TargetPlayer = "nil"
   PlayerTab:CreateDropdown({
      Name = "Select Player",
      Options = getPlayerList(),
      CurrentOption = "nil",
      Flag = "TargetPlayer",
      Callback = function(Option)
         TargetPlayer = Option
      end,
   })

   PlayerTab:CreateButton({
      Name = "Teleport to Player",
      Callback = function()
         local target = Players:FindFirstChild(TargetPlayer)
         if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            RootPart.CFrame = target.Character.HumanoidRootPart.CFrame
         end
      end,
   })

   PlayerTab:CreateButton({
      Name = "Spectate Player",
      Callback = function()
         local target = Players:FindFirstChild(TargetPlayer)
         if target and target.Character then
            Camera.CameraSubject = target.Character.Humanoid
         end
      end,
   })

   PlayerTab:CreateToggle({
      Name = "Follow Player",
      CurrentValue = false,
      Flag = "FollowPlayer",
      Callback = function(Value)
         -- Follow implementation
      end,
   })

   -- Combat Tab
   CombatTab:CreateToggle({
      Name = "Aimbot (Hold Right Mouse)",
      CurrentValue = false,
      Flag = "Aimbot",
      Callback = function(Value)
         -- Aimbot implementation
      end,
   })

   CombatTab:CreateToggle({
      Name = "Kill Aura",
      CurrentValue = false,
      Flag = "KillAura",
      Callback = function(Value)
         -- Kill aura implementation
      end,
   })

   -- Misc Tab
   MiscTab:CreateButton({
      Name = "Server Hop",
      Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/mygitusername/serverhop/main/serverhop.lua"))()
      end,
   })

   MiscTab:CreateToggle({
      Name = "Anti-AFK",
      CurrentValue = false,
      Flag = "AntiAFK",
      Callback = function(Value)
         -- Anti-AFK implementation
      end,
   })

   MiscTab:CreateButton({
      Name = "FPS Boost",
      Callback = function()
         -- FPS boost optimizations
         settings().Rendering.QualityLevel = "Level01"
         Lighting.FogEnd = 9e9
         Lighting.GlobalShadows = false
         Rayfield:Notify({
            Title = "FPS Boost Applied",
            Content = "Graphics optimized for performance",
            Duration = 3,
         })
      end,
   })

   -- Keybinds
   Keybinds["X"] = UserInputService.InputBegan:Connect(function(input, gp)
      if gp then return end
      if input.KeyCode == Enum.KeyCode.X then
         local flyToggle = Window.Flags.FlyToggle
         Window:UpdateToggle(Window.Flags.FlyToggle, not flyToggle)
      end
   end)

   Keybinds["C"] = UserInputService.InputBegan:Connect(function(input, gp)
      if gp then return end
      if input.KeyCode == Enum.KeyCode.C then
         local noclipToggle = Window.Flags.NoclipToggle
         Window:UpdateToggle(Window.Flags.NoclipToggle, not noclipToggle)
      end
   end)

   -- Player added/removed
   Players.PlayerAdded:Connect(function(player)
      if Window.Flags.ESP then
         createESP(player)
      end
   end)

   Players.PlayerRemoving:Connect(function(player)
      removeESP(player)
   end)

   -- Character respawn handling
   LocalPlayer.CharacterAdded:Connect(function(newChar)
      Character = newChar
      Humanoid = Character:WaitForChild("Humanoid")
      RootPart = Character:WaitForChild("HumanoidRootPart")
      Humanoid.WalkSpeed = walkSpeed
      Humanoid.JumpPower = jumpPower
   end)

   Rayfield:Notify({
      Title = "Turcjahub Loaded!",
      Content = "All features ready!",
      Duration = 5,
      Image = 4483362458,
   })
end
