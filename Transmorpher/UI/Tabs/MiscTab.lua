local addon, ns = ...

-- ============================================================
-- MISC TAB — Environment (Time Control) & Titles sub-tabs
-- ============================================================

local mainFrame = ns.mainFrame
local miscTab = mainFrame.tabs.env

local subTabBar = CreateFrame("Frame", nil, miscTab)
subTabBar:SetSize(220, 30); subTabBar:SetPoint("TOPLEFT", 0, -20)

local envPanel = CreateFrame("Frame", "$parentEnvPanel", miscTab)
envPanel:SetPoint("TOPLEFT", 0, -50); envPanel:SetPoint("BOTTOMRIGHT")

local titlesPanel = CreateFrame("Frame", "$parentTitlesPanel", miscTab)
titlesPanel:SetPoint("TOPLEFT", 0, -50); titlesPanel:SetPoint("BOTTOMRIGHT"); titlesPanel:Hide()

local function CreateMiscSubTabBtn(id, text)
    local btn = CreateFrame("Button", nil, subTabBar)
    btn:SetID(id); btn:SetSize(110, 30)
    local bg = btn:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetTexture(1,1,1,0); btn.bg = bg
    local line = btn:CreateTexture(nil, "OVERLAY"); line:SetHeight(2)
    line:SetPoint("BOTTOMLEFT", 15, 0); line:SetPoint("BOTTOMRIGHT", -15, 0)
    line:SetTexture(1, 0.82, 0); line:Hide(); btn.line = line
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("CENTER"); fs:SetText(text); fs:SetTextColor(0.5,0.5,0.5); btn.fs = fs
    btn.SetActive = function(self, active)
        self.isActive = active
        if active then self.line:Show(); self.fs:SetTextColor(1,1,1); self.bg:SetTexture(1,1,1,0.05)
        else self.line:Hide(); self.fs:SetTextColor(0.5,0.5,0.5); self.bg:SetTexture(0,0,0,0) end
    end
    btn:SetScript("OnEnter", function(self) if not self.isActive then self.fs:SetTextColor(0.9,0.9,0.9); self.bg:SetTexture(1,1,1,0.03) end end)
    btn:SetScript("OnLeave", function(self) if not self.isActive then self.fs:SetTextColor(0.5,0.5,0.5); self.bg:SetTexture(0,0,0,0) end end)
    return btn
end

local btnEnv = CreateMiscSubTabBtn(1, "Environment"); btnEnv:SetPoint("LEFT", 0, 0); btnEnv:SetWidth(85)
local btnTitles = CreateMiscSubTabBtn(2, "Titles"); btnTitles:SetPoint("LEFT", btnEnv, "RIGHT", 0, 0); btnTitles:SetWidth(85)
local btnOpt = CreateMiscSubTabBtn(3, "Optimization"); btnOpt:SetPoint("LEFT", btnTitles, "RIGHT", 0, 0); btnOpt:SetWidth(100)

local function ShowMiscSubTab(id)
    envPanel[id == 1 and "Show" or "Hide"](envPanel)
    titlesPanel[id == 2 and "Show" or "Hide"](titlesPanel)
    if optimizationPanel then optimizationPanel[id == 3 and "Show" or "Hide"](optimizationPanel) end
    btnEnv:SetActive(id == 1); btnTitles:SetActive(id == 2); btnOpt:SetActive(id == 3)
    PlaySound("gsTitleOptionOK")
end

btnEnv:SetScript("OnClick", function() ShowMiscSubTab(1) end)
btnTitles:SetScript("OnClick", function() ShowMiscSubTab(2) end)
btnOpt:SetScript("OnClick", function() ShowMiscSubTab(3) end)
ShowMiscSubTab(1)

-- ============================================================
-- OPTIMIZATION PANEL
-- ============================================================
local ShowOptSubTab -- forward decl

local optPanel = CreateFrame("Frame", "$parentOptPanel", miscTab)
optPanel:SetPoint("TOPLEFT", 0, -50); optPanel:SetPoint("BOTTOMRIGHT"); optPanel:Hide()
optimizationPanel = optPanel

-- Optimization Sub-Tab Bar
local optSubTabBar = CreateFrame("Frame", nil, optPanel)
optSubTabBar:SetSize(300, 24); optSubTabBar:SetPoint("TOPLEFT", 4, -4)

local btnOptGeneral = CreateMiscSubTabBtn(1, "General Optimization")
btnOptGeneral:SetParent(optSubTabBar); btnOptGeneral:SetPoint("LEFT", 0, 0); btnOptGeneral:SetSize(140, 24)
btnOptGeneral:SetScript("OnClick", function() ShowOptSubTab(1) end)

