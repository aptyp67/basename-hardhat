// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Watchlist {
    event Watchlisted(address indexed user, bytes32 indexed namehash);
    event Unwatchlisted(address indexed user, bytes32 indexed namehash);

    mapping(address => mapping(bytes32 => bool)) private _watching;
    mapping(address => uint256) public watchCount;

    function watch(bytes32 namehash) external {
        if (_watching[msg.sender][namehash]) return;
        _watching[msg.sender][namehash] = true;
        unchecked { watchCount[msg.sender] += 1; }
        emit Watchlisted(msg.sender, namehash);
    }

    function unwatch(bytes32 namehash) external {
        if (!_watching[msg.sender][namehash]) return;
        _watching[msg.sender][namehash] = false;
        unchecked { watchCount[msg.sender] -= 1; }
        emit Unwatchlisted(msg.sender, namehash);
    }

    function isWatching(address user, bytes32 namehash) external view returns (bool) {
        return _watching[user][namehash];
    }
}
