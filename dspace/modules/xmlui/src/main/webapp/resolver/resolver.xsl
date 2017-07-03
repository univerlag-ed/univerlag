<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	version="1.1">

	<xsl:param name="purl"/>
	<xsl:param name="query"/>
	<xsl:variable name="baseURL">http://univerlag.uni-goettingen.de</xsl:variable>
	<xsl:variable name="mapfile">purl-mapping.xml</xsl:variable>
	<xsl:variable name="purlMapping" select="document($mapfile)" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>


	<xsl:template match="resolvedLPIs">
		<resolvedLPIs>
			<LPI>
				<requestedLPI>
                                                <xsl:value-of select="concat($baseURL, '/resolvexml?', $query)"/>
                                </requestedLPI>
                                <service>Universitätsverlag Göttingen</service>
                                <servicehome><xsl:value-of select="$baseURL"/></servicehome>

		<xsl:choose>
			<!-- resolve only requests which are in the purl-mapping or starts with 'univerlag-' -->
			<xsl:when test="$purlMapping//nodes/node[@webdocID=$query]">
				 <url>
					<xsl:value-of select="concat($baseURL, '/handle/', $purlMapping//nodes/node[@webdocID=$query])" />
				</url>
				<mime>text/html</mime>
				<version>1.0</version>
                                <access>free</access>
			</xsl:when>
			<xsl:when test="contains($query, 'univerlag-')">
				<xsl:variable name="lpi"><xsl:value-of select="substring-after($query, 'univerlag-')" /></xsl:variable>
				<url>
				<xsl:choose>
						<xsl:when test="contains($lpi, 'isbn-')">
							<xsl:value-of select="concat($baseURL, '/handle/','3/isbn-', substring-after($lpi, 'isbn-'))" />
						</xsl:when>
						<xsl:when test="contains($lpi, 'issn-')">
							<xsl:value-of select="concat($baseURL, '/handle/','3/issn-', substring-after($lpi, 'issn-'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat($baseURL, '/handle/','3/', $lpi)" />
						</xsl:otherwise>
				</xsl:choose>

				</url>
				<mime>text/html</mime>
                                <version>1.0</version>
                                <access>free</access>
			</xsl:when>
			<xsl:when test="contains($query, 'isbn-')">
                                <xsl:variable name="lpi"><xsl:value-of select="substring-after($query, 'isbn-')" /></xsl:variable>
                                <url>



                                                        <xsl:value-of select="concat($baseURL, '/handle/','3/isbn-', $lpi)" />
                                </url>
                                <mime>text/html</mime>
                                <version>1.0</version>
                                <access>free</access>
             </xsl:when>

			<xsl:otherwise>
				<URL />
			</xsl:otherwise>
		</xsl:choose>

		
                 <xsl:apply-templates select="@*|node()"/> 
                          </LPI>
		</resolvedLPIs>
        </xsl:template>


</xsl:stylesheet>
	


