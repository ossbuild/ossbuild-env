#!/bin/bash

###############################################################################
#                                                                             #
#                           OSSBuild MSVC Tools                               #
#                                                                             #
# Contains functions for discovering and loading installed Microsoft          #
# development tools such as cl.exe, lib.exe, csc.exe, etc. It also sets up    #
# include and lib paths as well.                                              #
#                                                                             #
###############################################################################

OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS=( "10.0" "9.0" )
OSSBUILD_SUPPORTED_MSVC_COMMON_TOOLS=( VS100COMNTOOLS VS90COMNTOOLS )

export OSSBUILD_MSVC_LIB=

command -v reg &>/dev/null || { 
	echo "WARNING: OSSBuild requires the Windows reg tool to examine the system for .NET framework tools." >&2; 
}

query_registry_value() {
	hive=$1
	if [ "$hive" = "" ]; then
		hive="HKLM"
	fi
	key=$hive\\$2
	name=$3
	reg_value=`reg query "$key" //v $name 2>&- | awk 'NR==3{print substr(\$0, index(\$0,\$3))}'`
	if [ "$reg_value" = "" ]; then 
		echo ""
		return 1
	fi
	echo $reg_value
	return 0
}

find_ms_windows_sdk_dir() {
	reg_key='SOFTWARE\Microsoft\Microsoft SDKs\Windows'
	reg_key_name='CurrentInstallFolder'
	
	reg_value=$(query_registry_value "HKLM" "$reg_key" "$reg_key_name")
	if [ "$reg_value" = "" ]; then
		reg_value=$(query_registry_value "HKCU" "$reg_key" "$reg_key_name")
	fi
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_visual_studio_common_tools_dir() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VS7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for version in ${OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS[@]}
	do
		for reg_key in ${reg_keys[@]}
		do
			for reg_hive in ${reg_hives[@]}
			do
				reg_value=$(query_registry_value "$reg_hive" "$reg_key" "$version")
				if [ "$reg_value" != "" ]; then
					break;
				fi
			done
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if ([ "$reg_value" = "" ]) || ([ ! -d "${reg_value}Common7/Tools/" ]); then
		#Attempt to locate an env var like VS100COMNTOOLS or VS90COMNTOOLS 
		#and use that if it exists.
		for common_tools in ${OSSBUILD_SUPPORTED_MSVC_COMMON_TOOLS[@]}
		do
			#Expand the string env variable to its actual value.
			common_tools=${!common_tools}
			
			if [ -d "${common_tools}" ]; then 
				reg_value=`cd "${common_tools}" && pwd`
				echo $reg_value
				return 0
			fi 
		done
		
		echo ""
		return 1
	fi
	
	reg_value=`cd "${reg_value}Common7/Tools/" && pwd`
	echo $reg_value
	return 0
}

find_ms_visual_studio_install_dir() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VS7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VS7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for version in ${OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS[@]}
	do
		for reg_key in ${reg_keys[@]}
		do
			for reg_hive in ${reg_hives[@]}
			do
				reg_value=$(query_registry_value "$reg_hive" "$reg_key" "$version")
				if [ "$reg_value" != "" ]; then
					break;
				fi
			done
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_visual_cpp_install_dir() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VC7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for version in ${OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS[@]}
	do
		for reg_key in ${reg_keys[@]}
		do
			for reg_hive in ${reg_hives[@]}
			do
				reg_value=$(query_registry_value "$reg_hive" "$reg_key" "$version")
				if [ "$reg_value" != "" ]; then
					break;
				fi
			done
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_fsharp_install_dir() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\{0}\Setup\F#' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\{0}\Setup\F#' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for version in ${OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS[@]}
	do
		for reg_key in ${reg_keys[@]}
		do
			reg_key=`echo $reg_key | sed "s/{0}/$version/g"`
			for reg_hive in ${reg_hives[@]}
			do
				reg_value=$(query_registry_value "$reg_hive" "$reg_key" "ProductDir")
				if [ "$reg_value" != "" ]; then
					break;
				fi
			done
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_framework_dir_32() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VC7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "FrameworkDir32")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_framework_dir_64() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VC7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "FrameworkDir64")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_framework_ver_32() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VC7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "FrameworkVer32")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_framework_ver_64() {
	reg_keys=( 
		'SOFTWARE\Microsoft\VisualStudio\SxS\VC7' 
		'SOFTWARE\Wow6432Node\Microsoft\VisualStudio\SxS\VC7' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "FrameworkVer64")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo $reg_value
	return 0
}

