# 🚀 MAINNET SETUP GUIDE

## ⚠️ CRITICAL WARNING

**THIS GUIDE IS FOR MAINNET SETUP WITH REAL MONEY. READ EVERY STEP CAREFULLY!**

All mainnet transactions are **IRREVERSIBLE**. Mistakes can result in **PERMANENT LOSS OF FUNDS**.

---

## 📋 PREREQUISITES

Before enabling mainnet, ensure you have:

1. ✅ **Tested thoroughly on testnet** (BSC Testnet, Polygon Mumbai)
2. ✅ **Legal compliance** - Check your country's crypto regulations
3. ✅ **Security measures** in place (2FA, monitoring, alerts)
4. ✅ **Insurance** or risk management strategy
5. ✅ **24/7 monitoring** capability
6. ✅ **Hot wallet security** understanding

---

## 🔐 HOT WALLET SETUP

### What is a Hot Wallet?

A hot wallet is an **online wallet** that holds crypto for immediate withdrawals. It should contain **MINIMUM funds** - only enough for daily operations.

### Security Best Practices

1. **Cold Storage First**: Keep 95%+ of funds in cold storage (hardware wallet, multi-sig)
2. **Hot Wallet Minimum**: Only keep 1-2 days worth of expected withdrawals
3. **Multi-signature**: Consider using multi-sig wallets (2-of-3, 3-of-5)
4. **Hardware Security Module (HSM)**: For production, use HSM for key management

### Creating Hot Wallets

You need a hot wallet for each network:
- BSC Mainnet
- Polygon Mainnet

**Option A: Generate Securely (Recommended)**

```javascript
// Run this on an OFFLINE, SECURE computer
import { ethers } from 'ethers';

// BSC Hot Wallet
const bscWallet = ethers.Wallet.createRandom();
console.log('BSC Mainnet Hot Wallet:');
console.log('Address:', bscWallet.address);
console.log('Private Key:', bscWallet.privateKey);
console.log('Mnemonic:', bscWallet.mnemonic.phrase);

// Polygon Hot Wallet
const polyWallet = ethers.Wallet.createRandom();
console.log('\nPolygon Mainnet Hot Wallet:');
console.log('Address:', polyWallet.address);
console.log('Private Key:', polyWallet.privateKey);
console.log('Mnemonic:', polyWallet.mnemonic.phrase);
```

**CRITICAL: Save these securely!**
- Write down mnemonic phrases on paper (multiple copies)
- Store in safe deposit boxes or secure vaults
- NEVER store plain-text private keys digitally
- NEVER share private keys with anyone

**Option B: Use Existing Wallets**

If you already have secure wallets, you can use them. Ensure they:
- Are NOT exchange wallets (you need full control)
- Have NEVER been compromised
- Private keys are stored securely

---

## 💾 DATABASE CONFIGURATION

### Step 1: Insert Hot Wallet Configuration

⚠️ **ENCRYPT THE PRIVATE KEY BEFORE INSERTING!**

For now, we use base64 encoding (better encryption recommended for production):

```javascript
// Encrypt private key (use proper encryption in production!)
const encryptedPrivateKey = btoa(privateKey);
```

**Insert into database:**

```sql
-- BSC Mainnet Hot Wallet
INSERT INTO hot_wallet_config (
  network,
  currency,
  address,
  private_key_encrypted,
  balance,
  min_balance_threshold,
  is_active
) VALUES (
  'bsc',
  'BNB',
  'YOUR_BSC_HOT_WALLET_ADDRESS',
  'YOUR_ENCRYPTED_PRIVATE_KEY',
  0,
  0.1,  -- Alert if balance goes below 0.1 BNB
  true
);

-- Polygon Mainnet Hot Wallet
INSERT INTO hot_wallet_config (
  network,
  currency,
  address,
  private_key_encrypted,
  balance,
  min_balance_threshold,
  is_active
) VALUES (
  'polygon',
  'MATIC',
  'YOUR_POLYGON_HOT_WALLET_ADDRESS',
  'YOUR_ENCRYPTED_PRIVATE_KEY',
  0,
  10,  -- Alert if balance goes below 10 MATIC
  true
);
```

### Step 2: Fund Hot Wallets

**Start with TEST amounts:**

