<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

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
        xmlns:jstring="java.lang.String"
        xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
        xmlns:confman="org.dspace.core.ConfigurationManager"
        exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">

    <xsl:output indent="yes"/>

    <xsl:variable name="locale">
        <xsl:value-of select="//dri:metadata[@qualifier='currentLocale']" />
    </xsl:variable>

    <xsl:variable name="serie">
        <xsl:for-each select="//dri:reference[@type='DSpace Collection']">
            <xsl:if test="contains(./@url, '_series')">
                <xsl:value-of select="substring-after(substring-before(@url, '/mets.xml'), 'metadata')" />
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="handl">
        <xsl:value-of select="//dri:metadata[@element='request' and @qualifier='URI']" />
    </xsl:variable>

    <xsl:variable name="baseURL">
<!--         <xsl:value-of select="concat('//', //dri:metadata[@qualifier='serverName'], ':',//dri:metadata[@qualifier='serverPort'])" /> -->
	     <xsl:text>www.univerlag.uni-goettingen.de</xsl:text>
    </xsl:variable>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <!--<xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if> -->

        <xsl:call-template name="abstract" />
        <xsl:call-template name="itemSummaryView-collections"/>
    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <!-- <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates> -->
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">



            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-DOI"/>

                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>


                </div>
                <div class="col-sm-8">
                    <div class="primary-data page-header ">
                        <xsl:call-template name="itemSummaryView-DIM-title"/>
                        <xsl:call-template name="itemSummaryView-DIM-othertitle"/>
                        <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    </div>
                    <div class="secondary-data">
                        <xsl:call-template name="itemSummaryView-DIM-series"/>
                        <!-- <xsl:call-template name="itemSummaryView-DIM-edition"/> -->
                        <xsl:call-template name="itemSummaryView-DIM-date"/>
                        <!-- <span>
                            <xsl:call-template name="itemSummaryView-DIM-more"/>
                        </span> -->
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="itemSummaryView-DIM-format-section"/>
                    <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                    <!-- <xsl:call-template name="itemSummaryView-collections"/> -->

                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">

        <xsl:choose>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                <h2 class="page-header first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()" disable-output-escaping="yes"/>
                </h2>

                <div class="simple-item-view-other">
                    <p class="lead">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:if test="not(position() = 1)">
                                <xsl:value-of select="./node()" disable-output-escaping="yes"/>
                                <xsl:if test="count(following-sibling::dim:field[@element='title'][not(@qualifier)]) != 0">
                                    <xsl:text>; </xsl:text>
                                    <br/>
                                </xsl:if>
                            </xsl:if>

                        </xsl:for-each>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                <h2 class="first-page-header">
                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()" disable-output-escaping="yes"/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h2 class="page-header first-page-header">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                </h2>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="//dim:field[@element='volume'][not(@qualifier)]">
            <h2>
                <small>
                    <xsl:value-of select="//dim:field[@element='volume'][not(@qualifier)]" />
                    <xsl:if test="//dim:field[@element='title'][@qualifier='volume']">
                        <xsl:text>. </xsl:text><xsl:value-of select="//dim:field[@element='title'][@qualifier='volume']" />
                    </xsl:if>
                </small>
            </h2>
        </xsl:if>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-othertitle">
        <xsl:if test="dim:field[@element='title'][@qualifier='alternative']">
            <xsl:for-each select="dim:field[@element='title'][@qualifier='alternative']">
                <h3><xsl:value-of select="." disable-output-escaping="yes"/></h3>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="dim:field[@element='title'][@qualifier='translated']">
            <xsl:for-each select="dim:field[@element='title'][@qualifier='translated']">
                <h3><xsl:value-of select="." disable-output-escaping="yes"/></h3>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-events">
        <xsl:if test="//dim:field[@element='relation'][@qualifier='event']">
            <xsl:for-each select="//dim:field[@element='relation'][@qualifier='event']">
                <p class="event">
                    <xsl:value-of select="." />
                </p>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-edition">
        <xsl:if test="//dim:field[@element='description'][@qualifier='edition']">
            <xsl:value-of select="concat(//dim:field[@element='description'][@qualifier='edition'], '. ')"/>
        </xsl:if>
	<xsl:if test="//dim:field[@element='notes'][@qualifier='edition']">
            <xsl:value-of select="//dim:field[@element='notes'][@qualifier='edition']"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-series">
        <xsl:if test="dim:field[@element='relation'][@qualifier='ispartofseries']">
           
            <span class="relation">
                <a>
		<xsl:attribute name="href"><xsl:value-of select="$serie" /></xsl:attribute>
                    <xsl:value-of select="dim:field[@element='relation'][@qualifier='ispartofseries']" />
                </a>
		
                <xsl:choose>
                    <xsl:when test="starts-with(dim:field[@element='bibliographicCitation'][@qualifier='volume'], '00')">
                        <xsl:value-of select="concat('; ', substring(dim:field[@element='bibliographicCitation'][@qualifier='volume'], 3))"/>
                    </xsl:when>			
                    <xsl:when test="starts-with(dim:field[@element='bibliographicCitation'][@qualifier='volume'], '0')">
                        <xsl:value-of select="concat('; ', substring(dim:field[@element='bibliographicCitation'][@qualifier='volume'], 2))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('; ', dim:field[@element='bibliographicCitation'][@qualifier='volume'])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-more">
        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-division</i18n:text><xsl:text>: </xsl:text>
        <xsl:for-each select="dim:field[@element='subject'][@qualifier='division']">
            <i18n:text><xsl:value-of select="." /></i18n:text>
            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
        </xsl:for-each>
        <xsl:for-each select="dim:field[@element='language'][@qualifier='iso']">
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-language</i18n:text><xsl:text>: </xsl:text>
            <i18n:text><xsl:value-of select="." /></i18n:text>
            <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail"  id="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <img alt="Thumbnail">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$src"/>
                        </xsl:attribute>
                    </img>
                </xsl:when>
                <xsl:otherwise>
                    <img alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/100%x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>No Thumbnail</xsl:text>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
	<xsl:if test="//dim:field[@element='rights'][@qualifier='coverlicense']">
           <span id="coverlicense">
                <xsl:variable name="coverlicense"><xsl:value-of select="//dim:field[@element='rights'][@qualifier='coverlicense']"/></xsl:variable>
                <a rel="license"
                       href="{$coverlicense}"
                       alt="{$coverlicense}"
                       i18n:attr="title"
                       title="xmlui.item.license"
                    >
                        <i18n:text>xmlui.item.coverlicense</i18n:text>
                        <xsl:variable name="license"><xsl:value-of select="substring-before(substring-after($coverlicense, 'licenses/'), '/')" /></xsl:variable>
                        <xsl:variable name="cc-version"><xsl:value-of select="substring-before(substring-after($coverlicense, concat($license, '/')), '/')" /></xsl:variable>
                        <span class="license"><xsl:value-of select="concat(' CC ', $license, ' ', $cc-version)" /></span>

                    </a>
             </span>
         </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <h5 class="visible-xs"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
            <div class="itemView-authors">
                <xsl:choose>
	          <xsl:when test="dim:field[@element='contributor']">
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='author']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
			<br />
                    </xsl:if>
                    <xsl:if test="dim:field[@qualifier='editor']">
                        <xsl:for-each select="dim:field[@qualifier='editor']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='editor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
			    <xsl:text> </xsl:text>
                        </xsl:for-each>
                        <xsl:if test="not(//dim:field[@qualifier='corporation'])">
                            <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="dim:field[@qualifier='corporation']">
                        <xsl:for-each select="dim:field[@qualifier='corporation']">
                            <!-- <xsl:call-template name="itemSummaryView-DIM-authors-entry" /> -->
			    <xsl:value-of select="."/>
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor' and @qualifier='corporation']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
                    </xsl:if>
                    <xsl:if test="dim:field[@element='contributor'][@qualifier='other']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='other']">
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry" />
                            <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                    </xsl:if>
		  </xsl:when>
                  <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                  </xsl:otherwise>
                </xsl:choose>
            </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <nobr>
            <span>
                <xsl:if test="@authority">
                    <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                </xsl:if>
                <xsl:copy-of select="node()"/>
            </span>
            <xsl:choose>
                <xsl:when test="starts-with(@authority, 'orcid')">
                    <a target="_blank" href="{concat('//orcid.org/',substring-after(@authority, '/'))}" i18n:attr="title" title="xml.author.profile.orcid.label"><i class="icon-info-circled orcid"></i></a>
                </xsl:when>
                <xsl:when test="starts-with(@authority, 'gnd')">
                    <span class="gnd"><a target="_blank" href="{concat('//d-nb.info/',@authority)}" i18n:attr="title" title="xml.author.profile.dnb.label"><small><i class="icon-info-circled"></i></small></a></span>
                </xsl:when>
            </xsl:choose>
        </nobr>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:choose>
            <xsl:when test="not(contains(dim:field[@element='identifier' and @qualifier='uri'],'doi.org'))  and (dim:field[@element='type'] != 'bookPart')">
                <h4>
                    <a href="#" onclick="copyToClipboard('#pid')" i18n:attr="title" title="xmlui.dri2xhtml.METS-1.0.item-copyto-clipboard"><i class="icon-export"></i></a>

                    <strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text><xsl:text>: </xsl:text></strong>
                    <a id="pid">
                        <xsl:attribute name="href">
                            <xsl:copy-of select="dim:field[@element='identifier' and @qualifier='uri']"/>
                        </xsl:attribute>
                        <xsl:value-of select="//dim:field[@element='identifier' and @qualifier='uri']" />
                    </a>

                </h4>
