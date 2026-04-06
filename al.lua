-- Iskra Hub v3.0 - Dark Professional Edition
-- Created by: turcja
-- Key: iskra | Toggle: LEFT SHIFT

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Dark Theme Colors
local Colors = {
    Dark1 = Color3.fromRGB(25, 25, 35),      -- Main background
    Dark2 = Color3.fromRGB(35, 35, 45),      -- Secondary
    Dark3 = Color3.fromRGB(45, 45, 55),      -- Cards
    Pink = Color3.fromRGB(255, 105, 180),    -- Accent
    PinkLight = Color3.fromRGB(255, 182, 193),
    White = Color3.fromRGB(240, 240, 250),   -- Text
    Gray = Color3.fromRGB(150, 150, 170)     -- Subtext
}

-- State Management
local GuiOpen = false
local Toggles = {
    Fly = false, Noclip = false, InfiniteJump = false, NoFall = false, Fullbright = false
}
local Connections = {}

-- Main GUI
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "IskraHub"
MainGui.Parent = PlayerGui
MainGui.ResetOnSpawn = false
MainGui.Enabled = false

-- Create Main Frame
local function createMainFrame()
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.BackgroundColor3 = Colors.Dark1
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -275)
    MainFrame.Size = UDim2.new(0, 650, 0, 550)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    -- Corners & Effects
    local Corner = Instance.new("UICorner", MainFrame)
    Corner.CornerRadius = UDim.new(0, 16)
    
    local Stroke = Instance.new("UIStroke", MainFrame)
    Stroke.Color = Colors.Pink
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    
    local Gradient = Instance.new("UIGradient", MainFrame)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Dark1),
        ColorSequenceKeypoint.new(1, Colors.Dark2)
    }
    Gradient.Rotation = 45
    
    -- Shadow
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.ZIndex = -1
    local ShadowCorner = Instance.new("UICorner", Shadow)
    ShadowCorner.CornerRadius = UDim.new(0, 16)
    
    return MainFrame
end

-- Header
local function createHeader(parent)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = parent
    Header.BackgroundColor3 = Colors.Dark3
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BorderSizePixel = 0
    
    local HeaderCorner = Instance.new("UICorner", Header)
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.TopLeftRadius = 16
    HeaderCorner.TopRightRadius = 16
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌟 Iskra Hub v3.0"
    Title.TextColor3 = Colors.Pink
    Title.TextSize = 24
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local Creator = Instance.new("TextLabel")
    Creator.Parent = Header
    Creator.BackgroundTransparency = 1
    Creator.Position = UDim2.new(0, 20, 0, 35)
    Creator.Size = UDim2.new(0.6, 0, 0.5, 0)
    Creator.Font = Enum.Font.Gotham
    Creator.Text = "Created by: turcja"
    Creator.TextColor3 = Colors.Gray
    Creator.TextSize = 14
    Creator.TextXAlignment = Enum.TextXAlignment.Left
    
    -- User Info (Clean)
    local UserFrame = Instance.new("Frame")
    UserFrame.Parent = Header
    UserFrame.BackgroundColor3 = Colors.Dark2
    UserFrame.Position = UDim2.new(0.7, -10, 0.15, 0)
    UserFrame.Size = UDim2.new(0.28, 0, 0.7, 0)
    
    local UserCorner = Instance.new("UICorner", UserFrame)
    UserCorner.CornerRadius = UDim.new(0, 8)
    
    local UserText = Instance.new("TextLabel")
    UserText.Parent = UserFrame
    UserText.BackgroundTransparency = 1
    UserText.Size = UDim2.new(1, -8, 1, 0)
    UserText.Position = UDim2.new(0, 4, 0, 0)
    UserText.Font = Enum.Font.Gotham
    UserText.Text = string.format("%s\nID: %d", Player.DisplayName or Player.Name, Player.UserId)
    UserText.TextColor3 = Colors.White
    UserText.TextSize = 12
    UserText.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundColor3 = Colors.Pink
    CloseBtn.Position = UDim2.new(1, -45, 0, 15)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Colors.White
    CloseBtn.TextSize = 20
    
    local CloseCorner = Instance.new("UICorner", CloseBtn)
    CloseCorner.CornerRadius = UDim.new(0, 8)
    
    return CloseBtn
