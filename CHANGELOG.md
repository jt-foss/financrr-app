# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## Version 0.2.0 (12.03.2024)

### Added

- **[BREAKING]** Added pagination to `get_all` endpoints
- **[BREAKING]** moved to token-based session authentication
- **[BREAKING]** new session endpoints and session management
- new session limit (defaults to 25)
- session can now be named
- Added logging file with log rotation.
- added default headers to /api endpoints => `Content-Type: application/json` `Accept: application/json`
- added rate-limiting to /api endpoints
- added cors configuration

### Changed

- improved `Changelog.md`
- dependency updates
- improved logging

## Version 0.1.0 (26.02.2024)

- Initial release.
