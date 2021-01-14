<?xml version="1.0" encoding="UTF-8"?>

<!--
  vlb2csv.xsl

  Version: 1.0
 
  Date: 2016-06-29
 
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    

    <!--  
    the above should be replaced with if Saxon is going to be used.
    
     -->
    <xsl:output method="text" encoding="UTF-8" indent="no" media-type="text/csv; charset=UTF-8" />

	<xsl:template match="/items">
				<xsl:text>ISBN;DOI;Umfang Höhe / Breite / Gewicht;Lieferstatus;Zolltarifnummer;Herstellungsland</xsl:text>
<xsl:text>
</xsl:text>
                <xsl:for-each select="item">
					<xsl:variable name="mass">
						<xsl:choose>
							<xsl:when test="contains(@format, '12,6x20,5')">
								<xsl:text>H 20,5 cm / B 12,6 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '15x22')">
								<xsl:text>H 22 cm / B 15 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '15,5x23')">
								<xsl:text>H 23cm / B 15,5 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '17x24')">
								<xsl:text>H 24 cm / B 17 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '17,6x25')">
								<xsl:text>H 25 cm / B 17,6 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '20x20')">
								<xsl:text>H 20 cm / B 20 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '20x22,5')">
								<xsl:text>H 22,5 cm / B 20 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '21x21')">
								<xsl:text>H 21 cm / B 21 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '21x27')">
								<xsl:text>H 27 cm / B 21 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, '25x21')">
								<xsl:text>H 21 cm / B 25 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, 'DIN A4')">
								<xsl:text>H 29,7 cm / B 21 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, 'DIN A5')">
								<xsl:text>H 21 cm / B 14,8 cm / - g</xsl:text>
							</xsl:when>
							<xsl:when test="contains(@format, 'DIN A5 quer')">
								<xsl:text>H 14,8 cm / B 21 cm / - g</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>H 24 cm / B 17 cm / - g</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="concat(@isbn, ';', @DOI, ';', $mass, ';', @status, ';', '49019900;Deutschland')" />
<xsl:text>
</xsl:text>	
				</xsl:for-each>

   </xsl:template>
        
</xsl:stylesheet>


