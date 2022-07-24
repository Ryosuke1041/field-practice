@board.each_cell {|x, y, value| @rectangles[y][x].state to_state(value) }

require 'tk'
require 'matrix'
 
class RetrixForm
  def initialize(parent)
    @cellSize = 20
    @board = Board.new
 
    @canvas = TkCanvas.new(parent) do
      width 400
      height 500
      background 'white'
      pack
    end # @canvas
 
    Tk.root.bind('Key-Left',  proc {|e| onArrowKeyDown(-1, 0)})
    Tk.root.bind('Key-Right', proc {|e| onArrowKeyDown(1, 0)})
    Tk.root.bind('Key-Up',    proc {|e| onArrowKeyDown(0, 1)})
    Tk.root.bind('Key-Down',  proc {|e| onArrowKeyDown(0, -1)})
    Tk.root.bind('space',     proc {|e| on_spacebar_down()})
    init_rectangles
 
    @menu_spec = [
      [['File', 0],
        {:label=>'Start', :command=>proc{onStart}, :underline=>0},
        '---',
        ['Quit', proc{exit}, 0]
      ]]
    @menubar = parent.add_menubar(@menu_spec, false, nil)
 
    @timer = TkTimer.new(1000) do |timer|
      onTimer
    end.start
    refresh_canvas
  end # initialize
 
  def init_rectangles
    @rectangles = []
    for y in 0...Board::HEIGHT
      row = []
      for x in 0...Board::WIDTH
        ccoord = to_ccoord(x, y)
        rectangle = TkcRectangle.new(@canvas, ccoord[0], ccoord[1],
          ccoord[0] + @cellSize - 2, ccoord[1] + @cellSize - 2,
          'fill' => 'darkgray')
        rectangle.state "hidden"
 
        row << rectangle
      end # for x
      @rectangles << row
    end # for y
 
    @minis = []
    for y in 0...Board::MINI_HEIGHT
      row = []
      for x in 0...Board::MINI_WIDTH
        mcoord = to_mcoord(x, y)
        rectangle = TkcRectangle.new(@canvas, mcoord[0], mcoord[1],
          mcoord[0] + @cellSize - 2, mcoord[1] + @cellSize - 2,
          'fill' => 'darkgray')
        rectangle.state "hidden"
 
        row << rectangle
      end # for x
      @minis << row
    end
  end
 
  def to_ccoord(a_x, a_y)
    [a_x * @cellSize + 50,
      (Board::HEIGHT - a_y - 1) * @cellSize + 2]
  end
 
  def to_mcoord(a_x, a_y)
    [a_x * @cellSize + 100 + Board::WIDTH * @cellSize,
      (Board::MINI_HEIGHT - a_y - 1) * @cellSize + 2]
  end
 
  def onTimer
    return if not @board.active
 
    @board.tick
    refresh_canvas
  end # onTimer
 
  def refresh_canvas
    @board.each_cell do|x, y, value|
      if value
        @rectangles[y][x].state "normal"
      else
        @rectangles[y][x].state "hidden"
      end # if
    end # do
 
    @board.each_mini do|x, y, value|
      if value
        @minis[y][x].state "normal"
      else
        @minis[y][x].state "hidden"
      end # if
    end # do
  end # refresh_canvas
 
  def onStart
    @board.active = true
  end
 
  def onArrowKeyDown(a_deltaX, a_deltaY)
    return if not @board.active
 
    if a_deltaY == 1
      @board.drop
      @board.tick
      refresh_canvas
      return
    end
 
    @board.move_by(a_deltaX, a_deltaY)
    refresh_canvas
  end
 
  def on_spacebar_down
    return if not @board.active
 
    @board.rotate(true)
    refresh_canvas
  end
end
 
