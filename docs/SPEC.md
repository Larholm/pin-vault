> Source: *PIN Vault iOS Development Specification — Draft v0.2 (22 Oct 2026), review-highlights edition*, converted from .docx. Items highlighted for Lee/Brian review in the original are discussion points, not agreed decisions. The decision register is in Section 11 and the open questions are in Appendix A §16.

# PIN Vault — iOS Development Specification

Draft v0.2 \| 22 October 2026

Prepared for Brian • Review with Lee and the Android product owner

Android reference: native Java PIN Vault, version 5; commit a9c5865cfba9a5a0b9a35d6cc08b335683c9a8c4

**<mark>REVIEW GUIDE: Yellow highlighting identifies questions, assumptions and decisions for Lee and Brian to review together. The decision register in Section 11 and the detailed OPEN-001–OPEN-024 list in Appendix A are highlighted in full. Highlighting does not mean a decision has been made.</mark>**

<mark>STATUS: DISCUSSION DRAFT — not an agreed scope, implementation contract or release commitment.</mark>

# Document control

| Item              | Position                                                                                                            |
|-------------------|---------------------------------------------------------------------------------------------------------------------|
| Purpose           | Define a practical native iOS starting point based on the current Android app.                                      |
| Reference         | Codex source-observed functional specification, reproduced in Appendix A.                                           |
| Android ownership | Lee continues Android development and publication.                                                                  |
| iOS ownership     | <mark>Brian is prospective iOS implementation collaborator; delivery terms remain to be agreed.</mark> |
| Decisions         | Open questions are explicitly deferred pending joint discussion.                                                    |
| Verification      | Android source inspection only; no current end-to-end build/test verification.                                      |

# 1. Executive brief

PIN Vault helps users remember numeric secrets using a named 8-column × 5-row grid of coloured digits. Users mark genuine PIN cells and fill other cells with decoys. The application stores selected-cell flags, but not the user’s intended reading order. Local encryption and device authentication protect the saved vault.

<mark>The iOS objective is functional equivalence where agreed, delivered using native iOS conventions. It is not a line-by-line port of Java/Android APIs, and it must not reproduce known Android defects.</mark>

# 2. Scope and interpretation

| Classification                          | Meaning                                                                                                    |
|-----------------------------------------|------------------------------------------------------------------------------------------------------------|
| Confirmed Android behaviour             | Observed in Android source at the reference revision; target for discussion, not automatic iOS commitment. |
| Proposed iOS approach                   | Suggested engineering direction, subject to Brian’s design and platform validation.                        |
| Acceptance candidate                    | Testable outcome to confirm after launch scope is agreed.                                                  |
| <mark>Open decision</mark> | Unresolved matter for the three collaborators; no decision is assumed.                                     |
| Out of current scope                    | No current Android implementation or explicit commitment.                                                  |

Initial candidate scope: onboarding, authentication, grid creation/editing, gallery, reveal, favourites/order, appearance, local encrypted storage, password-protected backup/restore, free/Pro allowances, purchase/restore, help/support and accessibility.

Not currently implemented in Android: automatic cloud sync, accounts, search, folders, OTP, text-password storage, scheduled backups and shared cross-platform entitlements.

# 3. Functional requirements by capability

| Reference     | Behaviour required for parity discussion                                                                                                                                                                                                                   |
|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| GRID-001–018  | Exactly 40 cells (8 × 5), ten each of red/blue/green/yellow in newly generated grids; secure random placement; digits 0–9; genuine cells explicitly selected; decoys fill blanks only; save requires name, complete digits and at least one selected cell. |
| FLOW-001–007  | Create, edit and delete named grids; edit retains identity; modified drafts prompt on Back; deletion requires confirmation; backgrounding clears unsaved drafts in current Android policy.                                                                 |
| VIEW-001–009  | Gallery shows digits without marking real cells; press-and-hold temporarily highlights genuine cells; cancellation, page change and exit remove highlights; accessible explicit reading lists positions, not reading order.                                |
| ORG-001–011   | All/Favourites filtering; reorder and favourite via draft then Save/Cancel; encrypted organisation metadata; no modification of cell positions.                                                                                                            |
| ENT-001–016   | Free: two grids, six selected cells per grid. Pro: unlimited grids, up to 40 selected cells. Existing larger grids remain readable/editable within saved allowances. Restore restrictions require policy review.                                           |
| SEC-001–016   | Authenticate before sensitive content; foreground session; background/screen-lock ends access; authenticated encryption for all sensitive grid/organisation fields; secure key handling; protected screenshots/previews where feasible.                    |
| BACK/REST/REC | Password-encrypted portable backup; preview counts and Keep local / Use backup / Replace all; validate before commit; explicitly warn on unavailable local keys and destructive recovery.                                                                  |
| BUY-001–017   | One-time non-consumable Pro purchase, store price/eligible offers, restore ownership, no Pro on pending payment; platform-specific StoreKit design required.                                                                                               |
| UX/ERR        | Light/Dark/Auto; scalable layouts, VoiceOver support, protected dialogs, clear error states and non-disclosure in support links.                                                                                                                           |

# 4. Screen catalogue

<mark>Each screen below is a behavioural reference. Navigation and visual layout may adopt native iOS patterns once agreed.</mark>

| Screen IDs | Screen / key behaviours                                                                                                            |
|------------|------------------------------------------------------------------------------------------------------------------------------------|
| 001–002    | Locked entry and How it works: unlock, intro, public support; onboarding is skippable and revisitable.                             |
| 003–005    | Gallery and empty states: horizontally paged grids, All/Favourites, page counter, create, backup, Pro, organise, restore guidance. |
| 006–009    | Editor, digit keypad, discard-changes confirmation and free selection-limit explanation.                                           |
| 010–011    | Organise grids; explicit accessible reading of selected cell positions/digits.                                                     |
| 012–016    | Backup/restore hub, export password, file import, password preview and restore confirmation.                                       |
| 017        | Pro comparison, store pricing, buy, restore purchase and billing status.                                                           |
| 018–020    | Help/settings, appearance selection and About/support with privacy warning.                                                        |

# 5. Proposed iOS technical architecture — for review

- <mark>Native Swift application, with SwiftUI as a candidate presentation layer; Brian to confirm minimum iOS version and any UIKit components needed for protected interactions.</mark>

- <mark>Use LocalAuthentication for supported Face ID/Touch ID/device-passcode flows; agree exact fallback and session invalidation semantics rather than assuming Android parity.</mark>

- Use Keychain and platform-protected keys for vault-key material; authenticated encryption through a reviewed Apple-supported cryptographic implementation. Never copy Android Keystore aliases or Room schema.

- Use an encrypted on-device persistence layer that protects grid names, digits, colours, selected-cell flags, favourites and order. Ensure data lifecycle and backup exclusions are explicitly designed.

- Use StoreKit 2 as a candidate for non-consumable Pro ownership and restore, with entitlement validation and offline behaviour designed and tested independently.

- Use iOS document import/export APIs for user-selected encrypted backup files. Do not promise PV2 cross-platform compatibility until decided and cryptographic test vectors exist.

- Plan for VoiceOver, Dynamic Type, reduced-motion preferences, scene/background transitions and App Store privacy disclosures.

# 6. Security and recovery design checkpoints

- The application must never store the user’s remembered reading order or a reconstructed ordered PIN.

- Define what “Lock vault” does: Android currently has a navigation control whose label does not explicitly clear the session. iOS should not inherit that ambiguity.

- Clarify whether backgrounding, task switching, file pickers and multiple scenes invalidate the session and discard drafts; document exceptions.

- Treat recovery from a lost/unavailable local key as a high-risk, explicitly confirmed flow; avoid claims of atomic rollback until proven.

- <mark>Agree whether free-tier limits can block recovery of previously owned data; this is a product policy question, not a coding default.</mark>

- Limit decrypted data exposure in UI, logs, screenshots, diagnostics and temporary files; document platform limits on complete memory wiping and screen recording protection.

# 7. Backup and compatibility boundary

Android implements a PV2 password-encrypted file: PBKDF2-HMAC-SHA256, AES-256-GCM, a versioned authenticated header and JSON grid payload. The source appendix contains byte offsets, iteration counts, payload schema and validation rules. These details are reference evidence only, not an approved iOS format contract.

