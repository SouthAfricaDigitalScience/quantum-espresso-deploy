#!/bin/bash -e
#SOURCE_FILE=$NAME-$VERSION.tar.gz
# We will build the code from the github repo, but if we want specific versions,
# a new Jenkins job will be created for the version number and we'll provide
# the URL to the tarball in the configuration.
SOURCE_REPO="https://github.com/QEF/q-e.git"
# We pretend that the $SOURCE_FILE is there, even though it's actually a dir.
SOURCE_FILE=$NAME
module load ci
#module load gcc/4.8.2
module add fftw3

echo "REPO_DIR is "
echo $REPO_DIR
echo "SRC_DIR is "
echo $SRC_DIR
echo "WORKSPACE is "
echo $WORKSPACE
echo "SOFT_DIR is"
echo $SOFT_DIR

mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR

#  Download the source file

if [[ ! -e $SRC_DIR/$SOURCE_FILE ]] ; then
  echo "seems like this is the first build - doing a git clone  https://github.com/QEF/q-e.git $SRC_DIR/$SOURCE_FILE"
  mkdir -p $SRC_DIR
  git clone https://github.com/QEF/q-e.git $SRC_DIR/$SOURCE_FILE
else
  echo "continuing from previous builds, using source at " $SRC_DIR/$SOURCE_FILE
  cd $SRC_DIR/$SOURCE_FILE
  echo "Doing a git pull..."
  git pull
fi
# this is the equivalent of a git pull :
# tar -xvzf $SRC_DIR/$SOURCE_FILE -C $WORKSPACE
cp -rf $SRC_DIR/$SOURCE_FILE $WORKSPACE
cd $WORKSPACE/$NAME
echo "cleaning up previous builds"
make distclean
echo "Configuring the build"
FC=`which gfortran` MPIF90="/usr/lib64/openmpi/bin/mpif90" ./configure --prefix=${SOFT_DIR} --enable-parallel --enable-shared --enable-environment
echo "Running the build"
make all
