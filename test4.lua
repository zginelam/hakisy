--[[
    Tungtungsahur — ONLINE KEY SYSTEM
    Pobiera klucze z GitHub i sprawdza expiry date (czas polski UTC+1)
]]

local KeySystem = {
    KeyURL = "https://raw.githubusercontent.com/zginelam/hakisy/refs/heads/main/key3.txt",
    KeysCache = {},
    Authenticated = false,
    MaxAttempts = 3,
    Attempts = 0,
    LoadedKeysCount = 0,
}

-- Zaczekaj aż gra się załaduje
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Czekamy na gracza (jeśli jeszcze nie istnieje)
while not LocalPlayer do
    task.wait(1)
    LocalPlayer = Players.LocalPlayer
end

-- Funkcja do pobierania kluczy z GitHub
local function FetchKeysFromURL()
    local success, result = pcall(function()
        local request = syn and syn.request or request or http_request or (http and http.request)
        if not request then
            -- Fallback: użyj game:HttpGet
            local data = game:HttpGet(KeySystem.KeyURL)
            return data
        end
        
        local response = request({
            Url = KeySystem.KeyURL,
            Method = "GET",
        })
        
        if response and response.StatusCode == 200 then
            return response.Body
        end
        return nil
    end)
    
    if success and result then
        -- Parsujemy linie
        local lines = result:split("\n")
        local parsed = {}
        local count = 0
        
        for _, line in ipairs(lines) do
            local trimmed = line:gsub("^%s+", ""):gsub("%s+$", ""):gsub("\r", "")
            if trimmed and #trimmed > 0 then
                -- Format: klucz|expiry_date
                local key, expiry = trimmed:match("^([^|]+)|([^|]+)$")
                if key and expiry then
                    key = key:gsub("%s+", "")
                    expiry = expiry:gsub("%s+", "")
                    if #key > 0 and #expiry > 0 then
                        parsed[key] = expiry
                        count = count + 1
                    end
                end
            end
        end
        
        if count > 0 then
            KeySystem.KeysCache = parsed
            KeySystem.LoadedKeysCount = count
            return true
        end
    end
    
    return false
end

-- Funkcja do pobierania aktualnego czasu polskiego (UTC+1, zimą UTC+2 w lecie)
local function GetPolishTime()
    local success, result = pcall(function()
        -- Próbujemy przez HTTP API
        local request = syn and syn.request or request or http_request or (http and http.request)
        if request then
            local resp = request({
                Url = "https://worldtimeapi.org/api/timezone/Europe/Warsaw",
                Method = "GET",
            })
            if resp and resp.StatusCode == 200 then
                local data = HttpService:JSONDecode(resp.Body)
                if data and data.datetime then
                    -- Format: 2026-04-28T15:30:00.000000+02:00
                    local datePart = data.datetime:match("^(%d+-%d+-%d+)")
                    if datePart then
                        return datePart
                    end
                end
            end
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    
    -- Fallback: używamy czasu systemowego z przesunięciem UTC+1
    local osTime = os.time()
    local polishTime = osTime + 3600
    local dateTable = os.date("!%Y-%m-%d", polishTime)
    return dateTable
end

-- Sprawdza czy klucz jest ważny (nie wygasł)
local function IsKeyValid(key)
    local expiry = KeySystem.KeysCache[key]
    if not expiry then
        return false, "The key does not exist in the database!"
    end
    
    -- Klucz "never" = nigdy nie wygasa
    if expiry == "never" then
        return true, "Eternal Key - Authorization OK!"
    end
    
    -- Sprawdź czy expiry to poprawna data YYYY-MM-DD
    local expYear, expMonth, expDay = expiry:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not expYear then
        return false, "Invalid date format in key!"
    end
    
    -- Pobierz aktualną datę (czas polski)
    local currentDate = GetPolishTime()
    if not currentDate then
        return false, "Could not get current time! Check your connection."
    end
    
    local curYear, curMonth, curDay = currentDate:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not curYear then
        return false, "Invalid system date!"
    end
    
    -- Konwertuj na liczby
    expYear, expMonth, expDay = tonumber(expYear), tonumber(expMonth), tonumber(expDay)
    curYear, curMonth, curDay = tonumber(curYear), tonumber(curMonth), tonumber(curDay)
    
    -- Porównanie dat
    if expYear > curYear then
        return true, "Authorization successful!"
    elseif expYear < curYear then
        return false, "The key has expired! (expired: " .. expiry .. ")"
    end
    
    -- Ten sam rok
    if expMonth > curMonth then
        return true, "Authorization successful!"
    elseif expMonth < curMonth then
        return false, "The key has expired! (expired: " .. expiry .. ")"
    end
    
    -- Ten sam miesiąc
    if expDay >= curDay then
        return true, "Authorization successful!"
    else
        return false, "The key has expired! (expired: " .. expiry .. ")"
    end
end

-- Główna funkcja autoryzacji
local function Authenticate(inputKey)
    if not inputKey or inputKey == "" then
        return false, "The key cannot be empty!"
    end
    
    local cleanInput = tostring(inputKey):gsub("%s+", "")
    
    -- Sprawdź długość klucza (max 16 znaków)
    if #cleanInput > 16 then
        return false, "The key can have a maximum of 16 characters! (You entered " .. #cleanInput .. ")"
    end
    
    -- Szukamy klucza w cache
    return IsKeyValid(cleanInput)
end

-- ─── POBIERANIE KLUCZY ───────────────────────────────────────────────────────

print("[KEY SYSTEM] Downloading keys from server...")

local keysFetched = FetchKeysFromURL()

if keysFetched then
    print("[KEY SYSTEM] Downloaded " .. KeySystem.LoadedKeysCount .. " keys from the server.")
else
    print("[KEY SYSTEM] ERROR: Failed to download keys! Check URL or connection.")
    print("[KEY SYSTEM] URL: " .. KeySystem.KeyURL)
end

-- ─── INTERFEJS KEY SYSTEM ────────────────────────────────────────────────────

-- Czekaj aż PlayerGui będzie dostępny
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "tuntungsahur_KeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parent = CoreGui or playerGui
ScreenGui.Parent = parent

-- Tło
local Background = Instance.new("Frame")
Background.Size = UDim2.new(1, 0, 1, 0)
Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Background.BackgroundTransparency = 0.35
Background.Active = true
Background.Parent = ScreenGui

-- Główna ramka
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 360)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Niebieskie obramowanie
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 2, 1, 2)
Border.Position = UDim2.new(0, -1, 0, -1)
Border.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
Border.BackgroundTransparency = 0.4
Border.BorderSizePixel = 0
Border.Parent = MainFrame

-- Pasek górny
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 4)
TopBar.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Logo / Tytuł
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(1, -40, 0, 45)
Logo.Position = UDim2.new(0, 20, 0, 20)
Logo.BackgroundTransparency = 1
Logo.Text = "Tung Tung Sahur"
Logo.TextColor3 = Color3.fromRGB(0, 200, 255)
Logo.TextScaled = true
Logo.Font = Enum.Font.GothamBold
Logo.TextXAlignment = Enum.TextXAlignment.Left
Logo.Parent = MainFrame

-- Podtytuł
local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -40, 0, 25)
Subtitle.Position = UDim2.new(0, 20, 0, 65)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Authorization system - enter key"
Subtitle.TextColor3 = Color3.fromRGB(160, 160, 180)
Subtitle.TextScaled = true
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = MainFrame

-- Status kluczy
local KeyStatus = Instance.new("TextLabel")
KeyStatus.Size = UDim2.new(1, -40, 0, 20)
KeyStatus.Position = UDim2.new(0, 20, 0, 90)
KeyStatus.BackgroundTransparency = 1
if keysFetched then
    KeyStatus.Text = "✓ Database: " .. KeySystem.LoadedKeysCount .. " keys loaded"
    KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
else
    KeyStatus.Text = "✗ ERROR: Keys not collected!"
    KeyStatus.TextColor3 = Color3.fromRGB(255, 50, 50)
end
KeyStatus.TextScaled = true
KeyStatus.Font = Enum.Font.Gotham
KeyStatus.TextXAlignment = Enum.TextXAlignment.Left
KeyStatus.Parent = MainFrame

-- Pole tekstowe
local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -40, 0, 45)
TextBox.Position = UDim2.new(0, 20, 0, 120)
TextBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TextBox.BackgroundTransparency = 0.5
TextBox.BorderSizePixel = 2
TextBox.BorderColor3 = Color3.fromRGB(0, 120, 180)
TextBox.Text = ""
TextBox.PlaceholderText = "Enter authorization key..."
TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
TextBox.Font = Enum.Font.Gotham
TextBox.ClearTextOnFocus = false
TextBox.Parent = MainFrame

-- Label błędu
local ErrorLabel = Instance.new("TextLabel")
ErrorLabel.Size = UDim2.new(1, -40, 0, 25)
ErrorLabel.Position = UDim2.new(0, 20, 0, 170)
ErrorLabel.BackgroundTransparency = 1
ErrorLabel.Text = ""
ErrorLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
ErrorLabel.TextScaled = true
ErrorLabel.Font = Enum.Font.Gotham
ErrorLabel.TextXAlignment = Enum.TextXAlignment.Left
ErrorLabel.Parent = MainFrame

-- Informacja o próbach
local AttemptLabel = Instance.new("TextLabel")
AttemptLabel.Size = UDim2.new(1, -40, 0, 20)
AttemptLabel.Position = UDim2.new(0, 20, 0, 195)
AttemptLabel.BackgroundTransparency = 1
AttemptLabel.Text = "Trials left: " .. (KeySystem.MaxAttempts - KeySystem.Attempts) .. "/" .. KeySystem.MaxAttempts
AttemptLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
AttemptLabel.TextScaled = true
AttemptLabel.Font = Enum.Font.Gotham
AttemptLabel.TextXAlignment = Enum.TextXAlignment.Left
AttemptLabel.Parent = MainFrame

-- Przycisk autoryzacji
local AuthButton = Instance.new("TextButton")
AuthButton.Size = UDim2.new(0, 180, 0, 50)
AuthButton.Position = UDim2.new(0.5, -90, 0, 230)
AuthButton.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
AuthButton.BorderSizePixel = 0
AuthButton.Text = "AUTHORIZE"
AuthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
AuthButton.TextScaled = true
AuthButton.Font = Enum.Font.GothamBold
AuthButton.Parent = MainFrame

-- Hover
AuthButton.MouseEnter:Connect(function()
    AuthButton.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
end)
AuthButton.MouseLeave:Connect(function()
    if AuthButton.Text ~= "OK" then
        AuthButton.BackgroundColor3 = Color3.fromRGB(0, 140, 200)
    end
end)

-- Linia informacyjna na dole
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, -20, 0, 20)
FooterLabel.Position = UDim2.new(0, 10, 1, -30)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Text = "Keys downloaded from the server.."
FooterLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
FooterLabel.TextScaled = true
FooterLabel.Font = Enum.Font.Gotham
FooterLabel.TextXAlignment = Enum.TextXAlignment.Center
FooterLabel.Parent = MainFrame

-- Funkcja autoryzacji
local function TryAuthenticate()
    local input = TextBox.Text
    
    -- Sprawdź czy klucze są załadowane
    if not keysFetched then
        ErrorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        ErrorLabel.Text = "BŁĄD: Nie pobrano kluczy z serwera!"
        return
    end
    
    local success, message = Authenticate(input)
    
    if success then
        KeySystem.Authenticated = true
        ErrorLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
        ErrorLabel.Text = "✓ " .. message
        AuthButton.Text = "✓ AUTHORIZED"
        AuthButton.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
        TextBox.TextEditable = false
        AuthButton.AutoButtonColor = false
        
        task.wait(1.5)
        ScreenGui:Destroy()
        
        Notify = function(title, content, duration, icon)
            print("[OrionX] " .. title .. ": " .. content)
        end
        
    else
        KeySystem.Attempts = KeySystem.Attempts + 1
        local remaining = KeySystem.MaxAttempts - KeySystem.Attempts
        
        ErrorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        ErrorLabel.Text = "✗ " .. message
        AttemptLabel.Text = "Trials left: " .. remaining .. "/" .. KeySystem.MaxAttempts
        
        if remaining <= 0 then
            AuthButton.Text = "BLOCKADE"
            AuthButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            AuthButton.AutoButtonColor = false
            TextBox.Text = ""
            TextBox.PlaceholderText = "BLOCKADE — restart script"
            TextBox.TextEditable = false
            ErrorLabel.Text = "✗ You have exhausted all attempts!"
        end
    end
