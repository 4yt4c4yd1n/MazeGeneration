module MazeGeneration
include("node.jl")
struct MazeViz
    walls::Vector{String}
end

mutable struct Maze

    path::Union{Vector{Node}, Nothing}
    visual::Union{MazeViz, Nothing}
    nodes::Matrix{Node}
    start::Tuple{Int, Int}
    goal::Tuple{Int, Int}

    function Maze(height::Int, width::Int)
        Lab = Matrix{Node}(undef, height, width)
        for j in 1: height
            for i in 1:width
                
                Lab[j, i] = Node((j, i))

            end
        end
        return new(nothing, nothing, Lab)
    end
end

function neighbors(node::Node, nodes::Matrix{Node})

    hood = []
    height, width = size(nodes, 1), size(nodes, 2)
    y, x = node.position[1], node.position[2]

    if y-1 >= 1
        push!(hood, nodes[y-1, x])
    else
        push!(hood, nothing)
    end
    if x-1 >= 1
        push!(hood, nodes[y, x-1])
    else
        push!(hood, nothing)
    end
    if y+1 <= height
        push!(hood, nodes[y+1, x])
    else
        push!(hood, nothing)
    end
    if x+1 <= width
        push!(hood, nodes[y, x+1])
    else
        push!(hood, nothing)
    end

    return hood
end

function randUnvisitedDirection(nodes::Vector)
    # get a list of unvisited nodes
    unvisited = filter(x->!isnothing(x)&&!x.visited,nodes)

    # if no unvisited neighbors exist, return nothing
    if isempty(unvisited)
        return nothing
    end

    # pick a random next neighbor
    next = rand(unvisited)

    # get the index(direction) for the neighbor
    index = findfirst(==(next), nodes)


    # return the direction of the next node
    return index
end


function maze(height::Int, width::Int)
    NORTH = 1
    WEST = 2
    SOUTH = 3
    EAST = 4

    lab = Maze(height, width)

    stack = []

    push!(stack, rand(lab.nodes))
    curr_node = nothing

    # while there are encountered unvisited nodes
    while !isempty(stack)

        # if curr_node is nothing, get the latest node from the stack
        if isnothing(curr_node)
            curr_node = pop!(stack)
            curr_node.visited = true
        end

        _neighbors = neighbors(curr_node, lab.nodes)

        next = randUnvisitedDirection(_neighbors)

        # if no neighbor is possible to visit
        if isnothing(next)
            # we are done with curr_node then
            # set curr_node to nothing, go to the beginning of the loop
            # and get a node from the stack
            curr_node = nothing
            continue
        end
        
        # add the current node to the stack in case we need to backtrack
        push!(stack, curr_node)

        # remove the wall between the current node and the next
        curr_node.connections[next] = true
        curr_pos = curr_node.position

        # get the object of the next node depending on the next direction
        if  next == NORTH
            curr_node = lab.nodes[curr_pos[1] - 1, curr_pos[2]]
            # 2 nodes that share the same wall have the record of the wall. 
            # Remove the wall from the neighbor(now curr_node) too
            curr_node.connections[3] = true
            # mark it as visited
            curr_node.visited = true
        elseif  next == WEST
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] - 1]
            curr_node.connections[4] = true
            curr_node.visited = true
        elseif  next == SOUTH
            curr_node = lab.nodes[curr_pos[1] + 1, curr_pos[2]]
            curr_node.connections[1] = true
            curr_node.visited = true
        elseif  next == EAST
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] + 1]
            curr_node.connections[2] = true
            curr_node.visited = true
        end

        #loop
    end

    # y and x are random but they cannot be completely random.
    # They must be at edges. Therefore we constrict x to 2 options and let y be anything
    if rand(1:2) == 1
        ys = collect(1:height)
        xs = [1, width]
    else
        ys = [1, height]
        xs = collect(1:width)
    end

    start_y = rand(ys)
    start_x = rand(xs)

    # To make the maze more pleasant looking, remove the used indices
    filter!(x->x!=start_y, ys)
    filter!(x->x!=start_x, xs)


    goal_y = rand(ys)
    # only 1 option left for x
    goal_x = rand(xs)

    curr_node = lab.nodes[start_y, start_x]
    n = neighbors(curr_node, lab.nodes)
    # get all the indexes of edges(where the neighbor is marked as nothing)
    edges = findall(isnothing, n)
    # select a random edge wall and remove it
    curr_node.connections[rand(edges)] = true

    curr_node = lab.nodes[goal_y, goal_x]
    n = neighbors(curr_node, lab.nodes)
    edges = findall(isnothing, n)
    curr_node.connections[rand(edges)] = true
    
    return lab
end