<!-- 		<div data-badge-popover="right" data-badge-type="2" data-doi="${}" data-hide-no-mentions="true" class="altmetric-embed">
			 <xsl:attribute name="data-doi"><xsl:value-of select="substring-after(//dim:field[@element='identifier' and @qualifier='uri'], 'https://doi.org/')" /></xsl:attribute> 
		</div> -->
            </xsl:when>
            <xsl:otherwise>
                <div>&#160;</div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-DOI">
        <xsl:if test="contains(//dim:field[@element='identifier' and @qualifier='uri'], 'doi.org')">
            <h4 class="doi">
                <a href="#" onclick="copyToClipboard('#pid')" i18n:attr="title" title="xmlui.dri2xhtml.METS-1.0.item-copyto-clipboard"><i class="icon-export"></i></a>

                <strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-doi</i18n:text><xsl:text>: </xsl:text></strong>
                <br />
                <a id="pid">
                    <xsl:attribute name="href">
                        <xsl:value-of select="//dim:field[@element='identifier' and @qualifier='uri']"/>
                    </xsl:attribute>
                    <xsl:value-of select="//dim:field[@element='identifier' and @qualifier='uri']" />
                </a>
            </h4>
	 
        </xsl:if>
	 <a id="ds-stats" title="Statistics details">
                <xsl:attribute name="href"><xsl:value-of select="concat('/', $handl, '/statistics')"/></xsl:attribute>
                <span class="glyphicon glyphicon-stats"> </span>
                <!-- <span id="views"><i18n:text>xmlui.statistics.visits.views</i18n:text>: </span>
                <span id="downloads"> | <i18n:text>xmlui.statistics.visits.bitstreams</i18n:text>: </span> -->
                <span id="views">Views: </span>
		<xsl:if test="not(//dim:field[@element='notes' and @qualifier='access'] = 'nodocument')">
                	<span id="downloads"> | Downloads: </span>
		</xsl:if>
            </a>
	    <!-- <xsl:if test="contains(//dim:field[@element='identifier' and @qualifier='uri'], 'doi.org')">
		<div data-badge-details="right" data-badge-type="2" data-hide-no-mentions="true" class="altmetric-embed">
                         <xsl:attribute name="data-doi"><xsl:value-of select="substring-after(//dim:field[@element='identifier' and @qualifier='uri'], 'https://doi.org/')" /></xsl:attribute>
                    </div>
	    </xsl:if> -->
	    <xsl:choose>
		<xsl:when test="contains(//dim:field[@element='identifier' and @qualifier='uri'], 'doi.org')">
		
	            <div data-badge-details="right" data-badge-type="2" data-hide-no-mentions="true" class="altmetric-embed">
                         <xsl:attribute name="data-doi"><xsl:value-of select="substring-after(//dim:field[@element='identifier' and @qualifier='uri'], 'https://doi.org/')" /></xsl:attribute>
        	    </div>
		</xsl:when>
		<xsl:when test="//dim:field[@element='identifier' and @qualifier='doi']">
                    <div data-badge-details="right" data-badge-type="2" data-hide-no-mentions="true" class="altmetric-embed">
                         <xsl:attribute name="data-doi"><xsl:value-of select="//dim:field[@element='identifier' and @qualifier='doi']" /></xsl:attribute>
                    </div>
		</xsl:when>
	    </xsl:choose> 
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <span class="dateissued">
                <i18n:text>xmlui.dri2xhtml.item.dateissued</i18n:text><xsl:text>: </xsl:text>
                <xsl:copy-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                <!-- <xsl:if test="dim:field[@element='description'][@qualifier='edition']">
                    <xsl:value-of select="concat(' (', dim:field[@element='description'][@qualifier='edition'], ')')"/>
                </xsl:if> -->
            </span>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <span class="simple-item-view-show-full item-page-field-wrapper table">
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </span>
        <br />
        <span class="simple-item-view-show-full item-page-field-wrapper table">
            <a>
                <xsl:attribute name="href"><xsl:value-of select="concat('/metadata/' , $document//dri:metadata[@element='request' and @qualifier='URI'], '/mets.xml')"/></xsl:attribute>
                &#160;
            </a>
        </span>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5>
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-format-section">
        <!-- Print version existent -->
        <xsl:if test="dim:field[@element = 'format' and @qualifier='medium'] = 'Print'">
            <xsl:for-each select="dim:field[@element='description' and @qualifier='print']">
                <xsl:variable name="pos"><xsl:value-of select="position()"/></xsl:variable>

                <xsl:variable name="extent"><xsl:value-of select="../dim:field[@qualifier='extent'][position() = $pos]"/>
			<xsl:if test="../dim:field[@qualifier='extentpostfix'][position() = $pos]">
				<xsl:value-of select="concat(', ', ../dim:field[@qualifier='extentpostfix'][position() = $pos])"/>
			</xsl:if>
		</xsl:variable>
                <xsl:variable name="price">
                    <xsl:choose>
                        <xsl:when test="$locale = 'en'">
                            <xsl:value-of select="translate(../dim:field[@element='price' and @qualifier='print'][position() = $pos], ',', '.')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="../dim:field[@element='price' and @qualifier='print'][position() = $pos]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="descr">
                    <xsl:value-of select="../dim:field[@element='description' and @qualifier='print'][position() = $pos]"/>
                </xsl:variable>

                <div class="format">
                    <i class="icon-book-2"></i>
                    <i18n:text>xmlui.item.print.version</i18n:text><xsl:text> </xsl:text>
                    <xsl:if test="not($price = '-')">
                        <xsl:value-of select="concat($price, '&#160;€')" />
                    </xsl:if>
                    <span>
                        <xsl:choose>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'amazon')">
                                <xsl:attribute name="class"><xsl:text>access amazon</xsl:text></xsl:attribute>
                                <a target="_blank">
                                    <xsl:attribute name="href"><xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/></xsl:attribute>
                                    <i class="icon-amazon-1" aria-hidden="true"></i><xsl:text> </xsl:text> <i18n:text>xmlui.item.amazon.order</i18n:text>
                                </a>
                            </xsl:when>
                            <xsl:when test="starts-with(//dim:field[@element='notes' and @qualifier='printaccess'], 'http')">
                                <xsl:attribute name="class"><xsl:text>access amazon</xsl:text></xsl:attribute>
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/>
                                    </xsl:attribute>
                                    <i class="icon-link-ext" aria-hidden="true"></i><xsl:text> </xsl:text> <i18n:text>xmlui.item.publisher.order</i18n:text>
                                </a>
                            </xsl:when>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'http:')">
                                <xsl:attribute name="class"><xsl:text>access online</xsl:text></xsl:attribute>
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/>
                                    </xsl:attribute>
                                    <i class="icon-download-5"></i><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                                </a>
                            </xsl:when>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'outofstock')">
                                <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                <i class="icon-block"></i><i18n:text>xmlui.item.outofstock</i18n:text>
                            </xsl:when>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'notavailable')">
                                <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                <i18n:text>xmlui.item.notavailable</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
                                <xsl:attribute name="data-id"><xsl:value-of select="substring-after(//mets:METS/@OBJEDIT,'/admin/item?itemID=')" /></xsl:attribute>
                                <xsl:attribute name="data-contributor">
                                    <xsl:choose>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='author']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='author']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='editor']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='editor']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <!-- <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text> -->
					    <xsl:text> (eds.)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='other']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='other']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:attribute>

                                <xsl:attribute name="data-title"><xsl:value-of select="//dim:field[@element='title'][not(@qualifier)][1]" /></xsl:attribute>
                                <xsl:attribute name="data-amount"><xsl:value-of select="$price" /></xsl:attribute>
                                <xsl:attribute name="data-description"><xsl:value-of select="concat(. ,'; ', $extent, ' S.')" /></xsl:attribute>
                                <!-- <xsl:attribute name="data-amount"><xsl:value-of select="$price" /></xsl:attribute> -->
                                <xsl:attribute name="data-part">
                                    <xsl:choose>
                                        <xsl:when test="count(//dim:field[@element='description' and @qualifier='print']) &gt; 1">
                                            <xsl:text>print:</xsl:text><xsl:value-of select="position() -1" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>print</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <!-- <xsl:attribute name="data-shipping"><xsl:text>0</xsl:text></xsl:attribute> -->
                                <i class="icon-shopping-cart-1"></i> <i18n:text>xmlui.item.print.order</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                <div class="details">
                    <small><xsl:value-of select="concat($descr, '; ', $extent, ' ')" /><i18n:text>xmlui.item.info.pages</i18n:text></small>
                </div>

            </xsl:for-each>
        </xsl:if>


        <!-- CDROM format existent -->
        <xsl:if test="(//dim:field[@element='format' and @qualifier='medium'] = 'CD-ROM')">
            <xsl:for-each select="//dim:field[@element='description' and @qualifier='cdrom']">
                <xsl:variable name="pos"><xsl:value-of select="position()"/></xsl:variable>
                <xsl:variable name="desc">
                    <xsl:choose>
                        <xsl:when test="(. = '-')">
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(', ', .)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="price">
                    <xsl:choose>
                        <xsl:when test="(../dim:field[@element='price' and @qualifier='cdrom'][position() = $pos] = '-')">
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(': ', ../dim:field[@element='price' and @qualifier='cdrom'][position() = $pos], ' €')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <div class="format">
                    <i class="icon-cd"></i>&#160;
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="concat('CD-ROM ', $price)"/>

                    <span>
                        <xsl:choose>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='cdromaccess'], 'outofstock')">
                                <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                <i class="icon-block"></i>&#160; <i18n:text>xmlui.item.outofstock</i18n:text>
                            </xsl:when>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='cdromaccess'], 'http:')">
                                <xsl:attribute name="class"><xsl:text>access online</xsl:text></xsl:attribute>
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="//dim:field[@element='notes' and @qualifier='cdromaccess']"/>
                                    </xsl:attribute>
                                    <i class="icon-download-5"></i>&#160;  <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewContent</i18n:text>
                                </a>
                            </xsl:when>

                            <xsl:otherwise>
                                <xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
                                <xsl:attribute name="data-id"><xsl:value-of select="substring-after(//mets:METS/@OBJEDIT,'/admin/item?itemID=')" /></xsl:attribute>
                                <xsl:attribute name="data-contributor">
                                    <xsl:choose>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='author']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='author']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='editor']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='editor']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <!-- <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text> -->
						<xsl:text> (eds.)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='other']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='other']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:attribute>

                                <xsl:attribute name="data-title"><xsl:value-of select="//dim:field[@element='title'][not(@qualifier)][1]" /></xsl:attribute>
                                <xsl:variable name="price"><xsl:value-of select="//dim:field[@element='price' and @qualifier='cdrom'][position() = $pos]" /></xsl:variable>
                                <xsl:attribute name="data-amount"><xsl:value-of select="//dim:field[@element='price' and @qualifier='cdrom'][position() = $pos]" /></xsl:attribute>
                                <xsl:attribute name="data-part">
                                    <xsl:choose>
                                        <xsl:when test="count(//dim:field[@element='price' and @qualifier='cdrom']) &gt; 1">
                                            <xsl:text>cdrom:</xsl:text><xsl:value-of select="position() -1" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>cdrom</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <!-- <xsl:attribute name="data-shipping"><xsl:text>0</xsl:text></xsl:attribute> -->
                                <i class="icon-shopping-cart-1"></i> <i18n:text>xmlui.item.cdrom.order</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                <div class="details">
                    <xsl:if test=". != '-'">
                        <small><xsl:value-of select="."/></small>

                    </xsl:if>
                </div>
            </xsl:for-each>
        </xsl:if>

        <!-- DVD Format existent -->
        <xsl:if test="(//dim:field[@element='format' and @qualifier='medium'] = 'DVD')">
            <xsl:for-each select="//dim:field[@element='description' and @qualifier='dvd']">

                <xsl:variable name="pos"><xsl:value-of select="position()"/></xsl:variable>

                <xsl:variable name="price">
                    <xsl:choose>
                        <xsl:when test="(../dim:field[@element='price' and @qualifier='dvd'][position() = $pos] = '-')">
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(': ', ../dim:field[@element='price' and @qualifier='dvd'][position() = $pos], ' €')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <div class="format">
                    <i class="icon-cd"></i>
                    <xsl:text>&#160;</xsl:text>
                    <xsl:value-of select="concat('DVD-Video ', $price)"/>

                    <span>
                        <xsl:choose>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='dvdaccess'], 'outofstock')">
                                <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                <i class="icon-block"></i><xsl:text> </xsl:text> <i18n:text>xmlui.item.outofstock</i18n:text>
                            </xsl:when>
                            <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='dvdaccess'], 'http:')">
                                <xsl:attribute name="class"><xsl:text>access online</xsl:text></xsl:attribute>
                                <a target="_blank">
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="//dim:field[@element='notes' and @qualifier='dvdaccess']"/>
                                    </xsl:attribute>
                                    <i class="icon-download-5"></i><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                                </a>
                            </xsl:when>


                            <xsl:otherwise>
                                <xsl:attribute name="class"><xsl:text>access order</xsl:text></xsl:attribute>
                                <xsl:attribute name="data-id"><xsl:value-of select="substring-after(//mets:METS/@OBJEDIT,'/admin/item?itemID=')" /></xsl:attribute>
                                <xsl:attribute name="data-contributor">
                                    <xsl:choose>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='author']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='author']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='editor']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='editor']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                           <!--  <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text> -->
						<xsl:text> (eds.)</xsl:text>
                                        </xsl:when>
                                        <xsl:when test="//dim:field[@element='contributor'][@qualifier='other']">
                                            <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='other']">
                                                <xsl:value-of select="."/>
                                                <xsl:if test="position() != last()">
                                                    <xsl:text>; </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:attribute>

                                <xsl:attribute name="data-title"><xsl:value-of select="//dim:field[@element='title'][not(@qualifier)][1]" /></xsl:attribute>
                                <xsl:variable name="price"><xsl:value-of select="//dim:field[@element='price' and @qualifier='dvd'][position() = $pos]" /></xsl:variable>
                                <xsl:attribute name="data-amount"><xsl:value-of select="//dim:field[@element='price' and @qualifier='dvd'][position() = $pos]" /></xsl:attribute>
                                <xsl:attribute name="data-part">
                                    <xsl:choose>
                                        <xsl:when test="count(//dim:field[@element='price' and @qualifier='dvd']) &gt; 1">
                                            <xsl:text>dvd:</xsl:text><xsl:value-of select="position() -1" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>dvd</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <i class="icon-shopping-cart-1"></i> <i18n:text>xmlui.item.dvd.order</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                </div>
                <xsl:if test="(. != '-')">
                    <div class="details">
                        <small><xsl:value-of select="concat(., ' Min.')" /></small>

                    </div>
                </xsl:if>


            </xsl:for-each>
        </xsl:if>
        <!--<xsl:if test="dim:field[@element = 'notes' and @qualifier='access'] = 'nodocument'">
            <div class="format">
               <i18n:text>xmlui.item.online.version</i18n:text>
                <span class="access"><i18n:text>xmlui.item.nodocument</i18n:text></span>
            </div>
        </xsl:if>-->
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">

        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">

                <xsl:variable name="label-1">
                    <xsl:choose>
                        <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                            <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>label</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="label-2">
                    <xsl:choose>
                        <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                            <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>title</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">

                    <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=y') or //dri:userMeta[@authenticated='yes']">

                        <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                            <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                            <xsl:with-param name="mimetype" select="@MIMETYPE" />
                            <xsl:with-param name="label-1" select="$label-1" />
                            <xsl:with-param name="label-2" select="$label-2" />
                            <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                            <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                            <xsl:with-param name="size" select="@SIZE" />
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>

            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <div class="format">
            <xsl:call-template name="getFileIcon">
                <xsl:with-param name="mimetype">
                    <xsl:value-of select="substring-before($mimetype,'/')"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="substring-after($mimetype,'/')"/>
                </xsl:with-param>
            </xsl:call-template>
	    <a>
		<xsl:attribute name="href"><xsl:value-of select="concat('/bitstream/handle/3/', substring-before(substring-after($href, '3/'), 'isAllow'))"/></xsl:attribute>
            <i18n:text>xmlui.item.online.version</i18n:text>
	    </a>
            <span class="access">
		<xsl:choose>
		<xsl:when test="contains($href, '.pdf')">
	
		<a data-fancybox="" data-type="iframe" >
                        <xsl:attribute name="data-src">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after($href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after($href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
			<img title="You can annotate the opened document." id="hp" src="/dokumente/images/hypthesis_Symbol_bl.jpg"/>
			<i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
		</xsl:when>
		<xsl:otherwise>
		
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>

                    <i class="icon-download-5"></i><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>

                </a>
		</xsl:otherwise>
	     </xsl:choose>
            </span>
        </div>
        <div class="details">
            <small>
                <xsl:choose>
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        !-- <xsl:value-of select="$title"/>  -->
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <xsl:value-of select="$label"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <!-- <xsl:value-of select="$title"/> -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text><i18n:text>xmlui.dri2xhtml.mimetype.<xsl:value-of select="$mimetype"/></i18n:text><xsl:text> </xsl:text>

                <xsl:choose>
                    <xsl:when test="@SIZE &lt; 1024">
                        <xsl:value-of select="@SIZE"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1024 * 1024">
                        <xsl:choose>
                            <xsl:when test="$locale='de'">
                                <xsl:value-of select="translate(substring(string(@SIZE div 1024),1,5), '.', ',')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                        <xsl:choose>
                            <xsl:when test="$locale='de'">
                                <xsl:value-of select="translate(substring(string(@SIZE div (1024 * 1024)),1,5), '.', ',')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$locale='de'">
                                <xsl:value-of select="translate(substring(string(@SIZE div (1024 * 1024 * 1024)),1,5), '.', ',')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                            </xsl:otherwise>
                        </xsl:choose>

                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:if test="//dim:field[@element='rights'][@qualifier='uri']">

                    <!-- <div class="col-sm-3 col-xs-12"> -->
                    <a rel="license"
                       href="{//dim:field[@element='rights'][@qualifier='uri']}"
                       alt="{//dim:field[@element='rights'][@qualifier='uri']}"
                       i18n:attr="title"
                       title="xmlui.item.license"
                    >
                        <xsl:variable name="license"><xsl:value-of select="substring-before(substring-after(//dim:field[@element='rights'][@qualifier='uri'], 'licenses/'), '/')" /></xsl:variable>
                        <xsl:variable name="cc-version"><xsl:value-of select="substring-before(substring-after(//dim:field[@element='rights'][@qualifier='uri'], concat($license, '/')), '/')" /></xsl:variable>
                        <span class="license"><xsl:value-of select="concat(' (CC ', $license, ' ', $cc-version, ')')" /></span>
                        <!--
                        <xsl:call-template name="cc-logo">
                            <xsl:with-param name="ccLicenseName" select="//dim:field[@element='rights'][@qualifier='uri']"/>
                            <xsl:with-param name="ccLicenseUri" select="//dim:field[@element='rights'][@qualifier='uri']"/>
                        </xsl:call-template>
                        -->
                    </a>
                    <!-- </div>
                    <div class="col-sm-8">
                    <span>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                        <xsl:value-of select="//dim:field[@element='rights'][@qualifier='uri']"/>
                    </span> -->
                    <!-- </div> -->

                </xsl:if>
            </small>
            <!-- <xsl:choose>
                    <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
                        <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <a title="http://creativecommons.org/licenses/by-nd/2.0/de" alt="http://creativecommons.org/licenses/by-nd/2.0/de" href="http://creativecommons.org/licenses/by-nd/2.0/de" rel="license">
                            <img class="img-responsive" src="/themes/Mirage2//images/creativecommons/cc-by-nd.png" alt="http://creativecommons.org/licenses/by-nd/2.0/de"></img></a>
                    </xsl:otherwise>
                </xsl:choose> -->


        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
        <tr>
            <xsl:attribute name="class">
                <xsl:text>ds-table-row </xsl:text>
                <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
            </xsl:attribute>
            <td class="label-cell">
                <xsl:value-of select="./@mdschema"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="./@element"/>
                <xsl:if test="./@qualifier">
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@qualifier"/>
                </xsl:if>
            </td>
            <td class="word-break">
                <xsl:copy-of select="./node()"/>
            </td>
            <td><xsl:value-of select="./@language"/></td>
        </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:choose>
            <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
            <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Otherwise, iterate over and display all of them -->
            <xsl:otherwise>
                <xsl:apply-templates select="mets:file">
                    <!--Do not sort any more bitstream order can be changed-->
                    <xsl:with-param name="context" select="$context"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
        <xsl:apply-templates select="mets:file">
            <xsl:with-param name="context" select="$context"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail" id="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img alt="Thumbnail">
                                    <xsl:attribute name="data-src">
                                        <xsl:text>holder.js/100%x</xsl:text>
                                        <xsl:value-of select="$thumbnail.maxheight"/>
                                        <xsl:text>/text:No Thumbnail</xsl:text>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </div>
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                    <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">

                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:choose>
                                    <xsl:when test="$locale='de'">
                                        <xsl:value-of select="translate(substring(string(@SIZE div 1024),1,5), '.', ',')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:choose>
                                    <xsl:when test="$locale='de'">
                                        <xsl:value-of select="translate(substring(string(@SIZE div (1024 * 1024)),1,5), '.', ',')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="$locale='de'">
                                        <xsl:value-of select="translate(substring(string(@SIZE div (1024 * 1024 * 1024)),1,5), '.', ',')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                    <!-- Lookup File Type description in local messages.xml based on MIME Type.
             In the original DSpace, this would get resolved to an application via
             the Bitstream Registry, but we are constrained by the capabilities of METS
             and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                        <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                    <!-- Display the contents of 'Description' only if bitstream contains a description -->
                    <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                    </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="view-open">
	 <a data-fancybox="" data-type="iframe" >
                        <xsl:attribute name="data-src">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
        <!-- <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>-->
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                        <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                        <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
	
        <i class="icon-file-pdf"></i>
	
        <!--<xsl:attribute name="class">
            <xsl:choose>
                <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                    <xsl:text> &#128274;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text> &#128441;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>-->
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <xsl:template name="abstract">
	        <xsl:choose>
		<xsl:when test="(//dim:field[@element='type'] = 'bookChapter') or (//dim:field[@element='type'] = 'bookPart')">

		<xsl:variable name="parentUrl"><xsl:value-of select="//dim:field[@element='relation' and @qualifier='ispartof']"/></xsl:variable>
		<xsl:variable name="parentMetadataUrl"><xsl:value-of select="concat('cocoon://metadata/handle/', $parentUrl, '/mets.xml')" /></xsl:variable>
<!--		<xsl:variable name="metsData" select="document($parentMetadataUrl)/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>		-->

   <xsl:variable name="metsData" select="document($parentMetadataUrl)//dim:dim"/>
	<div><span class="chapter"><i18n:text>xmlui.item.chapter</i18n:text><xsl:value-of select="concat(' ', substring-after(/mets:METS/@ID, '.'))"/></span>
	<xsl:text> (</xsl:text><i18n:text>xmlui.item.chapter.pages</i18n:text>
	<xsl:value-of select="concat(' ', //dim:field[@element='bibliographicCitation'][@qualifier='firstpage'], '-', //dim:field[@element='bibliographicCitation'][@qualifier='lastpage'], ') ')"/> <i18n:text>xmlui.item.chapter.of</i18n:text> 
	<span class="decor"><hr /></span>
	</div>	
<div class="row">
 
  <div class="col-xs-hidden col-sm-hidden col-md-4 col-lg-4">
    <img id="parentthumb">
	<xsl:attribute name="src"><xsl:value-of select="concat('/bitstream/handle/', $parentUrl, '/cover-200.jpg')"/></xsl:attribute>
   </img>
</div>
   <div class="col-xs-12 col-sm-12 col-md-8 col-lg-8">
     <h3><a>
	<xsl:attribute name="href"><xsl:value-of select="concat('/handle/', $parentUrl)"/></xsl:attribute>
	<xsl:copy-of select="$metsData/dim:field[@element='title'][1]/node()"/>
</a></h3>
     <h4>
	<xsl:if test="$metsData/dim:field[@element='title' and @qualifier='alternative']">
		<xsl:copy-of select="$metsData/dim:field[@element='title' and @qualifier='alternative']"/>
        </xsl:if>
     </h4>
     <div class="itemView-authors">
	<xsl:for-each select="$metsData/dim:field[@element='contributor'][@qualifier='author']">	
		<xsl:copy-of select="."/>
		<xsl:if test="position() != last()">
			<xsl:text>; </xsl:text>
		</xsl:if>
		
	</xsl:for-each>
	<xsl:for-each select="$metsData/dim:field[@element='contributor'][@qualifier='editor']">        
                <xsl:copy-of select="."/>
                <xsl:if test="position() != last()">
                        <xsl:text>; </xsl:text>
                </xsl:if>

        </xsl:for-each>
	<i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
    </div>	
</div>
</div>	
	
		</xsl:when>
		<xsl:otherwise>

        <!-- <div class="simple-item-view-description"> -->
        <ul class="nav nav-tabs" id="myTab">
            <xsl:if test="//dim:field[@element='relation'][@qualifier='otherparts']">
                <li class="active"><a data-target="#related" data-toggle="tab"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-related.items</i18n:text></a></li>
            </xsl:if>
            <xsl:if test="//dim:field[@element='description' and starts-with(@qualifier, 'abstract')]">
                <li>
                    <xsl:if test="not(//dim:field[@element='relation'][@qualifier='otherparts'])"><xsl:attribute name="class">active</xsl:attribute></xsl:if>
                    <a data-target="#abstract" data-toggle="tab"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></a>
                </li>
            </xsl:if>
            <xsl:if test="//dim:field[@qualifier='isreferencedby']">
                <li><a data-target="#reviews" data-toggle="tab"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-reviewed</i18n:text></a></li>
            </xsl:if>
            <xsl:if test="//dim:field[@qualifier='tableofcontents']">
                <li><a data-target="#toc" data-toggle="tab"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-tableofcontents</i18n:text></a></li>
            </xsl:if>
	    <xsl:if test="//dim:field[@element='contributor' and not(@qualifier)]">
		<xsl:if test="count(//dim:field[@qualifier='haspart']) != number(//dim:field[@element='format'][@qualifier='chapters'])">
                <li>
                        <a data-target="#contributors" data-toggle="tab"><i18n:text>xmlui.item.contributors</i18n:text></a>
                </li>
		</xsl:if>
            </xsl:if>
            <li>
                <xsl:if test="not(//dim:field[@element='description' and starts-with(@qualifier, 'abstract')] or //dim:field[@qualifier='isreferencedby'] or //dim:field[@qualifier='tableofcontents'])">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                <a data-target="#details" data-toggle="tab"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-details</i18n:text></a>
            </li>
            <xsl:if test="//dri:referenceSet[@id='aspect.discovery.RelatedItems.referenceSet.item-related-items']">
                <li>
                    RELATED ITEMS
                </li>
            </xsl:if>
	    <xsl:if test="contains(//dim:field[@element='identifier' and @qualifier='uri'], 'doi.org')"> 
                <li><a  id="cs" data-target="#cite" data-toggle="tab">
			<i18n:text>xmlui.dri2xhtml.METS-1.0.item-cite</i18n:text> 
			</a>
		</li>
            </xsl:if> 
	    <xsl:if test="//dim:field[@element='relation' and @qualifier='multimedia']">
		<li><a  data-target="#film" data-toggle="tab">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-lecture</i18n:text>
                        </a>
                </li> 
	    </xsl:if> 
	    <li><a  id="anno" data-target="#annos" data-toggle="tab" style="display:none">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-annotations</i18n:text>
                        </a>
            </li>
            <!-- <li><a href="#cite">Zitieren</a></li> -->
        </ul>
        <!-- </div> -->
        <div class="tab-content">
            <div id="related" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'RelatedItems']);">
                <xsl:attribute name="class">tab-pane
                    <xsl:if test="//dim:field[@element='relation'][@qualifier='otherparts']"><xsl:text> active</xsl:text></xsl:if>
                </xsl:attribute>
                <xsl:for-each select="//dim:field[@element='relation'][@qualifier='otherparts']">
                    <p>
                        <a>
                            <xsl:attribute name="href"><xsl:value-of select="substring-after(., ': ')" /></xsl:attribute>
                            <xsl:value-of select="substring-before(., ': ')" /><i class="icon-arrow-right"></i>
                        </a>
                    </p>
                </xsl:for-each>

            </div>
            <div id="abstract" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'Abstract']);">
                <xsl:attribute name="class"><xsl:text>tab-pane</xsl:text>
                    <xsl:if test="(//dim:field[@element='description' and starts-with(@qualifier, 'abstract')]) and not(//dim:field[@element='relation'][@qualifier='otherparts'])">
                        <xsl:text> active</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:for-each select="//dim:field[@element='description'][@qualifier='other']">
                    <p>
                        <a target="_blank">
                            <xsl:attribute name="href"><xsl:value-of select="." /></xsl:attribute>
                            <i class="icon-link-ext"></i><i18n:text>xmlui.item.relation.online</i18n:text>
                        </a>
                    </p>
                </xsl:for-each>
                <p>
                    <xsl:choose>
                        <xsl:when test="$locale = 'de'">
                            <xsl:choose>
                                <xsl:when test="//dim:field[@element='description' and @qualifier='abstractger']">
                                    <xsl:value-of select="//dim:field[@element='description' and @qualifier='abstractger']" disable-output-escaping="yes" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="//dim:field[@element='description' and @qualifier='abstracteng']">
                                        <xsl:value-of select="//dim:field[@element='description' and @qualifier='abstracteng']" disable-output-escaping="yes" />
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="//dim:field[@element='description' and @qualifier='abstracteng']">
                                    <xsl:value-of select="//dim:field[@element='description' and @qualifier='abstracteng']" disable-output-escaping="yes" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="//dim:field[@element='description' and @qualifier='abstractger']">
                                        <xsl:value-of select="//dim:field[@element='description' and @qualifier='abstractger']" disable-output-escaping="yes" />
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:otherwise>
                    </xsl:choose>
                </p>
                <xsl:for-each select="//dim:field[@element='description' and @qualifier='abstractother']">
                    <p>
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:value-of select="node()" disable-output-escaping="yes" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                </xsl:for-each>

                <xsl:for-each select="//dim:field[@element='description' and @qualifier='abstract']">
                    <p>
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:value-of select="node()" disable-output-escaping="yes" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </p>
                </xsl:for-each>
            </div>
            <xsl:if test="//dim:field[@qualifier='isreferencedby']">
		<div class="tab-pane" id="reviews" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'reviews']);">
                    <xsl:for-each select="//dim:field[@qualifier='isreferencedby']">
                        <p>
                            <xsl:choose>
                                <xsl:when test="contains(., 'http')">

                                    <a class="extern-link" target="_blank">
                                        <xsl:choose>
                                            <xsl:when test="contains(node(), '@ ')">
                                                <xsl:attribute name="href"><xsl:value-of select="substring-after(node(), '@ ')" /></xsl:attribute>
                                                <xsl:value-of select="substring-before(node(), '@ ')" />
                                            </xsl:when>

                                            <xsl:otherwise>
                                                <xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>

                                                <small><i18n:text>xmlui.item.review.online</i18n:text></small>
                                            </xsl:otherwise>
                                        </xsl:choose>

                                    </a>

                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- <xsl:copy-of select="node()"/> -->
				    <xsl:value-of select="." disable-output-escaping="yes"/>
                                </xsl:otherwise>
                            </xsl:choose>

                        </p>
                    </xsl:for-each>
                </div>

            </xsl:if>
            <xsl:if test="//dim:field[@qualifier='tableofcontents']">
                <div class="tab-pane" id="toc" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'ToC']);">
                    <xsl:value-of select="//dim:field[@qualifier='tableofcontents']" disable-output-escaping="yes" />
                </div>
            </xsl:if>

	    <div id="contributors" class="tab-pane">
                <xsl:for-each select="//dim:field[@element='contributor' and not(@qualifier)]">
                        <a>
                        <xsl:choose>
                                <xsl:when test="string-length(./@authority) &gt; 1">

                                                <xsl:attribute name="href"><xsl:value-of select="concat('/handle/3/Regular_publications/browse?authority=', ./@authority, '&amp;type=author')"/></xsl:attribute>

                                </xsl:when>
                                <xsl:otherwise>
                                        <xsl:attribute name="href"><xsl:value-of select="concat('/handle/3/Regular_publications/browse?type=author&amp;value=', translate(.,' ','+'))"/></xsl:attribute>
                                </xsl:otherwise>
                        </xsl:choose>
                                <xsl:value-of select="."/>
                        </a>
                        <xsl:choose>
                                                <xsl:when test="count(//dim:field[@element='contributor' and not(@qualifier)]) &lt; 10">                                                        <br />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                        <xsl:if test="position() != last()">
                                                                <xsl:text>; </xsl:text>
                                                        </xsl:if>
                                                </xsl:otherwise>
                                                </xsl:choose>

                </xsl:for-each>
            </div>

            <div  class="tab-pane" id="details" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'Details']);">

                <xsl:if test="not(//dim:field[starts-with(@qualifier, 'abstract')])">
                    <xsl:attribute name="class">tab-pane active</xsl:attribute>
                </xsl:if>
                <xsl:for-each select="//dim:field[@qualifier='supplement']">
                    <p><xsl:value-of select="." /></p>
                </xsl:for-each>
                <xsl:call-template name="itemSummaryView-DIM-events"/>
                <xsl:if test="//dim:field[@qualifier='edition']">
                    <p><strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-edition</i18n:text></strong><xsl:text>: </xsl:text><xsl:call-template name="itemSummaryView-DIM-edition"/></p>
                </xsl:if>

                <p><strong><i18n:text>xmlui.Discovery.AdvancedSearch.type_type</i18n:text></strong><xsl:text>: </xsl:text>

                    <xsl:choose>
                        <xsl:when test="//dim:field[@qualifier='subtype']">
                            <i18n:text><xsl:value-of select="//dim:field[@qualifier='subtype']" /></i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text><xsl:value-of select="//dim:field[@element='type']" /></i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>

                <p><strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-division</i18n:text></strong><xsl:text>: </xsl:text><i18n:text><xsl:value-of select="//dim:field[@element='subject'][@qualifier='division']" /></i18n:text>
                    <xsl:if test="//dim:field[@element='subject'][@qualifier='division'] = 'peerReviewed'">
                        <i class="icon-star" title="peer-reviewed"></i>
                    </xsl:if></p>

                <p><strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-language</i18n:text></strong><xsl:text>: </xsl:text>
                    <xsl:for-each select="//dim:field[@element='language'][@qualifier='iso']">
                        <i18n:text><xsl:value-of select="." /></i18n:text>
                        <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                    </xsl:for-each>
                </p>

                <xsl:if test="//dim:field[starts-with(@qualifier,'isbn')]">
                    <p><strong>ISBN</strong><xsl:text>: </xsl:text>
                        <span id="isbn">
                            <xsl:choose>
                                <xsl:when test="//dim:field[@qualifier='isbn-13']">
                                    <xsl:value-of select="//dim:field[@qualifier='isbn-13']" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="//dim:field[@qualifier='isbn']" />
                                </xsl:otherwise>

                            </xsl:choose>
                        </span>

                        <xsl:if test="//dim:field[@qualifier='medium'] = 'Print'"><xsl:text> </xsl:text><i18n:text>xmlui.item.info.print</i18n:text></xsl:if>
                        <a href="#" onclick="copyToClipboard('#isbn')" i18n:attr="title" title="xmlui.dri2xhtml.METS-1.0.item-copyto-clipboard"><i class="icon-export"></i></a>

                    </p>
                </xsl:if>

                <p><strong> URN</strong><xsl:text>: </xsl:text><span id="urn"><xsl:value-of select="//dim:field[@element='identifier'][@qualifier='urn']" /></span><a href="#" onclick="copyToClipboard('#urn')" i18n:attr="title" title="xmlui.dri2xhtml.METS-1.0.item-copyto-clipboard"><i class="icon-export"></i></a></p>
                <xsl:for-each select="//dim:field[@element='relation'][@qualifier='sponsorship']">
		    <xsl:choose>
                    <xsl:when test="string-length(./@authority) &gt; 0">
                        <p>
                            <strong>Sponsor</strong><xsl:text>: </xsl:text>
                            <a target="_blank" class="extern-link">
                                <xsl:attribute name="href"><xsl:value-of select="concat('http://search.crossref.org/funding?q=', ./@authority)" /></xsl:attribute>
                                <xsl:value-of select="." />
                            </a>
                        </p>
                    </xsl:when>
		    <xsl:otherwise>
			<p>
                            <strong>Sponsor</strong><xsl:text>: </xsl:text>
                                <xsl:value-of select="." />
			    <xsl:if test="//dim:field[@element='relation'][@qualifier='sponsordetails']">
				<xsl:value-of select="concat(' ', //dim:field[@element='relation'][@qualifier='sponsordetails'])"/>
			    </xsl:if>
                        </p>
		    </xsl:otherwise>
		    </xsl:choose>
                </xsl:for-each>
                <xsl:if test="(//dim:field[@qualifier='access'] != 'nodocument')"><i18n:text>xmlui.item.info.document</i18n:text></xsl:if>
	        <xsl:if test="contains(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=y')">
                <!-- <p><strong><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-annotate.heading</i18n:text></strong><xsl:text>: </xsl:text>
                    <a data-fancybox="" data-type="iframe" >
                        <xsl:attribute name="data-src">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/pdfview/', substring-before(substring-after(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:href, '3/'), 'isAllow'))"/>
                        </xsl:attribute>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-annotate</i18n:text>
                    </a> -->
                    <span id="pdfurl" style="display: none;" aria-hidden="true"><xsl:value-of select="concat($baseURL, '/pdfview/', substring-before(substring-after(//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:href, '3/'), 'isAllow'))"/></span>
		    <span id="doctitle" style="display: none;"><xsl:value-of select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']/mets:file[1]/mets:FLocat/@xlink:title"/></span>
                  <!--  <a href="#" onclick="copyToClipboard('#pdfurl')" i18n:attr="title" title="xmlui.dri2xhtml.METS-1.0.item-copyto-clipboard"><i class="icon-export"></i></a>
                    <br /><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-annotate.description</i18n:text>
                </p> -->

		<!-- preparation for annotation export -->
                <div style="display: none;" aria-hidden="true">
                    <span aria-hidden="true" style="display: none;" id="annotation-details-text"><i18n:text>xmlui.item.annotation.details.text</i18n:text></span>
                    <span aria-hidden="true" style="display: none;" id="annotation-details-link"><i18n:text>xmlui.item.annotation.details.link</i18n:text></span>
                    <span aria-hidden="true" style="display: none;" id="annotation-details-none"><i18n:text>xmlui.item.annotation.details.none</i18n:text></span> 
                </div> 
		<!-- <span aria-hidden="true" style="display: none;" id="annotation-details-link"><i18n:text>xmlui.item.annotation.download</i18n:text></span> -->

		</xsl:if>
                <!-- preparation for peer review certificate -->
                <div id="pr-details-texts" style="display: none;" aria-hidden="true">
                    <span id="pr-details-text" style="display: none;" aria-hidden="true"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-pr-process</i18n:text></span>
                    <span id="pr-link-title" style="display: none;" aria-hidden="true"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-pr-process.icon.title</i18n:text></span>
                </div>
            </div>
	    <div class="tab-pane" id="cite" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'Cite']);">
		<h6 class="apa" style="display:none"><b>APA</b></h6>
                <p id="apa" class="cs"> </p>
		<h6 class="chicago-author-date-de" style="display:none"><b>Chicago</b></h6>
                <p id="chicago-author-date-de" class="cs"> </p>
		<h6 class="harvard1" style="display:none"><b>Harvard</b></h6>
                <p id="harvard1" class="cs"> </p>
		<!-- <h6><b>MLA</b></h6> 
                <p id="mla" class="cs"> </p>  -->
		
		<div>
			<xsl:variable name="hdl"><xsl:value-of select="substring-after(/mets:METS/@ID, 'hdl:')"/></xsl:variable>
                <b>Export: </b>
                <a>
                        <xsl:attribute name="href"><xsl:value-of select="concat('/bibtex/handle/', $hdl)"/></xsl:attribute>
			<xsl:attribute name="onclick"><xsl:text>javascript:_paq.push(['trackEvent', 'Clicks', 'Export', 'BibTeX']);</xsl:text></xsl:attribute>
                        BibTeX
                </a>
                <xsl:text> | </xsl:text>
                <a>
                        <xsl:attribute name="href"><xsl:value-of select="concat('/endnote/handle/', $hdl)"/></xsl:attribute>
			<xsl:attribute name="onclick"><xsl:text>javascript:_paq.push(['trackEvent', 'Clicks', 'Export', 'EndNote']);</xsl:text></xsl:attribute>
                        RefMan
                </a>
                <xsl:text> | </xsl:text>
                <a>
			<xsl:attribute name="onclick"><xsl:text>javascript:_paq.push(['trackEvent', 'Clicks', 'Export', 'RIS']);</xsl:text></xsl:attribute>
                        <xsl:attribute name="href"><xsl:value-of select="concat('/ris/handle/', $hdl)"/></xsl:attribute>
                        Ris
                </a>

		
		</div>
	    </div> 
	    <div class="tab-pane" id="film" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Tabs', 'video']);">
		<xsl:for-each select="//dim:field[@element='notes' and @qualifier='multimedia']">
			<xsl:choose>
				<xsl:when test="starts-with(., 'http')">
					<a target="_blank">
						<xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute>
						<xsl:value-of select="."/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="count(following-sibling::dim:field[@element='notes'][@qualifier='multimedia']) != 0">

                                 <xsl:text>&#160;</xsl:text>
                        </xsl:if>
		</xsl:for-each>
		<xsl:for-each select="//dim:field[@element='relation' and @qualifier='multimedia']">
		<div class="embed-responsive embed-responsive-16by9">
		  <iframe allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen="" width="560" height="315" frameborder="0">
			<xsl:attribute name="src"><xsl:value-of select="."/></xsl:attribute>
		  </iframe>
		</div>
		</xsl:for-each>
	    </div>
	    <div class="tab-pane" id="annos">
                <iframe id="hp-site" src="" width="100%" height="1000" frameborder="0"></iframe>
             </div>
	     <!-- preparation for annotation export -->
                <div style="display: none;" aria-hidden="true">
                    <span aria-hidden="true" style="display: none;" id="annotation-details-text"><i18n:text>xmlui.item.annotation.details.text</i18n:text></span> 
                    <span aria-hidden="true" style="display: none;" id="annotation-details-link"><i18n:text>xmlui.item.annotation.details.link</i18n:text></span>
                    <!-- <span aria-hidden="true" style="display: none;" id="annotation-details-none"><i18n:text>xmlui.item.annotation.details.none</i18n:text></span> -->
                </div>
        </div>
     </xsl:otherwise>
    </xsl:choose>

    <!-- show table of contents if parts of the publication have DOI -->
    	<xsl:if test="count(//dim:field[@qualifier='haspart']) = number(//dim:field[@element][@qualifier='chapters'])">
		<h3>
			<i18n:text>xmlui.item.toc.list</i18n:text>
			<small class="ital normal"> <xsl:text> (</xsl:text> <xsl:value-of select="count(//dim:field[@qualifier='haspart'])"/><xsl:text> </xsl:text> <i18n:text>xmlui.item.chapter</i18n:text><xsl:text>)</xsl:text></small>
		</h3>
                <hr />
                <div id="toc-outside">
			<ul>
			<xsl:for-each select="//dim:field[@qualifier='haspart']">
				<li>
				<xsl:variable name="childMetadataUrl"><xsl:value-of select="concat('cocoon://metadata/handle/', ., '/mets.xml')" /></xsl:variable>

   <xsl:variable name="metsData" select="document($childMetadataUrl)//dim:dim"/>
				<div class="col-sm-7 item">
				<span class="ptitle">
				<xsl:value-of select="$metsData/dim:field[@element='title']"/>
				<small class="ital"><xsl:text> (</xsl:text><i18n:text>xmlui.item.chapter.pages</i18n:text>
				<!-- <xsl:value-of select="concat(' ', $metsData/dim:field[@element='format'][@qualifier='extent'])"/><xsl:text>)</xsl:text></small> -->
				<xsl:value-of select="concat(' ', $metsData/dim:field[@element='bibliographicCitation'][@qualifier='firstpage'], '-', $metsData/dim:field[@element='bibliographicCitation'][@qualifier='lastpage'])"/><xsl:text>)</xsl:text></small>
				</span>
				<span class="pauthor">
				<xsl:for-each select="$metsData/dim:field[@element='contributor']">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()"><xsl:text>; </xsl:text></xsl:if>
				</xsl:for-each>
				</span>
				</div>
				<div class="col-sm-5 link">
				<span class="pdoi">
				
					<a>
					<xsl:attribute name="href">
						<xsl:value-of select="$metsData/dim:field[@element='identifier' and @qualifier='uri']"/> 
					</xsl:attribute>
					<xsl:value-of select="$metsData/dim:field[@element='identifier' and @qualifier='uri']"/>
					</a>
				</span>
				</div>
				</li>
			</xsl:for-each>
			</ul>
		</div>
	</xsl:if>

    </xsl:template>

    <xsl:template name="recentSubmissionsList-DIM">
        <div class="col-sm-6 col-md-4">
            <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                 mode="recentSubmissionsView-DIM"/>
        </div>
    </xsl:template>

    <xsl:template match="dim:dim" mode="recentSubmissionsView-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:choose>
                    <xsl:when test="$itemWithdrawn">
                        <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <div class="thumbnail artifact-preview">
                <xsl:choose>
                    <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                        <xsl:variable name="src">
                            <xsl:choose>
                                <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                    <xsl:value-of
                                            select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                            select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <img alt="Thumbnail">
                            <xsl:attribute name="src">
                                <xsl:value-of select="$src"/>
                            </xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:otherwise>
                        <img alt="Thumbnail">
                            <xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
                <div class="caption">
                    <h4 class="artifact-title">

                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>


                        <span class="Z3988">
                            <xsl:attribute name="title">
                                <xsl:call-template name="renderCOinS"/>
                            </xsl:attribute>
                            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                        </span></h4>

                    <!--<xsl:choose>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                            <p>
                                <small>
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
                                </small>
                            </p>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='editor']">
                            <p>
                                <small>
                                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                                        <xsl:copy-of select="node()"/>
                                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='editor']) != 0">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
                                </small>
                            </p>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='corporation']">
                            <p>
                                <small>
                                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='corporation']">
                                        <xsl:copy-of select="node()"/>
                                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='corporation']) != 0">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text> <xsl:text>)</xsl:text>
                                </small>
                            </p>
                        </xsl:when>
                        <xsl:when test="dim:field[@element='contributor'][@qualifier='other']">
                            <p>
                                <small>
                                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='other']">
                                        <xsl:copy-of select="node()"/>
                                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='other']) != 0">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                                </small>
                            </p>
                        </xsl:when>
                        <xsl:otherwise>
                            <p>
                                <small>
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                                </small>
                            </p>
                        </xsl:otherwise>
                    </xsl:choose> -->

                    <!-- <p>
                        <small>
                        <xsl:copy-of select="dim:field[@element='date' and @qualifier='issued']/node()"/>
                        </small>
                    </p> -->
                </div>
            </div>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>

