# Increment Version & prepare Workspace

flutter pub run pub_increment --type patch &&
git commit -a -m "publish: Patch" &&
git push &&

# Build

bash buildAndUpload.sh
