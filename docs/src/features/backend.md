# Backend

Features that are specific to the backend.

- [ ] API
- [X] compression (brotli, zstd, gzip => in this order!)
- [X] handling of trailing slashes for the API

## Easy Deployment

- [ ] provide docker image
- [ ] provide good installation instructions
- [ ] reduce external dependencies
    - [X] we only need our databases PostgreSQL & redis
    - [ ] integrated rate limiter -> no need for an external one
