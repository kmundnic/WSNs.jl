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

    include("networks.jl")
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