end

-- Toggle Button Component
local function createToggle(parent, name, callback, default)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Colors.Dark3
    ToggleFrame.Size = UDim2.new(1, -20, 0, 45)
    
    local ToggleCorner = Instance.new("UICorner", ToggleFrame)
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name:gsub("^%l", string.upper):gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    Label.TextColor3 = Colors.White
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = default and Colors.Pink or Colors.Gray
    ToggleBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
    ToggleBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = Colors.White
    ToggleBtn.TextSize = 12
    
    local BtnCorner = Instance.new("UICorner", ToggleBtn)
    BtnCorner.CornerRadius = UDim.new(0, 8)
    
    local state = default or false
    Toggles[name] = state
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Toggles[name] = state
        ToggleBtn.BackgroundColor3 = state and Colors.Pink or Colors.Gray
        ToggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)
    
    return ToggleFrame
end

-- Button Component
local function createButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = parent
    Button.BackgroundColor3 = Colors.Pink
    Button.Size = UDim2.new(1, -20, 0, 45)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name:gsub("^%l", string.upper):gsub("(%l)(%w*)", function(a,b) return string.upper(a)..b end)
    Button.TextColor3 = Colors.White
    Button.TextSize = 14
    
    local BtnCorner = Instance.new("UICorner", Button)
    BtnCorner.CornerRadius = UDim.new(0, 10)
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -25, 0, 42)}):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 45)}):Play()
        if callback then callback() end
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.PinkLight}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Pink}):Play()
    end)
    
    return Button
end

-- Category Tab System
local function createTabs()
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "Tabs"
    TabFrame.Parent = MainFrame
    TabFrame.BackgroundTransparency = 1
    TabFrame.Position = UDim2.new(0, 0, 0, 65)
    TabFrame.Size = UDim2.new(1, 0, 0, 35)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabFrame
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Position = UDim2.new(0, 0, 0, 105)
    ContentFrame.Size = UDim2.new(1, 0, 1, -105)
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Parent = ContentFrame
    ContentLayout.Padding = UDim.new(0, 10)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local tabs = {
        {name = "Universal", content = {
            createToggle(nil, "Fly", toggleFly),
            createToggle(nil, "Noclip", toggleNoclip),
            createButton(nil, "Speed 50", function() setWalkSpeed(50) end),
            createButton(nil, "Speed 100", function() setWalkSpeed(100) end),
            createButton(nil, "Respawn", respawnPlayer),
            createButton(nil, "Rejoin", rejoinServer)
        }},
        {name = "Troll", content = {
            createButton(nil, "Fling All", flingAll),
            createButton(nil, "Push All", pushAllPlayers),
            createButton(nil, "Spam Chat", spamChat),
            createButton(nil, "Sex Tool", loadSexTool)
        }},
        {name = "Combat", content = {
            createToggle(nil, "Infinite Jump", toggleInfJump),
            createToggle(nil, "No Fall", toggleNoFall),
            createToggle(nil, "Fullbright", toggleFullbright),
            createButton(nil, "Godmode", toggleGodmode),
            createButton(nil, "Click TP", clickTeleport)
        }},
        {name = "Tower of Hell", content = {
            createButton(nil, "Auto Win", towerOfHellAutoWin),
            createButton(nil, "Speed Hack", towerSpeedHack),
            createButton(nil, "NoClip Tower", towerNoclip),
            createButton(nil, "TP Checkpoints", towerTeleportCP)
        }},
        {name = "Commands", content = {
            createButton(nil, "Infinite Yield", loadInfiniteYield),
            createButton(nil, "Skibidi CMD", loadSkibidiCMD),
            createButton(nil, "CMD 3", loadCMD3)
        }}
    }
    
    local currentTab = 1
    for i, tabData in ipairs(tabs) do
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabData.name
        TabBtn.Parent = TabFrame
        TabBtn.BackgroundColor3 = i == 1 and Colors.Pink or Colors.Dark3
        TabBtn.Size = UDim2.new(0.18, 0, 1, 0)
        TabBtn.Font = Enum.Font.GothamSemibold
        TabBtn.Text = tabData.name
        TabBtn.TextColor3 = Colors.White
        TabBtn.TextSize = 14
        
        local TabCorner = Instance.new("UICorner", TabBtn)
        TabCorner.CornerRadius = UDim.new(0, 10)
        
        TabBtn.MouseButton1Click:Connect(function()
            currentTab = i
            for j, btn in ipairs(TabFrame:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = j == i and Colors.Pink or Colors.Dark3
                end
            end
            for j, frame in ipairs(ContentFrame:GetChildren()) do
                if frame:IsA("Frame") and frame.Name ~= "Content" then
                    frame.Visible = false
                end
            end
            tabData.contentFrame.Visible = true
        end)
        
        -- Create content frame
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = tabData.name .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, -20, 1, -10)
        TabContent.Position = UDim2.new(0, 10, 0, 5)
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Colors.Pink
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.Visible = i == 1
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Parent = TabContent
        ContentList.Padding = UDim.new(0, 8)
        
        for _, item in ipairs(tabData.content) do
            item.Parent = TabContent
        end
        
        tabData.contentFrame = TabContent
        
        ContentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 20)
        end)
    end
