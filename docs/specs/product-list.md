# BDD specs: the product list

How a customer reads the list of products and their sales counts. Each scenario is what one
acceptance test proves. The map at the end names that test.

## Narrative 4, browsing the products

```
As a signed in customer
I want to see every product with how many times it sold
So that I can tell at a glance what is selling
```

### Scenarios

```
Given the backend has products and sales
When the customer opens the product list
Then every product is shown with its sales count
And a product that never sold still appears, with a count of zero
```

```
Given the backend returns products out of order
When the customer opens the product list
Then they are shown in human name order, so "Item 9" comes before "Item 10"
```

```
Given the backend returns a sale whose product is not in the catalogue
When the customer opens the product list
Then that sale is ignored
And no phantom row appears
```

```
Given the app cannot reach the backend
When the customer opens the product list
Then no rows are shown
And the load error is shown
```

```
Given the first load failed
When the customer tries again and the backend answers
Then the products are shown
And the error is cleared
```

## Map to the tests

| Scenario | Test |
|---|---|
| Every product with its sales count | `customerOpensTheProductList_seesEveryProductWithItsSalesCount` |
| Human name order | `customerOpensTheProductList_seesProductsInHumanNameOrder` |
| A sale with no matching product is ignored | `customerOpensTheProductList_seesNothingForASaleWithNoMatchingProduct` |
| Offline shows the load error | `customerOpensTheProductListOffline_seesTheLoadError` |
| Retrying after a failure shows the products | `customerRetriesAfterAFailure_seesTheProducts` |

All five live in
[AppTests/Acceptance/ProductListAcceptanceTests.swift](../../AppTests/Acceptance/ProductListAcceptanceTests.swift).
