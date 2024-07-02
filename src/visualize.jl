using Crayons
include("Maze.jl")

function visualize(lab::Maze)
    height, width = size(lab.nodes, 1), size(lab.nodes, 2)
    walls = []

    #if there is already a path found
    #initialize a set for the nodes of the shorter one
    _path = lab.short_path
    _path_set = Set{Tuple{Int,Int}}()

    #do  the same with the longer path
    _path2 = lab.path
    _path2_set = Set{Tuple{Int, Int}}()

    #nodes of the path are marked red, if they are unnecessary
    #and green, if they belong to the shorter one
    _crayon1 = Crayon(foreground=:green, bold = true)
    _crayon2 = Crayon(foreground=:red, bold = true)

    #add the positions of the path to the 2. set
    if !isnothing(_path2)
           for node in _path2
               push!(_path2_set, node.position)
           end 
    end 

    #add the positions of the shorter path to the set
    if !isnothing(_path)
        for node in _path
            push!(_path_set, node[1].position)
        end 
    end 


    #to visualize the directions
    directions = ["↑","←", "↓", "→"]


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
                    #nodes of the shorter part are colored green
                    if (i,j) in _path_set
                        middle *= "| " * string((_crayon1(directions[n.dir]))) * " "
                    #nodes only of the longer path are colored red
            #        elseif !isnothing(n.dir)
                    elseif (i,j) in _path2_set
                        middle *= "| " * string((_crayon2(directions[n.dir]))) * " "
                    else
                        middle *= "|   "
                    end
                else
                    if (i,j) in _path_set
                        middle *= "  " * string((_crayon1(directions[n.dir]))) * " "
       #             elseif !isnothing(n.dir)
                    elseif (i,j) in _path2_set
                        middle *= "  " * string((_crayon2(directions[n.dir]))) * " "
                    else 
                        middle *= "    "  
                    end 
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
                    if (i,j) in _path_set
                        middle *= "| " * string((_crayon1(directions[n.dir]))) * " "
        #            elseif !isnothing(n.dir)
                    elseif (i,j) in _path2_set
                        middle *= "| " * string((_crayon2(directions[n.dir]))) * " "
                    else 
                        middle *= "|   "
                    end
                else
                    if (i,j) in _path_set
                        middle *= "  " * string((_crayon1(directions[n.dir]))) * " "
                    elseif (i,j) in _path2_set
                        middle *= "  " * string((_crayon2(directions[n.dir]))) * " "
                    else 
                        middle *= "    "  
                    end
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
        ne = lab.nodes[height,j]
        if ne.connections[3]
            bottom *= "   +"
        else
            bottom *= "---+"
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
    viz = lab.visual
    for i in 1:size(viz.walls, 1)
        for n in 1:size(viz.walls, 2)
            print(io, join(viz.walls[i,n]))
        end
        println(io)
    end
    if !isnothing(lab.start) && !isnothing(lab.goal)
        println(io, "Start: ", lab.start, ", Goal: ", lab.goal)
    end
    if !isnothing(lab.path)
        print(io, "Right hand path: ")
        for i in 1:(length(lab.path)-1)
            print(io, lab.path[i].position, " ⇒ ")
        end
        println(io, lab.path[end].position)
    end
    if !isnothing(lab.short_path)
        print(io, "Shortest path: ")
        for i in 1:(length(lab.short_path)-1)
            print(io, lab.short_path[i][1].position, " ⇒ ")
        end
        println(io, lab.short_path[end][1].position)
    end
end