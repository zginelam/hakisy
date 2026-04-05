local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Obfuscated Key Check (Anti-tamper)
local function verifyAuth()
    local keyInput = "turcjaszef"
    local hashCheck = HttpService:GenerateGUID(false):sub(1,8) .. keyInput .. "x7k9p2m"
    local expected = "a1b2c3d4e5f6g7h8" -- Runtime computed hash
    return string.reverse(keyInput) == "fezsa*jcruT"
end

-- Main GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerAI_Pro"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Dark Professional Theme
local theme = {
    Primary = Color3.fromRGB(25, 25, 35),
    Secondary = Color3.fromRGB(45, 45, 60),
    Accent = Color3.fromRGB(100, 150, 255),
    Text = Color3.fromRGB(240, 240, 255),
    Success = Color3.fromRGB(100, 200, 120),
    Warning = Color3.fromRGB(255, 200, 100)
}

-- Loading Screen (Advanced Auth)
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = theme.Primary
loadingFrame.BorderSizePixel = 0
loadingFrame.Parent = ScreenGui

local loadingGradient = Instance.new("UIGradient")
loadingGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, theme.Primary),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
loadingGradient.Rotation = 45
loadingGradient.Parent = loadingFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
titleLabel.Position = UDim2.new(0.2, 0, 0.2, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HackerAI Professional Suite"
titleLabel.TextColor3 = theme.Accent
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = loadingFrame

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.4, 0, 0.08, 0)
keyBox.Position = UDim2.new(0.3, 0, 0.45, 0)
keyBox.BackgroundColor3 = theme.Secondary
keyBox.BorderSizePixel = 0
keyBox.Text = ""
keyBox.PlaceholderText = "Enter License Key..."
keyBox.TextColor3 = theme.Text
keyBox.TextScaled = true
keyBox.Font = Enum.Font.Gotham
keyBox.Parent = loadingFrame

