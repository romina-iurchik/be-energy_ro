# Testing — Simulación Testnet BeEnergy

Última ejecución: **2026-03-06**
Red: **Stellar Testnet**

## Resumen

Se ejecutó una simulación completa del flujo de BeEnergy con 10 usuarios (7 prosumidores + 3 consumidores) en Stellar Testnet. Todo fue on-chain y verificable.

| Paso | Qué hace | Resultado |
|------|----------|-----------|
| 1. Keypairs + Friendbot | Genera 10 wallets y las fondea con 10,000 XLM testnet | 10/10 |
| 2. Registrar prosumidores | `POST /api/prosumers` para los 7 productores | 7/7 |
| 3. Lecturas de energía | `POST /api/readings` — 5 días × 7 prosumidores | 35/35 |
| 4. Mint HDROP on-chain | `POST /api/mint` — firma Soroban tx con MINTER_SECRET_KEY | 35/35 |
| 5. Ofertas marketplace | `POST /api/offers` + 2 marcadas como vendidas | 4 creadas, 2 vendidas |
| 6. Transfers P2P | Llamadas directas al contrato `transfer()` | 3/3 |
| 7. Gobernanza | `create_proposal()` en el contrato COMMUNITY_GOVERNANCE | 2/2 |

---

## Contratos involucrados

