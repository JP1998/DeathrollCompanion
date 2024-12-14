

if GetLocale() ~= "enGB" then
    return;
end

local _, app = ...;
local L = app.L;

for key, value in pairs({
})
do L[key] = value; end
