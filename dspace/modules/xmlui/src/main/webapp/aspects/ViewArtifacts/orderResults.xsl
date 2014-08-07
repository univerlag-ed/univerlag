<xsl:stylesheet 
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" 
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan" 
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:str="http://exslt.org/strings"
    xmlns:url="http://whatever/java/java.net.URLEncoder" 
    exclude-result-prefixes="xalan encoder i18n dri mets dim  xlink xsl str url">


    <!--  
    the above should be replaced with if Saxon is going to be used.
    
     -->
    <xsl:output method="text" indent="no" omit-xml-declaration="yes" media-type="text/plain" encoding="UTF-8"/>
    <xsl:param name="result">
        <![CDATA[{"success":"true"}]]>
    </xsl:param>

    <xsl:template match="*" />
    <xsl:template match="/" >
	<xsl:value-of select="$result"  disable-output-escaping="yes" />
    </xsl:template>
</xsl:stylesheet>
