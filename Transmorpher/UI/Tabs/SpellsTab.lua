local addon, ns = ...

-- Helper for finding spell IDs in the spellbook
local function GetSpellBookSpellId(spellBookIndex)
    local bookType = BOOKTYPE_SPELL or "spell"
    if type(GetSpellBookItemInfo) == "function" then
        local spellType, spellId = GetSpellBookItemInfo(spellBookIndex, bookType)
        if spellType == "SPELL" and spellId then
            return tonumber(spellId)
        end
    end
    -- Fallbacks for different client builds/locales
    if type(GetSpellLink) == "function" then
        local link = GetSpellLink(spellBookIndex, bookType)
        if link then
            local spellId = tonumber(link:match("spell:(%d+)"))
            if spellId and spellId > 0 then return spellId end
        end
    end
    return nil
end

-- Builds a list of spells for the main list
local function BuildSpellPool(showAllRanks)
    local pool = {}
    local seen = {}
    local nameToBestId = {}

    local function AddSpell(spellId)
        if not spellId or seen[spellId] then return end
        local name, rank, icon = GetSpellInfo(spellId)
        if not name or name == "" then return end
        
        seen[spellId] = true
        local entry = {
            id = spellId,
            name = name,
            rank = rank,
            fullName = (rank and rank ~= "") and (name .. " " .. rank) or name,
            icon = icon or "Interface\\Icons\\Spell_Holy_MagicalSentry",
            nameLower = name:lower(),
        }

        if not showAllRanks then
            -- "Latest Rank" logic: Keep the highest ID for each unique name
            if not nameToBestId[entry.nameLower] or spellId > nameToBestId[entry.nameLower].id then
                nameToBestId[entry.nameLower] = entry
            end
        else
            table.insert(pool, entry)
        end
    end

    -- 1. Scan player spellbook
    local numTabs = GetNumSpellTabs() or 0
    for tab = 1, numTabs do
        local _, _, offset, numSpells = GetSpellTabInfo(tab)
        if offset and numSpells then
            for i = 1, numSpells do
                local sId = GetSpellBookSpellId(offset + i)
                if sId then AddSpell(sId) end
            end
        end
    end

    -- 2. Include active morphs so they don't disappear from the list
    if TransmorpherCharacterState and TransmorpherCharacterState.SpellMorphs then
        for sourceId in pairs(TransmorpherCharacterState.SpellMorphs) do
            AddSpell(tonumber(sourceId))
        end
    end

    if not showAllRanks then
        for _, entry in pairs(nameToBestId) do
            table.insert(pool, entry)
        end
    end

    table.sort(pool, function(a, b)
        if a.nameLower ~= b.nameLower then return a.nameLower < b.nameLower end
        return a.id > b.id
    end)

    return pool
end