1. Send **small amounts** first (e.g., $50-100 worth)
2. Test a complete deposit → balance → withdrawal flow
3. Verify everything works correctly
4. Then fund with operational amounts

**Recommended Initial Funding:**
- BSC: 0.5-1 BNB (~$200-400) + gas reserves
- Polygon: 100-200 MATIC (~$100-200) + gas reserves

---

## 🔄 MAINNET ACTIVATION

### Current Status

The app is **ALREADY configured for mainnet** by default:
- `DEFAULT_NETWORK` is set to `'bsc'` (mainnet)
- Network selectors include both testnet and mainnet
- All edge functions support mainnet networks

### What Users See

When users access deposit/withdrawal:
1. **Network selector** appears with both testnet and mainnet
2. **MAINNET badge** shows in green for mainnet networks
3. **Warning modals** appear before mainnet transactions
4. Users must explicitly confirm they understand risks

### Safety Features Enabled

✅ **Mainnet Warning Modal** - Shows before any mainnet transaction
✅ **Network Badge** - Clear visual indicator (MAINNET/TESTNET)
✅ **Network Selector** - Users can choose their network
✅ **Irreversibility Warnings** - Multiple warnings about permanent loss
✅ **Address Validation** - Validates all blockchain addresses
✅ **Balance Checks** - Prevents insufficient balance withdrawals

---

## 🧪 TESTING CHECKLIST

Before going live, test EVERYTHING:

### Deposit Testing
- [ ] Generate deposit address on BSC Mainnet
- [ ] Send **SMALL** test amount (e.g., 0.001 BNB)
- [ ] Verify transaction appears in blockchain history
- [ ] Confirm balance updates after required confirmations
- [ ] Check database records are correct
- [ ] Test with Polygon Mainnet

### Withdrawal Testing
- [ ] Request **SMALL** withdrawal (to YOUR wallet)
- [ ] Verify withdrawal request created
- [ ] Check admin approval (if required)
- [ ] Confirm crypto arrives at destination
- [ ] Verify blockchain transaction
- [ ] Check balance deduction is correct
- [ ] Test with Polygon Mainnet

### Security Testing
- [ ] Verify RLS policies work correctly
- [ ] Test that users can't access other users' data
- [ ] Confirm private keys are encrypted
- [ ] Test withdrawal limits
- [ ] Verify network validation works
- [ ] Test double-spend prevention

---

## 📊 MONITORING & ALERTS

### What to Monitor

1. **Hot Wallet Balances**
   - Alert if below threshold
   - Auto-top-up from cold storage (manual process)

2. **Transaction Volume**
   - Unusual withdrawal patterns
   - Large single transactions
   - Velocity checks

3. **Failed Transactions**
   - Why are they failing?
   - User errors or system issues?

4. **Gas Prices**
   - Monitor for optimal times
   - Dynamic fee adjustment

### Monitoring Setup

```sql
-- Query hot wallet balances
SELECT
  network,
  currency,
  address,
  balance,
  min_balance_threshold,
  last_balance_check,
  CASE
    WHEN balance < min_balance_threshold THEN '⚠️ LOW BALANCE'
    ELSE '✅ OK'
  END as status
FROM hot_wallet_config
WHERE is_active = true;

-- Check pending withdrawals
SELECT
  id,
  currency,
  amount,
  status,
  created_at,
  EXTRACT(EPOCH FROM (NOW() - created_at))/3600 as hours_pending
FROM blockchain_withdrawals
WHERE status IN ('pending', 'processing')
ORDER BY created_at DESC;
```

---

## 🚨 EMERGENCY PROCEDURES

### If Hot Wallet is Compromised

1. **IMMEDIATE**: Disable hot wallet in database
   ```sql
   UPDATE hot_wallet_config SET is_active = false WHERE network = 'bsc';
   ```

2. **Transfer remaining funds** to new secure wallet

3. **Pause all withdrawals** - disable withdraw function

4. **Investigate** how compromise occurred

5. **Generate new hot wallets** following security procedures

6. **Resume operations** only after security audit

### If Withdrawal Stuck

1. Check blockchain explorer for transaction status
2. If stuck: speed up with higher gas price
3. If failed: investigate error message
4. Update database status accordingly
5. Notify user of status

---

## 💰 FINANCIAL MANAGEMENT