find_ms_framework35_ver() {
	echo "v3.5"
	return 0
}

find_alt_ms_framework_dir() {
	reg_keys=( 
		'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client' 
		'SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4\Client' 
		'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5' 
		'SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v3.5' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	
	#Save off the separator used in the loop.
	local sep=$IFS
	IFS=$(echo -en "\n\b")
	
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "InstallPath")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	
	#Restore the previous separator.
	IFS=sep
	
	if ([ "$reg_value" = "" ]); then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo "$reg_value"
	return 0
}

find_alt_ms_framework_ver() {
	reg_keys=( 
		'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Client' 
		'SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4\Client' 
		'SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5' 
		'SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v3.5' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	
	#Save off the separator used in the loop.
	local sep=$IFS
	IFS=$(echo -en "\n\b")
	
	for reg_key in ${reg_keys[@]}
	do
		for reg_hive in ${reg_hives[@]}
		do
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "Version")
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
		if [ "$reg_value" != "" ]; then
			break;
		fi
	done
	
	#Restore the previous separator.
	IFS=sep
	
	if ([ "$reg_value" = "" ]); then
		echo ""
		return 1
	fi
	
	echo "$reg_value"
	return 0
}

load_ms_exports() {
	local ProgramFiles_x86=`env | sed -n s,'^PROGRAMFILES(X86)=',,g`

	local windows_sdk_dir=$(find_ms_windows_sdk_dir)
	local vs_install_dir=$(find_ms_visual_studio_install_dir)
	local vc_install_dir=$(find_ms_visual_cpp_install_dir)
	local fsharp_install_dir=$(find_ms_fsharp_install_dir)
	local framework_dir_32=$(find_ms_framework_dir_32)
	local framework_dir_64=$(find_ms_framework_dir_64)
	local framework_ver_32=$(find_ms_framework_ver_32)
	local framework_ver_64=$(find_ms_framework_ver_64)
	local framework_35_ver=$(find_ms_framework35_ver)
	local alt_framework_ver=$(find_alt_ms_framework_ver)
	local alt_framework_dir=$(find_alt_ms_framework_dir)
	local vs_common_tools=$(find_ms_visual_studio_common_tools_dir)

	local dev_env_dir=${vs_install_dir}/Common7/IDE

	local framework_dir=${framework_dir_32}
	local framework_ver=${framework_ver_32}

	if [ "${windows_sdk_dir}" != "" ]; then
		export PATH=${windows_sdk_dir}/bin/NETFX\ 4.0\ Tools:${windows_sdk_dir}/bin:$PATH
		export INCLUDE=${windows_sdk_dir}/include:$INCLUDE
		export LIB=${windows_sdk_dir}/lib:$LIB
	fi

	if [ -d "${vs_install_dir}/Team\ Tools/Performance\ Tools" ]; then
		export PATH=${vs_install_dir}/Team\ Tools/Performance\ Tools:$PATH
	fi

	if [ -d "${ProgramFiles}/HTML\ Help\ Workshop" ]; then
		export PATH=${ProgramFiles}/HTML\ Help\ Workshop:$PATH
	fi

	if [ -d "${ProgramFiles_x86}/HTML\ Help\ Workshop" ]; then
		export PATH=${ProgramFiles_x86}/HTML\ Help\ Workshop:$PATH
	fi

	if [ -d "${vc_install_dir}/VCPackages" ]; then
		export PATH=${vc_install_dir}/VCPackages:$PATH
	fi

	export PATH=${framework_dir}/${framework_35_ver}:$PATH
	export PATH=${framework_dir}/${framework_ver}:$PATH
	export PATH=${vs_install_dir}/Common7/Tools:$PATH

	if [ -d "${vc_install_dir}/BIN" ]; then
		export PATH=${vc_install_dir}/BIN:$PATH
	fi

	export PATH=${dev_env_dir}:$PATH

	if [ -d "${vs_install_dir}/VSTSDB/Deploy" ]; then
		export PATH=${vs_install_dir}/VSTSDB/Deploy:$PATH
	fi

	if [ "${fsharp_install_dir}" != "" ]; then
		export PATH=${fsharp_install_dir}:$PATH
	fi

	if [ -d "${vc_install_dir}/ATLMFC/INCLUDE" ]; then
		export INCLUDE=${vc_install_dir}/ATLMFC/INCLUDE:$INCLUDE
	fi

	if [ -d "${vc_install_dir}/INCLUDE" ]; then
		export INCLUDE=${vc_install_dir}/INCLUDE:$INCLUDE
	fi

	if [ -d "${vc_install_dir}/ATLMFC/LIB" ]; then
		export LIB=${vc_install_dir}/ATLMFC/LIB:$LIB
	fi

	if [ -d "${vc_install_dir}/LIB" ]; then
		export LIB=${vc_install_dir}/LIB:$LIB
	fi

	if [ -d "${vc_install_dir}/ATLMFC/LIB" ]; then
		export LIBPATH=${vc_install_dir}/ATLMFC/LIB:$LIBPATH
	fi

	if [ -d "${vc_install_dir}/LIB" ]; then
		export LIBPATH=${vc_install_dir}/LIB:$LIBPATH
	fi

	export LIBPATH=${framework_dir}/${framework_35_ver}:$LIBPATH
	export LIBPATH=${framework_dir}/${framework_ver}:$LIBPATH

	#Export out vars.
	export WindowsSdkDir=`cd "${windows_sdk_dir}" && pwd -W`
	export VSINSTALLDIR=`cd "${vs_install_dir}" && pwd -W`
	export VCINSTALLDIR=`cd "${vc_install_dir}" && pwd -W`
	export FSHARPINSTALLDIR=`cd "${fsharp_install_dir}" && pwd -W`
	export FrameworkDir32=`cd "${framework_dir_32}" && pwd -W`
	export FrameworkVersion32=${framework_ver_32}
	export FrameworkDir64=`cd "${framework_dir_64}" && pwd -W`
	export FrameworkVersion64=${framework_ver_64}
	export Framework35Version=${framework_35_ver}
	export VSCOMNTOOLS=`cd "${vs_common_tools}" && pwd -W`
	export DevEnvDir=`cd "${dev_env_dir}" && pwd -W`
	export FrameworkDir=`cd "${framework_dir}" && pwd -W`
	export FrameworkVersion=${framework_ver}
	
	#Add our own.
	if [ "${alt_framework_dir}" != "" ]; then
		export PATH=${alt_framework_dir}:$PATH
	fi
	
	#Create some aliases.
	local msbuild=$(which MSBuild.exe)
	if [ "${msbuild}" != "" ]; then
		eval "alias msbuild='${msbuild}'"
	fi
}

clean_environment_variables() {
	unset OSSBUILD_SUPPORTED_MS_VISUAL_STUDIO_VERSIONS
	unset OSSBUILD_SUPPORTED_MSVC_COMMON_TOOLS
}

load_ms_exports
clean_environment_variables

if ([ ! -d "${VCINSTALLDIR}/BIN" ]) || ([ ! -e "${VCINSTALLDIR}/BIN/lib.exe" ]); then 
	echo "WARNING: OSSBuild will be unable to properly generate Visual C++-compatible lib (.lib) files. Please install Microsoft Visual Studio or an equivalent platform SDK."
else
	export OSSBUILD_MSVC_LIB=${VCINSTALLDIR}/BIN/lib.exe
fi
