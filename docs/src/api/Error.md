# API Error

We provide a custom error object that is utilized throughout the library.

## Error and HTTP Codes

We employ semantic HTTP codes to signify the type of error that occurred, enabling more precise error handling.
<br>
If HTTP codes lack granularity, we offer a custom error code for more specific error handling scenarios. By default,
HTTP codes are used.

## Custom Error Codes

Custom error codes come into play when HTTP codes lack granularity. For instance, if you need to handle a particular
error in a specific manner, custom error codes allow for such tailored handling.
<br>
Custom error codes always consist of at least four digits to prevent conflicts with HTTP codes.
<br>
We call these custom error codes `Api Codes`.

### Api Codes

| Code | Description     |
|------|-----------------|
| 1000 | Invalid API Key |
