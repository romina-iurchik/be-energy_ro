# be.energy — Como funciona (flujo real paso a paso)

## Lo primero que hay que entender

**La energia y los creditos son dos cosas separadas.**

La energia (electrones) viaja por cables fisicos. Siempre. No viaja por internet, no viaja por blockchain, no viaja por Stellar. Los electrones van del panel solar → al cable → a la red electrica. Punto.

Lo que si viaja por Stellar es el **registro del credito**: quien genero cuanta energia, quien la compro, y cuanto pago. Es como un recibo digital inmutable.

Pensalo asi: cuando haces una transferencia bancaria, los billetes fisicos no viajan por internet. Lo que viaja es la informacion del movimiento de plata. Con be.energy pasa lo mismo: la energia va por la red electrica, el credito va por Stellar.

---

## CAPA FISICA (electrones — esto ya existe hoy)

### Paso 1: El sol pega en los paneles

Una familia tiene paneles solares en el techo (como los que vende Energetica Sur: paneles fotovoltaicos de silicio). El sol genera corriente continua (CC) en los paneles.

### Paso 2: El inversor convierte la energia

Un **inversor ON GRID o HIBRIDO-INYECCION** (conectado a la red electrica) convierte la corriente continua del panel en corriente alterna (CA) de 220V 50Hz — la misma electricidad que sale del enchufe.

Hay dos escenarios en cada momento:
- **Si la familia consume mas de lo que genera** → la energia del panel se usa en la casa y el resto lo toma de la red normalmente.
- **Si la familia genera mas de lo que consume** → el excedente se inyecta automaticamente a la red electrica. Sale de la casa hacia afuera.

Esto pasa en tiempo real, automaticamente. No hay que apretar ningun boton.

### Paso 3: El medidor bidireccional registra todo

En la casa del prosumidor hay un **medidor bidireccional** (obligatorio por Ley 27.424). Este medidor mide dos cosas:
- **Energia consumida de la red** (kWh que entran a la casa)
- **Energia inyectada a la red** (kWh que salen de la casa)

El medidor registra ambos valores. La distribuidora o cooperativa lee este medidor periodicamente (mensual o bimestral, depende de la jurisdiccion).

**Importante:** El medidor bidireccional NO es un "smart meter" con WiFi ni IoT (en la mayoria de los casos en Argentina). Es un medidor que simplemente tiene dos contadores. La lectura la hace un empleado de la cooperativa, igual que la lectura de luz normal.

### Paso 4: La energia inyectada va a la red del barrio

Cuando el excedente sale de la casa del prosumidor, entra a la red de baja tension del barrio. Esa energia la consume **el vecino mas cercano que este demandando en ese momento**. Es fisica pura: el electron viaja por el cable al punto de menor resistencia.

El vecino no sabe que esta consumiendo energia del panel del vecino de al lado. Para el es electricidad normal. La red no distingue de donde viene cada electron.

**Resumen de la capa fisica:**
```
Sol → Panel → Inversor (CC→CA) → Casa (autoconsumo)
                                    ↓ (si hay excedente)
                                Red electrica del barrio → Vecinos la consumen
                                    ↓
                          Medidor bidireccional registra kWh inyectados
```

**Todo esto ya funciona hoy sin be.energy.** Miles de familias en Argentina ya hacen esto. El problema no es la energia fisica — es que pasa con el credito que genera esa inyeccion.

---

## CAPA DIGITAL (creditos — aca entra be.energy)

### Paso 5: La cooperativa lee el medidor y calcula el credito

La cooperativa lee el medidor bidireccional (manual o digital, depende del caso). Obtiene:
- Familia X inyecto 200 kWh este mes
- Familia X consumio 350 kWh este mes

La diferencia se compensa en factura. Si inyecto mas de lo que consumio, queda un **credito a favor** en pesos, que se arrastra al mes siguiente. Esto se llama **balance neto de facturacion** (Art. 12 de la Ley 27.424).

**Hoy, sin be.energy:** La cooperativa anota esto en Excel o en su sistema de facturacion. El prosumidor ve un numero en la factura (si tiene suerte). No puede hacer nada con ese credito excepto esperar a que se le descuente.

### Paso 6: be.energy digitaliza el dato de inyeccion (ACA ENTRAMOS NOSOTROS)

La cooperativa, en vez de solo anotar el dato en Excel, lo carga tambien en be.energy. Esto puede ser:

**Opcion A (hoy, MVP):** El admin de la cooperativa entra al dashboard de be.energy y carga manualmente: "Familia X inyecto 200 kWh en febrero 2026". Es un formulario simple.

