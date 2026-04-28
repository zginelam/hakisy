--[[
    ORION X — ONLINE KEY SYSTEM
    Pobiera klucze z GitHub i sprawdza expiry date (czas polski UTC+1)
]]

local KeySystem = {
    KeyURL = "https://raw.githubusercontent.com/zginelam/hakisy/refs/heads/main/key3.txt",
    KeysCache = {},         -- tabela: klucz -> expiry_date
    Authenticated = false,
    MaxAttempts = 3,
    Attempts = 0,
    LoadedKeysCount = 0,
}

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
                local data = game:GetService("HttpService"):JSONDecode(resp.Body)
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
    -- Polska: UTC+1 (zimą) lub UTC+2 (latem), dla uproszczenia +1
    local polishTime = osTime + 3600  -- +1h
    local dateTable = os.date("!%Y-%m-%d", polishTime)
    return dateTable
end

-- Sprawdza czy klucz jest ważny (nie wygasł)
local function IsKeyValid(key)
    local expiry = KeySystem.KeysCache[key]
    if not expiry then
        return false, "Klucz nie istnieje w bazie danych!"
    end
    
    -- Klucz "never" = nigdy nie wygasa
    if expiry == "never" then
        return true, "Klucz wieczny — autoryzacja OK!"
    end
    
    -- Sprawdź czy expiry to poprawna data YYYY-MM-DD
    local expYear, expMonth, expDay = expiry:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not expYear then
        return false, "Nieprawidłowy format daty w kluczu!"
    end
    
    -- Pobierz aktualną datę (czas polski)
    local currentDate = GetPolishTime()
    if not currentDate then
        return false, "Nie można pobrać aktualnego czasu! Sprawdź połączenie."
    end
    
    local curYear, curMonth, curDay = currentDate:match("^(%d%d%d%d)-(%d%d)-(%d%d)$")
    if not curYear then
        return false, "Nieprawidłowa data systemowa!"
    end
    
    -- Konwertuj na liczby
    expYear, expMonth, expDay = tonumber(expYear), tonumber(expMonth), tonumber(expDay)
    curYear, curMonth, curDay = tonumber(curYear), tonumber(curMonth), tonumber(curDay)
    
    -- Porównanie dat
    if expYear > curYear then
        return true, "Autoryzacja pomyślna!"
    elseif expYear < curYear then
        return false, "Klucz wygasł! (wygasł: " .. expiry .. ")"
    end
    
    -- Ten sam rok
    if expMonth > curMonth then
        return true, "Autoryzacja pomyślna!"
    elseif expMonth < curMonth then
        return false, "Klucz wygasł! (wygasł: " .. expiry .. ")"
    end
    
    -- Ten sam miesiąc
    if expDay >= curDay then
        return true, "Autoryzacja pomyślna!"
    else
        return false, "Klucz wygasł! (wygasł: " .. expiry .. ")"
    end
end

-- Główna funkcja autoryzacji
local function Authenticate(inputKey)
    if not inputKey or inputKey == "" then
        return false, "Klucz nie może być pusty!"
    end
    
    local cleanInput = tostring(inputKey):gsub("%s+", "")
    
    -- Sprawdź długość klucza (max 16 znaków)
    if #cleanInput > 16 then
        return false, "Klucz może mieć maksymalnie 16 znaków! (podałeś " .. #cleanInput .. ")"
    end
    
    -- Szukamy klucza w cache
    return IsKeyValid(cleanInput)
end

-- ─── POBIERANIE KLUCZY ───────────────────────────────────────────────────────

print("[KEY SYSTEM] Pobieranie kluczy z GitHub...")

local keysFetched = FetchKeysFromURL()

if keysFetched then
    print("[KEY SYSTEM] Pobrano " .. KeySystem.LoadedKeysCount .. " kluczy z serwera.")
else
    print("[KEY SYSTEM] BŁĄD: Nie udało się pobrać kluczy! Sprawdź URL lub połączenie.")
    print("[KEY SYSTEM] URL: " .. KeySystem.KeyURL)
end

-- ─── INTERFEJS KEY SYSTEM ────────────────────────────────────────────────────

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrionX_KeySystem"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
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
Logo.Text = "🔐 ORION X"
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
Subtitle.Text = "System autoryzacji — wpisz klucz"
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
    KeyStatus.Text = "✓ Baza: " .. KeySystem.LoadedKeysCount .. " kluczy załadowanych"
    KeyStatus.TextColor3 = Color3.fromRGB(0, 255, 100)
else
    KeyStatus.Text = "✗ BŁĄD: Nie pobrano kluczy!"
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
TextBox.PlaceholderText = "Wpisz klucz autoryzacyjny..."
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
AttemptLabel.Text = "Pozostało prób: " .. (KeySystem.MaxAttempts - KeySystem.Attempts) .. "/" .. KeySystem.MaxAttempts
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
AuthButton.Text = "AUTORYZUJ"
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
FooterLabel.Text = "Klucze pobierane z serwera GitHub • czas polski UTC+1"
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
        AuthButton.Text = "✓ ZAUTORYZOWANO"
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
        AttemptLabel.Text = "Pozostało prób: " .. remaining .. "/" .. KeySystem.MaxAttempts
        
        if remaining <= 0 then
            AuthButton.Text = "BLOKADA"
            AuthButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            AuthButton.AutoButtonColor = false
            TextBox.Text = ""
            TextBox.PlaceholderText = "BLOKADA — zrestartuj executor"
            TextBox.TextEditable = false
            ErrorLabel.Text = "✗ Wyczerpałeś wszystkie próby!"
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
print("[KEY SYSTEM] Oczekiwanie na autoryzację...")

while not KeySystem.Authenticated do
    task.wait(0.5)
end

pcall(function() ScreenGui:Destroy() end)
print("[KEY SYSTEM] Autoryzacja udana. Ładowanie GUI...")

-- ============================================================
-- TUTAJ KONTYNUUJE SIĘ GŁÓWNY SKRYPT (Rayfield itd.)
-- ============================================================
