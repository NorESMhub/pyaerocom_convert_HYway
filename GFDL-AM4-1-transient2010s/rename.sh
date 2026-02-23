#!/bin/bash

#script to create data that is readable by pyaerocom

IFS=$(echo -en "\n\b")

usage() { echo "Usage: $0 [-U] <infiles>" 
        echo "-U to update existing file with backup"
        exit 0
}

if [[ $# -eq 0 ]]
   then usage
fi

updateflag=0

while getopts ":U" opt; do
  case $opt in
    U)
      echo "-U was triggered!" >&2
      arg=${OPTARG}
      updateflag=1
                #remove the -U from $@
                shift 1
      ;;
    \?)
      usage
      ;;
  esac
done

date=$(date '+%Y%m%d_%H%M%S')
RND=${RANDOM}
tmpfile="./dummy_${RND}.nc"
cmd_nco="ncks -O -4 --chunk_policy nco"
cmd_cdo="cdo -O -f nc4 -k auto copy"
threedcmd="cdo -O -f nc4 -k auto copy"


# get paths of some nco commands and cdo
NCKS=$(mamba run -n nco which ncks)
NCRENAME=$(mamba run -n nco which ncrename)
NCATTED=$(mamba run -n nco which ncatted)
NCWA=$(mamba run -n nco which ncwa)
NCAP2=$(mamba run -n nco which ncap2)
CDO=$(mamba run -n cdo which cdo)

set -x
basedir='/nird/datapeak/NS11106K/HYway/modelling_repository/pyaerocom/'
Model=`pwd | rev | cut -d/ -f1 | rev`
outdir="${basedir}/${Model}/renamed/"
lowest_level=48

vert_coord_name='lev'

declare -A aerocom_vars
aerocom_vars[o3]="vmro3"
aerocom_vars[mmrso4]="mmrso4"
aerocom_vars[ta]="ts"
aerocom_vars[pfull]="ps"
aerocom_vars[no2]="vmrno2"
aerocom_vars[so2]="vmrso2"

declare -A vars_in_file
vars_in_file[o3]="O3_dvmr"
vars_in_file[mmrso4]="mmrso4"
vars_in_file[ta]="ta"
vars_in_file[no2]="NO2_dvmr"
vars_in_file[so2]="SO2_dvmr"


create_dir () {
        dir=${1}
        if [[ ! -d ${outdir} ]]
                then 
                mkdir -p ${outdir}
                echo 'created'
        else
                echo 'exists'
        fi
}

# for unit adjustments we need the temperature...
# prepare yearly files of that...

for file in "$@"
	do echo ${file}
	var=$(basename ${file} | cut -d_ -f1)
	# adjust for some oddities in the dataset
	if [[ ${var} == 'o3' || ${var} == 'no2' || ${var} == 'so2' ]]
		then vert_coord_name='pfull'

	fi
	timecode=$(basename ${file} | cut -d_ -f2)
	# the GFDL files unfortunately have an error indicating Julian calendar
	#  correct that assuming that it's just a conversion error
	cp ${file} ${tmpfile}
	${NCATTED} -O -a "calendar,time,o,c,proleptic_gregorian" ${tmpfile}
	if [[ ${var} != ${vars_in_file[${var}]} ]]
		then ${NCRENAME} -O -v ${vars_in_file[${var}]},${var} ${tmpfile}
	fi
	# split file into years
	${CDO} -O splityear ${tmpfile} splityear_${RND}_
	# extract lowest layer
	for yearfile in $(find . -name "splityear_${RND}_*.nc" | sort)
		do echo ${yearfile}
		year=$(echo ${yearfile} | cut -d_ -f3 | cut -d. -f1)
		#${CDO} -O splitlevel,0.992556 ${yearfile} splitlevel_${RND}_
		${NCKS} -O -d ${vert_coord_name},${lowest_level} -v ${var} ${yearfile} ${tmpfile}
		${NCWA} -O -a ${vert_coord_name} ${tmpfile} ${tmpfile}
		outfile="aerocom_${Model}_${aerocom_vars[${var}]}_Surface_${year}_${timecode}.nc"
		# here some unit conversions will follow
		if [[ ${var} != ${aerocom_vars[${var}]} ]]
			then ${NCRENAME} -O -v ${var},${aerocom_vars[${var}]} ${tmpfile}
		fi
		mv ${tmpfile} renamed/${outfile}
		rm ${yearfile} 

	done

done