**Opcion B (futuro cercano):** La cooperativa exporta un CSV de su sistema de facturacion con las lecturas de todos los medidores, y be.energy lo procesa automaticamente.

**Opcion C (futuro con inversion):** Medidores inteligentes (smart meters) con conectividad (WiFi, LoRa, celular) envian datos automaticamente a un servidor/API. be.energy lee esa API. Esto requiere hardware nuevo y es la version mas avanzada.

**No hay IA en este paso.** No se necesita inteligencia artificial para saber cuanto genero una familia. El medidor bidireccional ya lo mide con precision de kWh. Es un numero que la cooperativa ya tiene.

### Paso 7: be.energy emite HDROP en Soroban

Contra el dato validado por la cooperativa ("Familia X inyecto 200 kWh"), el smart contract de Soroban emite 200 HDROP a la wallet de la Familia X.

```
1 HDROP = 1 kWh de credito de inyeccion verificado por la cooperativa
```

**Quien autoriza el mint?** La cooperativa. Solo la cooperativa puede disparar la emision, porque es la unica que tiene la lectura del medidor. En el mundo crypto esto se llama "oraculo" — pero aca no es un oraculo sofisticado ni un servicio externo. Es simplemente la cooperativa haciendo lo que ya hace (leer el medidor) y cargando el dato en un sistema que emite tokens contra esa lectura.

**Puede alguien falsear kWh?** Solo si la cooperativa miente. Pero la cooperativa es la misma entidad que ya hace la lectura para la facturacion normal. Si falsean datos en be.energy, tambien estan falseando facturas — algo que ya es controlado por los entes reguladores provinciales.

### Paso 8: El prosumidor decide que hacer con sus HDROP

Ahora Familia X tiene 200 HDROP en su wallet. Tres opciones:

**A) Vender en el marketplace P2P:**
Familia X lista: "Vendo 100 HDROP a $50 ARS cada uno". El vecino (que no tiene paneles) ve la oferta, acepta, y paga. be.energy ejecuta un swap atomico en Stellar: los 100 HDROP van al vecino, los $5.000 ARS van a Familia X. Instantaneo, ~5 segundos, costo ~$0.

**B) Depositar en el pool comunitario:**
Familia X deposita 200 HDROP en el pool DeFindex de la cooperativa. Los creditos se distribuyen proporcionalmente entre todos los consumidores que participan del pool. Es como una "canasta comunitaria" de energia solar.

**C) No hacer nada:**
Los HDROP quedan en su wallet. El credito sigue existiendo en la factura de la cooperativa como siempre. be.energy no reemplaza el mecanismo normal de facturacion — es una capa adicional.

### Paso 9: El vecino que compro HDROP presenta el credito

El vecino tiene 100 HDROP. Que hace con ellos? La cooperativa reconoce esos HDROP como creditos transferidos bajo Art. 12f. En la facturacion del vecino, se descuentan los kWh equivalentes.

**En la practica:** El vecino consumio 400 kWh este mes. Tiene 100 HDROP. La cooperativa le factura solo 300 kWh. El ahorro viene de la diferencia entre el precio al que compro el HDROP (acordado P2P) y la tarifa plena que le cobraria la distribuidora.

### Paso 10: Todo queda registrado on-chain

Cada paso — emision, transferencia, venta, redencion — queda registrado en Stellar. Cualquier socio de la cooperativa puede verificar en Stellar Expert:
- Cuantos HDROP se emitieron (= cuanta energia se inyecto)
- Quien los tiene
- A que precio se vendieron
- Cuando se redimieron

Esto reemplaza el Excel opaco con un registro publico e inmutable.

---

## DIAGRAMA COMPLETO