end

AuthButton.MouseButton1Click:Connect(TryAuthenticate)

TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        TryAuthenticate()
    end
end)

-- Czekaj aż użytkownik się autoryzuje
print("[KEY SYSTEM] Waiting for authorization...")

while not KeySystem.Authenticated do
    task.wait(0.5)
end

pcall(function() ScreenGui:Destroy() end)
print("[KEY SYSTEM] Authorization successful")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local VirtualUser = game:GetService("VirtualUser")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

-- Anti-kick / Anti-detection utilities
local DetectionBypasses = {
    SpoofedNames = {},
    OriginalProperties = {},
    AntiKickActive = false,
}

-- ─── UTILITY FUNCTIONS ───────────────────────────────────────────────────────

local function GetCharacter(player)
    return player.Character
end

local function GetRootPart(player)
    local char = GetCharacter(player)
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    if char then
        return char:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function SafeWaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local step = 0
    while step < timeout * 10 do
        local found = parent:FindFirstChild(childName)
        if found then return found end
        task.wait(0.1)
        step = step + 1
    end
    return parent:FindFirstChild(childName)
end

local function GetPlayerFromCharacter(char)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == char then
            return player
        end
    end
    return nil
end

-- Anti-kick loop
local function StartAntiKick()
    if DetectionBypasses.AntiKickActive then return end
    DetectionBypasses.AntiKickActive = true
    
    task.spawn(function()
        while DetectionBypasses.AntiKickActive do
            pcall(function()
                -- Spoof network ownership
                if RootPart then
                    RootPart:SetNetworkOwner(nil)
                end
                -- Anti-idle
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            task.wait(5)
        end
    end)
end

local function StopAntiKick()
    DetectionBypasses.AntiKickActive = false
end

-- Notification wrapper
local function Notify(title, content, duration, icon)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = duration or 6.5,
        Image = icon or 4483362458,
    })
end

-- ─── ESP SYSTEM ──────────────────────────────────────────────────────────────

local ESP = {
    Enabled = false,
    Boxes = {},
    Names = {},
    Tracers = {},
    HealthBars = {},
    Chams = {},
    Glow = {},
    Connections = {},
    Color = Color3.fromRGB(255, 50, 50),
    TeamCheck = false,
    ShowBox = true,
    ShowName = true,
    ShowTracer = true,
    ShowHealth = true,
    ShowChams = false,
    ShowGlow = false,
}

local function CreateESP(player)
    if ESP.Boxes[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP.Color
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Color = ESP.Color
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.OutlineColor = Color3.new(0, 0, 0)
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = ESP.Color
    tracer.Thickness = 1.5
    tracer.Transparency = 1
    
    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 50)
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 0.8
    
    local healthBg = Drawing.new("Square")
    healthBg.Visible = false
    healthBg.Color = Color3.fromRGB(30, 30, 30)
    healthBg.Thickness = 1
    healthBg.Filled = true
    healthBg.Transparency = 0.9
    
    ESP.Boxes[player] = box
    ESP.Names[player] = nameLabel
    ESP.Tracers[player] = tracer
    ESP.HealthBars[player] = {Bar = healthBar, Bg = healthBg}
end

local function UpdateESP(player)
    local char = GetCharacter(player)
    local root = GetRootPart(player)
    local humanoid = GetHumanoid(player)
    
    if not char or not root or not humanoid or humanoid.Health <= 0 then
        -- Hide all for this player
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
        end
        return
    end
    
    if ESP.TeamCheck and player.Team == LocalPlayer.Team and player ~= LocalPlayer then
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
        end
        return
    end
    
    local cam = workspace.CurrentCamera
    local pos, onScreen = cam:WorldToViewportPoint(root.Position)
    local scale = cam.ViewportSize
    
    if not onScreen then
        if ESP.Boxes[player] then
            ESP.Boxes[player].Visible = false
            ESP.Names[player].Visible = false
            ESP.Tracers[player].Visible = false
            if ESP.HealthBars[player] then
                ESP.HealthBars[player].Bar.Visible = false
                ESP.HealthBars[player].Bg.Visible = false
            end
        end
        return
    end
    
    -- Calculate box size based on distance
    local dist = (cam.CFrame.Position - root.Position).Magnitude
    local boxSize = math.clamp(500 / dist * 4, 20, 200)
    local halfSize = boxSize / 2
    
    local box = ESP.Boxes[player]
    local nameL = ESP.Names[player]
    local tracer = ESP.Tracers[player]
    local hb = ESP.HealthBars[player]
    
    -- Box
    if ESP.ShowBox then
        box.Visible = true
        box.Position = Vector2.new(pos.X - halfSize, pos.Y - boxSize)
        box.Size = Vector2.new(boxSize, boxSize * 1.6)
        box.Color = ESP.Color
    else
        box.Visible = false
    end
    
    -- Name
    if ESP.ShowName and nameL then
        nameL.Visible = true
        nameL.Position = Vector2.new(pos.X, pos.Y - boxSize * 1.6 - 16)
        nameL.Text = player.Name
        nameL.Color = ESP.Color
    elseif nameL then
        nameL.Visible = false
    end
    
    -- Tracer
    if ESP.ShowTracer then
        tracer.Visible = true
        tracer.From = Vector2.new(scale.X / 2, scale.Y)
        tracer.To = Vector2.new(pos.X, pos.Y)
        tracer.Color = ESP.Color
    else
        tracer.Visible = false
    end
    
    -- Health bar
    if ESP.ShowHealth and hb then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        local healthColor = Color3.fromRGB(
            math.floor(255 * (1 - healthPercent)),
            math.floor(255 * healthPercent),
            50
        )
        hb.Bg.Visible = true
        hb.Bg.Position = Vector2.new(pos.X + halfSize + 3, pos.Y - boxSize)
        hb.Bg.Size = Vector2.new(6, boxSize * 1.6)
        
        hb.Bar.Visible = true
        hb.Bar.Color = healthColor
        hb.Bar.Position = Vector2.new(pos.X + halfSize + 3, pos.Y - boxSize + (boxSize * 1.6 * (1 - healthPercent)))
        hb.Bar.Size = Vector2.new(6, boxSize * 1.6 * healthPercent)
    elseif hb then
        hb.Bar.Visible = false
        hb.Bg.Visible = false
    end
    
    -- Chams (highlight)
    if ESP.ShowChams or ESP.ShowGlow then
        pcall(function()
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if ESP.ShowGlow then
                        part.Material = Enum.Material.Neon
                        part.Color = ESP.Color
                    end
                    part.LocalTransparencyModifier = 0.3
                end
            end
        end)
    else
        pcall(function()
            for _, part in ipairs(char:GetChildren()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                    if part.Material == Enum.Material.Neon and not ESP.Glow[player] then
                        -- Restore handled per-player
                    end
                end
            end
        end)
    end
end

local function StartESP()
    if ESP.Enabled then return end
    ESP.Enabled = true
    
    -- Create ESP for existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESP(player)
        end
    end
    
    -- Player added
    ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        CreateESP(player)
    end)
    
    -- Player removed
    ESP.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if ESP.Boxes[player] then
            ESP.Boxes[player]:Remove()
            ESP.Boxes[player] = nil
        end
        if ESP.Names[player] then
            ESP.Names[player]:Remove()
            ESP.Names[player] = nil
        end
        if ESP.Tracers[player] then
            ESP.Tracers[player]:Remove()
            ESP.Tracers[player] = nil
        end
        if ESP.HealthBars[player] then
            ESP.HealthBars[player].Bar:Remove()
            ESP.HealthBars[player].Bg:Remove()
            ESP.HealthBars[player] = nil
        end
    end)
    
    -- Render loop
    ESP.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        if not ESP.Enabled then return end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESP(player)
            end
        end
    end)
end

local function StopESP()
    ESP.Enabled = false
    
    for _, conn in pairs(ESP.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    ESP.Connections = {}
    
    for _, drawing in pairs(ESP.Boxes) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Boxes = {}
    
    for _, drawing in pairs(ESP.Names) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Names = {}
    
    for _, drawing in pairs(ESP.Tracers) do
        pcall(function() drawing:Remove() end)
    end
    ESP.Tracers = {}
    
    for _, hb in pairs(ESP.HealthBars) do
        pcall(function() hb.Bar:Remove() end)
        pcall(function() hb.Bg:Remove() end)
    end
    ESP.HealthBars = {}
end

-- ─── MOVEMENT SYSTEM ─────────────────────────────────────────────────────────

local Movement = {
    Fly = false,
    Noclip = false,
    Speed = false,
    SpeedValue = 100,
    JumpPower = false,
    JumpPowerValue = 200,
    InfJump = false,
    Float = false,
    Spin = false,
    FloatHeight = 10,
    SpinSpeed = 999,
    FlySpeed = 50,
    Connections = {},
}

-- Noclip loop
local function NoclipLoop()
    if not Movement.Noclip then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Fly system
local function StartFly()
    if Movement.Fly then return end
    Movement.Fly = true
    
    local flying = true
    local bodyGyro = Instance.new("BodyGyro")
    local bodyVelocity = Instance.new("BodyVelocity")
    
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = RootPart.CFrame
    
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    
    bodyGyro.Parent = RootPart
    bodyVelocity.Parent = RootPart
    
    local ws, ad = 0, 0
    local a, wd, sd = 0, 0, 0
    
    Movement.Connections.Fly = RunService.RenderStepped:Connect(function()
        if not Movement.Fly then
            bodyGyro:Destroy()
            bodyVelocity:Destroy()
            Movement.Connections.Fly:Disconnect()
            Movement.Connections.Fly = nil
            return
        end
        
        local char = LocalPlayer.Character
        if not char or not char.Parent then return end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.PlatformStand = true
        
        local cam = workspace.CurrentCamera
        local cf = cam.CFrame
        
        local forward = cf.LookVector
        local right = cf.RightVector
        local up = cf.UpVector
        
        -- WASD Controls
        a = 0; wd = 0; sd = 0; ad = 0
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then wd = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then wd = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then ad = -1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then ad = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then a = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then a = -1 end
        
        local moveVector = (forward * wd + right * ad + up * a) * Movement.FlySpeed
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = cf
    end)
    
    Notify("Fly", "Flight enabled — WASD to move, Space/Shift for up/down", 5)
end

local function StopFly()
    Movement.Fly = false
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
        end
    end)
end

-- Teleport to mouse
local function TeleportToMouse()
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if target then
        local hitPos = mouse.Hit.Position
        RootPart.CFrame = CFrame.new(hitPos.X, hitPos.Y + 3, hitPos.Z)
        Notify("Teleport", "Teleported to mouse position", 3)
    else
        Notify("Teleport", "No valid target position", 3)
    end
end

-- Teleport to position
local function TeleportTo(x, y, z)
    RootPart.CFrame = CFrame.new(x, y, z)
end

-- Teleport to player
local function TeleportToPlayer(targetPlayer)
    local targetRoot = GetRootPart(targetPlayer)
    if targetRoot then
        RootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        Notify("Teleport", "Teleported to " .. targetPlayer.Name, 3)
    end
end

