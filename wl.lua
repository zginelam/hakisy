-- Iskra Hub v2.0 - Professional Drag & Drop GUI
-- Created by: turcja
-- Colors: Light Pink (#FFB6C1), White (#FFFFFF), Gray (#D3D3D3)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- User Data
local UserData = {
    UserId = Player.UserId,
    Username = Player.Name,
    GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    DisplayName = Player.DisplayName
}

-- Main Colors
local Colors = {
    Pink = Color3.fromRGB(255, 182, 193),
    LightPink = Color3.fromRGB(255, 192, 203),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(211, 211, 211),
    DarkGray = Color3.fromRGB(169, 169, 169),
    Black = Color3.fromRGB(0, 0, 0)
}

-- Key System
local Key = "iskra"
local KeyGui = nil

-- Create Key GUI
local function createKeyGUI()
    KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "IskraKeyGUI"
    KeyGui.Parent = PlayerGui
    KeyGui.ResetOnSpawn = false
    
    local KeyFrame = Instance.new("Frame")
    KeyFrame.Name = "KeyFrame"
    KeyFrame.Parent = KeyGui
    KeyFrame.BackgroundColor3 = Colors.White
    KeyFrame.BorderSizePixel = 0
    KeyFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
    KeyFrame.Size = UDim2.new(0, 400, 0, 200)
    KeyFrame.Active = true
    KeyFrame.Draggable = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = KeyFrame
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Colors.Pink
    Stroke.Thickness = 2
    Stroke.Parent = KeyFrame
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.LightPink),
        ColorSequenceKeypoint.new(1, Colors.Pink)
    }
    Gradient.Rotation = 45
    Gradient.Parent = KeyFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = KeyFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 20, 0, 20)
    Title.Size = UDim2.new(1, -40, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🔑 Iskra Hub Key"
    Title.TextColor3 = Colors.Black
    Title.TextScaled = true
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local InputBox = Instance.new("TextBox")
    InputBox.Name = "KeyInput"
    InputBox.Parent = KeyFrame
    InputBox.BackgroundColor3 = Colors.White
    InputBox.Position = UDim2.new(0, 20, 0, 80)
    InputBox.Size = UDim2.new(1, -40, 0, 50)
    InputBox.Font = Enum.Font.Gotham
    InputBox.PlaceholderText = "Enter key: iskra"
    InputBox.Text = ""
    InputBox.TextColor3 = Colors.Black
    InputBox.TextScaled = true
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 8)
    UICorner2.Parent = InputBox
    
    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Name = "Submit"
    SubmitBtn.Parent = KeyFrame
    SubmitBtn.BackgroundColor3 = Colors.Pink
    SubmitBtn.Position = UDim2.new(0, 20, 0, 140)
    SubmitBtn.Size = UDim2.new(1, -40, 0, 40)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Text = "Verify Key"
    SubmitBtn.TextColor3 = Colors.White
    SubmitBtn.TextScaled = true
    
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 8)
    UICorner3.Parent = SubmitBtn
    
    -- Animations
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    SubmitBtn.MouseButton1Click:Connect(function()
        if InputBox.Text:lower() == Key:lower() then
            KeyGui:Destroy()
            createMainGUI()
        else
            TweenService:Create(KeyFrame, tweenInfo, {Size = UDim2.new(0, 380, 0, 190)}):Play()
            wait(0.1)
            TweenService:Create(KeyFrame, tweenInfo, {Size = UDim2.new(0, 400, 0, 200)}):Play()
        end
    end)
end

