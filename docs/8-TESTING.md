# 8. Testing — BeEnergy

Última actualización: **2026-03-07**
Red: **Stellar Testnet**

---

## Unit Tests (API Routes)

45 tests en 10 archivos. Se ejecutan con Vitest.

```bash
cd apps/web && pnpm test
```

| Archivo | Tests | Qué valida |
|---------|-------|------------|
| `cooperatives.test.ts` | 4 | CRUD cooperativas, validación de campos |
| `members.test.ts` | 4 | CRUD miembros, deduplicación por address |
| `meters.test.ts` | 5 | CRUD medidores, filtros por cooperativa y status |
| `readings.test.ts` | 4 | Lectura individual, backward compat (kwh_injected → kwh_generated) |
| `meters-readings.test.ts` | 6 | Ingesta bulk desde medidor, validación meter activo |
| `mint.test.ts` | 6 | Mint por reading_id (legacy) y por certificate_id (nuevo) |
| `certificates.test.ts` | 3 | CRUD certificados, filtros |
| `certificates-retire.test.ts` | 5 | Retiro (burn on-chain), validación buyer_purpose |
| `certificates-stats.test.ts` | 2 | Estadísticas de certificación, CO2 evitado |
| `prosumers.test.ts` | 6 | Legacy proxy, backward compat |

---

## Integration Test — Circuito completo en Stellar Testnet

Test end-to-end que ejecuta el circuito real del producto contra Stellar Testnet.

```bash
npx tsx scripts/integration-test.ts
```

### Qué hace

| Test | Paso | Verificación |
|------|------|-------------|
| 1 | Crear 3 wallets Stellar + fondear con Friendbot | Balance 10,000 XLM |
| 2 | Crear cooperativa + agregar prosumer en Supabase | IDs válidos |
| 3 | Crear medidor + enviar 3 lecturas (38.5 kWh) | Insert OK |
| 4 | Crear certificado + **mint on-chain** (Soroban) | Tx confirmada, status → `available` |
| 5 | Retirar certificado + **burn on-chain** (Soroban) | Tx confirmada, status → `retired` |

### Última ejecución exitosa (2026-03-07)

5/5 tests passed en ~32s.

| Operación | Tx Hash | Explorer |
|-----------|---------|----------|
| **Mint** (38.5 kWh) | `6ec071c2...` | [Stellar Expert](https://stellar.expert/explorer/testnet/tx/6ec071c257f628ba8c544539c8401b47c1cd10bd54a8b4b8bb168fe4c5522070) |
| **Burn** (38.5 kWh) | `afd646aa...` | [Stellar Expert](https://stellar.expert/explorer/testnet/tx/afd646aab80f055d5fec4176772ae67825b63865e42c8aca5d290c5a04ae9218) |

Contrato: Energy Token [`CCYOVOFDJ5...`](https://stellar.expert/explorer/testnet/contract/CCYOVOFDJ5BVBSI6HADLWETTUF3BU423MEAWBSBWV2X5UVNKSJMRPBA6) (ver [5-CONTRACTS.md](5-CONTRACTS.md) para todos los contratos deployados)

### Modelo custodial

Los tokens se mintean a la address del minter (plataforma) y se queman desde la misma address al retirar. El buyer se registra en la tabla `retirements` de Supabase pero no necesita tener tokens on-chain. Esto permite que el server-side maneje todo el ciclo con una sola clave privada (MINTER_SECRET_KEY).

### Cleanup

El test limpia automáticamente los datos de Supabase al finalizar (retirements, mint_log, certificates, readings, meters, prosumers, cooperatives).

---

## Smart Meter Mock

Simulador de medidores inteligentes para generar datos realistas.

```bash
# Generar 7 días de historial
COOPERATIVE_ID=<uuid> pnpm meter:mock:backfill

# Modo continuo (lectura cada 15 min)
COOPERATIVE_ID=<uuid> pnpm meter:mock
```

### Qué genera

- Curva solar gaussiana (pico a las 13:00, sigma ~3h)
- 0 kWh de noche
- Factor climático aleatorio 0.6–1.0
- Limitado por `capacity_kw` de cada medidor
- Envía a `POST /api/meters/readings` (bulk)

---

## Cómo correr los tests

### Unit tests

```bash
cd apps/web && pnpm test
```

### Contract tests (Soroban)

```bash
cd apps/contracts && cargo test
```

### Integration test (Stellar Testnet)

```bash
npx tsx scripts/integration-test.ts
```

Requiere `apps/web/.env.local` con las variables de Stellar y Supabase configuradas.

### Setup DB (primera vez o migración)

```bash
npx tsx scripts/setup-db.ts
```

Requiere `NEXT_PUBLIC_SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY` en `apps/web/.env.local`, y la función `exec_sql` creada en Supabase (ver script para detalle).

---

## Tablas en Supabase

| Tabla | Descripción |
|-------|-------------|
| `cooperatives` | Registro de cooperativas |
| `prosumers` | Miembros (legacy: prosumers, migrado con cooperative_id y role) |
| `meters` | Medidores/dispositivos por cooperativa |
| `readings` | Lecturas de generación (individual y bulk) |
| `certificates` | Proto-certificados de generación renovable |
| `retirements` | Retiros de certificados por compradores externos |
| `mint_log` | Log de transacciones on-chain (mint) |