-- Inf Jump
local function StartInfJump()
    if Movement.InfJump then return end
    Movement.InfJump = true
    
    Movement.Connections.InfJump = UserInputService.JumpRequest:Connect(function()
        if not Movement.InfJump then
            Movement.Connections.InfJump:Disconnect()
            Movement.Connections.InfJump = nil
            return
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
    
    Notify("Inf Jump", "Infinite jump activated", 3)
end

local function StopInfJump()
    Movement.InfJump = false
end

-- Float system
local function StartFloat()
    if Movement.Float then return end
    Movement.Float = true
    
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.P = 20000
    bodyPosition.MaxForce = Vector3.new(0, 9e9, 0)
    bodyPosition.Position = RootPart.Position + Vector3.new(0, Movement.FloatHeight, 0)
    bodyPosition.Parent = RootPart
    
    Movement.Connections.Float = RunService.RenderStepped:Connect(function()
        if not Movement.Float then
            bodyPosition:Destroy()
            Movement.Connections.Float:Disconnect()
            Movement.Connections.Float = nil
            return
        end
        bodyPosition.Position = RootPart.Position + Vector3.new(0, Movement.FloatHeight, 0)
    end)
    
    Notify("Float", "Floating at height " .. Movement.FloatHeight, 3)
end

local function StopFloat()
    Movement.Float = false
end

-- Spin system
local function StartSpin()
    if Movement.Spin then return end
    Movement.Spin = true
    
    local bodyAngVel = Instance.new("BodyAngularVelocity")
    bodyAngVel.AngularVelocity = Vector3.new(0, Movement.SpinSpeed, 0)
    bodyAngVel.MaxTorque = Vector3.new(0, 9e9, 0)
    bodyAngVel.P = 30000
    bodyAngVel.Parent = RootPart
    
    Movement.Connections.Spin = RunService.RenderStepped:Connect(function()
        if not Movement.Spin then
            bodyAngVel:Destroy()
            Movement.Connections.Spin:Disconnect()
            Movement.Connections.Spin = nil
            return
        end
    end)
    
    Notify("Spin", "Spinning like a top!", 3)
end

local function StopSpin()
    Movement.Spin = false
end

-- ─── FLING SYSTEM ────────────────────────────────────────────────────────────

local Fling = {
    Active = false,
    Type = "Classic", -- "Classic", "Up"
    Power = 5000,
    Connections = {},
}

local function GetFlingForce(player)
    local root = GetRootPart(player)
    if not root then return end
    
    if Fling.Type == "Classic" then
        -- Classic: random direction + spin
        local randomDir = Vector3.new(
            math.random(-100, 100) / 10,
            math.random(50, 100) / 10,
            math.random(-100, 100) / 10
        )
        
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = randomDir * Fling.Power
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVel.P = 50000
        bodyVel.Parent = root
        
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.AngularVelocity = Vector3.new(
            math.random(-500, 500),
            math.random(-500, 500),
            math.random(-500, 500)
        )
        bodyAngVel.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyAngVel.P = 30000
        bodyAngVel.Parent = root
        
        task.delay(2, function()
            pcall(function() bodyVel:Destroy() end)
            pcall(function() bodyAngVel:Destroy() end)
        end)
        
    elseif Fling.Type == "Up" then
        -- Up: straight up
        local bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, Fling.Power, 0)
        bodyVel.MaxForce = Vector3.new(0, 9e9, 0)
        bodyVel.P = 50000
        bodyVel.Parent = root
        
        task.delay(2, function()
            pcall(function() bodyVel:Destroy() end)
        end)
    end
end

local function StartFling()
    if Fling.Active then return end
    Fling.Active = true
    
    local serverPlayers = Players:GetPlayers()
    
    for _, player in ipairs(serverPlayers) do
        if player ~= LocalPlayer then
            task.spawn(function()
                pcall(function() GetFlingForce(player) end)
            end)
        end
    end
    
    -- Fling new players that join
    Fling.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        if Fling.Active then
            task.wait(1)
            pcall(function() GetFlingForce(player) end)
        end
    end)
    
    -- Loop to re-apply
    Fling.Connections.Loop = RunService.Heartbeat:Connect(function()
        if not Fling.Active then
            Fling.Connections.Loop:Disconnect()
            Fling.Connections.Loop = nil
            return
        end
        -- Periodically re-apply to all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and math.random(1, 100) <= 5 then
                task.spawn(function()
                    pcall(function() GetFlingForce(player) end)
                end)
            end
        end
    end)
    
    local flingTypeStr = Fling.Type == "Classic" and "Classic (random directions)" or "Up (straight up)"
    Notify("Fling", "FLING ALL ACTIVE — Mode: " .. flingTypeStr, 5)
end

local function StopFling()
    Fling.Active = false
    for _, conn in pairs(Fling.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Fling.Connections = {}
end

-- ─── VISUAL SYSTEM ───────────────────────────────────────────────────────────

local Visuals = {
    Fullbright = false,
    NightVision = false,
    XRay = false,
    RemoveFog = false,
    RemoveGrass = false,
    OriginalBrightness = Lighting.Brightness,
    OriginalAmbient = Lighting.Ambient,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalFogColor = Lighting.FogColor,
    OriginalGlobalShadows = Lighting.GlobalShadows,
    Connections = {},
}

local function SetFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = Visuals.OriginalBrightness
        Lighting.Ambient = Visuals.OriginalAmbient
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = Visuals.OriginalGlobalShadows
        Lighting.OutdoorAmbient = Color3.new(0.6, 0.6, 0.6)
    end
    Visuals.Fullbright = enabled
end

local function SetNightVision(enabled)
    if enabled then
        Visuals.OriginalBrightness = Lighting.Brightness
        Visuals.OriginalAmbient = Lighting.Ambient
        Visuals.OriginalGlobalShadows = Lighting.GlobalShadows
        
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(0, 255, 100)
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(0, 255, 100)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 200, 50)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 50, 20)
    else
        Lighting.Brightness = Visuals.OriginalBrightness
        Lighting.Ambient = Visuals.OriginalAmbient
        Lighting.GlobalShadows = Visuals.OriginalGlobalShadows
        Lighting.OutdoorAmbient = Color3.new(0.6, 0.6, 0.6)
        Lighting.ColorShift_Top = Color3.new(1, 1, 1)
        Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    end
    Visuals.NightVision = enabled
end

local function SetXRay(enabled)
    Visuals.XRay = enabled
    local transparency = enabled and 0.7 or 0
    
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
            local playerOwner = GetPlayerFromCharacter(v.Parent)
            if not playerOwner then
                v.LocalTransparencyModifier = transparency
            end
        end
    end
    
    -- Also handle newly added parts
    if enabled then
        Visuals.Connections.XRay = Workspace.DescendantAdded:Connect(function(v)
            if not Visuals.XRay then
                Visuals.Connections.XRay:Disconnect()
                Visuals.Connections.XRay = nil
                return
            end
            if v:IsA("BasePart") and not v:FindFirstAncestorOfClass("Tool") then
                local playerOwner = GetPlayerFromCharacter(v.Parent)
                if not playerOwner then
                    v.LocalTransparencyModifier = 0.7
                end
            end
        end)
    else
        if Visuals.Connections.XRay then
            Visuals.Connections.XRay:Disconnect()
            Visuals.Connections.XRay = nil
        end
    end
end

local function SetRemoveFog(enabled)
    if enabled then
        Visuals.OriginalFogEnd = Lighting.FogEnd
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    else
        Lighting.FogEnd = Visuals.OriginalFogEnd
        Lighting.FogStart = 0
    end
    Visuals.RemoveFog = enabled
end

local function SetRemoveGrass(enabled)
    Visuals.RemoveGrass = enabled
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("GrassDecoration") or v:IsA("TerrainDetail") then
            v.Visible = not enabled
        end
        if v:IsA("BasePart") and v.Name:lower():find("grass") then
            v.Visible = not enabled
        end
    end
end

-- ─── CHAT SPAM SYSTEM ─────────────────────────────────────────────────────────

local ChatSpam = {
    Active = false,
    Messages = {
        "turcja owns me!",
        "turcja the best!!",
        "Tung tung Sahur",
        "fk nygg3rs",
        "nyg3a",
    },
    Delay = 1.5,
    Connections = {},
}

local function StartChatSpam()
    if ChatSpam.Active then return end
    ChatSpam.Active = true
    
    local chatService = game:GetService("TextChatService")
    local useNewChat = chatService.ChatVersion == Enum.ChatVersion.TextChatService
    
    ChatSpam.Connections.Loop = task.spawn(function()
        while ChatSpam.Active do
            task.wait(ChatSpam.Delay)
            local msg = ChatSpam.Messages[math.random(1, #ChatSpam.Messages)]
            
            pcall(function()
                if useNewChat then
                    local textChannel = chatService:FindFirstChild("RBXGeneral")
                    if textChannel then
                        textChannel:SendAsync(msg)
                    end
                else
                    local replicatedStorage = game:GetService("ReplicatedStorage")
                    local defaultChat = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                    if defaultChat then
                        local sayMessage = defaultChat:FindFirstChild("SayMessageRequest")
                        if sayMessage then
                            sayMessage:FireServer(msg)
                        end
                    end
                end
                
                -- Also try direct methods
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Chat"):WaitForChild("ChatMessage"):FireServer(msg)
                end)
            end)
        end
    end)
    
    Notify("Chat Spam", "Chat spam started — " .. #ChatSpam.Messages .. " messages", 4)
end

local function StopChatSpam()
    ChatSpam.Active = false
end

-- ─── SOUND SPAM SYSTEM ───────────────────────────────────────────────────────

local SoundSpam = {
    Active = false,
    SoundId = "rbxassetid://9120388685",
    Volume = 1,
    Pitch = 1,
    Connections = {},
}

local function StartSoundSpam()
    if SoundSpam.Active then return end
    SoundSpam.Active = true
    
    task.spawn(function()
        while SoundSpam.Active do
            pcall(function()
                local sound = Instance.new("Sound")
                sound.SoundId = SoundSpam.SoundId
                sound.Volume = SoundSpam.Volume
                sound.PlaybackSpeed = SoundSpam.Pitch
                sound.Parent = RootPart or workspace
                sound:Play()
                
                -- Clean up after sound finishes
                task.delay(5, function()
                    pcall(function() sound:Destroy() end)
                end)
            end)
            task.wait(0.3)
        end
    end)
    
    Notify("Sound Spam", "Sound spam activated", 3)
end

local function StopSoundSpam()
    SoundSpam.Active = false
end

-- ─── MAIN LOOP (Noclip + Speed + JumpPower auto-update) ──────────────────────

RunService.Heartbeat:Connect(function()
    -- Noclip
    if Movement.Noclip then
        NoclipLoop()
    end
    
    -- Speed
    if Movement.Speed then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = Movement.SpeedValue
                end
            end
        end)
    end
    
    -- JumpPower (JumpHeight in newer Roblox)
    if Movement.JumpPower then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.JumpPower = Movement.JumpPowerValue
                    -- Also set JumpHeight for newer engine
                    pcall(function() hum.JumpHeight = Movement.JumpPowerValue / 7.5 end)
                end
            end
        end)
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    RootPart = SafeWaitForChild(newChar, "HumanoidRootPart")
    Humanoid = SafeWaitForChild(newChar, "Humanoid")
    
    -- Re-apply states on respawn
    task.wait(0.5)
    
    if Movement.Fly then
        StartFly()
    end
    if Movement.Float then
        StartFloat()
    end
    if Movement.Spin then
        StartSpin()
    end
    
    Notify("Character", "Character respawned — States re-applied", 3)
end)

-- ─── RAYFIELD GUI ────────────────────────────────────────────────────────────

