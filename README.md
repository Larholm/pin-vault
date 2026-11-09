# PIN Vault — iOS

Native iOS implementation of PIN Vault, based on the Android reference (v5, commit `a9c5865`).

- `docs/SPEC.md`: iOS development specification, Draft v0.2. Items marked with `<mark>` are open for discussion with Lee and David and haven't been decided.
- `Package.swift` / `Sources/PinVaultCore`: the start of a Swift package for the platform-independent grid model (Phase 1). It only has `GridColor` so far.

## Getting started on a Mac

```bash
swift build
swift test
```

Open the folder in Xcode (File › Open… › select the repo) to work on the package. The iOS app target hasn't been created yet.

The iOS 17 minimum in `Package.swift` is a placeholder until OPEN-007 is decided.
