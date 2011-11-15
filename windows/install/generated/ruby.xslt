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
		<xsl:processing-instruction name="define"><![CDATA[RUBY_DIR="..\build-packages\ruby"]]></xsl:processing-instruction>
		<xsl:processing-instruction name="define"><![CDATA[RUBY_DISKID="3"]]></xsl:processing-instruction>
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="*" />
		</xsl:copy>
	</xsl:template>

	<!-- Remove elements containing the text ".gitignore", so they are omitted from the output as well as their Component parent element -->
	<!-- <xsl:template match="*[* and not(descendant::*[not(*) and not(self::wix:File[contains(@Source, '.gitignore')])])]"/> -->
	
	<!-- Change the msys directory to "." -->
	<xsl:template match="wix:DirectoryRef[@Id='OSSBuildInstallMinGWDir']/wix:Directory[@Name='ruby']/@Name">
		<xsl:attribute name="Name">.</xsl:attribute>
	</xsl:template>

	<xsl:template match="wix:File">
		<xsl:copy>
			<xsl:apply-templates select="@*" />
			<xsl:apply-templates select="*" />
			<xsl:attribute name="DiskId">$(var.RUBY_DISKID)</xsl:attribute>
		</xsl:copy>
	</xsl:template>

</xsl:transform>
