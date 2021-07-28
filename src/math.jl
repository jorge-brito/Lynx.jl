"""
        mapr(t, a, b, c, d) -> Real

Maps the value `t` from the interval `[a, b]` to `[c, d]`
"""
function mapr(t::Real, a::Real, b::Real, c::Real, d::Real)
    return c + ((d - c) / (b - a)) * (t - a)
end
"""
        mapr(t, a, b) -> Real

Maps the value `t` from the interval `[0, 1]` to `[a, b]`
"""
mapr(t::Real, a::Real, b::Real) = mapr(t, 0, 1, a, b)
mapr(t::Real, (a, b)::Tuple, (c, d)::Tuple) = mapr(t, a, b, c, d)
mapr(t::Real, (a, b)::Tuple) = mapr(t, a, b)
mapr(t::Real, A::AbstractRange, B::AbstractRange) = mapr(t, extrema(A), extrema(B))
mapr(t::Real, A::AbstractRange) = mapr(t, extrema(A))