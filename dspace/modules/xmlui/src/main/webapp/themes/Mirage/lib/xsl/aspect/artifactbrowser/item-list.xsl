<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->



    <xsl:template name="itemSummaryList-DIM">
       <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>


        <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/>
        <xsl:choose>
            <xsl:when test="'file' = $emphasis">

                <div class="item-wrapper clearfix">
                    <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                    <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                         mode="itemSummaryList-DIM-file"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-file">
        <xsl:param name="href"/>
        <xsl:variable name="metadataWidth" select="575 - $thumbnail.maxwidth - 30"/>
        <div class="item-metadata" style="width: {$metadataWidth}px;">
            <!-- <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.title</i18n:text><xsl:text>:</xsl:text></span> -->
             <!-- <span class="content" style="width: {$metadataWidth - 110}px;">  -->
	    <span class="content" style="width: {$metadataWidth - 10}px;">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title' and descendant::text()]">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
			    <xsl:if test="//dim:field[@element='title'][@qualifier='part']">
				<xsl:text>, </xsl:text><xsl:value-of select="//dim:field[@element='title'][@qualifier='part']"/>
			    </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </span>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
	    <!-- <xsl:if test="dim:field[@element='title'][@qualifier='alternative']">
	    <span class="content"  style="width: {$metadataWidth - 110}px;">

                               <xsl:value-of select="dim:field[@element='title'][@qualifier='alternative']" />
	     </span>
            </xsl:if> -->

            <!-- <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.author</i18n:text><xsl:text>:</xsl:text></span> -->
            <!-- <span class="content-bold" style="width: {$metadataWidth - 110}px;">  -->
	    <span class="content-bold">
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:if test="@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            <!-- <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0"> -->
			    <xsl:if test="position() != last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='editor']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                            <xsl:copy-of select="node()"/>
			    <xsl:if test="position() != last()">
				<xsl:text>; </xsl:text>
			    </xsl:if>
                        </xsl:for-each>
			<i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                <!-- <span class="bold"><i18n:text>xmlui.dri2xhtml.pioneer.date</i18n:text><xsl:text>:</xsl:text></span> -->
                <!-- <span class="content" style="width: {$metadataWidth - 110}px;"> -->
		<span class="date" style="width: {$metadataWidth - 40}px;">
                    <xsl:value-of
                            select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                </span>
            </xsl:if>
	    <!-- <xsl:if test="dim:field[@element='relation' and @qualifier='ispartofseries']">
		<span class="date" style="width: {$metadataWidth - 40}px;">
                    <xsl:value-of
                            select="dim:field[@element='relation' and @qualifier='ispartofseries']"/>
                </span>
	    </xsl:if> -->
                  <xsl:if test="//dim:field[@element='relation'  and starts-with(@qualifier,'isbn')]">
                                <xsl:if test="//dim:field[@element='relation' and @qualifier='isbn-13']">
					<span class="isbn">
                                                <xsl:text>ISBN13: </xsl:text><xsl:value-of select="//dim:field[@element='relation' and @qualifier='isbn-13']"/>
					</span>
                                </xsl:if>
				<xsl:if test="//dim:field[@element='relation' and @qualifier='isbn']">
				
				<span class="isbn">
                                                <xsl:text>ISBN10: </xsl:text><xsl:value-of select="//dim:field[@element='relation' and @qualifier='isbn']"/>
				</span>
                                </xsl:if>
		</xsl:if>

	    <xsl:if test="dim:field[@element='description' and @qualifier='print']">
		<xsl:for-each select="dim:field[@element='description' and @qualifier='print']">
		    <xsl:variable name="print"><xsl:value-of select="."/></xsl:variable>
		    <xsl:variable name="desc">
			<xsl:choose>
				<xsl:when test="contains($print, '(ISBN')">
					<xsl:value-of select="substring-before($print, '(')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$print"/>
				</xsl:otherwise>
			</xsl:choose>
		   </xsl:variable>

					<span class="desc"><xsl:value-of select="$desc"/></span>
					<span>
					<xsl:choose>
						<xsl:when test="contains(//dim:field[@element='notes' and @qualifier='print'], 'amazon')">	
							<xsl:attribute name="class"><xsl:text>access amazon</xsl:text></xsl:attribute>
								<a target="_blank">
								<xsl:attribute name="href"><xsl:value-of select="//dim:field[@element='notes' and @qualifier='print']"/></xsl:attribute>
							<i18n:text>xmlui.item.amazon.order</i18n:text>
							</a>
						</xsl:when>
				                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='print'], 'vergriffen')">
							<xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>                       				    <i18n:text>xmlui.item.outofstock</i18n:text>
				                </xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
							<a>
							<xsl:attribute name="href">
                                                                                <xsl:value-of select="substring-after(//mets:METS/@OBJEDIT,'/admin/item')" />
                                                        </xsl:attribute>
							<i18n:text>xmlui.item.print.order</i18n:text></a>
						</xsl:otherwise>
					</xsl:choose>
					</span>
	       </xsl:for-each>
		
	    </xsl:if> 
	    <xsl:for-each select="dim:field[@element='description' and @qualifier='cdrom']">
			<xsl:variable name="print"><xsl:value-of select="."/></xsl:variable>
                    <xsl:variable name="desc">
                        <xsl:choose>
                                <xsl:when test="contains($print, '(ISBN')">
                                        <xsl:value-of select="substring-before($print, '(')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:value-of select="$print"/>
                                </xsl:otherwise>
                        </xsl:choose>
                   </xsl:variable>
		   <!-- <xsl:if test="//dim:field[starts-with(@qualifier, 'isbn')]">
  		   <span class="isbn">
			<xsl:choose>
                                <xsl:when test="//dim:field[@qualifier='isbn-13']">
                                        <xsl:value-of select="//dim:field[@qualifier='isbn-13']"/>
                                </xsl:when>
                                <xsl:when test="//dim:field[@qualifier='isbn']">
                                        <xsl:value-of select="//dim:field[@qualifier='isbn']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:text> </xsl:text>
                                </xsl:otherwise>
                        </xsl:choose>
		   </span>
		   </xsl:if> -->
		   <span class="desc"><xsl:value-of select="$desc"/></span>
		   <span>
		   	<xsl:choose>
                                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='cdrom'], 'vergriffen')">
                                                     <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                                     <i18n:text>xmlui.item.outofstock</i18n:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
                                                        <a>
							<xsl:attribute name="href">
                                                                                <xsl:value-of select="substring-after(//mets:METS/@OBJEDIT,'/admin/item')" />
                                                        </xsl:attribute>
							<i18n:text>xmlui.item.cdrom.order</i18n:text></a>
                                                </xsl:otherwise>
                                        </xsl:choose>
		   </span>
	    </xsl:for-each>
	    <xsl:for-each select="dim:field[@element='description' and @qualifier='dvd']">
		    <!-- <span class="isbn">DVD-Video</span> -->
                   <span class="desc"><xsl:value-of select="."/></span>
			
                   <span>
			<xsl:choose>
                                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='dvd'], 'vergriffen')">
                                                     <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                                     <i18n:text>xmlui.item.outofstock</i18n:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
                                                        <a>
							<xsl:attribute name="href">
                                                                                <xsl:value-of select="concat('#&amp;', substring-after(//mets:METS/@OBJEDIT,'/admin/item?'))" />
                                                        </xsl:attribute>
							<i18n:text>xmlui.item.dvd.order</i18n:text></a>
                                                </xsl:otherwise>
                          </xsl:choose>
		     </span>
            </xsl:for-each>

		<!-- fetch file infos -->
		<xsl:variable name="externalMetadataUrl">
	                <xsl:text>cocoon://metadata/handle/</xsl:text>
        	        <xsl:value-of select="substring-after(//dim:field[@element='identifier'][@qualifier='uri'], 'handle/')"/>
                	<xsl:text>/mets.xml</xsl:text>
	        </xsl:variable>

	    <xsl:variable name="metsDoc" select="document($externalMetadataUrl)/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']"/>

	     <xsl:for-each select="$metsDoc/mets:file[1]">	
		<!-- Do not show description if file is not free or no files atteched -->
		<xsl:choose>
		<xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n') or (mets:FLocat[@LOCTYPE='URL']/@xlink:label = 'Dummy')">
			<!-- do nothing -->
		</xsl:when>
		<xsl:otherwise>
			<span class="desc">
			<xsl:choose>
        	                <xsl:when test="mets:FLocat/@xlink:label != ''">
                	            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                        	</xsl:when>
	                        <xsl:otherwise>
        	                        <i18n:text>xmlui.item.online.version</i18n:text><xsl:text>, PDF (</xsl:text>
                	                <xsl:choose>
                        	            <xsl:when test="@SIZE &lt; 1024">
                                	        <xsl:value-of select="@SIZE"/>
                                        	<i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
	                                    </xsl:when>
        	                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                	                        <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                        	                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                                	    </xsl:when>
	                                    <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
        	                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                	                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                        	            </xsl:when>
                                	    <xsl:otherwise>
                                        	<xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
	                                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
        	                            </xsl:otherwise>
                	                </xsl:choose>
                        	        <xsl:text>)</xsl:text>
	                        </xsl:otherwise>
        	              </xsl:choose>
			</span>
			<span class="access"> 
				<xsl:attribute name="class"><xsl:text>access doc</xsl:text></xsl:attribute>
				<a href="{mets:FLocat/@xlink:href}"><i18n:text>xmlui.item.access.document</i18n:text></a></span>
		</xsl:otherwise>
		
		</xsl:choose>
		
	     </xsl:for-each>
	     <!-- sometimes there are more files. Handle them to -->
                <xsl:for-each select="$metsDoc/mets:file[position() &gt; 1]">
                <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=y')">
                        <span class="desc">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                                <xsl:text> (</xsl:text>
                                <xsl:choose>
                                            <xsl:when test="@SIZE &lt; 1024">
                                                <xsl:value-of select="@SIZE"/>
                                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                                            </xsl:when>
                                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                                            </xsl:when>
                                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                                            </xsl:otherwise>
                                 </xsl:choose>
                                <xsl:text>)</xsl:text>
                        </span>
                        <span class="access doc">
                                <a>
                                        <xsl:attribute name="href"><xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" /></xsl:attribute><i18n:text>xmlui.item.access.document</i18n:text>
                                </a>
                        </span>
                   </xsl:if>
                </xsl:for-each> 
        </div>
    </xsl:template>

    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <div class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title' and descendant::text()]">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            <xsl:if test="//dim:field[@element='title'][@qualifier='part']">
                                <xsl:text>, </xsl:text><xsl:value-of select="//dim:field[@element='title'][@qualifier='part']"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
            </div>
            <div class="artifact-info">
                <span class="author">
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                  <xsl:if test="@authority">
                                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                  </xsl:if>
                                  <xsl:copy-of select="node()"/>
                                </span>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='creator']">
                            <xsl:for-each select="dim:field[@element='creator']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor']">
                            <xsl:for-each select="dim:field[@element='contributor']">
                                <xsl:copy-of select="node()"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                    <xsl:text>; </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
	                <span class="publisher-date">
	                    <xsl:if test="dim:field[@element='publisher']">
	                        <span class="publisher">
	                            <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
	                        </span>
	                        <xsl:text>, </xsl:text>
	                    </xsl:if>
	                    <span class="date">
	                        <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
	                    </span>
	                </span>
                </xsl:if>
            </div>
            <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <!-- <div class="thumbnail-wrapper" style="width: {$thumbnail.maxwidth}px;"> -->
	<div class="thumbnail-wrapper">
            <div class="artifact-preview">
                <a class="image-link" href="{$href}">
                    <xsl:choose>
                        <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                            <img alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of
                                            select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img alt="Icon" src="{concat($theme-path, '/images/mime.png')}" style="height: {$thumbnail.maxheight}px;"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </div>
        </div>
    </xsl:template>


</xsl:stylesheet>
