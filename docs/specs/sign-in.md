# BDD specs: signing in

How a customer signs in, returns to the app, and is signed out again. Each scenario is what one
acceptance test proves. The map at the end names that test.

## Narrative 1, signing in

```
As a customer
I want to sign in with my username and password
So that I can see the products I am allowed to see
```

### Scenarios

```
Given the customer has valid credentials
When the customer submits them
Then the app shows the product list
And no error is shown
```

```
Given the customer has valid credentials
When the customer submits them
Then the token is kept for the next launch
```

```
Given the backend rejects the credentials with a message
When the customer submits them
Then the app stays on the login screen
And the server's own message is shown
```

```
Given the app cannot reach the backend
When the customer submits any credentials
Then the app stays on the login screen
And one generic error is shown, never a technical one
```

## Narrative 2, returning to the app

```
As a customer who signed in before
I want the app to remember me
So that I do not type my password every time
```

### Scenarios

```
Given a token was stored on an earlier launch
When the app starts
Then the app opens the product list without asking to sign in
```

```
Given no token was stored
When the app starts
Then the app opens the login screen
```

```
Given the token store cannot be read
When the app starts
Then the app opens the login screen
```

## Narrative 3, the session expiring

```
As a customer whose token is no longer accepted
I want to be told and sent back to sign in
So that I am never left looking at a screen that cannot load
```

### Scenarios

```
Given the customer is signed in
When the backend rejects a request with 401
Then the app returns to the login screen
And the expiry notice is shown
```

```
Given the customer is signed in
When the backend rejects a request with 401
Then the stored token is cleared
```

## Map to the tests

| Scenario | Test |
|---|---|
| Valid credentials reach the product list | `customerSignsIn_reachesTheProductList` |
| The token survives for the next launch | `customerSignsIn_keepsTheTokenForTheNextLaunch` |
| A rejected password shows the server's message | `customerSignsInWithRejectedCredentials_staysAtLoginWithTheServersMessage` |
| Offline shows one generic error | `customerSignsInWhileOffline_staysAtLoginWithTheGenericError` |
| A stored session skips the login screen | `customerReturnsAfterSigningInEarlier_reachesTheProductListWithoutSigningIn` |
| No stored session stays at login | `customerReturnsWithNoStoredSession_staysAtLogin` |
| An unreadable store stays at login | `customerReturnsWithAnUnreadableStore_staysAtLogin` |
| A 401 returns to login with the notice | `signedInCustomerIsRejected_returnsToLoginWithTheExpiryNotice` |
| A 401 clears the stored token | `signedInCustomerIsRejected_clearsTheStoredToken` |

All nine live in
[AppTests/Acceptance/SignInAcceptanceTests.swift](../../AppTests/Acceptance/SignInAcceptanceTests.swift).
