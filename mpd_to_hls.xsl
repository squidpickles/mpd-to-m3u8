<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="urn:mpeg:dash:schema:mpd:2011"
		version="1.0">
	<xsl:output encoding="utf-8" method="text" omit-xml-declaration="yes" />
	<xsl:param name="run_id" />

	<xsl:template match="/">
		<xsl:if test="not($run_id)">
			<xsl:message terminate="yes">Run ID must be set in $run_id</xsl:message>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="m:MPD">
		<xsl:text>#EXTM3U&#xa;</xsl:text>
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="m:Representation">
		<xsl:text>#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=</xsl:text>
		<xsl:value-of select="@bandwidth" />
		<xsl:if test="@width and @height">
			<xsl:text>,RESOLUTION=</xsl:text>
			<xsl:value-of select="@width" />
			<xsl:text>x</xsl:text>
			<xsl:value-of select="@height" />
		</xsl:if>
		<xsl:text>,CODECS="</xsl:text>
		<xsl:value-of select="@codecs" />
		<xsl:text>"&#xa;</xsl:text>
		<xsl:value-of select="$run_id" />
		<xsl:text>_</xsl:text>
		<xsl:value-of select="@id" />
		<xsl:text>.m3u8&#xa;</xsl:text>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:apply-templates />
	</xsl:template>

</xsl:stylesheet>
