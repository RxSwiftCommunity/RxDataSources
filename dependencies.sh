set -e
if [[ ( ! -d "RxSwift/.git" ) && ( ! -d "Carthage" ) && ( ! -d 'Pods' ) ]]; then
    git submodule update --init --recursive --force
    cd RxSwift
    git reset origin/master --hard
    osascript -e 'tell app "Xcode" to display dialog "We have downloaded dependencies. Please restart Xcode"'
fi
