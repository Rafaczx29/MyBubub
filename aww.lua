-- =============================================================
-- LOGIKA AUTO FISHING (GLOBAL SCOPE)
-- =============================================================

-- 🔥 VARIABEL PENTING (DIKONTROL OLEH RAYFIELD SLIDER/TOGGLE) 🔥
local ToolSlot = 1
local BiteDelay = 1.0 
local CastingX, CastingY = -1.233184814453125, 0.04706447494934768

local running = false          -- Status ON/OFF AutoFish
local currentAutoFishThread = nil -- Thread untuk AutoFish

local autoSellRunning = false  -- Status ON/OFF AutoSell
local autoSellThread = nil     -- Thread untuk AutoSell
local SellInterval = 5         -- Default 5 Menit

-- =============================================================
-- LOGIKA TELEPORT MURNI (Untuk Diuji Coba)
-- =============================================================

-- 🔥 1. DATA LOKASI (HARUS DIDEFINISIKAN SEBELUM GUI)
local TeleportData = {
    ["Weather Machine"] = Vector3.new(-1471, -3, 1929),
    ["Esoteric Depths"] = Vector3.new(3157, -1303, 1439),
    ["Tropical Grove"] = Vector3.new(-2038, 3, 3650),
    ["Stingray Shores"] = Vector3.new(-32, 4, 2773),
    ["Kohana Volcano"] = Vector3.new(-519, 24, 189),
    ["Coral Reefs"] = Vector3.new(-3095, 1, 2177),
    ["Crater Island"] = Vector3.new(968, 1, 4854),
    ["Kohana"] = Vector3.new(-658, 3, 719),
    ["Winter Fest"] = Vector3.new(1611, 4, 3280),
    ["Isoteric Island"] = Vector3.new(1987, 4, 1400),
    ["Treasure Hall"] = Vector3.new(-3600, -267, -1558),
    ["Lost Shore"] = Vector3.new(-3663, 38, -989 ),
    ["Sishypus Statue"] = Vector3.new(-3792, -135, -986)
}

-- Konversi data menjadi list string untuk Dropdown
local TeleportLocations = {}
for name, _ in pairs(TeleportData) do
    table.insert(TeleportLocations, name)
end
table.sort(TeleportLocations)

-- Variabel global untuk lokasi yang sedang dipilih
local CurrentTeleportLocation = TeleportLocations[1]

-- =============================================================
-- 2. FUNGSI TELEPORT AMAN
-- =============================================================

local Players = game:GetService("Players")

function TeleportToLocation(locationName)
    local destinationVector = TeleportData[locationName]
    
    if not destinationVector then return end

    local character = Players.LocalPlayer.Character
    local HRP = character and character:FindFirstChild("HumanoidRootPart")

    if HRP then
        -- Offset +3 untuk mencegah karakter stuck di lantai
        local targetCFrame = CFrame.new(destinationVector) * CFrame.new(0, 3, 0) 
        
        local success = pcall(function()
            HRP.CFrame = targetCFrame
        end)

        if success then
            return true
        end
    end
    return false
end

-- ========== SERVICE & REMOTE SETUP ==========
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetService = ReplicatedStorage:FindFirstChild("Packages", true)
and ReplicatedStorage.Packages:FindFirstChild("_Index", true)
and ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0", true)
and ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]:FindFirstChild("net", true)

if not NetService then
warn("❌ NetService tidak ditemukan. Logika memancing akan nonaktif.")
end

-- Ambil Remote. Jika NetService nil, ini akan menjadi nil (Aman).
local EquipToolEvent = NetService and NetService:WaitForChild("RE/EquipToolFromHotbar")
local ChargeRodFunc = NetService and NetService:WaitForChild("RF/ChargeFishingRod")
local RequestMinigameFunc = NetService and NetService:WaitForChild("RF/RequestFishingMinigameStarted")
local FishingCompletedEvent = NetService and NetService:WaitForChild("RE/FishingCompleted")
local CancelInputsFunc = NetService and NetService:WaitForChild("RF/CancelFishingInputs")
local SellAllItemsFunc = NetService and NetService:WaitForChild("RF/SellAllItems") 

-- ========== CORE GLOBAL FUNCTIONS ==========

function _G.EquipRod(slot)
 if EquipToolEvent then EquipToolEvent:FireServer(slot) end
task.wait(0.01)
end

function _G.ChargeRod()
 if not ChargeRodFunc then return false end
local ok = pcall(function()
 return ChargeRodFunc:InvokeServer()
end)
return ok
end

function _G.CastAndReel()
 if not RequestMinigameFunc or not FishingCompletedEvent then return false end

local currentTime = tick()
local args = {CastingX, CastingY, currentTime}
local cast_success = false

local charge_success = _G.ChargeRod()

if charge_success then
 task.wait(0.01) 
 
 local success, result = pcall(function()
return RequestMinigameFunc:InvokeServer(unpack(args))
 end)

 if success and (result == true or type(result) == "table") then
cast_success = true
 end
end

if cast_success then
 task.wait(BiteDelay) 
 FishingCompletedEvent:FireServer()
 
 task.wait(0.005) 
 if CancelInputsFunc then pcall(function() CancelInputsFunc:InvokeServer() end) end
 _G.EquipRod(ToolSlot)
 return true
end
return false
end

function _G.AutoFishLoop()
 _G.EquipRod(ToolSlot)
 task.wait(1) 

 while running do
 local ok = _G.CastAndReel()
 if not ok then
 task.wait(0.05) 
 end
 end
 currentAutoFishThread = nil 
