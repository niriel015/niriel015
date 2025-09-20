-- Niri Hub ⚡ Ultimate — Versão FINAL com slider de escala, puxar jogador e controles de transparência
-- Cole inteiro no executor (Delta). Tudo client-side; algumas ações podem falhar em servidores protegidos.

-- ===== SERVICES & UTIL =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- cleanup previous
if _G.NiriHub then
    pcall(function()
        if _G.NiriHub.gui and _G.NiriHub.gui.Parent then _G.NiriHub.gui:Destroy() end
        if _G.NiriHub._conns then for _,c in ipairs(_G.NiriHub._conns) do pcall(function() c:Disconnect() end) end end
    end)
end
_G.NiriHub = { _conns = {} }
local function keepConn(c) if c then table.insert(_G.NiriHub._conns, c) end end

local function safeWaitForChild(parent, name, t)
    t = t or 5
    local deadline = tick() + t
    while tick() < deadline do
        local v = parent:FindFirstChild(name)
        if v then return v end
        task.wait(0.03)
    end
    return parent:FindFirstChild(name)
end
local function clamp(n,a,b) return math.max(a, math.min(b, n)) end

-- helper: find player by partial name/display
local function findPlayerByName(query)
    if not query or query == "" then return nil end
    query = query:lower()
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(query) or (p.DisplayName and p.DisplayName:lower():find(query)) then
            return p
        end
    end
    return nil
end

-- Transparency defaults (you can change these; UI added to switch)
local nameBgTransparency = 0.5  -- default background transparency for the name (0 = opaque, 1 = fully transparent)
local panelTransparency = 0     -- default panel transparency (0 = opaque)

-- ===== MAIN GUI =====
local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.Name = "NiriHub"
screenGui.ResetOnSpawn = false
_G.NiriHub.gui = screenGui

local root = Instance.new("Frame", screenGui)
root.Name = "Root"
root.Size = UDim2.new(0, 920, 0, 560)
root.Position = UDim2.new(0.06,0,0.06,0)
root.BackgroundColor3 = Color3.fromRGB(23,23,27)
root.BorderSizePixel = 0
root.Active = true; root.Draggable = true
local rc = Instance.new("UICorner", root); rc.CornerRadius = UDim.new(0,12)
local rstroke = Instance.new("UIStroke", root); rstroke.Color = Color3.fromRGB(40,40,45); rstroke.Transparency = 0.7

-- Top bar
local topBar = Instance.new("Frame", root)
topBar.Size = UDim2.new(1,0,0,60)
topBar.Position = UDim2.new(0,0,0,0)
topBar.BackgroundColor3 = Color3.fromRGB(34,34,40)
local tc = Instance.new("UICorner", topBar); tc.CornerRadius = UDim.new(0,10)
local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -320, 1, 0); title.Position = UDim2.new(0,20,0,0)
title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 20
title.Text = "⚡  Niri Hub"; title.TextColor3 = Color3.fromRGB(245,245,245); title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0,44,0,36); closeBtn.Position = UDim2.new(1, -64, 0, 12)
closeBtn.Text = "—"; closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 22
closeBtn.BackgroundColor3 = Color3.fromRGB(170,60,60); closeBtn.TextColor3 = Color3.new(1,1,1)
local cc = Instance.new("UICorner", closeBtn); cc.CornerRadius = UDim.new(0,8)

-- expand/minimize arrow
local expandBtn = Instance.new("TextButton", topBar)
expandBtn.Size = UDim2.new(0,36,0,36); expandBtn.Position = UDim2.new(1, -108, 0, 12)
expandBtn.Text = "🔼"; expandBtn.Font = Enum.Font.GothamBold; expandBtn.TextSize = 20
expandBtn.BackgroundColor3 = Color3.fromRGB(90,44,150); expandBtn.TextColor3 = Color3.fromRGB(255,255,255)
local expc = Instance.new("UICorner", expandBtn); expc.CornerRadius = UDim.new(0,8)

-- Panel transparency buttons (50% / 100%)
local panel50Btn = Instance.new("TextButton", topBar)
panel50Btn.Size = UDim2.new(0,44,0,28); panel50Btn.Position = UDim2.new(1, -160, 0, 16)
panel50Btn.Text = "50%"; panel50Btn.Font = Enum.Font.Gotham; panel50Btn.TextSize = 14
panel50Btn.BackgroundColor3 = Color3.fromRGB(80,80,80); panel50Btn.TextColor3 = Color3.fromRGB(255,255,255)
local p50c = Instance.new("UICorner", panel50Btn); p50c.CornerRadius = UDim.new(0,6)

local panel100Btn = Instance.new("TextButton", topBar)
panel100Btn.Size = UDim2.new(0,44,0,28); panel100Btn.Position = UDim2.new(1, -210, 0, 16)
panel100Btn.Text = "100%"; panel100Btn.Font = Enum.Font.Gotham; panel100Btn.TextSize = 14
panel100Btn.BackgroundColor3 = Color3.fromRGB(80,80,80); panel100Btn.TextColor3 = Color3.fromRGB(255,255,255)
local p100c = Instance.new("UICorner", panel100Btn); p100c.CornerRadius = UDim.new(0,6)

local function applyPanelTransparency(v)
    panelTransparency = clamp(v, 0, 1)
    -- apply to main containers that have visible backgrounds
    if root then pcall(function() root.BackgroundTransparency = panelTransparency end) end
    if topBar then pcall(function() topBar.BackgroundTransparency = panelTransparency end) end
    if menu then pcall(function() menu.BackgroundTransparency = panelTransparency end) end
    if content then pcall(function() content.BackgroundTransparency = panelTransparency end) end
    -- adjust stroke visibility a bit (optional)
    if rstroke then pcall(function() rstroke.Transparency = clamp(0.7 + panelTransparency*0.3, 0, 1) end) end
end

panel50Btn.MouseButton1Click:Connect(function() applyPanelTransparency(0.5) end)
panel100Btn.MouseButton1Click:Connect(function() applyPanelTransparency(1.0) end)

-- scale slider container (top bar, right side)
local scaleContainer = Instance.new("Frame", topBar)
scaleContainer.Size = UDim2.new(0,180,0,32)
scaleContainer.Position = UDim2.new(1, -320, 0, 14)
scaleContainer.BackgroundTransparency = 1

