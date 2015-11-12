-- load EMA periods
dofile('EMAsetup.lua')
-- load regime settings
dofile('AQregimes.lua')
useRegime = 1

sendEvery = 3 -- number of data points to wait before logging online
sendCounter = 0

sendToTS = require('sendToTS')
sendToTS.setKey('YAUZS3HL8506DS6P')

uart.on("data", function(data)
    _, _, particleSize, concentration = string.find(data, "(.+): (.+)")
    concentration = tonumber(concentration)
    print(particleSize)
    print(concentration)
    if concentration ~= nil then
        calcMVA()
        judgeRegime()
        sendCounter = sendCounter + 1
        if sendCounter == sendEvery then
            valSet = sendToTS.setValue(1,avg1um)
            sendToTS.sendData(false) -- don't show debug msgs
            sendCounter = 0
        end
    end    
end)

function calcMVA()
    -- calculate moving average
    if avg1um==nil then
        tmr.stop(1)
        avg1um = concentration
        firstMeas = false
    else
        for i, cutoff in ipairs(cutoffs) do
            if avg1um >= cutoff then
                alpha = 2/(periods[i] + 1);
            end
        end
        avg1um = alpha * concentration + (1-alpha) * avg1um
    end
end

function judgeRegime()
    -- determine air quality regime
    --judgement = regimes[useRegime][2][1][2]]; -- worst regime if nothing else matches
    for i, regime in ipairs(regimes[useRegime][1]) do
        if avg1um >= regime then
            judgement = regimes[useRegime][2][i];
        end
    end
    print('P1 concentration: '..tostring(concentration))
    print('average: '..tostring(avg1um))
    print('regime: '..judgement)
    lcd.clear()
    lcd.put(lcd.locate(0, 0), judgement)
    lcd.put(lcd.locate(1, 0), tostring(math.floor(avg1um + 0.5)))
end