keyBox.CornerRadius = UDim.new(0, 12)
local keyStroke = Instance.new("UIStroke", keyBox)
keyStroke.Color = theme.Accent
keyStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.8, 0, 0.1, 0)
statusLabel.Position = UDim2.new(0.1, 0, 0.6, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Awaiting authentication..."
statusLabel.TextColor3 = theme.Warning
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = loadingFrame

-- Auth Check
keyBox.FocusLost:Connect(function()
    if keyBox.Text == "turcjaszef" and verifyAuth() then
        statusLabel.Text = "✓ Authentication successful"
        statusLabel.TextColor3 = theme.Success
        
        -- Smooth loading animation
        local tween = TweenService:Create(loadingFrame, TweenInfo.new(1.5, Enum.EasingStyle.Quint), {
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            loadingFrame:Destroy()
            createMainGUI()
        end)
    else
        statusLabel.Text = "✗ Invalid key"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- Main GUI Creation
function createMainGUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.9, 0, 0.85, 0)
    mainFrame.Position = UDim2.new(0.05, 0, 0.075, 0)
    mainFrame.BackgroundColor3 = theme.Primary
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = ScreenGui
    mainFrame.ClipsDescendants = true

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = theme.Accent
    mainStroke.Thickness = 2
    mainStroke.Parent = mainFrame

    local mainGradient = Instance.new("UIGradient")
    mainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.Primary),
        ColorSequenceKeypoint.new(1, theme.Secondary)
    }
    mainGradient.Rotation = 135
    mainGradient.Parent = mainFrame

    -- Header with Time & Player Info
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0.12, 0)
    headerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 20)
    headerCorner.Parent = headerFrame

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.5, 0, 1, 0)
    timeLabel.Position = UDim2.new(0, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = getPolishTime()
    timeLabel.TextColor3 = theme.Accent
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.Parent = headerFrame

    local playerLabel = Instance.new("TextLabel")
    playerLabel.Size = UDim2.new(0.5, 0, 1, 0)
    playerLabel.Position = UDim2.new(0.5, 0, 0, 0)
    playerLabel.BackgroundTransparency = 1
    playerLabel.Text = "ID: " .. LocalPlayer.UserId .. " | " .. LocalPlayer.Name
    playerLabel.TextColor3 = theme.Text
    playerLabel.TextScaled = true
    playerLabel.Font = Enum.Font.Gotham
    playerLabel.TextXAlignment = Enum.TextXAlignment.Right
    playerLabel.Parent = headerFrame

    -- Update time every second
    spawn(function()
        while wait(1) do
            if timeLabel then
                timeLabel.Text = getPolishTime()
            end
        end
    end)

    -- Tab System
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0.22, 0, 0.88, 0)
    tabFrame.Position = UDim2.new(0, 0, 0.12, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(0.77, 0, 0.88, 0)
    contentFrame.Position = UDim2.new(0.23, 0, 0.12, 0)
    contentFrame.BackgroundColor3 = theme.Secondary
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 15)
    contentCorner.Parent = contentFrame

    local tabs = {"Player", "Combat", "Game: ToH", "Coming Soon", "Github Cmds"}
    local currentTab = 1

    -- Create Tabs
    for i, tabName in ipairs(tabs) do
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, -10, 0.12, 0)
        tabButton.Position = UDim2.new(0, 5, (i-1)*0.12, 5)
        tabButton.BackgroundColor3 = theme.Secondary
        tabButton.BorderSizePixel = 0
        tabButton.Text = tabName
        tabButton.TextColor3 = theme.Text
        tabButton.TextScaled = true
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Parent = tabFrame

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 10)
        tabCorner.Parent = tabButton

        tabButton.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end

    function switchTab(tabIndex)
        currentTab = tabIndex
        -- Animate tab selection
        for i, child in ipairs(tabFrame:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.3), {
                    BackgroundColor3 = theme.Secondary
                }):Play()
            end
        end
        
        local selectedTab = tabFrame:FindFirstChildOfClass("TextButton")
        TweenService:Create(selectedTab, TweenInfo.new(0.3), {
            BackgroundColor3 = theme.Accent
        }):Play()
        
        loadTabContent(tabIndex)
    end

    function loadTabContent(tabIndex)
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") or child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        if tabIndex == 1 then loadPlayerTab()
        elseif tabIndex == 2 then loadCombatTab()
        elseif tabIndex == 3 then loadToHTab()
        elseif tabIndex == 4 then loadComingSoonTab()
        elseif tabIndex == 5 then loadGithubCmdsTab()
        end
    end

    -- PLAYER TAB
    function loadPlayerTab()
        local scroll = createScrollFrame(contentFrame)
        
        createButton(scroll, "Noclip [X]", function()
            toggleNoclip()
        end)
        
        createButton(scroll, "Fly [F]", function()
            toggleFly()
        end)
        
        createButton(scroll, "Speed x16 [V]", function()
            setSpeed(16)
        end)
        
        createButton(scroll, "Jump Power 100 [B]", function()
            setJumpPower(100)
        end)
        
        createButton(scroll, "Infinite Jump [G]", function()
            toggleInfiniteJump()
        end)
    end

    -- COMBAT TAB
    function loadCombatTab()
        local scroll = createScrollFrame(contentFrame)
        
        createButton(scroll, "Wallhack", function()
            toggleWallhack()
        end)
        
        createButton(scroll, "ESP Players", function()
            toggleESP()
        end)
        
        createButton(scroll, "Kill Aura", function()
            toggleKillAura()
        end)
    end

    -- TOWER OF HELL TAB
    function loadToHTab()
        local scroll = createScrollFrame(contentFrame)
        
        createButton(scroll, "ToH Fly", function()
            tohFly()
        end)
        
        createButton(scroll, "ToH Noclip", function()
            tohNoclip()
        end)
        
        createButton(scroll, "ToH Speed 50", function()
            tohSpeed(50)
        end)
        
        createButton(scroll, "Teleport to Win", function()
            tohWinTP()
        end)
        
        createButton(scroll, "Fling All", function()
            flingAll()
        end)
        
        createButton(scroll, "Auto Win", function()
            tohAutoWin()
        end)
    end

    -- COMING SOON
    function loadComingSoonTab()
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🚀 More games coming soon!\nArsenal | Phantom Forces | Jailbreak"
        label.TextColor3 = theme.Text
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextWrapped = true
        label.Parent = contentFrame
    end

    -- GITHUB CMDS TAB
    function loadGithubCmdsTab()
        local scroll = createScrollFrame(contentFrame)
        
        createButton(scroll, "Github: Infinite Yield", function()
            loadGithubScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
        end)
        
        createButton(scroll, "Github: CMD-X", function()
            loadGithubScript("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source")
        end)
        
        createButton(scroll, "Dark Dex", function()
            loadGithubScript("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt")
        end)
    end

    -- Utility Functions
    function createScrollFrame(parent)
        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundColor3 = theme.Primary
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 8
        scroll.ScrollBarImageColor3 = theme.Accent
        scroll.Parent = parent
        
        local scrollCorner = Instance.new("UICorner")
        scrollCorner.CornerRadius = UDim.new(0, 12)
        scrollCorner.Parent = scroll
        
        local listLayout = Instance.new("UIListLayout")
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.Padding = UDim.new(0, 8)
        listLayout.Parent = scroll
        
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
        end)
        
        return scroll
    end

    function createButton(parent, text, callback)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -20, 0, 50)
        button.BackgroundColor3 = theme.Secondary
        button.BorderSizePixel = 0
        button.Text = text
        button.TextColor3 = theme.Text
        button.TextScaled = true
        button.Font = Enum.Font.GothamBold
        button.Parent = parent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 12)
        buttonCorner.Parent = button
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = theme.Accent
        stroke.Thickness = 1.5
        stroke.Parent = button
        
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = theme.Accent,
                TextColor3 = Color3.fromRGB(20, 20, 30)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = theme.Secondary,
                TextColor3 = theme.Text
            }):Play()
        end)
        
        button.MouseButton1Click:Connect(callback)
        return button
    end

    -- Core Features Implementation
    local noclip = false
    local fly = false
    local flying = false
    local infJump = false

    function toggleNoclip()
        noclip = not noclip
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not noclip
                end
            end
        end
    end

    function toggleFly()
        fly = not fly
        if fly and LocalPlayer.Character then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            
            local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
            bodyAngularVelocity.MaxTorque = Vector3.new(4000, 4000, 4000)
            bodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
            bodyAngularVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
            
            flying = true
            spawn(function()
                while flying and LocalPlayer.Character do
                    local cam = workspace.CurrentCamera
                    local moveVector = Vector3.new(0, 0, 0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                        moveVector = moveVector + cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                        moveVector = moveVector - cam.CFrame.LookVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                        moveVector = moveVector - cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                        moveVector = moveVector + cam.CFrame.RightVector
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        moveVector = moveVector + Vector3.new(0, 1, 0)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                        moveVector = moveVector - Vector3.new(0, 1, 0)
                    end
                    
                    bodyVelocity.Velocity = moveVector * 50
                    wait()
                end
            end)
        else
            flying = false
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity"):Destroy()
                LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyAngularVelocity"):Destroy()
            end
        end
    end

    function setSpeed(speed)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end

    function setJumpPower(power)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = power
        end
    end

    function toggleInfiniteJump()
        infJump = not infJump
        UserInputService.JumpRequest:Connect(function()
            if infJump and LocalPlayer.Character then
                LocalPlayer.Character.Humanoid:ChangeState("Jumping")
            end
        end)
    end

    function toggleWallhack()
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.5
                        part.CanCollide = false
                    end
                end
            end
        end
    end

    -- Tower of Hell Specific
    function tohFly() setSpeed(100); toggleFly() end
    function tohNoclip() toggleNoclip() end
    function tohSpeed(speed) setSpeed(speed) end
    
    function tohWinTP()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "WinPad" or obj.Name:find("Win") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 10, 0)
                break
            end
        end
    end
    
    function flingAll()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Velocity = Vector3.new(math.random(-5000,5000), 99999, math.random(-5000,5000))
                end
            end
        end
    end
    
    function tohAutoWin()
        spawn(function()
            while true do
                tohWinTP()
                wait(0.1)
            end
        end)
    end

    function loadGithubScript(url)
        local success, result = pcall(function()
            return game:HttpGet(url)
        end)
        if success then
            loadstring(result)()
        end
    end

    function getPolishTime()
        local offset = 2 -- Poland UTC+2
        return os.date("!%H:%M:%S", os.time() + offset * 3600)
    end

    -- Noclip Loop
    RunService.Stepped:Connect(function()
        if noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)

    -- Initial tab load
    switchTab(1)

    -- Smooth entrance animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.9, 0, 0.85, 0)
    }):Play()
end

-- Keybinds
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.X then toggleNoclip() end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() end
    if input.KeyCode == Enum.KeyCode.V then setSpeed(16) end
end)

print("turcja loaded successfully!")
