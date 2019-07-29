using Plots
using Random
using Distances
using DataFrames
using Distributions

using WSNs

room = WSNs.Room() # create an empty room with three wals
network = WSNs.RandomNetwork()

WSNs.plot_layout(network, room; annotate=true)

D = WSNs.non_line_of_sight(network, room)