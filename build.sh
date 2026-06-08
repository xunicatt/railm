#!/bin/bash

UNAME=$(uname)

RAILM_API_URL="${RAILM_API_URL}"
RAILM_API_TOKEN="${RAILM_API_TOKEN}"
MAPBOX_API_TOKEN="${MAPBOX_API_TOKEN}"

RAILM_VERSION=$(cat railm/version)
RAILAPI_VERSION=$(cat railapi/version)

build-railm() {
    cd railm
    flutter build apk --release \
                      --dart-define=URL="${RAILM_API_URL}" \
                      --dart-define=TOKEN="${RAILM_API_TOKEN}" \
                      --dart-define=MAPBOX_TOKEN="${MAPBOX_API_TOKEN}"
    cd ..
    mv railm/build/app/outputs/apk/release/app-release.apk build/"railm-android-${RAILM_VERSION}.apk"

    if [[ "$UNAME" == "Darwin" ]]; then
        cd railm
        flutter build ipa --release --no-codesign \
                          --dart-define=URL="${RAILM_API_URL}" \
                          --dart-define=TOKEN="${RAILM_API_TOKEN}" \
                          --dart-define=MAPBOX_TOKEN="${MAPBOX_API_TOKEN}"
        cd ..
        cp -r railm/build/ios/archive/Runner.xcarchive/Products/Applications/Runner.app build/Payload
        zip -r build/app.zip build/Payload
        rm -r build/Payload
        mv build/app.zip build/"railm-ios-${RAILM_VERSION}.ipa"
    fi
}

build-railapi() {
    local OS=$1
    local ARCH=$2
    
    cd railapi
    GOOS=${OS} GOARCH=${ARCH} go build -o build/server cmd/server/main.go
    cd ..
    mv railapi/build/server build/"railapi-${OS}-${ARCH}-${RAILAPI_VERSION}"
}

main() {
    rm -rf build
    mkdir build

    local PLATFORMS=(
        "linux" "arm64"
        "linux" "amd64"
        "darwin" "arm64"
    )

    for ((i = 0; i < "${#PLATFORMS[@]}"; i+=2)); do
        build-railapi "${PLATFORMS[i]}" "${PLATFORMS[i+1]}"
    done

    build-railm
}

main "$@"
