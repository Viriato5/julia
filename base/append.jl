# This file is a part of Julia. License is MIT: https://julialang.org/license

# append.jl: non-mutating appending functions all in one place

"""
Auxiliary function
"""
function append_types_match(z, w)
    return typeof(z) == typeof(w)
end

"""
Strings
Second String is concatenated to the end of the first String
"""
function append(x::T, y::T) where T<:AbstractString
    return join([x, y])
end

"""
Vectors
Second Vector is concatenated to the end of the first Vector
If Vector types mismatch converts the result into Vector{Any}
"""
function append(x::T, y::U) where T <:AbstractVector where U<:AbstractVector
    if append_types_match(x, y)
        return append!(copy(x), y)
    else
        return append!(Vector{Any}(x), y)
    end
end

"""
Matrix
Second Matrix is concatenated horizontly or vertically to the first Matrix
If Matrix types mismatch converts the result into Matrix{Any}
As a default append(Matrix, Matrix) appends them horizontaly
"""
function append(x::T, y::U) where T <:AbstractMatrix where U<:AbstractMatrix
    return hcat(x, y)
end

function append(x::T, y::U, ver::Bool) where T <:AbstractMatrix where U<:AbstractMatrix
    if ver
        return vcat(x, y)
    else
        return hcat(x, y)
    end
end

"""
Set
Joins both Sets into one
If Set types mismatch converts the result into Set{Any}
"""
function append(x::T, y::U) where T<: AbstractSet where U<: AbstractSet
    if append_types_match(x, y)
        return union(x, y)
    else
        return union(Set{Any}(x), Set{Any}(y))
    end
end

"""
Tuple
Second Tuple is concatenated to the end of the first Tuple
"""
function tuplechoser(x::Tuple, y::Tuple, i::Int) 
    max = length(x)
    return i <= max ? x[i] : y[i - max]     
end

function append(x::Tuple, y::Tuple) 
    max = length(x) + length(y)
    return Tuple(tuplechoser(x, y, i) for i in 1:max)
end

"""
Named Tuple
Second Named-Tuple is concatenated to the end of the first Named-Tuple
If both Named-Tuples share an entry, that entry gets the Second Named-Tuple's value
"""
function append(x::NamedTuple, y::NamedTuple)
    return merge(x, y)
end

"""
Dictionaries
Joins both Dictionaries into one
If Dictionaries types mismatch on the key or the value, they get converted into Any
"""
function append(x::AbstractDict, y::AbstractDict)
    return merge(x, y)
end

"""
Numbers
Second Number is concatenated to the end of the first Number
Can't concatenate 2 real Numbers
"""

function append(x::T, y::U) where T<:Real where U<:Int
    return tryparse(Float64, "$x$y")
end

function append(x::T, y::U) where T<:Int where U<:Real
    return tryparse(Float64, "$x$y")
end

function append(x::T, y::U) where T<:Int where U<:Int
    return tryparse(Int, "$x$y")
end

"""
Polymorphism
function append for mismatching collections
"""

"""
Polymorphism
Vector Matrix
Vector is concatenated horizontally to the Matrix.
The Vector's length must match with the Matrix's Size
If Collection's types mismatch converts the result into Matrix{Any}
"""
function append(x::T, y::U) where T <:AbstractVector where U<:AbstractMatrix
    if isempty(x)
        return copy(y)
    else
        return hcat(x, y)
    end
end

function append(x::T, y::U) where T <:AbstractMatrix where U<:AbstractVector
    if isempty(y)
        return copy(x)
    else
        return hcat(x, y)
    end
end

function append(x::T, y::U, ver::Bool) where T <:AbstractVector where U<:AbstractMatrix
    if isempty(x)
        return copy(y)
    end
    if ver
        return vcat(x, y)
    else
        return hcat(x, y)
    end
end

function append(x::T, y::U, ver::Bool) where T <:AbstractMatrix where U<:AbstractVector
    if isempty(y)
        return copy(x)
    end
    if ver
        return vcat(x, y)
    else
        return hcat(x, y)
    end
end
# empty empty pedia isto
function append(x::T, y::U, ver::Bool) where T <:AbstractVector where U<:AbstractVector
    if isempty(x)
        return copy(y)
    end
    if ver
        return vcat(x, y)
    else
        return hcat(x, y)
    end
end

"""
Polymorphism
Strings Numbers
Concatenates the first element to the end of the first element
"""

function append(x::T, y::U) where T<:AbstractString where U<:Int
    return "$x$y"
end

function append(x::T, y::U) where T<:Int where U<:AbstractString
    return "$x$y"
end

function append(x::T, y::U) where T<:AbstractString where U<:Real
    return "$x$y"
end

function append(x::T, y::U) where T<:Real where U<:AbstractString
    return "$x$y"
end

"""
Polymorphism
Tuple Named-Tuple
Second (Named) Tuple is concatenated to the end of the First (Named) Tuple
The Named Tuple's values lose their "Names"
"""

function tuplechoser(x::Tuple, y::NamedTuple, i::Int) 
    max = length(x)
    return i <= max ? x[i] : y[i - max]     
end

function tuplechoser(x::NamedTuple, y::Tuple, i::Int) 
    max = length(x)
    return i <= max ? x[i] : y[i - max]     
end

function append(x::Tuple, y::NamedTuple) 
    if isempty(x)
        return y
    end
    max = length(x) + length(y)
    return Tuple(tuplechoser(x, y, i) for i in 1:max)
end

function append(x::NamedTuple, y::Tuple) 
    if isempty(y)
        return x
    end
    max = length(x) + length(y)
    return Tuple(tuplechoser(x, y, i) for i in 1:max)
end

"""
Polymorphism
Tuple Vector
Second Collection is concatenated into the first collection
If any Tuple element's type mismatches the Vector type the result is converted to Vector{Any}
"""

function append(x::T, y::U) where T <:AbstractVector where U<:Tuple
    y = collect(y)
    if append_types_match(x, y)
        return append!(copy(x), y)
    else
        return append!(Vector{Any}(x), y)
    end
end

function append(x::T, y::U) where T <:Tuple where U<:AbstractVector
    x = collect(x)
    if append_types_match(x, y)
        return append!(x, y)
    else
        return append!(Vector{Any}(x), y)
    end
end