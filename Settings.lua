
local app = select(2, ...);
local L = app.L;

local initialized = false;

app.Settings = {};
local settings = app.Settings;

local settingsFrame = CreateFrame("FRAME", app:GetName() .. "-Settings", UIParent);
settings.Frame = settingsFrame;

settingsFrame.name = app:GetName();
-- settingsFrame.MostRecentTab = nil;
settingsFrame.Tabs = {};
settingsFrame.ModifierKeys = { "None", "Shift", "Ctrl", "Alt" };

local mainCategory = Settings.RegisterCanvasLayoutCategory(settingsFrame, settingsFrame.name, settingsFrame.name);
mainCategory.ID = settingsFrame.name;
Settings.RegisterAddOnCategory(mainCategory);


settings.Open = function(self)
    -- Open the Options menu.
    if not SettingsPanel:IsVisible() then
        SettingsPanel:Show();
    end

    Settings.OpenToCategory(app:GetName());
end

local SettingsBase = {
    ["Debug"] = {
        ["Enabled"] = false
    },
    ["Deathroll"] = {
        ["Delay"] = 0.0,
        ["Threshold"] = 200
    }
};

settings.Initialize = function(self)
    PanelTemplates_SetNumTabs(self.Frame, #self.Frame.Tabs);

    if not DeathrollCompanionSettings then
        DeathrollCompanionSettings = CopyTable(SettingsBase);
    end

    self.Data = DeathrollCompanionSettings;

    self.Frame:Refresh();

    initialized = true;
end
settings.Get = function(self, category, option)
    if category == nil then
        return settings.Data;
    elseif option == nil then
        return settings.Data and settings.Data[category];
    else
        return settings.Data and settings.Data[category][option];
    end
end
settings.Set = function(self, category, option, value)
    settings.Data[category][option] = value;

    self.Frame:Refresh();
end
settingsFrame.Refresh = function(self)
    for i,tab in ipairs(self.Tabs) do
        if tab.OnRefresh then
            tab:OnRefresh();
        end

        for j,o in ipairs(tab.objects) do
            if o.OnRefresh then
                o:OnRefresh();
            end
        end
    end
end
settingsFrame.CreateCheckBox = function(self, parent, text, OnRefresh, OnClick)
    local cb = CreateFrame("CheckButton", self:GetName() .. "-" .. text, parent, "InterfaceOptionsCheckButtonTemplate");

    -- self.MostRecentTab:AddObject(cb);

    cb:SetScript("OnClick", OnClick);
    cb.OnRefresh = OnRefresh;
    cb.Text:SetText(text);
    cb:SetHitRectInsets(0,0 - cb.Text:GetWidth(),0,0);
    cb:Show();

    return cb;
end
settingsFrame.CreateTab = function(self, text, scroll)
    local id = #self.Tabs + 1;

    local settingsPanel;
    local subcategoryPanel;

    if scroll then
        local scrollFrame = CreateFrame("ScrollFrame", self:GetName() .. "-Tab" .. id .. "-Scroll", self, "ScrollFrameTemplate");
        settingsPanel = CreateFrame("Frame", self:GetName() .. "-Tab" .. id);

        scrollFrame:SetScrollChild(settingsPanel);
        settingsPanel:SetID(id);
        settingsPanel:SetWidth(1);    -- This is automatically defined, so long as the attribute exists at all
        settingsPanel:SetHeight(1);   -- This is automatically defined, so long as the attribute exists at all

        -- Move the scrollbar to its proper position (only needed for subcategories)
        scrollFrame.ScrollBar:ClearPoint("RIGHT");
        scrollFrame.ScrollBar:SetPoint("RIGHT", -36, 0);

        scrollFrame.Content = settingsPanel;

        -- Create the nested subcategory
        subcategoryPanel = scrollFrame;
    else
        settingsPanel = CreateFrame("Frame", self:GetName() .. "-Tab" .. id);

        settingsPanel:SetID(id);

        subcategoryPanel = settingsPanel;
    end

    subcategoryPanel.name = text;
    subcategoryPanel.parent = app:GetName();

    local subcategory = Settings.RegisterCanvasLayoutSubcategory(mainCategory, subcategoryPanel, text)

    table.insert(self.Tabs, settingsPanel);
    --self.MostRecentTab = settingsPanel;
--[[
    settingsPanel.AddObject = function(self, obj)
        if not self.objects then
            self.objects = {};
        end

        table.insert(self.objects, obj);
    end
]]--
    return subcategoryPanel;
end


local f = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
f:SetPoint("TOPLEFT", settingsFrame, "TOPLEFT", 12, -12);
f:SetJustifyH("LEFT");
f:SetText(L["TITLE"]);
f:SetScale(1.5);
f:Show();
settingsFrame.title = f;

f = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
f:SetPoint("TOPRIGHT", settingsFrame, "TOPRIGHT", -12, -12);
f:SetJustifyH("RIGHT");
f:SetText("v" .. C_AddOns.GetAddOnMetadata(app:GetName(), "Version"));
f:Show();
settingsFrame.version = f;

local DebugCheckBox = settingsFrame:CreateCheckBox(settingsFrame, "Debug",
    function(self) -- OnRefresh
        self:SetChecked(settings:Get("Debug", "Enabled"));
    end,
    function(self) -- OnClick
        settings:Set("Debug", "Enabled", self:GetChecked());
    end);
DebugCheckBox:SetPoint("TOPLEFT", settingsFrame.title, "BOTTOMLEFT", 0, -20);
settings.DebugCheckBox = DebugCheckBox;
-- DebugCheckBox:Show();


