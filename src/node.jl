mutable struct Node
    position::Tuple{Int, Int}
    connections::Vector{Bool}
    visited::Bool
    dir::Union{Int, Nothing}
    Node(position) = new(position, Vector{Bool}([false, false, false, false]), false, nothing)
end

function Base.show(io::IO, n::Node)
    if n.visited
        print(io,  " [n]$(n.position) ")
    else
        print(io,  "  N $(n.position) ")
    end
    if (n.connections[1])
        print(io, "⬆ ")
    else
        print(io, "✖ ")
    end
    if (n.connections[2])
        print(io, "⬅ ")
    else
        print(io, "✖ ")
    end
    if (n.connections[4])
        print(io, "➡ ")
    else
        print(io, "✖ ")
    end
    if (n.connections[3])
        print(io, "⬇")
    else
        print(io, "✖")
    end
end