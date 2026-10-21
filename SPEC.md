# Refrain — Build Specification

> Portfolio app 230, batch pending. This document is the complete brief for
> building this application. Read all of it before writing any code. Anything
> not specified here is your decision, but must stay consistent with section 3.

**One-line positioning:** Save quotes from your books, thread them by one shared word, and weave three into each day's triptych.

| Field | Value |
| --- | --- |
| Product name | Refrain |
| Bundle identifier | `com.refrain.triptych` |
| Domain | https://refrain-triptych.pro |
| Contact URL | https://refrain-triptych.pro/contact-us |
| Deployment target | iOS 17.0 |
| Swift version | 6.2, strict concurrency `complete` |
| Devices | iPhone and iPad, portrait |
| Interface style | Dark |
| Asset prefix | `rfr_` |
| User-Agent | `Refrain/1.0 (iOS; +https://refrain-triptych.pro)` |

---

## 1. Non-negotiable constraints

1. **No CocoaPods.** Dependencies come from Swift Package Manager, a local
   in-repo package, a vendored source folder, or nothing at all — per section 3.
2. **No shared code with other portfolio apps.** Business rules are re-implemented
   here under this app's own type names.
3. **All code, identifiers, comments, UI copy and the README are in English.**
4. **No launch gate, no WebView shell, no remote configuration, no analytics.**
   Guideline 4.2 (Minimum Functionality): this is a native SwiftUI product, not
   a web browsing experience. WKWebView / SFSafariViewController as UI is a
   reject. Push notifications, Core Location, and sharing do not make a
   browser or a thin catalog into an App Store app.
5. **Guideline 5.1.1 (Privacy):** never direct the user to grant camera access.
   A pre-permission screen may exist; the proceed button is **Continue** or
   **Next**, never "Allow camera", "Enable camera", "Grant camera", or a bare
   Allow/Enable that triggers `requestAccess`. The system alert is the only Allow.
6. **No CI files.** No `bitrise.yml`, no `Scripts/`, no `metadata/` folder.
7. **Assets are AI-generated.** No stock photography. SF Symbols may support
   small affordances but must never be the primary iconography.
8. **The app must build clean** with
   `xcodegen generate && xcodebuild -scheme Refrain -destination 'generic/platform=iOS' build`.
9. **Nothing may echo another app in this batch** in naming, layout or visuals.
10. **This is not a calorie meal-slot tracker** unless family is `food_tracker`.
   Do not invent food logging to fill the brief.

---

## 2. Product core

The product is offline-first. No account, no sign-in, no ads, no in-app purchase,
no analytics SDK, no remote config. All user data stays on the device.

A reader threads saved lines with one lemma and weaves a daily triptych from three quotes that share it across three different books.

### 2.1 User flow

1. On Quotes home, tap Weave to seat today's triptych from the seeded threshold lemma across three volumes.
2. Long-press a slip in the margin list to thread or change its lemma word.
3. Open Shelf as a sheet, add a volume, and capture a new slip with title, author, text, and optional page.
4. Mark a volume gone on Shelf so its spine hollows but its threaded slips stay weavable in the triptych pool.
5. Open Dashboard to read Swift Charts of top lemmas and consecutive woven days.
6. Peel today's weave to reopen Spooled and try another qualifying lemma the same day.

### 2.2 Essential behaviour

- Local volumes and slips with no account or sync
- One normalized lemma per slip (Thread) with a live eligibility rail when three distinct volumes qualify
- Triptych home with three panels filled by Weave and frozen under daykey
- Gone volumes hollow on Shelf without deleting slips or lemmas
- Dashboard analytics via Swift Charts (lemma frequency, woven-day streak)
- Peel undoes the newest WeaveMark for today
- Simulator seed: three volumes, three threshold slips, fold Spooled so Weave is the first tap

---

## 3. Uniqueness assignment for Refrain

| Axis | Assigned value |
| --- | --- |
| Architecture | **Triptych ADT fold (Idle | Spooled | Woven); the gallery is a fold over daykey Triptychs; Thread writes a Lemma on a Slip; when any normalized Lemma names at least three Slips from three distinct VolumeIDs the fold becomes Spooled; Weave writes a WeaveMark, seats three SlipIDs in Triptych panels, and folds Spooled to Woven; Weave on Idle writes BareMark; Weave when no Lemma qualifies writes ThinMark; Peel removes WeaveMark and folds Woven to Spooled; a second Weave on the same daykey while Woven is refused until Peel; empty gallery writes Blank** |
| UI approach | **SwiftUI multi module packages value NavigationStack routing · canvas-first** |
| Naming convention | **Lemma / triptych lexicon (Volume, Slip, Lemma, Triptych, Panel, ThreadMark, WeaveMark, ThinMark, BareMark, Peel, Blank)** |
| File organization | **By triptych role (Gallery, Volume, Slip, Lemma, Triptych, Panel, WeaveMark, ThinMark, BareMark, Peel)** |
| Dependency strategy | **None (zero external dependencies) · no SPM entry, no CocoaPods, no vendored source; UIKit, Core Graphics, AVFoundation and URLSession only** |
| Design direction | **supabase · action-strip · mid** |
| Typography | **American Typewriter** |
| Navigation pattern | **Triptych-locked chrome (the lemma chip rail and three weave panels never leave; Shelf and Dashboard arrive as sheets; thread and weave fuse on Quotes; Settings as a sheet; no tab bar)** |
| AI art style | **Flat corporate vector data viz · documentary** |
| Functional twist | **Thread-then-weave (Thread writes Lemma on Slip; Weave seats triptych when three volumes share a lemma; Weave on Idle refused; second Weave same daykey refused until Peel)** |
| Persistence | **UserDefaults+Codable · one Board root record holding Stations, Staff, Shifts, Pin, TillMarks, Bouts and Marks, encoded under a single key with debounced save after each mark** |
| Screen composition | see 3.6 |

