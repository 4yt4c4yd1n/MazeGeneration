using MazeGeneration
using Test

@testset verbose = true "All Tests" begin
@testset verbose = true "Maze Generation General"  begin
    for i in 1:10
        for j in 1:10
            for k in 1:j*i*16
                @test typeof(MazeGeneration.maze(j, i)) == MazeGeneration.Maze
            end
        end
    end
end

@testset verbose = true "Maze Generation Edge Cases" begin
    toTest = [
            (1, 1), (2, 1), (1,2), (0, 0), 
            (0, 1), (1, 0), (-1, -1), (2, 3), 
            (3, 2), (1.1, 1.2), (typemax(Int), typemax(Int)),
            (typemin(Int), typemin(Int)), (1000, 1000), (1001, 1000)
            ]
    for i in eachindex(toTest)
        try
            MazeGeneration.maze(toTest[i][1], toTest[i][2])
        catch e
            @test isa(e, AssertionError) || isa(e, ArgumentError) || isa(e, MethodError)
        end
    end
end

@testset verbose = true "Spanning Tree Test" begin
    lab = MazeGeneration.maze(10, 10)
    for j in 1:10
        for i in 1:10
            for y in 1:10
                for x in 1:10

                    lab.start = (j, i)
                    lab.goal = (y, x)
                    path = MazeGeneration.findpath(lab)[1]
                    @test isa(path, Vector{MazeGeneration.Node})
                    @test path[1].position == (j, i) && path[length(path)].position == (y, x)
                end
            end
        end
    end
    
end
end