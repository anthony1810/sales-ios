# BDD specs: a product's sales in US dollars

How a customer reads one product's sales, and what happens when the rates service is not running.
Each scenario is what one acceptance test proves. The map at the end names that test.

## Narrative 5, one product's sales in US dollars

```
As a signed in customer
I want to see one product's sales converted to US dollars
So that I can compare amounts that were taken in different currencies
```

### Scenarios

```
Given a product has two sales on different days
When the customer opens that product
Then the sales are shown newest first
And only that product's sales are shown
```

```
Given the rates service quotes the sale's currency
When the customer opens that product
Then every sale shows its amount converted to US dollars
```

```
Given every sale converts
When the customer opens that product
Then the header shows the total of every converted sale
```

## Narrative 6, the middleware is not running

```
As a customer whose rates service is down
I want to still see my sales
So that a missing conversion never costs me the data
```

### Scenarios

```
Given the rates service does not answer
When the customer opens a product
Then every sale is still shown in its own currency
And each conversion reads "USD unavailable"
```

```
Given the rates service does not answer
When the customer opens a product
Then the header shows no total
```

```
Given one sale is priced in a currency the rates service does not quote
When the customer opens that product
Then the header shows no total, rather than a total that leaves that sale out
```

```
Given the backend does not answer for sales
When the customer opens a product
Then nothing is shown
And the load error is shown
```

## Map to the tests

| Scenario | Test |
|---|---|
| Only this product's sales, newest first | `customerOpensAProduct_seesOnlyThatProductsSalesNewestFirst` |
| Every sale converted | `customerOpensAProduct_seesEverySaleConvertedToUSD` |
| The total of every converted sale | `customerOpensAProduct_seesTheTotalOfEveryConvertedSale` |
| No rates service, sales still shown | `customerOpensAProductWithNoRatesService_seesTheSalesWithoutAnyConversion` |
| No rates service, no total | `customerOpensAProductWithNoRatesService_seesNoTotal` |
| An unquoted currency means no total | `customerOpensAProductPricedInAnUnquotedCurrency_seesNoTotal` |
| A failed sales load shows the error | `customerOpensAProductAndTheSalesFail_seesTheLoadError` |

All seven live in
[AppTests/Acceptance/ProductDetailAcceptanceTests.swift](../../AppTests/Acceptance/ProductDetailAcceptanceTests.swift).
