using Plots
using Random
using Distances
using DataFrames
using Distributions
using LinearAlgebra

using WSNs

room = WSNs.Room() # create an empty room with three wals
network = WSNs.RandomNetwork(interval=)

WSNs.plot_layout(network, room; annotate=true)

NLOS = WSNs.non_line_of_sight(network, room)

H = WSNs.fading_model(network, room)
heatmap(H)