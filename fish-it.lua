-- =============================================================
-- KONFIGURASI FAST FISH
-- =============================================================
local ToolSlot = 1         -- Slot Hotbar tempat pancing berada (1-9).
local ChargeTime = 1.0     -- Durasi simulasi 'charge' pancing (detik).
local CycleDelay = 0.5     -- Jeda minimal antar siklus memancing (detik).

-- Nilai Casting (x, y)
local CastingX = -1.233184814453125
local CastingY = 0.04706447494934768

-- =============================================================
-- SERVICE & REMOTE FUNCTIONS/EVENTS
-- =============================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local NetService = Packages:WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

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
-- LOGIKA AUTO-FISHING
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
        wait(ChargeTime) -- Tetap perlu mensimulasikan waktu charge
        return true
    else
        warn("Charge Pancing GAGAL. Mencoba skip atau ulang.")
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
    
    print(string.format("Casting dengan Timestamp: %.2f", currentTime))
    
    local success, result = pcall(function()
        -- Memanggil RequestFishingMinigameStarted
        return RequestMinigameFunc:InvokeServer(unpack(args))
    end)

    if success and (result == true or type(result) == "table") then
        print("Casting BERHASIL.")
        
        -- 🔥 MODIFIKASI KRITIS UNTUK FAST FISH 🔥
        -- Kita tidak menunggu ReelInWaitTime, langsung panggil FishingCompleted
        -- Ini mengasumsikan server akan segera memproses minigame sebagai 'berhasil'
        wait(2) -- Jeda minimal agar server memproses casting
        FishingCompletedEvent:FireServer()
        print("Pancing ditarik INSTAN!")
        return true
    else
        warn("Casting GAGAL. Hasil: " .. tostring(result))
        return false
    end
end

-- =============================================================
-- EKSEKUSI UTAMA
-- =============================================================

local function AutoFishFast()
    print("--- FAST FISHING SCRIPT DIMULAI ---")

    EquipFishingRod(ToolSlot)
    wait(1)

    while true do 
        -- 1. Charge
        local isCharged = ChargeRod()
        if not isCharged then
            wait(CycleDelay * 2)
            continue
        end
        
        -- 2. Cast dan Reel In Instan
        local isSuccess = CastAndReelFast()

        if not isSuccess then
             warn("Siklus Fast Fish GAGAL. Mencoba lagi.")
        end

        -- Jeda antar siklus (untuk mencegah spam/disconnect)
        wait(CycleDelay) 
    end
end

AutoFishFast()