### 3.0 Product concept

This is the product the contracts below are assigned to. Do not substitute another.

**Family** — book_quotes

**Core** — A reader threads saved lines with one lemma and weaves a daily triptych from three quotes that share it across three different books.

**Audience** — Commonplace-book keepers who want a repeatable daily refrain after the physical volumes are gone—not page-percent tracking, not a fan ritual, and not a pasted cento.

**User flow**

1. On Quotes home, tap Weave to seat today's triptych from the seeded threshold lemma across three volumes.
2. Long-press a slip in the margin list to thread or change its lemma word.
3. Open Shelf as a sheet, add a volume, and capture a new slip with title, author, text, and optional page.
4. Mark a volume gone on Shelf so its spine hollows but its threaded slips stay weavable in the triptych pool.
5. Open Dashboard to read Swift Charts of top lemmas and consecutive woven days.
6. Peel today's weave to reopen Spooled and try another qualifying lemma the same day.

**Essential features**

- Local volumes and slips with no account or sync
- One normalized lemma per slip (Thread) with a live eligibility rail when three distinct volumes qualify
- Triptych home with three panels filled by Weave and frozen under daykey
- Gone volumes hollow on Shelf without deleting slips or lemmas
- Dashboard analytics via Swift Charts (lemma frequency, woven-day streak)
- Peel undoes the newest WeaveMark for today
- Simulator seed: three volumes, three threshold slips, fold Spooled so Weave is the first tap

**Twist** — Thread-then-weave fold

**Why this is not a repeat** — Same family as Margent and Posy but a different persisted verb: weave a three-panel triptych from lemmatized slips, not write-while-held, not release-then-fan, and not Pastedown's adjacent-volume cento paste. No camera, no remote catalog, no WebView. Home is the weave mechanic with Charts on Dashboard only.

### 3.0a Craft from the shipped portfolio

Full craft is in KNOWLEDGE.md. Follow it. Do not copy type names or layouts.
- Home: Shelf of spines. Drill shelf → book → margin.
- Invariant: One quote-store per book. Verdict is reread / not — no stars. progressFraction = currentPage/totalPages.
- Never: Not a store catalog crate.
- Desk `weave_pace`: weeksRemaining=(target−done)/last7d_meters. Nil if no meters this week.
- Taste DNA is section 7.6. Do not invent a second look.
- A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

### 3.1 Architecture contract

Refrain models its state as a pure Triptych ADT fold with phases Idle | Spooled | Woven evaluated per YYYYMMDD Int daykey across the Gallery root record. Each Volume holds its own quote store of Slips, and marking a Volume gone hollows its spine on the shelf while preserving its Slips and Lemmas in the triptych pool. Applying Thread writes a ThreadMark that normalizes and assigns a single Lemma word to a Slip; whenever any Lemma spans at least three Slips across three distinct VolumeIDs, the day fold transitions from Idle to Spooled. Applying the home verb Weave on Spooled writes a WeaveMark, seats three qualifying SlipIDs into the three Triptych Panels, and transitions the daykey fold to Woven. Simulator seed rfr.demo.v1 populates three Volumes and threads the lemma threshold across three Slips so the fold starts in Spooled and the primary Weave button is live on first frame. Unit tests verify refused transitions: invoking Weave on Idle appends a BareMark while leaving panels empty, invoking Weave when no Lemma spans three distinct volumes appends a ThinMark, and invoking a second Weave on the same daykey while Woven is rejected until Peel removes the newest WeaveMark and reopens Spooled.

Put a short comment block at the top of each principal type stating the role it
plays in this architecture. The README must justify the pattern for this product.

### 3.2 UI contract

SwiftUI canvas-first architecture organized into multi-module local packages with value-typed NavigationStack routing for sheet destinations. The root Quotes canvas locks the live eligibility lemma rail, the three triptych panels, and the action-strip bar on screen without a TabView. Interactive controls use a dedicated ButtonStyle implementing default, pressed (scale 0.97, 150ms ease-out), disabled, and loading states, with travel gated by accessibilityReduceMotion so reduced-motion users receive opacity fades only.

### 3.3 Naming contract

Convention: Lemma / triptych lexicon (Volume, Slip, Lemma, Triptych, Panel, ThreadMark, WeaveMark, ThinMark, BareMark, Peel, Blank).

Examples to follow: Gallery, Volume, Slip, Lemma, Triptych, Panel, ThreadMark, WeaveMark, ThinMark, BareMark, Peel, Blank

### 3.4 Dependency contract

Zero external dependencies: no Swift Package Manager packages, no CocoaPods, and no vendored third-party source. The binary imports only Apple system frameworks SwiftUI, Foundation, Charts, UIKit, and CoreGraphics, with no camera frameworks and no network catalog calls.

### 3.5 Navigation contract

Triptych-locked chrome keeps the Quotes canvas, lemma eligibility chip rail, and three weave panels permanently rooted with no TabView and no root back button. Shelf, Dashboard, and Settings open as modal sheets over the Quotes canvas using value-typed NavigationStack presentation with explicit Close controls and scale 0.96-to-1 fade transitions. Launch argument -ReviewScreen routes directly to today (Quotes home), log (Shelf sheet), goals (Dashboard sheet), and settings (Settings sheet) after onboarding and simulator seeding complete.

### 3.6 Screen composition contract

Triptych-root fused quotes (Quotes holds lemma rail and triptych weave; Shelf and Dashboard arrive as sheets; Settings as sheet; maps family Shelf|Quotes|Dashboard|Settings with Quotes home; no TabView)

