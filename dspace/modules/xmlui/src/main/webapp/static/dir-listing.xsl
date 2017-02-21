<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:dir="http://apache.org/cocoon/directory/2.0" exclude-result-prefixes="dir"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="dir:directory">
		<ul>
			
			<!-- <xsl:value-of select="@name"/>
			<xsl:text>&#160;&#160;</xsl:text>
			<xsl:value-of select="@size"/>
			<xsl:text>&#160;&#160;</xsl:text>
                        <xsl:value-of select="@date"/> -->
			<xsl:apply-templates />
		</ul>
</xsl:template>


<xsl:template match="dir:file">
		<xsl:variable name="dirname"><xsl:value-of select="../@name"/></xsl:variable>
		<li>
                	<xsl:element name="a">
                        	<xsl:attribute name="href"><xsl:value-of select="concat('/review-download/', $dirname, '/' , @name)"/></xsl:attribute>
	                        <xsl:value-of select="@name"/>
        	        </xsl:element>
			<xsl:text>&#160;&#160;</xsl:text>
	                <xsl:choose>
	                        <xsl:when test="@size &lt; 1000">
        	                        <xsl:value-of select="concat(@size, 'Bytes')"/> 
                	        </xsl:when>
                        	<xsl:when test="@size &lt; 1000000">
                                	<xsl:value-of select="substring(string(@size div 1000),1,5)"/><xsl:text> KB</xsl:text>
	                        </xsl:when>
        	                <xsl:when test="@size &lt; 1000000000">
                	                <xsl:value-of select="substring(string(@size div 1000000),1,5)"/><xsl:text> MB</xsl:text>
                        	</xsl:when>
	                        <xsl:when test="@size &lt; 1000000000000">
        	                        <xsl:value-of select="substring(string(@size div 1000000000),1,5)"/><xsl:text> GB</xsl:text>
                	        </xsl:when>
	                </xsl:choose>
			<!-- <xsl:value-of select="concat(' Date: ', substring-before(@date,' '), ' lastModified: ', @lastModified)"/> -->
		</li>
</xsl:template>
<xsl:template match="/">
	<html>
		<head>
			<title>eDiss Göttingen GVK Export</title>
		</head>
		<body>
	                <xsl:apply-templates/>
		</body>
	</html>
</xsl:template>

</xsl:stylesheet>
