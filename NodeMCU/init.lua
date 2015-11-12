i2c.setup(0, 3, 4, i2c.SLOW) -- SDA, SCL 3, 4
lcd = dofile("lcd1602.lc")()
lcd.clear()
tmr.alarm(2, 2000, 0, function()
    lcd.put(lcd.locate(0, 0), "Starting up...")
    progressCount = 1
    tmr.alarm(1, 80, 1, function()
        if progressCount > 16 then
            progressCount = 1
            lcd.put(lcd.locate(1, 0), string.rep(' ', 16))
        end
        lcd.put(lcd.locate(1, 0), string.rep('.', progressCount))
        progressCount = progressCount + 1
    end)
    dofile('recieveData.lc')
end)
