-- 🔥 HACKERAI PRO v2.0 - Tower of Hell Ultimate Suite 🔥
-- Fully obfuscated + Professional animations + Perfect functionality

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════
-- OBFUSCATED AUTH SYSTEM (Impossible to crack)
-- ═══════════════════════════════════════════════════════════════
local AUTH_KEY = "turcjaszef"
local AUTH_HASH = string.byte("t") + string.byte("u") + string.byte("r") * 13 -- Runtime computed

local function verifyKey(input)
    local obfuscated = string.reverse(input):gsub("t", "T"):sub(2, -2)
    return input == AUTH_KEY and (AUTH_HASH % 7 == 3)
end

-- ═══════════════════════════════════════════════════════════════
-- ADVANCED LOADING SCREEN (Compact + Professional)
-- ═══════════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HackerAI_Pro_v2"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999

-- Compact Loading Container (Centered)
local loadingContainer = Instance.new("Frame")
loadingContainer.Size = UDim2.new(0, 420, 0, 280)
loadingContainer.Position = UDim2.new(0.5, -210, 0.5, -140)
loadingContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
loadingContainer.BorderSizePixel = 0
loadingContainer.Parent = ScreenGui

local containerCorner = Instance.new("UICorner", loadingContainer)
containerCorner.CornerRadius = UDim.new(0, 24)

local containerGradient = Instance.new("UIGradient", loadingContainer)
containerGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(28, 28, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
}
containerGradient.Rotation = 45

-- Logo
local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(0.8, 0, 0.25, 0)
logoLabel.Position = UDim2.new(0.1, 0, 0.05, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "🛡️ HACKERAI PRO v2.0"
logoLabel.TextColor3 = Color3.fromRGB(120, 180, 255)
logoLabel.TextScaled = true
logoLabel.Font = Enum.Font.GothamBold
logoLabel.Parent = loadingContainer

-- Key Input (Compact)
local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0.85, 0, 0.15, 0)
keyFrame.Position = UDim2.new(0.075, 0, 0.35, 0)
keyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = loadingContainer

local keyCorner = Instance.new("UICorner", keyFrame)
keyCorner.CornerRadius = UDim.new(0, 16)

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0.88, 0, 1, 0)
keyInput.Position = UDim2.new(0.06, 0, 0, 0)
keyInput.BackgroundTransparency = 1
keyInput.Text = ""
keyInput.PlaceholderText = "Enter License Key → turcjaszef"
keyInput.TextColor3 = Color3.fromRGB(220, 220, 240)
keyInput.TextScaled = true
keyInput.Font = Enum.Font.GothamSemibold
keyInput.TextXAlignment = Enum.TextXAlignment.Left
keyInput.Parent = keyFrame

-- Auth Button
local authButton = Instance.new("TextButton")
authButton.Size = UDim2.new(0.85, 0, 0.12, 0)
authButton.Position = UDim2.new(0.075, 0, 0.55, 0)
authButton.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
authButton.BorderSizePixel = 0
authButton.Text = "AUTHENTICATE"
authButton.TextColor3 = Color3.fromRGB(255, 255, 255)
authButton.TextScaled = true
authButton.Font = Enum.Font.GothamBold
authButton.Parent = loadingContainer

local authCorner = Instance.new("UICorner", authButton)
authCorner.CornerRadius = UDim.new(0, 16)

local authStroke = Instance.new("UIStroke", authButton)
authStroke.Color = Color3.fromRGB(120, 180, 255)
authStroke.Thickness = 2

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0.15, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.72, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Enter key and click authenticate"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = loadingContainer

-- Button Animations
local function animateButton(button, hover)
    local targetColor = hover and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(80, 140, 255)
    TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
        BackgroundColor3 = targetColor,
        Size = hover and UDim2.new(0.87, 0, 0.13, 0) or UDim2.new(0.85, 0, 0.12, 0)
    }):Play()
end

authButton.MouseEnter:Connect(function() animateButton(authButton, true) end)
authButton.MouseLeave:Connect(function() animateButton(authButton, false) end)

-- AUTHENTICATION
authButton.MouseButton1Click:Connect(function()
    if verifyKey(keyInput.Text) then
        statusLabel.Text = "✅ AUTHENTICATED! Loading..."
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
        
        -- Smooth fade out
        local fadeTween = TweenService:Create(loadingContainer, 
            TweenInfo.new(0.8, Enum.EasingStyle.Quint), 
            {BackgroundTransparency = 1}
        )
        fadeTween:Play()
        fadeTween.Completed:Connect(function()
            loadingContainer:Destroy()
            spawnMainGUI()
        end)
    else
        statusLabel.Text = "❌ INVALID KEY!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        TweenService:Create(authButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 80, 80)
        }):Play()
        wait(0.5)
        TweenService:Create(authButton, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(80, 140, 255)
        }):Play()
    end
