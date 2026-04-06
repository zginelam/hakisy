-- Iskra Hub v3.1 - FIXED Dark Professional Edition
-- Created by: turcja
-- Key: iskra | Toggle: LEFT SHIFT

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Dark Theme Colors
local Colors = {
    Dark1 = Color3.fromRGB(25, 25, 35),
    Dark2 = Color3.fromRGB(35, 35, 45),
    Dark3 = Color3.fromRGB(45, 45, 55),
    Pink = Color3.fromRGB(255, 105, 180),
    PinkLight = Color3.fromRGB(255, 182, 193),
    White = Color3.fromRGB(240, 240, 250),
    Gray = Color3.fromRGB(150, 150, 170)
}

-- State Management
local GuiOpen = false
local Toggles = {Fly = false, Noclip = false, InfiniteJump = false, NoFall = false, Fullbright = false}
local Connections = {}

-- Main GUI
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "IskraHub"
MainGui.Parent = PlayerGui
MainGui.ResetOnSpawn = false
MainGui.Enabled = false

local MainFrame = nil

-- FIXED createMainFrame
local function createMainFrame()
    MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.BackgroundColor3 = Colors.Dark1
    MainFrame.Position = UDim2.new(0.5, -325, 0.5, -275)
    MainFrame.Size = UDim2.new(0, 650, 0, 550)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 16)
    Corner.Parent = MainFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Pink
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = MainFrame
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Dark1),
        ColorSequenceKeypoint.new(1, Colors.Dark2)
    }
    Gradient.Rotation = 45
    Gradient.Parent = MainFrame
    
    local Shadow = Instance.new("Frame")
    Shadow.Name = "Shadow"
    Shadow.Parent = MainFrame
    Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BackgroundTransparency = 0.7
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.ZIndex = -1
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 16)
    ShadowCorner.Parent = Shadow
    
    return MainFrame
end

-- FIXED createHeader
local function createHeader(parentFrame)
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = parentFrame
    Header.BackgroundColor3 = Colors.Dark3
    Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BorderSizePixel = 0
    
    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 16)
    HeaderCorner.TopLeftRadius = 16
    HeaderCorner.TopRightRadius = 16
    HeaderCorner.Parent = Header
    
    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🌟 Iskra Hub v3.1"
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
    
    local UserFrame = Instance.new("Frame")
    UserFrame.Parent = Header
    UserFrame.BackgroundColor3 = Colors.Dark2
    UserFrame.Position = UDim2.new(0.7, -10, 0.15, 0)
    UserFrame.Size = UDim2.new(0.28, 0, 0.7, 0)
    
    local UserCorner = Instance.new("UICorner")
    UserCorner.CornerRadius = UDim.new(0, 8)
    UserCorner.Parent = UserFrame
    
    local UserText = Instance.new("TextLabel")
    UserText.Parent = UserFrame
    UserText.BackgroundTransparency = 1
    UserText.Size = UDim2.new(1, -8, 1, 0)
    UserText.Position = UDim2.new(0, 4, 0, 0)
    UserText.Font = Enum.Font.Gotham
    UserText.Text = Player.Name .. "\nID: " .. Player.UserId
    UserText.TextColor3 = Colors.White
    UserText.TextSize = 12
    UserText.TextYAlignment = Enum.TextYAlignment.Top
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundColor3 = Colors.Pink
    CloseBtn.Position = UDim2.new(1, -45, 0, 15)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Colors.White
    CloseBtn.TextSize = 20
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    return CloseBtn
end

-- Toggle Button
local function createToggle(parent, name, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Colors.Dark3
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Font = Enum.Font.GothamSemibold
    Label.Text = name
    Label.TextColor3 = Colors.White
    Label.TextSize = 15
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = ToggleFrame
    ToggleBtn.BackgroundColor3 = Colors.Gray
    ToggleBtn.Position = UDim2.new(0.8, 0, 0.15, 0)
    ToggleBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "OFF"
    ToggleBtn.TextColor3 = Colors.White
    ToggleBtn.TextSize = 12
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = ToggleBtn
    
    local state = false
    Toggles[name] = state
    
    ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        Toggles[name] = state
        ToggleBtn.BackgroundColor3 = state and Colors.Pink or Colors.Gray
        ToggleBtn.Text = state and "ON" or "OFF"
        spawn(callback, state)
    end)
    
    return ToggleFrame
end

-- Button
local function createButton(parent, name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Parent = parent
    Button.BackgroundColor3 = Colors.Pink
    Button.Size = UDim2.new(1, 0, 0, 45)
    Button.Font = Enum.Font.GothamSemibold
    Button.Text = name
    Button.TextColor3 = Colors.White
    Button.TextSize = 15
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 10)
    BtnCorner.Parent = Button
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, -8, 0, 42)}):Play()
        wait(0.1)
        TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        spawn(callback)
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.PinkLight}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Pink}):Play()
    end)
    
    return Button
end

-- Initialize GUI
createMainFrame()
local CloseBtn = createHeader(MainFrame)