function ns.InitSpellsTab(parent)
    local morphSubTab = CreateFrame("Frame", "$parentMorphSubTab", parent)
    morphSubTab:SetPoint("TOPLEFT", 0, -50)
    morphSubTab:SetPoint("BOTTOMRIGHT")
    parent.morphSubTab = morphSubTab

    local subTabBar = CreateFrame("Frame", nil, parent)
    subTabBar:SetSize(300, 30)
    subTabBar:SetPoint("TOPLEFT", 0, -18)

    local function CreateSubTabButton(tabParent, id, text)
        local btn = CreateFrame("Button", nil, tabParent)
        btn:SetID(id)
        btn:SetSize(150, 30)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetTexture(1, 1, 1, 0)
        btn.bg = bg

        local line = btn:CreateTexture(nil, "OVERLAY")
        line:SetHeight(2)
        line:SetPoint("BOTTOMLEFT", 15, 0)
        line:SetPoint("BOTTOMRIGHT", -15, 0)
        line:SetTexture(1, 0.82, 0)
        line:Hide()
        btn.line = line

        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("CENTER")
        fs:SetText(text)
        fs:SetTextColor(0.5, 0.5, 0.5)
        btn.fs = fs

        btn.SetActive = function(self, active)
            self.isActive = active
            if active then
                self.line:Show()
                self.fs:SetTextColor(1, 1, 1)
                self.bg:SetTexture(1, 1, 1, 0.05)
            else
                self.line:Hide()
                self.fs:SetTextColor(0.5, 0.5, 0.5)
                self.bg:SetTexture(0, 0, 0, 0)
            end
        end

        btn:SetScript("OnEnter", function(self)
            if not self.isActive then
                self.fs:SetTextColor(0.9, 0.9, 0.9)
                self.bg:SetTexture(1, 1, 1, 0.03)
            end
        end)

        btn:SetScript("OnLeave", function(self)
            if not self.isActive then
                self.fs:SetTextColor(0.5, 0.5, 0.5)
                self.bg:SetTexture(0, 0, 0, 0)
            end
        end)

        return btn
    end

    local btnMorphs = CreateSubTabButton(subTabBar, 1, "Spell Morphs")
    btnMorphs:SetPoint("LEFT", 0, 0)

    local spellPool = {}
    local filteredPool = {}
    local searchResults = {}
    local activeSourceSpellId = nil

    local scroll = CreateFrame("ScrollFrame", "$parentScroll", morphSubTab, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -50)
    scroll:SetPoint("BOTTOMRIGHT", -26, 10)

    local selector = CreateFrame("Frame", "TransmorpherSpellSelector", morphSubTab)
    local searchBox
    local resultScroll

    local function UpdateFilteredPool(q)
        q = (q or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
        filteredPool = {}
        if not spellPool or #spellPool == 0 then
            spellPool = BuildSpellPool(selector.showAllRanks)
        end
        if q == "" then
            filteredPool = spellPool
        else
            for _, entry in ipairs(spellPool) do
                if (entry.nameLower and entry.nameLower:find(q, 1, true)) or tostring(entry.id):find(q, 1, true) then
                    table.insert(filteredPool, entry)
                end
            end
        end
    end

    local OpenSelector

    local function CreateSpellRow(p)
        local f = CreateFrame("Button", nil, p)
        f:SetSize(morphSubTab:GetWidth() > 0 and (morphSubTab:GetWidth() - 40) or 500, 44)
        f:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        f:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false, tileSize = 0, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        f:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
        f:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.9)

        f.icon = f:CreateTexture(nil, "ARTWORK")
        f.icon:SetSize(32, 32)
        f.icon:SetPoint("LEFT", 6, 0)
        f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        f.name:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 10, -2)
        f.name:SetTextColor(0.96, 0.90, 0.72)

        f.subText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.subText:SetPoint("TOPLEFT", f.name, "BOTTOMLEFT", 0, -2)
        f.subText:SetTextColor(0.6, 0.6, 0.6)

        f.assign = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        f.assign:SetPoint("RIGHT", -110, 0)
        f.assign:SetTextColor(0.4, 1.0, 0.6)
        f.assign:SetJustifyH("RIGHT")

        f.actionBtn = ns.CreateGoldenButton(nil, f)
        f.actionBtn:SetSize(90, 22)
        f.actionBtn:SetPoint("RIGHT", -8, 0)

        f:SetScript("OnClick", function(self)
            if self.data then OpenSelector(self.data) end
        end)
        f.actionBtn:SetScript("OnClick", function(self)
            local pRow = self:GetParent()
            if pRow.data then OpenSelector(pRow.data) end
        end)

        return f
    end

    local rows = {}
    local NUM_ROWS = math.floor((morphSubTab:GetHeight() - 60) / 46)
    if NUM_ROWS < 1 then NUM_ROWS = 10 end
    local ROW_HEIGHT = 46

    local function UpdateScroll()
        FauxScrollFrame_Update(scroll, #filteredPool, NUM_ROWS, ROW_HEIGHT)
        local offset = FauxScrollFrame_GetOffset(scroll)
        for i = 1, NUM_ROWS do
            local idx = i + offset
            local row = rows[i]
            if not row then break end
            local data = filteredPool[idx]
            if data then
                row.data = data
                row.icon:SetTexture(data.icon)
                row.name:SetText(data.name)
                row.subText:SetText("ID " .. data.id .. (data.rank and data.rank ~= "" and (" · " .. data.rank) or ""))

                local targetId = ns.GetSpellMorph and ns.GetSpellMorph(data.id)
                if targetId then
                    local tName = GetSpellInfo(targetId)
                    row.assign:SetText(tName or ("Spell " .. targetId))
                    row.assign:SetTextColor(0.3, 1.0, 0.5)
                    row.actionBtn:SetText("Change")
                else
                    row.assign:SetText("")
                    row.actionBtn:SetText("Select")
                end
                row:Show()
            else
                row:Hide()
            end
        end
    end

    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, UpdateScroll)
    end)

    for i = 1, NUM_ROWS do
        rows[i] = CreateSpellRow(morphSubTab)
        rows[i]:SetPoint("TOPLEFT", 10, -50 - (i - 1) * ROW_HEIGHT)
        rows[i]:Hide()
    end

    local header = CreateFrame("Frame", nil, morphSubTab)
    header:SetPoint("TOPLEFT", 6, -6)
    header:SetPoint("TOPRIGHT", -26, -6)
    header:SetHeight(40)
    header:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    header:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    header:SetBackdropBorderColor(0.35, 0.30, 0.18, 0.9)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", 10, 0)
    title:SetText("|cffF5C842Direct Spell Morphs|r")
    title:SetTextColor(0.95, 0.88, 0.65)

    local mainSearch = CreateFrame("EditBox", nil, header)
    mainSearch:SetSize(220, 22)
    mainSearch:SetPoint("RIGHT", -10, 0)
    mainSearch:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1 })
    mainSearch:SetBackdropColor(0, 0, 0, 0.5)
    mainSearch:SetFontObject("ChatFontNormal")
    mainSearch:SetAutoFocus(false)
    mainSearch:SetTextInsets(8, 8, 0, 0)
    local mainSearchHint = mainSearch:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    mainSearchHint:SetPoint("LEFT", 8, 0)
    mainSearchHint:SetText("Filter spellbook...")

    mainSearch:SetScript("OnTextChanged", function(self)
        if self:GetText() == "" then mainSearchHint:Show() else mainSearchHint:Hide() end
        UpdateFilteredPool(self:GetText())
        UpdateScroll()
    end)

    selector:SetSize(460, 720)
    selector:SetPoint("CENTER", 0, 0)
    selector:SetFrameStrata("DIALOG")
    selector:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    selector:SetBackdropColor(0.03, 0.03, 0.03, 0.98)
    selector:SetBackdropBorderColor(0.60, 0.50, 0.20, 0.95)
    selector:EnableMouse(true)
    selector:SetMovable(true)
    selector:SetClampedToScreen(true)
    selector:Hide()

    local selTitle = selector:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    selTitle:SetPoint("TOPLEFT", 14, -14)
    selTitle:SetTextColor(1.0, 0.84, 0.35)

    local selStatus = selector:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    selStatus:SetPoint("TOPRIGHT", -40, -18)
    selStatus:SetTextColor(0.5, 0.5, 0.5)

    local selSubTitle = selector:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    selSubTitle:SetPoint("TOPLEFT", 16, -36)
    selSubTitle:SetTextColor(0.74, 0.74, 0.74)
    selSubTitle:SetText("Press TAB to toggle All Ranks")

    local selClose = CreateFrame("Button", nil, selector, "UIPanelCloseButton")
    selClose:SetPoint("TOPRIGHT", -4, -4)

    searchBox = CreateFrame("EditBox", nil, selector)
    searchBox:SetSize(432, 28)
    searchBox:SetPoint("TOPLEFT", 14, -54)
    searchBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    searchBox:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    searchBox:SetBackdropBorderColor(0.30, 0.30, 0.30, 1)
    searchBox:SetFontObject("ChatFontNormal")
    searchBox:SetAutoFocus(false)
    searchBox:SetTextInsets(10, 10, 0, 0)
    local searchHint = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchHint:SetPoint("LEFT", 10, 0)
    searchHint:SetText("Search database (50,000+ spells)...")

    resultScroll = CreateFrame("ScrollFrame", "$parentResultScroll", selector, "FauxScrollFrameTemplate")
    resultScroll:SetPoint("TOPLEFT", 14, -90)
    resultScroll:SetPoint("BOTTOMRIGHT", -32, 44)
    local dummy = CreateFrame("Frame", nil, resultScroll)
    dummy:SetSize(1, 1)
    resultScroll:SetScrollChild(dummy)

    local resultContainer = CreateFrame("Frame", nil, selector)
    resultContainer:SetPoint("TOPLEFT", 14, -90)
    resultContainer:SetPoint("BOTTOMRIGHT", -32, 44)

    local resultRows = {}
    local RESULT_ROWS = 28
    local RESULT_HEIGHT = 21

    local function UpdateResultScroll()
        FauxScrollFrame_Update(resultScroll, #searchResults, RESULT_ROWS, RESULT_HEIGHT)
        selStatus:SetText("Results: " .. #searchResults)
        local offset = FauxScrollFrame_GetOffset(resultScroll)
        for i = 1, RESULT_ROWS do
            local idx = i + offset
            local row = resultRows[i]
            if not row then break end
            local data = searchResults[idx]
            if data then
                row.spellId = data.id
                row.icon:SetTexture(data.icon)
                row.text:SetText(data.name)
                row.didText:SetText("ID " .. data.id)
                row:Show()
            else
                row:Hide()
            end
        end
    end

    for i = 1, RESULT_ROWS do
        local btn = CreateFrame("Button", nil, resultContainer)
        btn:SetSize(396, RESULT_HEIGHT - 1)
        btn:SetPoint("TOPLEFT", 0, -(i - 1) * RESULT_HEIGHT)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        btn:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false, tileSize = 0, edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        btn:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
        btn:SetBackdropBorderColor(0.20, 0.20, 0.20, 0.9)
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(16, 16)
        btn.icon:SetPoint("LEFT", 5, 0)
        btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 8, 0)
        btn.text:SetJustifyH("LEFT")
        btn.didText = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        btn.didText:SetPoint("RIGHT", -8, 0)

        btn:SetScript("OnClick", function(self)
            if not activeSourceSpellId then return end
            ns.SetSpellMorph(activeSourceSpellId, self.spellId)
            ns.SendMorphCommand("SPELL_MORPH:" .. activeSourceSpellId .. ":" .. self.spellId)
            UpdateScroll()
            selector:Hide()
            PlaySound("gsTitleOptionOK")
        end)
        resultRows[i] = btn
    end

    resultScroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, RESULT_HEIGHT, UpdateResultScroll)
    end)

    local pollFrame = CreateFrame("Frame")
    local function PerformSearch(query)
        TRANSMORPHER_SEARCH_RESULTS = nil
        ns.SendMorphCommand("SPELL_SEARCH:" .. (query or ""))

        local pollStart = GetTime()
        pollFrame:SetScript("OnUpdate", function(self)
            local res = TRANSMORPHER_SEARCH_RESULTS
            if res or (GetTime() - pollStart > 0.2) then
                self:SetScript("OnUpdate", nil)
                res = res or ""
                searchResults = {}
                for sId in res:gmatch("(%d+)|") do
                    local id = tonumber(sId)
                    if id then
                        local name, rank, icon = GetSpellInfo(id)
                        if name then
                            table.insert(searchResults, {
                                id = id,
                                name = (rank and rank ~= "") and (name .. " " .. rank) or name,
                                icon = icon or "Interface\\Icons\\Spell_Holy_MagicalSentry",
                            })
                        end
                    end
                end
                UpdateResultScroll()
            end
        end)
    end

    OpenSelector = function(data)
        activeSourceSpellId = data.id
        selTitle:SetText("Morph: " .. data.name)
        searchBox:SetText("")
        searchHint:Show()
        searchResults = {}
        PerformSearch("")
        selector:Show()
        searchBox:SetFocus()
    end

    searchBox:SetScript("OnTextChanged", function(self)
        local txt = self:GetText()
        if txt == "" then searchHint:Show() else searchHint:Hide() end
        PerformSearch(txt)
    end)

    searchBox:SetScript("OnTabPressed", function()
        selector.showAllRanks = not selector.showAllRanks
        spellPool = BuildSpellPool(selector.showAllRanks)
        UpdateFilteredPool(mainSearch:GetText())
        UpdateScroll()
        PlaySound("igMainMenuOptionCheckBoxOn")
    end)

    local btnClear = ns.CreateGoldenButton(nil, selector)
    btnClear:SetSize(120, 24)
    btnClear:SetPoint("BOTTOMLEFT", 14, 12)
    btnClear:SetText("Remove Morph")
    btnClear:SetScript("OnClick", function()
        if activeSourceSpellId then
            ns.SetSpellMorph(activeSourceSpellId, nil)
            ns.SendMorphCommand("SPELL_RESET:" .. activeSourceSpellId)
            UpdateScroll()
            selector:Hide()
            PlaySound("gsTitleOptionOK")
        end
    end)

    local function RefreshMorphView()
        spellPool = BuildSpellPool(selector.showAllRanks)
        UpdateFilteredPool(mainSearch:GetText())
        UpdateScroll()
        ns.SendMorphCommand("SPELL_DBC_STATUS")
    end

    -- ============================================================
    -- SPELL MORPH PROFILE EXPORT / IMPORT / CLEAR ALL
    -- ============================================================

    -- Action bar below header
    local actionBar = CreateFrame("Frame", nil, morphSubTab)
    actionBar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -2)
    actionBar:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, -2)
    actionBar:SetHeight(28)
    actionBar:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    actionBar:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    actionBar:SetBackdropBorderColor(0.25, 0.22, 0.14, 0.8)

    local btnSpellExport = ns.CreateGoldenButton(nil, actionBar)
    btnSpellExport:SetSize(72, 20)
    btnSpellExport:SetPoint("LEFT", 8, 0)
    btnSpellExport:SetText("Export")

    local btnSpellImport = ns.CreateGoldenButton(nil, actionBar)
    btnSpellImport:SetSize(72, 20)
    btnSpellImport:SetPoint("LEFT", btnSpellExport, "RIGHT", 6, 0)
    btnSpellImport:SetText("Import")

    local btnClearAll = ns.CreateGoldenButton(nil, actionBar)
    btnClearAll:SetSize(82, 20)
    btnClearAll:SetPoint("LEFT", btnSpellImport, "RIGHT", 6, 0)
    btnClearAll:SetText("Clear All")

    local morphCountLabel = actionBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    morphCountLabel:SetPoint("RIGHT", -10, 0)
    morphCountLabel:SetTextColor(0.6, 0.6, 0.6)

    local function UpdateMorphCount()
        local count = 0
        if TransmorpherCharacterState and TransmorpherCharacterState.SpellMorphs then
            for _ in pairs(TransmorpherCharacterState.SpellMorphs) do
                count = count + 1
            end
        end
        if count > 0 then
            morphCountLabel:SetText("|cffF5C842" .. count .. "|r active morph" .. (count == 1 and "" or "s"))
        else
            morphCountLabel:SetText("|cff888888No active morphs|r")
        end
    end

    -- Adjust scroll frame to account for the new action bar
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", 0, -80)
    scroll:SetPoint("BOTTOMRIGHT", -26, 10)

    -- Adjust row positions
    for i = 1, NUM_ROWS do
        rows[i]:ClearAllPoints()
        rows[i]:SetPoint("TOPLEFT", 10, -80 - (i - 1) * ROW_HEIGHT)
    end

    -- ============================================================
    -- String Dialog (shared by export and import)
    -- ============================================================

    local smDialog = CreateFrame("Frame", "TransmorpherSpellMorphStringDialog", UIParent)
    smDialog:SetSize(520, 200)
    smDialog:SetPoint("CENTER")
    smDialog:SetFrameStrata("FULLSCREEN_DIALOG")
    smDialog:SetToplevel(true)
    smDialog:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })
    smDialog:Hide()
    smDialog:EnableMouse(true)
    smDialog:SetMovable(true)
    smDialog:RegisterForDrag("LeftButton")
    smDialog:SetScript("OnDragStart", smDialog.StartMoving)
    smDialog:SetScript("OnDragStop", smDialog.StopMovingOrSizing)

    local smDialogTitle = smDialog:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    smDialogTitle:SetPoint("TOP", 0, -16)

    local smDialogHint = smDialog:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    smDialogHint:SetPoint("TOP", 0, -36)
    smDialogHint:SetWidth(480)
    smDialogHint:SetJustifyH("CENTER")

    local smDialogScroll = CreateFrame("ScrollFrame", "$parentScroll", smDialog, "UIPanelScrollFrameTemplate")
    smDialogScroll:SetPoint("TOPLEFT", 24, -56)
    smDialogScroll:SetPoint("BOTTOMRIGHT", -44, 48)

    local SM_EDIT_WIDTH = 430
    local SM_EDIT_HEIGHT = 90

    local smDialogEdit = CreateFrame("EditBox", "$parentEdit", smDialogScroll)
    smDialogEdit:SetMultiLine(true)
    smDialogEdit:SetAutoFocus(false)
    smDialogEdit:SetFontObject("ChatFontNormal")
    smDialogEdit:SetWidth(SM_EDIT_WIDTH)
    smDialogEdit:SetHeight(SM_EDIT_HEIGHT)
    smDialogEdit:SetMaxLetters(4096)
    if smDialogEdit.SetTextInsets then
        smDialogEdit:SetTextInsets(4, 4, 4, 4)
    end
    smDialogEdit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        smDialog:Hide()
    end)
    smDialogScroll:SetScrollChild(smDialogEdit)

    local smDialogMode = "export"

    local btnSMClose = CreateFrame("Button", nil, smDialog, "UIPanelButtonTemplate")
    btnSMClose:SetSize(90, 22)
    btnSMClose:SetPoint("BOTTOMRIGHT", -16, 16)
    btnSMClose:SetText(CLOSE)
    btnSMClose:SetScript("OnClick", function() smDialog:Hide() end)

    local btnSMImport = CreateFrame("Button", nil, smDialog, "UIPanelButtonTemplate")
    btnSMImport:SetSize(110, 22)
    btnSMImport:SetPoint("BOTTOMLEFT", 16, 16)
    btnSMImport:SetText("Import & Merge")
    btnSMImport:Hide()

    -- ============================================================
    -- Apply Spell Morph Profile (Merge/Upsert)
    -- ============================================================

    local function ApplySpellMorphProfile(profile)
        if not profile or not profile.morphs then return false, "no morph data" end
        if not TransmorpherCharacterState then return false, "no character state" end
        if not TransmorpherCharacterState.SpellMorphs then
            TransmorpherCharacterState.SpellMorphs = {}
        end

        local applied = 0
        local overwritten = 0
        for sourceId, targetId in pairs(profile.morphs) do
            local src = tonumber(sourceId)
            local tgt = tonumber(targetId)
            if src and src > 0 and tgt and tgt > 0 then
                -- Check if this is an overwrite or a new entry
                local existing = TransmorpherCharacterState.SpellMorphs[src]
                if existing and tonumber(existing) ~= tgt then
                    overwritten = overwritten + 1
                end

                -- Merge/Upsert: set the spell morph in state
                ns.SetSpellMorph(src, tgt)

                -- Send the command to the DLL
                ns.SendMorphCommand("SPELL_MORPH:" .. src .. ":" .. tgt)

                applied = applied + 1
            end
        end

        return true, applied, overwritten
    end

    -- Expose for slash commands
    ns.ApplySpellMorphProfile = ApplySpellMorphProfile

    -- ============================================================
    -- Export Dialog
    -- ============================================================

    local function ShowSpellMorphExportDialog()
        local encoded, err = ns.SerializeSpellMorphProfile("Spell Morphs")
        if not encoded then
            SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: |cffff0000Export failed:|r " .. (err or "unknown error"))
            return
        end

        smDialogMode = "export"
        smDialogEdit:SetHeight(SM_EDIT_HEIGHT)
        smDialogEdit:SetWidth(SM_EDIT_WIDTH)
        smDialogEdit:SetText(encoded)
        smDialogTitle:SetText("Export Spell Morphs")

        -- Count morphs for hint
        local count = 0
        if TransmorpherCharacterState and TransmorpherCharacterState.SpellMorphs then
            for _ in pairs(TransmorpherCharacterState.SpellMorphs) do
                count = count + 1
            end
        end
        smDialogHint:SetText(count .. " spell morph" .. (count == 1 and "" or "s") .. " exported. Select all and copy (Ctrl+A, Ctrl+C).")

        btnSMImport:Hide()
        smDialog:Show()
        smDialogEdit:SetFocus()
        smDialogEdit:HighlightText()

        -- Also print to chat
        SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r Spell morph export string (also shown in dialog — Ctrl+A, Ctrl+C):")
        local chunkSize = 220
        for i = 1, #encoded, chunkSize do
            SELECTED_CHAT_FRAME:AddMessage(encoded:sub(i, i + chunkSize - 1))
        end
    end

    -- ============================================================
    -- Import Dialog
    -- ============================================================

    local function ShowSpellMorphImportDialog()
        smDialogMode = "import"
        smDialogEdit:SetHeight(SM_EDIT_HEIGHT)
        smDialogEdit:SetWidth(SM_EDIT_WIDTH)
        smDialogEdit:SetText("")
        smDialogTitle:SetText("Import Spell Morphs")
        smDialogHint:SetText("Paste an SM1 spell morph string, then click Import & Merge.")
        btnSMImport:Show()
        smDialog:Show()
        smDialogEdit:SetFocus()
    end

    local function ImportSpellMorphFromString(encoded)
        encoded = encoded and encoded:match("^%s*(.-)%s*$") or ""
        local profile, err = ns.DeserializeSpellMorphProfile(encoded)
        if not profile then
            SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: |cffff0000Import failed:|r " .. (err or "unknown error"))
            return false
        end

        local ok, applied, overwritten = ApplySpellMorphProfile(profile)
        if not ok then
            SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: |cffff0000Import failed:|r " .. tostring(applied))
            return false
        end

        -- Refresh the UI
        RefreshMorphView()
        UpdateMorphCount()
        PlaySound("gsTitleOptionOK")

        local msg = "|cffF5C842<Transmorpher>|r: Imported profile '" .. (profile.name or "Spell Morphs") .. "' — "
            .. "|cff00ff00" .. applied .. "|r morph" .. (applied == 1 and "" or "s") .. " applied"
        if overwritten > 0 then
            msg = msg .. " (|cffffff00" .. overwritten .. " overwritten|r)"
        end
        SELECTED_CHAT_FRAME:AddMessage(msg .. ".")

        return true
    end

    -- Expose for slash commands
    ns.ImportSpellMorphFromString = ImportSpellMorphFromString

    btnSMImport:SetScript("OnClick", function()
        ImportSpellMorphFromString(smDialogEdit:GetText())
        smDialog:Hide()
    end)

    -- ============================================================
    -- Clear All Confirmation
    -- ============================================================

    StaticPopupDialogs["TRANSMORPHER_CLEAR_ALL_SPELL_MORPHS"] = {
        text = "Are you sure you want to clear ALL spell morphs?\n\nThis will reset every spell back to its original appearance.",
        button1 = "Clear All",
        button2 = "Cancel",
        OnAccept = function()
            if TransmorpherCharacterState and TransmorpherCharacterState.SpellMorphs then
                -- Send reset for each active morph
                for sourceId in pairs(TransmorpherCharacterState.SpellMorphs) do
                    local src = tonumber(sourceId)
                    if src and src > 0 then
                        ns.SendMorphCommand("SPELL_RESET:" .. src)
                    end
                end
                wipe(TransmorpherCharacterState.SpellMorphs)
            end

            RefreshMorphView()
            UpdateMorphCount()
            PlaySound("gsTitleOptionOK")
            SELECTED_CHAT_FRAME:AddMessage("|cffF5C842<Transmorpher>|r: All spell morphs cleared.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
    }

    -- ============================================================
    -- Button Handlers
    -- ============================================================

    btnSpellExport:SetScript("OnClick", function()
        ShowSpellMorphExportDialog()
    end)

    btnSpellImport:SetScript("OnClick", function()
        ShowSpellMorphImportDialog()
    end)

    btnClearAll:SetScript("OnClick", function()
        StaticPopup_Show("TRANSMORPHER_CLEAR_ALL_SPELL_MORPHS")
    end)

    -- ============================================================
    -- Expose for Slash Commands
    -- ============================================================

    ns.ShowSpellMorphExportDialog = ShowSpellMorphExportDialog
    ns.ShowSpellMorphImportDialog = ShowSpellMorphImportDialog

    -- ============================================================
    -- Sub-Tab Logic
    -- ============================================================

    local function ShowSpellSubTab(id)
        local showMorphs = id == 1

        if showMorphs then morphSubTab:Show() else morphSubTab:Hide() end

        btnMorphs:SetActive(showMorphs)

        if showMorphs then
            RefreshMorphView()
            UpdateMorphCount()
        end

        PlaySound("gsTitleOptionOK")
    end

    btnMorphs:SetScript("OnClick", function() ShowSpellSubTab(1) end)

    parent.ShowSpellSubTab = ShowSpellSubTab

    parent:SetScript("OnShow", function()
        if not parent.tabInitialized then
            ShowSpellSubTab(1)
            parent.tabInitialized = true
        end
        UpdateMorphCount()
    end)

    RefreshMorphView()
    UpdateMorphCount()
    if #spellPool == 0 then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccff[Transmorpher]|r Scanning spellbook... (Please wait if just logged in)")
    end
end
