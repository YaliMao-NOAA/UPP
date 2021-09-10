set -x
cwd=`pwd`
cp ncep_post_gtg.fd/*90 ncep_post.fd/.

cd $HOMEgit/UPP.wafs
git submodule update --init CMakeModules
cd $HOMEgit/UPP.wafs/tests
./compile_upp.sh


cd $cwd/ncep_post_gtg_stub.fd
files=`ls`

cd $cwd
for filestub in $files ; do
    afile=`echo "${filestub%.*}"`
    cp ncep_post_gtg_stub.fd/$filestub ncep_post.fd/$afile
done