end

-- Initialize GUI
local MainFrame = createMainFrame()
local CloseBtn = createHeader(MainFrame)
createTabs()

-- Toggle GUI with LEFT SHIFT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftShift then
        GuiOpen = not GuiOpen
        MainGui.Enabled = GuiOpen
        if GuiOpen then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 650, 0, 550),
                Position = UDim2.new(0.5, -325, 0.5, -275)
            }):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    GuiOpen = false
    MainGui.Enabled = false
end)

-- WORKING FUNCTIONS
function toggleFly(state)
    if state and Player.Character then
        local BV = Instance.new("BodyVelocity")
        BV.MaxForce = Vector3.new(4000, 4000, 4000)
        BV.Velocity = Vector3.new(0,0,0)
        BV.Parent = Player.Character.HumanoidRootPart
        
        Connections[#Connections+1] = RunService.Heartbeat:Connect(function()
            if Player.Character and Player.Character.HumanoidRootPart then
                local camera = workspace.CurrentCamera
                local moveVector = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0,1,0) end
                BV.Velocity = moveVector * 50
            end
        end)
    else
        for i, conn in ipairs(Connections) do
            conn:Disconnect()
            table.remove(Connections, i)
        end
        if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
    end
end

function toggleNoclip(state)
    if state then
        Connections[#Connections+1] = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        for i, conn in ipairs(Connections) do
            conn:Disconnect()
            table.remove(Connections, i)
        end
    end
end

function setWalkSpeed(speed)
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = speed
    end
end

function respawnPlayer()
    if Player.Character then Player.Character:BreakJoints() end
end

function rejoinServer()
    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
end

function flingAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(math.random(-50,50), math.random(50,100), math.random(-50,50))
            bv.Parent = plr.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 0.3)
        end
    end
end

function pushAllPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 0, 4000)
            bv.Velocity = (plr.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Unit * 100
            bv.Parent = plr.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 0.2)
        end
    end
end

function toggleInfJump() -- Simplified working version
    Toggles.InfiniteJump = not Toggles.InfiniteJump
    if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
        Player.Character.Humanoid.JumpPower = Toggles.InfiniteJump and 100 or 50
    end
end

function toggleNoFall()
    Toggles.NoFall = not Toggles.NoFall
    if Toggles.NoFall then
        Connections[#Connections+1] = RunService.Stepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") then
                Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

function toggleFullbright(state)
    Toggles.Fullbright = state
    Lighting.Brightness = state and 2 or 1
    Lighting.GlobalShadows = not state
    Lighting.FogEnd = state and 9e9 or 100000
end

-- Load external scripts
function loadInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end

print("🌟 Iskra Hub v3.0 Loaded! Press LEFT SHIFT to toggle")
