# Sisu calendar synchronization

A simple script to filter out unwanted events from a sisu export. Mostly useful with calendar applications that don't know how to 
update themselves automatically from an url.

## Usage

Add the source url from Sisu to a file named `link.url` in the current directory and run
```sh
julia
> include("src/sisu_calendar_sync.jl")
> sisu_calendar_sync.main()
```
