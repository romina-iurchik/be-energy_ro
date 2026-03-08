# 3. BeEnergy — Data Flow

> Cuando te pierdas con el producto, volvé acá.

---

## El producto en una oración

**BeEnergy es un dashboard de gestión cooperativa + infraestructura de certificación on-chain que tokeniza energía renovable como proto-certificados verificables en Stellar, eliminando intermediarios centralizados y reduciendo costos de certificación.**

---

## El flujo completo

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   ☀️  COOPERATIVA GENERA energía renovable                          │
│                                                                     │
│   Paneles solares producen electricidad limpia.                     │
│   La producción se mide con medidores.                              │
│                                                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   📊  MEDIDOR registra kWh generados                                │
│                                                                     │
│   El medidor inteligente envía lecturas automáticamente vía API:    │
│   - POST /api/meters/readings — bulk cada 15 min (automático)       │
│   - POST /api/readings — lectura individual (manual)                │
│                                                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   ✅  COOPERATIVA VALIDA la lectura                                 │
│                                                                     │
│   El admin de la cooperativa revisa el dato en el dashboard         │
│   y confirma que es correcto.                                       │
│                                                                     │
│   Sin validación, no hay certificado. La cooperativa es la          │
│   autoridad sobre sus datos de generación.                          │
│                                                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   🪙  SE MINTEA EL PROTO-CERTIFICADO on-chain                        │
│                                                                     │
│    API: POST /api/certificates → valida + mintea on-chain           │                        │                                                                     │
│   1 token = 1 kWh de generación renovable verificada                │
│   El token es SEP-41 (estándar Stellar)                             │
│   Cada cooperativa tiene su propio token con nombre propio          │
│                                                                     │
│   Contrato: energy_token.mint_energy(miembro, cantidad)             │
│   Distribución: proporcional por participación de cada miembro      │
│   Blockchain: Stellar / Soroban                                     │
│                                                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   🏢  COMPRADOR EXTERNO adquiere certificados                       │
│                                                                     │
│   Empresas ESG, fondos climáticos, programas de compensación        │
│   compran proto-certificados para respaldar su consumo como         │
│   "energía renovable".                                              │
│                                                                     │
│   El comprador paga → los ingresos van a la cooperativa.            │
│                                                                     │
└──────────────────────────┬──────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│                                                                     │
│   🔥  SE RETIRA EL CERTIFICADO → se quema el token                  │
│                                                                     │
│   API: POST /api/certificates/retire → quema tokens on-chain        │                         │                                                                     │
│   El comprador retira (retire) el certificado.                      │
│   Los tokens retirados se queman (burn). No se reusan.              │
│   Esto evita doble conteo del atributo ambiental.                   │
│                                                                     │
│   Contrato: energy_token.burn_energy(comprador, cantidad)           │
│                                                                     │
│   Todo queda registrado en blockchain = auditable por terceros.     │
│   TX hash público en Stellar Explorer.                              │                         │                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ¿Quién es quién?

```
┌──────────────────────┐     ┌──────────────────────┐
│  COOPERATIVA         │     │  MIEMBROS            │
│  (nuestro cliente)   │────▶│  (participantes)     │
│                      │     │                      │
│  • Genera energía    │     │  • Generan energía   │
│  • Carga lecturas    │     │    (si son prosumers)│
│  • Valida datos      │     │  • Reciben tokens    │
│  • Ve analytics      │     │    proporcionales    │
│  • Gestiona miembros │     │  • Ven su generación │
│  • Vende certif.     │     │  • Dashboard propio  │
└──────────┬───────────┘     └──────────────────────┘
           │
           │                 ┌──────────────────────┐
           │                 │  COMPRADOR EXTERNO   │
           └────────────────▶│  (empresa ESG,       │
                             │   fondo climático)   │
                             │                      │
                             │  • Compra certif.    │
                             │  • Retira (burn)     │
                             │  • Declara consumo   │
                             │    como renovable    │
                             └──────────────────────┘
           │
           │  usa
           ▼
┌──────────────────────────────────────────────────────┐
│                                                      │
│   BEENERGY (nosotros)                                │
│                                                      │
│   Infraestructura de certificación                   │
│                                                      │
│   ┌────────────┐  ┌────────────┐  ┌───────────────┐ │
│   │  Dashboard  │  │  API       │  │  Contratos    │ │
│   │  Next.js    │  │  Routes    │  │  Soroban      │ │
│   └──────┬─────┘  └──────┬─────┘  └───────┬───────┘ │
│          │               │                 │         │
│          └───────────────┼─────────────────┘         │
│                          │                           │
└──────────────────────────┼───────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────┐
│                                                      │
│   STELLAR NETWORK                                    │
│                                                      │
│   • Token SEP-41 por cooperativa                     │
│   • Smart contracts Soroban                          │
│   • Registro inmutable y auditable                   │
│   • Fees: ~0.00001 XLM por transacción               │
│                                                      │
│   La blockchain es infraestructura invisible.         │
│   El comprador ve certificados, no transacciones.    │
│   Solo está ahí para que todo sea verificable.       │
│                                                      │
└──────────────────────────────────────────────────────┘
```

---

## Ciclo de vida del token

```
MINT                          TRANSFER                      RETIRE
  │                             │                             │
  ▼                             ▼                             ▼
Cooperativa genera         Comprador externo           Comprador retira
kWh renovables →           adquiere proto-             el certificado →
se mintean tokens          certificados →              burn on-chain →
a miembros por             tokens se transfieren       no se puede
participación              al comprador                reusar (evita
                                                       doble conteo)
```

---

## Cuando me pierda, recuerdo esto

1. **El token es un proto-certificado** — claim verificable de generación renovable, no energía física.
2. **1 token = 1 kWh generado.** Siempre. Sin excepción.
3. **El comprador es externo** — empresas ESG, fondos climáticos, no miembros de la cooperativa.
4. **No es P2P** — los miembros no intercambian tokens entre ellos.
5. **Burn = retiro del certificado.** Evita doble conteo del atributo ambiental.
6. **Miembros = participantes de la cooperativa.** Tres modelos posibles (prosumers, copropietarios, mixto).
7. **Blockchain es invisible.** Está para trazabilidad y auditoría, no para que nadie la vea.
8. **Proto-certificado ≠ REC formal.** Para ser REC necesita metadata, verificación independiente, estándar reconocido.
9. **Cooperativa valida SIEMPRE.** Sin validación de la cooperativa, no hay mint. La cooperativa es la autoridad sobre sus datos.

---
## Estados del certificado

Un certificado pasa por estos estados:
```
GENERADO          VALIDADO           MINTEADO          TRANSFERIDO        RETIRADO
   │                 │                  │                   │                │
   ▼                 ▼                  ▼                   ▼                ▼
Medidor          Cooperativa        Blockchain         Comprador       Certificado
registra  →      valida     →      emite token  →     adquiere   →    quemado
kWh              lectura            on-chain           (paga)          (burn)

Estado DB:       is_validated:      tx_hash:          transferred_    retired_at:
pending          true               0x7a8b...         to: 0xABC...    timestamp
```

