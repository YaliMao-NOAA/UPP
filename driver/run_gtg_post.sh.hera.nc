#!/bin/sh

#SBATCH -o /scratch2/NCEPDEV/stmp3/Yali.Mao/run_gfs_post.oe%j
#SBATCH -e /scratch2/NCEPDEV/stmp3/Yali.Mao/run_gfs_post.oe%j
#SBATCH -J gfs_post
#SBATCH -t 00:30:00
#SBATCH -N 8 --ntasks-per-node=12
#SBATCH -q batch
#SBATCH -A ovp
##SBATCH -V

set -x

# specify computation resource
export threads=1
export MP_LABELIO=yes
export OMP_NUM_THREADS=$threads
#export APRUN="mpirun -np $PBS_NP"
export APRUN="srun"
#comment machine for using MPMD to generate pgrb files on Hera
export APRUN_DWN="staskfarm"
#export machine=THEIA


############################################
# Loading module
############################################
module purge
. $MODULESHOME/init/sh
module load intel/18.0.5.274
#module load impi/2019.0.4
module load impi/2018.0.4
module use /scratch2/NCEPDEV/nwprod/NCEPLIBS/modulefiles
module load grib_util/1.1.1
module load prod_util/1.1.0
module load crtm/2.2.5
module load slurm/default
module load g2tmpl/1.6.0
module load wrfio/1.1.1
#module load netcdf/4.7.0
module load hdf5_parallel/1.10.6
module load netcdf_parallel/4.7.4
module load w3emc_para/2.4.0

module list


# specify PDY (the cycle start yyyymmdd) and cycle
export CDATE=2020013112
export CDATE=2020031000
export PDY=`echo $CDATE | cut -c1-8`
export cyc=`echo $CDATE | cut -c9-10`
export cycle=t${cyc}z


# specify the directory environment for executable, it's either para or prod
export envir=prod

####################################
# Specify RUN Name and model
####################################
export NET=gfs
export RUN=gfs

# set up running dir
export job=${RUN}_post_${cyc}
export pid=${pid:-$$}
export jobid=${job}.${pid}
mkdir -p /scratch2/NCEPDEV/stmp3/$LOGNAME/logs_post/logs
export jlogfile=/scratch2/NCEPDEV/stmp3/$LOGNAME/logs_post/jlogfile.${job}.${pid}

export DATA=/scratch2/NCEPDEV/stmp3/$LOGNAME/working_post/$jobid
mkdir -p $DATA
cd $DATA
rm -f ${DATA}/*

####################################
# SENDSMS  - Flag Events on SMS
# SENDCOM  - Copy Files From TMPDIR to $COMOUT
# SENDDBN  - Issue DBNet Client Calls
# RERUN    - Rerun posts from beginning (default no)
# VERBOSE  - Specify Verbose Output in global_postgp.sh
####################################
export SENDCOM=YES
export SENDDBN=NO
export RERUN=NO
export VERBOSE=YES

export HOMEgfs=/scratch2/NCEPDEV/ovp/Yali.Mao/git/EMC_post_fork

##############################################
# Define COM directories
##############################################
#export COMIN=/scratch2/NCEPDEV/stmp3/$LOGNAME/nemsio127/${RUN}.${PDY}/${cyc}
export COMIN=/scratch2/NCEPDEV/stmp3/$LOGNAME/nemsio/${RUN}.${PDY}/${cyc}
export COMIN=/scratch2/NCEPDEV/stmp3/Yali.Mao/netcdf/${RUN}.${PDY}/${cyc}
#export COMIN=/scratch1/NCEPDEV/stmp2/Fanglin.Yang/fv3test/gfs.20180110_nc_lossless/00
mkdir -p $COMIN
# specify my own COMOUT dir to mimic operations
export COMOUT=/scratch2/NCEPDEV/stmp3/$LOGNAME/com_post/${RUN}.$PDY/${cyc}
mkdir -p $COMOUT

# specify variables if testing post in non gfs structure environment
#export FIXglobal=/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/master/global_shared.v15.0.0/fix
#export FIXgfs=/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/master/global_shared.v15.0.0/fix
export FIXgfs=/scratch1/NCEPDEV/global/glopara/fix
#export POSTGRB2TBL=${HOMEgfs}/parm/params_grib2_tbl_new
#export POSTGRB2TBL=/scratch3/NCEPDEV/nwprod/lib/g2tmpl/v1.5.0/sorc/params_grib2_tbl_new
#export POSTGRB2TBL=$G2TMPL_SRC/params_grib2_tbl_new  # by module load g2tmpl
export POSTGPEXEC=${HOMEgfs}/exec/ncep_post
export PARMpost=${HOMEgfs}/parm

#export PostFlatFile=${HOMEgfs}/parm/postcntrl_gfs_gtg.msl.txt

export MSTF=NO

export PGBF=NO
export PGB1F=NO
export FLXF=NO
export GOESF=NO
export WAFSF=YES
export KEEPDATA=YES

####################################
# Specify Forecast Hour Range
####################################

#if [ $RUN = gdas ]; then
#    #export allfhr="anl 00 03 06 09"
#    export allfhr="anl 000 006"
#elif [ $RUN = gfs ]; then
#    #export allfhr="anl 00 01 06 12 60 120 180 240 252 384"
#    export allfhr="000"
#fi

#############################################################
export allfhr="039"

for post_times in $allfhr; do

    export post_times

    date

    # Theia doesn't have log.nemsio file, then prepare!
    COMROOT=/scratch2/NCEPDEV/rstprod/com
    COMROOT=$COMIN
    COMROOT=""
    if [[ -z $COMROOT ]] ; then
	export OUTPUT_FILE=netcdf
       $HOMEgfs/jobs/J_NCEPPOST
    elif [[  $COMROOT = $COMIN ]] ; then
       echo > $COMIN/gfs.t${cyc}z.logf${post_times}.nemsio
       $HOMEgfs/jobs/J_NCEPPOST
    else
       if [[ -f $COMROOT/gfs/prod/gfs.$PDY/$cyc/gfs.t${cyc}z.atmf${post_times}.nemsio ]] && \
	   [[ -f $COMROOT/gfs/prod/gfs.$PDY/$cyc/gfs.t${cyc}z.sfcf${post_times}.nemsio ]] ; then
	   ln -s $COMROOT/gfs/prod/gfs.$PDY/$cyc/gfs.t${cyc}z.atmf${post_times}.nemsio $COMIN/gfs.t${cyc}z.atmf${post_times}.nemsio
	   ln -s $COMROOT/gfs/prod/gfs.$PDY/$cyc/gfs.t${cyc}z.sfcf${post_times}.nemsio $COMIN/gfs.t${cyc}z.sfcf${post_times}.nemsio
	   echo > $COMIN/gfs.t${cyc}z.logf${post_times}.nemsio
	   $HOMEgfs/jobs/J_NCEPPOST
       else
	   echo "ERROR!!! Input files are not ready"
       fi
    fi

    echo $?

    date

done

#############################################################