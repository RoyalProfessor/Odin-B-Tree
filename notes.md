# B-Trees


## Inserting into the tree

### States

There are two states when comparing the new value to existing values in a node:
- No children
- Children

### Behavior
When inserting a new value into the tree, the new value is compared to the existing values in the node, starting at the root node.

#### Behavior when no children
- After comparison, the new value is inserted at the point where the ascending sort of the list is maintained.

#### Behavior when children
- After comparison, the appropriate child node is found and the set of behaviors begins again.


## Splitting a node

### States
Nodes has several states during splitting:
- Parent
    - No children
    - Has children
- No Parent
    - No children
    - Has children

### Behavior
#### Behavior when splitting with no children:
- The middle key-value in the list is added to the parent node, then sorted from lowest to highest.
- The key-values that are higher than the middle key-value is put into a new node, and the new node is then added as a child to the parent node.
- Parent node's children are then sorted from lowest to highest.

#### Behavior when splitting with children:
- Same as with no children
- The second half of children of the split node will be assigned to the new node.

#### Behavior when splitting with no parent:
- Create a new node and assign as a parent node to the splitting node.
- Same as with no children.

## Node Memory Tracking
- All nodes are in an array in the tree struct.
- Nodes contain an array of indexes that point to their children in the node pool.


## Deleting a value from the tree

- Traverses the tree to find the node that contains the value.
- Deletes the value from the node.
- Checks if the node needs to merge.
- Merges node with adjacent node if required.


## Merging nodes

### States of the node

States of the node when merging:
    - No children
    - Children

States of the adjacent node when merging:
    - Not at capacity
    - At capacity

### Behavior

#### Behavior of the node when no children
- The remaining values in the node are added to the adjacent node.

#### Behavior of the node when there are children