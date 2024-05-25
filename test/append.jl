# This file is a part of Julia. License is MIT: https://julialang.org/license

# append.jl test suite

include("../base/append.jl")
using Test

@testset "strings" begin
    @test isequal(append("ab", "cd"), "abcd")
    @test isequal(append("ab", ""), "ab")
    @test isequal(append("", "cd"), "cd")
    @test isequal(append("", ""), "")

    # testing the non-mutating propriety of append
    let a = "ab", b = "cd"
        c = append(a, b)
        @test isequal(c, "abcd")
        @test isequal(a, "ab")
        @test isequal(b, "cd")
    end
end

@testset "arrays" begin
    @test isequal(append([:a, :b], [:c, :d]), [:a, :b, :c, :d])
    @test isequal(append([:a, :b], []), [:a, :b])
    @test isequal(append([], [:c, :d]), [:c, :d])
    @test isequal(append([], []), [])
    @test isequal(append([1, 2], [:a, :b]), [1, 2, :a, :b])

    # testing the non-mutating propriety of append and conversion into Any
    let a = ["Abe", "Bob"], b = [55, 63]
        c = append(a, b)
        @test isequal(c, ["Abe", "Bob", 55, 63])
        @test isequal(typeof(c), Vector{Any})
        @test isequal(typeof(a), Vector{String})
        @test isequal(typeof(b), Vector{Int})
        @test isequal(a, ["Abe", "Bob"])
        @test isequal(b, [55, 63])
    end

    # testing the non-mutating propriety of append
    let a = [:a, :b], b = [:c, :d]
        c = append(a, b)
        @test isequal(c, [:a, :b, :c, :d])
        @test isequal(a, [:a, :b])
        @test isequal(b, [:c, :d])
    end
end

@testset "matrices" begin
    @test isequal(append([1 2;3 4], [5 6;7 8], true), [1 2;3 4;5 6;7 8])
    @test isequal(append([1 2;3 4], [5 6;7 8]), [1 2 5 6; 3 4 7 8])
    @test isequal(append([1 2;3 4], [], true), [1 2;3 4])
    @test isequal(append([], [5 6;7 8], true), [5 6;7 8])
    @test isequal(append([], [], true), [])

    # matrix need to have the same column-line or line-collumn to append
    @test_throws Exception append([1 2; 3 4], [1 2 3; 4 5 6; 7 8 9])

    # testing the non-mutating propriety of append and conversion into Any
    let a = [1 2; 3 4], b = ["a" "b"; "c" "d"]
        c = append(a,b)
        @test isequal(c, [1 2 "a" "b"; 3 4 "c" "d"])
        @test isequal(typeof(c), Matrix{Any})
        @test isequal(typeof(a), Matrix{Int})
        @test isequal(typeof(b), Matrix{String})
        @test isequal(a, [1 2; 3 4])
        @test isequal(b, ["a" "b"; "c" "d"])
    end

    # testing the non-mutating propriety of append
    let a = [1 2;3 4], b = [5 6;7 8]
        c = append(a, b, true)
        @test isequal(c, [1 2;3 4;5 6;7 8])
        @test isequal(a, [1 2;3 4])
        @test isequal(b, [5 6;7 8]) 
    end
    @test isequal(append([1 2;3 4], [5 6;7 8]), [1 2 5 6;3 4 7 8])
    @test isequal(append([1 2;3 4], [], false), [1 2;3 4])
    @test isequal(append([], [5 6;7 8]), [5 6;7 8])
    @test isequal(append([], [], false), [])

    # testing the non-mutating propriety of append
    let a = [1 2;3 4], b = [5 6;7 8]
        c = append(a, b, false)
        @test isequal(c, [1 2 5 6;3 4 7 8])
        @test isequal(a, [1 2;3 4])
        @test isequal(b, [5 6;7 8])
    end
end