-- Simple Categories (NO TABS BUG)
local CategoryFrame = Instance.new("ScrollingFrame")
CategoryFrame.Name = "Categories"
CategoryFrame.Parent = MainFrame
CategoryFrame.BackgroundTransparency = 1
CategoryFrame.Position = UDim2.new(0, 10, 0, 75)
CategoryFrame.Size = UDim2.new(1, -20, 1, -85)
CategoryFrame.ScrollBarThickness = 8
CategoryFrame.ScrollBarImageColor3 = Colors.Pink

local Layout = Instance.new("UIListLayout")
Layout.Parent = CategoryFrame
Layout.Padding = UDim.new(0, 15)

-- Universal Category
local UniversalCat = Instance.new("Frame")
UniversalCat.Name = "Universal"
UniversalCat.Parent = CategoryFrame
UniversalCat.BackgroundColor3 = Colors.Dark2
UniversalCat.Size = UDim2.new(1, 0, 0, 300)

local UniCorner = Instance.new("UICorner")
UniCorner.CornerRadius = UDim.new(0, 12)
UniCorner.Parent = UniversalCat

local UniTitle = Instance.new("TextLabel")
UniTitle.Parent = UniversalCat
UniTitle.BackgroundTransparency = 1
UniTitle.Size = UDim2.new(1, 0, 0, 40)
UniTitle.Font = Enum.Font.GothamBold
UniTitle.Text = "🌐 Universal"
UniTitle.TextColor3 = Colors.Pink
UniTitle.TextSize = 18

local UniLayout = Instance.new("UIListLayout")
UniLayout.Parent = UniversalCat
UniLayout.Padding = UDim.new(0, 8)
UniLayout.Position = UDim2.new(0, 0, 0, 45)

createToggle(UniversalCat, "Fly", toggleFly)
createToggle(UniversalCat, "Noclip", toggleNoclip)
createButton(UniversalCat, "Speed 50", function() setWalkSpeed(50) end)
createButton(UniversalCat, "Speed 100", function() setWalkSpeed(100) end)
createButton(UniversalCat, "Respawn", respawnPlayer)

-- Troll Category
local TrollCat = Instance.new("Frame")
TrollCat.Name = "Troll"
TrollCat.Parent = CategoryFrame
TrollCat.BackgroundColor3 = Colors.Dark2
TrollCat.Size = UDim2.new(1, 0, 0, 220)

local TrollCorner = Instance.new("UICorner")
TrollCorner.CornerRadius = UDim.new(0, 12)
TrollCorner.Parent = TrollCat

local TrollTitle = Instance.new("TextLabel")
TrollTitle.Parent = TrollCat
TrollTitle.BackgroundTransparency = 1
TrollTitle.Size = UDim2.new(1, 0, 0, 40)
TrollTitle.Font = Enum.Font.GothamBold
TrollTitle.Text = "😂 Troll"
TrollTitle.TextColor3 = Colors.Pink
TrollTitle.TextSize = 18

local TrollLayout = Instance.new("UIListLayout")
TrollLayout.Parent = TrollCat
TrollLayout.Padding = UDim.new(0, 8)
TrollLayout.Position = UDim2.new(0, 0, 0, 45)

createButton(TrollCat, "Fling All", flingAll)
createButton(TrollCat, "Push All", pushAllPlayers)
createButton(TrollCat, "Infinite Yield", loadInfiniteYield)

-- WORKING FUNCTIONS
function toggleFly(state)
    if state and Player.Character then
        local char = Player.Character
        local root = char:WaitForChild("HumanoidRootPart")
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0,0,0)
        bv.Parent = root
        
        Connections[#Connections+1] = RunService.Heartbeat:Connect(function()
            if char and char.Parent and root.Parent then
                local cam = workspace.CurrentCamera
                local move = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,50,0) end
                bv.Velocity = move
            end
        end)
    else
        for _, conn in pairs(Connections) do conn:Disconnect() end
        Connections = {}
        if Player.Character then
            local bv = Player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("BodyVelocity")
            if bv then bv:Destroy() end
        end
    end
end

function toggleNoclip(state)
    if state then
        Connections[#Connections+1] = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        for _, conn in pairs(Connections) do conn:Disconnect() end
        Connections = {}
    end
end

function setWalkSpeed(speed)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = speed
    end
end

function respawnPlayer()
    Player.Character:BreakJoints()
end

function flingAll()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.new(math.random(-100,100), 200, math.random(-100,100))
            bv.Parent = plr.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 0.5)
        end
    end
end

function pushAllPlayers()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dir = (plr.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Unit
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 0, 4000)
            bv.Velocity = dir * 100
            bv.Parent = plr.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 0.3)
        end
    end
end

function loadInfiniteYield()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end

-- Toggle GUI - LEFT SHIFT
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.LeftShift then
        GuiOpen = not GuiOpen
        MainGui.Enabled = GuiOpen
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    GuiOpen = false
    MainGui.Enabled = false
end)

-- Update canvas size
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    CategoryFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
end)

print("✅ Iskra Hub v3.1 LOADED! Press LEFT SHIFT")
