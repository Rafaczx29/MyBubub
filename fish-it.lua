-- =============================================================
-- 🐟 AUTO FAST FISHING UI EDITION (Reel Delay Editable)
-- =============================================================

local ToolSlot = 1
local ChargeTime = 1.0
local CycleDelay = 0.5
local ReelDelay = 5 -- ⬅ delay sebelum "FishingCompleted"
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768
local AutoFishingEnabled = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local NetService = Packages:WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")

-- =============================================================
-- 🔹 FUNGSI LOGIKA
-- =============================================================
local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
    task.wait(0.5)
end

local function ChargeRod()
    local success = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    if success then
        task.wait(ChargeTime)
        return true
    else
        warn("❌ Charge gagal.")
        return false
    end
end

local function CastAndReelFast()
    local currentTime = tick()
    local args = {CastingX, CastingY, currentTime}
    local success, result = pcall(function()
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)
    if success and (result == true or type(result) == "table") then
        task.wait(ReelDelay) -- ⬅ sekarang bisa diubah dari UI
        FishingCompletedEvent:FireServer()
        print("✅ Ikan ditarik instan!")
        return true
    else
        warn("❌ Casting gagal.")
        return false
    end
end

-- =============================================================
-- 🔹 AUTO LOOP
-- =============================================================
local function AutoFishLoop()
    print("🎣 Fast Fishing dimulai...")
    EquipFishingRod(ToolSlot)
    task.wait(1)

    while AutoFishingEnabled do
        local charged = ChargeRod()
        if not charged then
            task.wait(CycleDelay * 2)
        else
            CastAndReelFast()
        end
        task.wait(CycleDelay)
    end
    print("⛔ Auto Fishing dihentikan.")
end

-- =============================================================
-- 🧩 UI
-- =============================================================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "FastFishingUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 260, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Text = "🐟 FAST FISHING"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

task.spawn(function()
	while true do
		for hue = 0, 255 do
			Title.TextColor3 = Color3.fromHSV(hue / 255, 1, 1)
			task.wait(0.02)
		end
	end
end)

-- Tombol Start/Stop
local Toggle = Instance.new("TextButton", Frame)
Toggle.Text = "▶ START"
Toggle.Size = UDim2.new(0.9, 0, 0, 35)
Toggle.Position = UDim2.new(0.05, 0, 0.25, 0)
Toggle.BackgroundColor3 = Color3.fromRGB(60, 170, 80)
Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
Toggle.Font = Enum.Font.GothamBold
Toggle.TextSize = 18
Instance.new("UICorner", Toggle)

-- Input Cycle Delay
local DelayBox = Instance.new("TextBox", Frame)
DelayBox.PlaceholderText = "Cycle Delay (detik)"
DelayBox.Text = tostring(CycleDelay)
DelayBox.Size = UDim2.new(0.9, 0, 0, 35)
DelayBox.Position = UDim2.new(0.05, 0, 0.55, 0)
DelayBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.Font = Enum.Font.Gotham
DelayBox.TextSize = 16
Instance.new("UICorner", DelayBox)

-- Input Reel Delay (yang tadi lu maksud)
local ReelBox = Instance.new("TextBox", Frame)
ReelBox.PlaceholderText = "Reel Delay (detik)"
ReelBox.Text = tostring(ReelDelay)
ReelBox.Size = UDim2.new(0.9, 0, 0, 35)
ReelBox.Position = UDim2.new(0.05, 0, 0.75, 0)
ReelBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ReelBox.TextColor3 = Color3.fromRGB(255, 255, 255)
ReelBox.Font = Enum.Font.Gotham
ReelBox.TextSize = 16
Instance.new("UICorner", ReelBox)

-- =============================================================
-- 🔹 LOGIKA UI
-- =============================================================
Toggle.MouseButton1Click:Connect(function()
    AutoFishingEnabled = not AutoFishingEnabled

    if AutoFishingEnabled then
        Toggle.Text = "⏹ STOP"
        Toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        CycleDelay = tonumber(DelayBox.Text) or CycleDelay
        ReelDelay = tonumber(ReelBox.Text) or ReelDelay
        task.spawn(AutoFishLoop)
    else
        Toggle.Text = "▶ START"
        Toggle.BackgroundColor3 = Color3.fromRGB(60, 170, 80)
    end
end)

print("✅ Fast Fishing UI Loaded (dengan Reel Delay editable).")
