# Increment Version & prepare Workspace

flutter pub run pub_increment --type minor &&
git commit -a -m "publish: Minor" &&
git push &&

# Build

bash buildAndUpload.sh
