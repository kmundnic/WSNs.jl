# WSNs.jl
Tools for simulating wireless sensor networks (WSNs).

## Installation
This is an unregistered package. To use it, do the following (this asummes you have Julia v1.0 or newer installed).

Create a development directory for Julia, and clone the repository into that directory:

```bash
$ mkdir ~/.julia/dev
$ cd ~/.julia/dev
$ git clone git@github.com:kmundnic/WSNs.jl.git
```

Then, open your `~/.julia/config/startup.jl` file and add the following line:

```julia
push!(LOAD_PATH, expanduser("~/.julia/dev/"))
```
Then, you can open Julia and load this package with `using WSNs`.