-- Window
local Window = Rayfield:CreateWindow({
    Name = "Tung Tung Sahur | Universal",
    Icon = 0,
    LoadingTitle = "Tung Tung Sahur v1.0",
    LoadingSubtitle = "by turcja | Professional exploits",
    ShowText = "Tung Tung Sahur",
    Theme = "Default",
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Tungtungsahur",
        FileName = "Tungtungsahur_Config"
    },
    Discord = {
        Enabled = true,
        Invite = "discord",
        RememberJoins = true
    },
    KeySystem = false,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 1: INFORMATION
-- ═══════════════════════════════════════════════════════════════════════════════
local InfoTab = Window:CreateTab("Information", "info")

local InfoSection = InfoTab:CreateSection("About Tung Tung Sahur")

InfoTab:CreateLabel("Tung Tung Sahur — A universal script for every game", 0, Color3.fromRGB(255, 255, 255), false)
InfoTab:CreateLabel("Version 1.0 | Created by turcja", 0, Color3.fromRGB(150, 150, 150), false)
InfoTab:CreateLabel("Authorized so that only people with the key can use it", 0, Color3.fromRGB(255, 100, 100), false)

InfoTab:CreateDivider()

local DiscordSection = InfoTab:CreateSection("Community & Support")

InfoTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard("https://discord.gg/YfxJrZbpdq")
        Notify("Discord", "Invite link copied to clipboard!", 3, "message-square")
    end,
})

InfoTab:CreateLabel("Join our Discord for updates, support, and more.", "message-square", Color3.fromRGB(255, 255, 255), false)

InfoTab:CreateDivider()

local StatsSection = InfoTab:CreateSection("Session Stats")

InfoTab:CreateLabel("Player: " .. LocalPlayer.Name, "user", Color3.fromRGB(255, 255, 255), false)
InfoTab:CreateLabel("Players on server: " .. #Players:GetPlayers(), "users", Color3.fromRGB(255, 255, 255), false)
InfoTab:CreateLabel("Server: " .. (game.JobId or "N/A"), "server", Color3.fromRGB(150, 150, 150), false)

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 2: MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════════
local MoveTab = Window:CreateTab("Movement", "move")

-- Fly
local FlySection = MoveTab:CreateSection("Flight")

MoveTab:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    CurrentValue = false,
    Flag = "Movement_Fly",
    Callback = function(Value)
        if Value then
            StartFly()
        else
            StopFly()
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "Movement_FlySpeed",
    Callback = function(Value)
        Movement.FlySpeed = Value
    end,
})

-- Ground movement
local GroundSection = MoveTab:CreateSection("Ground Movement")

MoveTab:CreateToggle({
    Name = "Noclip (Walk through walls)",
    CurrentValue = false,
    Flag = "Movement_Noclip",
    Callback = function(Value)
        Movement.Noclip = Value
    end,
})

MoveTab:CreateToggle({
    Name = "Speed Boost",
    CurrentValue = false,
    Flag = "Movement_Speed",
    Callback = function(Value)
        Movement.Speed = Value
        if not Value then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.WalkSpeed = 16 end
                end
            end)
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 500},
    Increment = 5,
    Suffix = "WS",
    CurrentValue = 100,
    Flag = "Movement_SpeedValue",
    Callback = function(Value)
        Movement.SpeedValue = Value
    end,
})

MoveTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Flag = "Movement_JumpPower",
    Callback = function(Value)
        Movement.JumpPower = Value
        if not Value then
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.JumpPower = 50
                        pcall(function() hum.JumpHeight = 7.2 end)
                    end
                end
            end)
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Jump Power Value",
    Range = {50, 500},
    Increment = 10,
    Suffix = "JP",
    CurrentValue = 200,
    Flag = "Movement_JumpPowerValue",
    Callback = function(Value)
        Movement.JumpPowerValue = Value
    end,
})

-- Special movement
local SpecialMoveSection = MoveTab:CreateSection("Special Movement")

MoveTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "Movement_InfJump",
    Callback = function(Value)
        if Value then
            StartInfJump()
        else
            StopInfJump()
        end
    end,
})

MoveTab:CreateToggle({
    Name = "Float (Hover in place)",
    CurrentValue = false,
    Flag = "Movement_Float",
    Callback = function(Value)
        if Value then
            StartFloat()
        else
            StopFloat()
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Float Height",
    Range = {1, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 10,
    Flag = "Movement_FloatHeight",
    Callback = function(Value)
        Movement.FloatHeight = Value
    end,
})

MoveTab:CreateToggle({
    Name = "Spin (Like a top)",
    CurrentValue = false,
    Flag = "Movement_Spin",
    Callback = function(Value)
        if Value then
            StartSpin()
        else
            StopSpin()
        end
    end,
})

MoveTab:CreateSlider({
    Name = "Spin Speed",
    Range = {100, 9999},
    Increment = 100,
    Suffix = "rpm",
    CurrentValue = 999,
    Flag = "Movement_SpinSpeed",
    Callback = function(Value)
        Movement.SpinSpeed = Value
    end,
})

-- Teleport
local TeleportSection = MoveTab:CreateSection("Teleports")

MoveTab:CreateButton({
    Name = "Teleport to Mouse Position",
    Callback = function()
        TeleportToMouse()
    end,
})

MoveTab:CreateInput({
    Name = "Teleport to Coordinates",
    CurrentValue = "",
    PlaceholderText = "x, y, z (e.g. 0, 50, 0)",
    RemoveTextAfterFocusLost = true,
    Flag = "Teleport_Coords",
    Callback = function(Text)
        local x, y, z = string.match(Text, "(-?%d+),%s*(-?%d+),%s*(-?%d+)")
        if x and y and z then
            TeleportTo(tonumber(x), tonumber(y), tonumber(z))
        else
            Notify("Error", "Invalid coordinates. Use format: x, y, z", 3)
        end
    end,
})

-- Teleport to player dropdown
local TeleportToPlayerSection = MoveTab:CreateSection("Teleport to Player")

local function RefreshPlayerDropdown()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

local teleportPlayerDropdown = MoveTab:CreateDropdown({
    Name = "Select Player",
    Options = RefreshPlayerDropdown(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "Teleport_PlayerDropdown",
    Callback = function(Options)
        local targetName = Options[1]
        if targetName then
            local target = Players:FindFirstChild(targetName)
            if target then
                TeleportToPlayer(target)
            end
        end
    end,
})

-- Refresh player list every 10 seconds
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            teleportPlayerDropdown:Refresh(RefreshPlayerDropdown())
        end)
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 3: ESP / VISUALS
-- ═══════════════════════════════════════════════════════════════════════════════
local ESPTab = Window:CreateTab("ESP & Visuals", "eye")

local ESPSection = ESPTab:CreateSection("ESP Configuration")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP_Enabled",
    Callback = function(Value)
        if Value then
            StartESP()
        else
            StopESP()
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Team Check (Hide teammates)",
    CurrentValue = false,
    Flag = "ESP_TeamCheck",
    Callback = function(Value)
        ESP.TeamCheck = Value
    end,
})

ESPTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 50, 50),
    Flag = "ESP_Color",
    Callback = function(Value)
        ESP.Color = Value
    end,
})

ESPTab:CreateDivider()

local ESPComponentsSection = ESPTab:CreateSection("ESP Components")

ESPTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Flag = "ESP_Boxes",
    Callback = function(Value)
        ESP.ShowBox = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ESP_Names",
    Callback = function(Value)
        ESP.ShowName = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show Tracers",
    CurrentValue = true,
    Flag = "ESP_Tracers",
    Callback = function(Value)
        ESP.ShowTracer = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Show Health Bars",
    CurrentValue = false,
    Flag = "ESP_Health",
    Callback = function(Value)
        ESP.ShowHealth = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Chams (See through walls - highlight)",
    CurrentValue = false,
    Flag = "ESP_Chams",
    Callback = function(Value)
        ESP.ShowChams = Value
    end,
})

ESPTab:CreateToggle({
    Name = "Glow (Neon material)",
    CurrentValue = false,
    Flag = "ESP_Glow",
    Callback = function(Value)
        ESP.ShowGlow = Value
    end,
})

-- Visuals
ESPTab:CreateDivider()

local VisualsSection = ESPTab:CreateSection("World Visuals")

ESPTab:CreateToggle({
    Name = "Fullbright (Day vision)",
    CurrentValue = false,
    Flag = "Visuals_Fullbright",
    Callback = function(Value)
        SetFullbright(Value)
        if Value then
            SetNightVision(false)
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Night Vision (Green tint)",
    CurrentValue = false,
    Flag = "Visuals_NightVision",
    Callback = function(Value)
        SetNightVision(Value)
        if Value then
            SetFullbright(false)
        end
    end,
})

ESPTab:CreateToggle({
    Name = "X-Ray (See through walls)",
    CurrentValue = false,
    Flag = "Visuals_XRay",
    Callback = function(Value)
        SetXRay(Value)
    end,
})

ESPTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "Visuals_RemoveFog",
    Callback = function(Value)
        SetRemoveFog(Value)
    end,
})

