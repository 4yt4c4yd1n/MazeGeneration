include("node.jl")

struct MazeViz
    walls::Vector{String}
end
mutable struct Maze

    path::Union{Vector{Node}, Nothing}
    short_path::Union{Vector{Tuple{Node, Int}}, Nothing}
    visual::Union{MazeViz, Nothing}
    nodes::Matrix{Node}
    start::Union{Tuple{Int, Int}, Nothing}
    goal::Union{Tuple{Int, Int}, Nothing}

    function Maze(height::Int, width::Int)
        Lab = Matrix{Node}(undef, height, width)
        for j in 1: height
            for i in 1:width
                
                Lab[j, i] = Node((j, i))

            end
        end
        return new(nothing, nothing, nothing, Lab)
    end
end