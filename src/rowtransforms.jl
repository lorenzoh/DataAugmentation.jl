"""
    NormalizeRow(dict, cols)

Normalizes the values of a row present in `TabularItem` for the columns 
specified in `cols` using `dict`, which contains the column names as 
dictionary keys and the mean and standard deviation tuple present as 
dictionary values.

## Example

```julia
using DataAugmentation

cols = [:col1, :col2, :col3]
row = (; zip(cols, [1, 2, 3])...)
item = TabularItem(row, cols)
normdict = Dict(:col1 => (1, 1), :col2 => (2, 2))

tfm = NormalizeRow(normdict, [:col1, :col2])
apply(tfm, item)
```
"""
struct NormalizeRow{T, S} <: Transform
    dict::T
    cols::S
end

function apply(tfm::NormalizeRow, item::TabularItem; randstate=nothing)
    x = NamedTuple(Iterators.map(item.columns, item.data) do col, val
        if col in tfm.cols
            colmean, colstd = tfm.dict[col]
            val = (val - colmean)/colstd
        end
        (col, val)
    end)
    TabularItem(x, item.columns)
end

"""
    FillMissing(dict, cols)

Fills the missing values of a row present in `TabularItem` for the columns 
specified in `cols` using `dict`, which contains the column names as 
dictionary keys and the value to fill the column with present as 
dictionary values.

## Example

```julia
using DataAugmentation

cols = [:col1, :col2, :col3]
row = (; zip(cols, [1, 2, 3])...)
item = TabularItem(row, cols)
fmdict = Dict(:col1 => 100, :col2 => 100)

tfm = FillMissing(fmdict, [:col1, :col2])
apply(tfm, item)
```
"""
struct FillMissing{T, S} <: Transform
    dict::T
    cols::S
end

function apply(tfm::FillMissing, item::TabularItem; randstate=nothing)
    x = NamedTuple(Iterators.map(item.columns, item.data) do col, val
        if col in tfm.cols && ismissing(val)
            val = tfm.dict[col]
        end
        (col, val)
    end)
    TabularItem(x, item.columns)
end

"""
    Categorify(dict, cols)

Label encodes the values of a row present in `TabularItem` for the 
columns specified in `cols` using `dict`, which contains the column 
names as dictionary keys and the unique values of column present 
as dictionary values.

if there are any `missing` values in the values to be transformed, 
they are replaced by 1.

## Example

```julia
using DataAugmentation

cols = [:col1, :col2, :col3]
row = (; zip(cols, ["cat", 2, 3])...)
item = TabularItem(row, cols)
catdict = Dict(:col1 => ["dog", "cat"])

tfm = Categorify(catdict, [:col1])
apply(tfm, item)
```
"""
struct Categorify{T, S} <: Transform
    dict::T
    cols::S
    function Categorify{T, S}(dict::T, cols::S) where {T, S}
        for (col, vals) in dict
            if any(ismissing, vals)
                dict[col] = filter(!ismissing, vals)
                @warn "There is a missing value present for category '$col' which will be removed from Categorify dict"
            end
        end
        new{T, S}(dict, cols)
    end
end

Categorify(dict::T, cols::S) where {T, S} = Categorify{T, S}(dict, cols)

function apply(tfm::Categorify, item::TabularItem; randstate=nothing)
    x = NamedTuple(Iterators.map(item.columns, item.data) do col, val
        if col in tfm.cols
            val = ismissing(val) ? 1 : findfirst(val .== tfm.dict[col]) + 1
        end
        (col, val)
    end)
    TabularItem(x, item.columns)
end