ESPTab:CreateToggle({
    Name = "Remove Grass/Decorations",
    CurrentValue = false,
    Flag = "Visuals_RemoveGrass",
    Callback = function(Value)
        SetRemoveGrass(Value)
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 4: TROLL
-- ═══════════════════════════════════════════════════════════════════════════════
local TrollTab = Window:CreateTab("Troll", "skull")

local FlingSection = TrollTab:CreateSection("Fling Systems")

TrollTab:CreateDropdown({
    Name = "Fling Mode - Beta",
    Options = {"Classic (Random + Spin)", "Up (Skyward)"},
    CurrentOption = {"Classic (Random + Spin)"},
    MultipleOptions = false,
    Flag = "Troll_FlingMode",
    Callback = function(Options)
        if Options[1] == "Classic (Random + Spin)" then
            Fling.Type = "Classic"
        else
            Fling.Type = "Up"
        end
    end,
})

TrollTab:CreateSlider({
    Name = "Fling Power",
    Range = {1000, 50000},
    Increment = 500,
    Suffix = "force",
    CurrentValue = 5000,
    Flag = "Troll_FlingPower",
    Callback = function(Value)
        Fling.Power = Value
    end,
})

TrollTab:CreateToggle({
    Name = "FLING ALL",
    CurrentValue = false,
    Flag = "Troll_FlingAll",
    Callback = function(Value)
        if Value then
            StartFling()
        else
            StopFling()
        end
    end,
})

TrollTab:CreateDivider()

local ChatSection = TrollTab:CreateSection("Chat/Spam")

TrollTab:CreateToggle({
    Name = "Chat Spam",
    CurrentValue = false,
    Flag = "Troll_ChatSpam",
    Callback = function(Value)
        if Value then
            StartChatSpam()
        else
            StopChatSpam()
        end
    end,
})

TrollTab:CreateInput({
    Name = "Add Custom Spam Message",
    CurrentValue = "",
    PlaceholderText = "Enter message to add to spam list",
    RemoveTextAfterFocusLost = true,
    Flag = "Troll_ChatSpamAdd",
    Callback = function(Text)
        if Text and #Text > 0 then
            table.insert(ChatSpam.Messages, Text)
            Notify("Chat Spam", "Added message: " .. Text, 3)
        end
    end,
})

TrollTab:CreateSlider({
    Name = "Spam Delay (seconds)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = 1.5,
    Flag = "Troll_SpamDelay",
    Callback = function(Value)
        ChatSpam.Delay = Value
    end,
})

TrollTab:CreateDivider()

local SoundSection = TrollTab:CreateSection("Sound Spam")

TrollTab:CreateToggle({
    Name = "Sound Spam",
    CurrentValue = false,
    Flag = "Troll_SoundSpam",
    Callback = function(Value)
        if Value then
            StartSoundSpam()
        else
            StopSoundSpam()
        end
    end,
})

TrollTab:CreateInput({
    Name = "Sound ID (rbxassetid://...)",
    CurrentValue = "rbxassetid://9120388685",
    PlaceholderText = "rbxassetid://...",
    RemoveTextAfterFocusLost = false,
    Flag = "Troll_SoundID",
    Callback = function(Text)
        if Text and #Text > 0 then
            SoundSpam.SoundId = Text
        end
    end,
})

TrollTab:CreateSlider({
    Name = "Sound Volume",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "vol",
    CurrentValue = 1,
    Flag = "Troll_SoundVolume",
    Callback = function(Value)
        SoundSpam.Volume = Value
    end,
})

TrollTab:CreateSlider({
    Name = "Sound Pitch",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = 1,
    Flag = "Troll_SoundPitch",
    Callback = function(Value)
        SoundSpam.Pitch = Value
    end,
})

TrollTab:CreateDivider()

local ChaosSection = TrollTab:CreateSection("Chaos Tools")

TrollTab:CreateButton({
    Name = "Crash All (Disconnect Everyone)",
    Callback = function()
        Notify("Warning", "Attempting mass crash... This may also crash you!", 3)
        pcall(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local root = GetRootPart(player)
                    if root then
                        -- Force massive network replication
                        for i = 1, 200 do
                            local vel = Instance.new("BodyVelocity")
                            vel.Velocity = Vector3.new(math.random(-99999, 99999), math.random(-99999, 99999), math.random(-99999, 99999))
                            vel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                            vel.Parent = root
                            task.wait()
                            vel:Destroy()
                        end
                    end
                end
            end
        end)
    end,
})

TrollTab:CreateButton({
    Name = "Crash Local Client",
    Callback = function()
        Notify("Warning", "Crashing local client in 3 seconds...", 3)
        task.wait(3)
        pcall(function()
            for i = 1, 500 do
                local p = Instance.new("Part")
                p.Parent = workspace
                p.Anchored = true
                p.Size = Vector3.new(999999, 999999, 999999)
                p.CFrame = CFrame.new(0, 0, 0)
                task.wait()
            end
        end)
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 5: PLAYER LIST / ESP MANAGEMENT
-- ═══════════════════════════════════════════════════════════════════════════════
local PlayersTab = Window:CreateTab("Players", "users")

local PlayerListSection = PlayersTab:CreateSection("Player List")

PlayersTab:CreateLabel("Select a player to teleport to or view info:", "users", Color3.fromRGB(200, 200, 200), false)

-- Player list dropdown with refresh
local function GetPlayerList()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local playerDropdown = PlayersTab:CreateDropdown({
    Name = "Online Players",
    Options = GetPlayerList(),
    CurrentOption = {""},
    MultipleOptions = false,
    Flag = "Players_List",
    Callback = function(Options)
        local targetName = Options[1]
        local target = targetName and Players:FindFirstChild(targetName)
        if target then
            local root = GetRootPart(target)
            local hum = GetHumanoid(target)
            local dist = root and math.floor((RootPart.Position - root.Position).Magnitude) or 0
            local hp = hum and math.floor(hum.Health) or 0
            local maxHp = hum and math.floor(hum.MaxHealth) or 100
            
            Notify("Player: " .. targetName, 
                "HP: " .. hp .. "/" .. maxHp .. " | Distance: " .. dist .. " studs", 5)
        end
    end,
})

-- Auto refresh
task.spawn(function()
    while task.wait(5) do
        pcall(function()
            playerDropdown:Refresh(GetPlayerList())
        end)
    end
end)

PlayersTab:CreateDivider()

local ActionsSection = PlayersTab:CreateSection("Player Actions")

PlayersTab:CreateButton({
    Name = "Teleport to Selected Player",
    Callback = function()
        local currentOpts = playerDropdown.CurrentOption
        if currentOpts and #currentOpts > 0 and currentOpts[1] ~= "" then
            local target = Players:FindFirstChild(currentOpts[1])
            if target then
                TeleportToPlayer(target)
            end
        else
            Notify("Error", "No player selected", 3)
        end
    end,
})

PlayersTab:CreateButton({
    Name = "Loop Teleport to Selected Player",
    Callback = function()
        local currentOpts = playerDropdown.CurrentOption
        if currentOpts and #currentOpts > 0 and currentOpts[1] ~= "" then
            local target = Players:FindFirstChild(currentOpts[1])
            if target then
                Notify("Loop TP", "Teleporting to " .. target.Name .. " every 0.5s", 3)
                task.spawn(function()
                    for i = 1, 20 do
                        local tRoot = GetRootPart(target)
                        if tRoot then
                            RootPart.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 3, 0))
                        end
                        task.wait(0.5)
                    end
                    Notify("Loop TP", "Teleport loop finished", 3)
                end)
            end
        else
            Notify("Error", "No player selected", 3)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 6: BYPASS / EXPLOITS
-- ═══════════════════════════════════════════════════════════════════════════════
local BypassTab = Window:CreateTab("Bypass", "shield")

local AntikickSection = BypassTab:CreateSection("Anti-Kick / Anti-Detect")

BypassTab:CreateToggle({
    Name = "Anti-Kick (Spoof network + anti-idle)",
    CurrentValue = false,
    Flag = "Bypass_AntiKick",
    Callback = function(Value)
        if Value then
            StartAntiKick()
            Notify("Anti-Kick", "Anti-kick and anti-idle activated", 3)
        else
            StopAntiKick()
        end
    end,
})

BypassTab:CreateDivider()

local BypassSection = BypassTab:CreateSection("Script Bypasses")

BypassTab:CreateButton({
    Name = "Load Infinite Yield",
    Callback = function()
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
                Notify("Script", "Infinite Yield loaded!", 4)
            end)
        end)
    end,
})

BypassTab:CreateButton({
    Name = "Load Dex Explorer",
    Callback = function()
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/infycode/roblox-scripts/main/dex.lua'))()
                Notify("Script", "Dex Explorer loaded!", 4)
            end)
        end)
    end,
})

BypassTab:CreateButton({
    Name = "Load Remote Spy",
    Callback = function()
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/remotespy.lua'))()
                Notify("Script", "Remote Spy loaded!", 4)
            end)
        end)
    end,
})

BypassTab:CreateButton({
    Name = "Load Sirius Multi-Tool",
    Callback = function()
        task.spawn(function()
            pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/sirius.lua'))()
                Notify("Script", "Sirius Multi-Tool loaded!", 4)
            end)
        end)
    end,
})

BypassTab:CreateDivider()

local CustomScriptsSection = BypassTab:CreateSection("Custom Scripts")

BypassTab:CreateInput({
    Name = "Execute Custom Script (Raw URL)",
    CurrentValue = "",
    PlaceholderText = "https://raw.githubusercontent.com/...",
    RemoveTextAfterFocusLost = true,
    Flag = "Bypass_CustomURL",
    Callback = function(Text)
        if Text and #Text > 0 then
            task.spawn(function()
                pcall(function()
                    loadstring(game:HttpGet(Text))()
                    Notify("Script", "Custom script executed!", 4)
                end)
            end)
        end
    end,
})

BypassTab:CreateInput({
    Name = "Execute Raw Lua Code",
    CurrentValue = "",
    PlaceholderText = "print('hello world')",
    RemoveTextAfterFocusLost = true,
    Flag = "Bypass_LuaCode",
    Callback = function(Text)
        if Text and #Text > 0 then
            pcall(function()
                local func, err = loadstring(Text)
                if func then
                    func()
                    Notify("Script", "Lua code executed successfully!", 4)
                else
                    Notify("Error", "Lua error: " .. tostring(err), 5)
                end
            end)
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- TAB 7: MISC / UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════
local MiscTab = Window:CreateTab("Utilities", "settings")

local UsefulSection = MiscTab:CreateSection("Useful Utilities")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local placeId = game.PlaceId
            ts:Teleport(placeId, LocalPlayer)
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobIds = {}
            local req = request or syn and syn.request or http_request
            if req then
                local resp = req({
                    Url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100",
                    Method = "GET",
                })
                local data = HttpService:JSONDecode(resp.Body)
                for _, server in ipairs(data.data) do
                    if server.id ~= game.JobId then
                        table.insert(jobIds, server.id)
                    end
                end
                if #jobIds > 0 then
                    ts:TeleportToPlaceInstance(placeId, jobIds[math.random(1, #jobIds)], LocalPlayer)
                end
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:BreakJoints()
                end
            end
        end)
    end,
})

MiscTab:CreateButton({
    Name = "Clear Debris/Items",
    Callback = function()
        pcall(function()
            local debris = workspace:FindFirstChild("Debris")
            if debris then
                for _, v in ipairs(debris:GetChildren()) do
                    v:Destroy()
                end
            end
            Notify("Cleared", "Debris and items cleared", 3)
        end)
    end,
})

MiscTab:CreateDivider()

local InfoSection2 = MiscTab:CreateSection("Debug Info")

MiscTab:CreateButton({
    Name = "Print Server Data to Console",
    Callback = function()
        print("=== Tung Tung Sahur Debug Info ===")
        print("Player:", LocalPlayer.Name)
        print("UserID:", LocalPlayer.UserId)
        print("PlaceID:", game.PlaceId)
        print("JobID:", game.JobId)
        print("Players Online:", #Players:GetPlayers())
        print("Game:", game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or "Unknown")
        print("===========================")
        Notify("Debug", "Server info printed to console (F9)", 4)
    end,
})

MiscTab:CreateButton({
    Name = "Copy Server Join Link",
    Callback = function()
        local link = "https://www.roblox.com/games/" .. game.PlaceId .. "?privateServerLinkCode=" .. game.JobId
        pcall(function()
            setclipboard(link)
            Notify("Copied", "Server join link copied!", 3)
        end)
    end,
})

-- Settings section
MiscTab:CreateDivider()

local SettingsSection = MiscTab:CreateSection("GUI Settings")

MiscTab:CreateButton({
    Name = "Toggle UI Visibility (K)",
    Callback = function()
        Rayfield:SetVisibility(not Rayfield:IsVisible())
    end,
})

MiscTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        -- Stop all active systems
        StopESP()
        StopFly()
        StopAntiKick()
        StopFling()
        StopChatSpam()
        StopSoundSpam()
        StopInfJump()
        StopSpin()
        StopFloat()
        
        Movement.Speed = false
        Movement.Noclip = false
        Movement.JumpPower = false
        
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                    hum.JumpPower = 50
                    hum.PlatformStand = false
                end
            end
        end)
        
        SetFullbright(false)
        SetNightVision(false)
        SetXRay(false)
        SetRemoveFog(false)
        SetRemoveGrass(false)
        
        task.wait(0.5)
        Rayfield:Destroy()
    end,
})

-- ═══════════════════════════════════════════════════════════════════════════════
-- FINALIZATION
-- ═══════════════════════════════════════════════════════════════════════════════

Notify("Tung Tung Sahur", "GUI loaded successfully!", 5, "check-circle")

-- Refresh player list on player join/leave
Players.PlayerAdded:Connect(function()
    task.wait(1)
    local names = GetPlayerList()
    pcall(function()
        playerDropdown:Refresh(names)
        teleportPlayerDropdown:Refresh(names)
    end)
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    local names = GetPlayerList()
    pcall(function()
        playerDropdown:Refresh(names)
        teleportPlayerDropdown:Refresh(names)
    end)
end)

-- Clean up on script unload
LocalPlayer.OnTeleport:Connect(function(state)
    StopESP()
    StopFly()
    StopAntiKick()
    StopFling()
    StopChatSpam()
    StopSoundSpam()
    StopInfJump()
    StopSpin()
    StopFloat()
end)

-- ======================================================================
-- [FPS] ONE SCOPE — ADVANCED MODULE v2.0
-- PlaceId: 135648408848758 (automatyczne wykrywanie)
-- Wklej na KONIEC skryptu (za print i za Prison Life)
-- ======================================================================

if game.PlaceId ~= 135648408848758 then return end

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunSvc = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpSvc = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TweenSvc = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local TeleportSvc = game:GetService("TeleportService")