function visualize(lab::Maze)
    height, width = size(lab.nodes, 1), size(lab.nodes, 2)
    walls = []
    
    #iterate over nodes to find the walls
    for i in 1:height
        top = "+" #initialize upper walls with + for the first upper left corner
        middle = "" #initialize vertical walls
        for j in 1:width
            n = lab.nodes[i,j]
            
            #finding walls for nodes in the last column at the right site
            if j == width
                if !n.connections[1] #upper walls
                    top *= "---+"
                else
                    top *= "   +"
                end
                if !n.connections[2] #walls to the left
                    middle *= "|   "
                else
                    middle *= "    "
                end
                if !n.connections[4] #walls to the right
                    middle *= "|"
                else
                    middle *= " "
                end
            #finding walls for nodes NOT in the last column
            else
                if !n.connections[1] #upper walls
                    top *= "---+"
                else
                    top *= "   +"
                end
                if !n.connections[2] #left walls
                    middle *= "|   "
                else
                    middle *= "    "
                end
            end
        end
        #appending walls in the list
        push!(walls, top)
        push!(walls, middle)
    end
    
    #initializing last line with + for the lower left corner
    bottom = "+"
    #finding walls to the bottom of the last line
    for j in 1:width
        ne = lab.nodes[1,j]
        if !ne.connections[1]
            bottom *= "---+"
        else
            bottom *= "   +"
        end
    end
    #incluce bottom walls to the rest of the walls
    push!(walls, bottom)
    _visual = MazeViz(walls)
    lab.visual = _visual
    return _visual
end
            
#visualize the Maze by printing the walls                
function Base.show(io::IO, lab::Maze)
    viz = visualize(lab)
    for i in 1:size(viz.walls, 1)
        for n in 1:size(viz.walls, 2)
            print(io, join(viz.walls[i,n]))
        end
        println(io)
    end
end

function animateMaze(height::Int, width::Int)
    NORTH = 1
    WEST = 2
    SOUTH = 3
    EAST = 4

    lab = Maze(height, width)

    stack = []

    push!(stack, rand(lab.nodes))
    curr_node = nothing

    # while there are encountered unvisited nodes
    while !isempty(stack)
        print("\e[0;0H\e[2J")
        display(lab)
        sleep(0.1)
        
        # if curr_node is nothing, get the latest node from the stack
        if isnothing(curr_node)
            curr_node = pop!(stack)
            curr_node.visited = true
        end

        _neighbors = neighbors(curr_node, lab.nodes)

        next = randUnvisitedDirection(_neighbors)

        # if no neighbor is possible to visit
        if isnothing(next)
            # we are done with curr_node then
            # set curr_node to nothing, go to the beginning of the loop
            # and get a node from the stack
            curr_node = nothing
            continue
        end
        
        # add the current node to the stack in case we need to backtrack
        push!(stack, curr_node)

        # remove the wall between the current node and the next
        curr_node.connections[next] = true
        curr_pos = curr_node.position

        # get the object of the next node depending on the next direction
        if  next == NORTH
            curr_node = lab.nodes[curr_pos[1] - 1, curr_pos[2]]
            # 2 nodes that share the same wall have the record of the wall. 
            # Remove the wall from the neighbor(now curr_node) too
            curr_node.connections[3] = true
            # mark it as visited
            curr_node.visited = true
        elseif  next == WEST
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] - 1]
            curr_node.connections[4] = true
            curr_node.visited = true
        elseif  next == SOUTH
            curr_node = lab.nodes[curr_pos[1] + 1, curr_pos[2]]
            curr_node.connections[1] = true
            curr_node.visited = true
        elseif  next == EAST
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] + 1]
            curr_node.connections[2] = true
            curr_node.visited = true
        end

        #loop
    end

    # y and x are random but they cannot be completely random.
    # They must be at edges. Therefore we constrict x to 2 options and let y be anything
    ys = collect(1:height)
    xs = [1, width]

    start_y = rand(ys)
    start_x = rand(xs)

    # To make the maze more pleasant looking, remove the used indices
    popat!(ys, start_y)
    filter!(x->x!=start_x, xs)


    goal_y = rand(ys)
    # only 1 option left for x
    goal_x = xs[1]

    curr_node = lab.nodes[start_y, start_x]
    n = neighbors(curr_node, lab.nodes)
    # get all the indexes of edges(where the neighbor is marked as nothing)
    edges = findall(isnothing, n)
    # select a random edge wall and remove it
    curr_node.connections[rand(edges)] = true

    curr_node = lab.nodes[goal_y, goal_x]
    n = neighbors(curr_node, lab.nodes)
    edges = findall(isnothing, n)
    curr_node.connections[rand(edges)] = true
    
    return lab
end
maze(5, 5)
end # module MazeGeneration