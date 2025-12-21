package tests

// Import
import main "../"
import "core:testing"
import "core:fmt"
import "core:log"


@(test)
insert_value_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[0], 308)

    main.delete_tree(&tree)
}

@(test)
insert_multiple_values_into_tree_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[0], 308)
    
    ok = main.insert_entry_into_tree(660, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[1], 660)

    main.delete_tree(&tree)
}

@(test)
insert_existing_value_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[0], 308)
    
    ok = main.insert_entry_into_tree(660, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[1], 660)

    ok = main.insert_entry_into_tree(660, &tree)
    testing.expect_value(t, ok, false)
    testing.expect_value(t, len(tree.nodes[0].values), 2)

    main.delete_tree(&tree)
}

@(test)
split_node_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    ok = main.insert_entry_into_tree(660, &tree)
    ok = main.insert_entry_into_tree(375, &tree)
    ok = main.insert_entry_into_tree(227, &tree)
    ok = main.insert_entry_into_tree(651, &tree)
    testing.expect_value(t, ok, true)
    testing.expect_value(t, tree.nodes[0].values[0], 227)
    testing.expect_value(t, tree.nodes[0].values[1], 308)
    testing.expect_value(t, tree.nodes[1].values[0], 651)
    testing.expect_value(t, tree.nodes[1].values[1], 660)
    testing.expect_value(t, tree.nodes[2].values[0], 375)
    testing.expect_value(t, len(tree.nodes), 3)

    main.delete_tree(&tree)
}

@(test)
split_node_multiple_test :: proc(t: ^testing.T) {
    node : main.Node
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    ok = main.insert_entry_into_tree(660, &tree)
    ok = main.insert_entry_into_tree(375, &tree)
    ok = main.insert_entry_into_tree(227, &tree)
    ok = main.insert_entry_into_tree(651, &tree)
    ok = main.insert_entry_into_tree(24, &tree)
    ok = main.insert_entry_into_tree(597, &tree)
    ok = main.insert_entry_into_tree(38, &tree)
    ok = main.insert_entry_into_tree(922, &tree)
    ok = main.insert_entry_into_tree(949, &tree)
    testing.expect_value(t, len(tree.nodes), 4)
    node = tree.nodes[tree.parent]
    testing.expect_value(t, node.values[0], 375)
    testing.expect_value(t, node.values[1], 660)
    node = tree.nodes[tree.nodes[tree.parent].children[0]]
    testing.expect_value(t, node.values[0], 24)
    testing.expect_value(t, node.values[1], 38)
    testing.expect_value(t, node.values[2], 227)
    testing.expect_value(t, node.values[3], 308)
    node = tree.nodes[tree.nodes[tree.parent].children[1]]
    testing.expect_value(t, node.values[0], 597)
    testing.expect_value(t, node.values[1], 651)
    node = tree.nodes[tree.nodes[tree.parent].children[2]]
    testing.expect_value(t, node.values[0], 922)
    testing.expect_value(t, node.values[1], 949)

    main.delete_tree(&tree)
}

// @(test)
// split_node_three_levels :: proc(t: ^testing.T) {
//     node : main.Node
//     tree := main.create_tree(4)
//     ok := main.insert_entry_into_tree(308, &tree)
//     ok = main.insert_entry_into_tree(660, &tree)
//     ok = main.insert_entry_into_tree(375, &tree)
//     ok = main.insert_entry_into_tree(227, &tree)
//     ok = main.insert_entry_into_tree(651, &tree)
//     ok = main.insert_entry_into_tree(24, &tree)
//     ok = main.insert_entry_into_tree(597, &tree)
//     ok = main.insert_entry_into_tree(38, &tree)
//     ok = main.insert_entry_into_tree(922, &tree)
//     ok = main.insert_entry_into_tree(949, &tree)
//     ok = main.insert_entry_into_tree(179, &tree)
//     ok = main.insert_entry_into_tree(702, &tree)
//     ok = main.insert_entry_into_tree(62, &tree)
//     ok = main.insert_entry_into_tree(245, &tree)
//     ok = main.insert_entry_into_tree(440, &tree)
//     ok = main.insert_entry_into_tree(813, &tree)
//     ok = main.insert_entry_into_tree(124, &tree)
//     ok = main.insert_entry_into_tree(58, &tree)
//     ok = main.insert_entry_into_tree(885, &tree)

//     main.delete_tree(&tree)
// }

@(test)
find_value_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    ok = main.insert_entry_into_tree(660, &tree)
    ok = main.insert_entry_into_tree(375, &tree)
    ok = main.insert_entry_into_tree(227, &tree)
    ok = main.insert_entry_into_tree(651, &tree)
    node_i, found := main.find_value_in_tree(375, tree)
    testing.expect_value(t, found, true)
    testing.expect_value(t, 2, node_i)
    node_i, found = main.find_value_in_tree(660, tree)
    testing.expect_value(t, found, true)
    testing.expect_value(t, 1, node_i)

    main.delete_tree(&tree)
}

@(test)
find_no_value_test :: proc(t: ^testing.T) {
    tree := main.create_tree(4)
    ok := main.insert_entry_into_tree(308, &tree)
    ok = main.insert_entry_into_tree(660, &tree)
    ok = main.insert_entry_into_tree(375, &tree)
    ok = main.insert_entry_into_tree(227, &tree)
    ok = main.insert_entry_into_tree(651, &tree)
    node_i, found := main.find_value_in_tree(999, tree)
    testing.expect_value(t, found, false)
    testing.expect_value(t, -1, node_i)

    main.delete_tree(&tree)
}