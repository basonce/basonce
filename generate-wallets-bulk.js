import { ethers } from 'ethers';

const WALLET_COUNT = parseInt(process.argv[2]) || 10;
const NETWORK_TYPE = process.argv[3]?.toUpperCase() || 'BOTH'; // BEP20, TRC20, or BOTH

console.log('🚀 TOPLU CÜZDAN OLUŞTURUCU\n');
console.log(`📊 ${WALLET_COUNT} adet cüzdan oluşturulacak`);
console.log(`🌐 Network: ${NETWORK_TYPE}\n`);

const wallets = [];

function generateBEP20Wallet() {
  const wallet = ethers.Wallet.createRandom();
  return {
    network: 'BEP20',
    address: wallet.address,
    privateKey: wallet.privateKey,
    mnemonic: wallet.mnemonic.phrase
  };
}

function generateTRC20Wallet() {
  const wallet = ethers.Wallet.createRandom();
  const address = wallet.address;
  const tronAddress = 'T' + address.slice(2);

  return {
    network: 'TRC20',
    address: tronAddress,
    privateKey: wallet.privateKey,
    mnemonic: wallet.mnemonic.phrase,
    note: 'UYARI: Bu TRC20 adresi simüle edilmiştir. Gerçek TRON cüzdanı için TronWeb kullanın!'
  };
}

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

for (let i = 0; i < WALLET_COUNT; i++) {
  if (NETWORK_TYPE === 'BOTH') {
    if (i % 2 === 0) {
      wallets.push(generateBEP20Wallet());
    } else {
      wallets.push(generateTRC20Wallet());
    }
  } else if (NETWORK_TYPE === 'BEP20') {
    wallets.push(generateBEP20Wallet());
  } else if (NETWORK_TYPE === 'TRC20') {
    wallets.push(generateTRC20Wallet());
  }
}

console.log(`\n✅ ${wallets.length} CÜZDAN OLUŞTURULDU!\n`);

console.log('📋 TOPLU EKLEME İÇİN FORMAT (WalletPoolManagement için):\n');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

wallets.forEach((wallet, index) => {
  console.log(`${wallet.network}, ${wallet.address}, ${wallet.privateKey}`);
});

console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

console.log('📝 DETAYLI BİLGİLER:\n');

wallets.forEach((wallet, index) => {
  console.log(`\n[${index + 1}] ${wallet.network} CÜZDANI:`);
  console.log(`   Adres: ${wallet.address}`);
  console.log(`   Private Key: ${wallet.privateKey}`);
  if (wallet.note) {
    console.log(`   ⚠️  ${wallet.note}`);
  }
});

console.log('\n\n⚠️  GÜVENLİK UYARILARI:');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('1. Bu cüzdanları GÜVENLİ bir yere kaydedin');
console.log('2. Private Key\'leri ASLA kimseyle paylaşmayın');
console.log('3. Sadece test için gerçek para göndermeden önce kontrol edin');
console.log('4. TRC20 için gerçek TRON cüzdanı oluşturmak gerekir (TronWeb kullanın)');
console.log('\n📤 KULLANIM:');
console.log('   Yukarıdaki "TOPLU EKLEME İÇİN FORMAT" bölümünü kopyalayın');
console.log('   Admin panelinde "Toplu Ekle" butonuna tıklayın');
console.log('   Kopyaladığınız metni yapıştırın ve ekleyin\n');
