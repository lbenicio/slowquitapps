# Contributing

Bug reports, documentation improvements, and code contributions are welcome.
For larger changes, open an issue first so the approach can be discussed before
you invest in implementation.

## Development setup

- macOS 12 or later
- Xcode with the macOS SDK

To build locally without a Developer ID signing certificate:

```sh
xcodebuild \
  -project SlowQuitApps.xcodeproj \
  -scheme SlowQuitApps \
  -configuration Debug \
  -destination 'generic/platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The release DMG script requires a Developer ID Application certificate. See
the build instructions in [README.md](README.md).

## Pull requests

- Keep each pull request focused and describe the user-visible effect.
- Include steps to reproduce a bug or verify a behavior change.
- Update documentation when behavior, permissions, compatibility, or setup changes.
- Do not include personal data, credentials, or unrelated generated files.
- Follow the existing Objective-C and shell style in the files you change.
- Be respectful and follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Licensing

By submitting a contribution, you agree that it may be distributed under the
project's GPL-2.0-or-later license. Preserve existing copyright and attribution
notices, and identify the source and license for any third-party assets you add.
