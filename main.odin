package main

// Imports
import "core:fmt"
import "core:slice"

main :: proc() {
    
    tree := create_tree(4)
    ok := insert_entry_into_tree(308, &tree)
    ok = insert_entry_into_tree(660, &tree)
    ok = insert_entry_into_tree(375, &tree)
    ok = insert_entry_into_tree(227, &tree)
    ok = insert_entry_into_tree(651, &tree)
    ok = insert_entry_into_tree(24, &tree)
    ok = insert_entry_into_tree(597, &tree)
    ok = insert_entry_into_tree(38, &tree)
    ok = insert_entry_into_tree(922, &tree)
    ok = insert_entry_into_tree(949, &tree)
    ok = insert_entry_into_tree(179, &tree)
    ok = insert_entry_into_tree(702, &tree)
    ok = insert_entry_into_tree(62, &tree)
    ok = insert_entry_into_tree(245, &tree)
    ok = insert_entry_into_tree(440, &tree)
    ok = insert_entry_into_tree(813, &tree)
    ok = insert_entry_into_tree(124, &tree)
    ok = insert_entry_into_tree(58, &tree)
    ok = insert_entry_into_tree(885, &tree)
    // fmt.println(ok)
    print_tree(tree)
    // fmt.println(tree)
}

B_Tree :: struct {
    parent : int,
    size : int,
    generation : int,
    nodes : [dynamic]Node,
    deleted : [dynamic]int
}

Node :: struct {
    id : int,
    parent: int,
    size : int,
    values : [dynamic]int,
    children : [dynamic]int
}

create_tree :: proc(size: int) -> (tree: B_Tree) {
    node := Node{}
    node.size, tree.size = size, size
    node.id = 0
    node.parent = -1
    reserve(&node.values, size)
    reserve(&node.children, size)
    tree.parent = 0
    tree.generation = 1
    append(&tree.nodes, node)
    return
}

create_node_raw :: proc(size: int) -> (node: Node) {
    node.size = size
    return
}

create_node_tree :: proc(tree: ^B_Tree) -> (node_i: int) {
    node_i = -1
    node := Node{}
    node.size = tree.size
    node.id = tree.generation
    tree.generation += 1
    if len(tree.deleted) > 0 {
        assign_at(&tree.nodes, tree.deleted[0])
        node_i = tree.deleted[0]
        unordered_remove(&tree.deleted, 0)
    } else {
        append(&tree.nodes, node)
        node_i = len(tree.nodes)-1
    }
    return
}
create_node :: proc{create_node_raw, create_node_tree}

insert_entry_into_tree :: proc(value: int, tree: ^B_Tree) -> (bool) {
    node_i, ok := insert_entry_into_node(value, tree.parent, tree)
    if check_node_balance(tree.nodes[node_i]) == .Overflow {
        split_node(node_i, tree)
    }
    return ok
}

insert_entry_into_node :: proc(value, node_i: int, tree: ^B_Tree) -> (inserted_node: int, ok: bool) {
    inserted_node = node_i
    node := &tree.nodes[node_i]
    if len(node.children) > 0 {
        for i in 0..<len(node.values) {
            if value < node.values[i] {
                inserted_node, ok = insert_entry_into_node(value, node.children[i], tree)
                return
            } 
            else if value > node.values[i] && i == len(node.values)-1 {
                inserted_node, ok = insert_entry_into_node(value, node.children[i+1], tree)
                return
            }
        }
        return inserted_node, false
    } else {
        if len(node.values) == 0 {
            append(&node.values, value)
            return inserted_node, true
        }
        for i in 0..<len(node.values) {
            if value < node.values[i] {
                inject_at(&node.values, i, value)
                return inserted_node, true
            }
            else if value > node.values[i] && len(node.values) == i+1 {
                append(&node.values, value)
                return inserted_node, true
            }
            else if value == node.values[i] {
                return inserted_node, false
            }
        }
    }
    return -1, false
}

