## Subasta: Smart Contract en Solidity

Este proyecto implementa una subasta descentralizada mediante un contrato inteligente desplegado en la red **Sepolia**. El contrato permite a los usuarios ofertar, visualizar las ofertas y realizar reembolsos de forma segura.

---

## 📍 Contrato desplegado y verificado

- 🔗 **URL del contrato en Sepolia:** [Pega aquí la URL de tu contrato en Etherscan]  
- 💾 **Repositorio GitHub:** [Pega aquí la URL de tu repositorio público]

---

## ⚙️ Funcionalidades Requeridas

### 📦 Constructor
Inicializa la subasta configurando:
- El tiempo de duración.
- El precio inicial.

### 🏷️ Función para ofertar
Permite a los usuarios enviar ofertas con los siguientes requisitos:
- La oferta debe ser **al menos un 5% mayor** que la mejor oferta actual.
- La oferta solo es válida si se realiza **mientras la subasta esté activa**.
- Las ofertas son **enviadas como depósitos** al contrato.

### 🥇 Mostrar ganador
Función que devuelve:
- La dirección del oferente ganador.
- El valor de su oferta ganadora.

### 📜 Mostrar ofertas
Devuelve un array con:
- Todas las direcciones que participaron.
- Sus respectivos montos ofrecidos.

### 💸 Devolver depósitos
Al finalizar la subasta:
- Se devuelve el depósito a los oferentes **no ganadores**.
- Se aplica una **comisión del 2%** al monto a reembolsar.

---

## 💰 Manejo de Depósitos
- Las ofertas se depositan directamente en el contrato (`msg.value`).
- Se lleva registro de cada dirección ofertante y su historial.

---

## 📢 Eventos

- `NewOffer`: Se emite al recibir una nueva oferta válida.
- `AuctionEnded`: Se emite cuando finaliza la subasta.
- `AuctionWinner`: Se emite con el resultado final de la subasta.

---

## 🚀 Funcionalidades Avanzadas

### 🔁 Reembolso parcial
Durante la subasta, un participante puede retirar el excedente de sus ofertas anteriores.  
**Ejemplo:**
- `T0`: Usuario A ofrece 1 ETH.
- `T1`: Usuario B ofrece 2 ETH.
- `T2`: Usuario A ofrece 3 ETH.
- ✅ Usuario A puede pedir el reembolso de su oferta en `T0` (1 ETH).

### ⏳ Extensión del tiempo
Si una oferta válida se realiza **dentro de los últimos 10 minutos** antes del cierre, el contrato extiende el plazo de subasta **otros 10 minutos automáticamente**.

---

## 🔐 Seguridad y Buenas Prácticas

- Se utilizan `modifiers` para:
  - Validar la propiedad del contrato.
  - Comprobar si la subasta está activa.
  - Verificar que el tiempo límite no se haya cumplido.
- Se aplican buenas prácticas de control de errores con `require` y `assert`.
- Se evita el uso de operaciones peligrosas como `tx.origin`.
- Todas las transferencias de Ether se realizan con `call` para mayor control.

---

## 📄 Documentación Técnica

### 🔸 Variables de Estado
- `owner`: dirección del creador del contrato.
- `bidders`: array de structs `Bidder`, que almacena cada oferente.
- `winner`: struct del ganador actual.
- `bidPrice`: precio actual de la subasta.
- `auctionStart`, `auctionEnd`: tiempos de inicio y fin.

### 🔸 Estructuras
```solidity
struct Bidder {
  address addressBidder;
  uint amountRefund;
  uint amountBid;
  uint offerTime;
}
