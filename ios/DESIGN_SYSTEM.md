# UniMate design system

Code: `Sources/DesignSystem/Theme.swift` (tokens) and `Components.swift` (parts).
Screens must use these tokens instead of hex values, raw font sizes or one-off radii.
The C1 prototype (`C1/Mockup_v3/screens_source.html`) uses the same values as CSS variables.

## Idea

UniMate's distinctive feature is matching, so its visual language is built from it:

- **Match orbit**: radar rings with students linked to a centre (you, or your job).
  Closer means a better match. It appears on Welcome and Recommendations only, so it stays special.
- **Score ring**: always reads "97% match". Small rings put "match" underneath.
  The number is printed, so the score never depends on colour.
- **Reason chips**: every score comes with the reasons behind it ("1.4 km away").
- **Overlapping avatars**: a group of students who match.

Everything else stays quiet: one cream background, near-black text, and apricot used sparingly.

## Colour

| Token | Hex | Use | Contrast |
|---|---|---|---|
| canvas | #FBF5EC | page background | |
| sunken | #F3EADD | grouped lists, quiet tiles, tracks | |
| raised | #FFFDF9 | cards above the page (with hairline) | |
| hairline | #E6D9CA | dividers, outlines | |
| ink | #211B16 | titles, body, primary buttons, tab bar | 15.7:1 on canvas |
| inkSecondary | #6A5F55 | supporting text | 5.7:1 |
| inkTertiary | #877B70 | chevrons, placeholders (icons only) | 3.8:1 |
| apricot | #FFA266 | brand **fill**: score rings, Post button, top match outline, glow | ink on apricot 8.6:1 |
| apricotWash | #FFEBDC | strong reason chips, selected rows | |
| apricotTrack | #F6D9C2 | empty part of rings, bars, stars | |
| ember | #A9531C | orange **text and icons**, links, focused field | 4.9:1 on canvas |
| success / successWash | #2E7A4E / #E4F1E8 | verified, accepted, done | 4.8:1 |
| danger / dangerWash | #B23A2A / #FBE6E1 | errors, sign out, suspend | 5.5:1 |
| avatar green / purple / pink | #2F6B4F / #5B3F8C / #9C3D66 | avatars only | white initials 6.3–8.3:1 |

Rules:
- Never white text on apricot (2:1). Use ink.
- No blue or purple accents in the interface. Avatars are the only place other hues appear.
- Green and red mean success and destructive only.
- One gradient type: a radial apricot glow behind match graphics (strength of match). No decorative gradients.

## Type

- **Bricolage Grotesque** (SemiBold, Bold, ExtraBold; OFL licence, Google Fonts): display text, screen titles, names, score and rating numerals.
- **SF Pro** (system): everything else.
- Custom sizes use `Font.custom(_:size:relativeTo:)`, so they scale with Dynamic Type.

| Token | Font | Size | Text style |
|---|---|---|---|
| display | Bricolage ExtraBold | 36 | largeTitle |
| largeTitle | Bricolage Bold | 32 | largeTitle |
| title | Bricolage Bold | 26 | title |
| title2 | Bricolage SemiBold | 21 | title2 |
| headline / body / subheadline / footnote | SF Pro | system | same |
| score(n) | Bricolage ExtraBold, monospaced digits | n | headline |

Copy rules: sentence case, no all-caps labels, no "·" separators, and buttons start with a verb.

## Spacing, radius, elevation

- Space: 4, 8, 12, 16, 20, 24, 32. The page margin is 20.
- Radius grows with size: 14 for controls, 20 for cards and lists, 28 for hero panels and sheets. Buttons and chips are capsules.
- Shadow (`lift()`): only for things that float, such as the tab bar, the top match, hero panels and the sticky bar. Other separation uses colour (sunken against raised) or a hairline.

## Components

| Component | Use |
|---|---|
| `PrimaryButtonStyle` | ink capsule; the confirming action (one per screen) |
| `BrandButtonStyle` | apricot capsule with ink text; reserved for "find matches" |
| `SecondaryButtonStyle` | raised capsule with hairline; the alternative |
| `Chip` (`.neutral`, `.brand`, `.success`, `.danger`, `.selected`) | facts, reasons, statuses |
| `MatchReasonChip` | a reason; strong reasons use `.brand` |
| `ScoreRing`, `ScoredAvatar`, `ScoreFactorRow` | the score, the score around a person, one line of the breakdown |
| `MatchOrbit` | signature radar graphic |
| `AvatarView`, `AvatarStack` | people |
| `RatingBadge`, `StarRow`, `RatingSummary` | ratings: compact "★ 4.8 (18)"; exact-fill stars; profile summary with praise tags. No reviews shows "New", never 0 stars |
| `LabeledInput`, `ErrorBanner`, `InfoCard`, `SectionHeader`, `CircleIconButton` | forms and structure |