local scaleLabel = Instance.new("TextLabel", scaleContainer)
scaleLabel.Size = UDim2.new(0,44,1,0); scaleLabel.Position = UDim2.new(0,0,0,0)
scaleLabel.BackgroundTransparency = 1; scaleLabel.Font = Enum.Font.Gotham; scaleLabel.TextSize = 14; scaleLabel.Text = "Tamanho"; scaleLabel.TextColor3 = Color3.fromRGB(220,220,220)

local sliderBar = Instance.new("Frame", scaleContainer)
sliderBar.Size = UDim2.new(0,110,0,8); sliderBar.Position = UDim2.new(0,56,0,12)
sliderBar.BackgroundColor3 = Color3.fromRGB(60,60,66)
local sbarCorner = Instance.new("UICorner", sliderBar); sbarCorner.CornerRadius = UDim.new(0,6)

local thumb = Instance.new("Frame", sliderBar)
thumb.Size = UDim2.new(0,16,1,0); thumb.Position = UDim2.new(0.8, -8, 0, 0)
thumb.BackgroundColor3 = Color3.fromRGB(200,200,200)
local thumbCorner = Instance.new("UICorner", thumb); thumbCorner.CornerRadius = UDim.new(0,6)

-- Left menu
local menu = Instance.new("Frame", root)
menu.Size = UDim2.new(0, 220, 1, -84); menu.Position = UDim2.new(0, 16, 0, 68)
menu.BackgroundColor3 = Color3.fromRGB(18,18,22)
local mc = Instance.new("UICorner", menu); mc.CornerRadius = UDim.new(0,10)
local logo = Instance.new("TextLabel", menu)
logo.Size = UDim2.new(1, -28, 0, 48); logo.Position = UDim2.new(0,14,0,10)
logo.BackgroundTransparency = 1; logo.Text = "Niri Hub"; logo.Font = Enum.Font.GothamBold; logo.TextSize = 20; logo.TextColor3 = Color3.fromRGB(255,255,255); logo.TextXAlignment = Enum.TextXAlignment.Left

-- Content area
local content = Instance.new("Frame", root)
content.Size = UDim2.new(1, -268, 1, -84); content.Position = UDim2.new(0, 244, 0, 68)
content.BackgroundColor3 = Color3.fromRGB(28,28,32)
local contentc = Instance.new("UICorner", content); contentc.CornerRadius = UDim.new(0,10)

local contentTitle = Instance.new("TextLabel", content)
contentTitle.Size = UDim2.new(1, -24, 0, 40); contentTitle.Position = UDim2.new(0,12,0,12)
contentTitle.BackgroundTransparency = 1; contentTitle.Font = Enum.Font.GothamBold; contentTitle.TextSize = 18; contentTitle.TextColor3 = Color3.fromRGB(245,245,245)
contentTitle.Text = "Informações"

local contentHolder = Instance.new("Frame", content)
contentHolder.Size = UDim2.new(1, -24, 1, -64); contentHolder.Position = UDim2.new(0,12,0,56); contentHolder.BackgroundTransparency = 1

-- Ray icon (always visible)
local ray = Instance.new("TextButton", screenGui)
ray.Name = "RayIcon"; ray.Size = UDim2.new(0,64,0,64); ray.Position = UDim2.new(0.04,0,0.78,0)
ray.Text = "⚡"; ray.Font = Enum.Font.GothamBold; ray.TextSize = 32; ray.BackgroundColor3 = Color3.fromRGB(60,60,60); ray.TextColor3 = Color3.fromRGB(255,255,255)
ray.Active = true; ray.Draggable = true
local rcc = Instance.new("UICorner", ray); rcc.CornerRadius = UDim.new(0,32)

-- ===== tabs setup =====
local tabNames = {"Informações","Jogador","Casas","Carros","Poderes","Jogadores","Flings","Áudios","Avatar"}
local pages = {}
local selectedBtn = nil
local function makeMenuButton(text, y)
    local b = Instance.new("TextButton", menu)
    b.Size = UDim2.new(1, -28, 0, 40); b.Position = UDim2.new(0,14,0,y)
    b.BackgroundColor3 = Color3.fromRGB(34,34,38); b.Text = text; b.Font = Enum.Font.Gotham; b.TextSize = 15; b.TextColor3 = Color3.fromRGB(220,220,220)
    b.AutoButtonColor = false
    local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0,8)
    local s = Instance.new("UIStroke", b); s.Color = Color3.fromRGB(45,45,50); s.Transparency = 0.7
    return b
end

for i,name in ipairs(tabNames) do
    local btn = makeMenuButton(name, 74 + (i-1)*46)
    local page = Instance.new("Frame", contentHolder)
    page.Size = UDim2.new(1,0,1,0); page.BackgroundTransparency = 1; page.Visible = false
    pages[name] = page
    btn.MouseButton1Click:Connect(function()
        if selectedBtn then selectedBtn.BackgroundColor3 = Color3.fromRGB(34,34,38) end
        btn.BackgroundColor3 = Color3.fromRGB(90,44,150)
        selectedBtn = btn
        for k,v in pairs(pages) do v.Visible = (k==name) end
        contentTitle.Text = name
    end)
    if i==1 then
        btn.BackgroundColor3 = Color3.fromRGB(90,44,150)
        selectedBtn = btn
        page.Visible = true
        contentTitle.Text = name
    end
end

