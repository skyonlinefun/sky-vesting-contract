# Sky Vesting Contract 🚀

## Token Vesting Contract with Named Schedules - Remix IDE Compatible

A comprehensive BEP20 token vesting contract with advanced features including **named vesting schedules** for better organization and management.

## ✨ Key Features

### 🏷️ Named Vesting Schedules
- **Organize by Purpose**: Create schedules with meaningful names like "Seed Round", "Private Sale", "Team Vesting"
- **Easy Identification**: Quickly identify and manage different types of vesting schedules
- **Event Tracking**: All events include schedule names for better monitoring

### ⏰ Flexible Vesting Options
- **Per-Minute Vesting**: Set `_slicePeriodSeconds` to `60` for minute-by-minute token release
- **Custom Intervals**: Support for hourly, daily, weekly, or monthly vesting periods
- **Cliff Periods**: Configurable cliff periods before vesting begins
- **Revocable Schedules**: Owner can revoke schedules if needed

### 🔒 Security Features
- **Access Control**: Only owner can create and manage schedules
- **Reentrancy Protection**: Safe from reentrancy attacks
- **Pausable**: Emergency pause functionality
- **Safe Math**: Built-in overflow protection

## 📁 Files

- **`TokenVesting_Remix.sol`** - Main vesting contract (Remix IDE compatible)
- **`MockBEP20_Remix.sol`** - Test token for development
- **`DeploymentGuide_Remix.md`** - Complete deployment and usage guide

## 🚀 Quick Start

### 1. Import to Remix IDE
```
1. Go to https://remix.ethereum.org
2. Create new files and copy the contract code
3. Compile with Solidity 0.8.19
4. Deploy on BSC Testnet or Mainnet
```

### 2. Create Named Vesting Schedule
```solidity
// Example: Create a "Seed Round" vesting schedule
vesting.createVestingSchedule(
    beneficiaryAddress,
    startTime,
    cliffPeriod,
    totalDuration,
    60, // 60 seconds = per-minute vesting
    true, // revocable
    tokenAmount,
    "Seed Round" // Schedule name
);
```

### 3. Query by Name
```solidity
// Get all "Seed Round" schedules
bytes32[] memory seedSchedules = vesting.getVestingSchedulesByName("Seed Round");

// Get count of "Team Vesting" schedules
uint256 teamCount = vesting.getVestingSchedulesCountByName("Team Vesting");
```

## 📊 Vesting Schedule Examples

### Seed Round
- **Cliff**: 6 months
- **Duration**: 24 months
- **Release**: Per minute (for testing) or monthly
- **Revocable**: Yes

### Private Sale
- **Cliff**: 3 months
- **Duration**: 12 months
- **Release**: Per minute or weekly
- **Revocable**: Yes

### Team Vesting
- **Cliff**: 12 months
- **Duration**: 48 months
- **Release**: Per minute or monthly
- **Revocable**: No

## 🔧 Time Period Settings

| Interval | Seconds | Usage |
|----------|---------|-------|
| Per Minute | `60` | Testing/Demo |
| Hourly | `3600` | Frequent releases |
| Daily | `86400` | Regular vesting |
| Weekly | `604800` | Standard vesting |
| Monthly | `2592000` | Long-term vesting |

## 🌐 Network Support

### BSC Testnet
- **Chain ID**: 97
- **RPC**: https://data-seed-prebsc-1-s1.binance.org:8545/
- **Explorer**: https://testnet.bscscan.com

### BSC Mainnet
- **Chain ID**: 56
- **RPC**: https://bsc-dataseed1.binance.org/
- **Explorer**: https://bscscan.com

## 📚 New Functions

### Query by Name
```solidity
getVestingSchedulesCountByName(string memory _name)
getVestingSchedulesByName(string memory _name)
getVestingIdByNameAndIndex(string memory _name, uint256 _index)
getVestingScheduleName(bytes32 vestingScheduleId)
getVestingScheduleDetails(bytes32 vestingScheduleId)
```

### Events with Names
```solidity
event VestingScheduleCreated(..., string name, ...);
event TokensReleased(..., string name, ...);
event VestingScheduleRevoked(..., string name, ...);
```

## 🛡️ Security Considerations

- ✅ Audited OpenZeppelin contracts
- ✅ Reentrancy protection
- ✅ Access control mechanisms
- ✅ Safe math operations
- ✅ Emergency pause functionality

## 📖 Documentation

For detailed deployment instructions, parameter explanations, and usage examples, see [`DeploymentGuide_Remix.md`](DeploymentGuide_Remix.md).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

MIT License - see LICENSE file for details.

---

**Ready to deploy on BSC Mainnet with full naming functionality! 🎉**