local LP = Players.LocalPlayer
local function char() return LP.Character or LP.CharacterAdded:Wait() end
local function root() local c = char(); return c and c:FindFirstChild("HumanoidRootPart") end
local function hum() local c = char(); return c and c:FindFirstChildOfClass("Humanoid") end
local cam = Workspace.CurrentCamera

local function getPlrFromChar(c)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == c then return p end
    end
end
local function getRoot(p) local c = p.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum(p) local c = p.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getAlive()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then local h = getHum(p); if h and h.Health > 0 then table.insert(t, p) end end
    end
    return t
end

local function notify(t, c, d)
    pcall(function()
        if Rayfield and Rayfield.Notify then
            Rayfield:Notify({Title = t or "One Scope", Content = c or "", Duration = d or 5, Image = 4483362458})
        end
    end)
end

-- ======================================================================
-- KONFIGURACJA
-- ======================================================================
local Cfg = {
    SilentAim = false, SilentAimPriority = "Head",
    Aimbot = false, AimbotSmooth = 0.35, AimbotFOV = 200, AimbotPredict = false,
    Triggerbot = false, TriggerbotDelay = 0.05,
    ESP = false, ESPBox = true, ESPBoxOutline = true, ESPTracers = true, ESPName = true,
    ESPHealth = true, ESPDistance = false, ESPChams = false,
    ESPColor = Color3.fromRGB(255, 50, 50), ESPRainbow = false, ESPRainbowSpeed = 1,
    TracersRainbow = false,
    FovCircle = false, FovCircleColor = Color3.fromRGB(0, 255, 100),
    FovCircleRainbow = false, FovCircleSize = 150,
    FovCircleThick = 2, FovCircleTrans = 0.5,
    HitboxExpand = false, HitboxSize = 4,
    Fly = false, FlySpeed = 50, FlyAccel = 2,
    Noclip = false, InfJump = false,
    Wallhack = false, WallhackTrans = 0.55,
    FOVChanger = false, FOVValue = 120,
    NoRecoil = false, NoSpread = false,
    Bypass = false, BypassAll = false,
    KillAll = false, KillAllActive = false,
}

-- ======================================================================
-- ZAAWANSOWANY SILENT AIM (hookowanie __namecall)
-- ======================================================================
local silentHooks = {}
do
    local mt = getrawmetatable and getrawmetatable(game)
    if mt then
        local __namecall = mt.__namecall
        local __index = mt.__index
        setreadonly(mt, false)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            if Cfg.SilentAim and (method == "FireServer") then
                local target = getClosestPlayerToCursor()
                if target and self and self.Name then
                    local n = self.Name:lower()
                    -- Automatyczna detekcja remote'ów strzelania
                    if (n:find("fire") or n:find("shoot") or n:find("bullet") or n:find("hit") or n:find("damage") or n:find("ray") or n:find("projectile")) then
                        local tr = getRoot(target)
                        if tr then
                            -- podmiana arg — cel w głowę lub root
                            local head = target.Character and target.Character:FindFirstChild("Head")
                            local aimPos = (Cfg.SilentAimPriority == "Head" and head and head.Position) or tr.Position
                            if Cfg.AimbotPredict and Cfg.Aimbot then
                                local hum2 = getHum(target)
                                if hum2 and hum2.RootPart then
                                    local vel = hum2.RootPart.Velocity
                                    local dist = (cam.CFrame.Position - tr.Position).Magnitude
                                    local travelTime = dist / 2000
                                    aimPos = aimPos + vel * travelTime
                                end
                            end
                            -- podmiana argumentów
                            for i = 1, #args do
                                if typeof(args[i]) == "Vector3" then args[i] = aimPos end
                                if typeof(args[i]) == "CFrame" then args[i] = CFrame.new(aimPos) end
                                if typeof(args[i]) == "Instance" and args[i]:IsA("BasePart") then
                                    args[i] = head or tr
                                end
                            end
                            return __namecall(self, unpack(args))
                        end
                    end
                end
            end
            
            if Cfg.Triggerbot and (method == "FireServer") then
                local mouse = LP:GetMouse()
                local targetPart = mouse.Target
                if targetPart then
                    local plr = getPlrFromChar(targetPart.Parent)
                    if not plr and targetPart.Parent and targetPart.Parent.Parent then
                        plr = getPlrFromChar(targetPart.Parent.Parent)
                    end
                    if plr and plr ~= LP then
                        return __namecall(self, ...)
                    end
                end
            end
            
            -- Bypass: blokuj remotedetect/anticheat
            if Cfg.Bypass and (method == "FireServer" or method == "InvokeServer") then
                local n = self and self.Name and self.Name:lower() or ""
                if n:find("anticheat") or n:find("antihack") or n:find("detect") or n:find("kick") or n:find("ban") or n:find("report") or n:find("flag") then
                    return
                end
            end
            
            return __namecall(self, ...)
        end)

        mt.__index = newcclosure(function(self, k)
            if Cfg.Bypass and type(k) == "string" then
                local kl = k:lower()
                if kl:find("walkspeed") or kl:find("jumppower") or kl:find("hipheight") then
                    -- blokada odczytu przez anti-cheat (zawsze zwracaj normalnie)
                end
            end
            if Cfg.HitboxExpand and type(k) == "string" and k:lower():find("size") then
                -- pozwalamy na normalny odczyt
            end
            return __index(self, k)
        end)

        setreadonly(mt, true)
    end
end

-- ======================================================================
-- HELPER: closest player to cursor
-- ======================================================================
function getClosestPlayerToCursor()
    local mouse = LP:GetMouse()
    local closest, closestDist = nil, Cfg.AimbotFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local r = getRoot(p)
        local h = getHum(p)
        if r and h and h.Health > 0 then
            local pos, onScreen = cam:WorldToViewportPoint(r.Position)
            if onScreen then
                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                if d < closestDist then closestDist = d; closest = p end
            end
        end
    end
    return closest
end

-- ======================================================================
-- ESP z Drawing (zaawansowany)
-- ======================================================================
local espDrawings = {}
local espRainbowHue = 0
local espRunning = false

local function clearESP()
    for _, d in pairs(espDrawings) do
        for _, obj in pairs(d) do
            pcall(function() obj:Remove() end)
        end
    end
    espDrawings = {}
end

local function createESPDrawing(p)
    if espDrawings[p] then return end
    espDrawings[p] = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Distance = Drawing.new("Text"),
        Chams = nil,
    }
    local d = espDrawings[p]
    d.Box.Thickness = 2; d.Box.Filled = false; d.Box.Transparency = 1
    d.BoxOutline.Thickness = 3; d.BoxOutline.Filled = false; d.BoxOutline.Transparency = 1; d.BoxOutline.Color = Color3.new(0,0,0)
    d.Name.Size = 15; d.Name.Center = true; d.Name.Outline = true; d.Name.OutlineColor = Color3.new(0,0,0)
    d.Tracer.Thickness = 1.5; d.Tracer.Transparency = 1
    d.HealthBg.Thickness = 1; d.HealthBg.Filled = true; d.HealthBg.Transparency = 0.85; d.HealthBg.Color = Color3.fromRGB(20,20,20)
    d.HealthBar.Thickness = 0; d.HealthBar.Filled = true; d.HealthBar.Transparency = 0.8
    d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true; d.Distance.OutlineColor = Color3.new(0,0,0)
end

local function updateESP()
    if not Cfg.ESP then
        for _, d in pairs(espDrawings) do
            for _, obj in pairs(d) do pcall(function() obj.Visible = false end) end
        end
        return
    end
    
    if Cfg.ESPRainbow or Cfg.TracersRainbow then
        espRainbowHue = (espRainbowHue + Cfg.ESPRainbowSpeed) % 360
    end
    
    local scale = cam.ViewportSize
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        local r = getRoot(p)
        local h = getHum(p)
        if not r or not h or h.Health <= 0 then
            if espDrawings[p] then
                for _, obj in pairs(espDrawings[p]) do pcall(function() obj.Visible = false end) end
            end
            continue
        end
        
        createESPDrawing(p)
        local d = espDrawings[p]
        local pos, onScreen = cam:WorldToViewportPoint(r.Position + Vector3.new(0, 3, 0))
        local dist = (cam.CFrame.Position - r.Position).Magnitude
        local boxH = math.clamp(600/dist * 3.5, 30, 300)
        local boxW = boxH * 0.7
        
        local espColor
        if Cfg.ESPRainbow then
            espColor = Color3.fromHSV(espRainbowHue/360, 1, 1)
        else
            espColor = Cfg.ESPColor
        end
        
        local tracerColor
        if Cfg.TracersRainbow then
            tracerColor = Color3.fromHSV((espRainbowHue + 60)/360 % 1, 1, 1)
        else
            tracerColor = espColor
        end
        
        local x, y = pos.X, pos.Y
        
        -- BOX
        d.Box.Visible = Cfg.ESPBox and onScreen
        d.Box.Position = Vector2.new(x - boxW/2, y - boxH)
        d.Box.Size = Vector2.new(boxW, boxH)
        d.Box.Color = espColor
        
        d.BoxOutline.Visible = Cfg.ESPBoxOutline and Cfg.ESPBox and onScreen
        d.BoxOutline.Position = Vector2.new(x - boxW/2 - 1, y - boxH - 1)
        d.BoxOutline.Size = Vector2.new(boxW + 2, boxH + 2)
        
        -- NAME
        d.Name.Visible = Cfg.ESPName and onScreen
        d.Name.Position = Vector2.new(x, y - boxH - 18)
        d.Name.Text = p.Name
        d.Name.Color = espColor
        
        -- TRACER
        d.Tracer.Visible = Cfg.ESPTracers and onScreen
        d.Tracer.From = Vector2.new(scale.X/2, scale.Y)
        d.Tracer.To = Vector2.new(x, y)
        d.Tracer.Color = tracerColor
        
        -- HEALTH BAR
        if Cfg.ESPHealth and onScreen then
            local hp = math.clamp(h.Health/h.MaxHealth, 0, 1)
            local hpColor = Color3.fromHSV(hp * 0.35, 1, 1)
            d.HealthBg.Visible = true
            d.HealthBg.Position = Vector2.new(x + boxW/2 + 4, y - boxH)
            d.HealthBg.Size = Vector2.new(6, boxH)
            d.HealthBar.Visible = true
            d.HealthBar.Color = hpColor
            d.HealthBar.Position = Vector2.new(x + boxW/2 + 4, y - boxH + boxH * (1 - hp))
            d.HealthBar.Size = Vector2.new(6, boxH * hp)
        else
            d.HealthBg.Visible = false; d.HealthBar.Visible = false
        end
        
        -- DISTANCE
        d.Distance.Visible = Cfg.ESPDistance and onScreen
        d.Distance.Position = Vector2.new(x, y + boxH + 4)
        d.Distance.Text = math.floor(dist) .. " studs"
        d.Distance.Color = espColor
    end
end

-- ======================================================================
-- FOV CIRCLE
-- ======================================================================
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 2; fovCircle.NumSides = 72
fovCircle.Radius = 150; fovCircle.Transparency = 0.5; fovCircle.Color = Color3.fromRGB(0, 255, 100)
local fovRainbowHue = 0

local function updateFovCircle()
    if not Cfg.FovCircle then fovCircle.Visible = false; return end
    local mouse = LP:GetMouse()
    fovCircle.Visible = true
    fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
    fovCircle.Radius = Cfg.FovCircleSize
    fovCircle.Thickness = Cfg.FovCircleThick
    fovCircle.Transparency = Cfg.FovCircleTrans
    if Cfg.FovCircleRainbow then
        fovRainbowHue = (fovRainbowHue + 1.5) % 360
        fovCircle.Color = Color3.fromHSV(fovRainbowHue/360, 1, 1)
    else
        fovCircle.Color = Cfg.FovCircleColor
    end
end