-- ===== Informações page =====
do
    local page = pages["Informações"]
    local lbl = Instance.new("TextLabel", page)
    lbl.Size = UDim2.new(1,-10,1,-10); lbl.Position = UDim2.new(0,5,0,5); lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextYAlignment = Enum.TextYAlignment.Top; lbl.TextWrapped = true
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(230,230,230)
    local function refresh()
        local names = {}
        for _,p in ipairs(Players:GetPlayers()) do table.insert(names,p.Name) end
        local gameName = "Desconhecido"
        pcall(function() local ms=game:GetService("MarketplaceService"); local info=ms:GetProductInfo(game.PlaceId); if info and info.Name then gameName=info.Name end end)
        lbl.Text = string.format("Bem-vindo ao Niri Hub!\n\nJogadores (%d): %s\n\nJogo: %s\n\nObservação: muitas ações são client-side e podem não afetar outros jogadores.", #names, table.concat(names, ", "), tostring(gameName))
    end
    refresh()
    keepConn(Players.PlayerAdded:Connect(refresh)); keepConn(Players.PlayerRemoving:Connect(refresh))
end

-- ===== Jogador page (nome RGB, copiar roupa, seguir) =====
do
    local page = pages["Jogador"]

    local lblTarget = Instance.new("TextLabel", page)
    lblTarget.Size = UDim2.new(0,80,0,24); lblTarget.Position = UDim2.new(0,12,0,12)
    lblTarget.BackgroundTransparency = 1; lblTarget.Font = Enum.Font.Gotham; lblTarget.TextColor3 = Color3.fromRGB(220,220,220); lblTarget.Text = "Alvo:"

    local targetBox = Instance.new("TextBox", page)
    targetBox.Size = UDim2.new(0,320,0,30); targetBox.Position = UDim2.new(0,100,0,10)
    targetBox.PlaceholderText = "nick ou display"; targetBox.BackgroundColor3 = Color3.fromRGB(40,40,44); targetBox.TextColor3 = Color3.fromRGB(255,255,255)

    local tpBtn = Instance.new("TextButton", page)
    tpBtn.Size = UDim2.new(0,200,0,36); tpBtn.Position = UDim2.new(0,12,0,56); tpBtn.Text = "Teleportar p/ alvo"; tpBtn.Font = Enum.Font.GothamSemibold
    tpBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    tpBtn.MouseButton1Click:Connect(function()
        local t = findPlayerByName(targetBox.Text)
        if t and t.Character then
            local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
            local thrp = safeWaitForChild(t.Character, "HumanoidRootPart", 3)
            if hrp and thrp then pcall(function() hrp.CFrame = thrp.CFrame * CFrame.new(0,0,3) end) end
        else warn("Alvo não encontrado") end
    end)

    local followBtn = Instance.new("TextButton", page)
    followBtn.Size = UDim2.new(0,200,0,36); followBtn.Position = UDim2.new(0,230,0,56); followBtn.Text = "Seguir: OFF"; followBtn.Font = Enum.Font.GothamSemibold
    local followConn = nil
    followBtn.MouseButton1Click:Connect(function()
        if followConn then followConn:Disconnect(); followConn=nil; followBtn.Text="Seguir: OFF"; return end
        local t = findPlayerByName(targetBox.Text)
        if not t then warn("Alvo não encontrado"); return end
        followBtn.Text = "Seguir: ON"
        followConn = RunService.Heartbeat:Connect(function()
            if not t.Character or not LocalPlayer.Character then return end
            local thrp = t.Character:FindFirstChild("HumanoidRootPart"); local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if thrp and hrp then hrp.CFrame = CFrame.new(hrp.Position:Lerp(thrp.Position - thrp.CFrame.LookVector*2, 0.22), thrp.Position) end
        end)
        keepConn(followConn)
    end)

    local copyBtn = Instance.new("TextButton", page)
    copyBtn.Size = UDim2.new(0,200,0,36); copyBtn.Position = UDim2.new(0,12,0,106); copyBtn.Text = "Copiar roupa (local)"
    copyBtn.MouseButton1Click:Connect(function()
        local t = findPlayerByName(targetBox.Text)
        if not t or not t.Character then warn("Alvo não encontrado"); return end
        local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        for _,v in ipairs(myChar:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then pcall(function() v:Destroy() end) end end
        for _,acc in ipairs(myChar:GetChildren()) do if acc:IsA("Accessory") then pcall(function() acc:Destroy() end) end end
        for _,v in ipairs(t.Character:GetChildren()) do
            if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then pcall(function() v:Clone().Parent = myChar end) end
            if v:IsA("Accessory") then local ok,cl = pcall(function() return v:Clone() end); if ok and cl then cl.Parent = myChar; pcall(function() local mh = myChar:FindFirstChildOfClass("Humanoid"); if mh and mh.AddAccessory then mh:AddAccessory(cl) end end) end end
        end
        warn("Roupas copiadas localmente.")
    end)

    -- Nome RGB (igual foto)
    local nameLabel = Instance.new("TextLabel", page)
    nameLabel.Size = UDim2.new(0,80,0,24); nameLabel.Position = UDim2.new(0,12,0,160); nameLabel.BackgroundTransparency = 1; nameLabel.Font = Enum.Font.Gotham; nameLabel.TextColor3 = Color3.fromRGB(220,220,220); nameLabel.Text = "Seu nome:"

    local nameInput = Instance.new("TextBox", page)
    nameInput.Size = UDim2.new(0,320,0,32); nameInput.Position = UDim2.new(0,100,0,156)
    nameInput.PlaceholderText = "Digite (ex: DONO)"; nameInput.BackgroundColor3 = Color3.fromRGB(40,40,44); nameInput.TextColor3 = Color3.fromRGB(255,255,255); nameInput.Font = Enum.Font.Gotham

    local nameToggle = Instance.new("TextButton", page)
    nameToggle.Size = UDim2.new(0,140,0,36); nameToggle.Position = UDim2.new(0,440,0,156)
    nameToggle.Text = "Ativar Nome RGB"; nameToggle.Font = Enum.Font.GothamSemibold; nameToggle.BackgroundColor3 = Color3.fromRGB(80,160,80)

    local currBillboard, currConn, currText = nil, nil, nil
    local function createNameBox(texto)
        pcall(function() if currBillboard then currBillboard:Destroy() end end)
        if currConn then currConn:Disconnect(); currConn = nil end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local head = safeWaitForChild(char, "Head", 4)
        if not head then return end
        local billboard = Instance.new("BillboardGui", char)
        billboard.Name = "NiriNameBox"
        billboard.Adornee = head
        billboard.Size = UDim2.new(0,220,0,52)
        billboard.StudsOffset = Vector3.new(0,3.2,0)
        billboard.AlwaysOnTop = true
        local f = Instance.new("Frame", billboard); f.Size = UDim2.new(1,0,1,0);
        f.BackgroundColor3 = Color3.fromRGB(255,255,255);
        f.BackgroundTransparency = nameBgTransparency; -- use controlled transparency
        local fc = Instance.new("UICorner", f); fc.CornerRadius = UDim.new(0,12)
        local stroke = Instance.new("UIStroke", f); stroke.Thickness = 3; stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1,-10,1,0); lbl.Position = UDim2.new(0,5,0,0); lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 18; lbl.Text = tostring(texto); lbl.TextColor3 = Color3.fromRGB(18,18,18)
        currConn = RunService.RenderStepped:Connect(function()
            if not stroke.Parent then return end
            local t = tick() * 2
            local r = math.sin(t) * 127 + 128
            local g = math.sin(t + 2) * 127 + 128
            local b = math.sin(t + 4) * 127 + 128
            stroke.Color = Color3.fromRGB(clamp(r,0,255), clamp(g,0,255), clamp(b,0,255))
        end)
        currBillboard = billboard; currText = texto
    end

    nameToggle.MouseButton1Click:Connect(function()
        if currBillboard then
            pcall(function() currBillboard:Destroy() end)
            if currConn then currConn:Disconnect(); currConn=nil end
            currBillboard = nil; currConn = nil; currText = nil
            nameToggle.Text = "Ativar Nome RGB"; nameToggle.BackgroundColor3 = Color3.fromRGB(80,160,80)
            return
        end
        local txt = (nameInput.Text ~= "" and nameInput.Text) or "DONO"
        createNameBox(txt)
        nameToggle.Text = "Desativar Nome RGB"; nameToggle.BackgroundColor3 = Color3.fromRGB(160,60,60)
    end)

    -- ===== Controls for name BG transparency (0%, 50%, 100%) =====
    local nameTransLabel = Instance.new("TextLabel", page)
    nameTransLabel.Size = UDim2.new(0,80,0,20); nameTransLabel.Position = UDim2.new(0,12,0,204)
    nameTransLabel.BackgroundTransparency = 1; nameTransLabel.Font = Enum.Font.Gotham; nameTransLabel.TextSize = 14; nameTransLabel.TextColor3 = Color3.fromRGB(220,220,220)
    nameTransLabel.Text = "BG Nome:"

    local nameBg0Btn = Instance.new("TextButton", page)
    nameBg0Btn.Size = UDim2.new(0,80,0,28); nameBg0Btn.Position = UDim2.new(0,100,0,200)
    nameBg0Btn.Text = "0%"; nameBg0Btn.Font = Enum.Font.Gotham; nameBg0Btn.TextSize = 14; nameBg0Btn.BackgroundColor3 = Color3.fromRGB(70,70,70); nameBg0Btn.TextColor3 = Color3.fromRGB(255,255,255)
    local nameBg50Btn = Instance.new("TextButton", page)
    nameBg50Btn.Size = UDim2.new(0,80,0,28); nameBg50Btn.Position = UDim2.new(0,188,0,200)
    nameBg50Btn.Text = "50%"; nameBg50Btn.Font = Enum.Font.Gotham; nameBg50Btn.TextSize = 14; nameBg50Btn.BackgroundColor3 = Color3.fromRGB(70,70,70); nameBg50Btn.TextColor3 = Color3.fromRGB(255,255,255)
    local nameBg100Btn = Instance.new("TextButton", page)
    nameBg100Btn.Size = UDim2.new(0,80,0,28); nameBg100Btn.Position = UDim2.new(0,276,0,200)
    nameBg100Btn.Text = "100%"; nameBg100Btn.Font = Enum.Font.Gotham; nameBg100Btn.TextSize = 14; nameBg100Btn.BackgroundColor3 = Color3.fromRGB(70,70,70); nameBg100Btn.TextColor3 = Color3.fromRGB(255,255,255)

    local function updateCurrentBillboardTransparency()
        if currBillboard and currBillboard:IsDescendantOf(game) then
            local f = currBillboard:FindFirstChildWhichIsA("Frame")
            if f then
                pcall(function() f.BackgroundTransparency = nameBgTransparency end)
            end
        end
    end

    nameBg0Btn.MouseButton1Click:Connect(function()
        nameBgTransparency = 0
        updateCurrentBillboardTransparency()
    end)
    nameBg50Btn.MouseButton1Click:Connect(function()
        nameBgTransparency = 0.5
        updateCurrentBillboardTransparency()
    end)
    nameBg100Btn.MouseButton1Click:Connect(function()
        nameBgTransparency = 1
        updateCurrentBillboardTransparency()
    end)

    keepConn(LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.8)
        if currText then pcall(function() createNameBox(currText) end) end
    end))
