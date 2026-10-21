# Refrain

A reader keeps lines from finished books and weaves one daily set of three when the same word sits on three different books.

## Who it is for

Commonplace-book keepers who want a repeatable daily refrain after the physical book is gone. It is not a page-percent tracker and not a star shelf.

## Architecture

The gallery is a fold of daykey triptychs. Each day is Idle, Spooled, or Woven. Thread only writes a normalized word onto a line. Weave only seats three lines when that word already spans three books, and it refuses a second seat on the same day until the day is reopened. That split belongs in the model because the screen must not invent the phase.

Screens send those verbs to `GalleryBoard`. The board is the only seam to `GalleryArchive` (one Codable document, UserDefaults plus a file). Views do not touch storage. Routing is a value enum presented in sheets over a locked Quotes canvas, so Shelf, Counts, and Settings never become a tab bar. There is no package dependency: the binary stays on Apple frameworks only.

## Why someone would pick this

Annotation and the daily three are different actions. You can mark a word on a line without seating today, and you can seat today only when three books share that word. Weave on an idle shelf records a bare mark and leaves the seats empty. Weave when words exist but none span three books records a thin mark. A second Weave on a seated day is refused until you reopen that day. Simulator seed `rfr.demo.v1` starts the day Spooled, so Weave is the first tap.

## Art

Style: flat corporate vector data visualization, documentary precision.

Base prompt, extended for every asset:

```
Flat corporate vector data visualization with documentary precision: crisp geometric diagrams, clean orthographic book spine schematics, structured three-panel triptych grid lines, and sharp vector cutout silhouettes with transparent alpha corners and solid central subjects.
```

`rfr_Onboarding1` (1024x1536, cutout): base prompt, plus a person or object that is this product in one glance. Isolated solid subject, transparent corners.

`rfr_Onboarding2` (1024x1536, cutout): base prompt, plus the primary action mid-gesture. Isolated solid subject, transparent corners.

`rfr_Onboarding3` (1024x1536, cutout): base prompt, plus a later moment when the product has accumulated meaning. Isolated solid subject, transparent corners.

`rfr_EmptyHome` (1024x1024, cutout): base prompt, plus a solid closed bowl, crate, or folded cloth waiting to be used. Isolated solid subject, transparent corners.

`rfr_TwistHero` (1024x1024, cutout): base prompt, plus an emblem of the signature weave. Isolated solid subject, transparent corners.

`rfr_EmptyShelfCutout` (1024x1024, cutout): flat documentary vector cutout of three orthographic book spines linked by a clean geometric thread diagram, solid central subject, transparent background.

`rfr_EmptyTriptychCutout` (1024x1024, cutout): flat corporate vector data-viz cutout of an open three-panel folding frame with technical registration marks, solid interior geometry, transparent background.

## How this differs

Margent hollows a spine while a line is written. Refrain keeps that shelf, then adds a separate daily seat: three lines, three books, one word, one day key. No camera, no remote catalog, no web view.

## Build

```bash
cd apps/Refrain
xcodegen generate
xcodebuild -scheme Refrain -destination 'generic/platform=iOS' build
```

Portrait only. Contact: https://refrain-triptych.pro
