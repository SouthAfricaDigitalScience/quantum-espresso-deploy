#!/bin/bash
. /etc/profile.d/modules.sh
module add ci
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/3.3.4-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}

echo "About to make the modules"
cd ${WORKSPACE}/${NAME}
ls
echo $?

make install

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

module-whatis   "$NAME $VERSION. See https://github.com/SouthAfricaDigitalScience/quantum-espresso-deploy"
setenv       QE_VERSION       $VERSION
setenv       QE_DIR           /data/ci-build/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$::env(GCC_VERSION)
prepend-path PATH              $::env(QE_DIR)/
prepend-path LD_LIBRARY_PATH   $::env(QE_DIR)/
prepend-path GCC_INCLUDE_DIR   $::env(QE_DIR)/
MODULE_FILE
) > modules/${VERSION}-gcc-${GCC_VERSION}
mkdir -p ${CHEMISTRY}/${NAME}
cp -v modules/${VERSION}-gcc-${GCC_VERSION} ${CHEMISTRY}/${NAME}

module avail ${NAME}
module list
module add ${NAME}/${VERSION}-gcc-${GCC_VERSION}
module list
which xspectra.x
