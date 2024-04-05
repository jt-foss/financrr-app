# Increment Version & prepare Workspace

flutter pub run pub_increment --type major &&
git commit -a -m "publish: Major" &&
git push &&

# Build

bash buildAndUpload.sh
