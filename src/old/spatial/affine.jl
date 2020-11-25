



"""
    abstract type AbstractAffine <: Transform

Abstract supertype for affine transformations.

## Interface

An `AbstractAffine` transform "`T`" has to implement:

- [`getaffine`](#)`(tfm::T, getbounds(item), getrandstate(tfm))`

To be able to apply affine transformations an `Item` type `I` must
implement:

- [`getbounds`](#)`(item::MyItem)` returns the spatial bounds of an item,
  e.g. `size(img)` for an image array
- `applyaffine(item::MyItem, A)::MyItem` applies transformation matrix `A`
  (constructed with `getaffine`) to `item` and returns an item of the same
  type
"""
abstract type AbstractAffine <: Transform end


"""
    getaffine(tfm, bounds, randstate)

Return an affine transformation matrix, see
[CoordinateTransformations.jl](https://github.com/JuliaGeometry/CoordinateTransformations.jl).

Takes into account the `bounds` of the item it is applied to as well
as the `tfm`'s `randstate`.
"""
function getaffine end


"""

"""
function getbounds() end

getbounds(item::Image) = item.bounds
getbounds(item::Keypoints) = item.bounds
getbounds(item::MaskMulti) = item.bounds
getbounds(item::MaskBinary) = item.bounds
getbounds(wrapper::ItemWrapper) = getbounds(getwrapped(wrapper))
getbounds(a::AbstractMatrix) = makebounds(size(a))

affinetype(item) = Float32
affinetype(keypoints::Keypoints{N, T}) where {N, T} = T

function apply(tfm::AbstractAffine, item::Item; randstate=getrandstate(tfm))
    A = getaffine(tfm, getbounds(item), randstate, affinetype(item))
    return applyaffine(item, A)
end

"""
    applyaffine(item, A[, crop])

Applies affine transformation `A` to `item`, optionally cropping
to index ranges `crop`.
"""
function applyaffine end


"""
    applyaffine!(dstitem::I, item::I, A[, crop])

Applies affine transformation `A` to `item` inplace, optionally cropping
to index ranges `crop` and saving the result directly to `dstitem`.

If inplace transformation is not supported for item type `I`, defaults
to non-inplace version `applyaffine(item, A, crop)`.
"""
function applyaffine!(dstitem, item, A, crop = nothing)
    return applyaffine(item, A, crop)
end

# Image implementation

function applyaffine(item::Image{N, T}, A, crop=nothing) where {N, T}
    if crop isa Tuple
        newdata = warp(itemdata(item), inv(A), crop, Reflect())
        return Image(newdata)
    else
        newdata = warp(itemdata(item), inv(A), zero(T))
        newbounds = A.(getbounds(item))
        return Image(newdata, newbounds)
    end
end


# Keypoints implementation

function applyaffine(keypoints::Keypoints{N, T}, A, crop = nothing) where {N, T}
    if isnothing(crop)
        newbounds = A.(getbounds(keypoints))
    else
        newbounds = makebounds(length.(crop), T)
    end
    return Keypoints(
        mapmaybe(A, keypoints.data),
        newbounds
    )
end


function applyaffine(mask::MaskMulti, A, crop = nothing)
    a = itemdata(mask)
    etp = mask_extrapolation(a)
    if crop isa Tuple
        a_ = warp(etp, inv(A), crop)
        return MaskMulti(a_, mask.classes)
    else
        a_ = warp(etp, inv(A))
        bounds_ = A.(getbounds(mask))
        return MaskMulti(a_, mask.classes, bounds_)
    end
end


function applyaffine(mask::MaskBinary, A, crop = nothing)
    a = itemdata(mask)
    etp = mask_extrapolation(a)
    if crop isa Tuple
        a_ = warp(etp, inv(A), crop)
        return MaskBinary(a_)
    else
        a_ = warp(etp, inv(A))
        bounds_ = A.(getbounds(mask))
        return MaskBinary(a_, bounds_)
    end
end

function mask_extrapolation(
        mask::AbstractArray{T};
        degree = Constant(),
        boundary = Flat()) where T
    itp = interpolate(T, T, mask, BSpline(degree))
    etp = extrapolate(itp, Flat())
    return etp
end


# ## `Transform`s

struct Affine <: AbstractAffine
    A
end

getaffine(tfm::Affine, bounds, randstate, T = Float32) = tfm.A




"""
    ComposedAffine(transforms)

Composes several affine transformations.

Due to associativity of affine transformations, the transforms can be
combined before applying, leading to large performance improvements.

`compose`ing multiple `AbstractAffine`s automatically
creates a `ComposedAffine`.
"""
struct ComposedAffine <: AbstractAffine
    transforms::NTuple{N,AbstractAffine} where N
end

getrandstate(composed::ComposedAffine) = getrandstate.(composed.transforms)


function getaffine(composed::ComposedAffine, bounds, randstate, T = Float32)
    A_all = IdentityTransformation()
    for (tfm, r) in zip(composed.transforms, randstate)
        A = getaffine(tfm, bounds, r, T)
        bounds = A.(bounds)
        A_all = A ∘ A_all
    end
    return A_all
end

compose(tfm1::AbstractAffine, tfm2::AbstractAffine) =
    ComposedAffine((tfm1, tfm2))
compose(cat::ComposedAffine, tfm::AbstractAffine) =
    ComposedAffine((cat.transforms..., tfm))
compose(tfm::AbstractAffine, cat::ComposedAffine) =
    ComposedAffine((tfm, cat.transforms))



mapmaybe(f, a) = map(x -> isnothing(x) ? nothing : f(x), a)
mapmaybe!(f, dest, a) = map!(x -> isnothing(x) ? nothing : f(x), dest, a)