@testset "sets" begin
    @test isequal(append(Set("ab"), Set("cd")), Set("abcd"))
    @test isequal(append(Set("ab"), Set("")), Set("ab"))
    @test isequal(append(Set(""), Set("cd")), Set("cd"))
    @test isequal(append(Set(""), Set("")), Set(""))
    @test isequal(append(Set("ab"), Set("ac")), Set("abc"))

    # testing the non-mutating propriety of append and conversion into Any
    let a = Set("bbc"), b = Set((1,2,2,1))
        c = append(a, b)
        @test isequal(typeof(c), Set{Any})
        @test isequal(typeof(a), Set{Char})
        @test isequal(typeof(b), Set{Int})
        @test isequal(a, Set("bbc"))
        @test isequal(b, Set((1,2,2,1)))
        @test isequal(c, Set((1,2,'b','c')))
    end

    # testing the non-mutating propriety of append
    let a = Set("ab"), b = Set("cd")
        c = append(a, b)
        @test isequal(c, Set("abcd"))
        @test isequal(a, Set("ab"))
        @test isequal(b, Set("cd"))
    end
end

# adding empty tuples is kinda dumb because tuple is const and have a const empty????
@testset "tupples" begin
    @test isequal(append(("a", "b"), ("c", "d")), ("a", "b", "c", "d"))
    @test isequal(append(("a", "b"), ()), ("a", "b"))
    @test isequal(append((), ("c", "d")), ("c", "d"))
    @test isequal(append((), ()), ())
    @test isequal(append((:a, :b), (1, 2)), (:a, :b, 1, 2))

    # testing the non-mutating propriety of append
    let a = ("a", "b"), b = ("c", "d")
        c = append(a, b)
        @test isequal(c, ("a", "b", "c", "d"))
        @test isequal(a, ("a", "b"))
        @test isequal(b, ("c", "d"))
        @test_throws Exception c[0] = 1
    end
end

@testset "namedtupples" begin
    @test isequal(append((a = 1, b = 2), (c = 3, d = 4)), (a = 1, b = 2, c = 3, d = 4))
    @test isequal(append((a = 1, b = 2), ()), (a = 1, b = 2))
    @test isequal(append((), (c = 3, d = 4)), (c = 3, d = 4))
    @test isequal(append((), ()), ())
    @test isequal(append((a = 1, b = 2), (a = 1, c = 3)), (a = 1, b = 2, c = 3))
    @test isequal(append((a = 1, b = 2), (c = 3, a = 4)), (a = 4, b = 2, c = 3))
    
    # based on julia documentation adding 2 named tuples with the same key it is supposed to choose the last one
    @test isequal(append((a = 1, b = 2), (b = "a", c = "c")), (a = 1, b = "a", c = "c"))

    # testing the non-mutating propriety of append
    let a = (a = 1, b = 2), b = (c = 3, d = 4)
        c = append(a, b)
        @test isequal(c, (a = 1, b = 2, c = 3, d = 4))
        @test isequal(a, (a = 1, b = 2))
        @test isequal(b, (c = 3, d = 4))
        @test_throws Exception c[0] = 1
    end
end

@testset "dict" begin
    @test isequal(append(Dict([("a", 1), ("b", 2)]), Dict([("c", 3), ("d", 4)])), Dict([("a", 1), ("b", 2), ("c", 3), ("d", 4)]))
    @test isequal(append(Dict([("a", 1), ("b", 2)]), Dict()), Dict([("a", 1), ("b", 2)]))
    @test isequal(append(Dict(), Dict([("c", 3), ("d", 4)])), Dict([("c", 3), ("d", 4)]))
    @test isequal(append(Dict(), Dict()), Dict())
    @test isequal(append(Dict([("a", 1), ("b", 2)]), Dict([("a", 1), ("c", 3)])), Dict([("a", 1), ("b", 2), ("c", 3)]))
    @test isequal(append(Dict([("a", 1), ("b", 2)]), Dict([("c", 3), ("a", 4)])), Dict([("a", 4), ("b", 2), ("c", 3)]))

    # based on julia documentation adding 2 Dictionaries with the same key it is supposed to choose the last one
    @test isequal(append(Dict([("a", 1), ("b", 2)]), Dict([(:a, 'a'), (:b, 'c')])), Dict([("a", 1), ("b", 2), (:a, 'a'), (:b, 'c')]))

    # testing the non-mutating propriety of append
    let a = Dict([("a", 1), ("b", 2)]), b = Dict([("c", 3), ("d", 4)])
        c = append(a, b)
        @test isequal(c, Dict([("a", 1), ("b", 2), ("c", 3), ("d", 4)]))
        @test isequal(a, Dict([("a", 1), ("b", 2)]))
        @test isequal(b, Dict([("c", 3), ("d", 4)]))
    end
