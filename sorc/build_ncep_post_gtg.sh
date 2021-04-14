set -x
cwd=`pwd`
cp ncep_post_gtg.fd/*90 ncep_post.fd/.

cd $HOMEgit/EMC_post_wafs/tests
git submodule update --init CMakeModules
./compile_upp.sh


cd $cwd/ncep_post_gtg.fd
files=`ls *90`

cd $cwd
for file in $files ; do
    cp ncep_post_gtg.fd/${file}.stub ncep_post.fd/$file
done
