using Crayons

include("Maze.jl")
function visualize(lab::Maze)
    height, width = size(lab.nodes, 1), size(lab.nodes, 2)
    walls = []

    #if there is already a path found
    _path = lab.short_path
    _path_set = Set{Tuple{Int,Int}}()
 #   _path2 = lab.path
 #   _path2_set = Set{Tuple{Int,Int}}()
    _crayon1 = Crayon(foreground=:green, bold = true)
    _crayon2 = Crayon(foreground=:red, bold = true)

    #= get the path's positions
    if !isnothing(_path2)
           for node in _path2
               push!(_path2_set, node.position)
           end
    end  =#
    #get the positions of the shorter path
    if !isnothing(_path)
           for node in _path
               push!(_path_set, node[1].position)
           end 
    end 

    #create the crayons           
  #  _crayon2 = Crayon(foreground=:white, background=:red, bold=true)
  #  _crayon1 = Crayon(foreground=:white, background=:green, bold=true)
    directions = ["↑","←", "↓", "→"]
  #   footprints = "👣"
   #  walking_person = "🚶"
    

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
                    elseif !isnothing(n.dir)
                        middle *= "| " * string((_crayon2(directions[n.dir]))) * " "
                    else
                        middle *= "|   "
                    end
                else
                    if (i,j) in _path_set
                        middle *= "  " * string((_crayon1(directions[n.dir]))) * " "
                    elseif !isnothing(n.dir)
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
                    elseif !isnothing(n.dir)
                        middle *= "| " * string((_crayon2(directions[n.dir]))) * " "
                    else 
                        middle *= "|   "
                    end
                else
                    if (i,j) in _path_set
                        middle *= "  " * string((_crayon1(directions[n.dir]))) * " "
                    elseif !isnothing(n.dir)
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
    

    #=
    if !isnothing(_path)
        #walk thorugh the nodes of the path
        for k in 1:length(_path)
            #get the current node
            curr_node = _path[k][1]
            i = curr_node.position[1]
            j = curr_node.position[2]

            #find the right string in walls
            a = 2*i
            #find the right position, the middle
            b = 3+((j-1)*4)
            c = _path[k][2]
            #initialize new string
            _new = ""
            for n in eachindex(walls[a])
                #if we are at our node, add the direction to the string
                if n == b
                 #   _new *= string((_crayon1(directions[c])))
                    _new *= directions[c]
                else
                    _new *= walls[a][n]
                end 
            end 
            walls[a] = _new
        end 
    end
    =#
    

    
    

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
    println(io, "Start: ", lab.start, ", Goal: ", lab.goal)

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