split_node :: proc(node_i: int, tree: ^B_Tree) {
    new_node_i := create_node(tree)
    if tree.nodes[node_i].parent == -1 {
        parent_node_i := create_node(tree)
        tree.nodes[parent_node_i].parent = -1
        tree.parent = parent_node_i
        tree.nodes[node_i].parent = parent_node_i
    }
    node := &tree.nodes[node_i]
    new_node := &tree.nodes[new_node_i]
    parent := &tree.nodes[node.parent]
    new_node.parent = node.parent
    v_index := (len(node.values) / 2)
    append(&parent.values, node.values[v_index])
    slice.sort(parent.values[:])
    append(&new_node.values, ..node.values[v_index+1:])
    resize(&node.values, v_index)
    
    if !slice.contains(parent.children[:], node_i) {
        append(&parent.children, node_i)
    }
    if !slice.contains(parent.children[:], new_node_i) {
        append(&parent.children, new_node_i)
    }
    sort_children(parent, tree)

    if len(node.children) > 1 {
        child_index := len(node.children)/2
        append(&new_node.children, ..node.children[child_index:])
        for i in 0..<len(new_node.children) {
            tree.nodes[new_node.children[i]].parent = new_node_i
        }
        sort_children(new_node, tree)
        resize(&node.children, child_index)
    }

    if check_node_balance(parent^) == .Overflow {
        split_node(node.parent, tree)
    }
}

sort_children :: proc(node: ^Node, tree: ^B_Tree) {
    if len(node.children) == 0 || len(node.children) == 1 {
        return
    }
    
    Vector2 :: [2]int
    total : int
    finished : bool
    averages : [dynamic][2]int; defer delete(averages)
    new_children : [dynamic]int
    if len(node.children) > 0 {
        for i in 0..<len(node.children) {
            total = 0
            child_node := &tree.nodes[node.children[i]]
            for k in 0..<len(child_node.values) {
                total += child_node.values[k]
            }
            total = total / len(child_node.values)
            append(&averages, Vector2{i, total})
        }
    }
    for finished == false{
        finished = true
        for i in 0..<len(averages)-1 {
            if averages[i].y > averages[i+1].y {
                averages[i], averages[i+1] = averages[i+1], averages[i]
                finished = false
            } 
        }
    }
    for i in 0..<len(averages) {
        append(&new_children, node.children[averages[i].x])
    }
    delete(node.children)
    node.children = new_children
}

find_value_in_tree :: proc(value: int, tree: B_Tree) -> (node_i: int, found: bool) {
    node_i, found = find_node_from_value(value, tree.nodes[tree.parent], tree)
    return
}

find_node_from_value :: proc(value: int, node: Node, tree: B_Tree) -> (node_i: int, found: bool) {
    value_i : int
    node_i = -1
    value_i, found = find_value_in_node(value, node)
    if found {
        if node.parent >= 0 {
            parent := tree.nodes[node.parent]
            for i in 0..<len(parent.children) {
                if tree.nodes[parent.children[i]].id == node.id {
                    node_i = tree.nodes[node.parent].children[i]
                    return 
                }
            }
        } else {
            for i in 0..<len(tree.nodes) {
                if tree.nodes[i].id == node.id {
                    node_i = i
                    return
                }
            }
        }    
    } else {
        for i in 0..<len(node.children) {
            node_i, found = find_node_from_value(value, tree.nodes[node.children[i]], tree)
            if found {
                return
            }
        }
    }
    return
}

find_value_in_node :: proc(value: int, node: Node) -> (index: int, found: bool){
    for i in 0..<len(node.values) {
        if node.values[i] == value {
            return i, true
        }
    }
    return -1, false
}

delete_tree :: proc(tree: ^B_Tree) {
    for i in tree.nodes {
        delete(i.values)
        delete(i.children)
    }
    delete(tree.nodes)
}

