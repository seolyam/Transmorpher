local addon, ns = ...

-- ============================================================
-- MISC TAB — Environment, Atmosphere, Analysis, Titles, HD Font, Optimization
-- ============================================================

local mainFrame = ns.mainFrame
local miscTab = mainFrame.tabs.env

local subTabBar = CreateFrame("Frame", nil, miscTab)
subTabBar:SetPoint("TOPLEFT", 8, -18)
subTabBar:SetPoint("TOPRIGHT", -8, -18)
subTabBar:SetHeight(30)

local envPanel = CreateFrame("Frame", "$parentEnvPanel", miscTab)
envPanel:SetPoint("TOPLEFT", 0, -50); envPanel:SetPoint("BOTTOMRIGHT")

-- The Environment sub-tab now holds Time Control + Weather & Sky + Zone Atmosphere,
-- which is taller than the panel, so its content scrolls. All Environment cards
-- parent to envContent.
local envScroll = CreateFrame("ScrollFrame", "$parentEnvScroll", envPanel, "UIPanelScrollFrameTemplate")
envScroll:SetPoint("TOPLEFT", 0, -4)
envScroll:SetPoint("BOTTOMRIGHT", -28, 4)
local envContent = CreateFrame("Frame", nil, envScroll)
envContent:SetSize(1, 900)
envScroll:SetScrollChild(envContent)
envScroll:SetScript("OnSizeChanged", function(self, w) if w and w > 1 then envContent:SetWidth(w) end end)

local atmospherePanel = CreateFrame("Frame", "$parentAtmospherePanel", miscTab)
atmospherePanel:SetPoint("TOPLEFT", 0, -50); atmospherePanel:SetPoint("BOTTOMRIGHT"); atmospherePanel:Hide()

-- The Atmosphere sub-tab has more cards (Draw Distance + Fog + Camera) than fit on
-- screen, so its content lives in a scroll frame. Without this the lower cards spill
-- out of the panel AND the mouse wheel lands on the sliders (silently changing far
-- clip / fog) instead of scrolling. All Atmosphere cards parent to atmosphereContent.
local atmosphereScroll = CreateFrame("ScrollFrame", "$parentAtmosphereScroll", atmospherePanel, "UIPanelScrollFrameTemplate")
atmosphereScroll:SetPoint("TOPLEFT", 0, -4)
atmosphereScroll:SetPoint("BOTTOMRIGHT", -28, 4)
local atmosphereContent = CreateFrame("Frame", nil, atmosphereScroll)
atmosphereContent:SetSize(1, 540)
atmosphereScroll:SetScrollChild(atmosphereContent)
atmosphereScroll:SetScript("OnSizeChanged", function(self, w) if w and w > 1 then atmosphereContent:SetWidth(w) end end)

local titlesPanel = CreateFrame("Frame", "$parentTitlesPanel", miscTab)
titlesPanel:SetPoint("TOPLEFT", 0, -50); titlesPanel:SetPoint("BOTTOMRIGHT"); titlesPanel:Hide()

local hdFontPanel = CreateFrame("Frame", "$parentHdFontPanel", miscTab)
hdFontPanel:SetPoint("TOPLEFT", 0, -50); hdFontPanel:SetPoint("BOTTOMRIGHT"); hdFontPanel:Hide()

local analysisPanel = CreateFrame("Frame", "$parentAnalysisPanel", miscTab)
analysisPanel:SetPoint("TOPLEFT", 0, -50); analysisPanel:SetPoint("BOTTOMRIGHT"); analysisPanel:Hide()

local playersPanel = CreateFrame("Frame", "$parentPlayersPanel", miscTab)
playersPanel:SetPoint("TOPLEFT", 0, -50); playersPanel:SetPoint("BOTTOMRIGHT"); playersPanel:Hide()

local miscSubTabButtons = {}
local activeMiscSubTab = "env"

local function CreateMiscSubTabBtn(key, text, registerWithLayout)
    local btn = CreateFrame("Button", nil, subTabBar)
    btn.key = key
    btn:SetSize(96, 30)
    local bg = btn:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture(1,1,1,0); btn.bg = bg
    local line = btn:CreateTexture(nil, "OVERLAY"); line:SetHeight(2)
    line:SetPoint("BOTTOMLEFT", 10, 0); line:SetPoint("BOTTOMRIGHT", -10, 0)
    line:SetTexture(1, 0.82, 0); line:Hide(); btn.line = line
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("CENTER"); fs:SetText(text); fs:SetTextColor(0.5,0.5,0.5); btn.fs = fs
    btn.SetActive = function(self, active)
        self.isActive = active
        if active then self.line:Show(); self.fs:SetTextColor(1,1,1); self.bg:SetTexture(1,1,1,0.05)
        else self.line:Hide(); self.fs:SetTextColor(0.5,0.5,0.5); self.bg:SetTexture(0,0,0,0) end
    end
    btn:SetScript("OnEnter", function(self) if not self.isActive then self.fs:SetTextColor(0.9,0.9,0.9); self.bg:SetTexture(1,1,1,0.03) end end)
    btn:SetScript("OnLeave", function(self) if not self.isActive then self.fs:SetTextColor(0.5,0.5,0.5); self.bg:SetTexture(0,0,0,0) end end)
    if registerWithLayout ~= false then
        table.insert(miscSubTabButtons, btn)
    end
    return btn
end

local btnEnv = CreateMiscSubTabBtn("env", "Environment")
local btnAtmosphere = CreateMiscSubTabBtn("atmosphere", "Atmosphere")
local btnPlayers = CreateMiscSubTabBtn("players", "Units")
local btnAnalysis = CreateMiscSubTabBtn("analysis", "Analysis")
local btnTitles = CreateMiscSubTabBtn("titles", "Titles")
local btnHdFont = CreateMiscSubTabBtn("hd", "HD Font")
local btnOpt = CreateMiscSubTabBtn("optimization", "Optimization")

local function LayoutMiscSubTabs()
    local totalWidth = subTabBar:GetWidth() or 0
    local count = #miscSubTabButtons
    if totalWidth <= 0 or count == 0 then return end

    local spacing = 4
    local buttonWidth = math.floor((totalWidth - spacing * (count - 1)) / count)
    if buttonWidth < 78 then buttonWidth = 78 end

    for index, button in ipairs(miscSubTabButtons) do
        button:ClearAllPoints()
        button:SetWidth(buttonWidth)
        if index == 1 then
            button:SetPoint("LEFT", subTabBar, "LEFT", 0, 0)
        else
            button:SetPoint("LEFT", miscSubTabButtons[index - 1], "RIGHT", spacing, 0)
        end
    end
end

subTabBar:SetScript("OnSizeChanged", LayoutMiscSubTabs)
LayoutMiscSubTabs()

local function ShowMiscSubTab(key)
    activeMiscSubTab = key

    envPanel[key == "env" and "Show" or "Hide"](envPanel)
    atmospherePanel[key == "atmosphere" and "Show" or "Hide"](atmospherePanel)
    playersPanel[key == "players" and "Show" or "Hide"](playersPanel)
    analysisPanel[key == "analysis" and "Show" or "Hide"](analysisPanel)
    titlesPanel[key == "titles" and "Show" or "Hide"](titlesPanel)
    hdFontPanel[key == "hd" and "Show" or "Hide"](hdFontPanel)
    if optimizationPanel then optimizationPanel[key == "optimization" and "Show" or "Hide"](optimizationPanel) end

    btnEnv:SetActive(key == "env")
    btnAtmosphere:SetActive(key == "atmosphere")
    btnPlayers:SetActive(key == "players")
    btnAnalysis:SetActive(key == "analysis")
    btnTitles:SetActive(key == "titles")
    btnHdFont:SetActive(key == "hd")
    btnOpt:SetActive(key == "optimization")
    PlaySound("gsTitleOptionOK")
end

btnEnv:SetScript("OnClick", function() ShowMiscSubTab("env") end)
btnAtmosphere:SetScript("OnClick", function() ShowMiscSubTab("atmosphere") end)
btnPlayers:SetScript("OnClick", function() ShowMiscSubTab("players") end)
btnAnalysis:SetScript("OnClick", function() ShowMiscSubTab("analysis") end)
btnTitles:SetScript("OnClick", function() ShowMiscSubTab("titles") end)
btnHdFont:SetScript("OnClick", function() ShowMiscSubTab("hd") end)
btnOpt:SetScript("OnClick", function() ShowMiscSubTab("optimization") end)
ShowMiscSubTab(activeMiscSubTab)