| Contrato | Address | Explorer |
|----------|---------|----------|
| ENERGY_TOKEN (HDROP) | `CAUH3NUZGCNRHHVJK5S3FLXIS244GCNPC2LDZDU2SVOK66G3IGAGBBL2` | [Stellar Expert](https://stellar.expert/explorer/testnet/contract/CAUH3NUZGCNRHHVJK5S3FLXIS244GCNPC2LDZDU2SVOK66G3IGAGBBL2) |
| ENERGY_DISTRIBUTION | `CDXWZSWTM6DGYTDME3BEDE6U7JBHMG4YM7ZW237UZS2XTUWFVEEMIROR` | [Stellar Expert](https://stellar.expert/explorer/testnet/contract/CDXWZSWTM6DGYTDME3BEDE6U7JBHMG4YM7ZW237UZS2XTUWFVEEMIROR) |
| COMMUNITY_GOVERNANCE | `CCH2EXXNSDW2BAKBIPFAG6CCZS6LV4VJFUP2CZZCW5LEY4JOAXBJD6YI` | [Stellar Expert](https://stellar.expert/explorer/testnet/contract/CCH2EXXNSDW2BAKBIPFAG6CCZS6LV4VJFUP2CZZCW5LEY4JOAXBJD6YI) |

Minter account (firma los mints server-side):
`GBWTQUAHJYBFWBIFAH5OEKGKFLDON7EYIU5FZELKZT3SYFZOBGS3YUQW` — [ver en Stellar Expert](https://stellar.expert/explorer/testnet/account/GBWTQUAHJYBFWBIFAH5OEKGKFLDON7EYIU5FZELKZT3SYFZOBGS3YUQW)

---

## Wallets generadas

### Prosumidores (generan energía y reciben HDROP)

| # | Nombre | Stellar Address | HDROP minteados | Explorer |
|---|--------|----------------|-----------------|----------|
| 1 | Casa Solar Norte | `GCCDGCPJQUH35HMXOKKNJ7VEE5GEJTKKK4IFRH7YQOYD6ZST2DJ2RRZO` | 18.11 | [ver](https://stellar.expert/explorer/testnet/account/GCCDGCPJQUH35HMXOKKNJ7VEE5GEJTKKK4IFRH7YQOYD6ZST2DJ2RRZO) |
| 2 | Depto Sustentable | `GD36EL77LQ6NETIJSTURK7ISDGWIXJX6NXYWTUXUDASQASLBOLGYFH2Z` | 10.85 | [ver](https://stellar.expert/explorer/testnet/account/GD36EL77LQ6NETIJSTURK7ISDGWIXJX6NXYWTUXUDASQASLBOLGYFH2Z) |
| 3 | Edificio Verde | `GD3Q6IYUMPGEWEIMULT72F5W6F7WAOIWAO33AQ2EDVBB5X2XNYPRF3NJ` | 31.25 | [ver](https://stellar.expert/explorer/testnet/account/GD3Q6IYUMPGEWEIMULT72F5W6F7WAOIWAO33AQ2EDVBB5X2XNYPRF3NJ) |
| 4 | Taller EcoTech | `GDQKV5L6J3JN6W5I6TRNFOHJQKNCKWUB4G7N4FJYVMLK476TWCDWI4RI` | 32.49 | [ver](https://stellar.expert/explorer/testnet/account/GDQKV5L6J3JN6W5I6TRNFOHJQKNCKWUB4G7N4FJYVMLK476TWCDWI4RI) |
| 5 | Granja Solar Sur | `GDUBGHUFQEW66GPFURLM7TW5JDSWY3SXMB3OZRGEZTXDD5XJCMLOY5DB` | 60.62 | [ver](https://stellar.expert/explorer/testnet/account/GDUBGHUFQEW66GPFURLM7TW5JDSWY3SXMB3OZRGEZTXDD5XJCMLOY5DB) |
| 6 | Oficina Limpia | `GBSCPGBR7WOQWOFDHCKVTBS3Z4D4E44YINDGJXJ2EEBFJTWTSP76TZAF` | 23.92 | [ver](https://stellar.expert/explorer/testnet/account/GBSCPGBR7WOQWOFDHCKVTBS3Z4D4E44YINDGJXJ2EEBFJTWTSP76TZAF) |
| 7 | Almacén Renovable | `GDEI54SDYSOFGSAMTBGJ3WFHBTVOZB3MTKHLKPQH6CQ5FWM4LWS6TGOW` | 34.64 | [ver](https://stellar.expert/explorer/testnet/account/GDEI54SDYSOFGSAMTBGJ3WFHBTVOZB3MTKHLKPQH6CQ5FWM4LWS6TGOW) |

### Consumidores (recibieron HDROP via P2P transfer)

| # | Nombre | Stellar Address | HDROP recibidos | Explorer |
|---|--------|----------------|-----------------|----------|
| 8 | Vecino Consumidor A | `GAT7SCOAUC3JVK4M5IDCC5WQKRMMOVZOFLC5ICUFRTY6N5FVOHB5CZUR` | 2.00 | [ver](https://stellar.expert/explorer/testnet/account/GAT7SCOAUC3JVK4M5IDCC5WQKRMMOVZOFLC5ICUFRTY6N5FVOHB5CZUR) |
| 9 | Vecino Consumidor B | `GDGFRBZXYSHFYZ72K3L6MGPLZ6EVJCN6WTHYKKNCQUWXRSMTQEA6PNCC` | 5.00 | [ver](https://stellar.expert/explorer/testnet/account/GDGFRBZXYSHFYZ72K3L6MGPLZ6EVJCN6WTHYKKNCQUWXRSMTQEA6PNCC) |
| 10 | Vecino Consumidor C | `GDYTGK2H2OG3YVX6S45GABDH4PAMEEPTDL63NTV6SV7J4YIP4QQ32RRE` | 3.00 | [ver](https://stellar.expert/explorer/testnet/account/GDYTGK2H2OG3YVX6S45GABDH4PAMEEPTDL63NTV6SV7J4YIP4QQ32RRE) |

---

## Transacciones on-chain

### Mint HDROP (35 transacciones)

Cada mint llama a `mint_energy(to, amount, minter)` en el contrato ENERGY_TOKEN. Firmadas por la minter account.

**Casa Solar Norte** (5 mints, 18.11 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 2.17 | `8d48781d4f706c80fa7cc57b6f96bd599b8b849b5484d85786abc793d2e0af7f` | [ver](https://stellar.expert/explorer/testnet/tx/8d48781d4f706c80fa7cc57b6f96bd599b8b849b5484d85786abc793d2e0af7f) |
| 2026-03-04 | 3.61 | `32abc758eef3a8ec7f3d3dc8c9ab9ffeac99777e1c6db717780f77e16461c2e7` | [ver](https://stellar.expert/explorer/testnet/tx/32abc758eef3a8ec7f3d3dc8c9ab9ffeac99777e1c6db717780f77e16461c2e7) |
| 2026-03-03 | 2.72 | `1f6f4e10de00365120f90c6f6b498a8b1eaf0e52db3f115a19e14f09e1a5958d` | [ver](https://stellar.expert/explorer/testnet/tx/1f6f4e10de00365120f90c6f6b498a8b1eaf0e52db3f115a19e14f09e1a5958d) |
| 2026-03-02 | 4.79 | `d440a14451f6232f953e4f4110dfb711b77a0b73a728dab2e7a59fd3e5b4b60e` | [ver](https://stellar.expert/explorer/testnet/tx/d440a14451f6232f953e4f4110dfb711b77a0b73a728dab2e7a59fd3e5b4b60e) |
| 2026-03-01 | 4.82 | `8aba09e0fd4834c85f6c136c70ae1c29df451deac23a3521182366ba97a96958` | [ver](https://stellar.expert/explorer/testnet/tx/8aba09e0fd4834c85f6c136c70ae1c29df451deac23a3521182366ba97a96958) |

**Depto Sustentable** (5 mints, 10.85 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 2.29 | `9228b27797b454d1232ac98bc29a400e5b800c1025b993e0d76d0d4a5cef8696` | [ver](https://stellar.expert/explorer/testnet/tx/9228b27797b454d1232ac98bc29a400e5b800c1025b993e0d76d0d4a5cef8696) |
| 2026-03-04 | 2.14 | `b31d354bd9a1f32c424ce706fc32d1730ef5bc48d54d7d0f85c3f47793f94e21` | [ver](https://stellar.expert/explorer/testnet/tx/b31d354bd9a1f32c424ce706fc32d1730ef5bc48d54d7d0f85c3f47793f94e21) |
| 2026-03-03 | 2.00 | `9afc6acea745585869651ace4c1cf4d71b212e927fd475ac275afe774c81a62e` | [ver](https://stellar.expert/explorer/testnet/tx/9afc6acea745585869651ace4c1cf4d71b212e927fd475ac275afe774c81a62e) |
| 2026-03-02 | 2.08 | `0748358ac4d25fd790f4b61ac050f22066a76f2c2e36daefac1700929127751f` | [ver](https://stellar.expert/explorer/testnet/tx/0748358ac4d25fd790f4b61ac050f22066a76f2c2e36daefac1700929127751f) |
| 2026-03-01 | 2.34 | `2a43a047c3b33706ffc94245151ce5db3a01498d31a196dcbe43e0b60e33b3ea` | [ver](https://stellar.expert/explorer/testnet/tx/2a43a047c3b33706ffc94245151ce5db3a01498d31a196dcbe43e0b60e33b3ea) |

**Edificio Verde** (5 mints, 31.25 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 3.33 | `2a45e920c5ab6415a1035b63d27655aa08cc873b9e28fec26b704d386a9c11c8` | [ver](https://stellar.expert/explorer/testnet/tx/2a45e920c5ab6415a1035b63d27655aa08cc873b9e28fec26b704d386a9c11c8) |
| 2026-03-04 | 8.35 | `2e92f27d6272b6a586a8fa56bc30cff5d4a0ecf4915901276829aa30fec13d16` | [ver](https://stellar.expert/explorer/testnet/tx/2e92f27d6272b6a586a8fa56bc30cff5d4a0ecf4915901276829aa30fec13d16) |
| 2026-03-03 | 4.13 | `c911b4043d2e3cb95fca5d7ef112293c347450bf29dbd6b5feee2c70a76c1573` | [ver](https://stellar.expert/explorer/testnet/tx/c911b4043d2e3cb95fca5d7ef112293c347450bf29dbd6b5feee2c70a76c1573) |
| 2026-03-02 | 4.57 | `0c3a4d61f6f72551f76d37d72a864fa702e17b16331d4de2be7bbf94c8c27a70` | [ver](https://stellar.expert/explorer/testnet/tx/0c3a4d61f6f72551f76d37d72a864fa702e17b16331d4de2be7bbf94c8c27a70) |
| 2026-03-01 | 10.87 | `184b794fd2067cba3c50ce4e026952a1245a285d6050ab54f26542efa553f5d6` | [ver](https://stellar.expert/explorer/testnet/tx/184b794fd2067cba3c50ce4e026952a1245a285d6050ab54f26542efa553f5d6) |

**Taller EcoTech** (5 mints, 32.49 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 6.59 | `c861872b0f108c883950d3b4d51cc4fb62d7cd3b732ddb8967f2bbe7383a4697` | [ver](https://stellar.expert/explorer/testnet/tx/c861872b0f108c883950d3b4d51cc4fb62d7cd3b732ddb8967f2bbe7383a4697) |
| 2026-03-04 | 4.80 | `af4fe7c0516a6e5ea282ec7ecfbfa1c996b721069406ecc94dd7fe5ca8437333` | [ver](https://stellar.expert/explorer/testnet/tx/af4fe7c0516a6e5ea282ec7ecfbfa1c996b721069406ecc94dd7fe5ca8437333) |
| 2026-03-03 | 6.76 | `1d05c048ef7758bc2953b47552659727f3499ebe252af1493d63f8c4a878d5d1` | [ver](https://stellar.expert/explorer/testnet/tx/1d05c048ef7758bc2953b47552659727f3499ebe252af1493d63f8c4a878d5d1) |
| 2026-03-02 | 7.23 | `b35326702a5aa6e5bd9c732b073719b995990b7d2d95eeb7a33e9011054d1b7d` | [ver](https://stellar.expert/explorer/testnet/tx/b35326702a5aa6e5bd9c732b073719b995990b7d2d95eeb7a33e9011054d1b7d) |
| 2026-03-01 | 7.11 | `a4fb514c919e92830a4db12a998fdb054873fbf5655f39a44aa8fec8f2b666a6` | [ver](https://stellar.expert/explorer/testnet/tx/a4fb514c919e92830a4db12a998fdb054873fbf5655f39a44aa8fec8f2b666a6) |

**Granja Solar Sur** (5 mints, 60.62 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 8.27 | `e77c08db545eb4210dbb24ce43ea234b4fd38dbe45ae11666607960c2a8500a1` | [ver](https://stellar.expert/explorer/testnet/tx/e77c08db545eb4210dbb24ce43ea234b4fd38dbe45ae11666607960c2a8500a1) |
| 2026-03-04 | 14.06 | `375a0641f87074188a8c7946823574c1a6688bd336917ec5c12ebbf5f7221551` | [ver](https://stellar.expert/explorer/testnet/tx/375a0641f87074188a8c7946823574c1a6688bd336917ec5c12ebbf5f7221551) |
| 2026-03-03 | 11.56 | `1bc19dc9652fda95cd0c806e3733758c9c9eaad70b1d4ce2c0b6d1cbb7230ce6` | [ver](https://stellar.expert/explorer/testnet/tx/1bc19dc9652fda95cd0c806e3733758c9c9eaad70b1d4ce2c0b6d1cbb7230ce6) |
| 2026-03-02 | 12.10 | `8265d57bc26af482a1c381941e770f2781b5c57ca4cd027415df3155053ee54c` | [ver](https://stellar.expert/explorer/testnet/tx/8265d57bc26af482a1c381941e770f2781b5c57ca4cd027415df3155053ee54c) |
| 2026-03-01 | 14.63 | `fab6f3011ea768f331a10ac72d94a4f5a3b4e0004a0fa895130f86f91d4a844c` | [ver](https://stellar.expert/explorer/testnet/tx/fab6f3011ea768f331a10ac72d94a4f5a3b4e0004a0fa895130f86f91d4a844c) |

**Oficina Limpia** (5 mints, 23.92 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 4.79 | `8f6b01d0b77ccbd5c257420ee8514862776e95a03619f01326d0eedc58ccb1a3` | [ver](https://stellar.expert/explorer/testnet/tx/8f6b01d0b77ccbd5c257420ee8514862776e95a03619f01326d0eedc58ccb1a3) |
| 2026-03-04 | 3.46 | `c4ee172fdae22d55b8b11e36a7d828488c6117c44d849f9ce552ead2a62d9bad` | [ver](https://stellar.expert/explorer/testnet/tx/c4ee172fdae22d55b8b11e36a7d828488c6117c44d849f9ce552ead2a62d9bad) |
| 2026-03-03 | 4.62 | `7d998fb5712dde249bb58d029f6df3bbea78ce0e06ba7ec4704a64782b9ffeef` | [ver](https://stellar.expert/explorer/testnet/tx/7d998fb5712dde249bb58d029f6df3bbea78ce0e06ba7ec4704a64782b9ffeef) |
| 2026-03-02 | 5.91 | `ef30d57117dbf3f1872756f2694e9c40441f4a7225decff4c5a98122a0276d0f` | [ver](https://stellar.expert/explorer/testnet/tx/ef30d57117dbf3f1872756f2694e9c40441f4a7225decff4c5a98122a0276d0f) |
| 2026-03-01 | 5.14 | `dbe1d03dc0342a7469177629a95555a0b419cb834bf2f4abd7909f5f51b2a82c` | [ver](https://stellar.expert/explorer/testnet/tx/dbe1d03dc0342a7469177629a95555a0b419cb834bf2f4abd7909f5f51b2a82c) |

**Almacén Renovable** (5 mints, 34.64 HDROP total):

| Fecha | kWh | Tx Hash | Explorer |
|-------|-----|---------|----------|
| 2026-03-05 | 6.13 | `40315c5b5659621c49e9407e728ee0ef1e32063fdb24c29420b2bd6e5a6855a3` | [ver](https://stellar.expert/explorer/testnet/tx/40315c5b5659621c49e9407e728ee0ef1e32063fdb24c29420b2bd6e5a6855a3) |
| 2026-03-04 | 4.63 | `a7e3f035adb3fd673058fb2995d6910f8432b9c65fc4db2207c094542e671328` | [ver](https://stellar.expert/explorer/testnet/tx/a7e3f035adb3fd673058fb2995d6910f8432b9c65fc4db2207c094542e671328) |
| 2026-03-03 | 8.19 | `a6b408d9e28730d9df79dfd0a47dd610565684364dc6c1685a9b30e5438259c7` | [ver](https://stellar.expert/explorer/testnet/tx/a6b408d9e28730d9df79dfd0a47dd610565684364dc6c1685a9b30e5438259c7) |
| 2026-03-02 | 7.32 | `2e3a53cddc8ca7a76a88e885c2e9655c6c72a7772de336720f8b11b1b645dc94` | [ver](https://stellar.expert/explorer/testnet/tx/2e3a53cddc8ca7a76a88e885c2e9655c6c72a7772de336720f8b11b1b645dc94) |
| 2026-03-01 | 8.37 | `62459c896a238e53778e158dfff2e5143b4ec48398e43a8138b8361dc724b3f7` | [ver](https://stellar.expert/explorer/testnet/tx/62459c896a238e53778e158dfff2e5143b4ec48398e43a8138b8361dc724b3f7) |

### Transfers P2P (3 transacciones)

Llamadas directas a `transfer(from, to, amount)` en el contrato ENERGY_TOKEN. Firmadas por el sender.

| De | A | HDROP | Tx Hash | Explorer |
|----|---|-------|---------|----------|
| Casa Solar Norte | Vecino Consumidor A | 2.00 | `023a669b32c3d56acfbbec910a67067471d083eb8457083521d3989ac3b1cd4f` | [ver](https://stellar.expert/explorer/testnet/tx/023a669b32c3d56acfbbec910a67067471d083eb8457083521d3989ac3b1cd4f) |
| Edificio Verde | Vecino Consumidor B | 5.00 | `30b711ab12693c04452fc79b95ca988205299bc4bee3ed868713346a276700b3` | [ver](https://stellar.expert/explorer/testnet/tx/30b711ab12693c04452fc79b95ca988205299bc4bee3ed868713346a276700b3) |
| Granja Solar Sur | Vecino Consumidor C | 3.00 | `6e4881f6827e25aff88ba5b844f15d1c46feaec0e589800db314e8ee793458c3` | [ver](https://stellar.expert/explorer/testnet/tx/6e4881f6827e25aff88ba5b844f15d1c46feaec0e589800db314e8ee793458c3) |

### Propuestas de gobernanza (2 transacciones)

Llamadas a `create_proposal(proposer, title)` en el contrato COMMUNITY_GOVERNANCE.

| Proposer | Título | Tx Hash | Explorer |
|----------|--------|---------|----------|
| Casa Solar Norte | Instalar medidor inteligente comunitario | `cf69564f9c8656b806d27b0c96b0673d1c101bf461e14c17826de2c74b2b9625` | [ver](https://stellar.expert/explorer/testnet/tx/cf69564f9c8656b806d27b0c96b0673d1c101bf461e14c17826de2c74b2b9625) |
| Edificio Verde | Crear fondo de mantenimiento de paneles | `1225f4a3a7bf2e3ec7335a0b2e8bbe52a5cb1ce99871800a4b4517294fa20d44` | [ver](https://stellar.expert/explorer/testnet/tx/1225f4a3a7bf2e3ec7335a0b2e8bbe52a5cb1ce99871800a4b4517294fa20d44) |

---

## Datos en Supabase

La simulación también pobló las siguientes tablas:

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| `prosumers` | 7 | Productores de energía con su wallet y capacidad de panel |
| `readings` | 35 | Lecturas diarias de kWh inyectados (5 días × 7 prosumidores) |
| `mint_log` | 35 | Log de cada mint con tx_hash y amount_hdrop |
| `offers` | 4 | Ofertas de energía en marketplace (2 activas, 2 vendidas) |

---

## Cómo correr la simulación

### Prerequisitos

1. Servidor Next.js corriendo:
```bash
cd apps/web && pnpm dev
```

2. Tablas en Supabase creadas (solo primera vez):
```bash
npx tsx scripts/setup-db.ts
```

### Ejecutar

```bash
npx tsx scripts/simulate-testnet.ts
```

O con API base custom:
```bash
API_BASE=https://mi-deploy.vercel.app npx tsx scripts/simulate-testnet.ts
```

### Qué esperar

- ~5 min de ejecución (los mints on-chain necesitan ~4s cada uno)
- Al final imprime una tabla resumen con los balances
- Guarda keypairs en `scripts/.testnet-users.json` (gitignored)

### Verificar resultados

- **Dashboard**: Conectar una de las wallets generadas y ver balance HDROP
- **Marketplace**: Ver ofertas en `/marketplace`
- **Explorer**: Verificar transacciones en [Stellar Expert Testnet](https://stellar.expert/explorer/testnet)
- **Supabase**: Revisar tablas directamente en el [dashboard](https://supabase.com/dashboard)

---

## Flujo que se valida

```
Friendbot → Fondear cuenta XLM
     ↓
POST /api/prosumers → Registrar en Supabase
     ↓
POST /api/readings → Crear lectura de energía (status: pending)
     ↓
POST /api/mint → Soroban tx: mint_energy() → status: minted + tx_hash
     ↓
POST /api/offers → Listar energía en marketplace
     ↓
contract.call("transfer") → P2P entre wallets on-chain
     ↓
contract.call("create_proposal") → Gobernanza comunitaria
```

Este flujo cubre el ciclo completo de vida de BeEnergy: desde que un prosumidor genera energía solar hasta que un vecino la compra y la comunidad vota decisiones colectivas.