<mark>Until Lee and Brian agree on interoperability, Brian may design an iOS-local encrypted export/restore path, but should isolate the format implementation behind a versioned interface and avoid irreversible format assumptions.</mark>

# 8. Proposed implementation milestones

| Phase                  | Proposed deliverables                                                                                                                      | Exit evidence                                                  |
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| 0 — Alignment          | <mark>Review this document, agree initial feature scope, minimum OS, ownership, open decisions affecting architecture.</mark> | Signed-off phase-1 scope and tracked decisions.                |
| 1 — Core model/UI      | 40-cell model, colour generation, editor, decoys, validation, local gallery, delete, empty states.                                         | Unit tests and simulator demonstration with synthetic data.    |
| 2 — Secure vault       | Authentication, encryption/key management, foreground locking, protected reveal, lifecycle handling.                                       | Threat-model review and device tests with synthetic secrets.   |
| 3 — Organisation/UX    | Favourites, ordering, appearance, intro, help, VoiceOver/Dynamic Type.                                                                     | Accessibility and state-transition acceptance.                 |
| 4 — Backup/recovery    | Encrypted export, import preview, conflict strategies, error handling, lost-key policy.                                                    | Round-trip and negative tests, interrupted recovery scenarios. |
| 5 — Commercial/release | Free/Pro limits, StoreKit purchase/restore, privacy, TestFlight and App Store assets.                                                      | Sandbox billing tests and release checklist.                   |

<mark>Milestones are a suggested sequencing framework, not an agreed delivery schedule. Brian may propose alternatives.</mark>

# 9. Acceptance checklist — initial candidates

- A new grid always has 40 positions and the correct colour distribution; decoy filling never changes selected digits.

- Free users cannot create a third grid or select a seventh genuine cell in a new grid; Pro allows up to 40 genuine cells.

- Saving an edit preserves the record identity and any applicable grandfathered allowance.

- The gallery never reveals selected-cell status during ordinary viewing; reveal clears reliably on release, interruption and navigation.

- Organise Save persists changes atomically; Cancel makes no persistent changes.

- Sensitive data cannot be accessed after a defined session-lock event without renewed authentication.

- Wrong-password, corrupt-file, unsupported-version and truncated backups fail without partial import.

- Restore previews counts and consequences; each conflict strategy produces the expected final set.

- <mark>A pending purchase never unlocks Pro; ownership restoration and offline handling work as agreed.</mark>

- Core flows are usable with VoiceOver, large text and supported iPhone sizes.

The detailed source-derived acceptance scenarios AC-001–AC-026 appear in Appendix A; they are candidates, not all currently verified.

# 10. Risks and Android differences not to replicate

| Risk / limitation                                                     | iOS treatment                                                               |
|-----------------------------------------------------------------------|-----------------------------------------------------------------------------|
| Gallery “Lock vault” does not explicitly clear shared Android session | Specify and test explicit locking if retained.                              |
| Recovery above free quota may require Pro                             | Keep as unresolved commercial/recovery policy.                              |
| Key replacement and database rollback not atomic                      | Design failure-safe recovery and test interruption paths.                   |
| Export may exceed importer’s 1,000-grid limit                         | Specify symmetric limits or versioned large-backup support.                 |
| Duplicate-content grids may be hidden in Android gallery              | Preserve distinct record identities unless product decision says otherwise. |
| Partial schema validation and mutable timestamp ordering              | Agree strict schema, order and migration behaviour.                         |
| Live billing and full device matrix not verified                      | Require independent iOS release acceptance.                                 |

# 11. Decision register — pending Lee/Brian discussion

| Priority                                                | Decision                                                                                                          | Status                                    |
|---------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|-------------------------------------------|
| <mark>Before architecture lock</mark>      | <mark>iOS minimum version; biometric/passcode fallback; scene/session/explicit lock semantics</mark> | <mark>Open</mark>            |
| <mark>Before backup implementation</mark>  | <mark>Android↔iOS PV2 compatibility, versioning and test vectors</mark>                              | <mark>Open — deferred</mark> |
| <mark>Before billing implementation</mark> | <mark>Platform-specific or shared Pro ownership; purchase restoration policy</mark>                  | <mark>Open — deferred</mark> |
| <mark>Before product sign-off</mark>       | <mark>Launch parity, exact free/Pro limits, grandfathering and recovery entitlement</mark>           | <mark>Open</mark>            |
| <mark>Before visual sign-off</mark>        | <mark>Exact colours/layout versus native iOS conventions; brand/support details</mark>               | <mark>Open</mark>            |
| <mark>Before release</mark>                | <mark>Privacy policy, accessibility/device matrix, App Store account, ownership and support</mark>   | <mark>Open</mark>            |
| <mark>Ongoing</mark>                       | <mark>Feature coordination, change approval, release-version alignment with Lee</mark>               | <mark>Open</mark>            |

Appendix A preserves the full 24-question OPEN-001–OPEN-024 register, with no assumed answers.

# 12. Working arrangements and change control

Lee remains responsible for Android changes. Brian can use this specification and the source appendix as reference, but any shared product decision should be recorded separately before it changes either platform. Future Android changes should be reviewed against the pinned reference revision and classified as essential parity, optional enhancement or Android-specific.

<mark>Commercial collaboration, IP, publication accounts and revenue allocation are outside this technical specification and require separate agreement.</mark>

# Appendix A — Source-observed Android functional specification

The following material reproduces the Codex report supplied on 22 October 2026, preserving its requirement identifiers, technical values, caveats and source catalogue. It is a reference, not an approved iOS contract.

# PIN Vault — Functional Specification for the Native iOS Reference

Reference revision: a9c5865cfba9a5a0b9a35d6cc08b335683c9a8c4

Reference application: Native Android PIN Vault, version name/code 5

Purpose: Describe the current Android product for Brian’s separate native iOS implementation.

## 1. Scope and interpretation

This specification describes source-observable Android behavior. It does not establish that Android and iOS must launch with identical functionality.

Requirement identifiers are stable checklist references:

- Implemented: supported by current Android source.

- Intended: documented security or reliability requirement whose complete runtime guarantee is not established.

- Roadmap: documented but not implemented.

- <mark>Open: requires agreement between Lee, Brian and David.</mark>

Statements about Android APIs, storage frameworks, billing or screen protection are reference implementation details, not instructions to reproduce those APIs on iOS.

No builds, installations, device interactions or repository changes were performed for this specification.

### Evidence hierarchy

1.  Current source establishes implemented behavior.

2.  SECURITY.md, BILLING.md and the current maintainer handover explain policy.

3.  Dated testing/build records describe verification of particular builds.

4.  The historical development handover supplies background; its three-grid proposal and missing-billing statements are superseded.

Source references such as \[S4\] resolve to the source catalogue at the end.

## 2. Product purpose and core concepts

| ID       | Functional requirement or concept                                                                                                     | Status                 |
|----------|---------------------------------------------------------------------------------------------------------------------------------------|------------------------|
| PROD-001 | Store reminders for numeric secrets: card PINs, banking-app PINs, computer PINs, combination locks, safes and keypads.                | Implemented            |
| PROD-002 | Represent each secret using a named, coloured grid containing genuine digits and decoys.                                              | Implemented            |
| PROD-003 | Let the user choose which cells are genuine and remember their own reading order. The application does not store that reading order.  | Implemented            |
| PROD-004 | Treat colours and decoys as a memory aid/visual concealment technique. Encryption protects persisted data.                            | Implemented/documented |
| PROD-005 | Operate without a PIN Vault account or application-managed cloud synchronisation.                                                     | Implemented            |
| PROD-006 | Offer a limited free tier and a one-time Pro purchase. Core encryption, authentication and local backup controls exist in both tiers. | Implemented            |

Target users: Individuals retaining PINs or numeric combinations who can recognise or explicitly reveal their chosen cells. Accessibility users can inspect selected positions and digits without relying solely on colour or a continuous touch.

Terminology

- Grid/card: One named collection of 40 cells.

- PIN cell: A cell explicitly selected by the user as genuine.

- Decoy: A non-selected digit used to fill the grid.

- Pattern: The user’s remembered cell locations.

- Reading order: The user’s remembered sequence through those locations.

