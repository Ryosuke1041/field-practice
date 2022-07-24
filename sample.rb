require 'dxruby'

x = 0
y = 0
image = Image.load('data.png')

Window.loop do
    x += Input.x
    y += Input.y

    Window.draw(x,y, image)

    break if Input.keyPush?(K_ESCAPE)
end