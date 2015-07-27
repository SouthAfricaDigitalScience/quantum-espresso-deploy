module load ci
echo "About to make the modules"
cd $WORKSPACE/$NAME
ls
echo $?

make install # DESTDIR=$SOFT_DIR

#mkdir -p $REPO_DIR
#rm -rf $REPO_DIR/*
#tar -cvzf $REPO_DIR/build.tar.gz -C $WORKSPACE/build apprepo
#
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
   puts stderr "       This module does nothing but alert the user"
   puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION."
setenv       QE_VERSION       $VERSION
setenv       QE_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path PATH              $::env(QE_DIR)/
prepend-path LD_LIBRARY_PATH   $::env(QE_DIR)/
prepend-path GCC_INCLUDE_DIR   $::env(QE_DIR)/
MODULE_FILE
) > modules/$VERSION
mkdir -p $LIBRARIES_MODULES/$NAME
cp modules/$VERSION $LIBRARIES_MODULES/$NAME

module avail
module list
module add $NAME
which xspectra.x

cd $WORKSPACE/$NAME/atomic/examples/all-electron
./test-job
ls out