- Vault: The device’s saved grid collection.

- Foreground session: The period after authentication while the application remains in use.

- Backup: A password-encrypted portable PV2 file; distinct from purchase restoration.

Sources: \[S2\], \[S3\], \[S4\], \[S16\].

## 3. Feature inventory

### 3.1 Implemented features

| ID       | Feature                                                                |
|----------|------------------------------------------------------------------------|
| FEAT-001 | First-launch introduction and revisitable guidance                     |
| FEAT-002 | Device-authenticated vault access and foreground sessions              |
| FEAT-003 | Create, name, edit and delete grids                                    |
| FEAT-004 | Random colour distribution and random decoy filling                    |
| FEAT-005 | Swipeable, vertically scrollable grid pages                            |
| FEAT-006 | Momentary visual PIN-cell reveal                                       |
| FEAT-007 | Keyboard reveal and explicit accessibility reading dialog              |
| FEAT-008 | All grids and Favourites sections                                      |
| FEAT-009 | Manual card ordering and favourite selection                           |
| FEAT-010 | Light, Dark and device-following appearance                            |
| FEAT-011 | Encrypted local persistence                                            |
| FEAT-012 | Password-encrypted PV2 export                                          |
| FEAT-013 | Restore preview and three conflict/replacement strategies              |
| FEAT-014 | Explicit recovery from an unavailable local encryption key             |
| FEAT-015 | Two-grid/six-selected-cell free tier and grandfathering                |
| FEAT-016 | Google Play Pro purchase, entitlement refresh and purchase restoration |
| FEAT-017 | Store-supplied eligible discount presentation                          |
| FEAT-018 | Help/settings, credits and external support links                      |

### 3.2 Roadmap or absent functionality

| ID       | Feature                                                                                  | Status                                          |
|----------|------------------------------------------------------------------------------------------|-------------------------------------------------|
| ROAD-001 | Automatic Google-account encrypted backup/recovery                                       | Roadmap; design outstanding                     |
| ROAD-002 | Additional premium cloud destinations/direct device sharing                              | Roadmap                                         |
| ROAD-003 | Complete internationalisation/localisation                                               | Incomplete                                      |
| ROAD-004 | Fully verified release accessibility/device matrix                                       | Outstanding                                     |
| ROAD-005 | Expo backup/data import                                                                  | Explicitly excluded                             |
| ROAD-006 | Shared Android/iOS accounts or entitlements                                              | <mark>Absent; open decision</mark> |
| ROAD-007 | Search, folders, tags, text passwords, OTP generation, clipboard copy or per-grid export | No current implementation found                 |
| ROAD-008 | Automatic backup scheduling or automatic cross-device grid synchronisation               | Absent                                          |

Sources: \[S2\], \[S16\], \[S17\].

## 4. Screen and navigation specification

### 4.1 Entry screen

SCREEN-001 — Vault entry

The scrollable entry screen contains:

5.  PIN Vault logo.

6.  Vault title and status.

7.  Primary Unlock vault action.

8.  How it works.

9.  About & support.

Initial text identifies the vault as locked. Authentication cancellation/failure leaves the user on entry with retry guidance.

When a foreground session remains ready, the screen instead reports:

- “Your vault is unlocked while you use the app.”

- Open vault.

NAV-001: Successful authentication opens the gallery. Public introduction and support screens are available without vault authentication.

<mark>Important current discrepancy: The gallery navigation control is labelled Lock vault, but its callback finishes the gallery without explicitly clearing the shared session. Returning to entry through internal navigation can therefore retain access. Explicit manual locking must remain an open decision, not an assumed guarantee.</mark>

Sources: \[S1\], \[S5\], \[S12\].

### 4.2 Introduction

SCREEN-002 — How it works

A scrollable guide presents:

- Skip introduction.

- “Your codes. Your pattern.”

- Product purpose.

- A clearly labelled synthetic 40-cell illustration.

- Three steps: choose cells, fill gaps, find selected cells.

- Explanation of encryption and device authentication.

- Continue to vault.

- Guidance for users bringing an existing backup.

ONB-001: Automatically open this guide on first entry when the completion preference is absent.

ONB-002: Skip and Continue both record completion and return to entry. Neither authenticates the vault.

ONB-003: Reopen the guide from entry, Help/settings and the empty gallery.

ONB-004: Explain that the user must remember their reading order and avoid putting PINs or pattern clues in names.

ONB-005: The illustration must not read, save or expose actual vault content.

Backing out through system navigation does not execute the same completion handler as Skip/Continue.

Sources: \[S1\], \[S2\].

### 4.3 Gallery

SCREEN-003 — PIN grids

The gallery contains:

- Toolbar title PIN grids.

- Navigation action labelled Lock vault.

- Info.

- Overflow actions Pro and Organise grids.

- Prominent Unlock Pro · unlimited grids action for non-Pro users.

- All grids and Favourites tabs when saved pages exist.

- Page counter and status.

- Horizontal pager.

- Bottom actions Create grid and Backup.

Each grid page contains:

10. Grid name.

11. Hold-to-reveal guidance.

12. All 40 coloured digits.

13. Full-width Show PIN action.

14. Edit and Delete grid side by side.

GAL-001: Display one grid page at a time, with horizontal navigation and vertical scrolling within the page.

GAL-002: Display Grid n of m for the current filtered section.

GAL-003: Opening or returning to the gallery checks the foreground session and reloads saved content.

GAL-004: After cancelled authentication, show an explicit Unlock vault retry action.

GAL-005: Hide the prominent upgrade action when Pro is active; Pro remains available through navigation.

Sources: \[S5\], \[S6\].

### 4.4 Empty states

SCREEN-004 — Empty vault

Show:

- “Make room for your first grid”.

- Naming/pattern guidance.

- How it works.

- “Moving from another device?”

- Restore backup.

Create and Backup remain available.

SCREEN-005 — Empty favourites

If saved grids exist but none are favourites:

No favourites yet. Open Organise grids in the menu to choose your favourite cards.

This is distinct from an empty vault.

Sources: \[S5\], \[S16\].

### 4.5 Grid editor and keypad

SCREEN-006 — Create/Edit grid

Scrollable content:

- Back navigation.

- Title Create grid or Edit grid.

- Name field: “Grid name — no PINs or pattern clues”.

- Selection instructions.

- Selected-cell count/status.

- Five rows of eight editable cells.

- Fill decoys and Save grid.

- Warning to save before leaving because unfinished edits are cleared.

Selected PIN cells have contrasting outlines.

SCREEN-007 — Choose PIN digit

A protected, scrollable dialog contains:

- Selected row, column and colour.

- Digits 1–9 arranged as a conventional three-column keypad.

- 0 centred on a fourth row.

- Cancel.

- Clear cell.

Choosing a digit applies it immediately and dismisses the dialog.

SCREEN-008 — Discard changes?

Back navigation after a modified draft offers:

- Keep editing.

- Discard.

Both toolbar Back and system Back use the same guard.

SCREEN-009 — Selection limit

A rejected free-tier selection shows Six PIN cells included, explanatory guidance and Keep editing. It does not automatically leave the draft for the purchase screen.

Sources: \[S4\].

### 4.6 Organise grids

SCREEN-010 — Organise grids

A protected, scrollable dialog lists each card by ordinal number and name. Each row provides:

- Add to favourites or Remove from favourites.

- Move up.

- Move down.

Boundary movement controls are disabled appropriately.

Dialog actions:

- Cancel.

- Save.

Changes remain a draft until Save. Dismissal clears displayed names and draft references.

Sources: \[S7\].

### 4.7 PIN reading

SCREEN-011 — Your PIN cells

An explicit protected reading dialog contains:

- “Shown by grid position. Read these cells in the order you chose.”

- A row for every selected cell: Row r, column c: digit d.

- Hide PIN cells.

Rows follow grid position, not the user’s remembered reading order.

Sources: \[S6\], \[S8\].

### 4.8 Backup and restore

SCREEN-012 — Backup & restore

Scrollable content:

- Back.

- Explanation of encrypted recovery copies.

- Create backup.

- Status.

- Restore backup.

SCREEN-013 — Create encrypted backup

Protected password dialog:

- Backup password.

- Confirm password.

