

if GetLocale() ~= "deDE" then
    return;
end

local _, app = ...;
local L = app.L;

for key, value in pairs({
    -- ["TITLE"] = "|cFFD13653Deathroll Companion|r";
})
do L[key] = value; end
