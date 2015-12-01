#!/bin/bash -e
. /etc/profile.d/modules.sh
#SOURCE_FILE=$NAME-$VERSION.tar.gz
# We will build the code from the github repo, but if we want specific versions,
# a new Jenkins job will be created for the version number and we'll provide
# the URL to the tarball in the configuration.
SOURCE_REPO="https://github.com/QEF/q-e.git"
# We pretend that the $SOURCE_FILE is there, even though it's actually a dir.
SOURCE_FILE=${NAME}
module load ci
#module load gcc/4.8.2
#module add fftw

echo "REPO_DIR is ${REPO_DIR}"
echo "SRC_DIR is ${SRC_DIR}"
echo "WORKSPACE is ${WORKSPACE}"
echo "SOFT_DIR is ${SOFT_DIR}"

mkdir -p ${WORKSPACE}
mkdir -p ${SRC_DIR}
mkdir -p ${SOFT_DIR}

#  Download the source file
# since it's from SCM, should be done in ${WORKSPACE} instead of ${SRC_DIR}, but whatever
if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
  touch  ${SRC_DIR}/${SOURCE_FILE}.lock
  echo "seems like this is the first build - doing a git clone  https://github.com/SouthAfricaDigitalScience/q-e.git ${SRC_DIR}/${SOURCE_FILE}"
  mkdir -p ${SRC_DIR}
  git clone https://github.com/SouthAfricaDigitalScience/q-e.git ${SRC_DIR}/${SOURCE_FILE}
  echo "releasing lock"
  rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
  # Someone else has the file, wait till it's released
  while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
    echo " There seems to be a download currently under way, will check again in 5 sec"
    sleep 5
  done
else
  echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
  cd ${SRC_DIR}/${SOURCE_FILE}
  echo "Doing a git pull..."
  git pull
fi
# this is the equivalent of a git pull :
# tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
cp -rf ${SRC_DIR}/${SOURCE_FILE} ${WORKSPACE} --no-clobber
cd ${WORKSPACE}/${NAME}
echo "cleaning up previous builds"
make distclean
echo "Configuring the build for no parallel"
FC=`which gfortran` MPIF90=`which mpif90` ./configure \
--prefix=${SOFT_DIR} \
--enable-parallel=no \
--enable-shared \
--enable-environment \
--with-internal-blas \
--with-internal-lapack
echo "Running the build"
make -j2 all