- Independent visibility controls.

- Forgotten-password warning.

- Cancel and Create.

- Inline mismatch/empty-input feedback.

SCREEN-014 — Restore backup

Contains:

- Back.

- Instructions.

- File-selection status.

- Choose backup.

- Enter password to preview, after file selection.

- Operation status.

- Verified preview counts.

- Restore choices with explanations.

SCREEN-015 — Preview encrypted backup

Protected password dialog with Cancel, Preview, visibility toggle and inline required-password feedback.

SCREEN-016 — Restore backup?

Confirmation describes incoming, matching and retained/deleted counts. Actions are Cancel and the selected strategy.

The operating system owns file selection, save destinations and authentication prompts; their exact Android presentation is not an iOS layout requirement.

Sources: \[S9\], \[S10\], \[S11\].

### 4.9 Pro

SCREEN-017 — PIN Vault Pro

Scrollable content prioritises:

15. Free/Pro comparison.

16. “One purchase. No subscription.”

17. Eligible saving/original-price information.

18. Billing status.

19. Unlock Pro, optionally including the formatted price.

20. Explanation that encryption/authentication/local backups exist for everyone.

21. Restore purchase.

22. Same-store-account guidance and clarification that purchases do not back up grids.

An active entitlement changes the primary label to Pro active and disables buying.

Sources: \[S13\], \[S14\].

### 4.10 Help/settings and About

SCREEN-018 — Help & settings

Controls:

- Back.

- How it works.

- Appearance.

- PIN Vault Pro.

- About & support.

Explanatory sections cover grids, ordering/favourites, encryption, editing, reveal, authentication, cleanup, backup/recovery, entitlements, billing privacy and appearance.

SCREEN-019 — Appearance

Single-choice options:

- Light.

- Dark.

- Auto (follow device).

Selection applies immediately and is remembered locally. Auto is the default.

SCREEN-020 — About & support

Displays:

- App name and version.

- Credits naming LeeDrOiD Labs and David Peltz.

- Warning not to send PINs, grids, backups or passwords.

- Visible support email.

- Labelled email, website and social actions.

Current Android destinations are:

| Action    | Destination                              |
|-----------|------------------------------------------|
| Email     | leedroid.apps@gmail.com                  |
| Website   | https://www.leedroid.co.uk/              |
| Facebook  | https://www.facebook.com/LeeDr0iD/       |
| X         | https://twitter.com/LeeDrOiD             |
| Instagram | https://www.instagram.com/leedroid.labs/ |

External actions attach no vault data. Missing handlers produce an explanatory message rather than an intentional application failure.

<mark>These branding/contact choices are Android reference values; iOS ownership remains open.</mark>

Sources: \[S3\], \[S15\], \[S16\].

## 5. Exact grid rules

### 5.1 Shape and colours

| ID       | Rule                                                                             |
|----------|----------------------------------------------------------------------------------|
| GRID-001 | Exactly 40 cells, displayed as eight columns and five rows.                      |
| GRID-002 | Positions are internally 0–39, row-major. User-facing rows/columns start at 1.   |
| GRID-003 | New grids contain exactly ten cells of each colour: RED, BLUE, GREEN and YELLOW. |
| GRID-004 | Randomise colour positions using a cryptographically secure random source.       |
| GRID-005 | A new grid begins with blank digits and no selected PIN cells.                   |
| GRID-006 | Preserve colours and positions when saving, reopening, editing or restoring.     |

Android’s current cell colours are:

| Colour | RGB           | Hex      |
|--------|---------------|----------|
| Red    | 255, 100, 100 | \#FF6464 |
| Blue   | 110, 182, 255 | \#6EB6FF |
| Green  | 78, 205, 196  | \#4ECDC4 |
| Yellow | 253, 203, 110 | \#FDCB6E |

Digits use black text in both themes. Matching these exact hues on iOS is an open visual-parity decision.

### 5.2 Selection and decoys

| ID       | Rule                                                                                                                       |
|----------|----------------------------------------------------------------------------------------------------------------------------|
| GRID-007 | Each cell holds one digit 0–9; leading zeroes and repeated digits are valid.                                               |
| GRID-008 | Explicitly choosing a digit marks that cell as a PIN cell, including when replacing an existing decoy.                     |
| GRID-009 | Clear cell removes both digit and PIN status.                                                                              |
| GRID-010 | Cancel leaves the cell unchanged.                                                                                          |
| GRID-011 | Fill decoys populates only blank cells with random 0–9 digits marked as non-PIN.                                           |
| GRID-012 | Fill decoys preserves all existing digits and PIN selections. Repeating it on a complete grid does not reshuffle digits.   |
| GRID-013 | No numeric PIN string or selection order is stored separately.                                                             |
| GRID-014 | Selection patterns are unrestricted by colour, shape or conventional four-digit PIN length, subject to entitlement limits. |

### 5.3 Save validation

GRID-015: Save requires:

- A name non-empty after trimming.

- All 40 digits filled.

- At least one selected PIN cell.

- Applicable grid-count and selected-cell allowances.

GRID-016: There is no implemented requirement to press Fill decoys specifically. A fully populated grid can be saved if validation passes.

GRID-017: Pro permits all 40 cells to be selected; there need not be any decoys.

GRID-018: No implemented unique-name requirement or explicit name-length limit was found.

Sources: \[S4\], \[S6\], \[S18\].

## 6. Grid lifecycle workflows

### 6.1 Create

FLOW-001

23. Unlock/open the gallery.

24. Choose Create grid.

25. Check current entitlement and saved-record count.

26. If allowed, generate a new blank colour grid.

27. Enter a name and choose PIN digits.

28. Fill remaining blanks.

29. Save after validation.

30. Encrypt and persist under a new opaque identifier.

31. Return to the gallery with success feedback.

FLOW-002: A free user already at the grid limit sees Your two free grids are saved, with Not now and View Pro. Existing grids remain available.

### 6.2 Edit

FLOW-003

32. Open Edit on a saved card.

33. Load and decrypt the identified record under an authorised session.

34. Keep editing controls unavailable until loading succeeds.

35. Preserve layout, selected digits, favourite and ordering metadata.

36. Save over the original identifier.

37. Return without creating an additional card.

FLOW-004: Changing a decoy through the keypad selects it as genuine. To remove a chosen cell, Clear it and optionally refill the blank as a decoy.

FLOW-005: Leaving a modified editor through Back prompts Keep editing/Discard. Ordinary backgrounding clears the draft rather than preserving it.

FLOW-006: Loading/saving/authentication must not queue conflicting edits or competing exit operations. Already-authorised worker writes can complete after the initiating UI leaves; backgrounding is not a guaranteed rollback of an in-flight save.

### 6.3 Delete

FLOW-007

38. Choose Delete grid.

39. Show a confirmation naming the card and stating deletion cannot be undone.

40. Cancel preserves the record.

41. Confirm removes that identifier locally.

42. Update the current section/page count and show “Grid deleted”.

Deletion does not require an additional prompt during an already-authorised foreground session. It does not alter existing exported backups.

Sources: \[S4\], \[S5\], \[S18\].

## 7. Viewing, reveal, favourites and ordering

### 7.1 Reveal behavior

| ID       | Requirement                                                                                                                            |
|----------|----------------------------------------------------------------------------------------------------------------------------------------|
| VIEW-001 | Ordinary gallery display shows all digits but does not identify selected cells visually or through ordinary cell accessibility labels. |
| VIEW-002 | Holding Show PIN temporarily highlights selected cells without removing decoys.                                                        |
| VIEW-003 | While held, the label becomes Release PIN.                                                                                             |
| VIEW-004 | Release, cancellation, focus loss, page changes, detachment, recycling and gallery pause remove highlights.                            |
| VIEW-005 | An ordinary touch tap must not latch a permanent visual reveal.                                                                        |
| VIEW-006 | Android keyboard Space, Enter and centre-key hold/release mirror touch reveal.                                                         |
| VIEW-007 | Accessibility activation exposes an explicit Read PIN cells action opening the reading dialog.                                         |
| VIEW-008 | Hide, page change or leaving the gallery dismisses the reading dialog and clears its rows.                                             |
| VIEW-009 | Neither reveal mode invents or claims to know the user’s reading order.                                                                |

