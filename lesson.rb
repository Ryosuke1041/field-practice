# coding: utf-8
require 'dxruby'

x = 50
y = 50
block_x = 0
block_y = 0
count = 0
sprites1 = []
sprites2 = []
sprites3 = []
sprites4 = []

item_x = 70
item_y = 0

score = 0
score.to_s

gameover = 0



image_block = Image.load_tiles("./image/block.png",1,1)
image = Image.load_tiles("./character.png", 4, 4)
image_box = Image.load_tiles("./image/colorbox.png", 6, 1)
char_obj = Sprite.new(x, y, image[0])
box = Sprite.new(200, 200, image[1])
item = Sprite.new(item_x, item_y, image_box[0])
font = Font.new(20)
font1 = Font.new(30)
font2 = Font.new(30)

Window.width = 360
Window.height = 480
loop do
    sprites1[count] = Sprite.new(block_x, 0, image_block[0])
    if 480 < block_x
        break
    end
    block_x = block_x + 30
    count = count + 1
end
loop do
    sprites2[count] = Sprite.new(block_x, 450, image_block[0])
    if block_x < 0
        break
    end
    block_x = block_x -30
    count = count + 1
end
loop do
    sprites3[count] = Sprite.new(0, block_y, image_block[0])
    if 480 < block_y
        break
    end
    block_y = block_y + 30
    count = count + 1
end
loop do
    sprites4[count] = Sprite.new(330, block_y, image_block[0])
    if block_y < 0
        break
    end
    block_y = block_y - 30
    count = count + 1
end
arraydraw = [char_obj,box,sprites1,sprites2,sprites3,sprites4]#,item]

Window.loop do
    if Input.keyDown?(K_RIGHT)
        char_obj.x += 2
        if char_obj === box || char_obj === sprites4
            char_obj.x -= 2
        end
    end
    if Input.keyDown?(K_LEFT)
        char_obj.x -= 2
        if char_obj === box || char_obj === sprites3
            char_obj.x += 2
        end
    end
    if Input.keyDown?(K_DOWN)
        char_obj.y += 2
        if char_obj === box || char_obj === sprites2
            char_obj.y -= 2
        end
    end
    if Input.keyDown?(K_UP)
        char_obj.y -= 2
        if char_obj === box || char_obj === sprites1
            char_obj.y += 2
        end
    end

    if char_obj.y <= 420
        char_obj.y += 1
    end

    if item.nil? == false
        item.y += 1
    end
    if item.nil? == false
        Sprite.draw(item)
    else
        item_x = rand(340)
        item = Sprite.new(item_x, item_y, image_box[0])
    end
    if char_obj === item
        item = nil
        score += 1
    end

    Window.draw_font(200, 400, "スコアは#{score}点", font)

    if item === sprites2
        Window.draw_font(70, 70, "GAMEOVER", font1)
        Window.draw_font(100, 100, "スコアは#{score}点", font2)
        sleep 1
        if Input.keyDown?(K_SPACE)
          break
        end
    end


    Sprite.draw(arraydraw)

end