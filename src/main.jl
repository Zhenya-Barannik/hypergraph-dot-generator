##
using SimpleDirectedHypergraphs
using SimpleHypergraphs

##
CODE_DIR = @__DIR__
TEMPLATE_FILENAME = joinpath(CODE_DIR, "template.dot")
DOT_FILENAME = joinpath(CODE_DIR, "hg.dot")
SVG_FILENAME = joinpath(CODE_DIR, "hg.svg")

## Hypegraph preparation 
Base.run(`clear`)
vertices_names = ["M", "N", "P", "Q", "T", "U", "X"]

vertices_num = length(vertices_names)
dh1 = DirectedHypergraph{Int, String}(vertices_num, 0)
dh1.v_meta[1: vertices_num] = vertices_names 
name_to_id = Dict(name => id for (id, name) in enumerate(dh1.v_meta))
id_to_name = Dict(id => name for (id, name) in enumerate(dh1.v_meta))
add_hyperedge!(
    dh1;
    vertices_tail=Dict(name_to_id["M"] => 1, name_to_id["N"] => 1),
    vertices_head=Dict(name_to_id["P"] => 1, name_to_id["Q"] => 1)
)

add_hyperedge!(
    dh1;
    vertices_tail=Dict(name_to_id["M"] => 1, name_to_id["P"] => 1),
    vertices_head=Dict(name_to_id["T"] => 1)
)

add_hyperedge!(
    dh1;
    vertices_tail=Dict(name_to_id["Q"] => 2),
    vertices_head=Dict(name_to_id["U"] => 1)
)

add_hyperedge!(
    dh1;
    vertices_tail=Dict(name_to_id["U"] => 1, name_to_id["T"] => 2),
    vertices_head=Dict(name_to_id["X"] => 1)
)
 
## DOT preparation
vertices_string = join(dh1.v_meta, " ")
edges_multiline_string = " "
edges_num_read = size(dh1)[2]

for edge_id in 1:edges_num_read
    global edges_multiline_string
    edge_tail = dh1.hg_tail.he2v[edge_id]
    edge_tail_string = join((id_to_name[id] for id in keys(edge_tail)), " ")
    edge_head = dh1.hg_head.he2v[edge_id]
    edge_head_string = join((id_to_name[id] for id in keys(edge_head)), " ")
    edges_block = """
    $edge_id [xlabel=" $edge_id ", fontname="Impact", fontcolor="Grey"];
    {$edge_tail_string} -> $edge_id [dir=none];
    $edge_id -> {$edge_head_string};\n
    """
    edges_multiline_string = edges_multiline_string * edges_block
end

raw_template = read(TEMPLATE_FILENAME, String)
final_dot = replace(raw_template, "{{vertices_string}}" => vertices_string)
final_dot = replace(final_dot, "{{edges_multiline_string}}" => edges_multiline_string)

open(DOT_FILENAME, "w") do io
    write(io, final_dot)
end

## SVG creation
run(`neato -Tsvg $DOT_FILENAME -o $SVG_FILENAME`)
run(`open -g $SVG_FILENAME`)
##