### 7.2 Favourites and ordering

| ID      | Requirement                                                                                                             |
|---------|-------------------------------------------------------------------------------------------------------------------------|
| ORG-001 | All grids shows the ordered collection; Favourites filters that collection without changing its order.                  |
| ORG-002 | Organise grids edits a draft of card order and favourite flags.                                                         |
| ORG-003 | Save commits the complete organisation change atomically; Cancel leaves saved organisation unchanged.                   |
| ORG-004 | Reordering changes whole-card presentation only, never cell positions, digits or the remembered reading sequence.       |
| ORG-005 | Persist favourite/order information inside encrypted payloads.                                                          |
| ORG-006 | Preserve organisation through ordinary editing and new backups.                                                         |
| ORG-007 | Older payloads without metadata default to not favourite and unranked.                                                  |
| ORG-008 | Arranged cards precede unranked cards. Equal ranks preserve the incoming order. Negative ranks are treated as unranked. |
| ORG-009 | New unranked cards appear after explicitly arranged cards.                                                              |
| ORG-010 | Organising existing grids is available regardless of free-tier overage or larger existing PIN selections.               |
| ORG-011 | Backgrounding dismisses the organiser; stale-session work must not commit an organisation draft.                        |

<mark>Android ordering detail: Unranked input order comes from descending repository timestamps. Ordinary save refreshes that timestamp; organisation save preserves it. Restore does not preserve original record timestamps. This fallback behavior is not a deliberately agreed cross-platform ordering contract.</mark>

Sources: \[S5\], \[S6\], \[S7\], \[S8\], \[S18\].

## 8. Free and Pro entitlements

### 8.1 Normal allowances

| ID      | Capability                    | Free                    | Pro                               |
|---------|-------------------------------|-------------------------|-----------------------------------|
| ENT-001 | New saved grids               | Up to 2                 | No product count cap              |
| ENT-002 | Selected cells in a new grid  | 1–6                     | 1–40                              |
| ENT-003 | All 40 displayed cells/decoys | Yes                     | Yes                               |
| ENT-004 | Encryption/authentication     | Yes                     | Yes                               |
| ENT-005 | Favourites/order/themes       | Yes                     | Yes                               |
| ENT-006 | Local backup controls         | Yes                     | Yes                               |
| ENT-007 | Restore                       | Subject to limits below | Subject to format/resource limits |

“Unlimited” Pro grids does not remove backup size/count limits.

### 8.2 Existing-user/grandfathering rules

ENT-008: Losing Pro does not delete, hide, prevent reading, prevent deleting or prevent exporting existing grids.

ENT-009: Existing grid IDs remain editable even if the collection already exceeds two grids.

ENT-010: For an existing decryptable grid, the free selected-cell allowance is:

max(6, number of PIN cells in its currently saved version)

Examples:

- Saved with ten selected cells: a free user may retain ten or reduce the selection.

- Save a reduction to eight: eight becomes the allowance.

- Save a reduction below six: the ordinary six-cell allowance applies.

- Increasing above the current allowance requires Pro.

ENT-011: Validate the exception against the existing encrypted saved record, not a caller-supplied flag.

### 8.3 Restore restrictions

ENT-012: Apply limits to the entire operation before committing data; never trim a backup to fit.

ENT-013: For free users:

- Merge must normally result in at most two distinct IDs.

- A merge containing only existing IDs is allowed even in an already-over-limit vault.

- Replace all must contain at most two incoming grids.

- Incoming new grids above six selected cells require Pro.

- Replacing a matching larger grid may retain/reduce its proven existing allowance.

- Keep local skips incoming conflicts, including their selection allowance checks.

ENT-014: A clean device cannot prove a larger historical local allowance. A valid old backup with seven or more selected cells in a new grid requires Pro.

ENT-015: An unavailable local key cannot prove grandfathering. Such larger-grid recovery requires Pro.

ENT-016: Quota rejection preserves the backup and must occur before recovery key recreation. The incoming plaintext plan is cleared.

Sources: \[S14\], \[S18\], \[S19\].

## 9. Authentication, security and privacy

### 9.1 Observable authentication contract

| ID      | Requirement                                                                                                                                                      |
|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SEC-001 | Begin without a persisted unlocked session. Authenticate before displaying saved vault content.                                                                  |
| SEC-002 | Use device credentials or a supported strong biometric; provide a credential alternative.                                                                        |
| SEC-003 | If suitable device security is unavailable, do not grant vault access.                                                                                           |
| SEC-004 | One successful authentication authorises normal internal navigation, editing, saving and backup operations during a foreground session.                          |
| SEC-005 | Backgrounding, screen-off or device lock ends the session. External links and document pickers also end it when they take the application out of the foreground. |
| SEC-006 | Returning requires authentication before sensitive access resumes.                                                                                               |
| SEC-007 | Internal navigation/configuration recreation can retain the session; it is not governed by a 30-second foreground idle timer.                                    |
| SEC-008 | Ignore stale/cancelled/destroyed authentication results.                                                                                                         |
| SEC-009 | Explicit recovery of an unavailable key requires fresh authentication.                                                                                           |
| SEC-010 | Clear sensitive displayed data when its screen stops; discard unfinished editor drafts.                                                                          |

<mark>The platform-equivalent iOS authentication policy, scene lifecycle and acceptable biometric classes remain open.</mark>

### 9.2 Persistence and memory protection

SEC-011: Encrypt names, digits, colours, chosen-cell flags, favourite flags and custom ordering before persistence.

SEC-012: Use authenticated encryption with fresh nonces. Detect alteration rather than returning unauthenticated plaintext.

SEC-013: Protect local encryption keys using device security. A portable backup must not depend on exporting the local device-bound key.

SEC-014: Do not write real PINs, backup passwords, decrypted payloads or keys to logs, crash attachments or temporary files.

SEC-015: Keep plaintext only while needed; clear mutable password/plaintext/key buffers on completion, cancellation and lifecycle cleanup.

SEC-016: Suppress sensitive screenshots/recent-app previews and protect sensitive dialog windows using available platform mechanisms.

These are intended security requirements. Java string copying and some asynchronous paths prevent claiming perfect memory erasure.

### 9.3 Android implementation boundary

Android currently uses:

- Keystore wrapping key with a 30-second authentication window.

- Random 256-bit foreground data key.

- Persisted AES-GCM-wrapped data key.

- AES-GCM grid records with version-3 nonce metadata.

- Transactional migration of older native records.

- Room encrypted records and private preferences.

Brian need not reproduce Room, Java, Keystore aliases or the local ciphertext format. Their security effects require a separate iOS design.

### 9.4 Privacy

| ID       | Requirement                                                                                                     |
|----------|-----------------------------------------------------------------------------------------------------------------|
| PRIV-001 | No PIN Vault account is required.                                                                               |
| PRIV-002 | No application-managed cloud sync, analytics or grid-upload backend is implemented.                             |
| PRIV-003 | Billing must receive no grid names, digits, layouts or backup passwords.                                        |
| PRIV-004 | Store receipts remain separate from vault backups.                                                              |
| PRIV-005 | User-selected document providers can include cloud providers; this is explicit file export, not automatic sync. |
| PRIV-006 | Support/social links attach no vault content.                                                                   |
| PRIV-007 | Warn users not to send secrets or backups through support.                                                      |

Android automatic app-data backup is disabled. Portable backup is the supported recovery mechanism.

Sources: \[S11\], \[S12\], \[S14\], \[S17\], \[S20\].

## 10. Platform-independent data and persistence model

### 10.1 Grid model

| ID       | Field             | Meaning                                                                                       |
|----------|-------------------|-----------------------------------------------------------------------------------------------|
| DATA-001 | Opaque identifier | Stable identity for edit/delete/restore conflict matching; new Android grids use UUID strings |
| DATA-002 | Name              | Trimmed, non-empty user label                                                                 |
| DATA-003 | Cells             | Exactly 40 ordered cell objects                                                               |
| DATA-004 | Cell position     | Integer 0–39, matching array index                                                            |
| DATA-005 | Cell colour       | RED, BLUE, GREEN or YELLOW                                                                    |
| DATA-006 | Cell digit        | 0–9; nullable only in an unfinished editor draft                                              |
| DATA-007 | Cell PIN flag     | Whether explicitly selected as genuine                                                        |
| DATA-008 | Favourite         | Boolean, default false                                                                        |
| DATA-009 | Display order     | Optional non-negative rank; absent means unranked                                             |

