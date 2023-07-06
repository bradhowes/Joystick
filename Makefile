PLATFORM_IOS = iOS Simulator,name=iPad mini (6th generation)
PLATFORM_MACOS = macOS

DEST = -scheme "JoyStickView App" -destination platform="$(PLATFORM_IOS)"

default: post

clean:
	@echo "-- removing cov.txt percentage.txt"
	@-rm -rf cov.txt percentage.txt WD WD.xcresult build.run test.run
	@xcodebuild -workspace JoyStickView.xcworkspace clean $(DEST)

test: clean
	rm -rf WD.xcresult WD
	swift package resolve
	xcodebuild -workspace JoyStickView.xcworkspace test $(DEST) -enableCodeCoverage YES ENABLE_TESTING_SEARCH_PATHS=YES -resultBundlePath $PWD

# Extract coverage info for SF2Lib -- expects defintion of env variable GITHUB_ENV

cov.txt: test
	xcrun xccov view --report --only-targets WD.xcresult > cov.txt

coverage: cov.txt
	@cat cov.txt

percentage.txt: cov.txt
	awk '/ JoyStickView.framework / {print $$4;}' < cov.txt > percentage.txt
	@cat percentage.txt

percentage: percentage.txt
	@cat percentage.txt

post: percentage
	@if [[ -n "$$GITHUB_ENV" ]]; then \
		echo "PERCENTAGE=$$(< percentage.txt)" >> $$GITHUB_ENV; \
	fi

.PHONY: coverage clean build test post percentage coverage