end

-- ===== Casas page (Brookhaven) =====
do
    local page = pages["Casas"]
    local title = Instance.new("TextLabel", page)
    title.Size = UDim2.new(1,-24,0,24); title.Position = UDim2.new(0,12,0,12)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Color3.fromRGB(230,230,230)
    title.Text = "Casas (Brookhaven) - lista de plots detectados"

    local refreshBtn = Instance.new("TextButton", page)
    refreshBtn.Size = UDim2.new(0,140,0,36); refreshBtn.Position = UDim2.new(1,-156,0,12)
    refreshBtn.Text = "Atualizar lista"; refreshBtn.Font = Enum.Font.GothamSemibold; refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local scroll = Instance.new("ScrollingFrame", page); scroll.Size = UDim2.new(1,-24,1,-72); scroll.Position = UDim2.new(0,12,0,52); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    local listLayout = Instance.new("UIListLayout", scroll); listLayout.Padding = UDim.new(0,8); listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function detectPlots()
        local candidates = {}
        for _,v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and (v.Name:lower():find("plot") or v.Name:lower():find("house")) then
                table.insert(candidates, v)
            end
        end
        for _,f in ipairs(Workspace:GetChildren()) do
            local n = f.Name:lower()
            if n == "plots" or n == "houses" or n:find("house") then
                for _,m in ipairs(f:GetDescendants()) do if m:IsA("Model") then table.insert(candidates, m) end end
            end
        end
        local seen = {}
        local out = {}
        for _,v in ipairs(candidates) do if not seen[v] then seen[v] = true; table.insert(out, v) end end
        return out
    end

    local function getPlotOwner(plot)
        local owner = nil
        local sv = plot:FindFirstChild("Owner") or plot:FindFirstChild("OwnerName") or plot:FindFirstChild("OwnerValue")
        if sv and sv:IsA("StringValue") then owner = sv.Value end
        if not owner then
            for _,c in ipairs(plot:GetDescendants()) do
                if c:IsA("StringValue") and (c.Name:lower():find("owner") or c.Name:lower():find("name")) then owner = c.Value; break end
            end
        end
        if not owner then
            for _,c in ipairs(plot:GetDescendants()) do
                if c:IsA("TextLabel") and c.Text and c.Text ~= "" then owner = c.Text; break end
            end
        end
        return owner or "Sem dono"
    end

    local function clearList()
        for _,ch in ipairs(scroll:GetChildren()) do if not ch:IsA("UIListLayout") then ch:Destroy() end end
    end

    local function buildList()
        clearList()
        local plots = detectPlots()
        if #plots == 0 then
            local none = Instance.new("TextLabel", scroll); none.Size = UDim2.new(1,-20,0,36); none.Position = UDim2.new(0,10,0,10)
            none.BackgroundTransparency = 1; none.Font = Enum.Font.Gotham; none.TextSize = 14; none.TextColor3 = Color3.fromRGB(200,200,200)
            none.Text = "Nenhuma casa/plot detectada automaticamente."
            scroll.CanvasSize = UDim2.new(0,0,0,60)
            return
        end

        for i,plot in ipairs(plots) do
            local owner = getPlotOwner(plot)
            local entry = Instance.new("Frame", scroll); entry.Size = UDim2.new(1,-20,0,72); entry.BackgroundColor3 = Color3.fromRGB(36,36,40)
            local ec = Instance.new("UICorner", entry); ec.CornerRadius = UDim.new(0,8)
            local lbl = Instance.new("TextLabel", entry); lbl.Size = UDim2.new(0.6,-10,1,0); lbl.Position = UDim2.new(0,10,0,0)
            lbl.BackgroundTransparency = 1; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Text = string.format("%s\nDono: %s", tostring(plot.Name), tostring(owner))

            local tp = Instance.new("TextButton", entry); tp.Size = UDim2.new(0,100,0,28); tp.Position = UDim2.new(1,-110,0,8)
            tp.Text = "Teleportar"; tp.Font = Enum.Font.GothamSemibold; tp.BackgroundColor3 = Color3.fromRGB(60,120,60); local tpc = Instance.new("UICorner", tp); tpc.CornerRadius = UDim.new(0,6)

            local unban = Instance.new("TextButton", entry); unban.Size = UDim2.new(0,100,0,28); unban.Position = UDim2.new(1,-110,0,36)
            unban.Text = "Tirar ban"; unban.Font = Enum.Font.GothamSemibold; unban.BackgroundColor3 = Color3.fromRGB(170,90,40); local ubc = Instance.new("UICorner", unban); ubc.CornerRadius = UDim.new(0,6)

            local thru = Instance.new("TextButton", entry); thru.Size = UDim2.new(0,100,0,28); thru.Position = UDim2.new(1,-222,0,36)
            thru.Text = "Atravessar"; thru.Font = Enum.Font.GothamSemibold; thru.BackgroundColor3 = Color3.fromRGB(80,80,160); local thrc = Instance.new("UICorner", thru); thrc.CornerRadius = UDim.new(0,6)

            tp.MouseButton1Click:Connect(function()
                local dest = nil
                for _,c in ipairs(plot:GetDescendants()) do if c:IsA("BasePart") and (c.Name:lower():find("door") or c.Name:lower():find("entrance") or c.Name:lower():find("front")) then dest = c; break end end
                if not dest and plot.PrimaryPart then dest = plot.PrimaryPart end
                if dest then
                    local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
                    if hrp then pcall(function() hrp.CFrame = dest.CFrame * CFrame.new(0,0,4) end) end
                else warn("Não foi possível localizar porta/posição da casa.") end
            end)

            unban.MouseButton1Click:Connect(function()
                warn("Tentativa: remover ban (cliente) — não garante resultado server-side.")
                local dest = nil
                for _,c in ipairs(plot:GetDescendants()) do if c:IsA("BasePart") and (c.Name:lower():find("door") or c.Name:lower():find("entrance")) then dest = c; break end end
                local pos = dest and dest.Position or (plot.PrimaryPart and plot.PrimaryPart.Position)
                if pos then
                    local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
                    if hrp then pcall(function() hrp.CFrame = CFrame.new(pos) end) end
                    task.wait(0.25)
                    local found=false
                    for _,obj in ipairs(plot:GetDescendants()) do
                        if (obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt")) and obj.Parent then
                            local ppos = nil
                            if obj:IsA("ClickDetector") and obj.Parent:IsA("BasePart") then ppos = obj.Parent.Position
                            elseif obj:IsA("ProximityPrompt") and obj.Parent:IsA("BasePart") then ppos = obj.Parent.Position end
                            if ppos and (ppos - pos).Magnitude < 18 then
                                pcall(function()
                                    if obj:IsA("ClickDetector") then obj:MouseClick(LocalPlayer) end
                                    if obj:IsA("ProximityPrompt") then pcall(function() obj:InputHoldBegin() end); task.wait(0.1); pcall(function() obj:InputHoldEnd() end) end
                                end)
                                found = true
                                task.wait(0.12)
                            end
                        end
                    end
                    if found then warn("Interações feitas (não garante permissão).") else warn("Nenhuma interação detectada.") end
                else warn("Posição da casa não encontrada.") end
            end)

            thru.MouseButton1Click:Connect(function()
                local inside = nil
                for _,c in ipairs(plot:GetDescendants()) do if c:IsA("BasePart") and (c.Name:lower():find("inside") or c.Name:lower():find("interior") or c.Name:lower():find("living")) then inside = c; break end end
                if not inside and plot.PrimaryPart then inside = plot.PrimaryPart end
                if inside then
                    local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
                    if hrp then pcall(function() hrp.CFrame = inside.CFrame * CFrame.new(0,1,0) end) end
                else warn("Interior não detectado.") end
            end)
        end

        scroll.CanvasSize = UDim2.new(0,0,0, #plots * 82)
    end

    refreshBtn.MouseButton1Click:Connect(buildList)
    buildList()
    keepConn(Workspace.DescendantAdded:Connect(function() task.delay(0.5, buildList) end))
    keepConn(Workspace.DescendantRemoving:Connect(function() task.delay(0.5, buildList) end))
end

-- ===== Carros page =====
do
    local page = pages["Carros"]
    local info = Instance.new("TextLabel", page); info.Size = UDim2.new(1,-24,0,24); info.Position = UDim2.new(0,12,0,12); info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham; info.TextSize = 14; info.TextColor3 = Color3.fromRGB(220,220,220); info.Text = "Controle de veículo próximo (client-side)."

    local findBtn = Instance.new("TextButton", page); findBtn.Size = UDim2.new(0,160,0,36); findBtn.Position = UDim2.new(0,12,0,52); findBtn.Text = "Encontrar Veículo"
    local foundLabel = Instance.new("TextLabel", page); foundLabel.Size = UDim2.new(0,520,0,36); foundLabel.Position = UDim2.new(0,188,0,52); foundLabel.BackgroundTransparency = 1; foundLabel.Font = Enum.Font.Gotham; foundLabel.TextColor3 = Color3.fromRGB(220,220,220); foundLabel.Text = "Nenhum veículo selecionado"

    local function findNearestVehicle(maxRange)
        maxRange = maxRange or 100
        local myChar = LocalPlayer.Character; if not myChar or not myChar.PrimaryPart then return nil end
        local myPos = myChar.PrimaryPart.Position
        local nearest, nd = nil, 1e9
        for _,obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("VehicleSeat") or (obj:IsA("Model") and obj.Name:lower():find("vehicle")) then
                local model = obj:IsA("VehicleSeat") and obj.Parent or obj
                if model.PrimaryPart then
                    local d = (model.PrimaryPart.Position - myPos).Magnitude
                    if d < nd and d <= maxRange then nd = d; nearest = model end
                end
            end
        end
        return nearest
    end

    local selectedVehicle = nil
    findBtn.MouseButton1Click:Connect(function()
        local v = findNearestVehicle(120)
        if v then selectedVehicle = v; foundLabel.Text = "Selecionado: "..(v.Name or "Veículo") else foundLabel.Text = "Nenhum veículo próximo encontrado" end
    end)

    -- Sound
    local soundBox = Instance.new("TextBox", page); soundBox.Size = UDim2.new(0,260,0,32); soundBox.Position = UDim2.new(0,12,0,108); soundBox.PlaceholderText = "ID da música (apenas números)"; soundBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local playBtn = Instance.new("TextButton", page); playBtn.Size = UDim2.new(0,100,0,32); playBtn.Position = UDim2.new(0,288,0,108); playBtn.Text = "Tocar"
    local currentSound = nil
    playBtn.MouseButton1Click:Connect(function()
        if not selectedVehicle then warn("Selecione veículo primeiro") return end
        local id = tostring(soundBox.Text or "")
        if id == "" then warn("Digite ID") return end
        local parent = selectedVehicle.PrimaryPart or selectedVehicle:FindFirstChildWhichIsA("BasePart") or selectedVehicle
        if currentSound then pcall(function() currentSound:Stop(); currentSound:Destroy() end); currentSound = nil end
        local s = Instance.new("Sound", parent); s.Name = "NiriCarSound"; s.Looped = true; s.SoundId = "rbxassetid://"..id
        pcall(function() s:Play() end)
        currentSound = s
    end)

    -- Speed
    local speedBox = Instance.new("TextBox", page); speedBox.Size = UDim2.new(0,140,0,32); speedBox.Position = UDim2.new(0,12,0,156); speedBox.PlaceholderText = "MaxSpeed (ex:100)"
    speedBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local speedBtn = Instance.new("TextButton", page); speedBtn.Size = UDim2.new(0,140,0,32); speedBtn.Position = UDim2.new(0,164,0,156); speedBtn.Text = "Aplicar Veloc."
    speedBtn.MouseButton1Click:Connect(function()
        if not selectedVehicle then warn("Selecione veículo"); return end
        local val = tonumber(speedBox.Text); if not val then warn("Valor inválido"); return end
        local seat = nil
        for _,d in ipairs(selectedVehicle:GetDescendants()) do if d:IsA("VehicleSeat") then seat = d; break end end
        if seat then pcall(function() seat.MaxSpeed = val end); warn("Tentativa de ajustar velocidade (pode ser revertido).") else warn("VehicleSeat não encontrado.") end
    end)

    -- Color
    local rBox = Instance.new("TextBox", page); rBox.Size = UDim2.new(0,80,0,32); rBox.Position = UDim2.new(0,12,0,204); rBox.PlaceholderText = "R"; rBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local gBox = Instance.new("TextBox", page); gBox.Size = UDim2.new(0,80,0,32); gBox.Position = UDim2.new(0,100,0,204); gBox.PlaceholderText = "G"; gBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local bBox = Instance.new("TextBox", page); bBox.Size = UDim2.new(0,80,0,32); bBox.Position = UDim2.new(0,188,0,204); bBox.PlaceholderText = "B"; bBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local colorBtn = Instance.new("TextButton", page); colorBtn.Size = UDim2.new(0,140,0,32); colorBtn.Position = UDim2.new(0,276,0,204); colorBtn.Text = "Aplicar Cor"
    colorBtn.MouseButton1Click:Connect(function()
        if not selectedVehicle then warn("Selecione veículo"); return end
        local r,g,b = tonumber(rBox.Text), tonumber(gBox.Text), tonumber(bBox.Text)
        if not r or not g or not b then warn("RGB inválido"); return end
        r,g,b = clamp(r,0,255), clamp(g,0,255), clamp(b,0,255)
        for _,part in ipairs(selectedVehicle:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.Color = Color3.fromRGB(r,g,b) end) end end
        warn("Cor aplicada localmente (pode ser revertido).")
    end)
end

-- ===== Poderes (Fly / Speed / Jump / Noclip) =====
do
    local page = pages["Poderes"]
    local info = Instance.new("TextLabel", page); info.Size = UDim2.new(1,-24,0,24); info.Position = UDim2.new(0,12,0,12); info.BackgroundTransparency = 1
    info.Font = Enum.Font.Gotham; info.TextSize = 14; info.TextColor3 = Color3.fromRGB(220,220,220); info.Text = "Poderes do jogador (client-side)."

    -- Fly
    local flyBtn = Instance.new("TextButton", page); flyBtn.Size = UDim2.new(0,160,0,36); flyBtn.Position = UDim2.new(0,12,0,52); flyBtn.Text = "Fly: OFF"; flyBtn.Font = Enum.Font.GothamSemibold
    local flying = false; local flyVel, flyGyro = nil, nil
    local flySpeed = 80
    local flyConn = nil
    local function enableFly()
        if not LocalPlayer.Character then return end
        if flying then return end
        local hrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3); if not hrp then return end
        flyVel = Instance.new("BodyVelocity", hrp); flyVel.MaxForce = Vector3.new(1e5,1e5,1e5); flyVel.Velocity = Vector3.new(0,0,0)
        flyGyro = Instance.new("BodyGyro", hrp); flyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5); flyGyro.D = 10
        flying = true
        flyBtn.Text = "Fly: ON"
        flyConn = RunService.RenderStepped:Connect(function()
            if not flying or not hrp then return end
            local cam = workspace.CurrentCamera
            local move = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + (cam.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - (cam.CFrame.LookVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - (cam.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + (cam.CFrame.RightVector) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            local vel = (move.Magnitude > 0) and (move.Unit * flySpeed) or Vector3.new(0,0,0)
            pcall(function() if flyVel then flyVel.Velocity = vel end; if flyGyro then flyGyro.CFrame = workspace.CurrentCamera.CFrame end end)
        end)
        keepConn(flyConn)
    end
    local function disableFly()
        flying = false
        if flyVel then pcall(function() flyVel:Destroy() end); flyVel=nil end
        if flyGyro then pcall(function() flyGyro:Destroy() end); flyGyro=nil end
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        flyBtn.Text = "Fly: OFF"
    end
    flyBtn.MouseButton1Click:Connect(function() if flying then disableFly() else enableFly() end end)

    -- Speed
    local speedBox = Instance.new("TextBox", page); speedBox.Size = UDim2.new(0,120,0,32); speedBox.Position = UDim2.new(0,12,0,110); speedBox.PlaceholderText = "WalkSpeed"
    speedBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local speedBtn = Instance.new("TextButton", page); speedBtn.Size = UDim2.new(0,120,0,32); speedBtn.Position = UDim2.new(0,144,0,110); speedBtn.Text = "Aplicar Speed"
    speedBtn.MouseButton1Click:Connect(function()
        local v = tonumber(speedBox.Text); if not v then warn("Speed inválida"); return end
        local char = LocalPlayer.Character; if not char then warn("Character não encontrado"); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.WalkSpeed = v end); warn("WalkSpeed aplicado (apenas localmente).") end
    end)

    -- Jump
    local jumpBox = Instance.new("TextBox", page); jumpBox.Size = UDim2.new(0,120,0,32); jumpBox.Position = UDim2.new(0,12,0,156); jumpBox.PlaceholderText = "JumpPower"
    jumpBox.BackgroundColor3 = Color3.fromRGB(40,40,44)
    local jumpBtn = Instance.new("TextButton", page); jumpBtn.Size = UDim2.new(0,120,0,32); jumpBtn.Position = UDim2.new(0,144,0,156); jumpBtn.Text = "Aplicar Jump"
    jumpBtn.MouseButton1Click:Connect(function()
        local v = tonumber(jumpBox.Text); if not v then warn("Jump inválido"); return end
        local char = LocalPlayer.Character; if not char then warn("Character não encontrado"); return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then pcall(function() humanoid.JumpPower = v end); warn("JumpPower aplicado (apenas localmente).") end
    end)

    -- Noclip
    local noclipBtn = Instance.new("TextButton", page); noclipBtn.Size = UDim2.new(0,160,0,36); noclipBtn.Position = UDim2.new(0,12,0,204); noclipBtn.Text = "Noclip: OFF"
    local noclipOn = false; local noclipConn = nil
    noclipBtn.MouseButton1Click:Connect(function()
        noclipOn = not noclipOn
        if not noclipOn then
            noclipBtn.Text = "Noclip: OFF"
            if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
            local c = LocalPlayer.Character
            if c then for _,part in ipairs(c:GetDescendants()) do if part:IsA("BasePart") then pcall(function() part.CanCollide = true end) end end end
            return
        end
        noclipBtn.Text = "Noclip: ON"
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then
                for _,part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then pcall(function() part.CanCollide = false end) end
                end
            end
        end)
        keepConn(noclipConn)
    end)
end

-- ===== Jogadores page (lista + puxar) =====
do
    local page = pages["Jogadores"]
    local title = Instance.new("TextLabel", page); title.Size = UDim2.new(1,-24,0,28); title.Position = UDim2.new(0,12,0,12); title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold; title.TextSize = 14; title.TextColor3 = Color3.fromRGB(230,230,230); title.Text = "Jogadores no mapa"

    local refreshBtn = Instance.new("TextButton", page); refreshBtn.Size = UDim2.new(0,140,0,34); refreshBtn.Position = UDim2.new(1,-156,0,10); refreshBtn.Text = "Atualizar"; refreshBtn.Font = Enum.Font.GothamSemibold; refreshBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    local scroll = Instance.new("ScrollingFrame", page); scroll.Size = UDim2.new(1,-24,1,-64); scroll.Position = UDim2.new(0,12,0,52); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 6
    local layout = Instance.new("UIListLayout", scroll); layout.Padding = UDim.new(0,8); layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function clear()
        for _,c in ipairs(scroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
    end

    -- robust try-pull implementation (best-effort)
    local function tryPullPlayer(target)
        if not target or not target.Character then warn("Alvo inválido"); return end
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not thrp then warn("HRP do alvo não encontrado"); return end
        local myhrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
        if not myhrp then warn("Seu HRP não encontrado"); return end

        -- 1) Attempt direct CFrame set
        local ok1, e1 = pcall(function()
            thrp.CFrame = myhrp.CFrame * CFrame.new(0,0,3)
        end)
        if ok1 then warn("Tentativa via CFrame enviada (servidor pode bloquear)."); return end

        -- 2) Try BodyPosition anchored to target HRP (may replicate if server allows)
        local ok2, e2 = pcall(function()
            local bp = Instance.new("BodyPosition")
            bp.MaxForce = Vector3.new(1e6,1e6,1e6)
            bp.P = 1e5
            bp.Position = myhrp.Position + Vector3.new(0,1,0)
            bp.Parent = thrp
            task.delay(0.9, function() pcall(function() bp:Destroy() end) end)
        end)
        if ok2 then warn("Tentativa: puxar com BodyPosition (não garantido)."); return end

        -- 3) Try applying BodyVelocity to 'nudge' the target toward you
        local ok3, e3 = pcall(function()
            local dir = (myhrp.Position - thrp.Position).Unit
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 5e4
            bv.Velocity = dir * 80 + Vector3.new(0,10,0)
            bv.Parent = thrp
            task.delay(0.7, function() pcall(function() bv:Destroy() end) end)
        end)
        if ok3 then warn("Tentativa: empurrão com BodyVelocity enviada.") else warn("Falha ao tentar puxar:", tostring(e3 or e2 or e1)) end
    end

    local function build()
        clear()
        for _,p in ipairs(Players:GetPlayers()) do
            local entry = Instance.new("Frame", scroll); entry.Size = UDim2.new(1,-24,0,56); entry.BackgroundColor3 = Color3.fromRGB(36,36,40)
            local ec = Instance.new("UICorner", entry); ec.CornerRadius = UDim.new(0,8)
            local lbl = Instance.new("TextLabel", entry); lbl.Size = UDim2.new(0.5,-10,1,0); lbl.Position = UDim2.new(0,10,0,0); lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Gotham; lbl.TextSize = 14; lbl.TextColor3 = Color3.fromRGB(230,230,230)
            lbl.Text = p.Name.." ("..(p.DisplayName or "")..")"

            local pullBtn = Instance.new("TextButton", entry); pullBtn.Size = UDim2.new(0,92,0,28); pullBtn.Position = UDim2.new(1,-104,0,8)
            pullBtn.Text = "Puxar"; pullBtn.Font = Enum.Font.GothamSemibold; pullBtn.BackgroundColor3 = Color3.fromRGB(150,60,60)
            local teleportMeBtn = Instance.new("TextButton", entry); teleportMeBtn.Size = UDim2.new(0,92,0,28); teleportMeBtn.Position = UDim2.new(1,-104,0,32)
            teleportMeBtn.Text = "Ir p/ ele"; teleportMeBtn.Font = Enum.Font.GothamSemibold; teleportMeBtn.BackgroundColor3 = Color3.fromRGB(80,120,200)

            pullBtn.MouseButton1Click:Connect(function()
                if p == LocalPlayer then warn("Você não pode puxar a si mesmo.") return end
                warn("Iniciando tentativa de puxar "..p.Name.." — pode não funcionar em servidores protegidos.")
                tryPullPlayer(p)
            end)
            teleportMeBtn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local myhrp = safeWaitForChild(LocalPlayer.Character, "HumanoidRootPart", 3)
                    if myhrp then pcall(function() myhrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end) end
                else warn("Alvo sem character.") end
            end)
        end
        scroll.CanvasSize = UDim2.new(0,0,0, #Players:GetPlayers()*66)
    end

    refreshBtn.MouseButton1Click:Connect(build)
    build()
    keepConn(Players.PlayerAdded:Connect(build)); keepConn(Players.PlayerRemoving:Connect(build))
end

-- ===== Flings / Áudios / Avatar placeholders =====
do
    local p = pages["Flings"]; local l = Instance.new("TextLabel", p); l.Size = UDim2.new(1,-24,1,-24); l.Position = UDim2.new(0,12,0,12); l.BackgroundTransparency = 1; l.Font = Enum.Font.Gotham; l.TextSize = 14; l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Text = "Flings: adicione rotinas específicas (placeholder)."

    local a = pages["Áudios"]; local la = Instance.new("TextLabel", a); la.Size = UDim2.new(1,-24,1,-24); la.Position = UDim2.new(0,12,0,12); la.BackgroundTransparency = 1; la.Font = Enum.Font.Gotham; la.TextSize = 14; la.TextColor3 = Color3.fromRGB(220,220,220)
    la.Text = "Áudios: gerenciador de sons (placeholder)."

    local av = pages["Avatar"]; local avl = Instance.new("TextLabel", av); avl.Size = UDim2.new(1,-24,1,-24); avl.Position = UDim2.new(0,12,0,12); avl.BackgroundTransparency = 1; avl.Font = Enum.Font.Gotham; avl.TextSize = 14; avl.TextColor3 = Color3.fromRGB(220,220,220)
    avl.Text = "Avatar: trocas rápidas / visuais locais (placeholder)."
end

-- ===== Ray & Close & Expand behavior =====
ray.MouseButton1Click:Connect(function()
    root.Visible = not root.Visible
end)
closeBtn.MouseButton1Click:Connect(function()
    root.Visible = false
end)

local expanded = true
local largeSize = UDim2.new(0, 920, 0, 560)
local smallSize = UDim2.new(0, 920, 0, 300)
expandBtn.MouseButton1Click:Connect(function()
    expanded = not expanded
    if expanded then
        expandBtn.Text = "🔼"
        TweenService:Create(root, TweenInfo.new(0.25), {Size = largeSize}):Play()
    else
        expandBtn.Text = "🔽"
        TweenService:Create(root, TweenInfo.new(0.25), {Size = smallSize}):Play()
    end
end)

keepConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Escape then root.Visible = not root.Visible end
end))