Quotes (root canvas featuring the oversized active lemma header, live eligibility chip rail, three-panel triptych weave board, action-strip with Weave and Peel verbs, and margin slip list for long-press threading), Shelf (sheet presenting volume spines with Held or Hollowed Gone state, progressFraction = currentPage / totalPages, reread verdict toggle without star ratings, volume creation, and slip capture with title, author, text, and optional page), Dashboard (sheet rendering Swift Charts for top woven lemmas and consecutive woven-day streak), Settings (sheet with data reset, export summary, and tappable Contact URL to refrain-triptych.pro), and Onboarding (full-page introduction with bottom full-width Continue CTA, skipped on Simulator when rfr.demo.v1 is seeded).

Section 5 lists the logical functions that must exist. This section decides how
they are grouped into actual screens. Where the two disagree, this section wins.

A TabView with exactly three tabs is the factory stamp — use two or four-to-five destinations, or a different chrome. `-ReviewScreen today|log|goals` are launch keys, not tabs.

---

## 4. Target file organization

Scheme: **By triptych role (Gallery, Volume, Slip, Lemma, Triptych, Panel, WeaveMark, ThinMark, BareMark, Peel)**

```
Refrain/
  Refrain/
  App/
    RefrainApp.swift
    ReviewRouter.swift
  Gallery/
    GalleryStore.swift
    GalleryPersistence.swift
    DemoSeed.swift
  Volume/
    Volume.swift
    ShelfSheet.swift
    SpineRow.swift
  Slip/
    Slip.swift
    SlipComposerSheet.swift
  Lemma/
    Lemma.swift
    ThreadMark.swift
    LemmaRailView.swift
  Triptych/
    Triptych.swift
    Panel.swift
    QuotesCanvasView.swift
  Marks/
    WeaveMark.swift
    ThinMark.swift
    BareMark.swift
    Peel.swift
    Blank.swift
  Dashboard/
    DashboardSheet.swift
    SettingsSheet.swift
  DesignSystem/
    ThemeTokens.swift
    ActionStripButtonStyle.swift
  Assets.xcassets/
```

Adapt the leaf files to the architecture, but the top-level shape is fixed. Do
not create a `Utils/` or `Helpers/` dumping ground.

---

## 5. Screens

Build the screens named in section 3.6. The labels below are logical;
actual type names follow this app's naming convention.

### 5.1 Onboarding
Three to four pages. Explains the product, writes initial settings, sets a
completion flag. Skip still writes sensible defaults. Re-runnable from Settings.

### 5.2 Shelf
A first-class screen for **Shelf**. Must render empty, populated and error states.

### 5.3 Quotes
A first-class screen for **Quotes**. Must render empty, populated and error states.

### 5.4 Dashboard
A first-class screen for **Dashboard**. Must render empty, populated and error states.

### 5.5 Settings
A first-class screen for **Settings**. Must render empty, populated and error states.

### 5.6 Settings
Holds: re-run onboarding, reset all data (confirmed), and the contact link to
the domain contact-us URL.

### 5.7 Twist screen
See section 12. The twist needs at least one screen of its own plus a surface on the home screen.


---

## 6. Domain model

Minimum entities, named per this app's convention:

- **Book** — named per this app's convention.
- **Quote** — named per this app's convention.
- Plus whatever the twist in section 12 requires.


---

## 7. Design system

Direction: **supabase · action-strip · mid**

### 7.1 Palette

| Token | Hex | Use |
| --- | --- | --- |
| `background` | `#3B2848` | Screen background |
| `surface` | `#4A3857` | Cards, rows, sheets |
| `ink` | `#F5F4F6` | Primary text and icons |
| `accent` | `#B270E1` | Primary action, key figure, progress fill |
| `muted` | `#BEB6C3` | Secondary text, dividers, disabled |

The scaffold already wrote these exact values to `Refrain/DesignTokens.swift`
(`DesignTokens.bg`, `.surface`, `.ink`, `.accent`, `.muted`, plus
`DesignTokens.fontFamily`). Reach every colour through `DesignTokens` — a
typed accessor on top of it is fine. Keep the file and its hex values; do not
move them into `Assets.xcassets` and never hard-code a hex string anywhere else.

### 7.2 Typography

Family: **American Typewriter**

American Typewriter drives the literary commonplace voice inside the tactical dark-tech frame, setting the oversized single-word active lemma headline and the three woven quote panels with fixed vertical sizing so lines never clip. SF Pro handles compact tactical status labels, lemma rail counts, and sheet chrome, while numeric metrics and YYYYMMDD daykeys pass through NumberFormatter with monospaced digits and Dynamic Type scaling via ScaledMetric.

Define a type scale of at most six steps behind one accessor and use only those
steps. Text stays legible at the largest Dynamic Type size.

### 7.3 Layout

- One base spacing unit (4 or 8 pt); only multiples of it.
- Corner radius and elevation are fixed by section 7.4, not chosen per screen.
- Every interactive element is at least 44x44 pt.

### 7.4 Component contract

Corner radius: **18pt** for cards, sheets and primary surfaces; **8pt** for chips, badges and small controls. Reach both through one accessor. Never a bare literal number, and never zero — a hard edge is not this app's design direction.

Elevation: **shadow** — a single soft drop-shadow token, reused everywhere a surface sits above another.

Primary control: **bordered prominent** — primary actions use `.buttonStyle(.borderedProminent)` or an equivalent filled, bordered shape.

This is arithmetic, not a suggestion: every card, sheet, chip and button in this app uses these two radii and this elevation style. Do not introduce a second radius or a second elevation style.

### 7.5 Custom rendering scope

This app's `ui` axis is **SwiftUI multi module packages value NavigationStack routing · canvas-first**.

