struct Point{T <: Real}
    x::T
    y::T
end
 
struct Line{T <: Real}
    m::T
    c::T

    function Line(p0::Point{T}, p1::Point{T}) where T <: Real
        m = (p1.y - p0.y) / (p1.x - p0.x)
        c = p0.y - m * p0.x

        new{T}(m, c)
    end

end