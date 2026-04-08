-- Turcja Hub v20.1 | FIXED LOADING ERROR | PERFECT
local success, Rayfield = pcall(function()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/shlexware/Rayfield/main/source",
        "https://raw.githubusercontent.com/RegularVynixu/rayfield/main/source"
    }
    
    for _, url in ipairs(urls) do
        local success2, result = pcall(function()
            return loadstring(game:HttpGetAsync(url, true))()
        end)
        if success2 and result then 
            return result 
        end
        wait(0.1)
    end
    return nil
end)

if not success or not Rayfield then
    game.StarterGui:SetCore("SendNotification", {
        Title = "ERROR";
        Text = "Rayfield failed to load! Try again.";
        Duration = 5;
    })
    return
end

local Window = Rayfield:CreateWindow({
   Name = "Turcja Hub v20.1 🔥 FIXED",
   LoadingTitle = "Turcja Hub",
   LoadingSubtitle = "Loading safely...",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "TurciaHub"
   },
   KeySystem = false
})

-- SAFE SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- STATE
local Features = {
    ESP = false,
    Fly = false,
    Noclip = false,
    FakeLag = false,
    FlingAll = false,
    SpinAll = false,
    InfJump = false,
    selectedPlayer = ""
}

local playerList = {}
local flySpeed = 50
local ESPData = {}

-- UTILS
local function getPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(list, p.Name)
        end
    end
    table.sort(list)
    return list
end

playerList = getPlayers()

local function notify(title, text, img)
    pcall(function()
        Rayfield:Notify({
            Title = title,
            Content = text,
            Duration = 3,
            Image = img or 4483362458
        })
    end)
end

local function tpToPlayer(name)
    local target = Players:FindFirstChild(name)
    local me = LocalPlayer.Character
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and 
       me and me:FindFirstChild("HumanoidRootPart") then
        me.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, -2)
        return true
    end
    return false
end

-- TABS
local Tab1 = Window:CreateTab("🎉 Welcome", 4483362458)
local Tab2 = Window:CreateTab("🏠 Main", 4483362458)
local Tab3 = Window:CreateTab("👥 Players", 4483362458)
local Tab4 = Window:CreateTab("🚀 Movement", 4483362458)
local Tab5 = Window:CreateTab("🎨 Visuals", 4483362458)
local Tab6 = Window:CreateTab("😂 Troll", 4483362458)

-- BROOKHAVEN CHECK
local isBrookhaven = game.PlaceId == 4924922222
local BrookTab = isBrookhaven and Window:CreateTab("🏘️ Brookhaven", 4483362458)

-- WELCOME
Tab1:CreateParagraph({Title="Info", Content="Real exploits only"})
Tab1:CreateButton({
    Name = "Copy Discord",
    Callback = function()
        setclipboard("turcja")
        notify("Copied", "turcja")
    end
})

-- MAIN
Tab2:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Callback = function(v)
        Lighting.Brightness = v and 2 or 1
        Lighting.FogEnd = v and 9e9 or 100
    end
})

Tab2:CreateButton({
    Name = "Unlock Doors",
    Callback = function()
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("door") then
                obj.CanCollide = false
                count = count + 1
            end
        end
        notify("Unlocked", count .. " doors")
    end
})

-- PLAYERS
Tab3:CreateButton({
    Name = "Refresh Players",
    Callback = function()
        playerList = getPlayers()
        notify("Refreshed", #playerList .. " players")
    end
})

local tpDrop = Tab3:CreateDropdown({
    Name = "TP Target",
    Options = playerList,
    CurrentOption = {"Select"},
    Callback = function(opt)
        Features.selectedPlayer = opt[1]
    end
})

Tab3:CreateButton({
    Name = "Teleport",
    Callback = function()
        if tpToPlayer(Features.selectedPlayer) then
            notify("TP OK", Features.selectedPlayer)
        else
            notify("Error", "Player not found", 16711680)
        end
    end
})

local specDrop = Tab3:CreateDropdown({
    Name = "Spectate",
    Options = playerList,
    CurrentOption = {"Select"},
    Callback = function(opt)
        local target = Players:FindFirstChild(opt[1])
        if target and target.Character then
            Camera.CameraSubject = target.Character.Humanoid
        end
    end
})

-- MOVEMENT
Tab4:CreateToggle({
    Name = "Fly (WASD+Space)",
    CurrentValue = false,
    Callback = function(v)
        Features.Fly = v
    end
})

Tab4:CreateSlider({
    Name = "Fly Speed",
    Range = {16, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(v)
        flySpeed = v
    end
})

Tab4:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = function(v)
        Features.Noclip = v
    end
})

Tab4:CreateToggle({
    Name = "Inf Jump",
    CurrentValue = false,
    Callback = function(v)
        Features.InfJump = v
    end
})

-- VISUALS
Tab5:CreateToggle({
    Name = "Rainbow ESP",
    CurrentValue = false,
    Callback = function(v)
        Features.ESP = v
    end
})

-- TROLL
Tab6:CreateToggle({
    Name = "Fling All",
    CurrentValue = false,
    Callback = function(v)
        Features.FlingAll = v
    end
})

Tab6:CreateButton({
    Name = "Sit on Head",
    Callback = function()
        local target = Players:FindFirstChild(Features.selectedPlayer)
        local me = LocalPlayer.Character
        if target and target.Character and target.Character.Head and me then
            me.HumanoidRootPart.CFrame = target.Character.Head.CFrame * CFrame.new(0, 2, 0)
        end
    end
})

-- BROOKHAVEN
if BrookTab then
    BrookTab:CreateButton({
        Name = "All Houses",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "Hause", "Recieve")
            end)
        end
    })
    
    BrookTab:CreateButton({
        Name = "$1M Money",
        Callback = function()
            pcall(function()
                ReplicatedStorage.MainEvent:FireServer(LocalPlayer, "SetCash", 1000000)
            end)
        end
    })
end

-- PERFECT ESP
RunService.RenderStepped:Connect(function()
    if not Features.ESP then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if not ESPData[player] then
                ESPData[player] = Drawing.new("Square")
                ESPData[player].Size = Vector2.new(2000, 3000)
                ESPData[player].Color = Color3.new(1,0,0)
                ESPData[player].Visible = false
            end
            
            local head = player.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                ESPData[player].Size = Vector2.new(1000, 1500)
                ESPData[player].Position = Vector2.new(pos.X-500, pos.Y-750)
                ESPData[player].Color = Color3.fromHSV(tick()%5/5, 1, 1)
                ESPData[player].Visible = true
            else
                ESPData[player].Visible = false
            end
        end
    end
end)

-- MAIN LOOP
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if root and hum then
        -- FLY
        if Features.Fly then
            local bv = root:FindFirstChild("FlyBV")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(4000,4000,4000)
                bv.Parent = root
            end
            
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                move = move + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                move = move - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                move = move - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                move = move + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                move = move + Vector3.new(0,1,0)
            end
            
            bv.Velocity = move * flySpeed
        elseif root:FindFirstChild("FlyBV") then
            root.FlyBV:Destroy()
        end
        
        -- NOCLIP
        if Features.Noclip then
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
        
        -- FLING ALL
        if Features.FlingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.Velocity = Vector3.new(math.random(-50,50), 100, math.random(-50,50))
                end
            end
        end
    end
end)

-- JUMP
UserInputService.JumpRequest:Connect(function()
    if Features.InfJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

notify("Loaded!", "Turcja Hub v20.1 - No Errors", 4483362458)
print("✅ Turcja Hub v20.1 LOADED PERFECTLY")
