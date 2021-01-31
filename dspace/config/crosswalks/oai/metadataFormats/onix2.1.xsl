<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:doc="http://www.lyncode.com/xoai" 
	xmlns:date="http://exslt.org/dates-and-times"
	extension-element-prefixes="date"
	version="1.0">
    
        <xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

        <xsl:template match="/">

		<!-- actual used langueages: de, per, ara, en -->
		<xsl:variable name="internlang"><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']" /></xsl:variable>
		<xsl:variable name="lang">
			<xsl:choose>
				<xsl:when test="$internlang = 'en'">
					<xsl:text>eng</xsl:text>
				</xsl:when>
				<xsl:when test="$internlang = 'de'">
                                        <xsl:text>ger</xsl:text>
                                </xsl:when>
				<xsl:otherwise>
                                        <xsl:value-of select="$internlang" />
                                </xsl:otherwise>
				
			</xsl:choose>
		</xsl:variable> 
                <ONIXmessage 
			xmlns="http://www.editeur.org/onix/2.1/short"			
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.editeur.org/onix/2.1/short/ONIX_BookProduct_2.1_short.xsd" 
			release="2.1">
			<header>
				<m174 refname="FromCompany">Universitätsverlag Göttingen</m174>
				<m283 refname="FromEmail">univerlag@uni-goettingen.de</m283>
				<m182 refname="SentDate">
					<xsl:value-of select="date:format-date(date:date(), 'yyyyMMdd')" />
				</m182>
			</header>
			<product>
				<a001 refname="RecordReference">
					<xsl:choose>
						<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']">
							<xsl:value-of select="concat(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value'], '0')" />							
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>XXXXXX0</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</a001>
				<a002 refname="NotificationType">01</a002>


				<!-- CL 5: 01. propr. articelnumber, 02 ISBN-10, 06 DOI, 15 ISBN-13, 22 URN -->
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']">
				<productidentifier>
				<!--	<ProductIDType> -->
					<b221>01</b221>
					<!-- for propr. type only -->
					<!-- <IDValue> -->
					<b244>
						<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='articlenumber']/doc:element/doc:field[@name='value']" />
					</b244>
				</productidentifier>
				</xsl:if>


                                <!-- DOI -->
                                <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
                                <productidentifier>
                                        <b221>06</b221>
					<b244>
                                                <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']" />
                                        </b244>
                                </productidentifier>
                                </xsl:if>

				

				<!-- URN -->
                                <xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
                                <productidentifier>
                                        <b221>22</b221>
                                        <b244>
                                                <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']" />
                                        </b244>
                                </productidentifier>
                                </xsl:if>
		
				<!-- <ProductForm> CL 7: Audio, CD-ROM, Hardback, Paperback ... -->	
				<b012>DH</b012>
				<b211>002</b211>


				<!-- series -->
			 	<!--	<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='issn'][1]/doc:element/doc:field[@name='value']" > -->
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartofseries']/doc:element/doc:field[@name='value']" >
					<series>
						<!-- <SeriesIDType> CL 13: 02 ISSSn, 01 Proprietary, 06 DOI ... -->						
						<!-- <b273>02</b273> -->
						<!-- <IDValue> -->
						<!-- <b244>
							<xsl:value-of select="." />
						</b244> -->
						<!-- <TitleOfseries> -->
						<b018>
							<xsl:value-of select="." />
						</b018>
						<xsl:if test="//doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']">
						<!-- <NumberWithinSeries> -->
						<b019>
							<xsl:value-of select="//doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field[@name='value']" />
						</b019>
						</xsl:if>
					</series>
				</xsl:for-each> 

				<!-- multipart publications with or  without volume title -->
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='multipart']/doc:element/doc:field[@name='value']" >
                                        <set>
                                                <!-- <TitleOfSet> -->                    
                                                <b023>
							<xsl:choose>
								<xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='ispartof']/doc:element/doc:field[@name='value']">
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']" />
								</xsl:otherwise>
							</xsl:choose>
						</b023>
					<!-- <ItemNumberWithinSet> -->
                                                <b026>
                                                        <xsl:value-of select="." />
                                                </b026>
                                                <!-- <SetItemTitle> -->
                                                <b281>
                                                        <xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']" />
                                                </b281>
                                        </set>
                                </xsl:for-each>

				<!-- Title -->
				<!-- TitleType: CL 15 - 01.distinctive title, 11 alternative title appearing on the cover, 14 alternative title whether it appears on the book or not. 
				TitleElementLevel: CL 149 - 01. individual product -->
				<title>	
				<!--	<TitleType> -->
					<b202>01</b202>
				<!--			<TitlePrefix language=”ger”>Der</TitlePrefix>
							<TitleWithoutPrefix>Haupttitel</TitleWithoutPrefix> -->
				<!--			<TitleText> -->
							 <b203>
								<xsl:attribute name="language"><xsl:value-of select="$lang" /></xsl:attribute> 
								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']" /> 
							</b203>
							<!-- non-repeatable -->
							<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']">
							<!-- <Subtitle> -->
							<b029>
 								<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='alternative']/doc:element/doc:field[@name='value']" />
							</b029>
							</xsl:if>
				</title>


				<!-- author, editor 
				Role: CL 17 - A01 author -->
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
					<contributor>

				<!--	<SequenceNumber> -->
						<b034><xsl:value-of select="position()" /></b034> 
				<!--		<ContributorRole> -->
						<b035>A01</b035>
				<!-- <PersonNameInverted> -->
						<b037><xsl:value-of select="." /></b037>
				<!--		<NamesBeforeKey> -->
						<b039><xsl:value-of select="normalize-space(substring-after(., ','))" /></b039>
				<!--		<KeyNames> -->
						<b040><xsl:value-of select="substring-before(., ',')" /></b040>
					</contributor>
				</xsl:for-each>
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field[@name='value']">
                                        <contributor>
	                                        <b034><xsl:value-of select="position()" /></b034> 
                                                <b035>B01</b035>
                                                <b039><xsl:value-of select="normalize-space(substring-after(., ','))" /></b039>
                                                <b040><xsl:value-of select="substring-before(., ',')" /></b040>
                                        </contributor>
                                </xsl:for-each>

				<!-- contributor other !!! -->
		

				<!-- edition type
				Type Code: CL 21 - BLL bilingual edition, MLL multilingual edition, NED new edition, ENH enhanced with text, speech, video etc., 
				ENL enlarged content, REV revised -->
			
				<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']/doc:element/doc:field[@name='value']">	
				
				<!--		<EditionTypeCode> -->
					<b056>???</b056>
				<!--	<EditionNumber> -->
					<b057><xsl:value-of select="substring-before(doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']/doc:element/doc:field[@name='value'], '.')" /></b057>
	
				<!--	<EditionStatement> -->
					<b058><xsl:value-of select="substring-after(doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='edition']/doc:element/doc:field[@name='value'], '.')" /></b058>
				</xsl:if>	

				<!-- language 
				Role: CL 22 - 01. language of text, 03 lang of abstract, 08 lang of audio track 
				Code: CL 74 - ISO 638-2/B -->

				<language>
				<!--	<LanguageRole> -->
					<b253>01</b253> 
				 <!--	<LanguageCode> -->
					<b252><xsl:value-of select="$lang" /></b252> 
				</language>

				<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
                        	<xsl:for-each select="../doc:element[@name='bitstreams']/doc:element">
				<extent>
					<!-- <ExtentType> CL: 23 - 22 Filesize -->
					<b218>22</b218>
					<!-- <ExtentValue> -->
					<b219><xsl:value-of select="doc:field[@name='size']/text()" /></b219>
					<!-- <ExtentUnit>: CL 24 - 17. Bytes, 18. Kbytes, 19. Mbytes -->
					<b220>17</b220>
				</extent>
				</xsl:for-each>
				</xsl:for-each>	

				<!-- main subject -->
				<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='vlb']/doc:element/doc:field[@name='value']">
				<mainsubject>
					<!-- schema identifier: codelist 26, value26 = 	Warengruppen-Systematik des deutschen Buchhandels -->
					<b191>26</b191>
					<!-- subject version -->
					<b068>2.0</b068>
					<!-- subject code -->
					<b069><xsl:value-of select="." /></b069>
				</mainsubject>
				</xsl:for-each>

				<!-- ProductWebsite mandatory for DNB- Transfer 
				Role: CL 73 - 01 Publisher's corporate website -->
				<!-- requested by DNB -->
				
				<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
                                	<xsl:for-each select="../doc:element[@name='bitstreams']/doc:element/doc:field[@name='url']">	
				<productwebsite>
				<!--	<WebsiteRole> -->
					<b367>31</b367> 
				<!-- <ProductWebsiteDescription>  -->
				<!--	<ProductWebsiteLink> -->
				<f123><xsl:value-of select="."/></f123>
				<!-- <f123><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']" /> </f123> -->
				</productwebsite>
					</xsl:for-each>
				</xsl:for-each>
				
                                <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field">
				<productwebsite>
					<b367>02</b367>
					<f123><xsl:value-of select="."/></f123>
				</productwebsite>
				</xsl:for-each>
	

				<!-- publisher 
				Role: CL 45 - 01. Publisher -->
				<publisher>	
				<!--	<PublishingRole> -->
					<b291>01</b291>
				<!-- 	<PublisherName> -->
					<b081>Universitätsverlag Göttingen</b081> 
				</publisher>	


				<!-- <CityOfPublication> -->
				<b209>Göttingen</b209>
				<!-- <PublicationDate> -->
				<b003><xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']" /></b003>


                                <!-- mandatory in: <SupplierName> or supplier id (EAN-13 location number = EAN-UCC Global Location Number) -->
                                <supplydetail>
                                <!-- <SupplierEANLocationNumber> ??? -->
                                <j135>X13</j135>
					<price>
						<!-- <PriceTypeCode>: CL 58 - with and without tax etc. ??? -->
	                                        <j148>02</j148>
        	                                <!-- opt: <PriceQualifier> : reduced when..., member price...; <PriceTypeDescritpion> Free text: When purchased as part of a three-item set with ..., <MinimumOrderQuantity>  -->
                	                        <!-- <PriceAmount> -->
                        	                <j151>00.00</j151>
						<!-- <CurrencyCode> -->
	                                        <j152>EUR</j152>
        	                                <!-- <CountryCode> -->
                	                        <b251>DE</b251>
					</price>
					                                <!-- ProductAvailability>: CL 65 - 20 available, 31 out of stock, 40 not availabe (reason unspec.), 42 Not availabe, other format available ...  -->
                                <j396>
                                <!-- notes.access possible values: "notavailable", "outofstock", http.... -->
                                <xsl:choose>
                                   <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='notes']/doc:element[@name='access']/doc:element/doc:field[@name='value']">
                                        <xsl:choose>
                                                <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='notes']/doc:element[@name='access']/doc:element/doc:field[@name='value'] = 'notavailable'">
                                                        <xsl:text>40</xsl:text>
                                                </xsl:when>
                                                <xsl:when test="doc:metadata/doc:element[@name='dc']/doc:element[@name='notes']/doc:element[@name='access']/doc:element/doc:field[@name='value'] = 'outofstock'">
                                                        <xsl:text>31</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                <!-- URL: available from third party -->
                                                        <xsl:text>????</xsl:text>
                                                </xsl:otherwise>
                                        </xsl:choose>

                                   </xsl:when>
                                   <xsl:otherwise>
                                        <xsl:text>20</xsl:text>
                                   </xsl:otherwise>
                                </xsl:choose>
                                </j396>
	                        </supplydetail>
			</product>
		</ONIXmessage>
	</xsl:template>
</xsl:stylesheet>