No stored field represents the user’s reading order.

### 10.2 Persistence behavior

DATA-010: New save creates identity; edit retains identity.

DATA-011: Saved content survives application restart and persistence reopening.

DATA-012: Keep decrypted UI models separate from encrypted stored records.

DATA-013: Organisation updates commit atomically without changing grid contents.

DATA-014: Restore conflict identity is the opaque ID, not the name.

DATA-015: Store onboarding completion, appearance and verified purchase evidence separately from grid secrets.

DATA-016: Do not store a mutable “premium=true” preference as sufficient proof of production entitlement.

Android stores a non-sensitive timestamp outside encrypted content. Its field is named createdAtMillis, but ordinary save refreshes it; it must not be assumed to be immutable creation history.

Sources: \[S4\], \[S7\], \[S12\], \[S14\], \[S18\].

## 11. Backup, restore and recovery

### 11.1 Export workflow

BACK-001

43. Open Backup & restore.

44. Choose Create backup.

45. Enter and confirm a non-empty password.

46. Authorise through the current session or device authentication.

47. Read/decrypt saved grids.

48. Serialize the complete collection, including identities and organisation.

49. Encrypt entirely in memory.

50. Ask the user for a destination.

51. Write ciphertext only.

52. Report success only after stream closure succeeds.

BACK-002: No saved grids means no export; explain that the first grid must be saved.

BACK-003: Passwords are not stored or recoverable. Current code enforces non-empty matching strings, with no minimum strength/length beyond that. It does not trim password whitespace.

BACK-004: Suggest:

pin-vault-backup-YYYY-MM-DD-HH-mm.pvb

MIME type is application/octet-stream. Extension is a convenience, not proof of validity.

BACK-005: Do not create a private fallback backup that the user cannot locate.

BACK-006: Preserve prepared ciphertext across configuration recreation during file selection. Process death loses it; then abort without opening/truncating the selected destination.

BACK-007: Cancellation/write/close failure must not claim a successful backup. A provider may independently create an empty document.

### 11.2 PV2 binary format

<mark>This is the implemented Android format, not an agreed iOS interoperability commitment.</mark>

FMT-001: Binary envelope, big-endian integer fields:

| Offset | Length   | Value                                           |
|--------|----------|-------------------------------------------------|
| 0      | 4        | Magic bytes 50 56 32 00 — PV2 plus NUL          |
| 4      | 1        | Format version 1                                |
| 5      | 1        | KDF ID 1: PBKDF2-HMAC-SHA256                    |
| 6      | 1        | Cipher ID 1: AES-256-GCM                        |
| 7      | 4        | PBKDF2 iteration count                          |
| 11     | 1        | Salt length 16                                  |
| 12     | 1        | Nonce length 12                                 |
| 13     | 4        | Ciphertext length, including authentication tag |
| 17     | 16       | Random salt                                     |
| 33     | 12       | Random nonce                                    |
| 45     | Variable | Ciphertext followed by 16-byte GCM tag          |

FMT-002: Derive a 256-bit key. Export uses 600,000 iterations; import accepts 600,000–1,200,000.

FMT-003: Use a fresh 16-byte salt and 12-byte nonce per backup.

FMT-004: Authenticate the complete header through the nonce—bytes 0–44—as GCM additional authenticated data.

FMT-005: Reject unknown identifiers/versions, incorrect lengths, unsupported iteration counts, truncation and trailing bytes.

FMT-006: Maximum plaintext payload is 10,485,760 bytes. The code therefore permits a complete file of at most 10,485,821 bytes: 10 MiB plus 61 bytes of envelope/tag overhead. Documentation’s “10 MiB file” wording is approximate.

### 11.3 Payload schema

FMT-007: Decrypted data is UTF-8 JSON containing:

payloadVersion: 1

exportedAt: export time in milliseconds since Unix epoch

grids: \[

{

id,

name,

cells: \[

{ position, color, digit, pin },

... exactly 40 cells ...

\],

favourite: optional boolean,

displayOrder: optional integer

}

\]

FMT-008: Backup includes no local key, purchase receipt, device identifier, biometric data or user reading order.

FMT-009: Current importer validates:

- Payload version 1.

- One to 1,000 grids.

- Non-empty ID and trimmed non-empty name.

- Unique incoming IDs.

- Exactly 40 ordered positions.

- Recognised colours.

- Digits 0–9.

- Boolean PIN status.

- At least one selected cell.

FMT-010: The importer does not currently enforce UUID syntax, ten-of-each-colour distribution, explicit name-length limits or a strict organisation-metadata schema.

FMT-011: Existing native payloads without organisation metadata remain supported. Legacy Expo backup envelopes are rejected despite sharing the .pvb extension.

### 11.4 Import and preview

REST-001

53. Choose a file through the system picker.

54. Authenticate after returning if the session ended.

55. Enter its backup password.

56. Read within the envelope size bound.

57. Validate/decrypt the envelope.

58. Validate every grid.

59. Display counts only.

60. Offer restore strategies without modifying grids.

REST-002: Permit password retry without choosing the file again.

REST-003: Preview reports incoming, new-ID and matching-ID counts. Matching means identity equality, not content equality.

REST-004: Reject the complete import if any entry is malformed; do not partially restore.

REST-005: Backgrounding clears the preview plan. Late results from an older file/operation cannot republish it.

### 11.5 Restore strategies

| ID       | Choice      | Effect                                                                  |
|----------|-------------|-------------------------------------------------------------------------|
| REST-006 | Keep local  | Import only new IDs; preserve matching and extra local grids            |
| REST-007 | Use backup  | Import new IDs and replace matching IDs; retain extra local grids       |
| REST-008 | Replace all | Remove all local records and restore exactly the validated incoming set |

REST-009: Explain counts/consequences and obtain explicit confirmation.

REST-010: Check applicable entitlements before encryption/key recovery.

REST-011: Encrypt accepted incoming records using the receiving installation’s local key, then apply one database transaction.

REST-012: Follow the selected strategy for favourite/order metadata as part of each grid payload.

REST-013: Successful completion returns to the gallery and reports committed-grid count. Keep-local count reflects imported records, not every grid in the file.

### 11.6 Unavailable-key recovery

REC-001: Ordinary use must not silently replace an unavailable key.

REC-002: Merge must not recreate a failed key to write into an unreadable vault.

REC-003: Only a validated backup, explicit Replace all confirmation and fresh device authentication may authorise local key recreation.

REC-004: Apply quota/selection restrictions before recreating the key.

REC-005: Warn that unreadable local grids are discarded. Without a usable backup, they cannot be recovered.

REC-006: A forgotten backup password has no recovery route.

REC-007 — Limitation: Database rollback and key replacement are not one atomic system transaction. Failure after key recreation needs additional verification; current generic “existing grids unchanged” messaging is broader than the proven guarantee.

Sources: \[S9\], \[S10\], \[S11\], \[S12\], \[S18\], \[S19\].

## 12. Purchasing Pro and restoring purchases

### 12.1 Product behavior

BUY-001: Android sells Pro as a permanent, non-consumable one-time purchase; no subscription.

BUY-002: Default Android product ID is pro_unlock, with build-time override support.

BUY-003: Show store-formatted price. Do not hard-code currency or price.

BUY-004: Display savings and a struck-through original price only when supported by eligible store discount metadata.

BUY-005: Pair the displayed offer with the offer submitted for purchase. If expired at purchase time, refresh rather than silently charging a different offer.

BUY-006: Among supported current eligible offers, select the lowest price for one outright purchase option/currency. Reject ambiguous options/currencies and unsupported rental, preorder or limited-quantity offers.

### 12.2 Purchase workflow

BUY-007

61. Open Pro from gallery/menu/Help.

62. Connect to the store and refresh ownership/product information.

63. Enable buying only when configuration, ownership check, connection and offer permit.

64. Open the store-owned payment flow.

65. Grant access only after a completed purchase passes verification.

66. Refresh visible entitlement state.

BUY-008: Pending payment does not grant Pro.

