module WSNs

    using Pkg
    using JLD2
    using Plots
    using FileIO
    using Random
    using Missings
    using Distances
    using DataFrames
    using Convex, SCS
    using Localization

    export fading_model, plot_layout, load_layout, FixedNetwork, RandomNetwork, Point, Line, intersection

    Random.seed!(1)

    abstract type AbstractNetwork end

    struct FixedNetwork <: AbstractNetwork
        layout::DataFrame          # Network layout (2D or 3D)
        distances::Matrix{Float64} # Matrix of distances between all pair of nodes
        nodenames::Vector{String}  # Vector of strings for the names of nodes

        function FixedNetwork()
            layout = [(x,y) for x in 0:2:10, y in 0:2:10]
            layout = reshape(layout, length(layout))
            layout = DataFrame(x = [x[1] for x in layout], y = [y[2] for y in layout])

            distances = pairwise(Euclidean(), convert(Matrix, layout), dims=2)
            nodenames = [string(i) for i in 1:size(layout,1)]

            new(layout, distances, nodenames)
        end
    end

    struct RandomNetwork <: AbstractNetwork
        layout::DataFrame          # Network layout (2D or 3D)
        distances::Matrix{Float64} # Matrix of distances between all pair of nodes
        nodenames::Vector{String}  # Vector of strings for the names of nodes
        # A::Matrix{Float64}         # Adjacency matrix. A[j,i] is the weight of the edge from i to j
        # L::Matrix{Float64}         # Matrix of the network variation operator (e.g. the Laplacian)
        # occlusions::Array{Array{Float64,1}} # Array of arrays containing the coordintates of occlusions
    
        # function RandomNetwork()
        #     layout = load_layout()
        #     distances = pairwise(Euclidean(), layout, dims=2)

        #     layout = DataFrame(x = layout[:,1], y = layout[:,2])
        #     nodenames = [string(i) for i in 1:size(layout,1)]

        #     new(layout, distances, nodenames)
        # end

        """
        RandomNetwork([, σ::Float64=0.25, interval::StepRange{Int64,Int64}=1:3:10])

        Generate a random network of sensors.
        """
        function RandomNetwork(;σ::T=0.25, interval=1:3:10) where T <: Real
            layout = reshape([[x + σ*randn(), y + σ*randn()] for x = interval, y = interval], length(collect(interval))^2)
            layout = [[item[1] for item in layout] [item[2] for item in layout]]
            distances = pairwise(Euclidean(), layout, dims=1)

            layout = DataFrame(x = layout[:,1], y = layout[:,2])            
            nodenames = [string(i) for i in 1:size(layout,1)]

            new(layout, distances, nodenames)
        end
    end

    include("geometry.jl")
    include("room.jl")
    include("fading.jl")

    function plot_layout(network::AbstractNetwork, room::Room; annotate::Bool=false)

        colors = get_color_palette(:auto, plot_color(:white), 1)

        plot(room)
        
        if annotate
            scatter!(network.layout[:x], network.layout[:y],
                color=colors[1],
                legend=false,
                series_annotations=network.nodenames,
                show=true)
        else
            scatter!(network.layout[:x], network.layout[:y],
                color=colors[1],
                legend=false,
                show=true)
        end
    end

    function load_layout(;file::String=joinpath(Pkg.devdir(), "WSNs.jl/data/pseudorandom_layout.jld2"))
        return load(file)["layout"]
    end
end