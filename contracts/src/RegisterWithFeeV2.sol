// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBasenameRegistrarV2 {
    struct RegisterRequest {
        string name;
        address owner;
        uint256 duration;
        address resolver;
        bytes[] data;
        bool reverseRecord;
    }
    function available(string calldata name) external view returns (bool);
    function rentPrice(string calldata name, uint256 duration) external view returns (uint256);
    function register(RegisterRequest calldata request) external payable;
}

abstract contract NonReentrant {
    uint256 private _entered;
    modifier nonReentrant() {
        require(_entered == 0, "REENTRANCY");
        _entered = 1; _;
        _entered = 0;
    }
}

contract RegisterWithFeeV2 is NonReentrant {
    address public immutable registrar;
    address payable public immutable feeRecipient;
    uint96  public immutable feeBps;

    event RegisterIntent(address indexed caller, string name, address indexed owner, uint256 duration, uint256 registrarValue, uint256 feeValue);
    event Registered(string name, address indexed owner, uint256 duration, uint256 registrarValue, uint256 feeValue);

    error BadMsgValue();
    error BadParams();
    error FeeTransferFailed();

    constructor(address _registrar, address payable _feeRecipient, uint96 _feeBps) {
        require(_registrar != address(0) && _feeRecipient != address(0), "ZERO_ADDR");
        require(_feeBps <= 1000, "FEE_TOO_HIGH");
        registrar = _registrar;
        feeRecipient = _feeRecipient;
        feeBps = _feeBps;
    }

    function computeFee(uint256 totalValue) public view returns (uint256) {
        return (totalValue * feeBps) / 10_000;
    }

    function registerWithFee(
        IBasenameRegistrarV2.RegisterRequest calldata req,
        uint256 registrarValue
    ) external payable nonReentrant {
        if (req.duration == 0 || registrarValue == 0) revert BadParams();
        uint256 fee = computeFee(msg.value);
        if (msg.value != registrarValue + fee) revert BadMsgValue();

        emit RegisterIntent(msg.sender, req.name, req.owner, req.duration, registrarValue, fee);

        (bool okFee, ) = feeRecipient.call{value: fee}("");
        if (!okFee) revert FeeTransferFailed();

        IBasenameRegistrarV2(registrar).register{value: registrarValue}(req);

        emit Registered(req.name, req.owner, req.duration, registrarValue, fee);
    }

    function registerSimpleWithFee(
        string calldata name,
        address owner,
        uint256 duration,
        uint256 registrarValue
    ) external payable nonReentrant {
        if (duration == 0 || registrarValue == 0) revert BadParams();
        uint256 fee = computeFee(msg.value);
        if (msg.value != registrarValue + fee) revert BadMsgValue();

        emit RegisterIntent(msg.sender, name, owner, duration, registrarValue, fee);

        (bool okFee, ) = feeRecipient.call{value: fee}("");
        if (!okFee) revert FeeTransferFailed();

        bytes[] memory emptyData = new bytes[](0);
        IBasenameRegistrarV2.RegisterRequest memory req = IBasenameRegistrarV2.RegisterRequest({
            name: name,
            owner: owner,
            duration: duration,
            resolver: address(0),
            data: emptyData,
            reverseRecord: false
        });

        IBasenameRegistrarV2(registrar).register{value: registrarValue}(req);

        emit Registered(name, owner, duration, registrarValue, fee);
    }


    receive() external payable { revert("DIRECT_SEND_FORBIDDEN"); }
}
