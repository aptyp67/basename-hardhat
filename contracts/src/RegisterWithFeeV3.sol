pragma solidity ^0.8.24;

interface IBasenameRegistrarV3 {
    struct RegisterRequest {
        string name;
        address owner;
        uint256 duration;
        address resolver;
        bytes[] data;
        bool reverseRecord;
        uint256[] coinTypes;
        uint256 signatureExpiry;
        bytes signature;
    }
    function registerPrice(string calldata name, uint256 duration) external view returns (uint256);
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

contract RegisterWithFeeV3 is NonReentrant {
    address public immutable registrar;
    address payable public immutable feeRecipient;
    uint96  public immutable feeBps;

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

    function computeFee(uint256 price) public view returns (uint256) {
        return (price * feeBps) / 10_000;
    }

    function registerSimpleWithFee(
        string calldata name,
        address owner,
        uint256 duration
    ) external payable nonReentrant {
        if (duration == 0) revert BadParams();

        uint256 price = IBasenameRegistrarV3(registrar).registerPrice(name, duration);
        uint256 fee = computeFee(price);
        if (msg.value != price + fee) revert BadMsgValue();

        (bool okFee, ) = feeRecipient.call{value: fee}("");
        if (!okFee) revert FeeTransferFailed();

        IBasenameRegistrarV3.RegisterRequest memory req = IBasenameRegistrarV3.RegisterRequest({
            name: name,
            owner: owner,
            duration: duration,
            resolver: address(0),
            data: new bytes[](0),
            reverseRecord: false,
            coinTypes: new uint256[](0),
            signatureExpiry: 0,
            signature: bytes("")
        });

        IBasenameRegistrarV3(registrar).register{value: price}(req);
    }

    receive() external payable { revert("DIRECT_SEND_FORBIDDEN"); }
}