-- Main GUI Creation
function createMainGUI()
    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "IskraHub"
    MainGui.Parent = PlayerGui
    MainGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = MainGui
    MainFrame.BackgroundColor3 = Colors.White
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
    MainFrame.Size = UDim2.new(0, 600, 0, 450)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Colors.Pink
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame
    
    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.White),
        ColorSequenceKeypoint.new(1, Colors.LightPink)
    }
    MainGradient.Rotation = 45
    MainGradient.Parent = MainFrame
    
    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundTransparency = 1
    Header.Size = UDim2.new(1, 0, 0, 60)
    
    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Parent = Header
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Position = UDim2.new(0, 20, 0, 10)
    HeaderTitle.Size = UDim2.new(0.6, 0, 0, 40)
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.Text = "✨ Iskra Hub v2.0"
    HeaderTitle.TextColor3 = Colors.Black
    HeaderTitle.TextScaled = true
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local CreatorLabel = Instance.new("TextLabel")
    CreatorLabel.Parent = Header
    CreatorLabel.BackgroundTransparency = 1
    CreatorLabel.Position = UDim2.new(0, 20, 0, 35)
    CreatorLabel.Size = UDim2.new(0.6, 0, 0, 20)
    CreatorLabel.Font = Enum.Font.Gotham
    CreatorLabel.Text = "Created by: turcja"
    CreatorLabel.TextColor3 = Colors.DarkGray
    CreatorLabel.TextScaled = true
    CreatorLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Header
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -40, 0, 15)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Colors.Black
    CloseBtn.TextScaled = true
    
    -- User Info Panel
    local UserInfo = Instance.new("Frame")
    UserInfo.Name = "UserInfo"
    UserInfo.Parent = MainFrame
    UserInfo.BackgroundColor3 = Colors.Gray
    UserInfo.Position = UDim2.new(0.7, 0, 0, 10)
    UserInfo.Size = UDim2.new(0.28, 0, 0, 40)
    
    local UserCorner = Instance.new("UICorner")
    UserCorner.CornerRadius = UDim.new(0, 8)
    UserCorner.Parent = UserInfo
    
    local UserLabel = Instance.new("TextLabel")
    UserLabel.Parent = UserInfo
    UserLabel.BackgroundTransparency = 1
    UserLabel.Position = UDim2.new(0, 5, 0, 2)
    UserLabel.Size = UDim2.new(1, -10, 1, 0)
    UserLabel.Font = Enum.Font.Gotham
    UserLabel.Text = string.format("ID: %d\n%s\n%s", UserData.UserId, UserData.Username, UserData.GameName)
    UserLabel.TextColor3 = Colors.Black
    UserLabel.TextScaled = true
    UserLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Scrolling Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "ScrollFrame"
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.Position = UDim2.new(0, 0, 0, 70)
    ScrollFrame.Size = UDim2.new(1, 0, 1, -80)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 1200)
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.ScrollBarImageColor3 = Colors.Pink
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = ScrollFrame
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Category Function
    local function createCategory(name, items)
        local CategoryFrame = Instance.new("Frame")
        CategoryFrame.Name = name
        CategoryFrame.Parent = ScrollFrame
        CategoryFrame.BackgroundColor3 = Colors.White
        CategoryFrame.Size = UDim2.new(1, -20, 0, 0)
        CategoryFrame.LayoutOrder = 1
        
        local CatCorner = Instance.new("UICorner")
        CatCorner.CornerRadius = UDim.new(0, 12)
        CatCorner.Parent = CategoryFrame
        
        local CatStroke = Instance.new("UIStroke")
        CatStroke.Color = Colors.Gray
        CatStroke.Thickness = 1
        CatStroke.Parent = CategoryFrame
        
        local CatTitle = Instance.new("TextLabel")
        CatTitle.Parent = CategoryFrame
        CatTitle.BackgroundTransparency = 1
        CatTitle.Position = UDim2.new(0, 15, 0, 10)
        CatTitle.Size = UDim2.new(1, -30, 0, 30)
        CatTitle.Font = Enum.Font.GothamBold
        CatTitle.Text = "🎮 " .. name
        CatTitle.TextColor3 = Colors.Black
        CatTitle.TextScaled = true
        CatTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local ItemFrame = Instance.new("Frame")
        ItemFrame.Name = "Items"
        ItemFrame.Parent = CategoryFrame
        ItemFrame.BackgroundTransparency = 1
        ItemFrame.Position = UDim2.new(0, 15, 0, 45)
        ItemFrame.Size = UDim2.new(1, -30, 1, -55)
        
        local ItemList = Instance.new("UIListLayout")
        ItemList.Parent = ItemFrame
        ItemList.Padding = UDim.new(0, 8)
        ItemList.SortOrder = Enum.SortOrder.LayoutOrder
        
        for _, item in pairs(items) do
            local Btn = Instance.new("TextButton")
            Btn.Name = item.name
            Btn.Parent = ItemFrame
            Btn.BackgroundColor3 = Colors.LightPink
            Btn.Size = UDim2.new(1, 0, 0, 35)
            Btn.Font = Enum.Font.Gotham
            Btn.Text = item.text or item.name
            Btn.TextColor3 = Colors.Black
            Btn.TextScaled = true
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 8)
            BtnCorner.Parent = Btn
            
            Btn.MouseButton1Click:Connect(function()
                if item.callback then
                    item.callback()
                end
            end)
            
            -- Hover Animation
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Pink}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.LightPink}):Play()
            end)
        end
        
        CategoryFrame.Size = UDim2.new(1, -20, 0, ItemFrame.AbsoluteSize.Y + 60)
    end
    
    -- Universal Scripts
    local universalScripts = {
        {name = "Fly", text = "✈️ Fly (Toggle)", callback = function() toggleFly() end},
        {name = "Noclip", text = "👻 Noclip (Toggle)", callback = function() toggleNoclip() end},
        {name = "Speed", text = "⚡ Speed (2x)", callback = function() setSpeed(50) end},
        {name = "Respawn", text = "🔄 Respawn", callback = function() Player.Character:BreakJoints() end},
        {name = "Rejoin", text = "🔁 Rejoin Server", callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, Player) end}
    }
    
    -- Troll Category
    local trollScripts = {
        {name = "Fling All", text = "💥 Fling All Players", callback = function() flingAll() end},
        {name = "SexTool", text = "😈 SexTool (Github)", callback = function() loadSexTool() end},
        {name = "Spam Chat", text = "💬 Spam Chat", callback = function() spamChat() end},
        {name = "Push All", text = "🚀 Push Everyone", callback = function() pushAll() end}
    }
    
    -- Stats Category
    local statsScripts = {
        {name = "Infinite Jump", text = "🦘 Infinite Jump", callback = function() toggleInfJump() end},
        {name = "No Fall", text = "🪂 No Fall Damage", callback = function() toggleNoFall() end},
        {name = "Fullbright", text = "💡 Fullbright", callback = function() toggleFullbright() end},
        {name = "Godmode", text = "🛡️ Godmode", callback = function() toggleGodmode() end}
    }
    
    -- Tower of Hell Specific
    local towerOfHell = {
        {name = "Auto Win", text = "🏆 Tower of Hell Auto Win", callback = function() towerAutoWin() end},
        {name = "SpeedHack", text = "⚡ ToH Speed Hack", callback = function() towerSpeed() end},
        {name = "NoClip Tower", text = "👻 ToH NoClip", callback = function() towerNoclip() end},
        {name = "Teleport Checkpoints", text = "📍 ToH Teleport CP", callback = function() towerTeleport() end}
    }
    
    -- CMD Scripts (Fixed from Github)
    local cmdScripts = {
        {name = "CMD 1", text = "📟 Universal CMD 1", callback = function() loadCMD1() end},
        {name = "CMD 2", text = "📟 CMD 2 (Infinite Yield)", callback = function() loadInfiniteYield() end},
        {name = "CMD 3", text = "📟 CMD 3 (Skibidi)", callback = function() loadSkibidiCMD() end}
    }
    
    -- Create Categories
    createCategory("Universal", universalScripts)
    createCategory("Troll", trollScripts)
    createCategory("Player Stats", statsScripts)
    createCategory("Tower of Hell", towerOfHell)
    createCategory("Commands", cmdScripts)
    
    -- Close Button
    CloseBtn.MouseButton1Click:Connect(function()
        MainGui:Destroy()
    end)
    
    -- Update Canvas Size
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
    end)
