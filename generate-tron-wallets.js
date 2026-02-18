import { ethers } from 'ethers';

const WALLET_COUNT = parseInt(process.argv[2]) || 10;

console.log('🔴 GERÇEK TRON (TRC20) CÜZDAN OLUŞTURUCU\n');
console.log(`📊 ${WALLET_COUNT} adet TRC20 cüzdan oluşturulacak\n`);

console.log('⚠️  UYARI: TronWeb kütüphanesi olmadan gerçek TRON cüzdanları oluşturulamaz.');
console.log('Bu script Ethereum formatında cüzdanlar oluşturur ve T ile başlayan TRON formatına dönüştürür.\n');
console.log('Gerçek üretim için TronWeb kullanın: npm install tronweb\n');

const wallets = [];

function convertToTronAddress(ethAddress) {
  const hexAddress = ethAddress.slice(2);
  const tronAddress = 'T' + hexAddress.slice(0, 33);

  if (tronAddress.length !== 34) {
    const padding = '1'.repeat(34 - tronAddress.length);
    return tronAddress + padding;
  }

  return tronAddress;
}

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

for (let i = 0; i < WALLET_COUNT; i++) {
  const wallet = ethers.Wallet.createRandom();
  const tronAddress = convertToTronAddress(wallet.address);

  wallets.push({
    network: 'TRC20',
    address: tronAddress,
    privateKey: wallet.privateKey,
    ethAddress: wallet.address
  });
}

console.log(`\n✅ ${wallets.length} TRON CÜZDANI OLUŞTURULDU!\n`);

console.log('📋 TOPLU EKLEME İÇİN FORMAT:\n');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

wallets.forEach((wallet) => {
  console.log(`TRC20, ${wallet.address}, ${wallet.privateKey}`);
});

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

console.log('📝 DETAYLI BİLGİLER:\n');

wallets.forEach((wallet, index) => {
  console.log(`\n[${index + 1}] TRC20 CÜZDANI:`);
  console.log(`   TRON Adresi: ${wallet.address}`);
  console.log(`   Private Key: ${wallet.privateKey}`);
  console.log(`   ETH Formatı: ${wallet.ethAddress}`);
});

console.log('\n\n⚠️  ÖNEMLİ NOTLAR:');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('1. Bu adresler SİMÜLE EDİLMİŞ TRON adresleridir');
console.log('2. Gerçek TRON cüzdanı için TronWeb kullanmanız gerekir');
console.log('3. Test amaçlı kullanılabilir, üretimde TronWeb tercih edin');
console.log('4. Private key\'ler güvenli şekilde saklanmalıdır');
console.log('\n📦 GERÇEK TRON CÜZDANI İÇİN:');
console.log('   npm install tronweb');
console.log('   const TronWeb = require("tronweb");');
console.log('   const account = TronWeb.utils.accounts.generateAccount();\n');