local btnOptProtect = CreateMiscSubTabBtn(2, "Spell Protection")
btnOptProtect:SetParent(optSubTabBar); btnOptProtect:SetPoint("LEFT", btnOptGeneral, "RIGHT", 4, 0); btnOptProtect:SetSize(120, 24)
btnOptProtect:SetScript("OnClick", function() ShowOptSubTab(2) end)

local optGeneralPanel = CreateFrame("Frame", nil, optPanel); optGeneralPanel:SetAllPoints()
local optProtectPanel = CreateFrame("Frame", nil, optPanel); optProtectPanel:SetAllPoints(); optProtectPanel:Hide()

ShowOptSubTab = function(id)
    optGeneralPanel[id == 1 and "Show" or "Hide"](optGeneralPanel)
    optProtectPanel[id == 2 and "Show" or "Hide"](optProtectPanel)
    btnOptGeneral:SetActive(id == 1); btnOptProtect:SetActive(id == 2)
    PlaySound("gsTitleOptionOK")
end
ShowOptSubTab(1)

-- ============================================================
-- OPT GENERAL (TOGGLES)
-- ============================================================
local optCard = CreateFrame("Frame", nil, optGeneralPanel)
optCard:SetPoint("TOPLEFT", 8, -48); optCard:SetPoint("TOPRIGHT", -8, -48); optCard:SetHeight(380)
optCard:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", tile=true, tileSize=8, edgeSize=1, insets={left=1,right=1,top=1,bottom=1}})
optCard:SetBackdropColor(0.05, 0.055, 0.07, 0.93); optCard:SetBackdropBorderColor(0.56, 0.47, 0.20, 0.78)

local optTitle = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optTitle:SetPoint("TOPLEFT", 12, -12); optTitle:SetText("|cffF5C842Spell Visibility & Optimization|r")

local optDesc = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
optDesc:SetPoint("TOPLEFT", optTitle, "BOTTOMLEFT", 0, -4); optDesc:SetText("Toggle specific spell effects globally to maximize performance."); optDesc:SetTextColor(0.7, 0.7, 0.7)

local optWarning = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
optWarning:SetPoint("TOPLEFT", optDesc, "BOTTOMLEFT", 0, -2)
optWarning:SetText("|cffFF4444Warning:|r Some settings may hide boss mechanics even with active filters.")
optWarning:SetTextColor(0.9, 0.3, 0.3)
    
    local optBenefit = optCard:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    optBenefit:SetPoint("TOPLEFT", optWarning, "BOTTOMLEFT", 0, -6)
    optBenefit:SetText("|cff44ff44This optimization provides a massive FPS boost in raids and crowded areas.|r")

local optimizationCheckboxes = {}

local function CreateOptCheckbox(name, label, tooltip, settingKey, cmdPrefix)
    local cb = CreateFrame("CheckButton", "$parent"..name, optCard, "ChatConfigCheckButtonTemplate")
    cb:SetSize(22, 22)
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
    
    local sep1 = optCard:CreateTexture(nil, "ARTWORK")
    sep1:SetSize(400, 1); sep1:SetPoint("TOPLEFT", 16, -108); sep1:SetTexture(1, 1, 1, 0.08)

-- Column 1
    local col1X = 22
    local yPos1 = -120
local rowH = 22
local secGap = 32

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

-- ============================================================
-- PROTECTION WHITELIST (WHITE CARD)
-- ============================================================
optCard:SetScript("OnShow", function()
    -- Sub-tab specific show logic can go here if needed
end)

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
protDesc:SetPoint("TOPLEFT", protTitle, "BOTTOMLEFT", 0, -4); protDesc:SetText("Protect spells from optimization. Automated for custom IDs > 80864."); protDesc:SetTextColor(0.7, 0.7, 0.7)

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

local UpdateActiveProtList, UpdateProtSearchResults -- Forward declarations

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
            b.action:SetBackdropBorderColor(isProt and 0.8, 0.2, 0.2, 0.6 or 0.2, 0.8, 0.2, 0.6)
            b:SetPoint("TOPLEFT", 0, -((y-1)*PROT_ROW_H)); b:Show()
        end
    end
    listContent:SetHeight(math.max(1, y * PROT_ROW_H))
end

-- Delay utility for 3.3.5 (since C_Timer is nil)
local function SimpleTimer_After(delay, func)
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
-- ENVIRONMENT PANEL (Existing)
-- ============================================================
local timeCard = CreateFrame("Frame", nil, envPanel)
timeCard:SetPoint("TOPLEFT", 8, -8)
timeCard:SetPoint("TOPRIGHT", -8, -8)
timeCard:SetHeight(150)
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