### Daily Operations

1. **Morning**: Check hot wallet balances
2. **Continuous**: Monitor pending withdrawals
3. **As Needed**: Top-up hot wallets from cold storage
4. **Evening**: Sweep excess from hot wallets to cold storage
5. **Weekly**: Full audit and reconciliation

### Reconciliation

```sql
-- Total user balances
SELECT
  currency,
  SUM(available) as total_user_balance
FROM balances
GROUP BY currency;

-- Compare with actual crypto holdings
-- Hot wallet + Cold storage should >= Total user balances
```

---

## 📝 COMPLIANCE & LEGAL

### Requirements (varies by jurisdiction)

1. **KYC/AML** - Know Your Customer / Anti-Money Laundering
   - May need to verify user identity
   - Transaction monitoring for suspicious activity

2. **Licenses** - Some countries require crypto exchange licenses

3. **Tax Reporting** - Transaction reporting requirements

4. **Terms of Service** - Clear user agreements

5. **Insurance** - Consider crypto insurance for hot wallets

**⚠️ Consult with legal counsel in your jurisdiction!**

---

## 🔧 ADVANCED CONFIGURATION

### Custom RPC Endpoints

For better reliability, consider:
- [Alchemy](https://www.alchemy.com/)
- [Infura](https://www.infura.io/)
- [QuickNode](https://www.quicknode.com/)

Update in `src/lib/blockchain-config.ts`:
```typescript
bsc: {
  name: 'BSC Mainnet',
  chainId: 56,
  rpcUrl: 'https://your-alchemy-endpoint.com/v2/YOUR_KEY',
  ...
}
```

### Gas Price Optimization

Implement dynamic gas pricing based on network congestion.

### Rate Limiting

Add rate limits for withdrawals to prevent abuse.

---

## 📞 SUPPORT & MAINTENANCE

### User Support

Be prepared to handle:
- "Where is my deposit?" - Check blockchain confirmations
- "My withdrawal is stuck" - Check transaction status
- "Wrong network!" - Unfortunately irreversible, education is key

### Regular Maintenance

- **Daily**: Balance checks, withdrawal processing
- **Weekly**: Full system audit
- **Monthly**: Security review, update dependencies
- **Quarterly**: External security audit (recommended)

---

## ✅ FINAL CHECKLIST

Before going live with mainnet:

- [ ] Hot wallets created and secured
- [ ] Hot wallet configuration in database
- [ ] Hot wallets funded (test amounts)
- [ ] Full testing completed on mainnet (small amounts)
- [ ] Monitoring and alerts set up
- [ ] Emergency procedures documented
- [ ] Legal compliance verified
- [ ] User terms of service updated
- [ ] Customer support trained
- [ ] Backup procedures in place
- [ ] Insurance considered/obtained
- [ ] Team knows emergency contacts

---

## 🎯 SWITCHING BETWEEN TESTNET AND MAINNET

### To Use TESTNET (for testing)

In `src/lib/blockchain-config.ts`:
```typescript
export const DEFAULT_NETWORK: NetworkKey = 'bsc_testnet';
```

In `src/components/DepositMethodModal.tsx` and `SendMethodModal.tsx`:
```typescript
network: 'bsc_testnet'  // or 'polygon_mumbai'
```

### To Use MAINNET (for production)

In `src/lib/blockchain-config.ts`:
```typescript
export const DEFAULT_NETWORK: NetworkKey = 'bsc';  // Already set!
```

In `src/components/DepositMethodModal.tsx` and `SendMethodModal.tsx`:
```typescript
network: 'bsc'  // or 'polygon' - Already set!
```

**Current Status: ✅ MAINNET IS ACTIVE**

---

## 🆘 NEED HELP?

### Resources

- [Ethers.js Docs](https://docs.ethers.org/)
- [BSCScan API](https://docs.bscscan.com/)
- [Polygon Docs](https://wiki.polygon.technology/)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)

### Security Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Blockchain Security Best Practices](https://consensys.net/blog/blockchain-development/smart-contract-security-best-practices/)

---

## 🎉 YOU'RE READY!

Remember:
- Start small
- Test thoroughly
- Monitor constantly
- Prioritize security
- Have emergency plans

**Good luck with your crypto exchange! 🚀**