If that approach uses anything beyond stock SwiftUI/UIKit controls — `Canvas`, `CALayer`, Metal, SceneKit, SpriteKit, RealityKit, a hand-drawn `UIViewRepresentable`, or any other pixel-level custom rendering — confine it to exactly one hero surface on one screen (the mechanic's home view, or the one screen this axis exists to showcase). Every other screen — every list, every settings screen, every sheet, every secondary surface — is built from stock components: `List`, `Form`, `NavigationStack`, `TabView`, `Button`, `.sheet`, native `Text`/`Image`. A second custom-rendered surface elsewhere in the app is a defect, not a stylistic choice.

If **SwiftUI multi module packages value NavigationStack routing · canvas-first** is already fully native (no custom drawing layer), this section is satisfied automatically — there is nothing to confine.

The `ui` axis value is an implementation choice. It must never appear as a user-visible section title or label.

### 7.6 Taste DNA

Aesthetic: **dark** (Dark-tech: void surfaces, one glow or jewel, sparse chrome.)

Reference system: **supabase** — steal rhythm and restraint, not their colours or logos.

Mood: **Open-source Firebase alternative. Dark emerald theme, code-first.**.

Home rhythm (`action-strip`, airy): A strip of actions under a live figure.

Dark-tech: void surfaces, one glow or jewel, sparse chrome. Layout `action-strip`, density airy. Kit 18/8, shadow, bordered prominent. Palette recipe `mid`. Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only. Reduce Motion: fade only. Do not invent a second radius or a second accent.

Type move: Oversized single word, then silence. Reference type feel: dark.

Motion (`snap`): Press scale 0.97, 140-180ms ease-out. Sheets scale 0.96 to 1 plus fade. Reduce Motion: opacity only.

Voice (`tactical`): Status-first. Noun plus state. 'Scan failed. Try again.'

Anti-slop from KNOWLEDGE.md applies. Taste never overrides contrast, 44pt hits, VoiceOver labels, or Reduce Motion.

---

## 8. UI and UX quality bar

Every item here is a defect if it is missing. Do not treat this as advice.

**Layout**

- Respect safe areas on every screen. Nothing sits under the notch, the Dynamic
  Island or the home indicator.
- iPhone allows portrait, landscape left, and landscape right. iPad allows all
  four orientations. Keep both lists in the Info settings, and let a rotated
  screen scroll instead of clipping.
- No layout shift when asynchronous data arrives. Reserve the final size up
  front, or use a redacted placeholder of the same dimensions.
- Long product names must truncate gracefully, never push a number off screen.
  Numbers win; names truncate.
- Sibling cards, images and titles never overlap. Each cell owns its frame;
  `scaledToFill` is clipped to that cell. A chopped headline or two canvases
  in one slot is a defect, not a collage.
- Every headline, amount, and button title is fully visible. Do not give display
  type a fixed height shorter than the font, and do not let a sibling with
  `maxHeight: .infinity` compress it. When the column is taller than the screen,
  scroll it. `.clipped()` frames an image cell; it never wraps text.
- Minimum tap target 44x44 pt for every interactive element, including small
  icon buttons and list accessories.
- Pick one base spacing unit and use only multiples of it. No arbitrary values.

**Keyboard**

- The grams field uses `.decimalPad`, and the decimal separator matches the
  user's locale.
- Content scrolls out from under the keyboard. The focused field is always
  visible.
- Tapping outside the field, or scrolling, dismisses the keyboard.
- Validate on the fly: reject negative and non-numeric input rather than
  crashing the parser later.

**Loading and state**

- Every asynchronous operation has a visible loading state.
- Guard against the spinner flash: if the work finishes in under 150 ms, do not
  show a spinner at all.
- Every list has a designed empty state containing a primary action, not just a
  sentence of text.
- Every error state offers a retry, and states plainly what failed.
- Disable the primary button while its action is in flight so it cannot be
  double-tapped into a double push or a duplicate entry.

**Typography and accessibility**

- All text scales with Dynamic Type. Verify at the largest accessibility size:
  nothing may clip or overlap.
- Every icon-only control has an `accessibilityLabel`. Decorative images are
  marked as decorative so VoiceOver skips them.
- Colour is never the only signal. Pair it with a label, a shape or an icon.
- Honour Reduce Motion: replace movement-heavy transitions with a fade.
- Meet contrast requirements against the palette in section 7. Check the muted
  colour against the background specifically; that is where these palettes fail.

**Formatting**

- Format every number with `NumberFormatter`, never string interpolation. Group
  separators and decimal separators must follow the locale.
- Energy is shown as a whole number of kcal. Macros are shown with at most one
  decimal place.
- Round only at the point of display. Stored values keep full precision.
- Day boundaries use `Calendar.current.startOfDay(for:)` in the user's current
  time zone. Handle the day changing while the app is open, and handle the
  short and long days that daylight saving produces.
- Unknown macro values render as a dash or the word "unknown", never as 0.

**Motion and feedback**

- One haptic on a successful commit (a food logged, a target saved). No haptic
  on navigation.
- Animations are short (0.2 to 0.35 s) and use a single shared easing curve.
- Nothing animates on first appearance of a screen except an intentional entry
  transition.

**Navigation**

- The root screen has no back button. `.navigationTitle` is a screen name, never
  the product name. A back control titled with the app name is a defect: it
  reads as a button that returns to this same app.
- A sheet dismisses with Close and owns its stack. Do not push it onto a stack
  whose title is the product name.
- Back always works and never loses entered data without asking.
- A destructive action (delete a log row, reset all data) is confirmed.
- Modal sheets can always be dismissed; there is no dead end.
- Deep state is restorable: relaunching returns the user to a sane screen.


Every item here is a defect if it is missing. Section 7.4 fixed the numbers —
this is where they have to show up on screen.

**Hierarchy and density**

- Every screen has exactly one dominant element (a hero number, a canvas, a
  primary card) that the eye lands on first. A screen where every element has
  equal weight reads as a spreadsheet, not a product.
- Related content is grouped into a card or a section with the elevation
  style from 7.4, not left floating on the bare background.
- Unused flat background is not "minimal" — see the density rule in
  `KNOWLEDGE.md`. If a screen has room left after the mechanic and the
  content, add a secondary surface (a stat strip, a recent-activity card, a
  related-item row), not a `Spacer`.

**Components**

- Every card, sheet, chip, row and button in the app uses the corner radius
  and elevation from section 7.4. No screen introduces its own radius or its
  own shadow value "just for this one card".
- Buttons have a pressed state (`ButtonStyle` with a scale or opacity change
  on `isPressed`) and a disabled state that is visibly different, not just
  non-interactive.
- Chips and badges are pill or rounded-rect shaped per 7.4, never a bare
  `Text` with no background sitting where a control is expected.
- A functional control (add, filter, sort, close, more, share, delete) is an
  SF Symbol inside a properly hit-targeted `Button`. SF Symbols are fine and
  expected here — section 16 only bans them as the app's primary brand
  iconography (app icon, empty-state hero, onboarding art), which is what the
  generated assets in section 13 are for.

**Depth and material**

- At least one surface in the app (a sheet, a modal, a floating toolbar) uses
  the elevation style from 7.4 to visibly sit above the content behind it.
  A flat app with no depth anywhere reads as a wireframe.
- Icons and generated art sit on the surface colour from 7.1, never directly
  on a colour that makes their edges disappear.

**Motion as feedback, not decoration**

- The one dominant element in a screen (7.4's primary control, the mechanic's
  hero) responds visibly to touch: a scale, a colour shift, a haptic — pick
  at least one. A control that looks identical pressed and unpressed reads as
  broken, not calm.

**Taste DNA (section 7.6)**

- Home uses the assigned layout family and density. Three identical equal-weight
  cards, a leftover bento hole, or a second column structure copied down the
  page is a defect.
- Copy follows the assigned voice. No em-dash, no elevate/unlock/seamless, no
  emoji, no SECTION 01 labels.
- Motion follows the assigned personality and honours Reduce Motion with a fade.
  One signature motion per view. No glow stacked on glass stacked on spring.
- Tokens by intent: the live verb wears accent; delete does not wear primary.


---

## 9. Concurrency

The target builds with Swift 6.2 and `SWIFT_STRICT_CONCURRENCY = complete`. It
must compile with **zero concurrency warnings**. Warnings here become crashes
later, so they are not negotiable.

- All UI types are `@MainActor`. Annotate the type, not individual methods.
- Any value crossing an actor boundary is `Sendable`. Prefer immutable structs
  of primitives.
- Do not use `@unchecked Sendable`. If it is genuinely unavoidable, it needs a
  comment explaining what guarantees the safety.
- No mutable global state. No `static var` that is written after launch.
- Networking and storage APIs are `async` and honour cancellation. When the
  search query changes, cancel the in-flight task; do not let a stale response
  overwrite fresh results.
- Use structured concurrency. Avoid `Task.detached` unless there is a stated
  reason. Never fire a `Task` that outlives the view without owning it.
- Never use `DispatchQueue.main.asyncAfter` to paper over an ordering problem.
  Fix the ordering.
- `Timer` and notification observers are invalidated in `deinit` or on
  disappear.


---

## 10. Persistence engineering

Chosen technology: **UserDefaults+Codable · one Board root record holding Stations, Staff, Shifts, Pin, TillMarks, Bouts and Marks, encoded under a single key with debounced save after each mark**

UserDefaults+Codable persistence encoding a single root Gallery record containing Volumes, Slips, Lemmas, DayTriptychs, ThreadMarks, WeaveMarks, ThinMarks, BareMarks, and Peel entries under key rfr.gallery.v1 with debounced save after each mark, alongside simulator seed key rfr.demo.v1.

This app persists to **files on disk**. The following are mandatory.

- Write atomically. Either `Data.write(to:options: .atomic)` or write to a
  temporary file and `FileManager.replaceItemAt`. A non-atomic write that is
  interrupted leaves a truncated file and the app will not launch.
- Create the containing directory with
  `withIntermediateDirectories: true` before the first write.
- Every document carries a `schemaVersion` field from version 1, and the decoder
  switches on it.
- Decoding failure must be recoverable: keep the previous good file as a
  `.backup`, fall back to it, and if that also fails start from empty state and
  tell the user. Never crash on a corrupt file.
- All file IO happens off the main thread. The main thread never blocks on disk.
- Debounce writes during rapid edits, but force a flush when `scenePhase`
  becomes `.inactive` or `.background`, and after any destructive action.
- Exclude caches from backup with `URLResourceValues.isExcludedFromBackup` where
  appropriate; user data belongs in Application Support and should be backed up.
- Keep an explicit in-memory source of truth and treat the file as a projection
  of it, so a failed write never leaves the UI showing data that does not exist.


Regardless of technology:

- One seam between domain logic and storage; the UI never touches storage types.
- Writes survive a force-quit. Do not rely on `applicationWillTerminate`.
- Provide `resetAllData()`, used by tests and reachable from Settings.

---

## 11. Networking

- One client type owns both Open Food Facts endpoints.
- Set `User-Agent` on every request. Open Food Facts throttles clients that do
  not identify themselves.
- 15 second timeout. One retry on a transient transport failure, then a typed
  error. Do not retry a 404.
- Cancel the in-flight search when the query changes. Debounce input by roughly
  300 ms.
- Decode into DTO types that mirror the JSON exactly, then map to domain types.
  Never decode straight into your domain model.
- Dedicated `JSONDecoder` with `.useDefaultKeys`. Never `convertFromSnakeCase` —
  Open Food Facts keys like `energy-kcal_100g` break snake_case conversion.
- Resolve a scanned code with `GET /api/v2/product/<barcode>.json`, not a search.
- Open Food Facts data is user-contributed and frequently incomplete. Every
  numeric field is optional. A product with no energy value is a normal case
  that the UI must present, not an error.
- Some numeric fields arrive as strings. The decoder must accept both a number
  and a numeric string for every nutriment.
- `status` of `0` in the product response means not found. Map it to a distinct
  error case so the UI can offer manual entry.
- Never crash on malformed JSON. A decoding failure is a handled error.
- Cache every resolved product locally on success, so the app degrades to a
  working offline catalogue.


Set `User-Agent: Refrain/1.0 (iOS; +https://refrain-triptych.pro)` on every request. Never reuse another app's string.
No required remote catalog. Network only if this product actually needs it.
No scanner and no remote catalog in this product. Do not import AVFoundation or Vision for capture, do not add a camera usage description, and do not call a search endpoint. Ignore a leftover scanner or search axis.


---

## 11b. App Store readiness

The app must be submittable without further work.

- `PrivacyInfo.xcprivacy` in the target, declaring the UserDefaults access API
  reason `CA92.1` and the file timestamp reason `C617.1`, with
  `NSPrivacyTracking` false and no collected data types.
- `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO` in the pbxproj so TestFlight
  does not sit on Missing Compliance.
- `NSCameraUsageDescription` written specifically for this app. Generic strings
  get rejected.
- `LSApplicationCategoryType` of `public.app-category.healthcare-fitness`.
- iPhone: portrait, landscape left, landscape right. iPad: all four orientations (`TARGETED_DEVICE_FAMILY = "1,2"`).
- No account, no sign-in, no delete-account flow, no in-app purchase, no ads, no
  user-generated content, and therefore no report or block UI.
- App Tracking Transparency is never invoked.
- The camera is the only sensitive permission requested.
- Guideline 5.1.1 (Privacy): do not encourage or direct the user to grant camera
  access. A pre-permission screen may exist, but the proceed button must be
  **Continue** or **Next** — never "Allow camera", "Enable camera",
  "Grant camera", or a bare Allow/Enable that calls `requestAccess`. The
  system dialog is the only Allow. Denied/restricted offers Open Settings.
- The app must not present itself as a clinician or as medical advice.
- Guideline 4.2 (Design — Minimum Functionality): the binary must be a native
  product, not a web browsing experience. No WKWebView / SFSafariViewController
  / UIWebView as home, a tab, or the primary UX. A content catalog, article
  reader, or site wrapper that could be a website is a reject. Push
  notifications, Core Location, and sharing do not make that acceptable.
- Guideline 1.4.1 (Safety — Physical Harm): if the binary shows health or
  medical recommendations, body-based targets, dosages, "you should" guidance,
  or product health claims (food, drink, supplement, remedy), put citations
  in the app. Tappable links to the sources, easy to find: same screen as the
  claim, or a Sources row one tap from Settings. Name the source (Open Food
  Facts, USDA FoodData Central, WHO, NIH MedlinePlus, …) and link it. A
  "not medical advice" footer without sources is a reject. A personal log
  that never advises does not invent claims to cite.
- Nutrition catalog data is credited to the database this app actually uses
  (Open Food Facts unless the spec names another). Credit is a tappable link,
  not a dead "OpenFoodFacts" label.


### First minute on a clean install (Guideline 2.1)

A reviewer judges completeness (Guideline 2.1) in the first minute on a clean
install. The loop must finish there without knowing the app's rules. Long form:
`docs/REVIEW-LESSONS-2026-09-25.md`.

- The home verb writes a visible object on the first tap of a clean install:
  a row, a card, a mark on the dial. No second screen needed to see it.
- Never leave the home control disabled until an unexplained condition holds
  ("two links first", "long press first", "add a volume first"). Accept the
  first input with sane defaults and show the rule afterwards.
- The twist fires after a successful write, as a visible consequence (a highlight,
  a caption, a next step), never instead of the write.
- A refusal is allowed only after the first success, and it must name the next
  tap that works.
- Nothing in the first session waits for midnight, a second day, a second item or
  a streak. A screen that can only fill later shows its action, not a wait.
- Every empty state names one action, and that action completes on the spot.
- Next to home there is at least one more screen that works on a clean install.
- The subtitle and the first description line name an everyday action a stranger
  understands. Coined words may decorate labels; each primary button still says
  what it does.
- A failed network lookup falls back to local data or typed input with a message;
  the loop still finishes offline.


Ignore the food-log and Open Food Facts lines above when they conflict with this
family. Category for this app is `public.app-category.books`. Camera permission only if the
product actually captures.

Project settings that follow from the above:

```yaml
INFOPLIST_KEY_UIUserInterfaceStyle: Dark
INFOPLIST_KEY_UISupportedInterfaceOrientations: UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad: UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight
INFOPLIST_KEY_UIRequiresFullScreen: YES
INFOPLIST_KEY_ITSAppUsesNonExemptEncryption: NO
INFOPLIST_KEY_LSApplicationCategoryType: public.app-category.books
TARGETED_DEVICE_FAMILY: "1,2"
SWIFT_STRICT_CONCURRENCY: complete
```

---

## 12. Functional twist: Thread-then-weave (Thread writes Lemma on Slip; Weave seats triptych when three volumes share a lemma; Weave on Idle refused; second Weave same daykey refused until Peel)

The Thread-then-Weave mechanic separates slip annotation from daily triptych assembly across the Idle | Spooled | Woven fold. Long-pressing a Slip in the margin list or saving a Slip threads a normalized Lemma word via ThreadMark; once any single Lemma links at least three Slips from three distinct VolumeIDs, the day fold shifts to Spooled and highlights the qualifying chip in the rail. Tapping Weave commits a WeaveMark for the current YYYYMMDD daykey, locks the three SlipIDs into the left, center, and right Panels, fires a single commit haptic, and folds Spooled into Woven. Simulator seed rfr.demo.v1 pre-populates three Volumes and three Slips threaded with the lemma threshold (plus additional commonplace slips), leaving today's fold in Spooled so Weave is immediately live on first launch. Unit tests enforce all guardrails: calling Weave while Idle records a BareMark and leaves panels empty, calling Weave when no lemma spans three volumes records a ThinMark, and calling Weave a second time on the same daykey while Woven is refused until Peel removes today's WeaveMark and restores Spooled.

This is the app's marketed differentiator. It must be:

- visible on the home screen, not buried in settings;
- backed by real persisted data, not a cosmetic flourish;
- covered by at least one unit test;
- described in the README as the reason a user would pick this app.

---

## 13. AI-generated assets

Art style: **Flat corporate vector data viz · documentary**


Base prompt, reused and extended for every asset:

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects.
```

All 7 images below are required. Generate each one, export
as PNG, and add it to `Assets.xcassets` as its own image set named exactly as
given. Every name carries the `rfr_` prefix.

### 13.1 App icon

Do not generate an app icon. Do not create an AppIcon image set and do not
paint icon artwork. The factory installs the icon later. Leave the empty
AppIcon.appiconset from the scaffold untouched.

### 13.2 Full asset list

| # | Image set | Size (px) | Alpha | Purpose |
| --- | --- | --- | --- | --- |
| 1 | `rfr_Onboarding1` | 1024x1536 | **required cutout** | Onboarding page 1 illustration: what the app is for. |
| 2 | `rfr_Onboarding2` | 1024x1536 | **required cutout** | Onboarding page 2 illustration: the main verb. |
| 3 | `rfr_Onboarding3` | 1024x1536 | **required cutout** | Onboarding page 3 illustration: why they stay. |
| 4 | `rfr_EmptyHome` | 1024x1024 | **required cutout** | Empty state: the home screen has nothing yet. Calm and inviting, never sad. |
| 5 | `rfr_TwistHero` | 1024x1024 | **required cutout** | Hero art for the 'Thread-then-weave (Thread writes Lemma on Slip; Weave seats triptych when three volumes share a lemma; Weave on Idle refused; second Weave same daykey refused until Peel)' feature screen. |
| 6 | `rfr_EmptyShelfCutout` | 1024x1024 | **required cutout** | Flat documentary vector cutout illustration of three orthographic book spines linked by a clean geometric thread diagram, solid central subject with crisp edges on a transparent PNG background |
| 7 | `rfr_EmptyTriptychCutout` | 1024x1024 | **required cutout** | Flat corporate vector data-viz cutout of an open three-panel folding triptych frame with technical registration marks, solid interior geometry on a transparent PNG background |

### Prompt per asset

**`rfr_Onboarding1`** — 1024x1536

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects., a person or object that is this product in one glance

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_Onboarding2`** — 1024x1536

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects., the primary action of this product, mid-gesture

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_Onboarding3`** — 1024x1536

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects., a later moment when the product has accumulated meaning

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_EmptyHome`** — 1024x1024

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects., a solid closed bowl, crate or folded cloth waiting to be used — ceramic, wood or fabric, fully opaque, not glass

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_TwistHero`** — 1024x1024

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects., an emblem representing this app's signature feature

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_EmptyShelfCutout`** — 1024x1024

```
Flat documentary vector cutout illustration of three orthographic book spines linked by a clean geometric thread diagram, solid central subject with crisp edges on a transparent PNG background

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```

**`rfr_EmptyTriptychCutout`** — 1024x1024

```
Flat corporate vector data-viz cutout of an open three-panel folding triptych frame with technical registration marks, solid interior geometry on a transparent PNG background

HARD CUTOUT: isolated SOLID opaque subject on a fully transparent background, occupying the center of the canvas. Real PNG alpha channel. All four corners fully transparent. No square plate, no painted backdrop, no opaque box, no drop shadow that fills the canvas. Not glass, not a hollow frame, not a wire outline, not an empty vitrine — rembg punches through those and the cutout is empty. GenerateImage writes opaque RGB — after copy, convert the PNG to RGBA in place; do not generate it again for alpha.
```


### 13.3 Asset rules

- Cut-outs (everything except AppIcon, Splash, CardBackdrop): isolated subject,
  real PNG alpha, all four corners transparent. No square plate.
- Assets must be semantically different from each other.
- Record the exact prompt used for every asset in the README.
- SF Symbols are permitted only for close, chevron, share and similar system
  affordances.

Scanner frames, reticles, and seamless tiles are drawn in SwiftUI via `Path` or `Shape`. GenerateImage is not used for those. Every other in-app graphic (except AppIcon, Splash, CardBackdrop) is a **cutout**: isolated SOLID opaque subject in the center, real PNG alpha, all four corners transparent. An opaque square plate inside a circle or pentagon is a fail. A hollow glass box or wire frame with a transparent center is a fail.

---

## 14. Demo data

Seed a small local demo dataset for this family's entities so Simulator
screenshots are not empty. The same seed must mark onboarding complete and
fill the primary surface — otherwise `-ReviewScreen` never fires. Never seed
on a physical device. Guard with `#if targetEnvironment(simulator)` and
`rfr.demo.v1`.

Seed the happy path: the home primary verb is enabled. The blocked / gated /
error state is a unit-test fixture, not Simulator home. Home chrome names the
job and the next tap in words a stranger knows. Axis values (`ui`, `naming`,
`architecture`) never become user-visible titles. A card that looks tappable
is a `Button`. A readout does not use button chrome.

---

## 16. Anti-patterns

The following will fail review:

- `try!`, `as!`, or force-unwrapping anything derived from the network, the
  database or a file.
- `fatalError` anywhere reachable at runtime. It is acceptable only for a
  programmer error in an initialiser that cannot fail in practice, and needs a
  comment.
- Swallowing an error with an empty `catch`.
- `print` used as production logging.
- A hard-coded hex colour outside the single colour accessor.
- A hard-coded font name outside the single typography accessor.
- An SF Symbol used as the app's brand iconography — the app icon, the
  empty-state hero, or onboarding art. Those come from section 13. SF Symbols
  are the right choice for every functional control (add, filter, sort,
  close, share, delete) — leaving those as bare text instead of a symbol is
  also a defect.
- Storing a value that can be computed (day totals, remaining budget, macro
  percentages).
- Blocking the main thread on disk or network work.
- `UIScreen.main` for sizing. Use the geometry the layout system gives you.
- Index positions used as list identity. Identity is a stable identifier.
- A view that reaches into the persistence layer directly, bypassing the
  architecture's designated seam.
- Business logic inside a `View` body or a `UIViewController` method, when the
  assigned architecture places it elsewhere.
- Copying a source file from another app in this batch.
- A `TabView` with exactly three tabs. That is the factory stamp — two or
  four-to-five destinations, or a different chrome. ReviewScreen keys are
  not tabs.


---

## 17. Tests

Add a unit test target `RefrainTests` covering at minimum:

1. The core domain invariant of this family (the thing that would be wrong if
   the calculator, decay, crate, or log lied).
2. Empty, populated and invalid input paths for the primary verb.
3. The section 12 twist logic.
4. One architecture-specific test proving the pattern holds.
5. A persistence round-trip: write, relaunch-equivalent reload, verify.
6. `Refrain/ReviewLaunch.swift` (scaffold, keep it) parses `ProcessInfo.processInfo.arguments`.
   Read `ReviewLaunch.screen` once after onboarding:
   `-ReviewScreen today|log|goals` switches the running app's live navigation. Extra cover slugs open those screens.
   Cover that parser with a unit test. Do not host a `View` in the test.

---

## 18. README.md

Write `README.md` at the app folder root covering:

1. What the app does and who it is for.
2. The architecture used and **why** it suits this product.
3. The unique feature added and how it works.
4. The AI art style and the exact prompt used for every asset.
5. How this app differs from others in the batch.
6. Build instructions.

---

## 19. Definition of done

**Build**
- [ ] `xcodegen generate` succeeds.
- [ ] `xcodebuild -scheme Refrain -destination 'generic/platform=iOS' build` succeeds.
- [ ] Zero new compiler warnings.
- [ ] Strict concurrency `complete` compiles clean.
- [ ] Test target passes.

**Function**
- [ ] Onboarding to first successful primary action works on a clean install.
- [ ] Every screen in section 3.6 exists and handles empty / filled / error.
- [ ] Reset and contact link live in Settings.
- [ ] Force-quitting immediately after a write loses nothing.
- [ ] Seeded home names the job and next tap; primary verb enabled.
- [ ] App reads `-ReviewScreen today|log|goals` after onboarding.
- [ ] `RefrainWatch` stays in the project. It reads `ReviewLaunch.screen` and opens the same today, log, and goals destinations, laid out for Apple Watch.

**Uniqueness**
- [ ] Architecture matches **Triptych ADT fold (Idle | Spooled | Woven); the gallery is a fold over daykey Triptychs; Thread writes a Lemma on a Slip; when any normalized Lemma names at least three Slips from three distinct VolumeIDs the fold becomes Spooled; Weave writes a WeaveMark, seats three SlipIDs in Triptych panels, and folds Spooled to Woven; Weave on Idle writes BareMark; Weave when no Lemma qualifies writes ThinMark; Peel removes WeaveMark and folds Woven to Spooled; a second Weave on the same daykey while Woven is refused until Peel; empty gallery writes Blank** with no leakage across layers.
- [ ] UI approach matches **SwiftUI multi module packages value NavigationStack routing · canvas-first**.
- [ ] Custom rendering, if any, is confined to one hero surface (section 7.5).
- [ ] Navigation matches **Triptych-locked chrome (the lemma chip rail and three weave panels never leave; Shelf and Dashboard arrive as sheets; thread and weave fuse on Quotes; Settings as a sheet; no tab bar)**.
- [ ] Screen composition follows section 3.6.
- [ ] Typography uses **American Typewriter** and nothing else.
- [ ] Palette matches section 7.1 exactly.
- [ ] Home rhythm and motion match section 7.6. No second look.

**Quality**
- [ ] Section 8 UI/UX bar satisfied end to end.
- [ ] Contact link present.
- [ ] `PrivacyInfo.xcprivacy` present and correct.
- [ ] README complete.

---

## 20. Build commands

```bash
cd Refrain
xcodegen generate
xcodebuild build-for-testing -scheme Refrain -destination 'generic/platform=iOS Simulator' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.refrain.triptych/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES
xcodebuild -scheme Refrain -destination 'generic/platform=iOS' -jobs 4 CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.refrain.triptych/DerivedData' SWIFT_TREAT_WARNINGS_AS_ERRORS=YES build
xcrun simctl list devices available
xcodebuild test-without-building -scheme Refrain -destination 'platform=iOS Simulator,id=<UDID>' -jobs 4 -derivedDataPath '/Users/belzephyrus/Documents/gambling-factory/.artifacts/genesis/com.refrain.triptych/DerivedData'
```

Signing is off only on that command line. Do not put CODE_SIGNING_ALLOWED, CODE_SIGNING_REQUIRED, CODE_SIGN_IDENTITY, DEVELOPMENT_TEAM, SWIFT_TREAT_WARNINGS_AS_ERRORS or -derivedDataPath in project.yml — they are command-line only. CI signs the archive. Leave CODE_SIGN_STYLE: Automatic as the scaffold set it. The exact simulator does not matter — use any available UDID from the list.
