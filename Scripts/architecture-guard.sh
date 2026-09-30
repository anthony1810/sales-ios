#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

failures=0

report() {
    echo "architecture-guard: $1"
    failures=$((failures + 1))
}

sources() {
    find "$@" -name "*.swift" -not -path "*/.build/*" 2>/dev/null
}

# 1. SwiftUI and UIKit belong to the UI targets and the app, nowhere else.
for file in $(sources Modules -path "*/Sources/*"); do
    case "$file" in
        */Sources/*UI/*) continue ;;
        */Sources/*TestSupport/*) continue ;;
    esac
    if grep -qE "^import (SwiftUI|UIKit)$" "$file"; then
        report "$file imports SwiftUI or UIKit outside a UI target"
    fi
done

# 2. The three verticals never import each other.
for vertical in Login ProductList ProductDetail; do
    others=$(echo "Login ProductList ProductDetail" | tr ' ' '\n' | grep -v "^$vertical$")
    for file in $(sources "Modules/$vertical/Sources"); do
        for other in $others; do
            if grep -qE "^import $other(Feature|API|Presentation|UI|TestSupport)$" "$file"; then
                report "$file imports the $other vertical"
            fi
        done
    done
done

# 3. HTTPClient is for the composition root and Auth's decorator, never a vertical.
for file in $(sources Modules/Login/Sources Modules/ProductList/Sources Modules/ProductDetail/Sources); do
    if grep -qE "^import HTTPClient(Live)?$" "$file"; then
        report "$file imports HTTPClient inside a vertical"
    fi
done

# 4. The backend host is named once, in ServiceURLs.
service_urls="App/Composition/ServiceURLs.swift"
host=$(grep -oE 'https://[A-Za-z0-9.-]+' "$service_urls" | head -1 | sed 's|https://||')
if [ -n "$host" ]; then
    for file in $(grep -rl "$host" --include="*.swift" App Modules 2>/dev/null | grep -v "/.build/" || true); do
        [ "$file" = "$service_urls" ] && continue
        report "$file names the backend host, which belongs only in ServiceURLs"
    done
fi

# 5. A TestSupport module is linked by test bundles only.
for file in $(sources Modules -path "*/Sources/*"); do
    case "$file" in
        */Sources/*TestSupport/*) continue ;;
    esac
    if grep -qE "^import (TestSupport|[A-Za-z]+TestSupport)$" "$file"; then
        report "$file links a TestSupport module from production code"
    fi
done

# 6. Auth is a Login and composition concern, not a product one.
for file in $(sources Modules/ProductList/Sources Modules/ProductDetail/Sources); do
    if grep -qE "^import Auth$" "$file"; then
        report "$file imports Auth inside a product vertical"
    fi
done

if [ "$failures" -gt 0 ]; then
    echo "architecture-guard: $failures violation(s)"
    exit 1
fi

echo "architecture-guard: all rules hold"