-- ===== Slider behavior (arrastar thumb para ajustar escala) =====
local sliderDragging = false
local sliderStartPos = nil
local thumbStartX = nil
local sliderMinScale = 0.6 -- 60% of original
local sliderMaxScale = 1.5 -- 150% of original
local sliderWidth = sliderBar.AbsoluteSize.X

local function applyScaleFromThumb()
    local rel = 0
    local denom = (sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X)
    if denom ~= 0 then
        rel = thumb.Position.X.Offset / denom
    end
    rel = clamp(rel, 0, 1)
    local scale = sliderMinScale + (sliderMaxScale - sliderMinScale) * rel
    -- apply scale with tween (smooth)
    local newX = 920 * scale
    local newY = 560 * scale
    TweenService:Create(root, TweenInfo.new(0.18), {Size = UDim2.new(0, newX, 0, newY)}):Play()
end

thumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        sliderStartPos = input.Position
        thumbStartX = thumb.Position.X.Offset
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then sliderDragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position.X - sliderStartPos.X
        local newOffset = thumbStartX + delta
        local minOff = 0
        local maxOff = sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X
        newOffset = clamp(newOffset, minOff, maxOff)
        thumb.Position = UDim2.new(0, newOffset, 0, 0)
        applyScaleFromThumb()
    end
end)

-- Ensure sizes update if GUI re-layout changes
sliderBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
    -- keep thumb in bounds if needed
    local maxOff = math.max(0, sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X)
    local off = clamp(thumb.Position.X.Offset, 0, maxOff)
    thumb.Position = UDim2.new(0, off, 0, 0)
end)

-- start with thumb at 80% position (scale ~1.1)
local function initThumb()
    -- compute desired offset for middle scale (1.0)
    local rel = (1.0 - sliderMinScale) / (sliderMaxScale - sliderMinScale)
    local maxOff = math.max(0, sliderBar.AbsoluteSize.X - thumb.AbsoluteSize.X)
    thumb.Position = UDim2.new(0, clamp(math.floor(maxOff * rel), 0, maxOff), 0, 0)
    applyScaleFromThumb()
end
-- call init after layout
task.defer(function()
    task.wait(0.1)
    initThumb()
end)

-- ===== Keep global and finish =====
_G.NiriHub.root = root
_G.NiriHub.gui = screenGui

-- apply initial panel transparency (default)
applyPanelTransparency(panelTransparency)

print("Niri Hub ⚡ Ultimate (com slider, puxar e controles de transparência) carregado. Lembre-se: muitas ações são client-side e podem não funcionar em servidores protegidos.")