<?xml version="1.0" ?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">

	<!-- By default, copy all attributes and elements to the output. -->
	<xsl:template match="@*|*">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>
	
	<!-- Add preprocessing instructions -->
	<xsl:template match="/wix:Wix">
		<xsl:processing-instruction name="include"><![CDATA[..\etc\properties.wxi]]></xsl:processing-instruction>
		<xsl:processing-instruction name="define"><![CDATA[MSYS_DIR="..\msys"]]></xsl:processing-instruction>
		<xsl:processing-instruction name="define"><![CDATA[MSYS_DISKID="2"]]></xsl:processing-instruction>
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>

	<!-- Remove the home directory -->
	<xsl:template match="wix:Directory[@Name='home']" />

	<!-- Remove elements containing the text ".gitignore", so they are omitted from the output as well as their Component parent element -->
	<!-- <xsl:template match="*[* and not(descendant::*[not(*) and not(self::wix:File[contains(@Source, '.gitignore')])])]"/> -->
	
	<!-- Modify the id of certain files to something known -->
	<xsl:template match="wix:File[@Source='$(var.MSYS_DIR)\msys-x86.bat']/@Id">
		<xsl:attribute name="Id">MSYS_X86_BAT</xsl:attribute>
	</xsl:template>
	<xsl:template match="wix:File[@Source='$(var.MSYS_DIR)\msys-x86_64.bat']/@Id">
		<xsl:attribute name="Id">MSYS_X86_64_BAT</xsl:attribute>
	</xsl:template>

	<!-- Change the msys directory to "." -->
	<xsl:template match="wix:DirectoryRef[@Id='OSSBuildInstallSysDir']/wix:Directory[@Name='msys']/@Name">
		<xsl:attribute name="Name">.</xsl:attribute>
	</xsl:template>
	
	<!-- Change the msys /etc/profile.d/ directory id to something that can be referenced elsewhere -->
	<xsl:template match="wix:Directory[@Name='etc']/wix:Directory[@Name='profile.d']/@Id">
		<xsl:attribute name="Id">OSSBuildInstallSysEtcProfileDir</xsl:attribute>
	</xsl:template>
	
	<!-- Remove the msys /etc/profile.d/ossbuild/ directory -->
	<xsl:template match="wix:Directory[@Name='etc']/wix:Directory[@Name='profile.d']/wix:Directory[@Name='ossbuild']" />

	<xsl:template match="wix:File">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="*" />
			<xsl:attribute name="DiskId">$(var.MSYS_DISKID)</xsl:attribute>
		</xsl:copy>
	</xsl:template>

</xsl:transform>
