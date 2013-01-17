<?xml version="1.0" ?>
<xsl:transform version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:wix="http://schemas.microsoft.com/wix/2006/wi">

	<!-- By default, copy all attributes and elements to the output. -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Add preprocessing instructions -->
	<xsl:template match="/wix:Wix">
		<xsl:processing-instruction name="include"><![CDATA[..\etc\properties.wxi]]></xsl:processing-instruction>
		<xsl:processing-instruction name="define"><![CDATA[RUBY_DIR="..\build-packages\ruby"]]></xsl:processing-instruction>
		<xsl:processing-instruction name="define"><![CDATA[RUBY_DISKID="3"]]></xsl:processing-instruction>
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
		</xsl:copy>
	</xsl:template>

	<!-- Remove elements containing the text ".gitignore", so they are omitted from the output as well as their Component parent element -->
	<!-- <xsl:template match="*[* and not(descendant::*[not(*) and not(self::wix:File[contains(@Source, '.gitignore')])])]"/> -->
	
	<!-- Change the ruby directory to "." -->
	<!--
	<xsl:template match="wix:DirectoryRef[@Id='OSSBuildInstallMinGWDir']/wix:Directory[@Name='ruby']/@Name">
		<xsl:attribute name="Name">.</xsl:attribute>
	</xsl:template>
	-->

	<!-- Specify an exact GUID to avoid potential clashes with duplicate msys files. -->
	<xsl:template match="wix:DirectoryRef[@Id='OSSBuildInstallOptDir']/wix:Directory[@Name='ruby']/wix:Directory[@Name='bin']/wix:Component">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="wix:File[@Source='$(var.RUBY_DIR)\bin\libeay32.dll']">
					<xsl:attribute name="Guid">{2C19AEAD-8DC7-5BBC-B5DE-968C16FBFA4A}</xsl:attribute>
					<xsl:apply-templates select="node()|@*[local-name()!='Guid']"/>
				</xsl:when>
				<xsl:when test="wix:File[@Source='$(var.RUBY_DIR)\bin\libiconv-2.dll']">
					<xsl:attribute name="Guid">{6AF24087-F31B-5E4E-AE2E-0E2E5FAD1755}</xsl:attribute>
					<xsl:apply-templates select="node()|@*[local-name()!='Guid']"/>
				</xsl:when>
				<xsl:when test="wix:File[@Source='$(var.RUBY_DIR)\bin\ssleay32.dll']">
					<xsl:attribute name="Guid">{899CC335-A769-5743-91D8-F2C2A1B05324}</xsl:attribute>
					<xsl:apply-templates select="node()|@*[local-name()!='Guid']"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="node()|@*"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="wix:File">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*"/>
			<xsl:attribute name="DiskId">$(var.RUBY_DISKID)</xsl:attribute>
		</xsl:copy>
	</xsl:template>

</xsl:transform>