end

function _G.PerformAutoSell()
 if not SellAllItemsFunc then
 print("❌ ERROR: Remote SellAllItems tidak ditemukan.")
 return
 end

 local success, result = pcall(function()
 return SellAllItemsFunc:InvokeServer()
 end)

 if success and result == true then
 print("✅ Berhasil menjual isi tas!")
 else
 print("⚠️ Gagal menjual.")
 end
end

function _G.AutoSellLoop()
 while autoSellRunning do
 _G.PerformAutoSell()
 local waitTime = SellInterval * 60 
 task.wait(waitTime)
 end
 autoSellThread = nil
end


-- =============================================================
-- UI RAYFIELD & INTEGRASI TOGGLE
-- =============================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
Name = "Fish It Instant | Beta",
LoadingTitle = "Fish It Instant Script",
LoadingSubtitle = "by Rafaczx",
ConfigurationSaving = { Enabled = true, FolderName = "FishItInstant", FileName = "FishItConfig" },
Discord = { Enabled = false, Invite = "", RememberJoins = true },
KeySystem = false,
KeySettings = { Title = "Sirius Key System", Subtitle = "Key System", Note = "Join the discord (discord.gg/sirius) for the key!", FileName = "SiriusKey", SaveKey = true, GrabKeyFromSite = false, Key = "" }
})

local TabFish = Window:CreateTab("Fishing Menu", 4483362458) 

-- 🎣 SLIDER DELAY MEMANCING
TabFish:CreateSlider({
    Name = "🎣 Delay Tarikan",
    CurrentValue = BiteDelay,
    Range = {0.5, 3.0}, 
    Increment = 0.05,
    Suffix = "s",
    Callback = function(value)
        BiteDelay = value
    end,
})

-- 🐟 TOGGLE AUTO FISH ON/OFF
TabFish:CreateToggle({
    Name = "Instant Fishing",
    CurrentValue = false,
    Callback = function(toggled)
 if not NetService then
 Rayfield:Notify({ Title = "Error", Content = "Remote Services tidak ditemukan.", Duration = 5 })
 return
 end

 if toggled then
 -- HIDUPKAN SCRIPT
 running = true
 currentAutoFishThread = task.spawn(_G.AutoFishLoop)
 Rayfield:Notify({ Title = "Instant Fishing", Content = "Memancing otomatis diaktifkan! Delay: " .. string.format("%.2f", BiteDelay) .. "s", Duration = 3 })
 else
 -- MATIKAN SCRIPT
 running = false
 if currentAutoFishThread and task.cancel then task.cancel(currentAutoFishThread) end
 Rayfield:Notify({ Title = "Instant Fishing", Content = "Memancing otomatis dinonaktifkan.", Duration = 3 })
 end
 end,
})


local TabSell = Window:CreateTab("Sell Menu", 4483362458) 

-- 💰 SLIDER DELAY AUTO SELL
TabSell:CreateSlider({
    Name = "⏳ Jeda Auto Sell",
    CurrentValue = SellInterval,
    Range = {1, 60}, -- 1 menit sampai 60 menit (1 jam)
    Increment = 1,
    Suffix = " Menit",
    Callback = function(value)
        SellInterval = value 
    end,
})

-- 🛍️ TOGGLE AUTO SELL ON/OFF
TabSell:CreateToggle({
    Name = "Auto Sell Backpack",
    CurrentValue = false, -- Default OFF
    Callback = function(toggled)
        if not SellAllItemsFunc then
            Rayfield:Notify({ Title = "Error", Content = "Remote SellAllItems tidak ditemukan.", Duration = 5 })
            return
        end
        
        if toggled then
            -- HIDUPKAN
            autoSellRunning = true
            autoSellThread = task.spawn(_G.AutoSellLoop)
            Rayfield:Notify({ Title = "Auto Sell", Content = "Penjualan otomatis diaktifkan! Setiap " .. SellInterval .. " menit.", Duration = 3 })
        else
            -- MATIKAN
            autoSellRunning = false
            if autoSellThread and task.cancel then task.cancel(autoSellThread) end
            Rayfield:Notify({ Title = "Auto Sell", Content = "Penjualan otomatis dinonaktifkan.", Duration = 3 })
        end
    end
})

local Tab = Window:CreateTab("Teleport Menu", 4483362458) 

-- 🗺️ DROPDOWN PILIH LOKASI (Syntax Fix)
local Dropdown = Tab:CreateDropdown({
   Name = "Pilih Lokasi Teleport",
   Options = TeleportLocations,
   -- 🔥 FIX KRITIS: CurrentOption HARUS BERUPA TABEL 🔥
   CurrentOption = {TeleportLocations[1]}, 
   Callback = function(choices)
       -- Rayfield mengembalikan tabel, kita ambil string pertama
       CurrentTeleportLocation = choices[1]
       Rayfield:Notify({ Title = "Tujuan Diatur", Content = "Siap Teleport ke: " .. CurrentTeleportLocation, Duration = 2 })
   end,
})

-- ✈️ TOMBOL TELEPORT
Tab:CreateButton({
    Name = "Teleport Ke Lokasi",
    Callback = function()
        local success = TeleportToLocation(CurrentTeleportLocation)
        
        if success then
            Rayfield:Notify({ Title = "Teleport Sukses!", Content = "Berpindah ke " .. CurrentTeleportLocation, Duration = 3 })
        else
            Rayfield:Notify({ Title = "Teleport Gagal", Content = "Gagal memindahkan karakter (Coba lagi).", Duration = 3 })
        end
    end,
})