-- ======================================================================
-- AIMBOT LOOP
-- ======================================================================
local function aimbotLoop()
    while Cfg.Aimbot do
        task.wait()
        pcall(function()
            local target = getClosestPlayerToCursor()
            if target then
                local r = getRoot(target)
                if r then
                    local targetCF = CFrame.new(cam.CFrame.Position, r.Position)
                    cam.CFrame = cam.CFrame:Lerp(targetCF, Cfg.AimbotSmooth)
                end
            end
        end)
    end
end

-- ======================================================================
-- TRIGGERBOT LOOP
-- ======================================================================
local function triggerbotLoop()
    while Cfg.Triggerbot do
        task.wait(Cfg.TriggerbotDelay)
        pcall(function()
            local mouse = LP:GetMouse()
            local target = mouse.Target
            if not target then return end
            local plr = getPlrFromChar(target.Parent)
            if not plr and target.Parent and target.Parent.Parent then
                plr = getPlrFromChar(target.Parent.Parent)
            end
            if plr and plr ~= LP then
                local tool = char():FindFirstChildOfClass("Tool")
                if tool then
                    local rem = tool:FindFirstChildWhichIsA("RemoteEvent") or tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot")
                    if rem then
                        pcall(function() rem:FireServer() end)
                    end
                end
                -- backup: szukaj w ReplicatedStorage
                for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        local n = v.Name:lower()
                        if n:find("click") or n:find("fire") or n:find("shoot") or n:find("gun") then
                            pcall(function() v:FireServer() end)
                            break
                        end
                    end
                end
            end
        end)
    end
end

-- ======================================================================
-- HITBOX EXPANDER (bez bugów)
-- ======================================================================
local function hitboxLoop()
    while Cfg.HitboxExpand do
        task.wait(0.1)
        pcall(function()
            local s = Cfg.HitboxSize
            for _, p in ipairs(Players:GetPlayers()) do
                if p == LP then continue end
                local c = p.Character
                if c then
                    for _, part in ipairs(c:GetChildren()) do
                        if part:IsA("BasePart") then
                            local n = part.Name:lower()
                            if n == "head" then
                                part.Size = Vector3.new(s, s*0.6, s)
                                part.CanCollide = false
                                part.Transparency = 0.85
                            elseif n:find("torso") or n == "upperbody" or n == "lowerbody" or n == "humanoidrootpart" then
                                part.Size = Vector3.new(s*1.3, s*1.3, s*1.1)
                                part.CanCollide = false
                                part.Transparency = 0.85
                            elseif n:find("arm") or n:find("leg") or n:find("hand") or n:find("foot") then
                                part.Size = Vector3.new(s*0.6, s*0.8, s*0.6)
                                part.CanCollide = false
                                part.Transparency = 0.85
                            end
                        end
                    end
                end
            end
        end)
    end
    -- restore
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LP then continue end
            local c = p.Character
            if c then
                for _, part in ipairs(c:GetChildren()) do
                    if part:IsA("BasePart") then
                        local n = part.Name:lower()
                        if n == "head" then part.Size = Vector3.new(2,1,1); part.Transparency = 0
                        elseif n:find("torso") or n == "upperbody" or n == "lowerbody" then part.Size = Vector3.new(2,2,1); part.Transparency = 0
                        elseif n:find("arm") or n:find("leg") then part.Size = Vector3.new(1,1,1); part.Transparency = 0
                        end
                    end
                end
            end
        end
    end)
end

-- ======================================================================
-- FLY (zaawansowany z BodyVelocity + BodyGyro)
-- ======================================================================
local flyConns = {}

local function startFly()
    if flyConns.fly then return end
    local bg = Instance.new("BodyGyro"); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    local hrp = root()
    if not hrp then return end
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp; bv.Parent = hrp
    
    local function stopFly()
        pcall(function() bg:Destroy() end)
        pcall(function() bv:Destroy() end)
        pcall(function() local h = hum(); if h then h.PlatformStand = false end end)
    end
    
    local speed = Cfg.FlySpeed
    flyConns.fly = RunSvc.RenderStepped:Connect(function()
        if not Cfg.Fly then
            stopFly()
            if flyConns.fly then flyConns.fly:Disconnect(); flyConns.fly = nil end
            return
        end
        pcall(function()
            local h = hum(); if h then h.PlatformStand = true end
            local cf = cam.CFrame
            local fwd, rgt, up = cf.LookVector, cf.RightVector, cf.UpVector
            local move = Vector3.new()
            if UserInput:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then move = move - rgt end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then move = move + rgt end
            if UserInput:IsKeyDown(Enum.KeyCode.Space) then move = move + up end
            if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - up end
            
            if move.Magnitude > 0 then
                move = move.Unit * speed
            end
            
            -- acceleration
            local currentVel = bv.Velocity
            local newVel = currentVel:Lerp(move, 0.15)
            bv.Velocity = newVel
            bg.CFrame = cf
        end)
    end)
    
    flyConns.speedChanger = RunSvc.Heartbeat:Connect(function()
        speed = Cfg.FlySpeed
    end)
end

