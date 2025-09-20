-- Niri Hub ⚡ — com transparência no painel e no nome RGB

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- limpeza caso já esteja rodando
if _G.NiriHub and type(_G.NiriHub.cleanup) == "function" then
    pcall(function() _G.NiriHub.cleanup() end)
    task.wait(0.05)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "NiriHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local holder = { conns = {} }
_G.NiriHub = { gui = screenGui, holder = holder }

local function keepConn(c)
    if c then table.insert(holder.conns, c) end
end

local function clamp(n,a,b) return math.max(a, math.min(b, n)) end
local function safeWaitForChild(parent, name, timeout)
    timeout = timeout or 5
    local t0 = time()
    while time() - t0 < timeout do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(0.03)
    end
    return parent:FindFirstChild(name)
end

-- PAINEL PRINCIPAL
local root = Instance.new("Frame", screenGui)
root.Name = "Root"
root.Size = UDim2.new(0, 920, 0, 560)
root.Position = UDim2.new(0.06,0,0.06,0)
root.BackgroundColor3 = Color3.fromRGB(23,23,27)
root.BackgroundTransparency = 0.5 -- Painel 50% transparente
root.BorderSizePixel = 0
local rc = Instance.new("UICorner", root); rc.CornerRadius = UDim.new(0,12)

-- NOME RGB
local currBillboard, currConn, currText = nil, nil, nil
local function createNameBill(text)
    pcall(function() if currBillboard then currBillboard:Destroy() end end)
    if currConn then currConn:Disconnect(); currConn = nil end
    currText = tostring(text or LocalPlayer.Name)

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local head = safeWaitForChild(char, "Head", 4)
    if not head then return end

    local billboard = Instance.new("BillboardGui", char)
    billboard.Name = "NiriNameLocal"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0,220,0,52)
    billboard.StudsOffset = Vector3.new(0,3.2,0)
    billboard.AlwaysOnTop = true

    -- FUNDO BRANCO COM TRANSPARÊNCIA
    local f = Instance.new("Frame", billboard)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = 0.5 -- 50% transparente
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1,-10,1,0)
    lbl.Position = UDim2.new(0,5,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 18
    lbl.Text = currText
    lbl.TextColor3 = Color3.fromRGB(18,18,18)

    currConn = RunService.Heartbeat:Connect(function()
        if not stroke.Parent then return end
        local t = time() * 1.5
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        stroke.Color = Color3.fromRGB(clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
    end)

    currBillboard = billboard
end

-- Ativa automaticamente com o nome do jogador
createNameBill(LocalPlayer.Name)

-- Continua na Parte 2...