class Board
  attr_reader :active
 
  WIDTH = 9
  HEIGHT = 23
  MINI_WIDTH = 5
  MINI_HEIGHT = 5
 
  def Board.in_boundary?(a_x, a_y)
    if (a_x < 0) or (a_x >= WIDTH) or
      (a_y < 0) or (a_y >= HEIGHT)
      return false
    end # if
    true
  end
 
  def initialize(a_block = Block.new)
    @active = false
    @cells = []
    HEIGHT.times { @cells << empty_row }
 
    @mini_cells = []
    MINI_HEIGHT.times { @mini_cells << empty_row(MINI_WIDTH) }
 
    introduce_next_block a_block
    introduce_block
  end # initialize
 
  def empty_row(a_width = WIDTH)
    retval = []
    a_width.times { retval << false }
    return retval
  end
 
  def current_block
    @block
  end
 
  def [](a_y, a_x)
    @cells[a_y][a_x]
  end # []
 
  def []=(a_y, a_x, a_value)
    if not Board.in_boundary?(a_x, a_y)
      raise '(' + a_x.to_s + ', ' + a_y.to_s + ') is out of range'
    end # if
 
    @cells[a_y][a_x] = a_value
  end # []
 
  def set_mini(a_x, a_y, a_value)
    @mini_cells[a_y][a_x] = a_value
  end
 
  def move_by(a_deltaX, a_deltaY)
    transform { @block.move_by(a_deltaX, a_deltaY) }
  end # move_by
 
  def drop
    while move_by(0, -1) do
    end
  end # drop
 
  def rotate(a_clockWise)
    transform { @block.rotate(true) }
  end # rotate
 
  def transform(&a_block)
    retval = true
    map_cells(@block, false)
    temp = @block.dup
    a_block.call
 
    # if moving causes problem, roll it back
    if (not block_in_boundary?(@block)) or (collide? @block)
      # puts current_block.to_s + ' is bad'
      @block = temp
      retval = false
    end # if
 
    map_cells(@block, true)
    # puts current_block
    return retval
  end # transform
 
  def collide? a_block
    a_block.each {|x, y| return true if self[y, x] }
    return false
  end # collide?
 
  def map_cells(a_block, a_value)
    a_block.each {|x, y| self[y, x] = a_value }
  end # map cells
 
  def map_minis(a_block, a_value)
    a_block.each {|x, y| set_mini(x, y, a_value)}
  end
 
  def active=(a_value)
    @active = a_value
  end # active=
 
  def tick
    return if not @active
 
    if move_by(0, -1)
      check_rows
      return
    end # if
 
    introduce_block
  end # tick
 
  def introduce_block
    @block = @next_block
    @block.move_to(WIDTH / 2, HEIGHT - 3)
    introduce_next_block
 
    if (not block_in_boundary?(@block)) or (collide? @block)
      @active = false
      return false
    end # if
 
    map_cells(@block, true)
    return true
  end
 
  def block_in_boundary? (a_block)
    a_block.each {|x, y| return false if not Board.in_boundary?(x, y) }
    return true
  end
 
  def introduce_next_block(a_block = Block.new)
    @next_block = a_block
    clear_minis
    map_minis(@next_block, true)
  end
 
  def clear_minis
    each_mini {|x, y, value| set_mini(x, y, false)}
  end
 
  def check_rows
    (HEIGHT - 1).downto(0) do |i|
      if row_filled? i
        # puts to_s
        remove_row i
      end # if
    end # do
  end
 
  def row_filled? a_row
    retval = true
    @cells[a_row].each {|value| retval = (retval && value) }
    retval
  end
 
  def remove_row(a_row)
    map_cells(@block, false)
    @cells.delete_at(a_row)
    @cells << empty_row
    map_cells(@block, true)
  end
 
  def to_s
    retval = ''
    each_row do |row|
      rowString = ''
      row.each do |cell|
        if cell
          rowString << 'X'
        else
          rowString << '_'
        end # if-else
      end
      retval = rowString + "\n" + retval
    end
    retval
  end
 
  def each_row(&a_block)
    @cells.each {|cell| a_block.call(cell) }
  end
 
  def each_cell(&a_block)
    for y in 0...HEIGHT
      for x in 0...WIDTH
        a_block.call(x, y, self[y, x])
      end # for x
    end # for y
  end # each_cell
 
  def each_mini(&a_block)
    for y in 0...MINI_HEIGHT
      for x in 0...MINI_WIDTH
        a_block.call(x, y, @mini_cells[y][x])
      end # for x
    end # for y
  end
end
 
class Block
  attr_reader :x, :y
 
  def initialize(a_type = rand(6))
    @x = 2.0
    @y = 2.0
    @type = a_type
    @cells = type_to_cells @type
    @icells = Matrix[[0, 0], [0, 0], [0, 0], [0, 0]]
 
    update
  end
 
  def type_to_cells(a_type)
    case a_type
      when 0 # T
        Matrix[[0.0, 0.0], [-1.0, 0.0], [1.0, 0.0], [0.0, 1.0]]
      when 1 # X
        Matrix[[-0.5, 0.5], [0.5, 0.5], [-0.5, -0.5], [0.5, -0.5]]
      when 2 # L
        Matrix[[0.0, 0.0], [0.0, 1.0], [0.0, -1.0], [1.0, -1.0]]
      when 3 # J
        Matrix[[0.0, 0.0], [0.0, 1.0], [0.0, -1.0], [-1.0, -1.0]]
      when 4 # B
        Matrix[[0.0, -1.5], [0.0, -0.5], [0.0, 0.5], [0.0, 1.5]]
      when 5 # S
        Matrix[[-0.5, 0.0], [0.5, 0.0], [-0.5, 1.0], [0.5, -1.0]]
      when 6 # Z
        Matrix[[-0.5, 0.0], [0.5, 0.0], [-0.5, -1.0], [0.5, 1.0]]
    end # case
  end
 
  def [](a_y, a_x)
    @icells[a_y, a_x]
  end # []
 
  def each(&a_block)
    for i in 0..3 do
      a_block.call(self[i, 0], self[i, 1])
    end # for i
  end
 
  def to_s
    @icells.to_s + ' ' + x.to_s + ', ' + y.to_s
  end
 
  def move_by(a_deltaX, a_deltaY)
    move_to(@x + a_deltaX, @y + a_deltaY)
  end # move_by
 
  def move_to(a_x, a_y)
    @x = a_x.to_f
    @y = a_y.to_f
    update
  end
 
  def rotate(a_clockWise)
    rows = []
 
    for i in 0..3 do
      row = (rotation_matrix22(-Math::PI / 2.0) * @cells.row(i)).map do |value|
        (value * 10.0).round / 10.0
      end # map
      rows << row
    end # for
    @cells = Matrix.rows(rows)
 
    update
  end # rotate
 
  def update
    @icells = (@cells + position_matrix).round
  end # update
 
  def position_matrix
    Matrix[[@x, @y], [@x, @y], [@x, @y], [@x, @y]]
  end # position_matrix
 
  def rotation_matrix22(a_r)
    Matrix[ [Math.cos(a_r), -Math.sin(a_r)],
            [Math.sin(a_r), Math.cos(a_r)]]
  end # rotation_matrix22
end
 
class Matrix
  def round
    self.map do |x|
      if x >= 0
        x.round
      else
        -((x + 0.5).abs.round)
      end # if
    end
  end # to_i
end
 
root = TkRoot.new { title "Retrix" }
RetrixForm.new(root)
Tk.mainloop