end

@testset "numbers" begin
    @test isequal(append(24.5, 10), 24.51)
    @test isequal(append(10, 24.5), 1024.5)
    @test isequal(append(13, 31), 1331)
    @test_throws Exception append(2.5, 3.5)

    # testing the non-mutating propriety of append
    let a = 12, b = 13.6
        c = append(a, b)
        @test isequal(c, 1213.6)
        @test isequal(a, 12)
        @test isequal(b, 13.6)
    end
end

@testset "polymorphism matrices-vector" begin
    @test isequal(append([1 2; 4 5], [3, 6]), [1 2 3; 4 5 6])
    @test isequal(append([1 2 3; 4 5 6], [1, 2, 3]', true), [1 2 3; 4 5 6; 1 2 3])
    @test isequal(append([1 2; 3 4], ["a", "b"], false), [1 2 "a"; 3 4 "b"])

    # testing the non-mutating propriety of append
    let a = [1 2;3 4], b = [5, 6]
        c = append(a, b)
        @test isequal(c, [1 2 5; 3 4 6])
        @test isequal(a, [1 2;3 4])
        @test isequal(b, [5, 6])
    end

    # testing the non-mutating propriety of append and conversion into Any
    let a = [1 2;3 4], b = ["5" "6"; "7" "8"]
        c = append(a, b)
        @test isequal(c, [1 2 "5" "6"; 3 4 "7" "8"])
        @test isequal(typeof(c), Matrix{Any})
        @test isequal(a, [1 2;3 4])
        @test isequal(b, ["5" "6"; "7" "8"])
        @test isequal(typeof(a), Matrix{Int})
        @test isequal(typeof(b), Matrix{String})
    end
end

@testset "polymorphism string-number" begin
    @test isequal(append("John ", 5), "John 5")
    @test isequal(append(2, " apples"), "2 apples")
    @test isequal(append("Real: ", 23.5), "Real: 23.5")
    @test isequal(append(4.6, ""), "4.6")

    # testing the non-mutating propriety of append
    let a = "Bob ", b = 3
        c = append(a,b)
        @test isequal(c, "Bob 3")
        @test isequal(a, "Bob ")
        @test isequal(b, 3)
    end
end

@testset "polymorphism tupples named-tuples" begin
    @test isequal(append(("a", "b"), (c = "c", d = "d")), ("a", "b", "c", "d"))
    @test isequal(append((a = "a", b = "b"), ("b", "c")), ("a", "b", "b", "c"))
    @test isequal(append(("a", "b"), (a = 1, b = 2)), ("a", "b", 1, 2))

    # testing the non-mutating propriety of append
    let a = (f = 1, g = 2), b = (3, 4)
        c = append(a,b)
        @test isequal(c, (1, 2, 3, 4))
        @test isequal(a, (f = 1, g = 2))
        @test isequal(b, (3, 4))
    end
end

@testset "polymorphism Vectors Tuples" begin
    @test isequal(append([1, 2, 3], (4, 5, 6)), [1, 2, 3, 4, 5, 6])
    @test isequal(append((:a, :b), [:c, :d]), [:a, :b, :c, :d])
    @test isequal(append([1, 2, 3], ("a", "b", "c")), [1, 2, 3, "a", "b", "c"])
    @test isequal(append((1, 2, 3), ["a", "b", "c"]), [1, 2, 3, "a", "b", "c"])

    # testing the non-mutating propriety of append
    let a = ["a", "b"], b = ("c", "d")
        c = append(a,b)
        @test isequal(c, ["a", "b", "c", "d"])
        @test isequal(a, ["a", "b"])
        @test isequal(b, ("c", "d"))
    end
end