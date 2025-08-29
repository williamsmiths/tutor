# Readsubmodule
```bash
# add submodule
git submodule add -b main <URL_REPO> <THƯ_MỤC>

# clone with submodules
git clone --recurse-submodules <URL_REPO>
git submodule update --init --recursive

# update submodule
cd libs/lib
git pull origin main
cd ../..
git add libs/lib
git commit -m "Update submodule lib"
git submodule update --remote --merge

# edit submodule
cd libs/lib
git add .
git commit -m "Fix bug in lib"
git push origin main
cd ../..
git add libs/lib
git commit -m "Update submodule lib to latest commit"
git push origin main

# remove submodule
git submodule deinit -f -- <THƯ_MỤC>
rm -rf .git/modules/<THƯ_MỤC>
git rm -f <THƯ_MỤC>

# check & sync
git submodule status
git submodule sync
```
