// SADECE BİR KERE ÇALIŞTIRIN!
// Bu sizin GERÇEK cüzdanınızı oluşturur

import { ethers } from 'ethers';

console.log('🔐 CÜZDAN OLUŞTURULUYOR...\n');

// BSC/Polygon/Ethereum için (hepsi aynı adresi kullanır)
const wallet = ethers.Wallet.createRandom();

console.log('✅ CÜZDANINIZ OLUŞTURULDU!\n');
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('📍 CÜZDAN ADRESİNİZ:');
console.log('   ', wallet.address);
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('🔑 PRIVATE KEY (GİZLİ TUTUN!):');
console.log('   ', wallet.privateKey);
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
console.log('📝 MNEMONIC (YEDEK ALIN!):');
console.log('   ', wallet.mnemonic.phrase);
console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

console.log('⚠️  ÖNEMLİ:');
console.log('1. Bu bilgileri GÜVENLİ bir yere kaydedin');
console.log('2. Private Key\'i ASLA kimseyle paylaşmayın');
console.log('3. Mnemonic\'i kağıda yazın ve saklayın');
console.log('\n💰 TÜM PARA BU ADRESE GELECEKTİR!\n');

// Encrypted private key (database için)
const encrypted = Buffer.from(wallet.privateKey).toString('base64');
console.log('📊 DATABASE İÇİN ENCRYPTED KEY:');
console.log('   ', encrypted);
console.log('\n');
