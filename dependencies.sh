set -e
if [[ ( ! -d "RxSwift" ) && ( ! -d "Carthage" ) && ( ! -d 'Pods' ) ]]; then
    git submodule update --init --recursive --force
    cd RxSwift
    git reset origin/master --hard
fi