end

-- Script Functions
local flying = false
local noclipping = false
local connections = {}

function toggleFly()
    flying = not flying
    if flying then
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.Parent = Player.Character.HumanoidRootPart
        
        local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
        bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
        bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        bodyAngularVelocity.Parent = Player.Character.HumanoidRootPart
        
        connections[#connections + 1] = RunService.Heartbeat:Connect(function()
            if Player.Character and Player.Character.HumanoidRootPart then
                local cam = workspace.CurrentCamera
                local vel = bodyVelocity
                vel.Velocity = (cam.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.W) and 50 or 0)) +
                              (cam.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.D) and 50 or 0)) +
                              (cam.CFrame.LookVector * (UserInputService:IsKeyDown(Enum.KeyCode.S) and -50 or 0)) +
                              (cam.CFrame.RightVector * (UserInputService:IsKeyDown(Enum.KeyCode.A) and -50 or 0)) +
                              (Vector3.new(0, UserInputService:IsKeyDown(Enum.KeyCode.Space) and 50 or 0, 0))
            end
        end)
    else
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
            Player.Character.HumanoidRootPart.BodyVelocity:Destroy()
        end
        if Player.Character and Player.Character.HumanoidRootPart:FindFirstChild("BodyAngularVelocity") then
            Player.Character.HumanoidRootPart.BodyAngularVelocity:Destroy()
        end
    end
end

function toggleNoclip()
    noclipping = not noclipping
    if noclipping then
        connections[#connections + 1] = RunService.Stepped:Connect(function()
            if Player.Character then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        for _, conn in pairs(connections) do
            conn:Disconnect()
        end
        connections = {}
        if Player.Character then
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

function setSpeed(speed)
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = speed
    end
end

function flingAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local flingVel = Instance.new("BodyVelocity")
            flingVel.MaxForce = Vector3.new(4000, 4000, 4000)
            flingVel.Velocity = Vector3.new(math.random(-100,100), 200, math.random(-100,100))
            flingVel.Parent = player.Character.HumanoidRootPart
            
            game:GetService("Debris"):AddItem(flingVel, 0.5)
        end
    end
end

-- Additional Functions (placeholders for Github scripts)
function loadSexTool() print("SexTool loaded from Github") end
function spamChat() print("Chat spam activated") end
function pushAll() print("Push all activated") end
function toggleInfJump() print("Infinite jump toggled") end
function toggleNoFall() print("No fall toggled") end
function toggleFullbright()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
end
function toggleGodmode() print("Godmode toggled") end
function towerAutoWin() print("ToH Auto Win") end
function towerSpeed() setSpeed(100) end
function towerNoclip() toggleNoclip() end
function towerTeleport() print("ToH Teleport") end
function loadCMD1() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end
function loadInfiniteYield() loadCMD1() end
function loadSkibidiCMD() print("Skibidi CMD loaded") end

-- Initialize
createKeyGUI()

-- Auto-cleanup on respawn
Player.CharacterAdded:Connect(function()
    wait(1)
    if KeyGui then KeyGui:Destroy() end
end)
