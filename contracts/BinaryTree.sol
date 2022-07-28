// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract BinaryTree {

    int8 public constant null_value = 127;
    int8 [] public subtree;    
    uint public constant special_value = 126;
    uint count = 0;
    
    mapping (uint => uint) hash_group;

    function findSubTree(int8 [] memory data, uint pos) private view returns (int8[] memory) {

        if (pos >= data.length) 
            return new int8[](0);
        if (data[pos] == null_value) 
            return new int8[](0);

        int8[] memory l_subtree = findSubTree(data, pos * 2 + 1);
        int8[] memory r_subtree = findSubTree(data, pos * 2 + 2);
        int8[] memory ret = new int8[](1 + l_subtree.length + r_subtree.length);

        ret[0] = data[pos];
        for (uint i = 0; i < l_subtree.length; i++) 
            ret[i + 1] = l_subtree[i];
        for (uint i = 0; i < r_subtree.length; i++)
            ret[i + l_subtree.length + 1] = r_subtree[i];
        return ret;
    }

    function findMultiple(int8 [] memory data) external returns (int8[] memory) {
        count ++ ;

        while (subtree.length > 0) subtree.pop();

        uint n = data.length;
        uint m;
        for (m = 2; m - 1 < n; m *= 2){}

        -- m;

        int8 [] memory expand_data = new int8 [](m);
        for (uint i = 0; i < m; i++) {
            if (i < n) expand_data[i] = data[i];
            else expand_data[i] = null_value;
        }

        uint [] memory hash_tree = new uint[] (m);

        for (uint i = m - 1; i >= 0; i--) {
            uint id = i + 1;
            uint l_child_id = id * 2;
            uint r_child_id = id * 2 + 1;

            uint l_child_pos = l_child_id - 1;
            uint r_child_pos = r_child_id - 1;

            hash_tree[i] = uint(int256(expand_data[i]));

            if (l_child_pos < n && data[l_child_pos] != null_value) {
                hash_tree[i] = uint(keccak256(abi.encodePacked(hash_tree[i], hash_tree[l_child_pos])));
            }

            if (r_child_pos < n && data[r_child_pos] != null_value) {
                hash_tree[i] = uint(keccak256(abi.encodePacked(hash_tree[i], hash_tree[r_child_pos])));
            }

            hash_tree[i] = uint(keccak256(abi.encodePacked(hash_tree[i], count)));

            if (expand_data[i] != null_value) {
                if (hash_group[hash_tree[i]] == 1) {
                    int8[] memory cur;
                    cur = findSubTree(data, i);
                    for (uint j = 0; j < cur.length; j++) 
                        subtree.push(cur[j]);
                    subtree.push(null_value);
                }
                ++ hash_group[hash_tree[i]];   
            }

            if (i == 0) break;
        }

        return subtree;
    }
}