BUY-009: Cancellation does not intentionally revoke existing verified access.

BUY-010: Android verifies signed purchase data, product ID, package and token. Acknowledge completed purchases; retry acknowledgement on a later ownership query. Do not consume Pro.

### 12.3 Restore and offline behavior

BUY-011: Restore purchase refreshes ownership from the same Google Play account. It restores entitlement, not grids.

BUY-012: Cache signed purchase evidence privately and verify it again after restart.

BUY-013: Network/store failures retain previously verified access.

BUY-014: A successful owned-purchase query without Pro revokes access and removes cached entitlement evidence.

BUY-015: No real-time refund backend exists; offline access can remain until a successful store refresh.

BUY-016: Missing public-key configuration disables production purchasing and cannot grant Pro.

BUY-017: QA-only offline Pro is explicitly isolated from production and is not evidence of working purchase flows.

<mark>The iOS product ID, StoreKit implementation, refund policy and cross-platform entitlement relationship remain open.</mark>

Sources: \[S13\], \[S14\], \[S19\].

## 13. Settings, accessibility and errors

### 13.1 Presentation requirements

| ID     | Requirement                                                                                              |
|--------|----------------------------------------------------------------------------------------------------------|
| UX-001 | Persist Light/Dark/Auto and apply before initial UI presentation.                                        |
| UX-002 | Respect safe areas/system obstructions and allow scrolling to actions.                                   |
| UX-003 | Permit action labels to wrap with increased text sizes.                                                  |
| UX-004 | Use clear primary/secondary actions and explicit Back/Cancel controls.                                   |
| UX-005 | Label logo, navigation, actions and headings accessibly.                                                 |
| UX-006 | Gallery cell labels include row, column, colour and digit without PIN status.                            |
| UX-007 | Editor labels additionally identify selected versus decoy/empty state.                                   |
| UX-008 | Announce operation status through polite accessibility updates where implemented.                        |
| UX-009 | Password fields have visibility toggles, inline errors and no saved-state/autofill retention in Android. |
| UX-010 | Do not present the introductory illustration as 40 meaningful accessibility items.                       |

<mark>Android’s normal action minimum is 56 dp; keypad controls use at least 48 dp. These are Android reference measurements, not agreed iOS dimensions.</mark>

### 13.2 Important error semantics

| ID      | Situation                    | Current message/required meaning                                             |
|---------|------------------------------|------------------------------------------------------------------------------|
| ERR-001 | Entry authentication failure | “Vault remains locked. Try again with your screen lock or strong biometric.” |
| ERR-002 | Missing name                 | “Give your grid a name before saving.”                                       |
| ERR-003 | Incomplete grid              | “Fill the remaining empty cells with decoys, then save.”                     |
| ERR-004 | No selected cell             | “Tap a cell to choose at least one real PIN digit before saving.”            |
| ERR-005 | Password mismatch            | “Enter the same password in both fields.”                                    |
| ERR-006 | Missing import password      | “Enter the backup password.”                                                 |
| ERR-007 | Authentication-tag failure   | “The password is incorrect or this backup is damaged.”                       |
| ERR-008 | Invalid envelope             | “This is not a supported PIN Vault backup.”                                  |
| ERR-009 | Invalid payload              | “This backup is damaged or contains invalid grid data.”                      |
| ERR-010 | Lost prepared export         | Report interruption and require creating the backup again                    |
| ERR-011 | Quota rejection              | Explain required Pro access; do not trim or partially import                 |
| ERR-012 | Unavailable local key        | Explain explicit Replace all recovery and unreadable local grids             |
| ERR-013 | Organisation save failure    | “Could not save your grid order. Unlock and try again.”                      |
| ERR-014 | Store failure                | Preserve previously verified access; provide retry/status                    |
| ERR-015 | Missing external handler     | Explain that no email/browser handler is available                           |

<mark>Exact English wording is a reference. Translation and iOS copy approval remain open.</mark>

Sources: \[S1\], \[S4\], \[S5\], \[S9\], \[S10\], \[S13\], \[S15\], \[S16\].

## 14. Tests and derived acceptance checklist

### 14.1 Existing evidence

The checkout contains 37 unit-test methods and 48 instrumentation test methods. Some instrumentation cases are opt-in, use synthetic cryptography or capture synthetic UI.

Lee’s handover records 37 passing unit tests and later focused emulator/device checks. Those historical results do not establish that every current workflow is verified.

No tests were run for this specification. The previous baseline attempt was blocked by uncached Billing Client 9.1.0.

### 14.2 Acceptance scenarios

<mark>These can become platform-specific iOS checks after scope agreement.</mark>

| ID     | Acceptance criterion                                                               | Existing Android evidence                                   |
|--------|------------------------------------------------------------------------------------|-------------------------------------------------------------|
| AC-001 | First introduction is skippable, repeatable and contains only synthetic examples   | Intro UI test                                               |
| AC-002 | New grid has 40 cells and ten of each colour                                       | PinGridTest                                                 |
| AC-003 | Fill decoys preserves selected digits and layout                                   | PinGridTest                                                 |
| AC-004 | Name, completeness and selected-cell validation prevent invalid saves              | Editor source/manual checklist                              |
| AC-005 | A seventh new free PIN cell is rejected without changing the draft                 | Allowance/editor tests                                      |
| AC-006 | Existing larger selections may stay/shrink; saved reduction lowers allowance       | Allowance/repository tests                                  |
| AC-007 | Third free grid is rejected, including competing saves                             | Grid-limit tests                                            |
| AC-008 | Edit retains identity without duplicate creation                                   | Encrypted-store tests                                       |
| AC-009 | Back supports Keep editing/Discard; background clears models and digits            | Editor lifecycle tests                                      |
| AC-010 | Touch/key cancellation, focus loss and teardown hide markers                       | Gallery adapter tests                                       |
| AC-011 | Explicit reading dialog protects content and clears rows on dismissal              | Gallery adapter tests                                       |
| AC-012 | Favourite/order Save persists; Cancel changes nothing                              | Ordering/organisation tests                                 |
| AC-013 | Organisation changes preserve IDs, cells and timestamps atomically                 | Organisation repository tests                               |
| AC-014 | Stale session cannot apply organisation changes                                    | Organisation tests                                          |
| AC-015 | Authenticated session supports internal navigation and later saves; Home ends it   | Opt-in real-session test                                    |
| AC-016 | Data survives persistence reopening                                                | Encrypted-store tests                                       |
| AC-017 | Backup round-trip succeeds; wrong password/tampering/truncation fail               | BackupCryptoTest                                            |
| AC-018 | Prepared ciphertext transfers once, survives recreation and is cleared             | Export-state/lifecycle tests                                |
| AC-019 | Restore policies produce correct final identities/content                          | Encrypted-store tests                                       |
| AC-020 | Rejected over-limit restore clears incoming buffers before key recreation          | Limit/recovery tests                                        |
| AC-021 | Invalidated-key merge refuses recreation; explicit recovery follows policy         | Simulated recovery tests                                    |
| AC-022 | Invalid receipt/tampered signed data cannot establish Pro                          | PurchaseVerifierTest                                        |
| AC-023 | Offer selection honours eligibility, timing, price and currency/option constraints | ProOfferSelectionTest                                       |
| AC-024 | UI remains reachable in both themes/orientations and with assistive input          | Partial UI tests plus outstanding manual matrix             |
| AC-025 | Real purchase, pending payment, refund, restoration and offline cold start work    | Outstanding live-store acceptance                           |
| AC-026 | Export on one installation restores correctly on another with separate local keys  | Historical device evidence; current end-to-end rerun needed |

Additional acceptance gaps: Strict payload validation, provider-close failures, Unicode password interoperability, key-recreation failure atomicity, complete screen-reader behavior and full older-device coverage.

Sources: \[S17\], \[S21\].

## 15. Known limitations and incomplete behavior

