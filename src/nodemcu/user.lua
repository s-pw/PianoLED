gpio.mode(1,gpio.OUTPUT)
gpio.write(1,gpio.HIGH)
gpio.mode(2,gpio.OUTPUT)
gpio.write(2,gpio.HIGH)

ws2812.init(ws2812.MODE_SINGLE)
strip_buffer = ws2812.newBuffer(176, 3)
midi.init(strip_buffer)
midi.stop()

ws2812_effects.init(strip_buffer)
ws2812_effects.set_speed(250)
ws2812_effects.set_brightness(100)
ws2812_effects.set_mode("rainbow_cycle")
ws2812_effects.start()

gpio.write(1,gpio.HIGH)
gpio.write(2,gpio.LOW)


midi.setChannelMode(1,2)
midi.setChannelMode(2,6)
midi.setChannelMode(3,5)

midi.onInactivity(function()
    api:log('inactive')
    midi.stop()
    ws2812_effects.set_speed(250)
    ws2812_effects.set_brightness(100)
    ws2812_effects.set_mode("rainbow_cycle")
    ws2812_effects.start()
 end)

midi.onActivity(function()
    ws2812_effects.stop()
    midi.start()
 end)
    
api:on("receive", 
    function(method, path, data)      
        if method == 'POST' and path == '/mode' then
            post = sjson.decode(data)
            midi.setChannelMode(post.channel, loadstring("return midi."..post.mode)())
            return 200, 'application/json', data
        end
        if method == 'POST' and path == '/channel' then
            if data == '0' then
                gpio.write(1,gpio.HIGH)
                gpio.write(2,gpio.LOW)
            else 
                gpio.write(1,gpio.LOW)
                gpio.write(2,gpio.HIGH)
            end
            
            return 200
        end
        if method == 'POST' and path == '/suspend' then
            midi.stop()
            ws2812_effects.set_speed(250)
            ws2812_effects.set_brightness(100)
            ws2812_effects.set_mode(data)
            ws2812_effects.set_color(0,255,0)
            ws2812_effects.start()
            
            return 200
        end
    end
)