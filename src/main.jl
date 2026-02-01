##
using SimpleDirectedHypergraphs
using SimpleHypergraphs

##
PROJECT_DIR = dirname(Base.active_project())
DOT_FILENAME = joinpath(PROJECT_DIR, "hg.dot")
SVG_FILENAME = joinpath(PROJECT_DIR, "hg.svg")

EDGE_BLOCK_TEMPLATE(edge_id, tails, heads) = """
    $edge_id [xlabel=" $edge_id ", fontname="Impact", fontcolor="Grey"];
    {$tails} -> $edge_id [dir=none];
    $edge_id -> {$heads};\n
    """
GLOBAL_DOT_TEMPLATE(vertices, edges) = """
    digraph hypergraph {
    splines=curved;

    // Vertices
    node [shape = circle]; $vertices;
    node [width = 0, label = ""];

    // Hyperedges
    $edges
    }
    """

function prepare_dot(dhg)
    vertices_string = join(dhg.v_meta, " ")
    edges_multiline_string = ""
    edges_num_read = size(dhg)[2]
    id_to_name = Dict(id => name for (id, name) in enumerate(dhg.v_meta))
    for edge_id in 1:edges_num_read
	edge_tail = dhg.hg_tail.he2v[edge_id]
	edge_tail_string = join((id_to_name[id] for id in keys(edge_tail)), " ")
	edge_head = dhg.hg_head.he2v[edge_id]
	edge_head_string = join((id_to_name[id] for id in keys(edge_head)), " ")
	edges_multiline_string = edges_multiline_string * EDGE_BLOCK_TEMPLATE(edge_id, edge_tail_string, edge_head_string)
    end
    final_dot = GLOBAL_DOT_TEMPLATE(vertices_string, edges_multiline_string)
    open(DOT_FILENAME, "w") do io
	write(io, final_dot)
    end
end

function prepare_test_dhg()
    vertices_labels = ["M", "N", "P", "Q", "T", "U", "X"]
    vertices_num = length(vertices_labels)
    dhg = DirectedHypergraph{Int, String}(vertices_num, 0)
    dhg.v_meta[1: vertices_num] = vertices_labels 
    name_to_id = Dict(name => id for (id, name) in enumerate(dhg.v_meta))
    add_hyperedge!(
    dhg;
    vertices_tail=Dict(name_to_id["M"] => 1, name_to_id["N"] => 1),
    vertices_head=Dict(name_to_id["P"] => 1, name_to_id["Q"] => 1)
    )

    add_hyperedge!(
    dhg;
    vertices_tail=Dict(name_to_id["M"] => 1, name_to_id["P"] => 1),
    vertices_head=Dict(name_to_id["T"] => 1)
    )

    add_hyperedge!(
    dhg;
    vertices_tail=Dict(name_to_id["Q"] => 2),
    vertices_head=Dict(name_to_id["U"] => 1)
    )

    add_hyperedge!(
    dhg;
    vertices_tail=Dict(name_to_id["U"] => 1, name_to_id["T"] => 2),
    vertices_head=Dict(name_to_id["X"] => 1)
    )
    return dhg
end

##
dhg = prepare_test_dhg()
prepare_dot(dhg)
run(`neato -Tsvg $DOT_FILENAME -o $SVG_FILENAME`)
run(`open $SVG_FILENAME`)
