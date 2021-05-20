# WASM Barcode

One of the 3 pre-challenges made for the NorzhCTF 2021.

## How to build

```
wasm-pack build
```

## How to use

```
import * as secure from "secure-id";

let output = new Uint8Array(32);
secure.crypt("What must be encrypted will be", output);
```

We used this lib with this barcode generator : [https://github.com/bkuzmic/pdf417-js](https://github.com/bkuzmic/pdf417-js).


