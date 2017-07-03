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
				<xsl:text>ISBN;Lieferstatus</xsl:text>
<xsl:text>
</xsl:text>
                <xsl:for-each select="item">
					<xsl:value-of select="concat(@isbn, ';', @status)" />
<xsl:text>
</xsl:text>	
				</xsl:for-each>

   </xsl:template>
        
</xsl:stylesheet>
