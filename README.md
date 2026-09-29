# Sales in USD, iOS app

Log in, see every product with how many times it sold, open one and read its sales newest first
with each amount converted to US dollars.

The app never converts currencies itself. It asks a companion service, `sales-middleware`, for one
direct-to-USD rate per currency. That repository has its own README.

## Running it

```bash
open sales-ios.xcworkspace          # scheme: SalesInUSD
```

Log in with the tester account from the challenge brief.

The product list and the product detail work against the real backend with no further setup. The
US dollar conversions need the middleware running:

```bash
cd ../sales-middleware/Server && swift run ServerMain     # serves http://localhost:8080
```

Without it the detail screen still lists every sale with its own currency and date, and says
"USD unavailable" instead of a converted figure. That is deliberate, not a failure state.

On a **physical device** `localhost` is the phone, not your Mac. Set an environment variable in
the scheme (Product > Scheme > Edit Scheme > Run > Arguments):

```
RATES_BASE_URL = http://<your-mac-ip>:8080
```

## Tests

```bash
xcodebuild test -workspace sales-ios.xcworkspace -scheme SalesInUSD \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

That runs the app suite. Each package also tests on its own, for example
`swift test --package-path Modules/ProductList`.

Four **end-to-end** tests call the real services and are skipped unless you ask for them:

```bash
TEST_RUNNER_END_TO_END=1 TEST_RUNNER_RATES_BASE_URL=http://localhost:8080 \
  xcodebuild test -workspace sales-ios.xcworkspace -scheme SalesInUSD \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:SalesInUSDTests/RealServicesEndToEndTests
```

They are opt-in because a test that needs the network, a live account and a locally started server
should never be the reason a normal run goes red.

A **UI test** drives the real app the same way, under the same flag: it signs in, waits for the
product list and opens a product. Add `-only-testing:SalesInUSDUITests` to run just that one. It
found a bug the snapshots could not: a product row put `Text`, `Spacer`, `Text` in an `HStack`, so
the middle of the row was empty space and did not respond to a tap. Only the text was tappable.
`.contentShape(Rectangle())` fixed it.

## How it is put together

```
App/Composition/        the only place concrete types meet
Modules/Login/          LoginFeature, LoginAPI, LoginPresentation, LoginUI
Modules/ProductList/    same four layers
Modules/ProductDetail/  same four layers
Modules/Shared/         Auth, HTTPClient, SharedPresentation, TestSupport
```

Three screen verticals, each sliced into the same four layers, plus shared horizontals that hold
only technical things. Inside a vertical the arrows point one way: UI depends on Presentation,
Presentation on Feature, and the API target implements the seam the Feature declares. A test
enforces that no presentation target imports SwiftUI.

**Each vertical owns its own domain.** There is no shared model package. In the list a `Sale` is
just a product id, because the list counts sales. In the detail a `Sale` carries `Money` and a
`Date`, because the detail shows them. `Composition/Product+ProductDetail.swift` translates one
vertical's `Product` into the other's, and it is the only file that imports both.

**Business rules live in policy types**, never on the models. `ProductSummaryPolicy` counts sales
per product and sorts by name. `ProductDetailPolicy` filters, orders newest first, converts and
totals. Both are pure: same inputs, same output, no clock and no network, so their tests run in
about a millisecond.

**Coordination lives in the composition layer.** `ProductListService` and `ProductDetailService`
fetch from two sources at once and hand the results to a policy. They hold no business rule:
delete either one and nothing about the business is lost.

## Decisions worth explaining

**Money is never a `Double`.** Written as a Swift literal, `1.18` becomes
`1.1799999999999997952`. Amounts and rates cross every boundary as exact `Decimal`. The middleware
sends rates as JSON strings for the same reason, so nothing has to pass through binary floating
point. Rounding happens once, in the formatter, for display only.

**A 401 is final, so the app does not retry it.** The authorizing decorator raises one event, the
composition root clears the Keychain token, returns to Login and shows "Your session expired".
Features never learn this happened. Transport failures are different: they show an error and the
data stays on screen.

**A failed refresh keeps the data.** If a reload fails while content is already showing, the
message appears above the content rather than replacing it. Losing what someone is reading is
worse than showing it next to an error.

**No pagination.** Neither `/products` nor `/sales` accepts a page or a cursor. More decisive: the
list shows a sales count per product, which is only correct once every sale has been seen, so
paging the sales request would show counts that creep upward and are wrong until the last page.

**Dates follow the reader's language; English matches the brief exactly.** `SaleDateFormatter`
reads its pattern from the `.lproj` of the injected locale, so English reads
`Jan 2, 2030 at 11 am` exactly as the brief writes it, and Vietnamese reads
`2 thg 1, 2030 lúc 11 SA`.

**US dollars are written two ways on purpose.** The brief shows `US$407` in a row but `$107,587`
in the header. No single locale produces both, so the row passes an explicit symbol while the
header uses the currency's own. The row needs it: `$437` sitting beside `R$2,299` is ambiguous.

**The Keychain store has a single writer.** `KeychainTokenStore` is a `Sendable` final class whose
only mutable state is in the Keychain itself. The composition root is the one writer. If a second
writer ever appears, it should become an actor.

**The project file is generated.** `project.yml` is the source of truth and XcodeGen produces
`SalesInUSD.xcodeproj`, which is committed so you need no extra tool to open and build.

## What is tested

Around 140 tests. Unit tests for every policy, mapper, endpoint and view model. Snapshot tests for
all four screens in light and dark, including the states that are easy to forget: a failed refresh
with content still on screen, and the detail when US dollars are unavailable. Four end-to-end tests
against the real services. Two CI workflows run every package and the app suite, the latter with
Thread Sanitizer enabled.
