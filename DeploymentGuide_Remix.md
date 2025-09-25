# BEP20 Token Vesting Contract - Remix IDE Deployment Guide

## Overview
This guide will help you deploy and interact with the BEP20 Token Vesting Contract with **Named Schedules** functionality in Remix IDE.

## Features
- ✅ **Named Vesting Schedules**: Create schedules with meaningful names like "Seed Round", "Private Sale", "Team Vesting"
- ✅ **Per-Minute Vesting**: Set `_slicePeriodSeconds` to `60` for minute-by-minute token release
- ✅ **Flexible Time Periods**: Support for hourly, daily, weekly, or monthly vesting
- ✅ **Query by Name**: Retrieve vesting schedules by their assigned names
- ✅ **Event Tracking**: All events now include schedule names for better monitoring

## Prerequisites
- MetaMask wallet installed
- BSC Testnet or Mainnet configured in MetaMask
- Some BNB for gas fees

## Step 1: Setup Remix IDE

1. Go to [https://remix.ethereum.org](https://remix.ethereum.org)
2. Create a new workspace or use the default workspace
3. In the file explorer, create two new files:
   - `TokenVesting_Remix.sol`
   - `MockBEP20_Remix.sol`

## Step 2: Copy Contract Code

### TokenVesting_Remix.sol
Copy the complete TokenVesting contract code into this file.

### MockBEP20_Remix.sol  
Copy the MockBEP20 token contract code into this file (for testing purposes).

## Step 3: Compile Contracts

1. Go to the "Solidity Compiler" tab
2. Select compiler version: **0.8.19**
3. Click "Compile TokenVesting_Remix.sol"
4. Click "Compile MockBEP20_Remix.sol"
5. Ensure both contracts compile without errors

## Step 4: Deploy Contracts

### Deploy MockBEP20 Token (for testing)
1. Go to "Deploy & Run Transactions" tab
2. Select "MockBEP20" from the contract dropdown
3. Click "Deploy"
4. Copy the deployed token contract address

### Deploy TokenVesting Contract
1. Select "TokenVesting" from the contract dropdown
2. In the constructor parameters, enter the token contract address from step above
3. Click "Deploy"
4. Copy the deployed vesting contract address

## Step 5: Setup Token Allowance

Before creating vesting schedules, the vesting contract needs permission to transfer tokens:

1. In the MockBEP20 contract interface, find the `approve` function
2. Parameters:
   - `spender`: Vesting contract address
   - `amount`: Total amount of tokens to be vested (in wei, e.g., 1000000000000000000000 for 1000 tokens)
3. Click "transact"

## Step 6: Transfer Tokens to Vesting Contract

1. In the MockBEP20 contract interface, find the `transfer` function
2. Parameters:
   - `to`: Vesting contract address  
   - `amount`: Amount of tokens to transfer
3. Click "transact"

## Step 7: Create Named Vesting Schedules

Now you can create vesting schedules with meaningful names:

### Example 1: Seed Round Vesting
```solidity
createVestingSchedule(
    "0x742d35Cc6634C0532925a3b8D4C9db96590c6C87", // beneficiary
    1640995200, // start time (Unix timestamp)
    15552000,   // cliff duration (6 months in seconds)
    31104000,   // total duration (12 months in seconds)  
    60,         // slice period (60 seconds = per-minute vesting)
    true,       // revocable
    "1000000000000000000000", // amount (1000 tokens in wei)
    "Seed Round" // schedule name
)
```

### Example 2: Private Sale Vesting
```solidity
createVestingSchedule(
    "0x742d35Cc6634C0532925a3b8D4C9db96590c6C87", // beneficiary
    1640995200, // start time
    7776000,    // cliff duration (3 months)
    31104000,   // total duration (12 months)
    60,         // slice period (per-minute)
    true,       // revocable
    "500000000000000000000", // amount (500 tokens)
    "Private Sale" // schedule name
)
```

### Example 3: Team Vesting
```solidity
createVestingSchedule(
    "0x742d35Cc6634C0532925a3b8D4C9db96590c6C87", // beneficiary
    1640995200, // start time
    31536000,   // cliff duration (12 months)
    126144000,  // total duration (48 months)
    60,         // slice period (per-minute)
    false,      // not revocable
    "2000000000000000000000", // amount (2000 tokens)
    "Team Vesting" // schedule name
)
```

## Step 8: Query Vesting Schedules by Name

### Get Count of Schedules by Name
```solidity
getVestingSchedulesCountByName("Seed Round")
```

### Get All Schedule IDs by Name
```solidity
getVestingSchedulesByName("Private Sale")
```

### Get Specific Schedule by Name and Index
```solidity
getVestingIdByNameAndIndex("Team Vesting", 0)
```

### Get Schedule Name by ID
```solidity
getVestingScheduleName("0x123...") // schedule ID
```

### Get Complete Schedule Details
```solidity
getVestingScheduleDetails("0x123...") // returns all info including name
```

## Step 9: Release Tokens

Beneficiaries can release their vested tokens:

1. Use the `release` function
2. Parameters:
   - `vestingScheduleId`: The ID of the vesting schedule
   - `amount`: Amount to release (in wei)

## Step 10: Monitor Events with Names

All events now include the schedule name for better tracking:

- `VestingScheduleCreated`: Includes schedule name
- `TokensReleased`: Shows which named schedule released tokens  
- `VestingScheduleRevoked`: Indicates which named schedule was revoked

## Important Notes

### Time Period Settings
- **Per-Minute**: `_slicePeriodSeconds = 60` (ideal for testing)
- **Hourly**: `_slicePeriodSeconds = 3600`
- **Daily**: `_slicePeriodSeconds = 86400`
- **Weekly**: `_slicePeriodSeconds = 604800`
- **Monthly**: `_slicePeriodSeconds = 2592000`

### Security Features
- Only contract owner can create vesting schedules
- Reentrancy protection on all functions
- Emergency pause functionality
- Safe math operations

### Gas Optimization Tips
- Batch multiple operations when possible
- Use appropriate gas limits for complex transactions
- Consider gas prices during deployment

## Best Practices

1. **Testing**: Always test on BSC Testnet first
2. **Naming**: Use clear, descriptive names for vesting schedules
3. **Documentation**: Keep track of all schedule IDs and their purposes
4. **Security**: Verify all parameters before creating schedules
5. **Monitoring**: Watch events to track vesting activity

## Troubleshooting

### Common Issues
1. **Compilation Error**: Ensure Solidity version 0.8.19
2. **Deployment Failed**: Check gas limits and network connection
3. **Transaction Reverted**: Verify token allowance and balance
4. **Name Already Exists**: Each schedule can have the same name (names are not unique)

### Error Messages
- `"Insufficient token balance"`: Contract needs more tokens
- `"Name cannot be empty"`: Provide a valid schedule name
- `"Only owner"`: Only contract owner can perform this action

## Summary

The updated TokenVesting contract now supports:
- ✅ Named vesting schedules for better organization
- ✅ Per-minute vesting capability for flexible token release
- ✅ Query functions to retrieve schedules by name
- ✅ Enhanced event tracking with schedule names
- ✅ All original security and functionality features

Your contract is now ready for deployment on BSC Mainnet with full naming functionality! 🎉