-- ======================================================================
-- NOCLIP
-- ======================================================================
local function noclipLoop()
    while Cfg.Noclip do
        task.wait()
        pcall(function()
            local c = LP.Character
            if c then
                for _, p in ipairs(c:GetChildren()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end

-- ======================================================================
-- INFINITE JUMP
-- ======================================================================
local infJumpConn
local function toggleInfJump(v)
    if v then
        infJumpConn = UserInput.JumpRequest:Connect(function()
            if not Cfg.InfJump then
                if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
                return
            end
            pcall(function()
                local h = hum()
                if h and h:GetState() ~= Enum.HumanoidStateType.Jumping then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end)
    else
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
    end
end

-- ======================================================================
-- WALLHACK (X-Ray)
-- ======================================================================
local wallhackConn
local function toggleWallhack(v)
    if v then
        wallhackConn = RunSvc.RenderStepped:Connect(function()
            if not Cfg.Wallhack then
                if wallhackConn then wallhackConn:Disconnect(); wallhackConn = nil end
                pcall(function()
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
                    end
                end)
                return
            end
            pcall(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not LP.Character or not v:IsDescendantOf(LP.Character) then
                        local isEnemyPart = false
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p ~= LP and p.Character and v:IsDescendantOf(p.Character) then
                                isEnemyPart = true; break
                            end
                        end
                        if not isEnemyPart then
                            v.LocalTransparencyModifier = Cfg.WallhackTrans
                        end
                    end
                end
            end)
        end)
    else
        if wallhackConn then wallhackConn:Disconnect(); wallhackConn = nil end
        pcall(function()
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end
        end)
    end
end

-- ======================================================================
-- FOV CHANGER
-- ======================================================================
local function fovChangerLoop()
    while Cfg.FOVChanger do
        task.wait(0.05)
        pcall(function() cam.FieldOfView = Cfg.FOVValue end)
    end
    pcall(function() cam.FieldOfView = 70 end)
end

-- ======================================================================
-- NO RECOIL / NO SPREAD
-- ======================================================================
local function noRecoilSpread()
    while Cfg.NoRecoil or Cfg.NoSpread do
        task.wait(0.2)
        pcall(function()
            local tool = char():FindFirstChildOfClass("Tool")
            if tool then
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local n = v.Name:lower()
                        if Cfg.NoRecoil and (n:find("recoil") or n:find("kick")) then
                            v.Value = 0
                        end
                        if Cfg.NoSpread and (n:find("spread") or n:find("accuracy") or n:find("inaccuracy") or n:find("bloom")) then
                            v.Value = 0
                        end
                    end
                    if Cfg.NoRecoil and v:IsA("Script") and v.ClassName ~= "LocalScript" then
                        local n = v.Name:lower()
                        if n:find("recoil") then v.Disabled = true end
                    end
                end
            end
            -- szukaj w ReplicatedStorage / Workspace
            for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local n = v.Name:lower()
                    if Cfg.NoSpread and (n:find("spread") or n:find("accuracy") or n:find("bloom")) then
                        v.Value = 0
                    end
                end
            end
        end)
    end
end

-- ======================================================================
-- ZAAWANSOWANY BYPASS ANTYCHEAT
-- ======================================================================
local function advancedBypass()
    pcall(function()
        -- 1. Znajdź i zablokuj wszystkie skrypty anti-cheat
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") or v:IsA("ModuleScript") then
                local src = ""
                pcall(function() src = v.Source end)
                local srcLower = src:lower()
                if srcLower:find("anticheat") or srcLower:find("antihack") or srcLower:find("detectexploit") or srcLower:find("kickplayer") then
                    v.Disabled = true
                end
                local n = v.Name:lower()
                if n:find("anticheat") or n:find("antihack") or n:find("detect") or n:find("antiexploit") then
                    v.Disabled = true
                end
            end
            
            -- 2. Znajdź i blokuj remotes antycheat
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("anticheat") or n:find("antihack") or n:find("detect") or n:find("kick") or n:find("ban") or n:find("report") or n:find("admin") then
                    -- blokada przez hook __namecall (już zrobione)
                end
            end
        end
        
        -- 3. hookuj DebugInfo (Adonis/Knightmare)
        local gc = getgc
        local hf = hookfunction
        local di = debugInfo
        if hf and di then
            local oldDi = di
            debugInfo = newcclosure(function(...)
                local args = {...}
                if args[1] and type(args[1]) == "function" then
                    local name = ""
                    pcall(function() name = debugInfo(args[1]) end)
                    if name:find("kick") or name:find("ban") or name:find("detect") or name:find("crash") then
                        return "nil"
                    end
                end
                return oldDi(...)
            end)
        end
        
        -- 4. hookuj Identify
        if Identify then
            Identify = function() return "Synapse X", "v4.0.0" end
        end
        
        -- 5. spoofuj getexecutorname
        if getexecutorname then
            getexecutorname = function() return "Synapse X" end
        end
        
        -- 6. blokuj checki Drawing
        if Drawing then
            local oldDrawing = Drawing.new
            Drawing.new = function(...)
                -- enable all drawing features
                return oldDrawing(...)
            end
        end
        
        -- 7. blokuj checki CL (check caller)
        if checkcaller then
            checkcaller = function() return true end
        end
        
        notify("Bypass", "✅ Anti-cheat bypass fully active", 5)
    end)
end

-- ======================================================================
-- KILL ALL - teleport i zabij każdego gracza
-- ======================================================================
local killAllRunning = false

local function killAll()
    if killAllRunning then return end
    killAllRunning = true
    
    task.spawn(function()
        local targets = getAlive()
        if #targets == 0 then
            notify("Kill All", "No alive targets found", 3)
            killAllRunning = false
            return
        end
        
        notify("Kill All", "💀 Eliminating " .. #targets .. " players...", 4)
        
        -- Strategia 1: teleportuj się do każdego i użyj narzędzia
        local tool = char():FindFirstChildOfClass("Tool")
        local hasSword = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("MeshPart"))
        
        for _, target in ipairs(targets) do
            if not Cfg.KillAll then break end
            pcall(function()
                local r = getRoot(target)
                local h = getHum(target)
                if not r or not h or h.Health <= 0 then return end
                
                -- Teleportuj się do celu
                local hrp = root()
                if hrp then
                    hrp.CFrame = CFrame.new(r.Position + Vector3.new(0, 5, 0))
                    task.wait(0.05)
                end
                
                -- Użyj narzędzia jeśli jest
                if tool and hasSword then
                    local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("MeshPart")
                    if handle then
                        -- dotknij przeciwnika
                        local targetChar = target.Character
                        if targetChar then
                            handle.CFrame = r.CFrame
                            -- symuluj dotknięcie
                            pcall(function()
                                for _, p in ipairs(targetChar:GetChildren()) do
                                    if p:IsA("BasePart") then
                                        firetouchinterest(handle, p, 0)
                                        task.wait()
                                        firetouchinterest(handle, p, 1)
                                    end
                                end
                            end)
                        end
                    end
                end
                
                -- Strategia 2: Wyślij damage przez remote
                pcall(function()
                    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            local n = v.Name:lower()
                            if n:find("damage") or n:find("hit") or n:find("attack") or n:find("swing") or n:find("bullet") or n:find("melee") then
                                v:FireServer(target, target.Character and target.Character:FindFirstChild("Head") or r, 999)
                                v:FireServer(target.Character and target.Character:FindFirstChild("Head") or r, r.Position)
                                v:FireServer({Target = target, HitPart = target.Character and target.Character:FindFirstChild("Head") or r, Damage = 999})
                            end
                        end
                    end
                end)
                
                -- Strategia 3: Zniszcz humanoid
                pcall(function()
                    local h2 = getHum(target)
                    if h2 then h2.Health = 0 end
                end)
                
                task.wait(0.1)
            end)
        end
        
        -- Strategia 4: masowe niszczenie
        pcall(function()
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= LP then
                    local h2 = getHum(target)
                    if h2 then h2.Health = 0 end
                    local c = target.Character
                    if c then
                        pcall(function() c:BreakJoints() end)
                    end
                end
            end
        end)
        
        notify("Kill All", "💀 Kill All completed!", 3)
        killAllRunning = false
    end)
end

-- ======================================================================
-- GŁÓWNA PĘTLA RENDER
-- ======================================================================
RunSvc.RenderStepped:Connect(function()
    pcall(updateESP)
    pcall(updateFovCircle)
end)

-- ======================================================================
-- TWORZENIE ZAKŁADKI RAYFIELD
-- ======================================================================

local Tab = Window:CreateTab("[FPS] One Scope", 4483362458)

-- === AIMBOT SECTION ===
local aimSec = Tab:CreateSection("Aimbot")

Tab:CreateToggle({Name = "Silent Aim", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.SilentAim = v
    notify("Silent Aim", v and "✅ ON (bullet redirect)" or "OFF", 3)
end})

Tab:CreateDropdown({Name = "Silent Aim Priority", Section = aimSec, Options = {"Head", "Torso", "Root"}, CurrentOption = "Head", Callback = function(v)
    Cfg.SilentAimPriority = v
end})

Tab:CreateToggle({Name = "Aimbot (Aimlock)", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.Aimbot = v
    if v then task.spawn(aimbotLoop) end
end})

Tab:CreateToggle({Name = "Aimbot Prediction", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.AimbotPredict = v
end})

Tab:CreateSlider({Name = "Aimbot FOV", Section = aimSec, Min = 30, Max = 500, Default = 200, Increment = 10, Callback = function(v)
    Cfg.AimbotFOV = v
end})

Tab:CreateSlider({Name = "Smoothness", Section = aimSec, Min = 0.05, Max = 1, Default = 0.35, Increment = 0.05, Callback = function(v)
    Cfg.AimbotSmooth = v
end})

Tab:CreateToggle({Name = "Triggerbot", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.Triggerbot = v
    if v then task.spawn(triggerbotLoop) end
end})

Tab:CreateSlider({Name = "Triggerbot Delay", Section = aimSec, Min = 0.01, Max = 0.5, Default = 0.05, Increment = 0.01, Callback = function(v)
    Cfg.TriggerbotDelay = v
end})

Tab:CreateToggle({Name = "No Recoil", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.NoRecoil = v
    if v then task.spawn(noRecoilSpread) end
end})

Tab:CreateToggle({Name = "No Spread", Section = aimSec, CurrentValue = false, Callback = function(v)
    Cfg.NoSpread = v
    if v then task.spawn(noRecoilSpread) end
end})

-- === HITBOX ===
local hitSec = Tab:CreateSection("Hitbox Expander")

Tab:CreateToggle({Name = "Hitbox Expander", Section = hitSec, CurrentValue = false, Callback = function(v)
    Cfg.HitboxExpand = v
    if v then task.spawn(hitboxLoop) end
end})

Tab:CreateSlider({Name = "Hitbox Size", Section = hitSec, Min = 2, Max = 30, Default = 4, Increment = 1, Callback = function(v)
    Cfg.HitboxSize = v
end})

-- === ESP SECTION ===
local espSec = Tab:CreateSection("ESP")

Tab:CreateToggle({Name = "Enable ESP", Section = espSec, CurrentValue = false, Callback = function(v)
    Cfg.ESP = v
    if not v then
        for _, d in pairs(espDrawings) do
            for _, obj in pairs(d) do pcall(function() obj.Visible = false end) end
        end
    end
    notify("ESP", v and "✅ ESP ON" or "OFF", 3)
end})

Tab:CreateToggle({Name = "ESP Box", Section = espSec, CurrentValue = true, Callback = function(v) Cfg.ESPBox = v end})
Tab:CreateToggle({Name = "ESP Box Outline", Section = espSec, CurrentValue = true, Callback = function(v) Cfg.ESPBoxOutline = v end})
Tab:CreateToggle({Name = "ESP Tracers", Section = espSec, CurrentValue = true, Callback = function(v) Cfg.ESPTracers = v end})
Tab:CreateToggle({Name = "ESP Name", Section = espSec, CurrentValue = true, Callback = function(v) Cfg.ESPName = v end})
Tab:CreateToggle({Name = "ESP Health Bar", Section = espSec, CurrentValue = true, Callback = function(v) Cfg.ESPHealth = v end})
Tab:CreateToggle({Name = "ESP Distance", Section = espSec, CurrentValue = false, Callback = function(v) Cfg.ESPDistance = v end})

Tab:CreateColorPicker({Name = "ESP Color", Section = espSec, Default = Color3.fromRGB(255, 50, 50), Callback = function(v)
    Cfg.ESPColor = v
end})

Tab:CreateToggle({Name = "Rainbow ESP", Section = espSec, CurrentValue = false, Callback = function(v)
    Cfg.ESPRainbow = v
end})

Tab:CreateSlider({Name = "Rainbow Speed", Section = espSec, Min = 0.5, Max = 10, Default = 1, Increment = 0.5, Callback = function(v)
    Cfg.ESPRainbowSpeed = v
end})

Tab:CreateToggle({Name = "Rainbow Tracers", Section = espSec, CurrentValue = false, Callback = function(v)
    Cfg.TracersRainbow = v
end})

-- === FOV CIRCLE ===
local fovSec = Tab:CreateSection("FOV Circle")

Tab:CreateToggle({Name = "FOV Circle", Section = fovSec, CurrentValue = false, Callback = function(v)
    Cfg.FovCircle = v
end})

Tab:CreateColorPicker({Name = "Circle Color", Section = fovSec, Default = Color3.fromRGB(0, 255, 100), Callback = function(v)
    Cfg.FovCircleColor = v
    if not Cfg.FovCircleRainbow then fovCircle.Color = v end
end})

Tab:CreateToggle({Name = "Rainbow Circle", Section = fovSec, CurrentValue = false, Callback = function(v)
    Cfg.FovCircleRainbow = v
end})

Tab:CreateSlider({Name = "Circle Size", Section = fovSec, Min = 30, Max = 500, Default = 150, Increment = 10, Callback = function(v)
    Cfg.FovCircleSize = v
    fovCircle.Radius = v
end})

Tab:CreateSlider({Name = "Thickness", Section = fovSec, Min = 1, Max = 10, Default = 2, Increment = 1, Callback = function(v)
    Cfg.FovCircleThick = v; fovCircle.Thickness = v
end})

Tab:CreateSlider({Name = "Transparency", Section = fovSec, Min = 0, Max = 1, Default = 0.5, Increment = 0.05, Callback = function(v)
    Cfg.FovCircleTrans = v; fovCircle.Transparency = v
end})

-- === MOVEMENT ===
local movSec = Tab:CreateSection("Movement")

Tab:CreateToggle({Name = "Fly", Section = movSec, CurrentValue = false, Callback = function(v)
    Cfg.Fly = v
    if v then startFly() end
end})

Tab:CreateSlider({Name = "Fly Speed", Section = movSec, Min = 10, Max = 500, Default = 50, Increment = 5, Callback = function(v)
    Cfg.FlySpeed = v
end})

Tab:CreateToggle({Name = "Noclip", Section = movSec, CurrentValue = false, Callback = function(v)
    Cfg.Noclip = v
    if v then task.spawn(noclipLoop) end
end})

Tab:CreateToggle({Name = "Infinite Jump", Section = movSec, CurrentValue = false, Callback = function(v)
    Cfg.InfJump = v; toggleInfJump(v)
end})

-- === VISUALS ===
local visSec = Tab:CreateSection("Visuals")

Tab:CreateToggle({Name = "Wallhack (X-Ray)", Section = visSec, CurrentValue = false, Callback = function(v)
    Cfg.Wallhack = v; toggleWallhack(v)
end})

Tab:CreateSlider({Name = "Wallhack Transparency", Section = visSec, Min = 0.1, Max = 0.9, Default = 0.55, Increment = 0.05, Callback = function(v)
    Cfg.WallhackTrans = v
end})

Tab:CreateToggle({Name = "FOV Changer", Section = visSec, CurrentValue = false, Callback = function(v)
    Cfg.FOVChanger = v
    if v then task.spawn(fovChangerLoop) end
end})

Tab:CreateSlider({Name = "FOV Value", Section = visSec, Min = 30, Max = 160, Default = 120, Increment = 5, Callback = function(v)
    Cfg.FOVValue = v
end})

-- === BYPASS ===
local bypSec = Tab:CreateSection("Anti-Cheat Bypass")

Tab:CreateToggle({Name = "Bypass Anti-Cheat", Section = bypSec, CurrentValue = false, Callback = function(v)
    Cfg.Bypass = v
    if v then
        task.spawn(advancedBypass)
    end
end})

Tab:CreateButton({Name = "🔄 Rejoin (anti-ban)", Section = bypSec, Callback = function()
    pcall(function()
        notify("Rejoin", "Teleporting...", 3)
        task.wait(0.5)
        TeleportSvc:Teleport(game.PlaceId, LP)
    end)
end})

-- === KILL ALL ===
local killSec = Tab:CreateSection("Kill All")

Tab:CreateToggle({Name = "Enable Kill All Mode", Section = killSec, CurrentValue = false, Callback = function(v)
    Cfg.KillAll = v
end})

Tab:CreateButton({Name = "💀 EXECUTE KILL ALL", Section = killSec, Callback = function()
    if killAllRunning then
        notify("Kill All", "Already in progress!", 3)
        return
    end
    killAll()
end})

Tab:CreateButton({Name = "☠️ Kill All + Destroy", Section = killSec, Callback = function()
    if killAllRunning then
        notify("Kill All", "Already in progress!", 3)
        return
    end
    Cfg.KillAll = true
    killAll()
    task.wait(1)
    -- dodatkowe niszczenie
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local c = p.Character
                if c then
                    pcall(function() c:BreakJoints() end)
                    pcall(function() c:ClearAllChildren() end)
                end
            end
        end
    end)
end})

-- === UTILITIES ===
local utilSec = Tab:CreateSection("Utilities")

Tab:CreateButton({Name = "Reset Character", Section = utilSec, Callback = function()
    pcall(function()
        LP:LoadCharacter()
    end)
end})

Tab:CreateButton({Name = "Anti-Afk", Section = utilSec, Callback = function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        notify("Anti-Afk", "Activated! Press Ctrl+T to toggle", 3)
    end)
end})

Tab:CreateButton({Name = "Unlock FPS (uncap)", Section = utilSec, Callback = function()
    setfpscap(999)
    notify("FPS", "Uncapped! (999 FPS)", 3)
end})

-- == CLEANUP ==
Players.PlayerRemoving:Connect(function(p)
    if espDrawings[p] then
        for _, obj in pairs(espDrawings[p]) do
            pcall(function() obj:Remove() end)
        end
        espDrawings[p] = nil
    end
end)

print("Tung Tung Sahur loaded successfully!")
