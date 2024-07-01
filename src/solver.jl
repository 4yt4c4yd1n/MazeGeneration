include("node.jl")
include("Maze.jl")

function solve(maze::Maze)
    NORTH = 1
    WEST = 2
    SOUTH = 3
    EAST = 4
    diffs = [(-1, 0), (0, -1), (1, 0), (0, 1)]
    #get the start and end position
    x = maze.start
    y = maze.goal
    

    if !isnothing(x)&&!isnothing(y)

        #initialize the path
        start_x = maze.nodes[x[1], x[2]]
        solution = [start_x]

        #initialize the shortes path
        short_sol = Vector{Tuple{Node, Int}}()
        circle = Vector{Tuple{Node, Int}}()
        path_set = Set{Node}()

        goal_y = maze.nodes[y[1],y[2]]

        height =size(maze.nodes, 1)
        width = size(maze.nodes, 2)

        #get the first direction
        #if coming southwards, point must be (1, ...)
        if x[1] == 1 && start_x.connections[1]
            direction = SOUTH
        #if coming northwards, point must be (height, ...)
        elseif x[1] == height && start_x.connections[3]
            direction = NORTH
        #if coming eastwards, point must be (..., 1)
        elseif x[2] == 1 && start_x.connections[2]
            direction = EAST
        #if coming westwards, point must be (..., width)
        elseif x[2] == width && start_x.connections[4]
            direction = WEST
        end

        curr_node = start_x

        while curr_node != goal_y
            #to find out, where the right side is
            right = mod(direction + 2, 4)+1

            #to find out, where the left side is
            left = mod(direction, 4) + 1
            #opposite side, in order we have to go back
            opp = mod(direction + 1, 4) + 1

            #if there is no wall to the right
            if curr_node.connections[right]
                #get the next node's position
                i, j = curr_node.position[1], curr_node.position[2]
                next_i, next_j = diffs[right]

                #add the next node to the path
                push!(solution, maze.nodes[i+next_i, j+next_j])
                #change the direction
                #since we turned to the right
                direction = right

            #if we cannot tunr right, we try to go forward
            elseif curr_node.connections[direction]
                i, j = curr_node.position[1], curr_node.position[2]
                next_i, next_j = diffs[direction]

                push!(solution, maze.nodes[i+next_i, j+next_j])
                #in this case, the direction doesn't change

            #if we cannot go forward, we try to go to the left
            elseif curr_node.connections[left]
                i, j = curr_node.position[1], curr_node.position[2]
                next_i, next_j = diffs[left]

                push!(solution, maze.nodes[i+next_i, j+next_j])
                #direction changes, since we truned left
                direction = left
            
            #if nothign worked so far, we have to get back
            else 
                direction = opp
            end

            #check, if there is a circle
            if curr_node in path_set
                #find the revisited node
                for i in 1:length(short_sol)
                    if short_sol[i][1] == curr_node
                        k = i
                        #delete the circle
                        while length(short_sol) > k
                            push!(circle, pop!(short_sol))
                        end 
                        pop!(short_sol)
                        break
                    end 
                end 
            end
            #update the shorter path, save the (updated) direction
            push!(short_sol, (curr_node, direction))
            #add the node to the set of visited nodes
            push!(path_set, curr_node)
            
            #update current node
            curr_node = solution[end]

        end 

        #get the last direction
        if y[1] == height #if we are at the bottom
            if goal_y.connections[3] #if there is no wall
                direction = SOUTH #we leave to the south
            elseif y[2] == width #if there is no wall to the right
                direction = EAST #we leave to the right
            else
                direction = WEST #we leave to the left
            end 
        elseif y[1] == 1 #if we are at the top
            if goal_y.connections[1]
                direction = NORTH
            elseif y[2] == width
                direction = EAST
            else 
                    direction = WEST
                end
        else
            if y[2] == width
                direction = EAST
            else
                direction = WEST
            end
        end  

        #add the end node to the path
        push!(solution, goal_y)
        push!(short_sol, (goal_y, direction))

        for node in short_sol
            node[1].dir = node[2]
        end
        for node in circle
            _dir = node[2] + 2
            if _dir > 4
                _dir -= 4
            end
            node[1].dir = _dir
        end 

        return (solution, short_sol)
        end 
end

