## 1.0.0

## 0.0.1 - 2021-10-07

### Initial Release
- BramblClient has the ability to send JSON-RPC requests to a node that is running the Bifrost protocol
- Credentials can now be imported through an encoded private key, encrypted keyfile, or generated deterministically through the HDWallet


### Core libraries
- client: has all of the JSON_RPC and signing capabilities
- credentials: used to modify, store, and create credentials used by the bramblclient to sign transactions
- model: used to represent the application view of the blockchain
- crypto: used to encrypt keyfiles
- utilities: various utilities that help users to make or sign transactions or interact with credentials. 
