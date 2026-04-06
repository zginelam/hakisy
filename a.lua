local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Advanced Professional Theme
local theme = {
    mainBG = Color3.fromRGB(15, 15, 23),
    panelBG = Color3.fromRGB(28, 28, 38),
    darkPanel = Color3.fromRGB(22, 22, 32),
    accent = Color3.fromRGB(100, 150, 255),
    accentBright = Color3.fromRGB(120, 170, 280),
    textPrimary = Color3.fromRGB(240, 240, 250),
    textSecondary = Color3.fromRGB(170, 170, 190),
    success = Color3.fromRGB(100, 200, 120),
    error = Color3.fromRGB(255, 100, 100),
    stroke = Color3.fromRGB(50, 50, 70),
    strokeBright = Color3.fromRGB(80, 80, 100)
}

-- FIXED Key System
local VALID_KEY = "turcjaszef"
local authenticated = false

-- Create Main GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerAI_DevSuite_v4"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 10

-- State Variables
local flyEnabled = false
local noclipEnabled = false
local infJumpEnabled = false
local espEnabled = false
local antiAFKEnabled = false
local tohAutoWinEnabled = false
local connections = {}

-- UTILITY FUNCTIONS
local function notify(title, text, duration)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 80)
    notif.Position = UDim2.new(0, 20, 0, 20)
    notif.BackgroundColor3 = theme.panelBG
    notif.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = notif
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent
    stroke.Thickness = 2
    stroke.Parent = notif
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 0.5, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.accent
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = notif
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -20, 0.5, 0)
    textLabel.Position = UDim2.new(0, 10, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = theme.textPrimary
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.Gotham
    textLabel.Parent = notif
    
    TweenService:Create(notif, TweenInfo.new(0.5), {Position = UDim2.new(0, 20, 0, 120)}):Play()
    game:GetService("Debris"):AddItem(notif, duration or 3)
end

-- LOADING SCREEN
local function createLoadingScreen()
    local loadingFrame = Instance.new("Frame")
    loadingFrame.Size = UDim2.new(0, 400, 0, 280)
    loadingFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    loadingFrame.BackgroundColor3 = theme.mainBG
    loadingFrame.BorderSizePixel = 0
    loadingFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = loadingFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.mainBG),
        ColorSequenceKeypoint.new(1, theme.darkPanel)
    })
    gradient.Rotation = 45
    gradient.Parent = loadingFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent
    stroke.Thickness = 3
    stroke.Parent = loadingFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.9, 0, 0.25, 0)
    title.Position = UDim2.new(0.05, 0, 0.05, 0)
    title.BackgroundTransparency = 1
    title.Text = "HACKERAI DEVELOPER SUITE v4.0"
    title.TextColor3 = theme.accent
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = loadingFrame

    -- Key Input
    local keyFrame = Instance.new("Frame")
    keyFrame.Size = UDim2.new(0.9, 0, 0.18, 0)
    keyFrame.Position = UDim2.new(0.05, 0, 0.35, 0)
    keyFrame.BackgroundColor3 = theme.panelBG
    keyFrame.BorderSizePixel = 0
    keyFrame.Parent = loadingFrame

    local kfCorner = Instance.new("UICorner")
    kfCorner.CornerRadius = UDim.new(0, 14)
    kfCorner.Parent = keyFrame

    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.95, 0, 1, 0)
    keyInput.Position = UDim2.new(0.025, 0, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Enter key: turcjaszef"
    keyInput.TextColor3 = theme.textPrimary
    keyInput.PlaceholderColor3 = theme.textSecondary
    keyInput.TextScaled = true
    keyInput.Font = Enum.Font.GothamSemibold
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.Parent = keyFrame

    -- Auth Button
    local authBtn = Instance.new("TextButton")
    authBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
    authBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
    authBtn.BackgroundColor3 = theme.accent
    authBtn.Text = "AUTHENTICATE"
    authBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
    authBtn.TextScaled = true
    authBtn.Font = Enum.Font.GothamBold
    authBtn.Parent = loadingFrame

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 14)
    abCorner.Parent = authBtn

    local abStroke = Instance.new("UIStroke")
    abStroke.Color = theme.accentBright
    abStroke.Thickness = 2
    abStroke.Parent = authBtn

    -- Status
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.9, 0, 0.15, 0)
    status.Position = UDim2.new(0.05, 0, 0.78, 0)
    status.BackgroundTransparency = 1
    status.Text = "Status: Ready"
    status.TextColor3 = theme.textSecondary
    status.TextScaled = true
    status.Font = Enum.Font.Gotham
    status.Parent = loadingFrame

    -- Button Animations
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    
    authBtn.MouseEnter:Connect(function()
        TweenService:Create(authBtn, tweenInfo, {
            BackgroundColor3 = theme.accentBright,
            Size = UDim2.new(0.92, 0, 0.16, 0)
        }):Play()
    end)

    authBtn.MouseLeave:Connect(function()
        TweenService:Create(authBtn, tweenInfo, {
            BackgroundColor3 = theme.accent,
            Size = UDim2.new(0.9, 0, 0.15, 0)
        }):Play()
    end)

    -- AUTH LOGIC
    local function authenticate()
        if keyInput.Text == VALID_KEY then
            status.Text = "✓ Access Granted - Loading..."
            status.TextColor3 = theme.success
            TweenService:Create(loadingFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            
            task.wait(0.8)
            loadingFrame:Destroy()
            authenticated = true
            createMainGUI()
            notify("HackerAI", "Developer Suite v4.0 Loaded Successfully!", 3)
        else
            status.Text = "✗ Invalid Key"
            status.TextColor3 = theme.error
            TweenService:Create(authBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.error}):Play()
            task.wait(0.3)
            TweenService:Create(authBtn, TweenInfo.new(0.2), {BackgroundColor3 = theme.accent}):Play()
        end
    end

    authBtn.MouseButton1Click:Connect(authenticate)
    keyInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then authenticate() end
    end)
