#/bin/bash
#        $0		$1	$2	$3		$4
#usage:  jpg2avif	10	95	yuv444p10le	input
# getu:  input❤.avif

preset=$1
min_vmaf=$2
pix_format=$3
input_file=$4
temp_dir=$(dirname "${input_file}")
OutputContainer=avif

OutputDir=$(dirname "${input_file}")
OutputFilename=$(basename "${input_file%.*}").${input_file##*.}

AB_AV1_CACHE=

suffix=【${min_vmaf}⁄${preset}
tmp_suffix=_tmp

if [ -f "${OutputDir}/${OutputFilename}.log" ]||[ -f "${OutputDir}/${OutputFilename}.log.xz" ]; then
	LOGFILE="${OutputDir}/${OutputFilename}_$(date +"%Y%m%d_%H%M%S").log"
else
	LOGFILE="${OutputDir}/${OutputFilename}.log"
fi

echo "$(date +"%Y-%m-%d %H:%M:%S") Start New Task..." | tee -a "${LOGFILE}"
echo | tee -a "${LOGFILE}"
echo " Input: ${input_file}" | tee -a "${LOGFILE}"
echo "Output: ${OutputDir}/${OutputFilename}${suffix}.${OutputContainer}" | tee -a "${LOGFILE}"

echo | tee -a "${LOGFILE}"

	if [ -f "${OutputDir}/${OutputFilename}${suffix}.${OutputContainer}" ]; then
		echo "Warning: Output File Already Exists, nothing touched." | tee -a "${LOGFILE}"
	else
		if [ -f "${OutputDir}/${OutputFilename}${tmp_suffix}.${OutputContainer}" ]; then
			rm -f "${OutputDir}/${OutputFilename}${tmp_suffix}.${OutputContainer}"
		fi
		ab-av1 \
			auto-encode \
			--input ${input_file} \
			--preset ${preset} \
			--pix-format ${pix_format} \
			--min-vmaf ${min_vmaf} \
			--temp-dir ${temp_dir} \
			--output "${OutputDir}/${OutputFilename}${tmp_suffix}.${OutputContainer}" 2>&1 | tee \
			-a "${LOGFILE}"&&mv \
			"${OutputDir}/${OutputFilename}${tmp_suffix}.${OutputContainer}" \
			"${OutputDir}/${OutputFilename}${suffix}.${OutputContainer}"

		echo >> "${LOGFILE}"
		if [ -f "${OutputDir}/${OutputFilename}${suffix}.${OutputContainer}" ]; then
			echo ★Source File: >> "${LOGFILE}"
			mediainfo "${input_file}" >> "${LOGFILE}"
			echo ★Encoded File: >> "${LOGFILE}"
			mediainfo "${OutputDir}/${OutputFilename}${suffix}.${OutputContainer}" >> "${LOGFILE}"
			echo "$(date +"%Y-%m-%d %H:%M:%S") Encoding Successful" | tee -a "${LOGFILE}"
		else
			echo ★Source File: >> "${LOGFILE}"
			mediainfo "${input_file}" >> "${LOGFILE}"
			echo "$(date +"%Y-%m-%d %H:%M:%S") Encoding Interrupted" | tee -a "${LOGFILE}"
		fi
		xz --compress -9 --extreme --threads=0 "${LOGFILE}" #gzip --best "${LOGFILE}"
	fi
