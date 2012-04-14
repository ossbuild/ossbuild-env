#!/bin/bash

###############################################################################
#                                                                             #
#                           OSSBuild Java Tools                               #
#                                                                             #
# Contains functions for discovering and loading installed Java development   #
# tools such as javac.exe, java.exe, It also sets up include and lib paths as #
# well.                                                                       #
#                                                                             #
###############################################################################

command -v reg &>/dev/null || { 
	echo "WARNING: OSSBuild requires the Windows reg tool to examine the system for java tools." >&2; 
}

registry_query_options() {
	reg query "HKCU\SOFTWARE" //reg:64 &>/dev/null && echo "//reg:64" || echo ""
	return 0
}

query_registry_value() {
	hive=$1
	if [ "$hive" = "" ]; then
		hive="HKLM"
	fi
	key=$hive\\$2
	name=$3
	reg_query_options=$(registry_query_options)
	reg_value=`reg query "$key" //v $name $reg_query_options 2>&- | awk 'NR==3{print substr(\$0, index(\$0,\$3))}'`
	if [ "$reg_value" = "" ]; then 
		echo ""
		return 1
	fi
	echo "$reg_value"
	return 0
}

find_java_jdk_version() {
	reg_keys=( 
		'SOFTWARE\JavaSoft\Java Development Kit' 
		'SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit' 
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
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "CurrentVersion")
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

find_java_jdk_home() {
	java_jdk_version=$(find_java_jdk_version)
	
	reg_keys=( 
		'SOFTWARE\JavaSoft\Java Development Kit' 
		'SOFTWARE\Wow6432Node\JavaSoft\Java Development Kit' 
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
			reg_key=${reg_key}\\${java_jdk_version}
			reg_value=$(query_registry_value "$reg_hive" "$reg_key" "JavaHome")
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
	
	if [ "$reg_value" = "" ]; then
		echo ""
		return 1
	fi
	if [ -d "$reg_value" ]; then
		reg_value=`cd "${reg_value}" && pwd`
	fi
	echo "$reg_value"
	return 0
}

load_java_jdk_tools() {
	local java_jdk_home=$(find_java_jdk_home)
	local java_jdk_bin=${java_jdk_home}/bin
	local java_jdk_lib=${java_jdk_home}/lib
	local java_jdk_include=${java_jdk_home}/include
	local java_jdk_jawt_bin=${java_jdk_home}/jre/bin
	local java_jdk_jvm_bin=${java_jdk_home}/jre/bin/server
	
	if [ -d "${java_jdk_home}" ]; then
		if [ -d "${java_jdk_bin}" ]; then
			export PATH="${java_jdk_bin}:$PATH"
		fi

		if [ -d "${java_jdk_include}" ]; then
			export INCLUDE="${java_jdk_include}:$INCLUDE"
		fi

		if [ -d "${java_jdk_lib}" ]; then
			export LIB="${java_jdk_lib}:$LIB"
		fi
		
		export OSSBUILD_JAVA_JDK_HOME=`cd "${java_jdk_home}" && pwd -W`
		export OSSBUILD_JAVA_JDK_BIN_DIR=`cd "${java_jdk_bin}" && pwd -W`
		export OSSBUILD_JAVA_JDK_LIB_DIR=`cd "${java_jdk_lib}" && pwd -W`
		export OSSBUILD_JAVA_JDK_INCLUDE_DIR=`cd "${java_jdk_include}" && pwd -W`
		
		local gcc_triplet=$(gcc -dumpmachine)
		local gcc_dir=$(cd $(dirname $(which gcc))/../${gcc_triplet} && pwd)
		local gcc_lib_dir="${gcc_dir}/lib"
		
		local java_jvm_so="${java_jdk_jvm_bin}/jvm.dll"
		local java_jawt_so="${java_jdk_jawt_bin}/jawt.dll"
		
		local java_jvm_lib="${gcc_lib_dir}/libjvm.dll.a"
		local java_jawt_lib="${gcc_lib_dir}/libjawt.dll.a"
		
		if [ ! -f "${java_jawt_lib}" ] || [ ! -f "${java_jvm_lib}" ]; then 
			echo "INFO: OSSBuild has detected that there are missing Java import libraries. This is normal for the first run after a new install."
			echo "INFO: Generating new import libraries..."
			
			if [ -d "${java_jdk_jvm_bin}" ]; then
				gendef "${java_jvm_so}" &>/dev/null && sed -e '/DATA/d' jvm.def > jvm.clean.def && dlltool --input-def jvm.clean.def --kill-at --dllname jvm.dll --output-lib ${java_jvm_lib} && rm -f jvm.def jvm.clean.def
			else
				echo "WARNING: OSSBuild was unable to locate jvm.dll in order to create the jvm.dll import library."
			fi
			
			if [ -d "${java_jdk_jawt_bin}" ]; then
				gendef "${java_jawt_so}" &>/dev/null && sed -e '/DATA/d' jawt.def > jawt.clean.def  && dlltool --input-def jawt.clean.def --kill-at --dllname jawt.dll --output-lib ${java_jawt_lib} && rm -f jawt.def jawt.clean.def
			else
				echo "WARNING: OSSBuild was unable to locate jawt.dll in order to create the jawt.dll import library."
			fi
		fi
	else
		echo "WARNING: OSSBuild was unable to recognize a Java Development Kit (JDK) on this system."
	fi
}

load_java_tools() {
	load_java_jdk_tools
}

load_java_tools
