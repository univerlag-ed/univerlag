<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd

 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:template match="/">
		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
			xmlns:dc="http://purl.org/dc/elements/1.1/" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<dc:title>
	
					<xsl:value-of select="." />
					<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
						<xsl:value-of select="concat(' ', .) "/>
					</xsl:for-each>
					<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
                                                <xsl:value-of select="concat(' ', .) "/>
                                        </xsl:for-each>
					<xsl:if test="//doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']">
					<xsl:text> - </xsl:text>
					<xsl:for-each select="//doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">
                        		        <xsl:value-of select="concat(., ' ')" />
			                        </xsl:for-each>
					</xsl:if>
				</dc:title>
		
			</xsl:for-each>
			<!-- dc.title.* -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="concat('- ', .)" /></dc:title>
			</xsl:for-each> -->
			<!-- dc.creator -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.contributor.author -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.contributor.* (!author) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each>
			<!-- dc.subject -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each> -->
			<!-- dc.subject.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='bic']/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='eng']/doc:element/doc:field[@name='value']">
                                <dc:subject>
					<xsl:attribute name="xml:lang">en</xsl:attribute>
					<xsl:value-of select="." />
				</dc:subject>
                        </xsl:for-each>
			<!-- dc.description -->
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstracteng']/doc:element/doc:field[@name='value']">
                                <dc:description>
					<xsl:attribute name="xml:lang">en</xsl:attribute>
					<xsl:value-of select="." />
				</dc:description>
                        </xsl:for-each>
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractger']/doc:element/doc:field[@name='value']">
				<dc:description>
					<xsl:attribute name="xml:lang">de</xsl:attribute>
					<xsl:value-of select="." />
				</dc:description>
			</xsl:for-each> 
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractother']/doc:element/doc:field[@name='value']">
                                <dc:description><xsl:value-of select="." /></dc:description>
                        </xsl:for-each>
			<!-- abstract -->
			<!-- <xsl:choose>
				<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstracteng']">
					<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstracteng']/doc:element/doc:field[@name='value']">
	                	                <dc:description><xsl:value-of select="." /></dc:description>
					</xsl:for-each>
				</xsl:when>
				<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractger']">
                                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractger']/doc:element/doc:field[@name='value']">
                                                <dc:description><xsl:value-of select="." /></dc:description>
                                        </xsl:for-each>
                                </xsl:when>
				<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractother']">
                                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstractother']/doc:element/doc:field[@name='value']">
                                                <dc:description><xsl:value-of select="." /></dc:description>
                                        </xsl:for-each>
                                </xsl:when>
			</xsl:choose> -->
			<!-- dc.description.* (not provenance)-->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!='provenance']/doc:element/doc:field[@name='value']">
			
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each> -->
			<!-- dc.date -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="." /></dc:date>
			</xsl:for-each> -->
			<!-- dc.date.* -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="." /></dc:date>
			</xsl:for-each> -->
			<!-- date.issued -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
                                <dc:date><xsl:value-of select="." /></dc:date>
                        </xsl:for-each>
			<!-- dc.type -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field[@name='value']">
				<dc:type><xsl:value-of select="." /></dc:type>
			</xsl:for-each>
			<!-- dc.type.* -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:element/doc:field[@name='value']">
				<dc:type><xsl:value-of select="." /></dc:type>
			</xsl:for-each> -->
			<!-- dc.identifier -->
<!--			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each> -->
			<!-- dc.identifier.uri -->
			<!--<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='intern']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each> -->
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
		                                <dc:identifier><xsl:value-of select="." /></dc:identifier>
                        </xsl:for-each>
			<!-- PDF URL -->
                        <xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
				<xsl:for-each select="../doc:element[@name='bitstreams']/doc:element/doc:field[@name='url']">
	                                <dc:identifier xsi:type="download"><xsl:value-of select="." /></dc:identifier>
				</xsl:for-each>
                        </xsl:for-each>
			<!-- dc.identifier.isbn-13 -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isbn-13']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			<!-- dc.identifier.isbn -->
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
                                <dc:identifier><xsl:value-of select="." /></dc:identifier>
                        </xsl:for-each>
			<!-- dc.language -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<dc:language>
				<xsl:choose>
					<xsl:when test=". = 'ger'"><xsl:text>German</xsl:text></xsl:when>
					<xsl:when test=". = 'eng'"><xsl:text>English</xsl:text></xsl:when>
					<xsl:when test=". = 'ara'"><xsl:text>Arabic</xsl:text></xsl:when>
					<xsl:when test=". = 'per'"><xsl:text>Persian</xsl:text></xsl:when>
					<xsl:when test=". = 'arm'"><xsl:text>Armenien</xsl:text></xsl:when>
					<xsl:when test=". = 'spa'"><xsl:text>Spanish</xsl:text></xsl:when>
					<xsl:otherwise><xsl:text>other</xsl:text></xsl:otherwise>
				</xsl:choose>
				</dc:language>
			</xsl:for-each>
			<!-- dc.language.* -->
			<!--<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each> -->
			<!-- dc.relation -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			<!-- dc.relation.ispartofseries -->
                        <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofseries']/doc:element/doc:field[@name='value']">
                                <dc:relation><xsl:value-of select="." /></dc:relation>
                        </xsl:for-each>
			<!-- dc.rights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			<!-- dc.rights.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			<!-- dc.format -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element/doc:field[@name='value']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each> -->
			<!-- dc.format.extent -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element[@name='extent']/doc:element/doc:field[@name='value']">
				<dc:format>
					<xsl:value-of select="." />
				</dc:format>
			</xsl:for-each>
			<!-- ? -->
			<xsl:for-each select="doc:metadata/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>
			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			<!-- dc.coverage.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each>
			<!-- dc.publisher.* -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each> -->
			<dc:publisher>Universitätsverlag Göttingen</dc:publisher>
			<!-- dc.source -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:field[@name='value']">
				<dc:source><xsl:value-of select="." /></dc:source>
			</xsl:for-each> -->
			<!-- dc.source.* -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='source']/doc:element/doc:element/doc:field[@name='value']">
				<dc:source><xsl:value-of select="." /></dc:source>
			</xsl:for-each> -->
		</oai_dc:dc>
	</xsl:template>
</xsl:stylesheet>
