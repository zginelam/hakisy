-- 🦃 TurcjaHub Pro - NAPRAWIONY & PROFESJONALNY
-- Key: turcja | Pełne GUI bez błędów F9

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🦃 TurcjaHub v2.0",
   LoadingTitle = "TurcjaHub Pro",
   LoadingSubtitle = "Advanced Features",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "TurcjaHub",
   },
   KeySystem = false
})

-- Key System (wbudowany w główne GUI)
local KeyTab = Window:CreateTab("🔑 Key", 4483362458)
local Authenticated = false

KeyTab:CreateInput({
   Name = "Enter Key",
   PlaceholderText = "turcja",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      if Text:lower() == "turcja" then
         Authenticated = true
         Window:Notify({
            Title = "✅ Autentykacja udana!",
            Content = "Witaj w TurcjaHub Pro!",
            Duration = 4,
         })
         KeyTab:Destroy()
         loadMainTabs()
      else
         Window:Notify({
            Title = "❌ Błędny klucz!",
            Content = "Użyj: turcja",
            Duration = 3,
         })
      end
   end,
})

function loadMainTabs()
   -- Services
   local Players = game:GetService("Players")
   local RunService = game:GetService("RunService")
   local UserInputService = game:GetService("UserInputService")
   local Lighting = game:GetService("Lighting")
   local Workspace = game:GetService("Workspace")
   
   local LocalPlayer = Players.LocalPlayer
   local Camera = Workspace.CurrentCamera
   local flying = false
   local noclip = false
   local espObjects = {}
   local connections = {}

   local function getCharacter()
      return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   end

   local function getRootPart()
      local char = getCharacter()
      return char:WaitForChild("HumanoidRootPart")
   end

   -- MOVEMENT TAB
   local MovementTab = Window:CreateTab("🏃 Movement", 4066695722)
   
   MovementTab:CreateToggle({
      Name = "Fly [X]",
      CurrentValue = false,
      Flag = "Fly",
      Callback = function(state)
         flying = state
         local root = getRootPart()
         if state then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = root
            
            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.Parent = root
            
            connections.fly = RunService.Heartbeat:Connect(function()
               if flying and root.Parent then
                  local speed = Window.Flags.FlySpeed or 50
                  local cam = Camera.CFrame
                  local move = Vector3.new(
                     (UserInputService:IsKeyDown(Enum.KeyCode.D) and speed or 0) - 
                     (UserInputService:IsKeyDown(Enum.KeyCode.A) and speed or 0),
                     (UserInputService:IsKeyDown(Enum.KeyCode.Space) and speed or 0) - 
                     (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and speed or 0),
                     (UserInputService:IsKeyDown(Enum.KeyCode.W) and speed or 0) - 
                     (UserInputService:IsKeyDown(Enum.KeyCode.S) and speed or 0)
                  )
                  bv.Velocity = cam:VectorToWorldSpace(move)
                  bg.CFrame = cam
               end
            end)
         else
            if connections.fly then connections.fly:Disconnect() end
            if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
            if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
         end
      end
   })

   MovementTab:CreateSlider({
      Name = "Fly Speed",
      Range = {16, 300},
      Increment = 10,
      CurrentValue = 50,
      Flag = "FlySpeed"
   })

   MovementTab:CreateToggle({
      Name = "Noclip [C]",
      CurrentValue = false,
      Flag = "Noclip",
      Callback = function(state)
         noclip = state
         if state then
            connections.noclip = RunService.Stepped:Connect(function()
               if noclip then
                  local char = getCharacter()
                  for _, part in pairs(char:GetChildren()) do
                     if part:IsA("BasePart") then
                        part.CanCollide = false
                     end
                  end
               end
            end)
         else
            if connections.noclip then connections.noclip:Disconnect() end
            local char = getCharacter()
            for _, part in pairs(char:GetChildren()) do
               if part:IsA("BasePart") then
                  part.CanCollide = true
               end
            end
         end
      end
   })

   MovementTab:CreateSlider({
      Name = "WalkSpeed",
      Range = {16, 200},
      Increment = 5,
      CurrentValue = 16,
      Flag = "WalkSpeed",
      Callback = function(value)
         local char = getCharacter()
         local hum = char:WaitForChild("Humanoid")
         hum.WalkSpeed = value
      end
   })

   MovementTab:CreateSlider({
      Name = "JumpPower",
      Range = {50, 200},
      Increment = 5,
      CurrentValue = 50,
      Flag = "JumpPower",
      Callback = function(value)
         local char = getCharacter()
         local hum = char:WaitForChild("Humanoid")
         hum.JumpPower = value
      end
   })

   -- VISUAL TAB
   local VisualTab = Window:CreateTab("👁️ Visual", 4066706610)
   
   VisualTab:CreateToggle({
      Name = "ESP Box + Info",
      CurrentValue = false,
      Flag = "ESP",
      Callback = function(state)
         if state then
            for _, player in pairs(Players:GetPlayers()) do
               if player ~= LocalPlayer then
                  local char = player.Character
                  if char and char:FindFirstChild("HumanoidRootPart") then
                     local highlight = Instance.new("Highlight")
                     highlight.FillColor = Color3.new(0,1,0)
                     highlight.OutlineColor = Color3.new(1,1,1)
                     highlight.Parent = char
                     
                     espObjects[player] = highlight
                     
                     -- Update loop
                     connections[player] = RunService.Heartbeat:Connect(function()
                        local lpRoot = getRootPart()
                        if char.Parent and char:FindFirstChild("HumanoidRootPart") and lpRoot then
                           local dist = (lpRoot.Position - char.HumanoidRootPart.Position).Magnitude
                           highlight.Adornee = char
                           highlight.FillTransparency = 0.5
                        end
                     end)
                  end
               end
            end
         else
            for player, highlight in pairs(espObjects) do
               if highlight then highlight:Destroy() end
               if connections[player] then connections[player]:Disconnect() end
            end
            espObjects = {}
            connections = {}
         end
      end
   })

   -- PLAYER TAB
   local PlayerTab = Window:CreateTab("👤 Player", 4066712134)
   local targetPlayer = nil
   
   PlayerTab:CreateDropdown({
      Name = "Target Player",
      Options = {},
      CurrentOption = "None",
      Flag = "TargetPlayer",
      Callback = function(option)
         targetPlayer = Players:FindFirstChild(option[1])
      end
   })

   PlayerTab:CreateButton({
      Name = "TP to Target",
      Callback = function()
         if targetPlayer and targetPlayer.Character then
            local root = getRootPart()
            root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
         end
      end
   })

   PlayerTab:CreateButton({
      Name = "Spectate Target",
      Callback = function()
         if targetPlayer and targetPlayer.Character then
            Camera.CameraSubject = targetPlayer.Character:FindFirstChild("Humanoid")
         end
      end
   })

   -- COMBAT TAB
   local CombatTab = Window:CreateTab("⚔️ Combat", 4066708657)
   
   CombatTab:CreateToggle({
      Name = "KillAura",
      CurrentValue = false,
      Flag = "KillAura"
   })

   -- MISC TAB
   local MiscTab = Window:CreateTab("⚙️ Misc", 4066713922)
   
   MiscTab:CreateToggle({
      Name = "Anti-AFK",
      CurrentValue = false,
      Flag = "AntiAFK",
      Callback = function(state)
         if state then
            spawn(function()
               while Window.Flags.AntiAFK do
                  game:GetService("VirtualUser"):CaptureController()
                  game:GetService("VirtualUser"):ClickButton2(Vector2.new())
                  wait(1)
               end
            end)
         end
      end
   })

   MiscTab:CreateButton({
      Name = "FPS Boost",
      Callback = function()
         settings().Rendering.QualityLevel = "Level01"
         Lighting.FogEnd = math.huge
         Lighting.GlobalShadows = false
         Window:Notify({Title = "FPS Boosted!", Duration = 2})
      end
   })

   MiscTab:CreateButton({
      Name = "Server Hop",
      Callback = function()
         local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
         if #servers.data > 1 then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers.data[1].id)
         end
      end
   })

   -- Update player list
   spawn(function()
      while wait(3) do
         local players = {}
         for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
               table.insert(players, p.Name)
            end
         end
         Window:UpdateDropdown("TargetPlayer", players)
      end
   end)

   -- Keybinds
   UserInputService.InputBegan:Connect(function(input)
      if input.KeyCode == Enum.KeyCode.X then
         Window.Flags.Fly = not Window.Flags.Fly
      elseif input.KeyCode == Enum.KeyCode.C then
         Window.Flags.Noclip = not Window.Flags.Noclip
      end
   end)

   Window:Notify({
      Title = "🦃 TurcjaHub READY!",
      Content = "X=Fly | C=Noclip | Key: turcja",
      Duration = 5,
   })
end

print("🦃 TurcjaHub Pro loaded - Key: turcja")
