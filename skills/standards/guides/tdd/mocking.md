# When to mock

Mock only at the edges of your system:

- third-party APIs (payments, email);
- time and randomness;
- the database or file system, only when you can't run a real one.

Never mock your own modules. If you control it, run it.

## Make the edges easy to mock

**Pass dependencies in** instead of creating them inside:

```typescript
// Easy to test: the caller supplies the client
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to test: the client is built inside
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**Give each external call its own function** instead of one generic fetcher:

```typescript
// Good: each call can be mocked with one fixed response
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch("/orders", { method: "POST", body: data }),
};

// Bad: the mock has to branch on the URL to know what to return
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

With one function per call, each mock returns one shape, the test shows which
calls it uses, and each call keeps its own types.
