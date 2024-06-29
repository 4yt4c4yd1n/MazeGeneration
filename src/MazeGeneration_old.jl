module MazeGeneration
include("node.jl")
struct MazeViz
end

mutable struct Maze

    path::Union{Vector{Node}, Nothing}
    visual::Union{MazeViz, Nothing}
    nodes::Matrix{Node}

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
    unvisited = filter(x->!isnothing(x)&&!x.visited,nodes)
    if isempty(unvisited)
        return nothing, nothing
    end
    next = rand(unvisited)
    #println("Next: ", next)
    index = findfirst(==(next), nodes)
    uindex = findfirst(==(next), unvisited)
    deleteat!(unvisited, uindex)
    #println(index)
    return index, unvisited
end


function maze(height::Int, width::Int)
    lab = Maze(height, width)

    stack = []

    push!(stack, rand(lab.nodes))
    curr_node = nothing

    while !isempty(stack)

        if isnothing(curr_node)
            curr_node = pop!(stack)
            curr_node.visited = true
        end
        #println(curr_node)
        _neighbors = neighbors(curr_node, lab.nodes)

        next, unvisitedNeighbors = randUnvisitedDirection(_neighbors)

        if isnothing(next)
            if all(!, curr_node.connections)
                curr_node.connections[rand(1:4)] = true
            end
            curr_node=nothing
            continue
        end
        
        stack = vcat(stack, unvisitedNeighbors)
        push!(stack, curr_node)

        curr_node.connections[next] = true
        curr_pos = curr_node.position
        if  next == 1
            curr_node = lab.nodes[curr_pos[1] - 1, curr_pos[2]]
            curr_node.connections[3] = true
            curr_node.visited = true
        elseif  next == 2
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] - 1]
            curr_node.connections[4] = true
            curr_node.visited = true
        elseif  next == 3
            curr_node = lab.nodes[curr_pos[1] + 1, curr_pos[2]]
            curr_node.connections[1] = true
            curr_node.visited = true
        elseif  next == 4
            curr_node = lab.nodes[curr_pos[1], curr_pos[2] + 1]
            curr_node.connections[2] = true
            curr_node.visited = true
        end

    end
    start_y = rand(1:height)
    start_x = rand([1, width])

    goal_y = rand(1:height)
    goal_x = rand([1, width])

    while goal_y == start_y || goal_x  == start_x
        goal_y = rand(1:height)
        goal_x = rand([1, width])
    end

    curr_node = lab.nodes[start_y, start_x]
    n = neighbors(curr_node, lab.nodes)
    edges = findall(isnothing, n)
    curr_node.connections[rand(edges)] = true

    curr_node = lab.nodes[goal_y, goal_x]
    n = neighbors(curr_node, lab.nodes)
    edges = findall(isnothing, n)
    curr_node.connections[rand(edges)] = true
    
    return lab
end

display(maze(10, 10).nodes)

end # module MazeGeneration