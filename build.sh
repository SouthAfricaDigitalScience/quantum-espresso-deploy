#!/bin/bash -e
. /etc/profile.d/modules.sh
#SOURCE_FILE=$NAME-$VERSION.tar.gz
# We will build the code from the github repo, but if we want specific versions,
# a new Jenkins job will be created for the version number and we'll provide
# the URL to the tarball in the configuration.
SOURCE_REPO="https://github.com/QEF/q-e.git"
# We pretend that the $SOURCE_FILE is there, even though it's actually a dir.
SOURCE_FILE=${NAME}
module add ci
module add gcc/${GCC_VERSION}
module add openmpi/1.8.8-gcc-${GCC_VERSION}
module add fftw/3.3.4-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION}
module add lapack/3.6.0-gcc-${GCC_VERSION}


echo "REPO_DIR is ${REPO_DIR}"
echo "SRC_DIR is ${SRC_DIR}"
echo "WORKSPACE is ${WORKSPACE}"
echo "SOFT_DIR is ${SOFT_DIR}"

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file
# since it's from SCM, should be done in ${WORKSPACE} instead of ${SRC_DIR}, but whatever
if [ ! -e ${WORKSPACE}/${SOURCE_FILE}.lock ] && [ ! -s ${WORKSPACE}/${SOURCE_FILE} ] ; then
# First download
  touch  ${WORKSPACE}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - doing a git clone  https://github.com/SouthAfricaDigitalScience/q-e.git to ${WORKSPACE}/${SOURCE_FILE}"
  git clone https://github.com/SouthAfricaDigitalScience/q-e.git ${WORKSPACE}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${WORKSPACE}/${SOURCE_FILE}.lock
elif [ -e ${WORKSPACE}/${SOURCE_FILE}.lock ] ; then
# Someone else has the file, wait till it's released
  while [ -e ${WORKSPACE}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${WORKSPACE}/${SOURCE_FILE}
fi
cd ${WORKSPACE}/${NAME}
echo "cleaning up previous builds"
make distclean
echo "Configuring the build for no parallel"
export FC=`which gfortran`
export MPIF90=`which mpif90`
export FCFLAGS="$CFLAGS -I${FFTW_DIR}/include -I${OPENBLAS_DIR}/include -I${LAPACK_DIR}/include"
export LAPACK_LIBS="-L${LAPACK_DIR}/lib -L${LAPACK_DIR}/lib64 -L${OPENBLAS_DIR}/lib -llapack -lblas"
# QE doesn't like to be compiled out of source
export LDFLAGS="-L${LAPACK_DIR}/lib -L${LAPACK_DIR}/lib64"
./configure \
--prefix=${SOFT_DIR}-gcc-${GCC_VERSION}-mpi-${OPENMPI_VERSION} \
--enable-parallel \
--enable-shared \
--enable-environment \
--enable-signals

echo "Running the build"
make all