| ID      | Limitation                                                                                                                    |
|---------|-------------------------------------------------------------------------------------------------------------------------------|
| LIM-001 | Cross-platform backup compatibility and shared entitlements are not defined.                                                  |
| LIM-002 | Export can exceed 1,000 grids while import rejects more than 1,000.                                                           |
| LIM-003 | Some schema constraints are missing despite documentation describing full validation.                                         |
| LIM-004 | Gallery suppresses duplicate-content records even when IDs differ; quota/export still operate on stored records.              |
| LIM-005 | Unranked ordering depends on mutable timestamps and is not a portable ordering guarantee.                                     |
| LIM-006 | No idle timeout; foreground access continues until a locking lifecycle event.                                                 |
| LIM-007 | The gallery’s “Lock vault” label does not correspond to an explicit session-clear call.                                       |
| LIM-008 | Recovery above free allowances can require Pro even for an old valid backup.                                                  |
| LIM-009 | Key replacement and database rollback lack a single atomic guarantee.                                                         |
| LIM-010 | Java object/string lifetime prevents guaranteed complete plaintext erasure.                                                   |
| LIM-011 | Full accessibility, OEM and older-Android verification remain incomplete.                                                     |
| LIM-012 | Real billing/refund/restore behavior remains release testing work.                                                            |
| LIM-013 | Local record migration is forward-only in practice: earlier pre-session APKs cannot read upgraded records.                    |
| LIM-014 | Localisation is incomplete; many UI strings remain embedded in Java.                                                          |
| LIM-015 | Signed release regeneration, correct upload-certificate verification, privacy/Data safety and publication remain outstanding. |

These are reference findings, not requirements to reproduce defects in iOS.

## 16. Open Questions for Lee, Brian and David

No answers are assumed.

| ID                                 | Decision required                                                                                                                                                                     |
|------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| <mark>OPEN-001</mark> | <mark>Should Android and iOS backups be interoperable? If so, is PV2 version 1 the shared contract, or should a reviewed successor be introduced?</mark>                 |
| <mark>OPEN-002</mark> | <mark>Must both platforms have identical features at launch? Which features are mandatory, deferred or intentionally platform-specific?</mark>                           |
| <mark>OPEN-003</mark> | <mark>Are Pro purchases platform-specific? Would an Android purchase ever unlock iOS, or vice versa?</mark>                                                              |
| <mark>OPEN-004</mark> | <mark>How will future functionality and changes be coordinated? Who owns the shared requirements, format versions, change approvals and compatibility tests?</mark>      |
| <mark>OPEN-005</mark> | <mark>Should both platforms use the exact two-grid/six-cell limits and the same grandfathering formula?</mark>                                                           |
| <mark>OPEN-006</mark> | <mark>Should disaster recovery of already-owned data remain entitlement-gated? How should unavailable/offline store access affect recovery?</mark>                       |
| <mark>OPEN-007</mark> | <mark>What constitutes equivalent device authentication on iOS? What minimum OS/device support is required?</mark>                                                       |
| <mark>OPEN-008</mark> | <mark>How should multiple iOS scenes, multitasking, interruptions, file pickers and system authentication affect sessions and drafts?</mark>                             |
| <mark>OPEN-009</mark> | <mark>Should there be explicit manual locking, an idle timeout, or both? What should “Lock vault” guarantee?</mark>                                                      |
| <mark>OPEN-010</mark> | <mark>Should Android’s automatic draft discard be retained on iOS, including rotation/scene changes, or revised?</mark>                                                  |
| <mark>OPEN-011</mark> | <mark>Should the application continue never to store reading order? Are any future ordered-PIN features contemplated?</mark>                                             |
| <mark>OPEN-012</mark> | <mark>Are the grid colours, exact layout, navigation and screen copy required to match, or may iOS use native conventions?</mark>                                        |
| <mark>OPEN-013</mark> | <mark>Should the protected accessibility reading dialog be the shared reveal model? What screenshot/recording protections are feasible and required per platform?</mark> |
| <mark>OPEN-014</mark> | <mark>What are the final name limits, ID rules, organisation validation and permitted imported colour distributions?</mark>                                              |
| <mark>OPEN-015</mark> | <mark>Should identical-content cards remain independently visible rather than being suppressed?</mark>                                                                   |
| <mark>OPEN-016</mark> | <mark>What ordering should unranked/restored cards use? Should creation/update timestamps become explicit portable metadata?</mark>                                      |
| <mark>OPEN-017</mark> | <mark>Should export and import share a single 1,000-grid/size policy, or should large backups use another design?</mark>                                                 |
| <mark>OPEN-018</mark> | <mark>If interoperable, how will password Unicode encoding/normalisation and cross-platform cryptographic test vectors be specified?</mark>                              |
| <mark>OPEN-019</mark> | <mark>How will unknown optional payload fields survive round-trips and edits across platforms?</mark>                                                                    |
| <mark>OPEN-020</mark> | <mark>What interrupted-recovery guarantees must each platform provide when local key replacement has begun?</mark>                                                       |
| <mark>OPEN-021</mark> | <mark>Who owns iOS credits, support addresses, privacy documents, branding and store accounts?</mark>                                                                    |
| <mark>OPEN-022</mark> | <mark>Which languages, accessibility standards, devices and acceptance evidence are required for launch?</mark>                                                          |
| <mark>OPEN-023</mark> | <mark>Are cloud recovery, direct sharing or accounts in either platform’s launch scope?</mark>                                                                           |
| <mark>OPEN-024</mark> | <mark>How will release versions and this Android reference revision be tracked as Lee continues development?</mark>                                                      |

## 17. Source catalogue

All paths are relative to the native repository root:

/home/davidpeltz/AppProjects/Pincode_Vault/PinVault-Android

| Ref | Supporting files                                                                                                                                                                                         |
|-----|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| S1  | app/src/main/java/com/peltzdev/pinvault/MainActivity.java; app/src/main/res/layout/activity_main.xml                                                                                                     |
| S2  | ui/info/IntroActivity.java                                                                                                                                                                               |
| S3  | ui/info/SecurityInfoActivity.java; app/src/main/res/values/strings.xml                                                                                                                                   |
| S4  | ui/editor/GridEditorActivity.java                                                                                                                                                                        |
| S5  | ui/gallery/GridGalleryActivity.java                                                                                                                                                                      |
| S6  | ui/gallery/GridPageAdapter.java                                                                                                                                                                          |
| S7  | ui/gallery/GridOrganisationDialog.java; ui/gallery/SavedGridPage.java                                                                                                                                    |
| S8  | ui/gallery/PinDetailsDialog.java                                                                                                                                                                         |
| S9  | ui/backup/BackupExportActivity.java; ui/backup/BackupExportState.java                                                                                                                                    |
| S10 | ui/backup/RestorePreviewActivity.java                                                                                                                                                                    |
| S11 | security/BackupCrypto.java; ui/AppDialogs.java; docs/BACKUP_RESTORE_DESIGN.md                                                                                                                            |
| S12 | security/DeviceAuthentication.java; security/VaultSession.java; security/VaultCrypto.java; security/ForegroundWork.java; PinVaultApplication.java                                                        |
| S13 | ui/pro/ProActivity.java                                                                                                                                                                                  |
| S14 | billing/ProBilling.java; billing/PurchaseVerifier.java; billing/ProOfferSelection.java                                                                                                                   |
| S15 | ui/info/AboutActivity.java; ui/ThemePreference.java; ui/ActionButtons.java; theme/colour resources                                                                                                       |
| S16 | README.md; docs/MAINTAINER_HANDOFF_2026-10-05.md; string resources                                                                                                                                       |
| S17 | docs/BUILD_PLAN.md; docs/TESTING.md; docs/REVIEW_FIXES_2026-09-29.md; dated APK handovers                                                                                                                |
| S18 | domain/PinGrid.java; domain/GridCell.java; domain/GridColor.java; data/EncryptedGridStore.java; data/EncryptedGridDao.java; data/EncryptedGridRecord.java; data/GridPinCells.java; restore model classes |
| S19 | billing/GridAllowance.java; docs/BILLING.md                                                                                                                                                              |
| S20 | docs/SECURITY.md; AGENTS.md; app/src/main/AndroidManifest.xml; app/build.gradle                                                                                                                          |
| S21 | app/src/test/java/com/peltzdev/pinvault/; app/src/androidTest/java/com/peltzdev/pinvault/                                                                                                                |

Paths beginning ui/, security/, billing/, domain/ or data/, and PinVaultApplication.java, are beneath:

app/src/main/java/com/peltzdev/pinvault/
