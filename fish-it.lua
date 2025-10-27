-- =============================================================
-- KONFIGURASI AWAL & VARIABEL GLOBAL
-- =============================================================
local ToolSlot = 1         -- Slot Hotbar tempat pancing berada.
local ChargeTime = 1.0     -- Durasi simulasi 'charge' pancing.
local CycleDelay = 0.5     -- Jeda minimal antar siklus memancing.

-- Variabel status dan delay yang akan diatur oleh GUI
local isRunning = false
local BiteDelay = 3.0 -- Nilai default yang sudah terbukti berhasil
local AutoFishThread = nil -- Untuk menyimpan thread (proses) memancing

-- Nilai Casting (x, y)
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local NetService = Packages:WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Pastikan semua RemoteFunctions/Events tersedia
local EquipToolEvent = NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService:WaitForChild("RF/RequestFishingMinigameStarted") 
local FishingCompletedEvent = NetService:WaitForChild("RE/FishingCompleted")

local function wait(time)
    if time then
        task.wait(time)
    else
        task.wait()
    end
end

-- =============================================================
-- LOGIKA AUTO-FISHING (DIJALANKAN DALAM THREAD)
-- =============================================================

local function EquipFishingRod(slot)
    EquipToolEvent:FireServer(slot)
    wait(0.5)
end

local function ChargeRod()
    local success, result = pcall(function()
        return ChargeRodFunc:InvokeServer()
    end)
    
    if success then
        wait(ChargeTime)
        return true
    else
        warn("Charge Pancing GAGAL.")
        return false
    end
end

local function CastAndReelFast()
    local currentTime = tick()
    
    local args = {
        [1] = CastingX,
        [2] = CastingY,
        [3] = currentTime
    }
    
    local success, result = pcall(function()
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)

    if success and (result == true or type(result) == "table") then
        
        -- Menggunakan variabel global BiteDelay yang diatur oleh GUI
        wait(BiteDelay) 
        FishingCompletedEvent:FireServer()
        return true
    else
        warn("Casting GAGAL. Hasil: " .. tostring(result))
        return false
    end
end

local function AutoFishLoop()
    EquipFishingRod(ToolSlot)
    wait(1)

    while isRunning do 
        local isCharged = ChargeRod()
        if not isCharged then
            wait(CycleDelay * 2)
            continue
        end
        
        CastAndReelFast()

        wait(CycleDelay) 
    end
end

-- =============================================================
-- KODE GUI
-- =============================================================

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderColor3 = Color3.fromRGB(20, 20, 20)
Frame.Active = true
Frame.Draggable = true -- Membuat GUI bisa dipindah
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🎣 Auto Fish - Fast Reel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0.9, 0, 0, 30)
ToggleButton.Position = UDim2.new(0.05, 0, 0, 40)
ToggleButton.Text = "STATUS: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40) -- Merah (OFF)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

local DelayLabel = Instance.new("TextLabel")
DelayLabel.Size = UDim2.new(0.45, 0, 0, 20)
DelayLabel.Position = UDim2.new(0.05, 0, 0, 80)
DelayLabel.Text = "Bite Delay (s):"
DelayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DelayLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DelayLabel.Font = Enum.Font.SourceSans
DelayLabel.Parent = Frame

local DelayInput = Instance.new("TextBox")
DelayInput.Name = "DelayInput"
DelayInput.Size = UDim2.new(0.45, 0, 0, 25)
DelayInput.Position = UDim2.new(0.5, 0, 0, 105)
DelayInput.Text = tostring(BiteDelay)
DelayInput.PlaceholderText = "3.0"
DelayInput.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayInput.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DelayInput.Font = Enum.Font.SourceSans
DelayInput.TextXAlignment = Enum.TextXAlignment.Center
DelayInput.Parent = Frame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(0.9, 0, 0, 20)
InfoLabel.Position = UDim2.new(0.05, 0, 0, 130)
InfoLabel.Text = "Tingkatkan Delay jika ikan gagal ditarik."
InfoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
InfoLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
InfoLabel.Font = Enum.Font.SourceSans
InfoLabel.TextSize = 12
InfoLabel.Parent = Frame

-- =============================================================
-- KODE PENGHUBUNG (HANDLERS)
-- =============================================================

-- Handler untuk Tombol ON/OFF
ToggleButton.MouseButton1Click:Connect(function()
    if isRunning then
        -- MATIKAN SCRIPT
        isRunning = false
        if AutoFishThread then
            -- Hentikan thread memancing yang sedang berjalan
            coroutine.yield(AutoFishThread) 
            AutoFishThread = nil
        end
        ToggleButton.Text = "STATUS: OFF"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 40, 40) -- Merah
        print("Auto-Fishing DIMATIKAN.")
    else
        -- HIDUPKAN SCRIPT
        isRunning = true
        ToggleButton.Text = "STATUS: ON"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(40, 150, 40) -- Hijau
        print("Auto-Fishing DIHIDUPKAN.")
        
        -- Jalankan loop memancing dalam thread baru
        AutoFishThread = task.spawn(AutoFishLoop)
    end
end)

-- Handler untuk Input Delay
DelayInput.FocusLost:Connect(function(enterPressed)
    local newDelay = tonumber(DelayInput.Text)
    if newDelay and newDelay >= 0.1 then
        BiteDelay = newDelay
        print("Bite Delay diatur ke: " .. BiteDelay .. " detik.")
    else
        warn("Input Delay tidak valid. Menggunakan delay saat ini: " .. BiteDelay)
        -- Reset textbox ke nilai valid terakhir
        DelayInput.Text = tostring(BiteDelay) 
    end
end)
