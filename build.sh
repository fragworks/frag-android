cwd="$PWD"
docker build -t android .
docker run -it -v "$cwd/app/src/main/jniLibs:/app/src/main/jniLibs" android
#cp -r assets bin/assets
#zip bin/space-shooter.zip bin/win64/** bin/assets/**