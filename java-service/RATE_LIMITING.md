# API Rate Limiting

## Overview

The SSN Validation Service implements API rate limiting to protect against abuse and ensure fair resource allocation across clients.

## Configuration

Rate limiting is configured in `application.properties`:

```properties
rate.limit.requests-per-minute=100
```

**Default**: 100 requests per minute per IP address

## How It Works

### Token Bucket Algorithm

The service uses the **Bucket4j** library which implements a token bucket algorithm:

- Each IP address gets its own bucket with 100 tokens
- Each request consumes 1 token
- Tokens refill at a rate of 100 tokens per minute
- When the bucket is empty, requests are rejected with HTTP 429

### IP Detection

The filter detects client IPs using:
1. `X-Forwarded-For` header (for requests behind proxies/load balancers)
2. `RemoteAddr` (fallback when X-Forwarded-For is not present)

## Response Headers

All API responses include rate limit information:

| Header | Description | Example |
|--------|-------------|---------|
| `X-RateLimit-Limit` | Maximum requests allowed per minute | `100` |
| `X-RateLimit-Remaining` | Number of requests remaining in current window | `87` |
| `X-RateLimit-Reset` | Unix timestamp when the rate limit resets | `1703350920` |

## HTTP 429 Response

When rate limit is exceeded, the API returns:

**Status Code**: `429 Too Many Requests`

**Response Body**:
```json
{
  "error": "Too many requests",
  "message": "Rate limit exceeded. Please try again in 45 seconds."
}
```

**Headers**:
- `X-RateLimit-Limit: 100`
- `X-RateLimit-Remaining: 0`
- `X-RateLimit-Reset: 1703350920`

## Examples

### Successful Request (Under Limit)

```bash
curl -i http://localhost:8080/api/v1/ssn/validate \
  -H "Content-Type: application/json" \
  -d '{"ssn": "123-45-6789"}'

HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
Content-Type: application/json

{"valid": true, "ssn": "123-45-6789"}
```

### Rate Limit Exceeded

```bash
# After 100 requests in same minute
curl -i http://localhost:8080/api/v1/ssn/validate \
  -H "Content-Type: application/json" \
  -d '{"ssn": "123-45-6789"}'

HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1703350920
Content-Type: application/json

{
  "error": "Too many requests",
  "message": "Rate limit exceeded. Please try again in 45 seconds."
}
```

## Client Implementation

### Handling Rate Limits

Clients should:

1. **Check Response Headers**: Monitor `X-RateLimit-Remaining` to track quota
2. **Handle 429 Responses**: Implement exponential backoff or use `X-RateLimit-Reset` to retry
3. **Implement Retry Logic**: Wait for the time specified in the error message

### Example Client Code (JavaScript)

```javascript
async function validateSSN(ssn) {
  try {
    const response = await fetch('http://localhost:8080/api/v1/ssn/validate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ssn })
    });

    // Check rate limit headers
    const remaining = response.headers.get('X-RateLimit-Remaining');
    console.log(`Requests remaining: ${remaining}`);

    if (response.status === 429) {
      const data = await response.json();
      console.error(`Rate limit exceeded: ${data.message}`);
      
      const resetTime = response.headers.get('X-RateLimit-Reset');
      const waitSeconds = resetTime - Math.floor(Date.now() / 1000);
      
      // Wait and retry
      await new Promise(resolve => setTimeout(resolve, waitSeconds * 1000));
      return validateSSN(ssn);
    }

    return await response.json();
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}
```

## Testing

The rate limiting functionality is thoroughly tested in `RateLimitFilterTest.java`:

- ✅ Requests under limit are allowed
- ✅ Rate limit headers are included in responses
- ✅ 429 status is returned when limit exceeded
- ✅ Different IPs have separate rate limits
- ✅ X-Forwarded-For header is respected

Run tests:
```bash
mvn test -Dtest=RateLimitFilterTest
```

## Performance Considerations

- **Memory Usage**: Each unique IP address creates a bucket in memory (ConcurrentHashMap)
- **Scalability**: For distributed systems, consider Redis-backed buckets using `bucket4j-redis`
- **Cleanup**: Buckets are held in memory indefinitely; implement periodic cleanup for production

## Security

Rate limiting protects against:
- 🛡️ **Brute Force Attacks**: Limits password/SSN guessing attempts
- 🛡️ **DoS Attacks**: Prevents service exhaustion
- 🛡️ **Resource Abuse**: Ensures fair usage across clients

## Future Enhancements

Potential improvements:
- Different limits for different endpoints
- Whitelist trusted IPs (no rate limiting)
- Redis-backed storage for distributed systems
- Dynamic rate limits based on user tier/plan
- Rate limiting by API key instead of IP

