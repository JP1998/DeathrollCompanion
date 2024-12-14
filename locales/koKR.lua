

if GetLocale() ~= "koKR" then
    return;
end

local _, app = ...;
local L = app.L;

for key, value in pairs({
    ["TITLE"] = "|cFFD13653전투 애완 동물 유틸리티|r";
})
do L[key] = value; end
