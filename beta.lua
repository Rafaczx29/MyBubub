--==============================================================
-- FAST FISH AUTO SCRIPT (UI + IKON 🎣 + KOSTUM DELAY)
-- Versi Aman di Semua Executor (Termasuk Android)
--==============================================================

--=== KONFIGURASI DASAR ===--
local ToolSlot = 1
local BiteDelay = 1.0
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

--=== SERVICE & REMOTES ===--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local NetService = ReplicatedStorage:FindFirstChild("Packages", true)
if NetService then
    NetService = NetService:FindFirstChild("_Index", true)
    if NetService then
        NetService = NetService:FindFirstChild("sleitnick_net@0.2.0", true)
        if NetService then
            NetService = NetService:FindFirstChild("net", true)
        end
    end
end

if not NetService then
    warn("❌ NetService tidak ditemukan. Script gagal berjalan.")
    return
end

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService:WaitForChild("RF/CancelFishingInputs")

--=== FUNGSI UTAMA ===--
local running = false

local function EquipFishingRod(slot)
    pcall(function()
        EquipToolEvent:FireServer(slot)
    end)
    task.wait(0.01)
end

local function ChargeRod()
    local success = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    if success then
        return true
    else
        task.wait(0.01)
        return false
    end
end

local function CastAndReelFast()
    local args = { CastingX, CastingY, tick() }
    local success, result = pcall(function()
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)

    if success and (result == true or type(result) == "table") then
        task.wait(BiteDelay)
        FishingCompletedEvent:FireServer()
        task.wait(0.005)
        pcall(function()
            CancelInputsFunc:InvokeServer()
        end)
        EquipFishingRod(ToolSlot)
        return true
    else
        return false
    end
end

local function AutoFishFast()
    running = true
    EquipFishingRod(ToolSlot)
    task.wait(1)

    while running do
        if ChargeRod() then
            CastAndReelFast()
        end
        task.wait(0.01)
    end
end

--=== UI SETUP ===--
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FastFishUI"
ScreenGui.Parent = guiParent
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 180)
MainFrame.Position = UDim2.new(1, -270, 1, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Text = "🎣 Fast Fish UI"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.9, 0, 0, 40)
StartButton.Position = UDim2.new(0.05, 0, 0.35, 0)
StartButton.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
StartButton.Text = "▶️ Start Auto Fish"
StartButton.TextColor3 = Color3.new(1, 1, 1)
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16
StartButton.Parent = MainFrame

local StopButton = Instance.new("TextButton")
StopButton.Size = UDim2.new(0.9, 0, 0, 40)
StopButton.Position = UDim2.new(0.05, 0, 0.65, 0)
StopButton.BackgroundColor3 = Color3.fromRGB(120, 40, 40)
StopButton.Text = "⏹ Stop Auto Fish"
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 16
StopButton.Parent = MainFrame

local DelayBox = Instance.new("TextBox")
DelayBox.Size = UDim2.new(0.9, 0, 0, 30)
DelayBox.Position = UDim2.new(0.05, 0, 0.15, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DelayBox.Text = tostring(BiteDelay)
DelayBox.TextColor3 = Color3.new(1, 1, 1)
DelayBox.Font = Enum.Font.Gotham
DelayBox.TextSize = 14
DelayBox.PlaceholderText = "Masukkan Bite Delay..."
DelayBox.Parent = MainFrame

--=== IKON TOGGLE ===--
local IconButton = Instance.new("ImageButton")
IconButton.Size = UDim2.new(0, 70, 0, 70)
IconButton.Position = UDim2.new(1, -90, 1, -90)
IconButton.BackgroundTransparency = 1
IconButton.Image = "rbxassetid://6034293816" -- 🎣 Ikon Roblox style
IconButton.Parent = ScreenGui

IconButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--=== LOGIKA UI ===--
StartButton.MouseButton1Click:Connect(function()
    local val = tonumber(DelayBox.Text)
    if val and val > 0 then
        BiteDelay = val
    end
    if not running then
        task.spawn(AutoFishFast)
    end
end)

StopButton.MouseButton1Click:Connect(function()
    running = false
end)

--=== ANIMASI RGB TITTLE ===--
task.spawn(function()
    local hue = 0
    while task.wait(0.05) do
        hue = (hue + 0.01) % 1
        Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end
end)
