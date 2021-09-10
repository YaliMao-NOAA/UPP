#!/bin/sh

#BSUB -cwd /gpfs/dell3/ptmp/Yali.Mao
#BSUB -oo /gpfs/dell3/ptmp/Yali.Mao/post_gtg.o%J
#BSUB -eo /gpfs/dell3/ptmp/Yali.Mao/post_gtg.o%J
#BSUB -J post_gtg.dell
#BSUB -W 00:30
#BSUB -q debug
#BSUB -P GFS-DEV
#BSUB -n 60
#BSUB -R span[ptile=12]
#BSUB -R affinity[core(2):distribute=balance]

export NODES=8
export ntasks=72
export ptile=12
export threads=1
# this script mimics operational GFS post processing production
export MP_LABELIO=yes
export OMP_NUM_THREADS=$threads
export APRUN=mpirun
export APRUN_DWN="mpirun cfp"
#export APRUN="aprun -j 1 -n${ntasks} -N${ptile} -d${threads} -cc depth"

############################################
# Loading module
############################################
module purge
. $MODULESHOME/init/sh
module use /usrx/local/nceplibs/dev/hpc-stack/libs/hpc-stack/modulefiles/stack
module load hpc/1.1.0
module load hpc-ips/18.0.1.163
module load hpc-impi/18.0.1
module load prod_util
module load lsf/10.1
module load grib_util
module load wgrib2
module list

module load prod_envir
module load CFP/2.0.1
export WGRIB2=wgrib2
export CRTM_FIX="/gpfs/dell1/nco/ops/nwprod/lib/crtm/v2.3.0/fix"

#module load g2tmpl/1.9.1
#module load crtm/2.3.0

module list

set -xa

####################################
# Specify NET and RUN Name and model
####################################
export RUN=gfs
export NET=gfs
export envir=prod

#export PDY=20171225
#export cyc=18
export PDY=20210909
export cyc=00
export cycle=t${cyc}z

############################################
# Define DATA COMOUT and COMIN
############################################
export COMIN=$COMROOT/${NET}/${envir}/${RUN}.${PDY}/${cyc}/atmos
#export COMIN=/gpfs/dell3/ptmp/Yali.Mao/gfsnetcdf/${RUN}.${PDY}/${cyc}

# specify your output and working directory
export user=`whoami`
export COMOUT=/gpfs/dell3/ptmp/${user}/gtg.fv3.${PDY}
mkdir -p $COMOUT
export DATA=/gpfs/dell3/ptmp/${user}/gtg.working.$PDY.$$
rm -rf $DATA; mkdir -p $DATA
cd $DATA

####################################
# SENDSMS  - Flag Events on SMS
# SENDCOM  - Copy Files From TMPDIR to $COMOUT
# SENDDBN  - Issue DBNet Client Calls
# RERUN    - Rerun posts from beginning (default no)
# VERBOSE  - Specify Verbose Output in global_postgp.sh
####################################
export SENDSMS=NO
export SENDCOM=YES
export SENDDBN=NO
export RERUN=NO
export VERBOSE=YES

##############################################
# Define source code directories
##############################################
export HOMEgfs=/gpfs/dell2/emc/modeling/noscrub/Yali.Mao/git/UPP.wafs

export PARMpost=${HOMEgfs}/parm
export POSTGPEXEC=$HOMEgfs/exec/upp.x
#
#export PostFlatFile=$HOMEgfs/parm/postxconfig-NT-GFS.txt
export POSTGRB2TBL=${HOMEgfs}/parm/params_grib2_tbl_new

export OUTPUT_FILE=netcdf

# For FIXCRTM satellite in scripts/exgfs_nceppost.sh.ecf
#export hwrf_ver=v11.0.5
#export g2tmpl_ver=v1.5.0

export PGBF=NO
export PGB1F=NO
export FLXF=NO
export GOESF=NO
export WAFSF=YES
export KEEPDATA=YES

####################################
# Specify Forecast Hour Range
####################################
allfhr=006

#############################################################

for post_times in $allfhr; do
    export post_times
    date
    $HOMEgfs/jobs/J_NCEPPOST #JGLOBAL_NCEPPOST
    echo $?
    date
done

#############################################################
