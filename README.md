# Node Sunucusu

Kripto projelerinin ödül ihtimali olan node'larını (teşvikli testnet, validator vb.) tek bir Ubuntu sunucuda Docker ile çalıştırmak için betikler.

## Kurulum

```bash
git clone <bu-repo> && cd polatyusuff
sudo bash setup/sunucu-hazirlik.sh     # Docker, UFW, fail2ban, swap, otomatik güncellemeler
# oturumu kapatıp yeniden aç
```

Ayarlar: `SWAP_GB=16 SSH_PORT=2222 sudo -E bash setup/sunucu-hazirlik.sh`

## Yeni node ekleme

```bash
cp -r nodes/_sablon nodes/<proje>
cd nodes/<proje>
cp .env.example .env && nano .env      # imaj, port, anahtarlar
sudo ufw allow <p2p-port>/tcp
docker compose up -d
docker compose logs -f
```

## Günlük kullanım

| İş | Komut |
|---|---|
| Hepsinin durumu | `bash scripts/durum.sh` |
| Loglar | `cd nodes/<proje> && docker compose logs -f --tail 100` |
| Güncelleme | `docker compose pull && docker compose up -d` |
| Durdurma | `docker compose down` |

## Güvenlik kuralları

- Node'lara **yalnızca o iş için açılmış, içinde ana paran olmayan** cüzdanlar ver.
- Seed phrase / private key'i hiçbir zaman git'e, Discord'a, "destek" ekibine verme.
- Kurulum komutlarını yalnızca projenin **resmi** dokümanından veya GitHub'ından al; Telegram/YouTube'daki `curl ... | bash` betiklerine dikkat.
- Testnet ödülleri garanti değildir; çoğu proje sonradan kriterleri değiştirir.
