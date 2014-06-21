# This is a maze solving algorithm. It traverses a text based file made up of hashes to represent walls in order to ascertain whether the maze is solvable.
# At first I am going to implement a maze solving algortithm called the right/left hand on wall in order to traverse the maze
class MazeSolver
	@maze
	@maze_lines
	START_LABEL = "A"
	FINISH_LABEL = "B"
	MAZE_FILE_PATH = "D:\\Coding stuff\\Maze\\maze.txt"
	@hash_space_to_movement
	@maze_solved
	@last_move_array
	@unbounded_spaces
	@exhausted_unbounded_spaces
	@already_declared_unsolvable


	def initialize
		@maze_lines = Array.new
		@last_move_array = Array.new
		@maze_solved = false
		@unbounded_spaces = Array.new
		@exhausted_unbounded_spaces = Array.new
		@already_declared_unsolvable = false
	end

	# Read in the maze file that we have created
	def read_in_maze_from_file		
		if File.exists?(MAZE_FILE_PATH)
			@maze = File.new(MAZE_FILE_PATH)
			while line = @maze.gets
				@maze_lines.push(line)
			end

			puts "This is the maze you have created:"
			for i in @maze_lines
				puts i
			end

			check_maze_is_valid
		end
	end

	# Check if we have a start and an end and only one of each
	# Want to add something in here that allows you to check that the maze is completely enclosed.
	def check_maze_is_valid
		start_found = false
		end_found = false
		valid_maze = true

		puts "Need to check that the maze is valid..."

		for i in @maze_lines
			line_array = i.chars.to_a
			for j in line_array
				char = j		
				if char == START_LABEL
					if start_found == false
						start_found = true
					else
						valid_maze = false
					end
				elsif char == FINISH_LABEL
					if end_found == false
						end_found = true
					else
						valid_maze = false
					end
				end
			end

			# Break out of the loop if we have already set the maze to be invalid
			if valid_maze == false
				break
			end
		end

		if valid_maze and start_found and end_found
			puts "The maze is valid!"
		else
			puts "The maze is invalid."
		end
	end

	# Find the start position for the maze denoted the 'A' character
	def find_start_position
		hash_start = Hash.new
		hash_end = Hash.new
		hash_start_end = Hash.new

		for i in @maze_lines
			line_array = i.chars.to_a
			for j in line_array
				char = j
				# Add the start and end positions to a hash
				if char == START_LABEL
					puts "Start position found"
					line_index = @maze_lines.index(i)
					pos_index = line_array.index(j)
					hash_start = { START_LABEL => [line_index, pos_index] }
				elsif char == FINISH_LABEL
					puts "End position found"
					line_index = @maze_lines.index(i)
					pos_index = line_array.index(j)
					hash_end = { FINISH_LABEL => [line_index, pos_index]}					
				end
			end
		end
		hash_start_end = hash_start.merge(hash_end)
	end

	# Starts the algorithm that checks whether the maze is solvable or not
	def find_path(hash_positions = Hash.new)
		start_position = hash_positions[START_LABEL]

		# First element of the array is the line index, second is the position on the line
		line = start_position.fetch(0)
		position = start_position.fetch(1)

		success = move_position_recursively(line, position)
		return success
	end

	# Changes the target position depending on what is surrounding it.
	def move_position_recursively(line, position, last_move = "")
		if check_current_position_is_not_wall(line, position) == false
			puts "Something bad has happened. The current position is a wall."
			return false
		end

		surrounding_squares = inspect_surrounding_positions(line, position)
		movement = ""

		puts "Before moving: #{line}"
		puts "Before moving: #{position}"

		movement_useless = Array.new

		# Changing the pattern of movement to remember every space that is encountered and return there if we have an issue
		if @unbounded_spaces.include?([line, position]) == false and @exhausted_unbounded_spaces.include?([line, position]) == false
			@unbounded_spaces.push([line, position])
		end

		decide_possible_moves(line, position, surrounding_squares)

		if @hash_space_to_movement != nil
			if @hash_space_to_movement.has_key?([line, position])
				movement_useless = @hash_space_to_movement.fetch([line, position])
			end
		end

		#THisis where the movement is decided
		if movement_useless.include?("left") == false
			movement = "left"
		elsif movement_useless.include?("up") == false
			movement = "up"
		elsif movement_useless.include?("right") == false
			movement = "right"
		elsif movement_useless.include?("down") == false
			movement = "down"
		else
			# Delete the space if we get to this point as we are no longer interested in it.
			@unbounded_spaces.delete([line, position])
			@exhausted_unbounded_spaces.push([line, position])

			for i in @unbounded_spaces
				# Get the line and position out of the array and return a square where we can make any decision
				line = i.fetch(0)
				position = i.fetch(1)

				puts "Returning to a point where a decision was made"

				# If we return here and eventually become successful then we also want to return a solvable maze
				if move_position_recursively(line, position)
					return true
				end

				return false
			end
		end		

		# Record the movement that has been made against the space
		add_movement_to_space(line, position, movement)

		# Adjust line and position values depending on movement
		if movement == "right"
			position = position + 1
		elsif movement == "left"
			position = position - 1
		elsif movement == "up"
			line = line - 1
		else
			line = line + 1
		end

		puts "After moving: #{line}" 
		puts "After moving: #{position}"

		# Check if the maze has been solved
		if check_if_we_have_won(line, position)
			@maze_solved = true
			return true
		end

		# Return true if we are able to move again
		if move_position_recursively(line, position, movement)
			return true
		end
	end

	def decide_possible_moves(line, position, surrounding_squares)
		if (@hash_space_to_movement == nil or !@hash_space_to_movement.has_key?([line, position]))
			left = surrounding_squares["left"]
			right = surrounding_squares["right"]
			up = surrounding_squares["top"]
			down = surrounding_squares["bottom"]

			puts "Initialising moves that are possible"

			if left == "#"
				add_movement_to_space(line, position, "left")
				puts "can't move left"
			end
			if right == "#"
				add_movement_to_space(line, position, "right")
				puts "can't move right"
			end
			if up == "#"
				add_movement_to_space(line, position, "up")
				puts "can't move up"
			end
			if down == "#"
				add_movement_to_space(line, position, "down")
				puts "can't move down"
			end
		end
	end

	# Checks if we have made it to the end space
	def check_if_we_have_won(line, position)
		line_string = @maze_lines.fetch(line)
		line_array = line_string.chars.to_a

		position_char = line_array.fetch(position)
		puts position_char

		if position_char == "B"
			puts "We have got to the end!"
			return true
		end

		return false
	end

	# Add the movement we've made to a given space so we don't keep making the same moves at each space
	def add_movement_to_space(line, position, movement)
		movement_at_space = Array.new

		if @hash_space_to_movement != nil
			if @hash_space_to_movement.has_key?([line, position])
				movement_at_space = @hash_space_to_movement.fetch([line, position])
			end
		else
			@hash_space_to_movement = Hash.new
		end

		if movement_at_space != nil
			movement_at_space.push(movement)
		else
			movement_at_space = [movement]
		end

		position_array = [line, position]

		@hash_space_to_movement[position_array] = movement_at_space
	end

	# Finds the setting of each of the four surrounding positions and returns them in an array
	def inspect_surrounding_positions(line, position)
		line_above = @maze_lines.fetch(line-1)
		current_line = @maze_lines.fetch(line)
		line_below = @maze_lines.fetch(line+1)

		# change the lines into arrays
		line_above_arr = line_above.chars.to_a
		current_line_arr = current_line.chars.to_a
		line_below_arr = line_below.chars.to_a

		# get left position and right position 
		left_position = current_line_arr.fetch(position-1)
		right_position = current_line_arr.fetch(position+1)

		# get top and bottom
		top_position = line_above_arr.fetch(position)
		bottom_position = line_below_arr.fetch(position)

		# Add the positions to the array
		surrounding_squares = { "left" => left_position, "right" => right_position, "top" => top_position, "bottom" => bottom_position}		

		return surrounding_squares
	end

	def check_current_position_is_not_wall (line, position)
		current_line = @maze_lines.fetch(line)
		current_line_arr = current_line.chars.to_a

		current_position = current_line_arr.fetch(position)

		if current_position == "#"
			return false
		end

		return true
	end
end

if __FILE__ == $0
	ms = MazeSolver.new
	ms.read_in_maze_from_file
	hash_positions = ms.find_start_position

	success = ms.find_path(hash_positions)

	if success == true
		puts "This maze is solvable!"
	else
		puts "This maze has no solution"
	end
end