```
☀️ SOL
 │
 ▼
┌─────────────┐
│ PANEL SOLAR │  ← Hardware (ya existe, lo vende Energetica Sur y otros)
└──────┬──────┘
       │ Corriente continua (CC)
       ▼
┌──────────────┐
│  INVERSOR    │  ← ON GRID o HIBRIDO (ya existe, lo instala un electricista)
│  CC → CA     │
└──────┬───────┘
       │ Corriente alterna 220V
       ▼
┌──────────────────────────────┐
│         CASA                  │
│  Si consumo < generacion:     │
│    → excedente sale a la red  │
│  Si consumo > generacion:     │
│    → toma de la red           │
└──────────────┬───────────────┘
               │ Excedente
               ▼
┌──────────────────────────────┐
│   MEDIDOR BIDIRECCIONAL      │  ← Hardware obligatorio (ya existe)
│   Cuenta: kWh entrada/salida │
└──────────────┬───────────────┘
               │
═══════════════╪═══════════════════════════════════════
               │  ↑↑↑ CAPA FISICA (ya funciona sin nosotros) ↑↑↑
               │  ↓↓↓ CAPA DIGITAL (aca entra be.energy) ↓↓↓
═══════════════╪═══════════════════════════════════════
               │ Dato: "Familia X inyecto 200 kWh"
               ▼
┌──────────────────────────────┐
│   COOPERATIVA (oraculo)      │  ← Lee el medidor y carga el dato
│   Dashboard be.energy        │     en be.energy (manual o CSV o API)
└──────────────┬───────────────┘
               │ Valida y autoriza mint
               ▼
┌──────────────────────────────┐
│   SMART CONTRACT SOROBAN     │  ← Emite 200 HDROP a wallet Familia X
│   Mint: 200 HDROP            │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────────────────────┐
│              PROSUMIDOR DECIDE               │
│                                              │
│  A) Vender P2P    B) Pool comunidad   C) Hold│
│     en marketplace    DeFindex               │
└───────┬──────────────┬───────────────────────┘
        │              │
        ▼              ▼
┌──────────────┐ ┌──────────────┐
│ VECINO COMPRA│ │ POOL REPARTE │
│ Swap atomico │ │ Proporcional │
│ HDROP ↔ ARS  │ │ a socios     │
│ (~5 seg)     │ │              │
└──────┬───────┘ └──────┬───────┘
       │                │
       ▼                ▼
┌──────────────────────────────┐
│   FACTURACION COOPERATIVA    │  ← Reconoce HDROP como credito Art.12f
│   Vecino: 400 - 100 = 300   │     Descuenta kWh de la factura
│   kWh facturados             │
└──────────────────────────────┘
```

---

## PREGUNTAS QUE SEGURO TENES

**Necesito smart meters / IoT / router especial?**
No para el MVP. El medidor bidireccional que ya tiene el prosumidor es suficiente. La cooperativa carga el dato manualmente o por CSV. Smart meters con API son una mejora futura que automatiza el proceso pero no es requisito.

**Donde entra la IA?**
No entra. No se necesita. El medidor mide kWh con precision. No hay que "calcular" nada con IA. El calculo es aritmetico: kWh inyectados - kWh consumidos = credito. Lo hace el medidor y la cooperativa.

**La energia se "reparte" con blockchain?**
No. La energia se reparte por fisica (va al vecino mas cercano que demanda). Blockchain reparte los **creditos** (el derecho economico sobre esa energia). Son dos capas independientes.

**El vecino que compra HDROP recibe los electrones del prosumidor?**
No necesariamente. Lo que recibe es el **credito economico** de esa inyeccion. La energia fisica puede haber ido a cualquier punto de la red. Pero el credito es verificable: se genero, se transfirio, se aplico en factura. Igual que un bono de carbono no te manda aire limpio a tu casa — te da el credito.

**Que hardware necesita un prosumidor para participar?**
Lo que ya tiene: paneles + inversor on-grid + medidor bidireccional + contrato de usuario-generador con la cooperativa. be.energy no requiere hardware adicional. Solo necesita un celular para usar la app/wallet.

**Y el link de Energetica Sur?**
Energetica Sur vende el hardware (paneles, inversores, baterias, termotanques solares). Son un posible partner comercial: ellos venden el hardware, nosotros damos la capa de credito digital. Pero no son parte del stack tecnico de be.energy.

---

## EN RESUMEN

| Componente | Que hace? | Quien lo provee? | be.energy lo toca? |
|---|---|---|---|
| Panel solar | Genera electricidad del sol | Energetica Sur, Sungrow, etc. | No |
| Inversor ON GRID | Convierte CC→CA, inyecta excedente | Fabricantes (Sungrow, Growatt, etc.) | No |
| Medidor bidireccional | Cuenta kWh entrada/salida | Distribuidora/cooperativa (obligatorio) | No (lee el dato) |
| Red electrica | Transporta electrones | Cooperativa/distribuidora | No |
| Dashboard cooperativa | Carga lectura del medidor a be.energy | **be.energy** | Si |
| Smart contract Soroban | Emite HDROP contra lectura validada | **be.energy** | Si |
| Marketplace P2P | Permite venta de creditos entre vecinos | **be.energy** | Si |
| Pool DeFindex | Distribucion comunitaria de creditos | **be.energy** | Si |
| Wallet (Freighter) | Prosumidor gestiona sus HDROP | **be.energy** (UX) + Stellar | Si |
| Facturacion | Aplica HDROP como descuento en factura | Cooperativa (con dato de be.energy) | Parcial (informa) |

**be.energy NO toca la capa fisica.** No instalamos paneles, no ponemos medidores, no manejamos la red. Hacemos la capa de credito digital que falta entre el medidor y la factura.
