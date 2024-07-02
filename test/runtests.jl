using Crayons
using MazeGeneration

_crayon1 = Crayon(foreground=:green, bold = true)
_crayon2 = Crayon(foreground=:red, bold = true)

function test1(verbose::Bool)
    passed = true
    for i in 1:10
        for j in 1:10
            for k in 1:j*i*16
                try
                    if verbose
                        print("Test 1 for maze", (j, i))
                    end
                    MazeGeneration.maze(j, i)
                catch e
                    if verbose
                        println(string(_crayon2(" : ", string(e))))
                        rethrow(e)
                    end
                    passed = false
                else
                    if verbose
                        println(string(_crayon1(" ✓")))
                    end
                end
            end
        end
    end
    return passed
end

function test2(verbose::Bool)
    passed = true
    toTest = [
            (1, 1), (2, 1), (1,2), (0, 0), 
            (0, 1), (1, 0), (-1, -1), (2, 3), 
            (3, 2), (1.1, 1.2), (typemax(Int), typemax(Int)),
            (typemin(Int), typemin(Int)), (1000, 1000), (1001, 1000)
            ]
    for i in eachindex(toTest)
        try
            if verbose
                print("Test 2 for maze", toTest[i])
            end
            MazeGeneration.maze(toTest[i][1], toTest[i][2])
        catch e
            if verbose
                if isa(e, AssertionError)
                    println(string(_crayon1(" : Unwanted parameters found, raised error succesfully")))
                elseif isa(e, BoundsError)
                    println(string(_crayon2(" : Algorithm failure")))
                    passed = false
                else
                    println(string(_crayon1(" : Error found by system")))
                end
            end
        else
            if verbose
                println(string(_crayon1(" ✓")))
            end
        end
    end
    return passed
end

function alltests(verbose::Bool=false)
    results = Bool[]
    append!(results, test1(verbose))
    append!(results, test2(verbose))
    println(results)
    if all(results)
        println(_crayon1("All tests passed succesfully!"))
        return true
    else
        println(_crayon2("Test(s) failed: ", string(findall(!, results))))
        return false
    end
end
@test alltests(true)