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


                <div class="item-wrapper row">
                    <div class="col-sm-2 hidden-xs">
                        <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                    <div class="col-sm-10">
                        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                             mode="itemSummaryList-DIM-metadata">
                            <xsl:with-param name="href" select="$href"/>
                        </xsl:apply-templates>
                    </div>

                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description">
            <xsl:if test="(dim:field[@element='relation' and @qualifier='ispartofseries'])">
                <xsl:value-of select="dim:field[@element='relation' and @qualifier='ispartofseries']" />
                <xsl:if test="//dim:field[@element='bibliographicCitation' and @qualifier='volume']">
                    <xsl:choose>
                        <xsl:when test="starts-with(//dim:field[@element='bibliographicCitation' and @qualifier='volume'], '0')">
                            <xsl:text>;&#160;</xsl:text><i18n:text>xmlui.dri2xhtml.item.series.volume</i18n:text><xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="substring-after(//dim:field[@element='bibliographicCitation' and @qualifier='volume'], '0')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>;&#160;</xsl:text><i18n:text>xmlui.dri2xhtml.item.series.volume</i18n:text><xsl:text>&#160;</xsl:text>
                            <xsl:value-of select="//dim:field[@element='bibliographicCitation' and @qualifier='volume']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>


            </xsl:if>
            <xsl:text> </xsl:text>
            <h4 class="artifact-title">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="$href"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()" disable-output-escaping="yes"/>
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
            </h4>
            <!-- <xsl:if test="//dim:field[@element='title'][@qualifier='alternative']">
                <xsl:for-each select="//dim:field[@element='title'][@qualifier='alternative']">
                    <div><small>
                        <xsl:value-of select="node()"/>
                    </small>
                    </div>
                </xsl:for-each>

            </xsl:if> -->
            <div class="artifact-info">
                <span class="author h4">
                    <small>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <span>
                                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">

                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>

                                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                </span>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='editor' or @qualifier='corporation']">
                                <span>
                                    <xsl:for-each select="dim:field[@element='contributor'][@qualifier='editor']">
                                        <xsl:copy-of select="node()"/>
                                        <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='editor']) != 0">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <xsl:if test="//dim:field[@element='contributor'][@qualifier='corporation']">
                                        <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='corporation']">
                                            <xsl:copy-of select="node()"/>
                                            <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='corporation']) != 0">
                                                <xsl:text>; </xsl:text>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:if>
                                    <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
                                </span>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='other']">

                                <span>
                                    <xsl:for-each select="//dim:field[@element='contributor'][@qualifier='other']">
                                        <xsl:value-of select="."/>
                                        <xsl:if test="position() != last()">
                                            <xsl:text>; </xsl:text>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <i18n:text>xmlui.dri2xhtml.item.contributor.other</i18n:text>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </small>
                </span>

                <xsl:text> </xsl:text>
                <xsl:if test="dim:field[@element='date' and @qualifier='issued']">
                    <span class="publisher-date h4">  <small>
                        <xsl:if test="dim:field[@element='publisher']">
                            <span class="publisher">
                                <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                            </span>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <span class="date">
                            <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                        </span>
                    </small></span>
                </xsl:if>
            </div>
            <!-- Print version existent -->
            <xsl:if test="dim:field[@element = 'format' and @qualifier='medium'] = 'Print'">
                <xsl:for-each select="dim:field[@element='description' and @qualifier='print'][1]">
                    <xsl:variable name="pos"><xsl:value-of select="position()"/></xsl:variable>

                    <xsl:variable name="extent"><xsl:value-of select="../dim:field[@qualifier='extent'][position() = $pos]"/></xsl:variable>
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
                        <!-- <span class="icon">&#x1f56e;</span> -->
                        <i class="icon-book-2"></i>
                        <xsl:text>&#160;</xsl:text><i18n:text>xmlui.item.print.version</i18n:text><xsl:text> </xsl:text>
                        <xsl:if test="not($price = '-')">
                            <xsl:value-of select="concat($price, '&#160;€')" />
                        </xsl:if>
                        <span>
                            <xsl:choose>
                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'amazon')">
                                    <xsl:attribute name="class"><xsl:text>access amazon</xsl:text></xsl:attribute>
                                    <a target="_blank">
                                        <xsl:attribute name="href"><xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/></xsl:attribute>
                                        <i class="icon-amazon-1"></i> <i18n:text>xmlui.item.amazon.order</i18n:text>
                                    </a>
                                </xsl:when>
                                <xsl:when test="starts-with(//dim:field[@element='notes' and @qualifier='printaccess'], 'http')">
                                    <xsl:attribute name="class"><xsl:text>access amazon</xsl:text></xsl:attribute>
                                    <a target="_blank">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/>
                                        </xsl:attribute>
                                        <i class="icon-link-ext"></i> <i18n:text>xmlui.item.publisher.order</i18n:text>
                                    </a>
                                </xsl:when>
                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'http:')">
                                    <xsl:attribute name="class"><xsl:text>access online</xsl:text></xsl:attribute>
                                    <a target="_blank">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="//dim:field[@element='notes' and @qualifier='printaccess']"/>
                                        </xsl:attribute>
                                        <i class="icon-link-ext"></i> <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                                    </a>
                                </xsl:when>
                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='printaccess'], 'outofstock')">
                                    <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                    <i class="icon-block"></i>  <i18n:text>xmlui.item.outofstock</i18n:text>
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
                                                <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
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
                                    <xsl:attribute name="data-description"><xsl:value-of select="concat(. ,', ', $extent, ' S.')" /></xsl:attribute>
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
                    <!-- <div class="details">
                        <small><xsl:value-of select="concat($descr, ', ', $extent, ' ')" /><i18n:text>xmlui.item.info.pages</i18n:text></small>
                    </div> -->

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
                        <i class="icon-cd"></i>
                        <xsl:text>&#160;</xsl:text>
                        <xsl:value-of select="concat('CD-ROM ', $price)"/>

                        <span>
                            <xsl:choose>
                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='cdromaccess'], 'outofstock')">
                                    <xsl:attribute name="class"><xsl:text>access</xsl:text></xsl:attribute>
                                    <i class="icon-block"></i><xsl:text> </xsl:text> <i18n:text>xmlui.item.outofstock</i18n:text>
                                </xsl:when>
                                <xsl:when test="contains(//dim:field[@element='notes' and @qualifier='cdromaccess'], 'http:')">
                                    <xsl:attribute name="class"><xsl:text>access online</xsl:text></xsl:attribute>
                                    <a target="_blank">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="//dim:field[@element='notes' and @qualifier='cdromaccess']"/>
                                        </xsl:attribute>
                                        <i class="icon-link-ext"></i>  <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
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
                                                <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
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
                                    <i class="icon-shopping-cart-1"></i><xsl:text> </xsl:text> <i18n:text>xmlui.item.cdrom.order</i18n:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </div>
                    <!--<div class="details">
                     <xsl:if test=". != '-'">
                        <small><xsl:value-of select="."/></small>

                    </xsl:if>
                    </div>-->
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
                                        <i class="icon-link-ext"></i> <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
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
                                                <i18n:text>xmlui.dri2xhtml.item.editor</i18n:text>
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
                    <!--<xsl:if test="(. != '-')">
                        <div class="details">
                             <small><xsl:value-of select="concat(., ' Min.')" /></small>

                                </div>
                            </xsl:if>-->


                </xsl:for-each>
            </xsl:if>

            <!-- fetch file infos -->
            <xsl:variable name="externalMetadataUrl">
                <xsl:text>cocoon://metadata/handle/3/</xsl:text>
                <xsl:choose>
		    <xsl:when test="contains(//dim:field[@element='identifier'][@qualifier='uri'], '10.17875')">
                        <xsl:value-of select="//dim:field[@element='identifier'][@qualifier='intern']"/>
                    </xsl:when>
                    <xsl:when test="contains(//dim:field[@element='identifier'][@qualifier='uri'], 'univerlag')">
                        <xsl:value-of select="substring-after(//dim:field[@element='identifier'][@qualifier='uri'], 'purl?univerlag-')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(//dim:field[@element='identifier'][@qualifier='uri'], 'purl?')"/>
                    </xsl:otherwise>

                </xsl:choose>
                <xsl:text>/mets.xml</xsl:text>
            </xsl:variable>

		
            <xsl:variable name="metsDoc" select="document($externalMetadataUrl)/mets:METS/mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL']"/>
            <xsl:for-each select="$metsDoc/mets:file[1]">
		<!-- <xsl:value-of select="$metsDoc/mets:file[1]" /> -->
                <!-- Do not show description if file is not free or no files atteched -->
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <!-- do nothing -->
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="format">
                            <i class="icon-file-pdf"></i><xsl:text>&#160;</xsl:text>
                            <xsl:choose>
                                <xsl:when test="mets:FLocat/@xlink:label != ''">
                                    <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <i18n:text>xmlui.item.online.version</i18n:text><xsl:text>, </xsl:text>
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
                                    <!--xsl:choose>
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
                                    </xsl:choose> -->

                                </xsl:otherwise>
                            </xsl:choose>

                            <span class="access">
                                <xsl:attribute name="class"><xsl:text>access doc</xsl:text></xsl:attribute>
				<xsl:variable name="viewer"><xsl:value-of select="concat('/pdfview', substring-after(mets:FLocat/@xlink:href, '/bitstream/handle/3'))" /></xsl:variable>
                                <!-- <a data-type="iframe" data-fancybox="" data-scr="{mets:FLocat/@xlink:href}" href="{mets:FLocat/@xlink:href}">  -->
                                <i class="icon-download-5"></i>
				<a data-type="iframe" data-fancybox="" data-scr="{$viewer}" href="{$viewer}"> 
				<!-- <a href="{mets:FLocat/@xlink:href}"> -->
				<i18n:text>xmlui.item.access.document</i18n:text>
				</a>
                            </span>
                        </div>
                    </xsl:otherwise>

                </xsl:choose>
            </xsl:for-each>
            <!-- sometimes there are more files. Handle them too
            <xsl:for-each select="$metsDoc/mets:file[position() &gt; 1]">
                <xsl:if test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=y')">
                    <div class="format">
                        <i class="icon-file-pdf"></i>
                        <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                        <i18n:text>xmlui.item.online.version</i18n:text><xsl:text>, </xsl:text>
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

                        <span class="access doc">
                            <a>
                                <xsl:attribute name="href"><xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" /></xsl:attribute><i18n:text>xmlui.item.access.document</i18n:text>
                            </a>
                        </span>
                    </div>
                </xsl:if>
            </xsl:for-each>-->

            <!-- <xsl:if test="//dim:field[@element='notes'][@qualifier='access'] = 'onlineonly'">
                <span class="versioninfo">
                    <i18n:text><xsl:value-of select="concat('xmlui.item.', //dim:field[@element='notes'][@qualifier='access'])" /></i18n:text>
                </span>
            </xsl:if> -->


            <!-- <xsl:if test="dim:field[@element = 'description' and @qualifier='abstractger']">
                <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstractger']/node()"/>
                <div class="artifact-abstract">
                    <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                </div>
            </xsl:if> -->
        </div>

    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail artifact-preview">
            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <img class="img-responsive" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="src">
                                <xsl:value-of
                                        select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:attribute>
                        </img>
                    </xsl:when>
                    <xsl:otherwise>
                        <img alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
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
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



    <!-- Generate the info about the item from the metadata section -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="@withdrawn" />
        <div class="artifact-description">
            <div class="artifact-title">

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
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='title']">
                            <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </div>
            <span class="Z3988">
                <xsl:attribute name="title">
                    <xsl:call-template name="renderCOinS"/>
                </xsl:attribute>
                &#xFEFF; <!-- non-breaking space to force separating the end tag -->
            </span>
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
                        <xsl:text>(</xsl:text>
                        <xsl:if test="dim:field[@element='publisher']">
                            <span class="publisher">
                                <xsl:copy-of select="dim:field[@element='publisher']/node()"/>
                            </span>
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                        <span class="date">
                            <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                        </span>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>
</xsl:stylesheet>
