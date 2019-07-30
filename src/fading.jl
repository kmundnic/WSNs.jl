    """
    fading_model(d::T; np::Float64=4.0) where T <: Real

    Obtain an RSSI value (in dBm) from a distance in meters.
    """
    function fading_model(d::T; np::S=4.0) where {T <: Real, S <:Real}
        @assert d > 0 "fading_model: Distance should be > 0"
        @assert np > 0 && np ≤ 10 "fading_model: Parameter np should be in the interval (0,10]"

        P₀ = 170 # RSSI
        d₀ = 3   # meters
        P = P₀ - 10np*log10(d/d₀)

        return P > 193 ? 193 : P < 136 ? 0 : P # return P in [136,193], otherwise saturate
    end

    """
    fading_model(d::Vector{T}, np::Vector{S}) where {T <: Real, S <: Real}

    Obtain an RSSI values (in dBm) from an array of distances in meters and and an
    array of np (fading) parameters.

    This function can be used to create discontinuities in the fading model by passing different
    values for np.
    """
    function fading_model(d::Vector{T}, np::Vector{S}) where {T <: Real, S <: Real}
        @assert all(d -> d > 0,  d) "fading_model: Distance should be > 0"
        @assert all(np -> np > 0 && np ≤ 10, np) "fading_model: Parameter np should be in the interval (0,10]"
        @assert length(d) == length(np) "fading_model: d and np must have the same length"

        return [fading_model(d[i]; np=np[i]) for (i,_) in enumerate(d)]
    end

    # function fading_model(d::T, threshold::Vector{T},; np::S=2.0) where {T <: Real, S <: Real}
    #     number_of_thresholds = length(threshold)

    #     if number_of_thresholds > 1
    #     else
    #         if d < t
    #             return fading_model(d; np=2.0)
    #         else
    #             return fading_model()                
    #         end
    # end

    function fading_model(network::AbstractNetwork, room::Room; np::T=6.0) where T <: Real
        # Compute the distances from each node to all occlusions in the line of sight between two nodes
        NLOS = non_line_of_sight(network, room)

        number_of_sensors = length(network.nodenames)

        H = zeros(Float64, number_of_sensors, number_of_sensors)

        for j in 1:number_of_sensors, i in 1:number_of_sensors
            if i != j
                occlusions = count(!ismissing(NLOS[i,j,:]))
                H[i,j] = fading_model(network.distances[i,j], np=np + (occlusions*1))
            end
        end

        return H

    end
