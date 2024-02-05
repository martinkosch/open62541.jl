using SafeTestsets
using Test

@safetestset "Aqua" begin
    include("aqua.jl")
end

@safetestset "Statuscodes" begin
    include("statuscodes.jl")
end

@safetestset "Exceptions" begin
    include("exceptions.jl")
end

@safetestset "Callback generators" begin
    include("callbacks.jl")
end

@safetestset "Basic types and functions" begin
    include("basic_types_and_functions.jl")
end

@safetestset "Basic data handling" begin
    include("data_handling.jl")
end

@safetestset "NodeIds" begin
    include("nodeids.jl")
end

@safetestset "Attribute generation" begin
    include("attribute_generation.jl")
end

@safetestset "Server configurations" begin
    include("server_config.jl")
end

@safetestset "Server Read Functions" begin
    include("server_read.jl")
end

@safetestset "Server Write Functions" begin
    include("server_write.jl")
end

@safetestset "Server Add Nodes" begin
    include("server_add_nodes.jl")
end

@safetestset "Memory leaks" begin
    include("memoryleaks.jl")
end

#Testsets below here use Distributed; normal testsets required
# !!! Leakage of variables must be assessed manually. !!!
#see: https://github.com/YingboMa/SafeTestsets.jl/issues/13
@testset "Simple Server/Client" begin
    include("simple_server_client.jl")
end

@testset "Add, read, change scalar variables" begin
    include("add_change_var_scalar.jl")
end

@testset "Add, read, change array variables" begin
    include("add_change_var_array.jl")
end

@testset "Username/password login & access control" begin
    include("username_password_login_accesscontrol.jl")
end
