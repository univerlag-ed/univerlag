<?xml version="1.0" encoding="UTF-8" ?>
<!-- 


    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/
    
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	>  http://www.loc.gov/standards/mets/mets.xsd
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:urn="http://www.d-nb.de/standards/urn/"
	xmlns:hdl="http://www.d-nb.de/standards/hdl/"
	xmlns:doi="http://www.d-nb.de/standards/doi/"
	xmlns:picaxml="info:srw/schema/5/picaXML-v1.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="info:srw/schema/5/picaXML-v1.0 http://www.oclcpica.org/xml/picaplus.xsd"
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:xlink="http://www.w3.org/TR/xlink/" 
	version="1.0">
    
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />

	<xsl:template match="/">
		<picaxml 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:doc="http://www.lyncode.com/xoai"
		xmlns:dc="http://purl.org/dc/elements/1.1/" 
		xmlns:dcterms="http://purl.org/dc/terms/" 
		xmlns="info:srw/schema/5/picaXML-v1.0" 
		xmlns:picaxml="info:srw/schema/5/picaXML-v1.0" 
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
		xsi:schemaLocation="info:srw/schema/5/picaXML-v1.0 http://www.oclcpica.org/xml/picaplus.xsd">
		
		<!-- save doctype, division and file size as global variable -->
		<xsl:variable name="doctype"><xsl:value-of select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[not(@name='version')]/doc:field/text()" /></xsl:variable>
		<xsl:variable name="division"><xsl:value-of select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='division']/doc:element/doc:field/text()" /></xsl:variable>
		<xsl:variable name="file">
					<xsl:for-each select="//doc:element[@name='bundles']/doc:element[@name='bundle']">
							<xsl:if test="doc:field[@name='name']/text() ='ORIGINAL'">
								<xsl:value-of select="doc:element[@name='bitstreams']/doc:element[@name='bitstream'][1]/doc:field[@name='size']" />
							</xsl:if>
					</xsl:for-each>
		</xsl:variable>
		
		<!-- <xsl:copy-of select="*" /> -->
		
		<!-- Handle only publications with printed books -->
		<xsl:if test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element[@name='medium']/doc:element/doc:field = 'Print' and not(//doc:metadata/doc:element[@name='dc']/doc:element[@name='notes']/doc:element[@name='access']/doc:element/doc:field = 'nodocument')">
			
			
		
		<datafield>
				<!-- possible type values: monograph, anthology, conference,  other 
				other is CD-ROM or DVD -->
                        <xsl:attribute name="tag">002@</xsl:attribute>
                        <subfield>			
								<xsl:attribute name="code">0</xsl:attribute>
								<xsl:variable name="type"><xsl:value-of select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element/doc:field/text()" /></xsl:variable>
								<xsl:variable name="code">
									<xsl:choose>
										<xsl:when test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='multipart']">
											<!-- Teil eines MBW description.multipart -->
											<xsl:text>f</xsl:text>
										</xsl:when>
										<xsl:when test="$doctype = 'monograph'">
											<xsl:text>a</xsl:text>
										</xsl:when>
										<xsl:when test="$doctype = 'anthology'">
											<xsl:text>a</xsl:text>
										</xsl:when>
									</xsl:choose>
								</xsl:variable>
								<!-- "u" for autopsie. -->
								<xsl:value-of select="concat('O', $code, 'u')" />			
                        </subfield>
                        
            </datafield>
         
		<!-- O - Online Resource +  Typkodierung: 
		a - Monographie
		b - Zeitschrift/Zeitung
		c - Gesamtaufnahme eines mehrbändigen Werkes
		d - Schriftenreihe
		e - Abteilung
		f - Teil eines mehrbändigen Werkes
		F - Teil eines mehrbändigen begrenzten Werkes
		s - unselbständiges Werk (Aufsatz, Rezension etc.)
		v - Bandsatz bei Zeitschriften/ zeitschr. Reihen
		z - keine Angabe + a - Erwerbungsdatensatz-->
		
		<!-- static RDA fields. What about CD-ROM, DVD ???-->
		
			<!-- O- and A-Records -->
			<datafield>
				<xsl:attribute name="tag">002C</xsl:attribute>
				<subfield>
					<xsl:attribute name="code">a</xsl:attribute>
					<xsl:text>Text</xsl:text>
				</subfield>
				<subfield>
					<xsl:attribute name="code">b</xsl:attribute>
					<xsl:text>txt</xsl:text>
				</subfield>			
			</datafield>
			
			<!-- O-Records only. A-Records with value: "a: ohne Hilfsmittel zu benutzen, b: n"-->
			<datafield>
				<xsl:attribute name="tag">002D</xsl:attribute>
				<subfield>
					<xsl:attribute name="code">a</xsl:attribute>
					<xsl:text>Computermedien</xsl:text>
				</subfield>
				<subfield>
					<xsl:attribute name="code">b</xsl:attribute>
					<xsl:text>c</xsl:text>
				</subfield>			
			</datafield>
			
			<!-- O-Records only. A-Records with value: "a: Band, b: nc"-->
			<datafield>
				<xsl:attribute name="tag">002E</xsl:attribute>
				<subfield>
					<xsl:attribute name="code">a</xsl:attribute>
					<xsl:text>Online-Ressource</xsl:text>
				</subfield>
				<subfield>
					<xsl:attribute name="code">b</xsl:attribute>
					<xsl:text>cr</xsl:text>
				</subfield>			
			</datafield>
		 <!-- </xsl:for-each> -->
		 
		 <xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='ppn']">
				<datafield>
                        <xsl:attribute name="tag">003@</xsl:attribute>
                         <subfield>
                        <xsl:attribute name="code">0</xsl:attribute>
                       	
								<xsl:value-of select="doc:element/doc:field/text()"/>
						</subfield>
				</datafield>
		 </xsl:for-each>
		 
		   
            <!-- identifiers -->
             <xsl:for-each select="//doc:element[@name='identifier']/doc:element">
				 
				 
				<!-- URN -->
				<xsl:if test="@name='urn'">
					<datafield>
                        <xsl:attribute name="tag">004U</xsl:attribute>
                        <subfield>			
								<xsl:attribute name="code">0</xsl:attribute>
								<xsl:value-of select="doc:element/doc:field[@name='value']/text()" />			
                        </subfield>
                </datafield>
				</xsl:if> 
				<xsl:if test="@name='doi'">
					<datafield>
                        <xsl:attribute name="tag">004V</xsl:attribute>
                        <subfield>			
								<xsl:attribute name="code">0</xsl:attribute>
								<xsl:value-of select="doc:element/doc:field[@name='value']/text()" />			
                        </subfield>
                </datafield>
				</xsl:if>
				
				<!-- isbn in A-records have not subfield "S" -->
				<xsl:if test="@name='isbn'">
					
					<datafield>
                        <xsl:attribute name="tag">00P</xsl:attribute>
                        <subfield>
									<xsl:attribute name="code">S</xsl:attribute>
									<xsl:text>p</xsl:text>
                        </subfield>
                        <subfield>							
									<xsl:attribute name="code">A</xsl:attribute>
									<xsl:value-of select="doc:element/doc:field[@name='value']/text()" />
                        </subfield>
					</datafield>           
				</xsl:if>
				<xsl:if test="@name='isbn-13'">
					
					<datafield>
                        <xsl:attribute name="tag">004P</xsl:attribute>
                        <subfield>
									<xsl:attribute name="code">S</xsl:attribute>
									<xsl:text>p</xsl:text>
                        </subfield>
                        <subfield>
									<xsl:attribute name="code">A</xsl:attribute>
									<xsl:value-of select="doc:element/doc:field[@name='value']/text()" />
                        </subfield>
					</datafield>           
				</xsl:if>		
						
				<!-- uri: handle -->
				<xsl:if test="@name='uri'">
					<datafield>
						<xsl:attribute name="tag">009P</xsl:attribute>
						<xsl:attribute name="occurence">03</xsl:attribute>
						<subfield>
							<xsl:attribute name="code">y</xsl:attribute>
							<xsl:text>Volltext</xsl:text>
						</subfield>
						<subfield>
							<xsl:attribute name="code">q</xsl:attribute>
							<xsl:text>text/html</xsl:text>
						</subfield>
						<subfield>
							<xsl:attribute name="code">a</xsl:attribute>
							<xsl:value-of select="doc:element/doc:field[@name='value']/text()" />
						</subfield>
						<subfield>
							<xsl:attribute name="code">4</xsl:attribute>
							<xsl:text>LF</xsl:text>
						</subfield>
					</datafield>      
				</xsl:if>
				
				<!-- direct links to documents -->
				<!-- <xsl:for-each select="//doc:metadata/doc:element[@name='bundles']/doc:element/doc:field[text()='ORIGINAL']">
					<xsl:for-each select="../doc:element[@name='bitstreams']/doc:element">
						<datafield>
							<xsl:attribute name="tag">009P</xsl:attribute>
							<xsl:attribute name="occurence">03</xsl:attribute>
							<subfield>
								<xsl:attribute name="code">y</xsl:attribute>
								<xsl:text>Volltext</xsl:text>
							</subfield>
							<subfield>
								<xsl:attribute name="code">q</xsl:attribute>
								<xsl:value-of select="doc:field[@name='format']/text()" />
							</subfield>
							<subfield>
								<xsl:attribute name="code">a</xsl:attribute>
								<xsl:value-of select="doc:field[@name='url']/text()" />
							</subfield>
						</datafield>     							
					</xsl:for-each>
				</xsl:for-each> 
				
			   -->   
			
				
			 </xsl:for-each>
			<!-- RDA Field for O- and A-Records -->
				<datafield>
					<xsl:attribute name="tag">010E</xsl:attribute>
					<subfield>
						<xsl:attribute name="code">e</xsl:attribute>
						<xsl:text>rda</xsl:text>
					</subfield>		
				</datafield> 
			
			<!-- Language: GVK requires ISO-639-2 Bibliographic [ger] -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
				<!-- do not export language "other" -->
				<xsl:if test="not(. = 'other')">
					<datafield>
						<xsl:attribute name="tag">010@</xsl:attribute>
						<subfield>
							<xsl:attribute name="code">a</xsl:attribute>							
								<xsl:value-of select="." />
						</subfield>
					</datafield>   
				</xsl:if>
			</xsl:for-each> 
			
			<!-- date issued: 1100 = 011@ handle year only -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element">

				<xsl:if test="@name='issued'">
				<xsl:variable name="date"><xsl:value-of select="doc:element/doc:field" /></xsl:variable>
					<datafield>
						<xsl:attribute name="tag">011@</xsl:attribute>
						<subfield>
							<xsl:attribute name="code">a</xsl:attribute>
							<xsl:choose>
								<xsl:when test="contains($date, '-')">
									<xsl:value-of select="substring-before($date, '-')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$date" />
								</xsl:otherwise>
							</xsl:choose>
						</subfield>
					</datafield>

					<!-- write exact date issue in order to support new record selection -->
					<datafield>
                                                <xsl:attribute name="tag">091O</xsl:attribute>
                                                <subfield>
                                                        <xsl:attribute name="code">t</xsl:attribute>
								<xsl:value-of select="$date" />
                                                </subfield>
                                        </datafield>
				</xsl:if>
			</xsl:for-each>
			
			

			
			<!-- Zugerhörige PPNs hinterlegen !!! -->
			
			
			
			
			<!-- title: 021A $a; alternative $d + $h author -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element">
				
				<!-- 013D 9: Verknüpfung 8: Hochschulschrift/Ausstellungskatalog/Bibliographie/Festschrift/Monographische Reiehe (BGV) ; ID: gnd/<nummer> -->
				<xsl:if test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='subtype']">
					<xsl:variable name="subtype"><xsl:value-of select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='subtype']/doc:element/doc:field/text()" /></xsl:variable>
					<xsl:choose>
						<xsl:when test="$subtype = 'catalog'">
							<datafield>
							<xsl:attribute name="tag">013D</xsl:attribute>
							<subfield>
								<xsl:attribute name="code">9</xsl:attribute>
								<xsl:text>10566491X</xsl:text>
							</subfield>
							<subfield>
								<xsl:attribute name="code">8</xsl:attribute>
								<xsl:text>Austellungskatalog</xsl:text>
							</subfield>
						</datafield>
						</xsl:when>
						<xsl:when test="$subtype = 'bibliography'">
						<datafield>
							<xsl:attribute name="tag">013D</xsl:attribute>
							<subfield>
								<xsl:attribute name="code">9</xsl:attribute>
								<xsl:text>104814519</xsl:text>
							</subfield>
							<subfield>
								<xsl:attribute name="code">8</xsl:attribute>
								<xsl:text>Bibliografie</xsl:text>
							</subfield>
						</datafield>
						</xsl:when>
						<xsl:when test="$subtype = 'thesis' or $subtype = 'habilitaion'">
						<datafield>
							<xsl:attribute name="tag">013D</xsl:attribute>
							<subfield>
								<xsl:attribute name="code">9</xsl:attribute>
								<xsl:text>105825778</xsl:text>
							</subfield>
							<subfield>
								<xsl:attribute name="code">8</xsl:attribute>
								<xsl:text>Hochschulschrift</xsl:text>
							</subfield>
						</datafield>
						</xsl:when>
					</xsl:choose>
				</xsl:if>
				
				<xsl:if test="$doctype = 'conference'">
					<datafield>
							<xsl:attribute name="tag">013D</xsl:attribute>
							<subfield>
								<xsl:attribute name="code">9</xsl:attribute>
								<xsl:text>10826484824</xsl:text>
							</subfield>
							<subfield>
								<xsl:attribute name="code">8</xsl:attribute>
								<xsl:text>Konferenzschrift</xsl:text>
							</subfield>
						</datafield>
				</xsl:if>
				<!-- Country Code: XA-DE-NI; Mandatory for GVK-Import -->
			
				<datafield>
					<xsl:attribute name="tag">019@</xsl:attribute>
					<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
						<xsl:text>XA-DE-NI</xsl:text>
					</subfield>
				</datafield>
				
				<!-- And now the title -->
				
				
				<xsl:if test="not(@name = 'alternative' or @name='translated' or @name='alternativeTranslated')">
					<datafield>
						<xsl:attribute name="tag">021A</xsl:attribute>
						<subfield>
							<xsl:attribute name="code">a</xsl:attribute>
							<xsl:value-of select="doc:field" />

						</subfield>
						<xsl:if test="../doc:element[@name='alternative']">
							<subfield>
								<xsl:attribute name="code">d</xsl:attribute>
								<xsl:value-of select="../doc:element[@name='alternative']/doc:element/doc:field/text()" />
							</subfield>
						</xsl:if>
						
						<subfield>
							<xsl:attribute name="code">h</xsl:attribute>
							<!-- mehrere authoren mit "und", "semikolon" ja nach Vorlage. Eckige Klammern sind hinzugefügte Daten, die nicht auf dem Cover stehen -->
							<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field">
								<xsl:variable name="person"><xsl:value-of select="." /></xsl:variable>
								<xsl:value-of select="normalize-space(substring-after($person, ','))" /><xsl:text> </xsl:text><xsl:value-of select="substring-before($person, ',')" />
								<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
								
							</xsl:for-each>
							
							<xsl:if test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']">
								<!-- <xsl:choose>
									<xsl:when test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']">
										<xsl:text> (Hg.) </xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>hrsg. von </xsl:text>
									</xsl:otherwise>
								</xsl:choose> -->
								
								
								<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field">
									<xsl:variable name="person"><xsl:value-of select="." /></xsl:variable>
									<xsl:value-of select="normalize-space(substring-after($person, ','))" /><xsl:text> </xsl:text><xsl:value-of select="substring-before($person, ',')" />
									<xsl:if test="position() != last()"><xsl:text> und </xsl:text></xsl:if>
								</xsl:for-each>
								<!-- <xsl:if test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']"> -->
									<xsl:text> (Hrsg.)</xsl:text>
								<!-- </xsl:if> -->
							</xsl:if>
							
							<!-- <xsl:value-of select="" /> -->
						</subfield>
					</datafield>
				</xsl:if>
			</xsl:for-each>
			
			<!-- Verfasser, 1. 028A und  2. 028B; Herausgeber, 028C; Andere beteiligte Personen 028C: Unterfelder $d Vorname, $a Familienname, $n Zählung?, $B Funktionsbezeichnung -->
			<!-- If name contains "von" => subfield c: "von" !!!!! -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field">
				<datafield>
					<xsl:choose>
						<xsl:when test="position() = 1">
							<xsl:attribute name="tag">028A</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
								<xsl:attribute name="tag">028B</xsl:attribute>
								/
						</xsl:otherwise>
					</xsl:choose>
					<xsl:variable name="author"><xsl:value-of select="." /></xsl:variable>
					<subfield>
					<xsl:attribute name="code">d</xsl:attribute>
						<xsl:value-of select="normalize-space(substring-after($author, ','))" />
					</subfield>
								
					<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
					<xsl:value-of select="normalize-space(substring-before($author, ','))" />
					</subfield>
					
				</datafield>
			</xsl:for-each>
			
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='editor']/doc:element/doc:field">
				<!-- Hochzählen editoren und sonstige Personen wie: occurrence-Attr. , $n subfield ??? -->
									<!-- attribute occurence -->	
					<xsl:variable name="author"><xsl:value-of select="." /></xsl:variable>
					
					
					
							<datafield>
					
								<xsl:attribute name="tag">028C</xsl:attribute>
								<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position() - 1)" /></xsl:attribute>
								<subfield>
								<xsl:attribute name="code">d</xsl:attribute>
									<xsl:value-of select="normalize-space(substring-after($author, ','))" />
								</subfield>
											
								<subfield>
									<xsl:attribute name="code">a</xsl:attribute>
								<xsl:value-of select="normalize-space(substring-before($author, ','))" />
								</subfield>
								
								<subfield>
									<xsl:attribute name="code">B</xsl:attribute>
									<xsl:text>HerausgeberIn</xsl:text>
								</subfield>
								<subfield>
									<xsl:attribute name="code">4</xsl:attribute>
									<xsl:text>edt</xsl:text>
								</subfield>
							</datafield>
						
							
			</xsl:for-each>
			
			
			
			<!-- 029F Körperschaft, wenn keine Konferenz (d.h. kein "event" vorhanden) 8: Name der Körperschaft   -->
			
							
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='corporation']/doc:element/doc:field">
				<!-- Hochzählen  wie: occurrence-Attr. , $n subfield ??? -->
									<!-- attribute occurence -->	
					<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position() - 1)" /></xsl:attribute>
							<xsl:if test="not(//doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='event'])">
								<datafield>					
									<xsl:attribute name="tag">029F</xsl:attribute>
									<subfield>
										<xsl:attribute name="code">8</xsl:attribute>
										<xsl:value-of select="." />
									</subfield>
								</datafield>
							</xsl:if>
			</xsl:for-each>
				
			<!-- 030F Körpeschaft mit "event". a: Bezeichnung der Konferenz j:Zählung???? k: Ort p:Datum  !!!muss auch immer 013D besetzt sein"
			Value: Workshop ; <numbering> <(Göttingen)> : 2006.09.27-29 -->
			
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='event']"> 
				<datafield>			
					<xsl:attribute name="tag">030F</xsl:attribute>
					<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
						<xsl:value-of select="substring-before(doc:element/doc:field/text(), ' ; ')" />
					</subfield>
					<xsl:variable name="numb-place"><xsl:value-of select="substring-after(substring-before(doc:element/doc:field/text(), ' : '), ' ; ')" /></xsl:variable>
					<xsl:choose>
						<xsl:when test="contains($numb-place, '(')">
							<xsl:if test="string-length(normalize-space(substring-before($numb-place, '('))) &gt; 0">
								<subfield>
									<xsl:attribute name="code">j</xsl:attribute>
									<xsl:value-of select="normalize-space(substring-before($numb-place, '('))" />
								</subfield>
							</xsl:if>
							<subfield>
								<xsl:attribute name="code">k</xsl:attribute>
									<xsl:value-of select="normalize-space(translate(substring-before($numb-place, ')'), '(', ''))" />
							</subfield>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="string-length(normalize-space($numb-place)) &gt; 0">
								<subfield>
									<xsl:attribute name="code">k</xsl:attribute>
									<xsl:value-of select="normalize-space($numb-place)" />
								</subfield>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>	
					<subfield>
						<xsl:attribute name="code">p</xsl:attribute>
						<xsl:value-of select="substring-after(doc:element/doc:field/text(), ' : ')" />
					</subfield>	
					
				</datafield>
				
			</xsl:for-each>
			
			
			<!-- for journal article only. 4070 = 031A Differenzierende Angaben zur Quelle Nur verwendbar mit 039B zusammen!!!!
			$d Band
			$e Heft
			$j Erscheinungsjahr
			$h firstP-lastP
			Beispiel: 
			031A	$d34$j2010$h203-238 -->
			
			
			<!-- Publisher and publisher place: $p Place, $n publisher name -->
			
					<datafield>
							<xsl:attribute name="tag">033A</xsl:attribute>
								<subfield>
										<xsl:attribute name="code">p</xsl:attribute>
										<xsl:text>Göttingen</xsl:text>

								</subfield>										
								<subfield>
										<xsl:attribute name="code">n</xsl:attribute>
										<xsl:text>Universitätsverlag</xsl:text>

								</subfield>

						</datafield>
		
			
			<!-- extent: 4060 = 034D -->
			<!-- O-Record only. File Size missing!!!
				A-Record "a: value "Seiten" -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='format']/doc:element">
				<xsl:if test="@name='extent'">
				
				<xsl:variable name="size">
					<xsl:choose>
						<xsl:when test="$file &lt; 1024">
							<xsl:value-of select="concat($file, ' B')"/> 
						</xsl:when>
                        <xsl:when test="$file &lt; 1024 * 1024">
							<xsl:value-of select="concat(translate(substring(($file div 1024),1,5), '.', ','),' KB')"/>
                        </xsl:when>
                        <xsl:when test="$file &lt; 1024 * 1024 * 1024">
							<xsl:value-of select="concat(translate(substring($file div (1024 * 1024),1,5), '.', ','),' MB')"/>
                       </xsl:when>
                       <xsl:otherwise>
							<xsl:value-of select="concat(translate(substring($file div (1024 * 1024 * 1024),1,5), '.', ','), ' GB')"/>
                       </xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<datafield>
					<xsl:attribute name="tag">034D</xsl:attribute>
					<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
						<xsl:value-of select="concat('1 Online-Ressource (PDF-Datei: ', doc:element/doc:field, ' S. ', $size, ')')" />
					</subfield>
				</datafield>
				</xsl:if>
			</xsl:for-each> 
			
			<!-- multivolume work will not be imported automatically-->
			
			
			<!-- 036D BBW Verlinkung mit übergeordnetem Werk händisch !!! -->
			<!-- Write "Universitätsdrucke as serie -->
			<!-- Why is there not 036F for Universiätsdrucke??? -->
			<xsl:if test="$division = 'surveyed'">
				<datafield>
					<xsl:attribute name="tag">036E</xsl:attribute>
					<xsl:attribute name="occurence"><xsl:text>00</xsl:text></xsl:attribute>
						<subfield>
								<xsl:attribute name="code">a</xsl:attribute>
								<xsl:text>Universiätsdrucke</xsl:text>
						</subfield>
				</datafield>
			</xsl:if>
			
			<!-- part of series: 036D, $a title, $l number -->
			<!-- make PPN of series available!!! -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element">
				<xsl:if test="@name='ispartofseries'">
				<xsl:variable name="volume">
					<xsl:choose>
						<xsl:when test="starts-with(//doc:metadata/doc:element[@name='dc']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field/text(), '0')">
						<xsl:value-of select="substring(//doc:metadata/doc:element[@name='dc']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field/text(), 2)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='bibliographicCitation']/doc:element[@name='volume']/doc:element/doc:field/text()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>	
				<datafield>
					<xsl:attribute name="tag">036E</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$division = 'surveyed'">
							<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position())" /></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position() -1)" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					
							<subfield>
								<xsl:attribute name="code">a</xsl:attribute>
								<xsl:value-of select="doc:element/doc:field/text()" />
							</subfield>
							<subfield>
								<xsl:attribute name="code">l</xsl:attribute>
								<xsl:value-of select="$volume" />						
							</subfield>
											
				</datafield>
				<datafield>
					<xsl:attribute name="tag">036F</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$division = 'surveyed'">
							<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position())" /></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position() -1)" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<subfield>
								<xsl:attribute name="code">x</xsl:attribute>
								<xsl:value-of select="concat($volume, '00')" />
					</subfield>
							<!--<subfield>
								 <xsl:attribute name="code">9</xsl:attribute> -->
								<!-- PPN !!! -->
								<!-- <xsl:value-of select="" />						 -->
							<!--</subfield> -->
					<subfield>
								<xsl:attribute name="code">8</xsl:attribute>
								<xsl:value-of select="doc:element/doc:field/text()" />
					</subfield>
				 </datafield>
				</xsl:if>
			</xsl:for-each> 
			
			
			<!-- translated title -->
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element[@name='translated']">
			<datafield>
			<xsl:attribute name="tag">046C</xsl:attribute>
				<subfield>
				<xsl:attribute name="code">a</xsl:attribute>
					<xsl:value-of select="doc:element/doc:field" />
				</subfield>
			</datafield>
			</xsl:for-each> 


			<!-- Marker OAPEN, univdoc For O-Records only -->		
			
			
			<xsl:if test="//doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']">
				<datafield>
					<xsl:attribute name="tag">209O</xsl:attribute>
					<xsl:attribute name="occurence"><xsl:text>00</xsl:text></xsl:attribute>
						<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
							<xsl:text>univdoc</xsl:text>
						</subfield>
					</datafield>
			</xsl:if>
			
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='other']">
				
					<datafield>
					<xsl:attribute name="tag">209O</xsl:attribute>
					<xsl:attribute name="occurence"><xsl:value-of select="concat('0', position())" /></xsl:attribute>
						<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
							<xsl:value-of select="doc:element/doc:field" />
						</subfield>
					</datafield>
				
			</xsl:for-each>
			
			
			<!-- abstracts -->
			
			<xsl:for-each select="//doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element">
				<xsl:if test="contains(@name, 'abstract')">
					<datafield>
					<xsl:attribute name="tag">047I</xsl:attribute>
						<subfield>
						<xsl:attribute name="code">a</xsl:attribute>
							<xsl:variable name="head"><xsl:value-of select="substring(normalize-space(doc:element/doc:field), 1, 597)" /></xsl:variable>				
							<xsl:variable name="tail"><xsl:value-of select="substring(normalize-space(doc:element/doc:field), 598, 620)" /></xsl:variable>
							<xsl:value-of select="concat($head, substring-before($tail, ' '))"/>
							<xsl:if test="string-length(/doc:element/doc:field &gt; 597)">
									<xsl:text>...</xsl:text>
							</xsl:if>
						</subfield>
					</datafield>
				</xsl:if>
			</xsl:for-each>
		</xsl:if>	
		
		</picaxml>
	</xsl:template>
	
</xsl:stylesheet>
