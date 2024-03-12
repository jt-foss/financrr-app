# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] 12-03-2024

### Changed

- improved `Changelog.md`

## [0.2.0] 12-03-2024

- dependency updates
- improved logging
- Added logging file with log rotation.
- added default headers to /api endpoints => `Content-Type: application/json` `Accept: application/json`
- added rate-limiting to /api endpoints
- added cors configuration
- Added pagination to `get_all` endpoints
- moved to token-based session authentication
- new session limit (defaults to 25)
- new session endpoints and session management
- session can now be named

## [0.1.0] 26-02-2024

- Initial release.
