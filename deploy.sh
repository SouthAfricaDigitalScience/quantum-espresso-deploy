#!/bin/bash
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add  gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/3.3.4-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}
echo "All tests have passed, will now build into ${SOFT_DIR}"
export FC=`which gfortran`
export MPIF90=`which mpif90`
./configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-parallel \
--enable-shared \
--enable-environment \
--enable-signals

make -j2 install
echo "Creating the modules file directory "
mkdir -p ${CHEMISTRY_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/gmp-deploy"
setenv       QE_VERSION       $VERSION
setenv       QE_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(QE_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(QE_DIR)/include
prepend-path PATH             $::env(QE_DIR)
MODULE_FILE
) > ${CHEMISTRY_MODULES}/${NAME}/${VERSION}-gcc-${GCC_VERSION}