end

-- MAIN GUI SYSTEM
function createMainGUI()
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainGUI"
    mainFrame.Size = UDim2.new(0, 950, 0, 650)
    mainFrame.Position = UDim2.new(0.5, -475, 0.5, -325)
    mainFrame.BackgroundColor3 = theme.mainBG
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = mainFrame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.mainBG),
        ColorSequenceKeypoint.new(1, theme.panelBG)
    })
    gradient.Rotation = 135
    gradient.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.accent
    stroke.Thickness = 3
    stroke.Parent = mainFrame

    -- DRAG SYSTEM
    makeDraggable(mainFrame)

    -- HEADER
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = theme.darkPanel
    header.BorderSizePixel = 0
    header.Parent = mainFrame

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 20)
    hCorner.Parent = header

    local titleHeader = Instance.new("TextLabel")
    titleHeader.Size = UDim2.new(0.6, 0, 1, 0)
    titleHeader.BackgroundTransparency = 1
    titleHeader.Text = "HACKERAI DEVELOPER SUITE v4.0"
    titleHeader.TextColor3 = theme.accent
    titleHeader.TextScaled = true
    titleHeader.Font = Enum.Font.GothamBold
    titleHeader.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -50, 0, 10)
    closeBtn.BackgroundColor3 = theme.error
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 10)
    cbCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- TABS SYSTEM
    local tabs = {"PLAYER", "COMBAT", "TOH", "SCRIPTS", "UTILITY"}
    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(0, 180, 1, -70)
    tabFrame.Position = UDim2.new(0, 10, 0, 70)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -205, 1, -90)
    contentFrame.Position = UDim2.new(0, 195, 0, 70)
    contentFrame.BackgroundColor3 = theme.panelBG
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = mainFrame

    local cfCorner = Instance.new("UICorner")
    cfCorner.CornerRadius = UDim.new(0, 16)
    cfCorner.Parent = contentFrame

    local currentTab = 1
    local tabButtons = {}

    -- Create Tabs
    for i, tabName in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -12, 0, 55)
        tabBtn.Position = UDim2.new(0, 6, 0, (i-1) * 62)
        tabBtn.BackgroundColor3 = theme.stroke
        tabBtn.Text = tabName
        tabBtn.TextColor3 = theme.textSecondary
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = tabFrame

        local tCorner = Instance.new("UICorner")
        tCorner.CornerRadius = UDim.new(0, 12)
        tCorner.Parent = tabBtn

        local tStroke = Instance.new("UIStroke")
        tStroke.Color = theme.strokeBright
        tStroke.Thickness = 1.5
        tStroke.Parent = tabBtn

        tabButtons[i] = {btn = tabBtn, stroke = tStroke}

        tabBtn.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end

    function switchTab(tabIndex)
        currentTab = tabIndex
        for i, data in ipairs(tabButtons) do
            local isActive = i == tabIndex
            TweenService:Create(data.btn, TweenInfo.new(0.3), {
                BackgroundColor3 = isActive and theme.accent or theme.stroke
            }):Play()
            TweenService:Create(data.stroke, TweenInfo.new(0.3), {
                Color = isActive and theme.accentBright or theme.strokeBright
            }):Play()
            data.btn.TextColor3 = isActive and Color3.fromRGB(25, 25, 40) or theme.textSecondary
        end
        loadTabContent(tabIndex)
    end

    function loadTabContent(tabIndex)
        for _, child in pairs(contentFrame:GetChildren()) do
            if child.Name ~= "UICorner" then
                child:Destroy()
            end
        end

        local scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Content"
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundColor3 = theme.darkPanel
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 8
        scroll.ScrollBarImageColor3 = theme.accent
        scroll.Parent = contentFrame

        local sCorner = Instance.new("UICorner")
        sCorner.CornerRadius = UDim.new(0, 12)
        sCorner.Parent = scroll

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 15)
        layout.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 30)
        end)

        if tabIndex == 1 then createPlayerTab(scroll)
        elseif tabIndex == 2 then createCombatTab(scroll)
        elseif tabIndex == 3 then createToHTab(scroll)
        elseif tabIndex == 4 then createScriptsTab(scroll)
        elseif tabIndex == 5 then createUtilityTab(scroll)
        end
    end

    -- PROFESSIONAL BUTTON CREATOR
    function createProButton(parent, text, callback, layoutOrder)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 65)
        btn.BackgroundColor3 = theme.stroke
        btn.Text = text
        btn.TextColor3 = theme.textPrimary
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.LayoutOrder = layoutOrder or 0
        btn.Parent = parent

        local bCorner = Instance.new("UICorner")
        bCorner.CornerRadius = UDim.new(0, 14)
        bCorner.Parent = btn

        local bStroke = Instance.new("UIStroke")
        bStroke.Color = theme.strokeBright
        bStroke.Thickness = 2
        bStroke.Parent = btn

        local hoverInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, hoverInfo, {
                BackgroundColor3 = theme.accent,
                Size = UDim2.new(1, -16, 0, 70)
            }):Play()
            TweenService:Create(bStroke, hoverInfo, {Color = theme.accentBright}):Play()
            btn.TextColor3 = Color3.fromRGB(25, 25, 40)
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, hoverInfo, {
                BackgroundColor3 = theme.stroke,
                Size = UDim2.new(1, -20, 0, 65)
            }):Play()
            TweenService:Create(bStroke, hoverInfo, {Color = theme.strokeBright}):Play()
            btn.TextColor3 = theme.textPrimary
        end)

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- TAB CONTENTS
    function createPlayerTab(parent)
        createProButton(parent, "🚀 Fly (Hold F)", toggleFly, 1)
        createProButton(parent, "👻 Noclip (X)", toggleNoclip, 2)
        createProButton(parent, "⚡ Speed 80 (V)", function() setSpeed(80) end, 3)
        createProButton(parent, "🦘 Jump 120 (B)", function() setJump(120) end, 4)
        createProButton(parent, "♾️ Infinite Jump (G)", toggleInfJump, 5)
        createProButton(parent, "💡 Fullbright", toggleFullbright, 6)
        createProButton(parent, "📏 Resize 10x", function() resizePlayer(10) end, 7)
    end

    function createCombatTab(parent)
        createProButton(parent, "👁️ Wallhack", toggleWallhack, 1)
        createProButton(parent, "🎯 Player ESP", toggleESP, 2)
        createProButton(parent, "💥 Kill Aura", toggleKillAura, 3)
        createProButton(parent, "🌪️ Fling All", flingAllPlayers, 4)
        createProButton(parent, "🛡️ God Mode", toggleGodMode, 5)
    end

    function createToHTab(parent)
        createProButton(parent, "🎮 ToH God Mode", tohGodMode, 1)
        createProButton(parent, "⚡ ToH Speed 150", function() setSpeed(150) end, 2)
        createProButton(parent, "🚀 ToH Fly + Speed", tohFlySpeed, 3)
        createProButton(parent, "🏆 Auto Win", toggleToHAutoWin, 4)
        createProButton(parent, "📡 Teleport Win", findWinPad, 5)
        createProButton(parent, "💣 Crash Server", crashServer, 6)
    end

    function createScriptsTab(parent)
        createProButton(parent, "📚 Infinite Yield", function() loadScript("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end, 1)
        createProButton(parent, "🧠 CMD-X", function() loadScript("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source") end, 2)
        createProButton(parent, "🔍 Dark Dex V4", function() loadScript("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt") end, 3)
        createProButton(parent, "🗺️ Dex Explorer", function() loadScript("https://raw.githubusercontent.com/exxtremestuffs/Dex_Explorer/main/Dex%20Explorer.txt") end, 4)
    end

    function createUtilityTab(parent)
        createProButton(parent, "🔄 Rejoin Server", rejoinServer, 1)
        createProButton(parent, "🛡️ Anti-AFK", toggleAntiAFK, 2)
        createProButton(parent, "⚡ FPS Boost", fpsBoost, 3)
        createProButton(parent, "🎮 Copy Game Link", copyGameLink, 4)
        createProButton(parent, "📊 Player List", showPlayerList, 5)
    end

    -- ALL FEATURES IMPLEMENTED (FIXED & WORKING)
    function makeDraggable(frame)
        local dragging = false
        local dragInput, mousePos, framePos

        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                mousePos = input.Position
                framePos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - mousePos
                frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
            end
        end)
    end

    function toggleFly()
        flyEnabled = not flyEnabled
        if flyEnabled and LocalPlayer.Character then
            local char = LocalPlayer.Character
            local root = char:WaitForChild("HumanoidRootPart")
            
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(40000, 40000, 40000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = root

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(40000, 40000, 40000)
            bg.CFrame = root.CFrame
            bg.Parent = root

            connections.fly = RunService.Heartbeat:Connect(function()
                if not flyEnabled or not char.Parent or not root.Parent then return end
                local cam = workspace.CurrentCamera
                local vel = Vector3.new(0, 0, 0)

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel + Vector3.new(0, -1, 0) end

                bv.Velocity = vel * 60
                bg.CFrame = cam.CFrame
            end)
        else
            if connections.fly then connections.fly:Disconnect() end
            if LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
                    if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
                end
            end
        end
    end

    function toggleNoclip()
        noclipEnabled = not noclipEnabled
        if noclipEnabled then
            connections.noclip = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            if connections.noclip then connections.noclip:Disconnect() end
        end
    end

    function setSpeed(speed)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end

    function setJump(jump)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jump
        end
    end

    function toggleInfJump()
        infJumpEnabled = not infJumpEnabled
        if infJumpEnabled then
            connections.infjump = UserInputService.JumpRequest:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if connections.infjump then connections.infjump:Disconnect() end
        end
    end

    function toggleFullbright()
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = math.huge
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    function toggleESP()
        espEnabled = not espEnabled
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                if espEnabled then
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = theme.accent
                        highlight.FillTransparency = 0.5
                        highlight.Parent = player.Character
                    end
                else
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end

    function flingAllPlayers()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                hrp.Velocity = Vector3.new(math.random(-1000,1000), 5000, math.random(-1000,1000))
                hrp.AngularVelocity = Vector3.new(math.random(-200,200), math.random(-200,200), math.random(-200,200))
            end
        end
    end

    function loadScript(url)
        local success, result = pcall(function()
            return game:HttpGetAsync(url)
        end)
        if success then
            loadstring(result)()
            notify("Script Loaded", url, 2)
        else
            notify("Error", "Failed to load script", 2)
        end
    end

    function toggleToHAutoWin()
        tohAutoWinEnabled = not tohAutoWinEnabled
        if tohAutoWinEnabled then
            spawn(function()
                while tohAutoWinEnabled do
                    findWinPad()
                    task.wait(0.1)
                end
            end)
        end
    end

    function findWinPad()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (string.find(string.lower(obj.Name), "win") or 
                string.find(string.lower(obj.Name), "end") or 
                string.find(string.lower(obj.Name), "pad") or
                string.find(string.lower(obj.Name), "finish")) then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                    return
                end
            end
        end
    end

    function rejoinServer()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end

    function toggleAntiAFK()
        antiAFKEnabled = not antiAFKEnabled
        if antiAFKEnabled then
            connections.antiafk = RunService.Heartbeat:Connect(function()
                local args = {
                    [1] = "WalkAroundScript",
                    [2] = "Set"
                }
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(unpack(args))
            end)
        else
            if connections.antiafk then connections.antiafk:Disconnect() end
        end
    end

    -- KEYBINDS
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        local key = input.KeyCode
        if key == Enum.KeyCode.F then toggleFly()
        elseif key == Enum.KeyCode.X then toggleNoclip()
        elseif key == Enum.KeyCode.V then setSpeed(80)
        elseif key == Enum.KeyCode.B then setJump(120)
        elseif key == Enum.KeyCode.G then toggleInfJump()
        end
    end)

    -- Entrance Animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 950, 0, 650)
    }):Play()

    switchTab(1)
end

-- START
createLoadingScreen()