delete_entry_from_tree :: proc(value: int, tree: ^B_Tree) -> (ok: bool) {
    rebalance, split : Node_Balance
    node_i, found := find_value_in_tree(value, tree^)
    node := &tree.nodes[node_i]
    parent := &tree.nodes[node.parent]
    node_child_i, found2 := slice.linear_search(tree.nodes[node.parent].children[:], node_i)
    adjacent_i := find_adjacent_child(node_i, tree)
    target_i := tree.nodes[node.parent].children[adjacent_i]
    target := &tree.nodes[target_i]
    value_i := cap_index(node_child_i, len(parent.values)-1)

    if found {
        delete_value_from_node(value, node_i, tree)
        ok = true
    } else {
        return false
    }
    rebalance = check_node_balance(node^)
    if rebalance == .Underflow {        
        migrate_to_node(node_i, target_i, tree)
        append(&target.values, parent.values[value_i])
        slice.sort(target.values[:])
        ordered_remove(&parent.values, value_i)
        delete_node(node_i, tree)
        split = check_node_balance(target^)
        if split == .Overflow {
            split_node(target_i, tree)
        }
    }
    return ok
}

delete_value_from_node :: proc(value, node_i: int, tree: ^B_Tree) -> (ok: bool) {
    node := &tree.nodes[node_i]
    value_i, found := find_value_in_node(value, node^)
    if found { 
        ordered_remove(&node.values, value_i)
        return true
    }
    return false
}

delete_node :: proc(node_i: int, tree: ^B_Tree) {
    node := &tree.nodes[node_i]
    parent := &tree.nodes[node.parent]
    for i in 0..<len(parent.children) {
        if parent.children[i] == node_i {
            ordered_remove(&parent.children, i)
        }
    }
    append(&tree.deleted, node_i)
    clear(&node.values)
    clear(&node.children)
}

Node_Balance :: enum {
    Underflow,
    Overflow,
    Balanced
}

check_node_balance :: proc(node: Node) -> (Node_Balance) {
    if len(node.values) < node.size/2 {
        return .Underflow
    }
    if len(node.values) > node.size {
        return .Overflow
    }
    return .Balanced
}

migrate_to_node :: proc(origin_i, target_i: int, tree: ^B_Tree) {
    origin_node := &tree.nodes[origin_i]
    target_node := &tree.nodes[target_i]
    append(&target_node.values, ..origin_node.values[:])
    append(&target_node.children, ..origin_node.children[:])
    slice.sort(target_node.values[:])
    if len(target_node.children) > 0 {
        sort_children(target_node, tree)
    }
    clear(&origin_node.values)
    clear(&origin_node.children)
}

print_tree :: proc(tree: B_Tree) {
    fmt.println(tree.nodes[tree.parent])
    print_node_children(tree.nodes[tree.parent], tree)
}

print_node_children :: proc(node: Node, tree: B_Tree) {
    for i in 0..<len(node.children) {
        fmt.print(tree.nodes[node.children[i]])
    }
    if len(node.children) > 0 {
        for i in node.children {
            print_node_children(tree.nodes[i], tree)
        }
    }
}

find_adjacent_child :: proc(node_i: int, tree: ^B_Tree) -> (adjacent_i: int) {
    node := tree.nodes[node_i]
    parent := tree.nodes[node.parent]
    index : int
    for i in 0..<len(parent.children) {
        if parent.children[i] == node_i {
            index = i
        }
    }
    if (index+1) >= len(parent.children) {
        index -= 1
    } else {
        index += 1
    }
    adjacent_i = index
    return
}

index_add_nocap :: proc(index, offset: int) -> (new_index: int) {
    new_index = index + offset
    if new_index < 0 {
        new_index = 0
    }
    return
}

index_add_cap :: proc(index, offset, cap: int) -> (new_index: int) {
    new_index = index + offset
    if new_index < 0 {
        new_index = 0
    }
    if new_index > cap {
        new_index = cap
    }
    return
}
index_add :: proc{index_add_nocap, index_add_cap}

cap_index :: proc(index, cap: int) -> (new_index: int)  {
    new_index = index
    if index > cap {
        new_index = cap
    }
    return
}