## 0.3.0
- Added `User#displayName`
- Added `Restrr#logout`
- Added `Restrr#register`
- Further refactored error handling
  - Added `errorMap` to `ApiService#request` (and similar methods)
- Added more tests

## 0.2.1
- Removed `ErrorResponse`
- Replaced `RestResponse#error` with `RestrrError?`
- Added `Route#translateDioException`
- Added `IOUtils#checkConnection`

## 0.2.0
- Added `RestrrBuilder#login`
- More cleanup

## 0.1.1
- Added Dart Action

## 0.1.0
- Added `Restrr#checkUri`
- Added tests
- Further laid out concrete package structure

## 0.0.1
- Initial commit
- Implemented concrete structure
