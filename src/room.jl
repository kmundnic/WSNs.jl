abstract type AbstractOcclusion end

struct Wall <: AbstractOcclusion
    shape::Shape
    np_increase::Real

    function Wall(w::Real, h::Real, x::Real, y::Real)
        new(rect(w,h,x,y), 2)
    end
end

struct Room
    width::Real
    height::Real

    occlusions::Array{AbstractOcclusion}

    function Room(w::Real, h::Real, walls::Vector{Wall})
        @assert w > 0 "Room width must be > 0"
        @assert h > 0 "Room height must be > 0"

        @assert all([all(x -> x ≤ w, Plots.coords(wall.shape)[1]) for wall in walls]) "Walls are outside of the room"
        @assert all([all(x -> x ≤ h, Plots.coords(wall.shape)[2]) for wall in walls]) "Walls are outside of the room"

        new(w, h, walls)
    end

    function Room()
        walls = [Wall(6, 0.2, -0.5, 2.4), Wall(6, 0.2, 7.5, 5.2), Wall(6, 0.2, -0.5, 9.7)]

        new(16, 16, walls)
    end
end

function rect(w, h, x, y)
    @assert w > 0 "Rectangle width must be > 0"
    @assert h > 0 "Rectangle height must be > 0"

    return Shape(x .+ [0, w ,w ,0], y .+ [0, 0, h, h])
end

"""
line_of_sight(network::AbstractNetwork, room::Room)

Return a matrix containing the distance from i to j at which an occlusion happens,
or a missing if there are no occlusions bewteen two points
"""
function non_line_of_sight(network::AbstractNetwork, room::Room)
    
    number_of_occlusions = length(room.occlusions)
    number_of_sensors = size(network.layout,1)

    NLOS = Array{Union{Missings.Missing, Float64}, number_of_occlusions}(undef, number_of_sensors, number_of_sensors, number_of_occlusions)

    for (w, wall) in enumerate(room.occlusions)
        # Check for intersection between the edge between two nodes and a given wall
        for j in 1:number_of_sensors, i in 1:number_of_sensors
            if i != j
                nodes = network.layout[[i,j],:]
                try
                    p, NLOS[i,j,w] = non_line_of_sight(nodes, wall)
                catch e
                    @show (i,j,w)
                    throw(e)
                end
            end
        end        
    end
        
    return NLOS
end

function distance(p1::Point{T}, p2::Point{T}) where T <: Real
    return norm([p1.x - p2.x; p1.y - p2.y], 2)
end

"""
line_of_sight(nodes::DataFrame, wall::Wall)

Checks wether the wall is between the nodes.

This problem is posed as a feasibility problem within convex optimization.
It assumes that the wall is a convex (rectangular) structure.
"""
function non_line_of_sight(nodes::DataFrame, wall::Wall)

    p1 = Point(nodes[1,:][:x], nodes[1,:][:y])
    p2 = Point(nodes[2,:][:x], nodes[2,:][:y])

    edge = Line(p1, p2)

    x = Variable(1)
    f = x -> edge.m * x + edge.c

    problem = minimize(f(x))
    problem.constraints += -x ≤ -minimum(wall.shape.x)
    problem.constraints += x ≤ maximum(wall.shape.x)
    problem.constraints += -f(x) ≤ -minimum(wall.shape.y)
    problem.constraints += f(x) ≤ maximum(wall.shape.y)

    problem.constraints += -x ≤ minimum(nodes[:x])
    problem.constraints += x ≤ maximum(nodes[:x])
    problem.constraints += -f(x) ≤ minimum(nodes[:y])
    problem.constraints += f(x) ≤ maximum(nodes[:y])

    solve!(problem, SCSSolver(verbose=false), verbose=false) # Second verbose=false is for warnings


    if problem.status == :Infeasible
        return missing, missing
    elseif problem.status == :Optimal
        p3 = Point(x.value, f(x.value))
        return p3, distance(p1, p3)
    else
        @warn "Feasibility problem not solved: $(problem.status)"
        return missing, missing
    end
end

# function line_of_sight(nodes::DataFrame, wall::Wall)
#     @assert size(nodes, 1) == 2
#     @assert size(nodes, 2) == 2

#     p1 = Point(nodes[1,:][:x], nodes[1,:][:y])
#     p2 = Point(nodes[2,:][:x], nodes[2,:][:y])

#     w1 = Point(wall.shape.x[1], wall.shape.y[1])
#     w2 = Point(wall.shape.x[2], wall.shape.y[2])

#     edge = Line(p1, p2)
#     occlusion = Line(w1, w2)

#     p = intersection(edge, occlusion)

#     return (w1.x ≤ p.x ≤ w2.x) && (w1.y ≤ p.y ≤ w2.y)
# end

function plot(room::Room)
    # plot()
    for wall in room.occlusions
        plot!(wall.shape,
            color=:gray,
            alpha=0.75,
            legend=false,
            show=true)
    end
end

    