require 'dxruby'

class Tetris
    def initialize ()
        wall_x = 0
        wall_y = 0
        wallCount = 0
        sprites1 = []
        sprites2 = []
        sprites3 = []
        sprites4 = []

        image_wall = Image.load_tiles("./image/59774112_220x220.jpg", 10, 10)

        loop do
            sprites1[wallCount] = Sprite.new(wall_x, 0, image_wall[0])
            if 220 < wall_x
                break
            end
            wall_x = wall_x + 20
            wallCount = wallCount + 1
        end
        loop do
            sprites2[wallCount] = Sprite.new(wall_x, 420, image_wall[0])
            if wall_x < 0
                break
            end
            wall_x = wall_x - 20
            wallCount = wallCount + 1
        end
        loop do
            sprites3[wallCount] = Sprite.new(0, wall_y, image_wall[0])
            if 420 < wall_y
                break
            end
            wall_y = wall_y + 20
            wallCount = wallCount + 1
        end
        loop do
            sprites4[wallCount] = Sprite.new(220, wall_y, image_wall[0])
            if wall_y < 0
                break
            end
            wall_y = wall_y - 20
            wallCount = wallCount + 1
        end

        

        Window.width = 240
        Window.height = 440
        @blocks = self.createBlocks()
        print(@blocks)
        @block_x = 120
        @block_y = 0
        
        @start = Time.now
        @fallTime = 1.0

        #TODO : 秒数経ったら速度を変える
        @speedChangeTime = 60

        img_tohu = Image.new(100,100,blocks.[0].color)
        tohu = Sprite.new(100,100,img_tohu)
        @arraydraw = [tohu,sprites1,sprites2,sprites3,sprites4]

    end

    def createBlocks()
        blocks = [
            {
                shape: [[[-1, 0], [0, 0], [1, 0], [2, 0]],
                        [[0, -1], [0, 0], [0, 1], [0, 2]],
                        [[-1, 0], [0, 0], [1, 0], [2, 0]],
                        [[0, -1], [0, 0], [0, 1], [0, 2]]],
                color: "rgb(0, 255, 255)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(0, 128, 128)"
            },
            {
                shape: [[[0, 0], [1, 0], [0, 1], [1, 1]],
                        [[0, 0], [1, 0], [0, 1], [1, 1]],
                        [[0, 0], [1, 0], [0, 1], [1, 1]],
                        [[0, 0], [1, 0], [0, 1], [1, 1]]],
                color: "rgb(255, 255, 0)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(128, 128, 0)"
            },
            {
                shape: [[[0, 0], [1, 0], [-1, 1], [0, 1]],
                        [[-1, -1], [-1, 0], [0, 0], [0, 1]],
                        [[0, 0], [1, 0], [-1, 1], [0, 1]],
                        [[-1, -1], [-1, 0], [0, 0], [0, 1]]],
                color: "rgb(0, 255, 0)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(0, 128, 0)"
            },
            {
                shape: [[[-1, 0], [0, 0], [0, 1], [1, 1]],
                        [[0, -1], [-1, 0], [0, 0], [-1, 1]],
                        [[-1, 0], [0, 0], [0, 1], [1, 1]],
                        [[0, -1], [-1, 0], [0, 0], [-1, 1]]],
                color: "rgb(255, 0, 0)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(128, 0, 0)"
            },
            {
                shape: [[[-1, -1], [-1, 0], [0, 0], [1, 0]],
                        [[0, -1], [1, -1], [0, 0], [0, 1]],
                        [[-1, 0], [0, 0], [1, 0], [1, 1]],
                        [[0, -1], [0, 0], [-1, 1], [0, 1]]],
                color: "rgb(0, 0, 255)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(0, 0, 128)"
            },
            {
                shape: [[[1, -1], [-1, 0], [0, 0], [1, 0]],
                        [[0, -1], [0, 0], [0, 1], [1, 1]],
                        [[-1, 0], [0, 0], [1, 0], [-1, 1]],
                        [[-1, -1], [0, -1], [0, 0], [0, 1]]],
                color: "rgb(255, 165, 0)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(128, 82, 0)"
            },
            {
                shape: [[[0, -1], [-1, 0], [0, 0], [1, 0]],
                        [[0, -1], [0, 0], [1, 0], [0, 1]],
                        [[-1, 0], [0, 0], [1, 0], [0, 1]],
                        [[0, -1], [-1, 0], [0, 0], [0, 1]]],
                color: "rgb(255, 0, 255)",
                highlight: "rgb(255, 255, 255)",
                shadow: "rgb(128, 0, 128)"
            } 
        ]
        return blocks
    end


    def drawBlock(x, y, type, angle, canvas) 
        block = blocks[type]
        @arraydraw.append(block)
        for i in block.shape[angle] do
            this.drawCell(
                    x + (block.shape[angle][i][0] * cellSize),
                    y + (block.shape[angle][i][1] * cellSize),
                    cellSize,
                    type)
        end
    end


    def drewCell(type)
        block = blocks[type]
        

    end


    def mainLoop
        Window.loop do
            if Input.keyDown?(K_RIGHT)
                block.x += 2
                if block === box || block === sprites4
                    block.x -= 2
                end
            end
            if Input.keyDown?(K_LEFT)
                block.x -= 2
                if block === box || block === sprites3
                    block.x += 2
                end
            end
            if Input.keyDown?(K_DOWN)
                block.y += 2
                if block === box || block === sprites2
                    block.y -= 2
                end 
            end
            if Input.keyDown?(K_RETURN)
                break
            end
            
            startTime = @start.to_f
            storageTime = startTime
            newTime = Time.now
            if startTime + @speedChangeTime == newTime
                @fallTime -= 0.1
                @speedChangeTime += 60
            end
            if storageTime + @fallTime == newTime
                block.y -= 20
                storageTime += startTime + @fallTime
            end
        
            Sprite.draw(@arraydraw)
        end
    end

end

tetris = Tetris.new
tetris.mainLoop
