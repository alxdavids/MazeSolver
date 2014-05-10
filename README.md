Maze Solver
======================

Something that I have written in Ruby in order to solve mazes that are predtermined in a text file by the user of the software.

The maze must be made up of #'s to represent walls and spaces to represent places where moves are allowed, the start and finish point of the maze is defined with an A and a B respectively. The program returns whether the maze you have created is solvable or not.
Currently the validation is not completely finished. As such if you make a maze which is not completely enclosed by #'s then the program will not work as expected. Also if you use tab charcters instead of spaces then this will also cause the program problems.

My future objective with this piece of work is to try and make it so the program is able to calculate the shortest path from the start to the finish. 