-- ============================================================
-- PLAYERS PANEL — distance culling: make far objects "not exist" for FPS.
-- Backed by the DLL's RenderObject hook (skips GetObjectModel/ShouldRender/
-- PreAnimate/Animate/draw for far objects — real FPS, not just a hidden draw).
-- Stateless per frame, so toggling/sliding restores instantly. Never the local
-- player (or units the local player owns).
-- ============================================================
do
    local PLAYERS_MIN_DIST = 0
    local PLAYERS_MAX_DIST = 200

    local playersCard = CreateFrame("Frame", nil, playersPanel)
    playersCard:SetPoint("TOPLEFT", 8, -8); playersCard:SetPoint("TOPRIGHT", -8, -8); playersCard:SetHeight(346)
    playersCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    playersCard:SetBackdropColor(0.05, 0.055, 0.07, 0.93); playersCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

    local title = playersCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12); title:SetText("|cffF5C842Distance Culling (FPS)|r")

    local desc = playersCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    desc:SetPoint("RIGHT", playersCard, "RIGHT", -14, 0); desc:SetJustifyH("LEFT")
    desc:SetText("Skips ALL rendering and animation work for far objects, as if they don't exist — a real FPS boost in crowds and raids. Your own character (and your own pet) are never affected.")
    desc:SetTextColor(0.7, 0.7, 0.7)

    local applyingPlayers = false

    -- Helper: push the full current state to the DLL (radius + categories + master).
    local function PushHideState()
        if not ns.IsMorpherReady() then return end
        local s = ns.GetSettings()
        ns.SendMorphCommand("SET:HIDE_PLAYERS_DIST:" .. (s.hidePlayersDistance or 30))
        ns.SendMorphCommand("SET:HIDE_PLAYERS:" .. (s.hideCatPlayers and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_PETS:" .. (s.hideCatPets and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_NPCS:" .. (s.hideCatNpcs and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_OBJECTS:" .. (s.hideCatObjects and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_CORPSES:" .. (s.hideCatCorpses and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_SHOW_GROUP:" .. (s.hideShowGroup and "1" or "0"))
        if ns.PushHideGroupList then ns.PushHideGroupList(true) end
        ns.SendMorphCommand("SET:HIDE_SHADOWS:" .. (s.hideShadows and "1" or "0"))
        ns.SendMorphCommand("SET:HIDE_PLAYERS_ENABLED:" .. (s.hidePlayersEnabled and "1" or "0"))
    end

    local enableCb = ns.CreateCheckbox(playersCard, "|cffF5C842Enable Distance Culling|r", "Master switch. Hides the categories below past the distance. Local player is never affected.")
    enableCb:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    enableCb:SetScript("OnClick", function(self)
        if applyingPlayers then return end
        local checked = self:GetChecked() and true or false
        ns.GetSettings().hidePlayersEnabled = checked
        PushHideState()
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
    end)

    local distSlider = CreateFrame("Slider", "TransmorpherMiscHidePlayersSlider", playersCard, "OptionsSliderTemplate")
    distSlider:SetPoint("TOPLEFT", enableCb, "BOTTOMLEFT", 6, -26)
    distSlider:SetPoint("RIGHT", -24, 0)
    distSlider:SetHeight(18)
    distSlider:SetMinMaxValues(PLAYERS_MIN_DIST, PLAYERS_MAX_DIST)
    distSlider:SetValueStep(1)
    _G[distSlider:GetName() .. "Low"]:SetText(PLAYERS_MIN_DIST .. " yd")
    _G[distSlider:GetName() .. "High"]:SetText(PLAYERS_MAX_DIST .. " yd")
    _G[distSlider:GetName() .. "Text"]:SetText("Distance")

    distSlider:SetScript("OnValueChanged", function(self, value)
        local yards = math.floor((value or 0) + 0.5)
        local t = _G[self:GetName() .. "Text"]
        t:SetText("Hide past: " .. yards .. " yd"); t:SetTextColor(1, 0.82, 0)
        if applyingPlayers then return end
        ns.GetSettings().hidePlayersDistance = yards
        if ns.IsMorpherReady() then
            ns.SendMorphCommand("SET:HIDE_PLAYERS_DIST:" .. yards)
        end
    end)

    -- Category checkboxes ---------------------------------------------------
    local catBoxes = {}
    local function CreateCatCheckbox(label, tooltip, settingKey, cmd)
        local cb = ns.CreateCheckbox(playersCard, label, tooltip)
        cb:SetScript("OnClick", function(self)
            if applyingPlayers then return end
            local checked = self:GetChecked() and true or false
            ns.GetSettings()[settingKey] = checked
            if ns.IsMorpherReady() then
                ns.SendMorphCommand(cmd .. ":" .. (checked and "1" or "0"))
            end
            PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
        end)
        catBoxes[settingKey] = cb
        return cb
    end

    -- CVar-backed extra toggles (chat bubbles, sound effects) — global, not per-distance.
    local function CreateCVarCheckbox(label, tooltip, settingKey)
        local cb = ns.CreateCheckbox(playersCard, label, tooltip)
        cb:SetScript("OnClick", function(self)
            if applyingPlayers then return end
            ns.GetSettings()[settingKey] = self:GetChecked() and true or false
            if ns.ApplyHideCVars then ns.ApplyHideCVars() end
            PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
        end)
        return cb
    end

    local COL2 = 300

    -- Left column: what to cull past the distance
    local catHeader = playersCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catHeader:SetPoint("TOPLEFT", distSlider, "BOTTOMLEFT", -6, -16)
    catHeader:SetText("|cffA3A3A3Hide past the distance|r")

    local cbPlayers = CreateCatCheckbox("Other Players", "Hide other players' character models.", "hideCatPlayers", "SET:HIDE_PLAYERS")
    cbPlayers:SetPoint("TOPLEFT", catHeader, "BOTTOMLEFT", 4, -6)

    local cbPets = CreateCatCheckbox("Their Pets & Summons", "Hide pets, summons, totems and guardians owned by other players. Your own pet is never hidden.", "hideCatPets", "SET:HIDE_PETS")
    cbPets:SetPoint("TOPLEFT", cbPlayers, "BOTTOMLEFT", 0, -4)

    local cbNpcs = CreateCatCheckbox("All Other NPCs / Creatures", "Hide every other creature in the world. Biggest FPS gain in cities and raids.", "hideCatNpcs", "SET:HIDE_NPCS")
    cbNpcs:SetPoint("TOPLEFT", cbPets, "BOTTOMLEFT", 0, -4)

    local cbObjects = CreateCatCheckbox("Ground Effects & Objects", "Hide game objects and ground AoE spell effects (their \"traces\": Blizzard, Consecration, traps, banners...).", "hideCatObjects", "SET:HIDE_OBJECTS")
    cbObjects:SetPoint("TOPLEFT", cbNpcs, "BOTTOMLEFT", 0, -4)

    local cbCorpses = CreateCatCheckbox("Corpses", "Hide player/creature corpses past the distance.", "hideCatCorpses", "SET:HIDE_CORPSES")
    cbCorpses:SetPoint("TOPLEFT", cbObjects, "BOTTOMLEFT", 0, -4)

    -- Right column: extra global FPS toggles (apply everywhere, not just past the distance)
    local extraHeader = playersCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    extraHeader:SetPoint("TOPLEFT", catHeader, "TOPLEFT", COL2, 0)
    extraHeader:SetText("|cffA3A3A3Extra (max FPS, global)|r")

    local cbShadows = CreateCatCheckbox("Hide All Shadows", "Disable character/object ground shadows globally (incl. hidden players). Big FPS gain in crowds.", "hideShadows", "SET:HIDE_SHADOWS")
    cbShadows:SetPoint("TOPLEFT", extraHeader, "BOTTOMLEFT", 4, -6)

    local cbBubbles = CreateCVarCheckbox("Hide Chat Bubbles", "Hide the say/yell speech bubbles floating in the world.", "hideChatBubbles")
    cbBubbles:SetPoint("TOPLEFT", cbShadows, "BOTTOMLEFT", 0, -4)

    local cbSounds = CreateCVarCheckbox("Mute Sound Effects", "Mute world sound effects (keeps music & UI sounds).", "hideOtherSounds")
    cbSounds:SetPoint("TOPLEFT", cbBubbles, "BOTTOMLEFT", 0, -4)

    -- Protection: keep your party/raid (and their pets) always visible.
    local sepGroup = playersCard:CreateTexture(nil, "ARTWORK")
    sepGroup:SetHeight(1); sepGroup:SetPoint("TOPLEFT", cbCorpses, "BOTTOMLEFT", -4, -8)
    sepGroup:SetPoint("RIGHT", playersCard, "RIGHT", -14, 0); sepGroup:SetTexture(1, 1, 1, 0.08)

    local cbGroup = ns.CreateCheckbox(playersCard, "|cff44ff88Always show group / raid members|r", "Party and raid members (and their pets) are never hidden, no matter the distance.")
    cbGroup:SetPoint("TOPLEFT", sepGroup, "BOTTOMLEFT", 4, -6)
    cbGroup:SetScript("OnClick", function(self)
        if applyingPlayers then return end
        local checked = self:GetChecked() and true or false
        ns.GetSettings().hideShowGroup = checked
        if ns.IsMorpherReady() then
            ns.SendMorphCommand("SET:HIDE_SHOW_GROUP:" .. (checked and "1" or "0"))
            if ns.PushHideGroupList then ns.PushHideGroupList(true) end
        end
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
    end)

    local resetBtn = ns.CreateGoldenButton(nil, playersCard)
    resetBtn:SetSize(86, 22)
    resetBtn:SetPoint("TOPRIGHT", playersCard, "TOPRIGHT", -12, -10)
    resetBtn:SetText("Reset")

    local function SyncWidgets()
        local s = ns.GetSettings()
        applyingPlayers = true
        local d = tonumber(s.hidePlayersDistance) or 30
        if d < PLAYERS_MIN_DIST then d = PLAYERS_MIN_DIST end
        if d > PLAYERS_MAX_DIST then d = PLAYERS_MAX_DIST end
        distSlider:SetValue(d)
        enableCb:SetChecked(s.hidePlayersEnabled and true or false)
        cbPlayers:SetChecked(s.hideCatPlayers and true or false)
        cbPets:SetChecked(s.hideCatPets and true or false)
        cbNpcs:SetChecked(s.hideCatNpcs and true or false)
        cbObjects:SetChecked(s.hideCatObjects and true or false)
        cbCorpses:SetChecked(s.hideCatCorpses and true or false)
        cbShadows:SetChecked(s.hideShadows and true or false)
        cbBubbles:SetChecked(s.hideChatBubbles and true or false)
        cbSounds:SetChecked(s.hideOtherSounds and true or false)
        cbGroup:SetChecked(s.hideShowGroup and true or false)
        applyingPlayers = false
    end

    resetBtn:SetScript("OnClick", function()
        local s = ns.GetSettings()
        s.hidePlayersEnabled = false
        s.hidePlayersDistance = 30
        s.hideCatPlayers = true
        s.hideCatPets = true
        s.hideCatNpcs = false
        s.hideCatObjects = false
        s.hideCatCorpses = false
        s.hideShowGroup = true
        s.hideShadows = false
        s.hideChatBubbles = false
        s.hideOtherSounds = false
        SyncWidgets()
        PushHideState()
        if ns.PushHideGroupList then ns.PushHideGroupList(true) end
        if ns.ApplyHideCVars then ns.ApplyHideCVars() end
        PlaySound("gsTitleOptionOK")
    end)

    playersPanel:SetScript("OnShow", SyncWidgets)
end

-- ============================================================
-- OPTIMIZATION PANEL
-- ============================================================
local ShowOptSubTab -- forward decl

local optPanel = CreateFrame("Frame", "$parentOptPanel", miscTab)
optPanel:SetPoint("TOPLEFT", 0, -50); optPanel:SetPoint("BOTTOMRIGHT"); optPanel:Hide()
optimizationPanel = optPanel

-- Optimization Sub-Tab Bar
local optSubTabBar = CreateFrame("Frame", nil, optPanel)
optSubTabBar:SetSize(320, 24); optSubTabBar:SetPoint("TOPLEFT", 4, -4)

local btnOptGeneral = CreateMiscSubTabBtn(1, "General Optimization", false)
btnOptGeneral:SetParent(optSubTabBar); btnOptGeneral:SetPoint("LEFT", 0, 0); btnOptGeneral:SetSize(140, 24)
btnOptGeneral:SetScript("OnClick", function() ShowOptSubTab(1) end)

local btnOptProtectedFile = CreateMiscSubTabBtn(2, "Protected File", false)
btnOptProtectedFile:SetParent(optSubTabBar); btnOptProtectedFile:SetPoint("LEFT", btnOptGeneral, "RIGHT", 4, 0); btnOptProtectedFile:SetSize(110, 24)
btnOptProtectedFile:SetScript("OnClick", function() ShowOptSubTab(2) end)

local optGeneralPanel = CreateFrame("Frame", nil, optPanel); optGeneralPanel:SetAllPoints()
local optProtectPanel = CreateFrame("Frame", nil, optPanel); optProtectPanel:SetAllPoints(); optProtectPanel:Hide()
local optProtectedFilePanel = CreateFrame("Frame", nil, optPanel); optProtectedFilePanel:SetAllPoints(); optProtectedFilePanel:Hide()

ShowOptSubTab = function(id)
    optGeneralPanel[id == 1 and "Show" or "Hide"](optGeneralPanel)
    optProtectPanel:Hide()
    optProtectedFilePanel[id == 2 and "Show" or "Hide"](optProtectedFilePanel)
    btnOptGeneral:SetActive(id == 1); btnOptProtectedFile:SetActive(id == 2)
    PlaySound("gsTitleOptionOK")
end
ShowOptSubTab(1)

-- ============================================================
-- OPT GENERAL (TOGGLES)
-- ============================================================
local optCard = CreateFrame("Frame", nil, optGeneralPanel)
optCard:SetPoint("TOPLEFT", 8, -32); optCard:SetPoint("BOTTOMRIGHT", -8, 8)
optCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
optCard:SetBackdropColor(0.05, 0.055, 0.07, 0.93); optCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local optTitle = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optTitle:SetPoint("TOPLEFT", 12, -12); optTitle:SetText("|cffF5C842Spell Visibility & Optimization|r")

-- Header lines are width-bounded to the card and wrap, so a long sentence can never
-- bleed past the card's right edge ("text leaking outside the panel").
local optDesc = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
optDesc:SetPoint("TOPLEFT", optTitle, "BOTTOMLEFT", 0, -4)
optDesc:SetPoint("RIGHT", optCard, "RIGHT", -14, 0); optDesc:SetJustifyH("LEFT")
optDesc:SetText("Toggle spell effects globally to maximize performance. Raid tiers on the right extend the always-active protected base list."); optDesc:SetTextColor(0.7, 0.7, 0.7)

local optWarning = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
optWarning:SetPoint("TOPLEFT", optDesc, "BOTTOMLEFT", 0, -2)
optWarning:SetPoint("RIGHT", optCard, "RIGHT", -14, 0); optWarning:SetJustifyH("LEFT")
optWarning:SetText("|cffFF4444Warning:|r Some settings may hide boss mechanics even with active filters.")
optWarning:SetTextColor(0.9, 0.3, 0.3)

    local optBenefit = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    optBenefit:SetPoint("TOPLEFT", optWarning, "BOTTOMLEFT", 0, -6)
    optBenefit:SetPoint("RIGHT", optCard, "RIGHT", -14, 0); optBenefit:SetJustifyH("LEFT")
    optBenefit:SetText("|cff44ff44This optimization provides a massive FPS boost in raids and crowded areas.|r")

local optimizationCheckboxes = {}

local function CreateOptCheckbox(name, label, tooltip, settingKey, cmdPrefix)
    local cb = CreateFrame("CheckButton", "$parent"..name, optCard, "ChatConfigCheckButtonTemplate")
    cb:SetSize(22, 22)
    if ns.NormalizeCheckboxHitRect then ns.NormalizeCheckboxHitRect(cb) end
    local text = _G[cb:GetName().."Text"]
    text:SetText(label); text:SetFontObject("GameFontNormalSmall"); text:SetPoint("LEFT", cb, "RIGHT", 4, 1)
    
    cb:SetScript("OnShow", function(self)
        self:SetChecked(ns.GetSettings()[settingKey])
    end)
    
    cb:SetScript("OnClick", function(self)
        local settings = ns.GetSettings()
        local checked = self:GetChecked()
        settings[settingKey] = checked
        if ns.IsMorpherReady() then
            ns.SendMorphCommand("SET:"..cmdPrefix..":"..(checked and "1" or "0"))
            if settingKey == "showOwnSpells" and ns.SyncPlayerSpellbookVisibility then
                if ns.InvalidatePlayerSpellbookVisibilityCache then
                    ns.InvalidatePlayerSpellbookVisibilityCache()
                end
                ns.SyncPlayerSpellbookVisibility(true)
            end
        end
        PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
    end)
    
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(label, 1, 0.82, 0)
        GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("\n|cffF5C842Note:|r Affects all units globally.", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    optimizationCheckboxes[settingKey] = cb
    return cb
end




    local cbHideAll = CreateOptCheckbox("HideAll", "|cffFF4444[MASTER] Hide ALL Spells|r", "Completely disables all spell visuals globally for peak FPS.", "hideAllSpells", "HIDE_ALL")
    cbHideAll:SetPoint("TOPLEFT", 16, -80)

    local cbShowOwn = CreateOptCheckbox("ShowOwn", "|cff44ff88Show Spellbook Spells|r", "Keeps spells found in your current spellbook visible even when optimization is active. Morphed versions of those spellbook spells also stay visible.", "showOwnSpells", "SHOW_OWN_SPELLS")
    cbShowOwn:SetPoint("LEFT", cbHideAll, "RIGHT", 170, 0)
    
    local sep1 = optCard:CreateTexture(nil, "ARTWORK")
    sep1:SetHeight(1); sep1:SetPoint("TOPLEFT", 16, -108); sep1:SetPoint("TOPRIGHT", -16, -108); sep1:SetTexture(1, 1, 1, 0.08)

-- Column 1
    local col1X = 22
    local yPos1 = -120
local rowH = 20
local secGap = 20

local sub1 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub1:SetPoint("TOPLEFT", 18, yPos1); sub1:SetText("|cffA3A3A3Casting & Auras|r")
yPos1 = yPos1 - 18

CreateOptCheckbox("HidePre", "Pre-Cast Hand Glows", "Hides hand glows before a spell launches.", "hidePrecast", "HIDE_PRECAST"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - rowH
CreateOptCheckbox("HideCast", "Casting Animations", "Hides main character casting visuals.", "hideCast", "HIDE_CAST"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - rowH
CreateOptCheckbox("HideChan", "Channeled Beams", "Hides beams like Mind Flay or Drain Life.", "hideChannel", "HIDE_CHANNEL"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - secGap

local sub2 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub2:SetPoint("TOPLEFT", 18, yPos1); sub2:SetText("|cffA3A3A3Aura Application|r")
yPos1 = yPos1 - 18

CreateOptCheckbox("HideAuraS", "Aura Apply (Start)", "Hides visuals triggered when an aura is applied.", "hideAuraStart", "HIDE_AURA_START"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - rowH
CreateOptCheckbox("HideAuraE", "Aura Remove (End)", "Hides visuals triggered when an aura expires.", "hideAuraEnd", "HIDE_AURA_END"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - secGap

local sub3 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub3:SetPoint("TOPLEFT", 18, yPos1); sub3:SetText("|cffA3A3A3Impacts (Self)|r")
yPos1 = yPos1 - 18

CreateOptCheckbox("HideImpG", "Hit (Hand Effect)", "Hides generic hit effects usually attached to hands.", "hideImpact", "HIDE_IMPACT"):SetPoint("TOPLEFT", col1X, yPos1); yPos1 = yPos1 - rowH
CreateOptCheckbox("HideImpC", "Impact (Caster)", "Hides caster-side impact visuals.", "hideImpactCaster", "HIDE_IMPACT_CASTER"):SetPoint("TOPLEFT", col1X, yPos1)


-- Column 2
    local col2X = 240
    local yPos2 = -120

local sub4 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub4:SetPoint("TOPLEFT", col2X - 4, yPos2); sub4:SetText("|cffA3A3A3World & Target Impacts|r")
yPos2 = yPos2 - 18

CreateOptCheckbox("HideImpT", "Impact (Target)", "Hides hit visuals on the target character.", "hideTargetImpact", "HIDE_IMPACT_TARGET"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - rowH
CreateOptCheckbox("HideAreaI", "Area (Instant Kit)", "Hides instant area-of-effect visuals.", "hideAreaInstant", "HIDE_AREA_INSTANT"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - rowH
CreateOptCheckbox("HideAreaM", "Area (Impact Kit)", "Hides area visuals triggered on impact.", "hideAreaImpact", "HIDE_AREA_IMPACT"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - rowH
CreateOptCheckbox("HideAreaP", "Area (Persistent)", "Hides persistent ground effects like Consecration.", "hideAreaPersistent", "HIDE_AREA_PERSISTENT"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - secGap

local sub5 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub5:SetPoint("TOPLEFT", col2X - 4, yPos2); sub5:SetText("|cffA3A3A3Missiles & Markers|r")
yPos2 = yPos2 - 18

CreateOptCheckbox("HideMiss", "Missile Projectiles", "Hides traveling bolts (Fireball, Frostbolt) and arrows.", "hideMissile", "HIDE_MISSILE"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - rowH
CreateOptCheckbox("HideMissM", "Missile Markers", "Hides markers where missiles land.", "hideMissileMarker", "HIDE_MISSILE_MARKER"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - secGap

local sub6 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub6:SetPoint("TOPLEFT", col2X - 4, yPos2); sub6:SetText("|cffA3A3A3Audio Suppression|r")
yPos2 = yPos2 - 18

CreateOptCheckbox("HideSndM", "Missile Sounds", "Suppresses sounds of traveling projectiles.", "hideSoundMissile", "HIDE_SOUND_MISSILE"):SetPoint("TOPLEFT", col2X, yPos2); yPos2 = yPos2 - rowH
CreateOptCheckbox("HideSndE", "Impact & Event Sounds", "Suppresses sounds triggered by impacts or events.", "hideSoundEvent", "HIDE_SOUND_EVENT"):SetPoint("TOPLEFT", col2X, yPos2)

local col3X = 460
local yPos3 = -120

local sub7 = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sub7:SetPoint("TOPLEFT", col3X - 4, yPos3); sub7:SetText("|cffA3A3A3Raid Tier Protection|r")
yPos3 = yPos3 - 18

for _, tierInfo in ipairs(ns.optimizationTierOptions or {}) do
    local cb = CreateOptCheckbox("Tier" .. tierInfo.key, "|cffF5C842" .. tierInfo.label .. "|r  " .. tierInfo.raids, "Extends the always-active protected base list with this raid tier's spell set.\n\nEnabled: Protected base + this tier\nDisabled: Protected base only", tierInfo.settingKey, "PROTECTED_TIER:" .. tierInfo.key)
    cb:SetPoint("TOPLEFT", col3X, yPos3)
    yPos3 = yPos3 - rowH
end

-- ============================================================
-- PROTECTION WHITELIST (WHITE CARD)
-- ============================================================

-- ============================================================
-- OPT PROTECTION (WHITE CARD & SEARCH)
-- ============================================================
local protCard = CreateFrame("Frame", nil, optProtectPanel)
protCard:SetPoint("TOPLEFT", 8, -32); protCard:SetPoint("BOTTOMRIGHT", -8, 8)
protCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
protCard:SetBackdropColor(0.05, 0.057, 0.08, 0.95); protCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local protTitle = protCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
protTitle:SetPoint("TOPLEFT", 14, -14); protTitle:SetText("|cffF5C842Spell Protection (White Card)|r")

local protDesc = protCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
protDesc:SetPoint("TOPLEFT", protTitle, "BOTTOMLEFT", 0, -4); protDesc:SetText("Legacy local whitelist view. Runtime protection now depends on the base list plus enabled tier spell sets from optimizationdb."); protDesc:SetTextColor(0.7, 0.7, 0.7)

-- Search Section (Left Column)
local searchTitle = protCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
searchTitle:SetPoint("TOPLEFT", 14, -64); searchTitle:SetText("|cffA3A3A3Search DBC Spells|r")

local searchShell = CreateFrame("Frame", nil, protCard)
searchShell:SetPoint("TOPLEFT", 14, -80); searchShell:SetWidth(240); searchShell:SetHeight(28)
searchShell:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
searchShell:SetBackdropColor(0, 0, 0, 0.4); searchShell:SetBackdropBorderColor(1, 1, 1, 0.1)

local searchIcon = searchShell:CreateTexture(nil, "OVERLAY")
searchIcon:SetSize(14, 14); searchIcon:SetPoint("LEFT", 8, 0); searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon"); searchIcon:SetVertexColor(0.96, 0.82, 0.30)

local protSearch = CreateFrame("EditBox", nil, searchShell)
protSearch:SetPoint("LEFT", searchIcon, "RIGHT", 6, 0); protSearch:SetPoint("RIGHT", -8, 0); protSearch:SetHeight(18)
protSearch:SetAutoFocus(false); protSearch:SetFontObject("ChatFontNormal"); protSearch:SetTextColor(0.95, 0.88, 0.65)

local searchHint = protSearch:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
searchHint:SetPoint("LEFT", 0, 0); searchHint:SetText("Spell name or ID...")
protSearch:SetScript("OnEditFocusGained", function() searchHint:Hide() end)
protSearch:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then searchHint:Show() end end)
protSearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local listBg = CreateFrame("Frame", nil, protCard)
listBg:SetPoint("TOPLEFT", 14, -114); listBg:SetPoint("BOTTOMRIGHT", -230, 14)
listBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
listBg:SetBackdropColor(0, 0, 0, 0.2); listBg:SetBackdropBorderColor(1, 1, 1, 0.05)

local listScroll = CreateFrame("ScrollFrame", "$parentProtListScroll", listBg, "UIPanelScrollFrameTemplate")
listScroll:SetPoint("TOPLEFT", 4, -4); listScroll:SetPoint("BOTTOMRIGHT", -22, 4)
local listContent = CreateFrame("Frame", nil, listScroll)
listContent:SetSize(listScroll:GetWidth(), 1); listScroll:SetScrollChild(listContent)

-- Active Protected Spells (Right side)
local activeTitle = protCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
activeTitle:SetPoint("TOPLEFT", listBg, "TOPRIGHT", 10, 50); activeTitle:SetText("|cffA3A3A3Protected List|r")

local activeBg = CreateFrame("Frame", nil, protCard)
activeBg:SetPoint("TOPLEFT", listBg, "TOPRIGHT", 10, 32); activeBg:SetPoint("BOTTOMRIGHT", -14, 60)
activeBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
activeBg:SetBackdropColor(0.02, 0.025, 0.03, 0.6); activeBg:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.4)

local activeScroll = CreateFrame("ScrollFrame", "$parentActiveProtScroll", activeBg, "UIPanelScrollFrameTemplate")
activeScroll:SetPoint("TOPLEFT", 4, -4); activeScroll:SetPoint("BOTTOMRIGHT", -22, 4)
local activeContent = CreateFrame("Frame", nil, activeScroll)
activeContent:SetSize(activeScroll:GetWidth(), 1); activeScroll:SetScrollChild(activeContent)

-- Manual Add Field (Bottom Right)
local manualBg = CreateFrame("Frame", nil, protCard)
manualBg:SetPoint("TOPLEFT", activeBg, "BOTTOMLEFT", 0, -4); manualBg:SetPoint("BOTTOMRIGHT", -14, 14)
manualBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
manualBg:SetBackdropColor(0, 0, 0, 0.3); manualBg:SetBackdropBorderColor(1, 1, 1, 0.1)

local manualInput = CreateFrame("EditBox", nil, manualBg, "InputBoxTemplate")
manualInput:SetSize(110, 20); manualInput:SetPoint("LEFT", 8, 0); manualInput:SetAutoFocus(false)
local manualHint = manualInput:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
manualHint:SetPoint("LEFT", 4, 0); manualHint:SetText("Enter ID..."); manualInput:SetScript("OnEditFocusGained", function() manualHint:Hide() end); manualInput:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then manualHint:Show() end end)

local btnManualAdd = ns.CreateGoldenButton(nil, manualBg)
btnManualAdd:SetPoint("LEFT", manualInput, "RIGHT", 4, 0); btnManualAdd:SetSize(40, 20); btnManualAdd:SetText("Add")

local function GetSpellName335(id)
    local name = GetSpellInfo(id)
    return name or ("Spell " .. id)
end

local UpdateActiveProtList, UpdateProtSearchResults, SimpleTimer_After -- Forward declarations

local protBtns = {}
local activeBtns = {}
local PROT_ROW_H = 26 -- Slightly taller for icons

UpdateActiveProtList = function()
    local settings = ns.GetSettings()
    local y = 0
    for _, b in ipairs(activeBtns) do b:Hide() end
    
    local sortedIds = {}
    for id, _ in pairs(settings.whiteCardSpells) do table.insert(sortedIds, id) end
    table.sort(sortedIds)

    for _, id in ipairs(sortedIds) do
        y = y + 1
        local b = activeBtns[y]
        if not b then
            b = CreateFrame("Button", nil, activeContent)
            b:SetSize(activeContent:GetWidth(), PROT_ROW_H)
            
            local icon = b:CreateTexture(nil, "OVERLAY")
            icon:SetSize(20, 20); icon:SetPoint("LEFT", 4, 0); b.icon = icon
            
            local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); fs:SetPoint("LEFT", icon, "RIGHT", 6, 0); fs:SetPoint("RIGHT", -24, 0); fs:SetJustifyH("LEFT"); b.text = fs
            
            local rem = CreateFrame("Button", nil, b)
            rem:SetSize(18, 18); rem:SetPoint("RIGHT", -4, 0)
            local rTex = rem:CreateTexture(nil, "OVERLAY"); rTex:SetAllPoints(); rTex:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up"); rem.tex = rTex
            rem:SetScript("OnClick", function() b:Click() end)
            
            b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
            b:GetHighlightTexture():SetVertexColor(1, 0, 0, 0.1)
            
            b:SetScript("OnClick", function(self)
                local s = ns.GetSettings()
                s.whiteCardSpells[self.spellID] = nil
                if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_WHITE_REMOVE:"..self.spellID) end
                UpdateActiveProtList()
                UpdateProtSearchResults()
                PlaySound("igMainMenuOptionCheckBoxOff")
            end)
            activeBtns[y] = b
        end
        b.spellID = id
        local name, _, iconPath = GetSpellInfo(id)
        b.icon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")
        b.text:SetText("|cff888888" .. id .. "|r " .. (name or "Spell "..id))
        b:SetPoint("TOPLEFT", 0, -((y-1)*PROT_ROW_H)); b:Show()
    end
    activeContent:SetHeight(math.max(1, y * PROT_ROW_H))
end

UpdateProtSearchResults = function()
    local results = TRANSMORPHER_SEARCH_RESULTS or ""
    if results == "" then
        for _, b in ipairs(protBtns) do b:Hide() end
        listContent:SetHeight(1)
        return
    end
    
    local y = 0
    local settings = ns.GetSettings()

    for idStr in results:gmatch("([^|]+)") do
        local id = tonumber(idStr)
        if id then
            y = y + 1
            local b = protBtns[y]
            if not b then
                b = CreateFrame("Button", nil, listContent)
                b:SetSize(listContent:GetWidth(), PROT_ROW_H)
                
                local icon = b:CreateTexture(nil, "OVERLAY")
                icon:SetSize(20, 20); icon:SetPoint("LEFT", 4, 0); b.icon = icon
                
                local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); fs:SetPoint("LEFT", icon, "RIGHT", 6, 0); fs:SetPoint("RIGHT", -45, 0); fs:SetJustifyH("LEFT"); b.text = fs
                
                local action = CreateFrame("Button", nil, b)
                action:SetSize(32, 18); action:SetPoint("RIGHT", -4, 0); b.action = action
                action:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
                action:SetBackdropColor(0.1, 0.08, 0, 0.8)
                action:SetBackdropBorderColor(0.56, 0.47, 0.2, 0.6)
                local afs = action:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); afs:SetPoint("CENTER"); b.actionText = afs
                action:SetScript("OnClick", function() b:Click() end)
                
                b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
                b:GetHighlightTexture():SetVertexColor(1, 0.92, 0.56, 0.08)
                
                b:SetScript("OnClick", function(self)
                    local s = ns.GetSettings()
                    if s.whiteCardSpells[self.spellID] then
                        s.whiteCardSpells[self.spellID] = nil
                        if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_WHITE_REMOVE:"..self.spellID) end
                    else
                        s.whiteCardSpells[self.spellID] = true
                        if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_WHITE_CARD:"..self.spellID) end
                    end
                    UpdateActiveProtList()
                    UpdateProtSearchResults()
                    PlaySound("igMainMenuOptionCheckBoxOn")
                end)
                protBtns[y] = b
            end
            b.spellID = id
            local isProt = settings.whiteCardSpells[id]
            local name, _, iconPath = GetSpellInfo(id)
            b.icon:SetTexture(iconPath or "Interface\\Icons\\INV_Misc_QuestionMark")
            b.text:SetText("|cffAAAAAA" .. id .. "|r " .. (name or "Spell "..id))
            b.actionText:SetText(isProt and "|cffff4444- |r" or "|cff44ff44+|r")
            b.action:SetBackdropBorderColor(isProt and 0.8 or 0.2, 0.2, 0.2, 0.6)
            b:SetPoint("TOPLEFT", 0, -((y-1)*PROT_ROW_H)); b:Show()
        end
    end
    listContent:SetHeight(math.max(1, y * PROT_ROW_H))
end

-- Delay utility for 3.3.5 (since C_Timer is nil)
SimpleTimer_After = function(delay, func)
    local f = CreateFrame("Frame")
    f.t = 0
    f:SetScript("OnUpdate", function(self, e)
        self.t = self.t + e
        if self.t >= delay then
            self:SetScript("OnUpdate", nil)
            func()
        end
    end)
end

protSearch:SetScript("OnTextChanged", function(self)
    local query = self:GetText():lower()
    if query:len() >= 2 then
        if ns.IsMorpherReady() then
            ns.SendMorphCommand("SPELL_SEARCH:" .. query)
            -- Small delay to let DLL setting the global propagate
            SimpleTimer_After(0.1, UpdateProtSearchResults)
        end
    else
        TRANSMORPHER_SEARCH_RESULTS = ""
        UpdateProtSearchResults()
    end
end)

btnManualAdd:SetScript("OnClick", function()
    local id = tonumber(manualInput:GetText())
    if id and id > 0 then
        local s = ns.GetSettings()
        s.whiteCardSpells[id] = true
        if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_WHITE_CARD:" .. id) end
        manualInput:SetText("")
        UpdateActiveProtList()
        PlaySound("igMainMenuOptionCheckBoxOn")
    end
end)

protCard:SetScript("OnShow", function()
    UpdateActiveProtList()
end)

-- ============================================================
-- PROTECTED FILE MANAGER (`optimizationdb/protected_spells.lua`)
-- ============================================================
local protectedFileState = {
    ids = {},
    map = {},
    filtered = {},
    page = 1,
    pageSize = 100,
    loaded = false,
}

local function NormalizeText(text)
    return (text or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
end

local function GetProtectedSpellName(id)
    local name = GetSpellInfo(id)
    return name or ("Spell " .. id)
end

local function SortNumericKeys(tbl)
    local ids = {}
    for id in pairs(tbl) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

local function ParseProtectedDump(raw)
    protectedFileState.map = {}
    if raw and raw ~= "" then
        for token in string.gmatch(raw, "[^|]+") do
            local id = tonumber(token)
            if id and id > 0 then
                protectedFileState.map[id] = true
            end
        end
    end
    protectedFileState.ids = SortNumericKeys(protectedFileState.map)
    protectedFileState.loaded = true
end

local fileCard = CreateFrame("Frame", nil, optProtectedFilePanel)
fileCard:SetPoint("TOPLEFT", 8, -32); fileCard:SetPoint("BOTTOMRIGHT", -8, 8)
fileCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
fileCard:SetBackdropColor(0.05, 0.057, 0.08, 0.95); fileCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local fileTitle = fileCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
fileTitle:SetPoint("TOPLEFT", 14, -14); fileTitle:SetText("|cffF5C842Protected Base List|r")

local fileDesc = fileCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fileDesc:SetPoint("TOPLEFT", fileTitle, "BOTTOMLEFT", 0, -4)
fileDesc:SetPoint("RIGHT", -14, 0)
fileDesc:SetText("Manage the always-active base protected list stored in optimizationdb/protected_spells.lua. Tier files extend this list when enabled from General Optimization.")
fileDesc:SetTextColor(0.7, 0.7, 0.7)

local fileStats = fileCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fileStats:SetPoint("TOPLEFT", fileDesc, "BOTTOMLEFT", 0, -8)
fileStats:SetTextColor(0.85, 0.82, 0.72)

local fileSearchShell = CreateFrame("Frame", nil, fileCard)
fileSearchShell:SetPoint("TOPLEFT", 14, -86); fileSearchShell:SetSize(260, 28)
fileSearchShell:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
fileSearchShell:SetBackdropColor(0.02, 0.02, 0.03, 0.95); fileSearchShell:SetBackdropBorderColor(0.30, 0.28, 0.24, 0.7)

local fileSearchIcon = fileSearchShell:CreateTexture(nil, "OVERLAY")
fileSearchIcon:SetSize(14, 14); fileSearchIcon:SetPoint("LEFT", 8, 0)
fileSearchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon"); fileSearchIcon:SetVertexColor(0.96, 0.82, 0.30)

local fileSearch = CreateFrame("EditBox", nil, fileSearchShell)
fileSearch:SetPoint("LEFT", fileSearchIcon, "RIGHT", 6, 0); fileSearch:SetPoint("RIGHT", -8, 0); fileSearch:SetHeight(18)
fileSearch:SetAutoFocus(false); fileSearch:SetFontObject("ChatFontNormal"); fileSearch:SetTextColor(0.95, 0.88, 0.65)

local fileSearchHint = fileSearch:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
fileSearchHint:SetPoint("LEFT", 0, 0); fileSearchHint:SetText("Search current protected list...")
fileSearch:SetScript("OnEditFocusGained", function() fileSearchHint:Hide() end)
fileSearch:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then fileSearchHint:Show() end end)
fileSearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local fileListBg = CreateFrame("Frame", nil, fileCard)
fileListBg:SetPoint("TOPLEFT", 14, -120); fileListBg:SetPoint("BOTTOMRIGHT", -260, 42)
fileListBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
fileListBg:SetBackdropColor(0.01, 0.015, 0.02, 0.78); fileListBg:SetBackdropBorderColor(0.18, 0.18, 0.18, 0.6)

local fileListScroll = CreateFrame("ScrollFrame", "$parentProtectedFileScroll", fileListBg, "UIPanelScrollFrameTemplate")
fileListScroll:SetPoint("TOPLEFT", 4, -4); fileListScroll:SetPoint("BOTTOMRIGHT", -22, 4)
local fileListContent = CreateFrame("Frame", nil, fileListScroll)
fileListContent:SetSize(fileListScroll:GetWidth(), 1); fileListScroll:SetScrollChild(fileListContent)

local sidePanel = CreateFrame("Frame", nil, fileCard)
sidePanel:SetPoint("TOPLEFT", fileListBg, "TOPRIGHT", 10, 0); sidePanel:SetPoint("BOTTOMRIGHT", -14, 8)
sidePanel:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
sidePanel:SetBackdropColor(0.04, 0.045, 0.06, 0.95); sidePanel:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.6)

local sideTitle = sidePanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
sideTitle:SetPoint("TOPLEFT", 10, -10); sideTitle:SetText("|cffA3A3A3Add or Sync|r")

local sideDesc = sidePanel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
sideDesc:SetPoint("TOPLEFT", sideTitle, "BOTTOMLEFT", 0, -3)
sideDesc:SetPoint("RIGHT", sidePanel, "RIGHT", -10, 0)
sideDesc:SetJustifyH("LEFT")
sideDesc:SetText("Search the DBC for new spells only, or add a spell ID manually.")

local addSearchShell = CreateFrame("Frame", nil, sidePanel)
addSearchShell:SetPoint("TOPLEFT", 10, -42); addSearchShell:SetPoint("TOPRIGHT", -10, -42); addSearchShell:SetHeight(28)
addSearchShell:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
addSearchShell:SetBackdropColor(0.02, 0.02, 0.03, 0.95)
addSearchShell:SetBackdropBorderColor(0.30, 0.28, 0.24, 0.7)

local addSearchIcon = addSearchShell:CreateTexture(nil, "OVERLAY")
addSearchIcon:SetSize(14, 14); addSearchIcon:SetPoint("LEFT", 8, 0)
addSearchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon"); addSearchIcon:SetVertexColor(0.96, 0.82, 0.30)

local addSearch = CreateFrame("EditBox", nil, addSearchShell)
addSearch:SetPoint("LEFT", addSearchIcon, "RIGHT", 6, 0); addSearch:SetPoint("RIGHT", -8, 0); addSearch:SetHeight(18)
addSearch:SetAutoFocus(false); addSearch:SetFontObject("ChatFontNormal"); addSearch:SetTextColor(0.95, 0.88, 0.65)

local addSearchHint = addSearch:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
addSearchHint:SetPoint("LEFT", 0, 0); addSearchHint:SetText("Search DBC by name/ID...")
addSearch:SetScript("OnEditFocusGained", function() addSearchHint:Hide() end)
addSearch:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then addSearchHint:Show() end end)
addSearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local searchResultsBg = CreateFrame("Frame", nil, sidePanel)
searchResultsBg:SetPoint("TOPLEFT", addSearchShell, "BOTTOMLEFT", 0, -8)
searchResultsBg:SetPoint("TOPRIGHT", addSearchShell, "BOTTOMRIGHT", 0, -8)
searchResultsBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
searchResultsBg:SetBackdropColor(0.03, 0.035, 0.05, 0.95); searchResultsBg:SetBackdropBorderColor(0.30, 0.28, 0.24, 0.5)

local searchResultsTitle = searchResultsBg:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
searchResultsTitle:SetPoint("TOPLEFT", 8, -8)
searchResultsTitle:SetText("Search Results")

local searchResultsEmpty = searchResultsBg:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
searchResultsEmpty:SetPoint("CENTER", 0, -4)
searchResultsEmpty:SetText("Type at least 2 letters or an ID")
searchResultsEmpty:SetTextColor(0.55, 0.55, 0.55)

local searchResultRows, protectedFileRows = {}, {}
local PROTECTED_FILE_ROW_H = 24
local PROTECTED_FILE_SEARCH_ROW_H = 25
local PROTECTED_FILE_SEARCH_VISIBLE_ROWS = 5
local ProtectedFile_RenderSearchResults

local searchResultsScroll = CreateFrame("ScrollFrame", "$parentProtectedSearchScroll", searchResultsBg, "UIPanelScrollFrameTemplate")
searchResultsScroll:SetPoint("TOPLEFT", 4, -24); searchResultsScroll:SetPoint("BOTTOMRIGHT", -24, 4)
local searchResultsContent = CreateFrame("Frame", nil, searchResultsScroll)
searchResultsContent:SetSize(1, 1); searchResultsScroll:SetScrollChild(searchResultsContent)
local searchResultsScrollBar = _G[searchResultsScroll:GetName() .. "ScrollBar"]
searchResultsScroll:EnableMouseWheel(true)
searchResultsScroll:SetScript("OnMouseWheel", function(self, delta)
    local current = self:GetVerticalScroll()
    local minVal, maxVal = 0, 0
    if searchResultsScrollBar then
        minVal, maxVal = searchResultsScrollBar:GetMinMaxValues()
    else
        maxVal = math.max(0, searchResultsContent:GetHeight() - self:GetHeight())
    end
    local nextVal = current - (delta * PROTECTED_FILE_SEARCH_ROW_H * 2)
    if nextVal < minVal then nextVal = minVal end
    if nextVal > maxVal then nextVal = maxVal end
    self:SetVerticalScroll(nextVal)
end)

local filePageLabel = fileCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
filePageLabel:SetPoint("BOTTOMLEFT", fileListBg, "TOPLEFT", 0, 8)
filePageLabel:SetTextColor(0.75, 0.75, 0.75)

local btnPrevPage = ns.CreateGoldenButton(nil, fileCard)
btnPrevPage:SetPoint("BOTTOMLEFT", fileListBg, "BOTTOMLEFT", 0, -28); btnPrevPage:SetSize(70, 22); btnPrevPage:SetText("Prev")

local btnNextPage = ns.CreateGoldenButton(nil, fileCard)
btnNextPage:SetPoint("LEFT", btnPrevPage, "RIGHT", 8, 0); btnNextPage:SetSize(70, 22); btnNextPage:SetText("Next")

local btnReloadFile = ns.CreateGoldenButton(nil, fileCard)
btnReloadFile:SetParent(sidePanel)
btnReloadFile:SetPoint("BOTTOMRIGHT", -10, 10); btnReloadFile:SetSize(100, 22); btnReloadFile:SetText("Reload File")

local btnExportFile = ns.CreateGoldenButton(nil, fileCard)
btnExportFile:SetParent(sidePanel)
btnExportFile:SetPoint("RIGHT", btnReloadFile, "LEFT", -8, 0); btnExportFile:SetSize(100, 22); btnExportFile:SetText("Export File")

local function ProtectedFile_UpdateSideLayout(showResults)
    searchResultsBg:ClearAllPoints()
    btnReloadFile:ClearAllPoints()
    btnExportFile:ClearAllPoints()

    if showResults then
        searchResultsBg:SetPoint("TOPLEFT", addSearchShell, "BOTTOMLEFT", 0, -8)
        searchResultsBg:SetPoint("TOPRIGHT", addSearchShell, "BOTTOMRIGHT", 0, -8)
        searchResultsBg:SetPoint("BOTTOMLEFT", sidePanel, "BOTTOMLEFT", 10, 42)
        searchResultsBg:SetPoint("BOTTOMRIGHT", sidePanel, "BOTTOMRIGHT", -10, 42)
        searchResultsBg:Show()
    else
        searchResultsBg:Hide()
        searchResultsScroll:SetVerticalScroll(0)
    end

    btnReloadFile:SetPoint("BOTTOMRIGHT", sidePanel, "BOTTOMRIGHT", -10, 10)
    btnExportFile:SetPoint("RIGHT", btnReloadFile, "LEFT", -8, 0)
end

local function ProtectedFile_RefreshFiltered()
    protectedFileState.ids = SortNumericKeys(protectedFileState.map)
    wipe(protectedFileState.filtered)
    local query = NormalizeText(fileSearch:GetText())
    for _, id in ipairs(protectedFileState.ids) do
        local name = NormalizeText(GetProtectedSpellName(id))
        if query == "" or string.find(tostring(id), query, 1, true) or string.find(name, query, 1, true) then
            table.insert(protectedFileState.filtered, id)
        end
    end
    local maxPage = math.max(1, math.ceil(#protectedFileState.filtered / protectedFileState.pageSize))
    if protectedFileState.page > maxPage then
        protectedFileState.page = maxPage
    end
end

local function ProtectedFile_RenderList()
    ProtectedFile_RefreshFiltered()
    local total = #protectedFileState.ids
    local filtered = #protectedFileState.filtered
    local maxPage = math.max(1, math.ceil(filtered / protectedFileState.pageSize))
    local startIndex = ((protectedFileState.page - 1) * protectedFileState.pageSize) + 1
    local endIndex = math.min(filtered, startIndex + protectedFileState.pageSize - 1)

    for _, row in ipairs(protectedFileRows) do row:Hide() end

    local visible = 0
    for i = startIndex, endIndex do
        local id = protectedFileState.filtered[i]
        if id then
            visible = visible + 1
            local row = protectedFileRows[visible]
            if not row then
                row = CreateFrame("Button", nil, fileListContent)
                row:SetSize(fileListContent:GetWidth(), PROTECTED_FILE_ROW_H)
                row.icon = row:CreateTexture(nil, "OVERLAY")
                row.icon:SetSize(18, 18); row.icon:SetPoint("LEFT", 4, 0)
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0); row.text:SetPoint("RIGHT", -40, 0); row.text:SetJustifyH("LEFT")
                row.remove = CreateFrame("Button", nil, row)
                row.remove:SetSize(28, 18); row.remove:SetPoint("RIGHT", -4, 0)
                row.remove:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
                row.remove:SetBackdropColor(0.18, 0.04, 0.04, 0.85); row.remove:SetBackdropBorderColor(0.70, 0.20, 0.20, 0.8)
                row.remove.label = row.remove:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.remove.label:SetPoint("CENTER"); row.remove.label:SetText("X")
                row.remove:SetScript("OnClick", function() row:Click() end)
                row:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
                row:GetHighlightTexture():SetVertexColor(1, 0.92, 0.56, 0.08)
                row:SetScript("OnClick", function(self)
                    protectedFileState.map[self.spellID] = nil
                    if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_PROTECTED_REMOVE:" .. self.spellID) end
                    ProtectedFile_RenderList()
                    ProtectedFile_RenderSearchResults()
                    PlaySound("igMainMenuOptionCheckBoxOff")
                end)
                protectedFileRows[visible] = row
            end

            local name, _, icon = GetSpellInfo(id)
            row.spellID = id
            row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.text:SetText("|cff8A8A8A" .. id .. "|r  " .. (name or ("Spell " .. id)))
            row:SetPoint("TOPLEFT", 0, -((visible - 1) * PROTECTED_FILE_ROW_H))
            row:Show()
        end
    end

    fileListContent:SetHeight(math.max(1, visible * PROTECTED_FILE_ROW_H))
    fileStats:SetText(string.format("%d total spells in file  |  %d matching  |  100 shown per page", total, filtered))
    filePageLabel:SetText(string.format("Page %d/%d", protectedFileState.page, maxPage))
    if protectedFileState.page > 1 then btnPrevPage:Enable() else btnPrevPage:Disable() end
    if protectedFileState.page < maxPage then btnNextPage:Enable() else btnNextPage:Disable() end
end

local function ProtectedFile_AddSpell(id)
    id = tonumber(id)
    if not id or id <= 0 or protectedFileState.map[id] then return end
    protectedFileState.map[id] = true
    if ns.IsMorpherReady() then ns.SendMorphCommand("SPELL_PROTECTED_ADD:" .. id) end
    ProtectedFile_RenderList()
    ProtectedFile_RenderSearchResults()
    PlaySound("igMainMenuOptionCheckBoxOn")
end

local function ProtectedFile_LoadFromDll()
    if not ns.IsMorpherReady() then return end
    ns.SendMorphCommand("SPELL_PROTECTED_DUMP")
    SimpleTimer_After(0.1, function()
        ParseProtectedDump(TRANSMORPHER_PROTECTED_RESULTS or "")
        ProtectedFile_RenderList()
    end)
end

ProtectedFile_RenderSearchResults = function()
    for _, row in ipairs(searchResultRows) do row:Hide() end
    local raw = TRANSMORPHER_SEARCH_RESULTS or ""
    local shown = 0
    local query = NormalizeText(addSearch:GetText())

    if query == "" or string.len(query) < 2 then
        searchResultsContent:SetHeight(1)
        searchResultsEmpty:Hide()
        searchResultsScroll:SetVerticalScroll(0)
        ProtectedFile_UpdateSideLayout(false)
        return
    end

    ProtectedFile_UpdateSideLayout(true)

    searchResultsContent:SetWidth(math.max(1, searchResultsBg:GetWidth() - 28))

    for token in string.gmatch(raw, "[^|]+") do
        local id = tonumber(token)
        if id and not protectedFileState.map[id] then
            shown = shown + 1
            local row = searchResultRows[shown]
            if not row then
                row = CreateFrame("Button", nil, searchResultsContent)
                row:SetSize(math.max(1, searchResultsBg:GetWidth() - 28), 24)
                local rowBg = row:CreateTexture(nil, "BACKGROUND"); rowBg:SetAllPoints(); row.rowBg = rowBg
                row.icon = row:CreateTexture(nil, "OVERLAY")
                row.icon:SetSize(18, 18); row.icon:SetPoint("LEFT", 4, 0)
                row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0); row.text:SetPoint("RIGHT", -34, 0); row.text:SetJustifyH("LEFT")
                row.action = CreateFrame("Button", nil, row)
                row.action:SetSize(24, 18); row.action:SetPoint("RIGHT", -4, 0)
                row.action:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
                row.action:SetBackdropColor(0.08, 0.14, 0.05, 0.85); row.action:SetBackdropBorderColor(0.20, 0.65, 0.20, 0.8)
                row.action.label = row.action:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.action.label:SetPoint("CENTER"); row.action.label:SetText("+")
                row.action:SetScript("OnClick", function() row:Click() end)
                row:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
                row:GetHighlightTexture():SetVertexColor(1, 0.92, 0.56, 0.08)
                row:SetScript("OnClick", function(self) ProtectedFile_AddSpell(self.spellID) end)
                searchResultRows[shown] = row
            end

            local name, _, icon = GetSpellInfo(id)
            row.spellID = id
            row.icon:SetTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            row.text:SetText("|cff8A8A8A" .. id .. "|r  " .. (name or ("Spell " .. id)))
            if row.rowBg then
                if shown % 2 == 0 then row.rowBg:SetTexture(1, 1, 1, 0.03) else row.rowBg:SetTexture(0, 0, 0, 0) end
            end
            row:SetWidth(math.max(1, searchResultsBg:GetWidth() - 28))
            row:SetPoint("TOPLEFT", 2, -2 - ((shown - 1) * PROTECTED_FILE_SEARCH_ROW_H))
            row:Show()
        end
    end

    searchResultsContent:SetHeight(math.max(1, shown * PROTECTED_FILE_SEARCH_ROW_H + 2))
    searchResultsScroll:SetVerticalScroll(0)

    if shown == 0 then
        searchResultsEmpty:SetText("No new spells found")
        searchResultsEmpty:Show()
    else
        searchResultsEmpty:Hide()
    end
end

searchResultsBg:SetScript("OnSizeChanged", function()
    ProtectedFile_RenderSearchResults()
end)

ProtectedFile_UpdateSideLayout(false)

fileSearch:SetScript("OnTextChanged", function()
    protectedFileState.page = 1
    ProtectedFile_RenderList()
end)

addSearch:SetScript("OnTextChanged", function(self)
    local query = NormalizeText(self:GetText())
    if string.len(query) >= 2 and ns.IsMorpherReady() then
        ns.SendMorphCommand("SPELL_SEARCH:" .. query)
        SimpleTimer_After(0.1, ProtectedFile_RenderSearchResults)
    else
        TRANSMORPHER_SEARCH_RESULTS = ""
        ProtectedFile_RenderSearchResults()
    end
end)

btnPrevPage:SetScript("OnClick", function()
    if protectedFileState.page > 1 then
        protectedFileState.page = protectedFileState.page - 1
        ProtectedFile_RenderList()
    end
end)

btnNextPage:SetScript("OnClick", function()
    local maxPage = math.max(1, math.ceil(#protectedFileState.filtered / protectedFileState.pageSize))
    if protectedFileState.page < maxPage then
        protectedFileState.page = protectedFileState.page + 1
        ProtectedFile_RenderList()
    end
end)

btnReloadFile:SetScript("OnClick", function()
    if ns.IsMorpherReady() then
        ns.SendMorphCommand("SPELL_PROTECTED_RELOAD")
        SimpleTimer_After(0.1, function()
            ParseProtectedDump(TRANSMORPHER_PROTECTED_RESULTS or "")
            protectedFileState.page = 1
            ProtectedFile_RenderList()
        end)
    end
    PlaySound("gsTitleOptionOK")
end)

btnExportFile:SetScript("OnClick", function()
    if ns.IsMorpherReady() then
        TRANSMORPHER_PROTECTED_SAVE_OK = nil
        ns.SendMorphCommand("SPELL_PROTECTED_SAVE")
        SimpleTimer_After(0.1, function()
            if TRANSMORPHER_PROTECTED_SAVE_OK == false then
                SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Failed to export optimizationdb/protected_spells.lua.")
            else
                SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Exported current protected base list to optimizationdb/protected_spells.lua.")
            end
        end)
    end
    PlaySound("gsTitleOptionOK")
end)

fileCard:SetScript("OnShow", function()
    if not protectedFileState.loaded then
        ProtectedFile_LoadFromDll()
    else
        ProtectedFile_RenderList()
    end
    ProtectedFile_RenderSearchResults()
end)

-- ============================================================
-- ENVIRONMENT PANEL (Existing)
-- ============================================================
local timeCard = CreateFrame("Frame", nil, envContent)
timeCard:SetPoint("TOPLEFT", 8, -8)
timeCard:SetPoint("TOPRIGHT", -8, -8)
timeCard:SetHeight(104)
timeCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
timeCard:SetBackdropColor(0.05, 0.055, 0.07, 0.93)
timeCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local timeTitle = timeCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
timeTitle:SetPoint("TOPLEFT", 12, -12); timeTitle:SetText("|cffF5C842Time Control|r")

local timeDesc = timeCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
timeDesc:SetPoint("TOPLEFT", timeTitle, "BOTTOMLEFT", 0, -4); timeDesc:SetText("Override the client-side time of day."); timeDesc:SetTextColor(0.7, 0.7, 0.7)

local slider = CreateFrame("Slider", "$parentTimeSlider", timeCard, "OptionsSliderTemplate")
slider:SetPoint("TOPLEFT", 20, -74); slider:SetPoint("RIGHT", -120, 0); slider:SetHeight(18)
slider:SetMinMaxValues(0.0, 24.0); slider:SetValueStep(0.5); slider:EnableMouse(true)

_G[slider:GetName().."Low"]:SetText("00:00"); _G[slider:GetName().."High"]:SetText("24:00")
local sliderText = _G[slider:GetName().."Text"]; sliderText:SetText("Noon"); sliderText:SetTextColor(1, 0.82, 0)

slider:SetScript("OnValueChanged", function(self, value)
    local hour = math.floor(value); local minute = math.floor((value - hour)*60)
    sliderText:SetText(string.format("%02d:%02d", hour, minute))
end)
slider:SetScript("OnShow", function(self)
    if TransmorpherCharacterState and TransmorpherCharacterState.WorldTime then self:SetValue(TransmorpherCharacterState.WorldTime * 24.0) else self:SetValue(12.0) end
end)

local btnApplyTime = ns.CreateGoldenButton("$parentApplyTime", timeCard)
btnApplyTime:SetPoint("LEFT", slider, "RIGHT", 12, 0); btnApplyTime:SetSize(86, 24); btnApplyTime:SetText("Set Time")
btnApplyTime:SetScript("OnClick", function()
    local val = slider:GetValue() / 24.0
    if ns.IsMorpherReady() then
        ns.SendMorphCommand("TIME:"..val)
        if not TransmorpherCharacterState then TransmorpherCharacterState = {} end
        TransmorpherCharacterState.WorldTime = val
        SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Time updated.")
    end; PlaySound("gsTitleOptionOK")
end)

local btnResetTime = ns.CreateGoldenButton("$parentResetTime", timeCard)
btnResetTime:SetPoint("TOPRIGHT", timeCard, "TOPRIGHT", -12, -10); btnResetTime:SetSize(82, 20); btnResetTime:SetText("Reset")
btnResetTime:SetScript("OnClick", function()
    if ns.IsMorpherReady() then
        ns.SendMorphCommand("TIME:-1")
        if TransmorpherCharacterState then TransmorpherCharacterState.WorldTime = nil end
        slider:SetValue(12.0)
        SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Time reset to server default.")
    end; PlaySound("gsTitleOptionOK")
end)

-- ============================================================
-- WEATHER & SKY (moved here from the Color tab — Misc > Environment)
--   Force precipitation in the current zone and/or swap the skybox. Engine-side,
--   client only. Persists per character and re-applies on login via
--   ns.Environment_ApplyAll (called by ColorTab's Color_ApplyAll on DLL-ready).
-- ============================================================
do
    local function EnvSend(cmd)
        if ns.IsMorpherReady and ns.IsMorpherReady() then
            if ns.SendRawMorphCommand then ns.SendRawMorphCommand(cmd)
            elseif ns.SendMorphCommand then ns.SendMorphCommand(cmd) end
        end
    end
    local function EnvWX()
        local s = ns.GetSettings(); s.colorWeather = s.colorWeather or { type = 0, intensity = 60 }; return s.colorWeather
    end
    local function EnvSky()
        local s = ns.GetSettings(); s.colorSky = s.colorSky or { id = nil, name = nil }; return s.colorSky
    end
    local function SendWeather()
        local w = EnvWX()
        if w.type and w.type > 0 then EnvSend(("WEATHER:%d:%d"):format(w.type, w.intensity or 60))
        else EnvSend("WEATHER_OFF") end
    end
    local function SendSky()
        local s = EnvSky()
        if s.id then EnvSend("SKYBOXID:" .. s.id) else EnvSend("SKYBOX_OFF") end
    end

    function ns.Environment_ApplyAll()
        SendWeather(); SendSky(); EnvSend("SKYBOX_LIST")
    end

    local card = CreateFrame("Frame", nil, envContent)
    card:SetPoint("TOPLEFT", timeCard, "BOTTOMLEFT", 0, -10)
    card:SetPoint("TOPRIGHT", timeCard, "BOTTOMRIGHT", 0, -10)
    card:SetHeight(300)   -- fixed height (lives in a scroll child now, not anchored to the panel bottom)
    card:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    card:SetBackdropColor(0.05, 0.055, 0.07, 0.93); card:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

    local wsTitle = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    wsTitle:SetPoint("TOPLEFT", 12, -12); wsTitle:SetText("|cffF5C842Weather & Sky|r")
    local wsDesc = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    wsDesc:SetPoint("TOPLEFT", wsTitle, "BOTTOMLEFT", 0, -4); wsDesc:SetPoint("RIGHT", -12, 0); wsDesc:SetJustifyH("LEFT")
    wsDesc:SetText("Force the weather and replace the skybox in your current zone. Outdoors only."); wsDesc:SetTextColor(0.7, 0.7, 0.7)

    -- ---- weather buttons ----
    local WEATHER_TYPES = {
        { id = 0, name = "Clear" }, { id = 1, name = "Rain" },
        { id = 2, name = "Snow" },  { id = 3, name = "Sandstorm" },
    }
    local weatherBtns = {}
    local function refreshWeatherSel()
        local cur = EnvWX().type or 0
        for _, b in ipairs(weatherBtns) do
            local on = (b.wtype == cur)
            b.bg:SetTexture(on and 0.22 or 0.08, on and 0.17 or 0.07, on and 0.06 or 0.05, on and 1 or 0.9)
            b:GetFontString():SetTextColor(on and 0.98 or 0.62, on and 0.80 or 0.57, on and 0.28 or 0.46, 1)
        end
    end
    for i, wt in ipairs(WEATHER_TYPES) do
        local b = CreateFrame("Button", nil, card); b:SetSize(104, 22)
        b:SetPoint("TOPLEFT", 14 + (i - 1) * 110, -52)
        local bg = b:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture(0.08, 0.07, 0.05, 0.9); b.bg = bg
        local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); fs:SetPoint("CENTER"); fs:SetText(wt.name); b:SetFontString(fs)
        local hl = b:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetTexture(0.96, 0.78, 0.26, 0.12); b:SetHighlightTexture(hl)
        b.wtype = wt.id
        b:SetScript("OnClick", function()
            EnvWX().type = wt.id; SendWeather(); refreshWeatherSel(); PlaySound("igMainMenuOptionCheckBoxOn")
        end)
        weatherBtns[i] = b
    end

    local wiSlider = CreateFrame("Slider", "TM_Misc_WeatherSlider", card, "OptionsSliderTemplate")
    wiSlider:SetWidth(260); wiSlider:SetPoint("TOPLEFT", 22, -86)
    wiSlider:SetMinMaxValues(5, 100); wiSlider:SetValueStep(5)
    _G["TM_Misc_WeatherSliderLow"]:SetText("Light"); _G["TM_Misc_WeatherSliderHigh"]:SetText("Heavy")
    _G["TM_Misc_WeatherSliderText"]:SetText("Intensity")
    local wiVal = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    wiVal:SetPoint("LEFT", wiSlider, "RIGHT", 14, 0)
    wiSlider:SetScript("OnValueChanged", function(self)
        local v = math.floor(self:GetValue() + 0.5); EnvWX().intensity = v
        wiVal:SetText(("|cffF5C842%d%%|r"):format(v))
        if (EnvWX().type or 0) > 0 then SendWeather() end
    end)

    local sep = card:CreateTexture(nil, "ARTWORK"); sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 14, -116); sep:SetPoint("TOPRIGHT", -14, -116); sep:SetTexture(1, 1, 1, 0.08)

    -- ---- skybox ----
    local skHd = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    skHd:SetPoint("TOPLEFT", 14, -124); skHd:SetText("|cffF5C842Skybox|r")

    local skFilter = CreateFrame("EditBox", nil, card, "InputBoxTemplate")
    skFilter:SetSize(200, 18); skFilter:SetPoint("TOPLEFT", 20, -146); skFilter:SetAutoFocus(false)
    skFilter:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local skOff = ns.CreateGoldenButton(nil, card); skOff:SetSize(110, 20); skOff:SetText("Natural (off)")
    skOff:SetPoint("LEFT", skFilter, "RIGHT", 10, 0)
    skOff:EnableMouse(true)

    -- Bordered list box so the skybox list reads as a proper contained list instead
    -- of bare text floating over the card; it also spans to the card edge so nothing
    -- behind it bleeds through. The scroll sits inside with padding + a scrollbar gutter.
    local skBox = CreateFrame("Frame", nil, card)
    skBox:SetPoint("TOPLEFT", 14, -182); skBox:SetPoint("BOTTOMRIGHT", -14, 10)
    skBox:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=false, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    skBox:SetBackdropColor(0.03, 0.035, 0.05, 0.97); skBox:SetBackdropBorderColor(0.40, 0.34, 0.16, 0.85)
    skBox:SetFrameLevel(card:GetFrameLevel() + 1)
    skFilter:SetFrameLevel(card:GetFrameLevel() + 5)
    skOff:SetFrameLevel(card:GetFrameLevel() + 5)

    local skScroll = CreateFrame("ScrollFrame", "TM_Misc_SkyScroll", skBox, "UIPanelScrollFrameTemplate")
    skScroll:SetPoint("TOPLEFT", 6, -6); skScroll:SetPoint("BOTTOMRIGHT", -26, 6)
    local skContent = CreateFrame("Frame", nil, skScroll); skContent:SetSize(10, 1); skScroll:SetScrollChild(skContent)
    local skRows = {}

    local function FriendlySky(path)
        local n = path:match("([^\\]+)$") or path
        n = n:gsub("%.[Mm][Dd][Xx]$", ""):gsub("%.[Mm]2$", "")
        return n
    end
    local function BuildSkyList()
        local out = {}
        if type(TRANSMORPHER_SKYBOXES) == "table" then
            for id, path in pairs(TRANSMORPHER_SKYBOXES) do
                out[#out + 1] = { id = id, name = FriendlySky(path), path = path }
            end
            table.sort(out, function(a, b) return a.name:lower() < b.name:lower() end)
        end
        return out
    end
    local PopulateSky
    PopulateSky = function()
        local list = BuildSkyList()
        local ft = (skFilter:GetText() or ""):lower()
        for _, r in ipairs(skRows) do r:Hide() end
        local cur = EnvSky().id
        local shown = 0
        local rowW = math.max(1, skScroll:GetWidth() - 4)
        skContent:SetWidth(rowW)
        for _, it in ipairs(list) do
            if ft == "" or it.name:lower():find(ft, 1, true) then
                shown = shown + 1
                local r = skRows[shown]
                if not r then
                    r = CreateFrame("Button", nil, skContent); r:SetSize(rowW, 18)
                    local t = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); t:SetPoint("LEFT", 4, 0); t:SetPoint("RIGHT", -2, 0); t:SetJustifyH("LEFT"); r.t = t
                    local hl = r:CreateTexture(nil, "HIGHLIGHT"); hl:SetAllPoints(); hl:SetTexture(0.96, 0.78, 0.26, 0.18); r:SetHighlightTexture(hl)
                    skRows[shown] = r
                end
                r:SetWidth(rowW)
                r.sky = it
                local on = (cur == it.id)
                r.t:SetText((on and "|cff88ff88> " or "|cffcccccc") .. it.name .. "|r")
                r:SetScript("OnClick", function(self)
                    local sky = EnvSky(); sky.id = self.sky.id; sky.name = self.sky.path
                    SendSky(); PopulateSky(); PlaySound("igMainMenuOptionCheckBoxOn")
                end)
                r:SetPoint("TOPLEFT", 0, -((shown - 1) * 18)); r:Show()
            end
        end
        skContent:SetHeight(math.max(1, shown * 18))
        if shown == 0 then EnvSend("SKYBOX_LIST") end  -- not published yet; ask again
    end
    skFilter:SetScript("OnTextChanged", PopulateSky)
    skOff:SetScript("OnClick", function()
        local sky = EnvSky(); sky.id = nil; sky.name = nil; SendSky(); PopulateSky(); PlaySound("gsTitleOptionOK")
    end)

    card:SetScript("OnShow", function()
        refreshWeatherSel()
        wiSlider:SetValue(EnvWX().intensity or 60)
        wiVal:SetText(("|cffF5C842%d%%|r"):format(EnvWX().intensity or 60))
        EnvSend("SKYBOX_LIST")
        ns.RunAfter(0.4, PopulateSky)
        PopulateSky()
    end)
end

local function CreateEnvCard(parent, titleTextValue, descTextValue, yOffset, height)
    local card = CreateFrame("Frame", nil, parent)
    card:SetPoint("TOPLEFT", 8, yOffset)
    card:SetPoint("TOPRIGHT", -8, yOffset)
    card:SetHeight(height)
    card:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
    card:SetBackdropColor(0.05, 0.055, 0.07, 0.93)
    card:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

    local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -12)
    title:SetText(titleTextValue)

    local desc = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    desc:SetPoint("RIGHT", -12, 0)
    desc:SetJustifyH("LEFT")
    desc:SetText(descTextValue)
    desc:SetTextColor(0.7, 0.7, 0.7)

    return card, title, desc
end

local function MiscHexToRGB(hex)
    local clean = tostring(hex or "#FFFFFF"):gsub("#", "")
    local r = tonumber(clean:sub(1, 2), 16) or 255
    local g = tonumber(clean:sub(3, 4), 16) or 255
    local b = tonumber(clean:sub(5, 6), 16) or 255
    return r / 255, g / 255, b / 255
end

local function MiscColorByte(value)
    local n = tonumber(value) or 0
    if n <= 1 then n = n * 255 end
    n = math.floor(n + 0.5)
    if n < 0 then n = 0 elseif n > 255 then n = 255 end
    return n
end

local atmosphereCard = CreateEnvCard(atmosphereContent, "|cffF5C842Draw Distance|r", "Higher values push the horizon farther out. Toggle the checkbox to apply.", -8, 188)
local fogCard = CreateEnvCard(atmosphereContent, "|cffF5C842Fog Override|r", "Custom world fog. Off by default — enable it only with the checkbox.", -212, 208)
local fogSettingsUpdating = false

local function GetFogSettings()
    return ns.GetWorldEnvironmentSettings()
end

local function QueueFogSync()
    if ns.QueueWorldEnvironmentSync then
        ns.QueueWorldEnvironmentSync()
    end
end

local fogEnable = ns.CreateCheckbox(fogCard, "Enable Fog Override", "Override world fog color and start/end distance")
fogEnable:SetPoint("TOPLEFT", fogCard, "TOPLEFT", 10, -54)
fogEnable:SetScript("OnClick", function(self)
    if fogSettingsUpdating then return end
    ns.SetWorldEnvironmentSetting("worldFogEnabled", self:GetChecked() and true or false)
    QueueFogSync()
    PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

local fogColorLabel = fogCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fogColorLabel:SetPoint("TOPLEFT", fogEnable, "BOTTOMLEFT", 4, -14)
fogColorLabel:SetText("Fog Color")
fogColorLabel:SetTextColor(0.95, 0.88, 0.65)

local fogColorBox = CreateFrame("EditBox", "TransmorpherMiscFogColorBox", fogCard, "InputBoxTemplate")
fogColorBox:SetSize(84, 20)
fogColorBox:SetPoint("LEFT", fogColorLabel, "RIGHT", 10, 0)
fogColorBox:SetAutoFocus(false)
fogColorBox:SetMaxLetters(7)

local fogColorSwatch = CreateFrame("Button", nil, fogCard)
fogColorSwatch:SetSize(24, 24)
fogColorSwatch:SetPoint("LEFT", fogColorBox, "RIGHT", 6, 0)
fogColorSwatch:SetNormalTexture("Interface\\Buttons\\WHITE8x8")

local function UpdateFogSwatch(hex)
    local r, g, b = MiscHexToRGB(hex)
    fogColorSwatch:GetNormalTexture():SetVertexColor(r, g, b)
end

fogColorBox:SetScript("OnTextChanged", function(self)
    if fogSettingsUpdating then return end
    local text = self:GetText()
    if text:match("^#%x%x%x%x%x%x$") then
        local color = text:upper()
        ns.SetWorldEnvironmentSetting("worldFogColor", color)
        UpdateFogSwatch(color)
        -- Changing the color does NOT enable the override; that's the checkbox's job.
        if ns.GetWorldEnvironmentSettings().worldFogEnabled then QueueFogSync() end
    end
end)

fogColorSwatch:SetScript("OnClick", function()
    local settings = GetFogSettings()
    local r, g, b = MiscHexToRGB(settings.worldFogColor)
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.hasOpacity = false
    ColorPickerFrame.func = function()
        local cr, cg, cb = ColorPickerFrame:GetColorRGB()
        local hex = string.format("#%02X%02X%02X", MiscColorByte(cr), MiscColorByte(cg), MiscColorByte(cb))
        ns.SetWorldEnvironmentSetting("worldFogColor", hex)
        fogSettingsUpdating = true
        fogColorBox:SetText(hex)
        fogSettingsUpdating = false
        UpdateFogSwatch(hex)
        if ns.GetWorldEnvironmentSettings().worldFogEnabled then QueueFogSync() end
    end
    ColorPickerFrame.cancelFunc = function() end
    ColorPickerFrame:Show()
end)

local fogStartSlider = CreateFrame("Slider", "TransmorpherMiscFogStartSlider", fogCard, "OptionsSliderTemplate")
fogStartSlider:SetPoint("TOPLEFT", 20, -122)
fogStartSlider:SetPoint("RIGHT", -24, 0)
fogStartSlider:SetHeight(18)
fogStartSlider:SetMinMaxValues(0, 4000)
fogStartSlider:SetValueStep(10)
_G[fogStartSlider:GetName() .. "Low"]:SetText("0")
_G[fogStartSlider:GetName() .. "High"]:SetText("4000")
_G[fogStartSlider:GetName() .. "Text"]:SetText("Fog Start")

local fogEndSlider = CreateFrame("Slider", "TransmorpherMiscFogEndSlider", fogCard, "OptionsSliderTemplate")
fogEndSlider:SetPoint("TOPLEFT", fogStartSlider, "BOTTOMLEFT", 0, -38)
fogEndSlider:SetPoint("RIGHT", -24, 0)
fogEndSlider:SetHeight(18)
fogEndSlider:SetMinMaxValues(0, 6000)
fogEndSlider:SetValueStep(10)
_G[fogEndSlider:GetName() .. "Low"]:SetText("0")
_G[fogEndSlider:GetName() .. "High"]:SetText("6000")
_G[fogEndSlider:GetName() .. "Text"]:SetText("Fog End")

local function SyncFogSliderText(sliderFrame, value)
    local text = _G[sliderFrame:GetName() .. "Text"]
    if sliderFrame == fogStartSlider then
        text:SetText("Fog Start: " .. math.floor((value or 0) + 0.5))
    else
        text:SetText("Fog End: " .. math.floor((value or 0) + 0.5))
    end
    text:SetTextColor(1, 0.82, 0)
end

fogStartSlider:SetScript("OnValueChanged", function(self, value)
    SyncFogSliderText(self, value)
    if fogSettingsUpdating then return end
    local fogStart = math.floor((value or 0) / 10 + 0.5) * 10
    local settings = GetFogSettings()
    if settings.worldFogEnd <= fogStart then
        ns.SetWorldEnvironmentSetting("worldFogEnd", fogStart + 10)
        fogSettingsUpdating = true
        fogEndSlider:SetValue(fogStart + 10)
        fogSettingsUpdating = false
    end
    ns.SetWorldEnvironmentSetting("worldFogStart", fogStart)
    if settings.worldFogEnabled then QueueFogSync() end
end)

fogEndSlider:SetScript("OnValueChanged", function(self, value)
    SyncFogSliderText(self, value)
    if fogSettingsUpdating then return end
    local settings = GetFogSettings()
    local fogEnd = math.floor((value or 0) / 10 + 0.5) * 10
    if fogEnd <= settings.worldFogStart then
        fogEnd = settings.worldFogStart + 10
        fogSettingsUpdating = true
        self:SetValue(fogEnd)
        fogSettingsUpdating = false
    end
    ns.SetWorldEnvironmentSetting("worldFogEnd", fogEnd)
    if settings.worldFogEnabled then QueueFogSync() end
end)

local fogResetButton = ns.CreateGoldenButton(nil, fogCard)
fogResetButton:SetSize(86, 22)
fogResetButton:SetPoint("TOPRIGHT", fogCard, "TOPRIGHT", -12, -10)
fogResetButton:SetText("Reset")
fogResetButton:SetScript("OnClick", function()
    ns.ResetWorldFogSettings()
    local settings = GetFogSettings()
    fogSettingsUpdating = true
    fogEnable:SetChecked(false)
    fogColorBox:SetText(settings.worldFogColor)
    UpdateFogSwatch(settings.worldFogColor)
    fogStartSlider:SetValue(settings.worldFogStart)
    fogEndSlider:SetValue(settings.worldFogEnd)
    fogSettingsUpdating = false
    QueueFogSync()
    PlaySound("gsTitleOptionOK")
end)

local atmosphereSettingsUpdating = false

local farClipEnable = ns.CreateCheckbox(atmosphereCard, "Enable Far Clip Override", "Apply a custom draw distance for the active environment config")
farClipEnable:SetPoint("TOPLEFT", atmosphereCard, "TOPLEFT", 10, -54)
farClipEnable:SetScript("OnClick", function(self)
    if atmosphereSettingsUpdating then return end
    ns.SetWorldEnvironmentSetting("worldFarClipEnabled", self:GetChecked() and true or false)
    QueueFogSync()
    PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

local farClipHint = atmosphereCard:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
farClipHint:SetPoint("TOPLEFT", farClipEnable, "BOTTOMLEFT", 4, -8)
farClipHint:SetPoint("RIGHT", -14, 0)
farClipHint:SetJustifyH("LEFT")
farClipHint:SetText("Higher values push the horizon farther out. Use the checkbox above to apply.")

local farClipSlider = CreateFrame("Slider", "TransmorpherMiscFarClipSlider", atmosphereCard, "OptionsSliderTemplate")
farClipSlider:SetPoint("TOPLEFT", 20, -126)
farClipSlider:SetPoint("RIGHT", -24, 0)
farClipSlider:SetHeight(18)
farClipSlider:SetMinMaxValues(100, 2666)
farClipSlider:SetValueStep(1)
_G[farClipSlider:GetName() .. "Low"]:SetText("100")
_G[farClipSlider:GetName() .. "High"]:SetText("2666")
_G[farClipSlider:GetName() .. "Text"]:SetText("Far Clip")

local function SyncFarClipSliderText(value)
    local text = _G[farClipSlider:GetName() .. "Text"]
    text:SetText("Far Clip: " .. math.floor((value or 0) + 0.5))
    text:SetTextColor(1, 0.82, 0)
end

farClipSlider:SetScript("OnValueChanged", function(self, value)
    SyncFarClipSliderText(value)
    if atmosphereSettingsUpdating then return end
    -- Only store the value. The override is enabled SOLELY via the checkbox — moving
    -- the slider must never silently turn it on (that auto-enable, plus the wheel
    -- landing on the slider, is what forced an unwanted far-clip override on login).
    local farClip = math.floor((value or 0) + 0.5)
    ns.SetWorldEnvironmentSetting("worldFarClip", farClip)
    if ns.GetWorldEnvironmentSettings().worldFarClipEnabled then QueueFogSync() end
end)

local farClipResetButton = ns.CreateGoldenButton(nil, atmosphereCard)
farClipResetButton:SetSize(86, 22)
farClipResetButton:SetPoint("TOPRIGHT", atmosphereCard, "TOPRIGHT", -12, -10)
farClipResetButton:SetText("Reset")
farClipResetButton:SetScript("OnClick", function()
    ns.ResetWorldAtmosphereSettings()
    local settings = ns.GetWorldEnvironmentSettings()
    atmosphereSettingsUpdating = true
    farClipEnable:SetChecked(settings.worldFarClipEnabled and true or false)
    farClipSlider:SetValue(settings.worldFarClip)
    atmosphereSettingsUpdating = false
    PlaySound("gsTitleOptionOK")
end)

-- ============================================================
-- CAMERA (moved here from the Morph tab) — field of view control.
-- Lives in Atmosphere because it's a world/view setting; pushed wider than the
-- old 150 cap for dramatic fish-eye shots. 90 = client default.
-- ============================================================
local cameraCard = CreateEnvCard(atmosphereContent, "|cffF5C842Camera|r", "Adjust your field of view. Higher = wider, more cinematic. Client-side only.", -424, 96)

local fovApplying = false
local fovSlider = CreateFrame("Slider", "TransmorpherMiscFovSlider", cameraCard, "OptionsSliderTemplate")
fovSlider:SetPoint("TOPLEFT", cameraCard, "TOPLEFT", 20, -56)
fovSlider:SetPoint("RIGHT", cameraCard, "RIGHT", -120, 0)
fovSlider:SetHeight(18)
fovSlider:SetMinMaxValues(20, 350); fovSlider:SetValueStep(5); fovSlider:EnableMouse(true)
do
    local n = fovSlider:GetName()
    if _G[n.."Low"] then _G[n.."Low"]:SetText("20") end
    if _G[n.."High"] then _G[n.."High"]:SetText("350") end
end
local function FovLabel(v)
    local t = _G[fovSlider:GetName().."Text"]
    if t then t:SetText("Camera FOV: " .. v .. "\194\176"); t:SetTextColor(1, 0.82, 0) end
end
fovSlider:SetScript("OnValueChanged", function(self, value)
    local v = math.floor(value + 0.5)
    FovLabel(v)
    if not fovApplying and ns.Enh_SetFov then ns.Enh_SetFov(v) end
end)
fovSlider:SetScript("OnShow", function(self)
    local cur = (ns.Enh_GetFov and ns.Enh_GetFov()) or 0
    fovApplying = true
    self:SetValue(cur and cur > 0 and cur or 90)
    fovApplying = false
    FovLabel(cur and cur > 0 and cur or 90)
end)

local btnFovDefault = ns.CreateGoldenButton("TransmorpherMiscFovDefault", cameraCard)
btnFovDefault:SetSize(86, 22); btnFovDefault:SetPoint("LEFT", fovSlider, "RIGHT", 12, 0); btnFovDefault:SetText("Default")
btnFovDefault:SetScript("OnClick", function()
    if ns.Enh_SetFov then ns.Enh_SetFov(0) end
    fovApplying = true; fovSlider:SetValue(90); fovApplying = false
    FovLabel(90)
    PlaySound("gsTitleOptionOK")
end)

local hdCard = CreateEnvCard(hdFontPanel, "|cffF5C842HD Font Rendering|r", "Enable the retail-style MSDF font runtime for sharper UI text. This setting is only applied on the next client launch.", -8, 168)

local hdModeLabel = hdCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hdModeLabel:SetPoint("TOPLEFT", hdCard, "TOPLEFT", 12, -58)
hdModeLabel:SetText("Next Launch")
hdModeLabel:SetTextColor(0.95, 0.88, 0.65)

local hdModeValue = hdCard:CreateFontString(nil, "OVERLAY", "GameFontNormal")
hdModeValue:SetPoint("LEFT", hdModeLabel, "RIGHT", 8, 0)
hdModeValue:SetTextColor(1.0, 0.82, 0.20)

local hdToggle = ns.CreateCheckbox(hdCard, "Enable MSDF Font", "Persist the MSDF font runtime mode for the next client launch")
hdToggle:SetPoint("TOPLEFT", hdModeLabel, "BOTTOMLEFT", 0, -18)

local hdHint = hdCard:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hdHint:SetPoint("TOPLEFT", hdToggle, "BOTTOMLEFT", 4, -8)
hdHint:SetPoint("RIGHT", -12, 0)
hdHint:SetJustifyH("LEFT")

local hdUiUpdating = false

local function GetHdFontEnabled()
    local settings = ns.GetSettings()
    local mode = tonumber(settings.miscHdFontMode) or 0
    if mode <= 0 then mode = 0 else mode = 1 end
    settings.miscHdFontMode = mode
    return mode == 1
end

local function UpdateHdFontModeUI(enabled)
    hdUiUpdating = true
    hdToggle:SetChecked(enabled and true or false)
    hdUiUpdating = false
    hdModeValue:SetText(enabled and "MSDF" or "Native")
    hdHint:SetText(enabled and "MSDF font rendering is queued for the next launch. The current session will keep using the existing font renderer." or "Native font rendering is queued for the next launch. The current session will keep using the existing font renderer.")
end

StaticPopupDialogs["TRANSMORPHER_MSDF_RESTART"] = {
    text = "MSDF font changes only apply after you close and reopen the client.",
    button1 = OKAY,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

hdToggle:SetScript("OnClick", function(self)
    if hdUiUpdating then return end
    local enabled = self:GetChecked() and true or false
    local settings = ns.GetSettings()
    settings.miscHdFontMode = enabled and 1 or 0
    UpdateHdFontModeUI(enabled)
    if ns.SendRawMorphCommand and ns.IsMorpherReady and ns.IsMorpherReady() then
        ns.SendRawMorphCommand("MSDF_MODE:" .. (enabled and "1" or "0"))
    end
    StaticPopup_Show("TRANSMORPHER_MSDF_RESTART")
    SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: MSDF font rendering is queued for the next client launch.")
    PlaySound(enabled and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
end)

atmospherePanel:SetScript("OnShow", function()
    local settings = ns.GetWorldEnvironmentSettings()
    atmosphereSettingsUpdating = true
    farClipEnable:SetChecked(settings.worldFarClipEnabled and true or false)
    farClipSlider:SetValue(settings.worldFarClip)
    atmosphereSettingsUpdating = false

    fogSettingsUpdating = true
    fogEnable:SetChecked(settings.worldFogEnabled and true or false)
    fogColorBox:SetText(settings.worldFogColor)
    UpdateFogSwatch(settings.worldFogColor)
    fogStartSlider:SetValue(settings.worldFogStart)
    fogEndSlider:SetValue(settings.worldFogEnd)
    fogSettingsUpdating = false
end)

hdFontPanel:SetScript("OnShow", function()
    UpdateHdFontModeUI(GetHdFontEnabled())
end)

analysisPanel:SetScript("OnShow", function(self)
    if not self.transmorpherWorldAnalysisBuilt and ns.InitializeWorldAnalysisPanel then
        ns.InitializeWorldAnalysisPanel(self)
    end

    if ns.RefreshWorldAnalysisControls then
        ns.RefreshWorldAnalysisControls()
    end
end)

local titleTopBar = CreateFrame("Frame", nil, titlesPanel)
titleTopBar:SetPoint("TOPLEFT", 8, -8)
titleTopBar:SetPoint("TOPRIGHT", -8, -8)
titleTopBar:SetHeight(30)
titleTopBar:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
titleTopBar:SetBackdropColor(0.05, 0.055, 0.07, 0.93)
titleTopBar:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local titleSearchShell = CreateFrame("Frame", nil, titleTopBar)
titleSearchShell:SetPoint("TOPLEFT", 8, -4)
titleSearchShell:SetPoint("BOTTOMRIGHT", -94, 4)
titleSearchShell:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
titleSearchShell:SetBackdropColor(0.03, 0.03, 0.04, 0.9)
titleSearchShell:SetBackdropBorderColor(0.30, 0.28, 0.24, 0.7)

local titleSearchIcon = titleSearchShell:CreateTexture(nil, "OVERLAY")
titleSearchIcon:SetSize(14, 14); titleSearchIcon:SetPoint("LEFT", 6, 0)
titleSearchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon"); titleSearchIcon:SetVertexColor(0.96, 0.82, 0.30)

local titleSearch = CreateFrame("EditBox", "$parentTitleSearch", titleSearchShell)
titleSearch:SetPoint("LEFT", titleSearchIcon, "RIGHT", 4, 0); titleSearch:SetPoint("BOTTOMRIGHT", -22, 1)
titleSearch:SetAutoFocus(false); titleSearch:SetFontObject("ChatFontNormal"); titleSearch:SetTextInsets(0, 0, 0, 0); titleSearch:SetTextColor(0.95, 0.88, 0.65)

local titleSearchHint = titleSearch:CreateFontString(nil, "ARTWORK", "GameFontDisable")
titleSearchHint:SetPoint("LEFT", 0, 0); titleSearchHint:SetText("Search titles...")
titleSearch:SetScript("OnEditFocusGained", function() titleSearchHint:Hide() end)
titleSearch:SetScript("OnEditFocusLost", function(self) if self:GetText() == "" then titleSearchHint:Show() end end)
titleSearch:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

local btnClear = CreateFrame("Button", nil, titleSearchShell)
btnClear:SetSize(14, 14); btnClear:SetPoint("RIGHT", -4, 0)
btnClear:SetNormalTexture("Interface\\FriendsFrame\\ClearBroadcastIcon"); btnClear:SetAlpha(0.6)
btnClear:SetScript("OnClick", function() titleSearch:SetText(""); titleSearch:ClearFocus(); titleSearchHint:Show() end)

local btnResetTitle = ns.CreateGoldenButton("$parentResetTitle", titleTopBar)
btnResetTitle:SetPoint("RIGHT", -8, 0); btnResetTitle:SetSize(76, 22); btnResetTitle:SetText("Reset")
btnResetTitle:SetScript("OnClick", function()
    if ns.IsMorpherReady() then
        ns.SendMorphCommand("TITLE_RESET")
        if TransmorpherCharacterState then TransmorpherCharacterState.TitleID = nil end
        SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Title reset to original.")
        PlaySound("gsTitleOptionOK")
    end
end)

local titleResultCount = titleTopBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
titleResultCount:SetPoint("RIGHT", btnResetTitle, "LEFT", -8, 0)
titleResultCount:SetTextColor(0.78, 0.66, 0.40, 0.8)

local titleListBg = CreateFrame("Frame", "$parentTitleListBg", titlesPanel)
titleListBg:SetPoint("TOPLEFT", 8, -42); titleListBg:SetPoint("BOTTOMRIGHT", -8, 8)
titleListBg:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
titleListBg:SetBackdropColor(0.04, 0.045, 0.06, 0.94); titleListBg:SetBackdropBorderColor(0.45, 0.38, 0.18, 0.72)

local titleListScroll = CreateFrame("ScrollFrame", "$parentTitleListScroll", titleListBg, "UIPanelScrollFrameTemplate")
titleListScroll:SetPoint("TOPLEFT", 4, -4); titleListScroll:SetPoint("BOTTOMRIGHT", -22, 4)
local titleListContent = CreateFrame("Frame", nil, titleListScroll)
titleListContent:SetSize(titleListScroll:GetWidth(), 1); titleListScroll:SetScrollChild(titleListContent)

local titleBtns = {}
local TITLE_ROW_H = 22

local function UpdateTitles()
    local query = titleSearch:GetText():lower()
    local y = 0
    for _, b in ipairs(titleBtns) do b:Hide() end
    if Transmorpher_Titles then
        for _, t in ipairs(Transmorpher_Titles) do
            local name = t.name:gsub("%%s", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if name == "" then name = t.name end
            if query == "" or name:lower():find(query, 1, true) then
                y = y + 1
                local b = titleBtns[y]
                if not b then
                    b = CreateFrame("Button", nil, titleListContent)
                    b:SetSize(titleListContent:GetWidth(), TITLE_ROW_H)
                    b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
                    b:GetHighlightTexture():SetVertexColor(1, 0.92, 0.56, 0.12)
                    local rowBg = b:CreateTexture(nil, "BACKGROUND"); rowBg:SetAllPoints(); b.rowBg = rowBg
                    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft"); fs:SetPoint("LEFT", 8, 0); b.text = fs
                    local idFs = b:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"); idFs:SetPoint("RIGHT", -8, 0); b.idText = idFs
                    b:SetScript("OnClick", function(self)
                        ns.SendMorphCommand("TITLE:"..self.titleID)
                        if not TransmorpherCharacterState then TransmorpherCharacterState = {} end
                        TransmorpherCharacterState.TitleID = self.titleID
                        
                        if ns.BroadcastMorphState then ns.BroadcastMorphState(true) end
                        
                        SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: Title set: "..self.titleName)
                        PlaySound("gsTitleOptionOK")
                    end)
                    titleBtns[y] = b
                end
                b.titleID = t.id; b.titleName = name; b.text:SetText(name); b.idText:SetText(t.id)
                if b.rowBg then
                    if y % 2 == 0 then b.rowBg:SetTexture(1, 1, 1, 0.025) else b.rowBg:SetTexture(0, 0, 0, 0) end
                end
                b:SetPoint("TOPLEFT", 0, -((y-1)*TITLE_ROW_H)); b:Show()
            end
        end
    end
    titleListContent:SetHeight(math.max(1, y * TITLE_ROW_H))
    if titleResultCount then
        if y > 0 then titleResultCount:SetText("|cffC8AA6E" .. y .. " titles|r")
        else titleResultCount:SetText("|cff6a6050No titles found|r") end
    end
end


titleSearch:SetScript("OnTextChanged", UpdateTitles)
