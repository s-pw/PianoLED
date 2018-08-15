api = devapi.createServer()

wifi.sta.sethostname("piano-led")

function errh(err)
    api:log(debug.traceback(err))
end

function user()
    dofile("user.nodemcu")
end

function userTrace()
    xpcall(user, errh)
end

local rawcode, reason = node.bootreason()
if reason >= 1 and reason <=3 then
    api:log("SAFE MODE")
    tmr.create():alarm(60000, tmr.ALARM_SINGLE, function() userTrace() end)
else
    onInit = userTrace
end

startup = true
sntp.sync(nil,
    function(sec, usec, server, info)
        if startup and onInit ~= nil then
            startup = false
            onInit()
        end
    end, nil, 1)
