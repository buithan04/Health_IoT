# HealthAI Server Tests

## Test Structure

### Unit Tests
- `api.test.js` - API endpoint tests
- `socket.test.js` - Socket.IO functionality tests
- `chat_service.test.js` - Chat service logic tests

### Running Tests

```bash
# Install test dependencies
npm install --save-dev jest supertest

# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run only unit tests
npm run test:unit

# Run with coverage report
npm test -- --coverage
```

## Test Coverage

Tests cover:
- ✅ API authentication and authorization
- ✅ Socket.IO connections and events
- ✅ Chat message handling
- ✅ Video call signaling
- ✅ User status tracking
- ✅ Error handling
- ✅ CORS configuration

## Expected Results

All tests should pass with:
- API endpoints responding correctly
- Socket events working properly
- Chat functionality operational
- Video call signaling functional
- Error cases handled gracefully

## CI/CD Integration

These tests can be integrated into your CI/CD pipeline:
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-node@v2
        with:
          node-version: '18'
      - run: npm install
      - run: npm test
```
