#!/bin/bash

###############################################################################
#                                                                             #
#                        OSSBuild Installer Tools                             #
#                                                                             #
# Contains functions for discovering and loading installed installer tools    #
# such as WiX (Windows Installer XML).                                        #
#                                                                             #
###############################################################################

OSSBUILD_SUPPORTED_WIX_VERSIONS=( "3.5" )

OSSBUILD_INSTALLER_WIX_HEAT_DEFAULT_OPTS="-sw5150 -nologo -ag -sreg -scom -svb6 -sfrag -template fragment "

command -v reg &>/dev/null || { 
	echo "WARNING: OSSBuild requires the Windows reg tool to examine the system for installer tools." >&2; 
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

find_wix_install_root() {
	reg_keys=( 
		'SOFTWARE\Microsoft\Windows Installer XML' 
		'SOFTWARE\Wow6432Node\Microsoft\Windows Installer XML' 
	)
	reg_hives=(
		"HKLM"
		"HKCU"
	)
	reg_value=""
	
	#Save off the separator used in the loop.
	local sep=$IFS
	IFS=$(echo -en "\n\b")
	for version in ${OSSBUILD_SUPPORTED_WIX_VERSIONS[@]}
	do
		for reg_key in ${reg_keys[@]}
		do
			for reg_hive in ${reg_hives[@]}
			do
				reg_key=${reg_key}\\${version}
				reg_value=$(query_registry_value "$reg_hive" "$reg_key" "InstallRoot")
				if [ "$reg_value" != "" ]; then
					break;
				fi
			done
			if [ "$reg_value" != "" ]; then
				break;
			fi
		done
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

load_installer_wix_tools() {
	local installer_wix_installroot=$(find_wix_install_root)
	local installer_wix_home=`cd "${installer_wix_installroot}/.." && pwd`
	local installer_wix_bin=${installer_wix_home}/bin
	local installer_wix_sdk=${installer_wix_home}/SDK
	local installer_wix_sdk_include=${installer_wix_sdk}/inc
	local installer_wix_sdk_lib=${installer_wix_sdk}/lib
	
	if [ -d "${installer_wix_home}" ]; then
		if [ -d "${installer_wix_bin}" ]; then
			export OSSBUILD_INSTALLER_WIX_HOME=`cd "${installer_wix_home}" && pwd -W`
			export OSSBUILD_INSTALLER_WIX_BIN_DIR=`cd "${installer_wix_bin}" && pwd -W`
			export OSSBUILD_INSTALLER_WIX_SDK_LIB_DIR=`cd "${installer_wix_sdk_lib}" && pwd -W`
			export OSSBUILD_INSTALLER_WIX_SDK_INCLUDE_DIR=`cd "${installer_wix_sdk_include}" && pwd -W`
		fi
		
		if [ -d "${installer_wix_bin}" ]; then
			export PATH="${installer_wix_bin}:$PATH"
		fi

		if [ -d "${installer_wix_sdk_include}" ]; then
			export INCLUDE="${installer_wix_sdk_include}:$INCLUDE"
		fi

		if [ -d "${installer_wix_sdk_lib}" ]; then
			export LIB="${installer_wix_sdk_lib}:$LIB"
		fi
		
		if [ -e "${OSSBUILD_INSTALLER_WIX_BIN_DIR}/heat.exe" ]; then
			export OSSBUILD_INSTALLER_WIX_HEAT=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/heat.exe
			export OSSBUILD_INSTALLER_WIX_LIGHT=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/light.exe
			export OSSBUILD_INSTALLER_WIX_CANDLE=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/candle.exe
			export OSSBUILD_INSTALLER_WIX_TORCH=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/torch.exe
			export OSSBUILD_INSTALLER_WIX_SETUPBLD=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/setupbld.exe
			export OSSBUILD_INSTALLER_WIX_PYRO=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/pyro.exe
			export OSSBUILD_INSTALLER_WIX_DARK=${OSSBUILD_INSTALLER_WIX_BIN_DIR}/dark.exe
		else
			echo "WARNING: Unable to locate the WiX heat.exe application for generating installer files."
			clean_environment_variables_on_error
		fi
	else
		echo "WARNING: OSSBuild was unable to find WiX (Windows Installer XML) on this system."
		clean_environment_variables_on_error
	fi
}

load_installer_tools() {
	#Validate a proper WiX installation.
	load_installer_wix_tools
}

clean_environment_variables() {
	unset OSSBUILD_SUPPORTED_WIX_VERSIONS
}

clean_environment_variables_on_error() {
	unset OSSBUILD_INSTALLER_WIX_HEAT_DEFAULT_OPTS
}

load_installer_tools
clean_environment_variables

