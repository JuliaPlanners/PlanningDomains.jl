## Download and cache management utilities ##

const CACHE_DIRS = Dict{String,String}()

"Return or create local cache directory for a remote planning repository."
function get_cache!(repo::T) where {T <: PlanningRepository}
    return get!(CACHE_DIRS, string(T)) do
        get_scratch!(@__MODULE__, string(T))
    end
end

"Clear local cache directory associated with a remote planning repository."
function clear_cache!(repo::T) where {T <: PlanningRepository}
    delete_scratch!(@__MODULE__, string(T))
    delete!(CACHE_DIRS, string(T))
    return nothing
end

"Clear all local caches of remote planning repositories."
function clear_all_caches!()
    for repo in keys(CACHE_DIRS)
        delete_scratch!(@__MODULE__, repo)
    end
    empty!(CACHE_DIRS)
    return nothing
end

"Download `src` URL to `dst` path with a fixed timeout."
function timed_download(src, dst, timeout)
    tmp_path, tmp_io = mktemp()
    @info "Downloading $src to local cache..."
    Downloads.download(src, tmp_io, timeout=timeout)
    close(tmp_io)
    mkpath(dirname(dst))
    mv(tmp_path, dst)
end

"Query a JSON endpoint if a local cache is not available."
function cached_json_query(endpoint, cache)
    if isfile(cache)
        resp = open(cache) do f
            JSON3.read(f)
        end
    else
        @info "Downloading JSON response from $endpoint..."
        json = HTTP.get(endpoint).body |> String
        resp = JSON3.read(json)
        if get(resp, "error", false)
            error(resp["message"])
        end
        open(cache, "w") do f
            write(f, json)
        end
    end
    return resp
end
