# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2023-07-22

### Added

- `pushFmt` method to append a formatted string to `SmlStr`

## [0.1.0] - 2023-07-22

### Added

#### `SmlStr`

- `init` and `from` creation functions.
- `push` and `pushStr` appending methods.
- `slice` conversion method.
- Unbound versions of `from`, `push` and `pushStr`.

#### `SmlStrError`

- Overflow error.

[Unreleased]: https://github.com/sonro/smlstr/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/sonro/smlstr/releases/tag/v0.1.1
[0.1.0]: https://github.com/sonro/smlstr/releases/tag/v0.1.0
