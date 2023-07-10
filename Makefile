PLATFORM_IOS = iOS Simulator,name=iPhone 14 Pro
SCHEME = JoyStickView App
DOCC_DIR = ./docs
QUIET = -quiet
WORKSPACE = $(PWD)/JoyStickView.xcworkspace
SPM_WORKSPACE = $(PWD)/.workspace

default: percentage

clean:
	rm -rf "$(PWD)/.DerivedData-macos" "$(PWD)/.DerivedData-ios" "$(PWD)/.DerivedData-tvos" "$(SPM_WORKSPACE)"

docc:
	xcodebuild docbuild \
		-workspace "$(WORKSPACE)" \
		$(QUIET) \
		-scheme "JoyStickView" \
		-destination platform="$(PLATFORM_IOS)" \
		-derivedDataPath "$(PWD)/.DerivedData-ios"
	DOCC_JSON_PRETTYPRINT="YES" \
	xcrun docc process-archive transform-for-static-hosting `find $(PWD)/.DerivedData-ios -type d -name *.doccarchive` \
		--hosting-base-path JoystickView \
		--output-path docs

lint: clean
	@if command -v swiftlint; then swiftlint; fi

resolve-deps: lint
	xcodebuild \
		-workspace "$(WORKSPACE)" \
		$(QUIET) \
		-resolvePackageDependencies \
		-clonedSourcePackagesDirPath "$(SPM_WORKSPACE)" \
		-scheme "$(SCHEME)"

test-ios: resolve-deps
	xcodebuild test \
		-workspace "$(WORKSPACE)" \
		$(QUIET) \
		-clonedSourcePackagesDirPath "$(SPM_WORKSPACE)" \
		-scheme "$(SCHEME)" \
		-derivedDataPath "$(PWD)/.DerivedData-ios" \
		-destination platform="$(PLATFORM_IOS)"

coverage: test-ios
	xcrun xccov view --report --only-targets $(PWD)/.DerivedData-ios/Logs/Test/*.xcresult > coverage.txt
	cat coverage.txt

percentage: coverage
	awk '/ JoyStickView.framework / { if ($$3 > 0) print $$4; }' coverage.txt > percentage.txt
	cat percentage.txt

test: test-ios test-tvos percentage

.PHONY: test test-ios test-macos test-tvos coverage percentage test-linux test-swift
