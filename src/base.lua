
local name, app = ...;
function app:GetName()
    return name;
end
_G[name] = app;

-- Create an Event Processor.
local events = {};
local updates = {};
local _ = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate");
_:SetScript("OnEvent", function(self, e, ...)
    local ev_listeners = rawget(events, e);

    if ev_listeners ~= nil and type(ev_listeners) == "table" then
        for _,listener in pairs(ev_listeners) do
            listener(...);
        end
    else
        print(...);
    end
end);
_:SetScript("OnUpdate", function(self, elapsed)
    for _,v in pairs(updates) do
        v(elapsed);
    end
end);
_:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", 0, 0);
_:SetSize(1, 1);
_:Show();
app._ = _;
app.RegisterEvent = function(self, event, key, handler)
    if events[event] == nil then
        events[event] = {};
    end

    if events[event][key] ~= nil then
        error("the event '" .. event .. "' with key '" .. key .. "' was already registered.", 2);
    end

    events[event][key] = handler;
    if #events[event] ~= 1 then
        _:RegisterEvent(event);
    end
end
app.UnregisterEvent = function(self, event, key)
    if events[event] == nil or events[event][key] == nil then
        error("the event '" .. event .. "' with key '" .. key .. "' was not registered.", 2);
    end

    events[event][key] = nil;
    if #events[event] == 0 then
        _:UnregisterEvent(event);
    end
end
app.RegisterUpdate = function(self, key, handler)
    updates[key] = handler;
end
app.UnregisterUpdate = function(self, key)
    updates[key] = nil;
end