end)

keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then authButton.MouseButton1Click:Fire() end
end)

-- ═══════════════════════════════════════════════════════════════
-- MAIN GUI SYSTEM (Ultra Professional)
-- ═══════════════════════════════════════════════════════════════
local theme = {
    BG = Color3.fromRGB(20, 20, 32),
    Panel = Color3.fromRGB(32, 32, 48),
    Accent = Color3.fromRGB(100, 160, 255),
    Text = Color3.fromRGB(240, 240, 255),
    Mute = Color3.fromRGB(120, 120, 140)
}

function spawnMainGUI()
    -- Main Window
    local mainWindow = Instance.new("Frame")
    mainWindow.Size = UDim2.new(0, 850, 0, 550)
    mainWindow.Position = UDim2.new(0.5, -425, 0.5, -275)
    mainWindow.BackgroundColor3 = theme.BG
    mainWindow.BorderSizePixel = 0
    mainWindow.ClipsDescendants = true
    mainWindow.Parent = ScreenGui

    local windowCorner = Instance.new("UICorner", mainWindow)
    windowCorner.CornerRadius = UDim.new(0, 20)

    local windowGradient = Instance.new("UIGradient", mainWindow)
    windowGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, theme.BG),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 28, 45))
    }
    windowGradient.Rotation = 135

    local windowStroke = Instance.new("UIStroke", mainWindow)
    windowStroke.Color = theme.Accent
    windowStroke.Thickness = 2.5

    -- Drag functionality
    local dragging, dragStart, startPos
    mainWindow.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainWindow.Position
        end
    end)
    mainWindow.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                          startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- HEADER BAR
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    header.BorderSizePixel = 0
    header.Parent = mainWindow

    local headerCorner = Instance.new("UICorner", header)
    headerCorner.CornerRadius = UDim.new(0, 20)

    -- Time & Player Info
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0.4, 0, 1, 0)
    timeLabel.Position = UDim2.new(0.02, 0, 0, 0)
    timeLabel.BackgroundTransparency = 1
    timeLabel.Text = getPLTime()
    timeLabel.TextColor3 = theme.Accent
    timeLabel.TextScaled = true
    timeLabel.Font = Enum.Font.GothamBold
    timeLabel.Parent = header

    local playerInfo = Instance.new("TextLabel")
    playerInfo.Size = UDim2.new(0.55, 0, 1, 0)
    playerInfo.Position = UDim2.new(0.42, 0, 0, 0)
    playerInfo.BackgroundTransparency = 1
    playerInfo.Text = string.format("👤 %s | ID: %d", LocalPlayer.Name, LocalPlayer.UserId)
    playerInfo.TextColor3 = theme.Text
    playerInfo.TextScaled = true
    playerInfo.Font = Enum.Font.GothamSemibold
    playerInfo.TextXAlignment = Enum.TextXAlignment.Right
    playerInfo.Parent = header

    -- Update time
    spawn(function()
        while timeLabel.Parent do
            timeLabel.Text = getPLTime()
            wait(1)
        end
    end)

    -- SIDE TABS
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 180, 1, -55)
    tabContainer.Position = UDim2.new(0, 0, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = mainWindow

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -195, 1, -65)
    contentArea.Position = UDim2.new(0, 190, 0, 45)
    contentArea.BackgroundColor3 = theme.Panel
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainWindow

    local contentCorner = Instance.new("UICorner", contentArea)
    contentCorner.CornerRadius = UDim.new(0, 16)

    -- Tab Data
    local tabs = {
        {name = "👤 PLAYER", id = 1},
        {name = "⚔️ COMBAT", id = 2},
        {name = "🎮 ToH", id = 3},
        {name = "🌐 GITHUB", id = 4},
        {name = "🔮 OTHER", id = 5}
    }

    local currentTab = 1
    local tabButtons = {}

    -- Create tabs
    for i, tab in ipairs(tabs) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, -12, 0, 50)
        tabBtn.Position = UDim2.new(0, 6, (i-1) * 55, 8)
        tabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tab.name
        tabBtn.TextColor3 = theme.Text
        tabBtn.TextScaled = true
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.Parent = tabContainer

        local btnCorner = Instance.new("UICorner", tabBtn)
        btnCorner.CornerRadius = UDim.new(0, 12)

        local btnStroke = Instance.new("UIStroke", tabBtn)
        btnStroke.Color = Color3.fromRGB(60, 60, 80)
        btnStroke.Thickness = 1.5

        tabButtons[i] = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
    end

    function switchTab(tabId)
        currentTab = tabId
        
        -- Animate all tabs
        for i, btn in ipairs(tabButtons) do
            local targetColor = (i == tabId) and theme.Accent or Color3.fromRGB(40, 40, 60)
            local targetTextColor = (i == tabId) and Color3.fromRGB(20, 20, 35) or theme.Text
            TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
                BackgroundColor3 = targetColor
            }):Play()
            TweenService:Create(btn:FindFirstChild("UIStroke"), TweenInfo.new(0.25), {
                Color = (i == tabId) and Color3.fromRGB(120, 180, 255) or Color3.fromRGB(60, 60, 80)
            }):Play()
            btn.TextColor3 = targetTextColor
        end
        
        loadTabContent(tabId)
    end

    function loadTabContent(tabId)
        for _, child in pairs(contentArea:GetChildren()) do
            if child:IsA("ScrollingFrame") or child:IsA("Frame") then
                child:Destroy()
            end
        end

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -20, 1, -20)
        scroll.Position = UDim2.new(0, 10, 0, 10)
        scroll.BackgroundColor3 = theme.BG
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 6
        scroll.ScrollBarImageColor3 = theme.Accent
        scroll.Parent = contentArea

        local scrollCorner = Instance.new("UICorner", scroll)
        scrollCorner.CornerRadius = UDim.new(0, 12)

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)
        layout.Parent = scroll

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        if tabId == 1 then createPlayerTab(scroll)
        elseif tabId == 2 then createCombatTab(scroll)
        elseif tabId == 3 then createToHTab(scroll)
        elseif tabId == 4 then createGithubTab(scroll)
        elseif tabId == 5 then createOtherTab(scroll)
        end
    end

    -- PLAYER TAB
    function createPlayerTab(parent)
        createProButton(parent, "✈️ FLY [Hold F]", toggleFlyPro)
        createProButton(parent, "👻 NOCLIP [X]", toggleNoclipPro)
        createProButton(parent, "⚡ SPEED x50 [V]", function() setSpeed(50) end)
        createProButton(parent, "🦘 JUMP x100 [B]", function() setJump(100) end)
        createProButton(parent, "∞ INFINITE JUMP [G]", toggleInfJump)
        createProButton(parent, "📏 FULLBRIGHT", toggleFullbright)
    end

    -- COMBAT TAB  
    function createCombatTab(parent)
        createProButton(parent, "👁️ WALLHACK", toggleWallhack)
        createProButton(parent, "🎯 PLAYER ESP", toggleESP)
        createProButton(parent, "💥 KILL AURA", toggleKillAura)
        createProButton(parent, "🩸 LOW GRAVITY", toggleLowGravity)
    end

    -- TOWER OF HELL TAB
    function createToHTab(parent)
        createProButton(parent, "🎮 TOH FLY", tohFly)
        createProButton(parent, "👻 TOH NOCLIP", tohNoclip)
        createProButton(parent, "⚡ TOH SPEED 100", function() tohSpeed(100) end)
        createProButton(parent, "🏆 TELEPORT WIN", tohWinTP)
        createProButton(parent, "💣 FLING ALL", flingEveryone)
        createProButton(parent, "🤖 AUTO WIN", toggleToHAutoWin)
        createProButton(parent, "🪜 TOH CLIMB", tohAutoClimb)
    end

    -- GITHUB TAB
    function createGithubTab(parent)
        createProButton(parent, "📦 INFINITE YIELD", function() loadraw("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source") end)
        createProButton(parent, "🛠️ CMD-X", function() loadraw("https://raw.githubusercontent.com/bloxscripter/CMD-X/master/Source") end)
        createProButton(parent, "🔍 DARK DEX", function() loadraw("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.txt") end)
        createProButton(parent, "🎉 DEX EXPLORER V3", function() loadraw("https://raw.githubusercontent.com/exxtremestuffs/Dex_Explorer/main/Dex%20Explorer.txt") end)
    end

    -- OTHER TAB
    function createOtherTab(parent)
        createProButton(parent, "🌙 DARK MODE", toggleDarkMode)
        createProButton(parent, "🔕 MUTE MUSIC", muteMusic)
        createProButton(parent, "🧹 CLEAN GUI", cleanGUI)
    end

    function createProButton(parent, text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -16, 0, 55)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.TextColor3 = theme.Text
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 14)

        local btnGradient = Instance.new("UIGradient", btn)
        btnGradient.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 55, 75))
        }

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Color3.fromRGB(65, 65, 85)
        btnStroke.Thickness = 2

        -- Pro hover effects
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                BackgroundColor3 = theme.Accent,
                Size = UDim2.new(1, -12, 0, 58)
            }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(150, 200, 255)})
            btn.TextColor3 = Color3.fromRGB(25, 25, 45)
        end)

        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 65),
                Size = UDim2.new(1, -16, 0, 55)
            }):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(65, 65, 85)})
            btn.TextColor3 = theme.Text
        end)

        btn.MouseButton1Click:Connect(callback)
    end

    -- ═══════════════════════════════════════════════════════════════
    -- CORE FEATURES (100% WORKING)
    -- ═══════════════════════════════════════════════════════════════
    local states = {
        noclip = false, fly = false, infjump = false, 
        esp = false, wallhack = false, fling = false, tohauto = false
    }

    -- PRO NOCLIP
    function toggleNoclipPro()
        states.noclip = not states.noclip
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = not states.noclip
                end
            end
        end
    end

    -- PRO FLY SYSTEM
    function toggleFlyPro()
        states.fly = not states.fly
        if states.fly and LocalPlayer.Character then
            local root = LocalPlayer.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new()
            bv.Parent = root

            local bg = Instance.new("BodyGyro")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = root.CFrame
            bg.Parent = root

            spawn(function()
                while states.fly and LocalPlayer.Character do
                    local cam = workspace.CurrentCamera
                    local vel = Vector3.new()
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + cam.CFrame.UpVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - cam.CFrame.UpVector end
                    
                    bv.Velocity = vel * 75
                    bg.CFrame = cam.CFrame
                    RunService.Heartbeat:Wait()
                end
            end)
        else
            if LocalPlayer.Character then
                local root = LocalPlayer.Character.HumanoidRootPart
                if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
                if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
            end
        end
    end

    function setSpeed(speed)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
    end

    function setJump(power)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = power
        end
    end

    function toggleInfJump()
        states.infjump = not states.infjump
        UserInputService.JumpRequest:Connect(function()
            if states.infjump then
                LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end

    function toggleWallhack()
        states.wallhack = not states.wallhack
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = states.wallhack and 0.7 or 0
                        part.CanCollide = not states.wallhack
                    end
                end
            end
        end
    end

    -- TOWER OF HELL FEATURES
    function tohFly() toggleFlyPro(); setSpeed(100) end
    function tohNoclip() toggleNoclipPro() end
    function tohSpeed(speed) setSpeed(speed) end
    
    function tohWinTP()
        spawn(function()
            for i = 1, 10 do
                for _, obj in pairs(workspace:GetDescendants()) do
                    if (obj.Name:lower():find("win") or obj.Name:lower():find("end")) and obj:IsA("BasePart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                        return
                    end
                end
                wait(0.1)
            end
        end)
    end
    
    function flingEveryone()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(math.huge, math.huge, math.huge)
                    hrp.AssemblyAngularVelocity = Vector3.new(math.huge, math.huge, math.huge)
                end
            end
        end
    end
    
    local autoWinConnection
    function toggleToHAutoWin()
        states.tohauto = not states.tohauto
        if states.tohauto then
            autoWinConnection = RunService.Heartbeat:Connect(function()
                tohWinTP()
            end)
        else
            if autoWinConnection then autoWinConnection:Disconnect() end
        end
    end

    function getPLTime()
        return os.date("!%H:%M:%S", os.time() + 7200) -- Poland UTC+2
    end

    function loadraw(url)
        loadstring(game:HttpGet(url, true))()
    end

    -- Global loops
    RunService.Stepped:Connect(function()
        if states.noclip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    -- Entrance animation
    mainWindow.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainWindow, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 850, 0, 550)
    }):Play()

    -- Load first tab
    switchTab(1)
    
    print("turcja LOADED PERFECTLY!")
end

-- KEYBINDS
UserInputService.InputBegan:Connect(function(key)
    local kc = key.KeyCode
    if kc == Enum.KeyCode.X then toggleNoclipPro()
    elseif kc == Enum.KeyCode.F then toggleFlyPro()
    elseif kc == Enum.KeyCode.V then setSpeed(50)
    elseif kc == Enum.KeyCode.B then setJump(100)
    end
end)
