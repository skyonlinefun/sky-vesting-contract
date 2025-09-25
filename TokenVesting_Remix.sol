// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TokenVesting - Remix IDE Compatible Version
 * @dev A secure BEP20 token vesting contract with comprehensive features
 * @notice This contract allows for token vesting with customizable schedules
 * @dev All OpenZeppelin imports are included inline for Remix compatibility
 */

// OpenZeppelin IERC20 Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// OpenZeppelin Context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Ownable
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin ReentrancyGuard
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// OpenZeppelin Pausable
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SafeMath Library
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

// SafeERC20 Library
library SafeERC20 {
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// Address Library
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @title TokenVesting
 * @dev Main Token Vesting Contract
 */
contract TokenVesting is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    // Vesting schedule structure
    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        bool revocable;
        uint256 amountTotal;
        uint256 released;
        bool revoked;
        string name; // Name/Tag for the vesting schedule (e.g., "Seed Round", "Private Sale")
    }

    // The BEP20 token being vested
    IERC20 private immutable _token;

    // Mapping from vesting schedule ID to VestingSchedule
    mapping(bytes32 => VestingSchedule) private vestingSchedules;
    
    // Mapping from beneficiary to list of vesting schedule IDs
    mapping(address => bytes32[]) private beneficiaryVestingSchedules;
    
    // Mapping from schedule name to list of vesting schedule IDs
    mapping(string => bytes32[]) private schedulesByName;
    
    // Total amount of tokens held by the vesting contract
    uint256 private vestingSchedulesTotalAmount;
    
    // Current vesting schedule count
    uint256 private vestingSchedulesIds;

    // Events
    event VestingScheduleCreated(
        bytes32 indexed vestingScheduleId,
        address indexed beneficiary,
        string name,
        uint256 cliff,
        uint256 start,
        uint256 duration,
        uint256 slicePeriodSeconds,
        bool revocable,
        uint256 amount
    );

    event TokensReleased(
        bytes32 indexed vestingScheduleId,
        address indexed beneficiary,
        string name,
        uint256 amount
    );

    event VestingScheduleRevoked(
        bytes32 indexed vestingScheduleId,
        address indexed beneficiary,
        string name,
        uint256 unreleased
    );

    event TokensWithdrawn(address indexed owner, uint256 amount);

    /**
     * @dev Creates a vesting contract
     * @param token_ address of the BEP20 token contract
     */
    constructor(address token_) {
        require(token_ != address(0), "TokenVesting: token is the zero address");
        _token = IERC20(token_);
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary
     * @param _beneficiary Address of the beneficiary
     * @param _start Start time of the vesting period (Unix timestamp)
     * @param _cliff Cliff period in seconds from start
     * @param _duration Total vesting duration in seconds
     * @param _slicePeriodSeconds Interval for token release (minimum 60 seconds for per-minute vesting)
     * @param _revocable Whether the schedule can be revoked by owner
     * @param _amount Total amount of tokens to vest
     * @param _name Name/Tag for the vesting schedule (e.g., "Seed Round", "Private Sale", "Team Vesting")
     */
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        bool _revocable,
        uint256 _amount,
        string memory _name
    ) external onlyOwner whenNotPaused {
        require(
            getWithdrawableAmount() >= _amount,
            "TokenVesting: cannot create vesting schedule because not sufficient tokens"
        );
        require(_duration > 0, "TokenVesting: duration must be > 0");
        require(_amount > 0, "TokenVesting: amount must be > 0");
        require(_slicePeriodSeconds >= 1, "TokenVesting: slicePeriodSeconds must be >= 1");
        require(_beneficiary != address(0), "TokenVesting: beneficiary is the zero address");
        require(bytes(_name).length > 0, "TokenVesting: name cannot be empty");

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(_beneficiary);
        uint256 cliff = _start.add(_cliff);
        
        vestingSchedules[vestingScheduleId] = VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _revocable,
            _amount,
            0,
            false,
            _name
        );
        
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.add(_amount);
        vestingSchedulesIds = vestingSchedulesIds.add(1);
        beneficiaryVestingSchedules[_beneficiary].push(vestingScheduleId);
        schedulesByName[_name].push(vestingScheduleId);

        emit VestingScheduleCreated(
            vestingScheduleId,
            _beneficiary,
            _name,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _revocable,
            _amount
        );
    }

    /**
     * @notice Revokes the vesting schedule for given identifier
     */
    function revoke(bytes32 vestingScheduleId) external onlyOwner whenNotPaused {
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        require(vestingSchedule.initialized, "TokenVesting: vesting schedule not initialized");
        require(vestingSchedule.revocable, "TokenVesting: vesting schedule not revocable");
        require(!vestingSchedule.revoked, "TokenVesting: vesting schedule already revoked");
        
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        if (vestedAmount > 0) {
            release(vestingScheduleId, vestedAmount);
        }
        
        uint256 unreleased = vestingSchedule.amountTotal.sub(vestingSchedule.released);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(unreleased);
        vestingSchedule.revoked = true;

        emit VestingScheduleRevoked(vestingScheduleId, vestingSchedule.beneficiary, vestingSchedule.name, unreleased);
    }

    /**
     * @notice Release vested amount of tokens
     */
    function release(bytes32 vestingScheduleId, uint256 amount) public nonReentrant whenNotPaused {
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        bool isBeneficiary = msg.sender == vestingSchedule.beneficiary;
        bool isOwner = msg.sender == owner();
        require(
            isBeneficiary || isOwner,
            "TokenVesting: only beneficiary and owner can release vested tokens"
        );
        require(vestingSchedule.initialized, "TokenVesting: vesting schedule not initialized");
        require(!vestingSchedule.revoked, "TokenVesting: vesting schedule revoked");
        
        uint256 vestedAmount = _computeReleasableAmount(vestingSchedule);
        require(vestedAmount >= amount, "TokenVesting: cannot release tokens, not enough vested tokens");
        
        vestingSchedule.released = vestingSchedule.released.add(amount);
        vestingSchedulesTotalAmount = vestingSchedulesTotalAmount.sub(amount);
        _token.safeTransfer(vestingSchedule.beneficiary, amount);

        emit TokensReleased(vestingScheduleId, vestingSchedule.beneficiary, vestingSchedule.name, amount);
    }

    // View Functions
    function getVestingSchedulesCountByBeneficiary(address _beneficiary) external view returns (uint256) {
        return beneficiaryVestingSchedules[_beneficiary].length;
    }

    function getVestingIdAtIndex(address _beneficiary, uint256 _index) external view returns (bytes32) {
        require(_index < beneficiaryVestingSchedules[_beneficiary].length, "TokenVesting: index out of bounds");
        return beneficiaryVestingSchedules[_beneficiary][_index];
    }

    function getVestingSchedule(bytes32 vestingScheduleId) external view returns (VestingSchedule memory) {
        return vestingSchedules[vestingScheduleId];
    }

    /**
     * @notice Get vesting schedules count by name/tag
     * @param _name Name/Tag of the vesting schedule (e.g., "Seed Round", "Private Sale")
     * @return Number of vesting schedules with the given name
     */
    function getVestingSchedulesCountByName(string memory _name) external view returns (uint256) {
        return schedulesByName[_name].length;
    }

    /**
     * @notice Get vesting schedule ID by name and index
     * @param _name Name/Tag of the vesting schedule
     * @param _index Index in the name-based array
     * @return Vesting schedule ID
     */
    function getVestingIdByNameAndIndex(string memory _name, uint256 _index) external view returns (bytes32) {
        require(_index < schedulesByName[_name].length, "TokenVesting: index out of bounds");
        return schedulesByName[_name][_index];
    }

    /**
     * @notice Get all vesting schedule IDs for a specific name/tag
     * @param _name Name/Tag of the vesting schedule
     * @return Array of vesting schedule IDs
     */
    function getVestingSchedulesByName(string memory _name) external view returns (bytes32[] memory) {
        return schedulesByName[_name];
    }

    /**
     * @notice Get vesting schedule name by ID
     * @param vestingScheduleId The vesting schedule ID
     * @return Name/Tag of the vesting schedule
     */
    function getVestingScheduleName(bytes32 vestingScheduleId) external view returns (string memory) {
        require(vestingSchedules[vestingScheduleId].initialized, "TokenVesting: vesting schedule not initialized");
        return vestingSchedules[vestingScheduleId].name;
    }

    /**
     * @notice Get detailed vesting schedule information with name
     * @param vestingScheduleId The vesting schedule ID
     * @return beneficiary Address of the beneficiary
     * @return name Name/Tag of the vesting schedule
     * @return start Start time of vesting
     * @return cliff Cliff time
     * @return duration Total duration
     * @return slicePeriodSeconds Release interval
     * @return amountTotal Total amount
     * @return released Released amount
     * @return revocable Whether revocable
     * @return revoked Whether revoked
     */
    function getVestingScheduleDetails(bytes32 vestingScheduleId) external view returns (
        address beneficiary,
        string memory name,
        uint256 start,
        uint256 cliff,
        uint256 duration,
        uint256 slicePeriodSeconds,
        uint256 amountTotal,
        uint256 released,
        bool revocable,
        bool revoked
    ) {
        VestingSchedule memory schedule = vestingSchedules[vestingScheduleId];
        require(schedule.initialized, "TokenVesting: vesting schedule not initialized");
        
        return (
            schedule.beneficiary,
            schedule.name,
            schedule.start,
            schedule.cliff,
            schedule.duration,
            schedule.slicePeriodSeconds,
            schedule.amountTotal,
            schedule.released,
            schedule.revocable,
            schedule.revoked
        );
    }

    function getWithdrawableAmount() public view returns (uint256) {
        return _token.balanceOf(address(this)).sub(vestingSchedulesTotalAmount);
    }

    function computeNextVestingScheduleIdForHolder(address holder) public view returns (bytes32) {
        return computeVestingScheduleIdForAddressAndIndex(holder, beneficiaryVestingSchedules[holder].length);
    }

    function computeVestingScheduleIdForAddressAndIndex(address holder, uint256 index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function computeReleasableAmount(bytes32 vestingScheduleId) external view returns (uint256) {
        VestingSchedule storage vestingSchedule = vestingSchedules[vestingScheduleId];
        return _computeReleasableAmount(vestingSchedule);
    }

    function _computeReleasableAmount(VestingSchedule memory vestingSchedule) internal view returns (uint256) {
        if (!vestingSchedule.initialized || vestingSchedule.revoked) {
            return 0;
        }
        
        uint256 currentTime = getCurrentTime();
        if (currentTime < vestingSchedule.cliff) {
            return 0;
        } else if (currentTime >= vestingSchedule.start.add(vestingSchedule.duration)) {
            return vestingSchedule.amountTotal.sub(vestingSchedule.released);
        } else {
            uint256 timeFromStart = currentTime.sub(vestingSchedule.start);
            uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 vestedSlicePeriods = timeFromStart.div(secondsPerSlice);
            uint256 vestedSeconds = vestedSlicePeriods.mul(secondsPerSlice);
            uint256 vestedAmount = vestingSchedule.amountTotal.mul(vestedSeconds).div(vestingSchedule.duration);
            return vestedAmount.sub(vestingSchedule.released);
        }
    }

    function getCurrentTime() internal view virtual returns (uint256) {
        return block.timestamp;
    }

    // Owner Functions
    function withdraw(uint256 amount) external onlyOwner whenNotPaused {
        require(getWithdrawableAmount() >= amount, "TokenVesting: not enough withdrawable funds");
        _token.safeTransfer(owner(), amount);
        emit TokensWithdrawn(owner(), amount);
    }

    function getToken() external view returns (address) {
        return address(_token);
    }

    function getVestingSchedulesCount() external view returns (uint256) {
        return vestingSchedulesIds;
    }

    function getVestingSchedulesTotalAmount() external view returns (uint256) {
        return vestingSchedulesTotalAmount;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Recover accidentally sent BEP20 tokens (except vesting token)
     * @param tokenAddress Address of the token to recover
     * @param tokenAmount Amount of tokens to recover
     */
    function recoverBEP20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        require(tokenAddress != address(_token), "TokenVesting: cannot recover vesting token");
        require(tokenAddress != address(0), "TokenVesting: token address cannot be zero");
        require(tokenAmount > 0, "TokenVesting: amount must be greater than 0");
        
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        
        emit TokensWithdrawn(owner(), tokenAmount);
    }
}