<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Rendering specific to the navigation (options)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
	xmlns:dri="http://di.tamu.edu/DRI/1.0/"
	xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/TR/xlink/"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:mods="http://www.loc.gov/mods/v3"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc">

    <xsl:output indent="yes"/>

    <!--
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the ds-options div and applying
        the templates inside it.

        In fact, the only bit of real work this template does is add the search box, which has to be
        handled specially in that it is not actually included in the options div, and is instead built
        from metadata available under pageMeta.
    -->
    <!-- TODO: figure out why i18n tags break the go button -->
    <xsl:template match="dri:options">
        <div id="ds-options-wrapper">
            <div id="ds-options">
		    <!-- do not show general browsing navi on the homepage -->
		    <!-- <xsl:if test="string-length(//dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']) = 0"> -->
		    	<h1 class="ds-option-set-head"><i18n:text>xmlui.ArtifactBrowser.CommunityViewer.head_browse</i18n:text></h1>
			<div class="ds-option-set" id="aspect_viewArtifacts_Navigation_list_browse">
			    	<xsl:call-template name="menu-static"/>
			</div>

		<h1 class="ds-option-set-head"><i18n:text>xmlui.static.navigation.informations</i18n:text></h1>
		<div class="ds-option-set" id="infonav">
			<ul class="ds-options-list">
				<li>
					
					<a href="{$context-path}/info/publishing"><i18n:text>xmlui.static.publishing.trail</i18n:text></a>
					<!-- show only if Publishing is activ -->
					<xsl:if test="contains(//dri:metadata[@element='request'][@qualifier='URI'], 'info/publishing')">
					<ul class="ds-simple-list sublist">
						<li><a href="{$context-path}/info/publishing-authors"><i18n:text>xmlui.static.editors-authors.head</i18n:text></a></li>
						<li><a href="{$context-path}/info/publishing-price"><i18n:text>xmlui.static.price.head</i18n:text></a></li>
						<li><a href="{$context-path}/info/publishing-policy"><i18n:text>xmlui.static.policy.head</i18n:text></a></li>
					</ul>
					</xsl:if>
				</li>
				<!-- Review Form: accessible for authenticated user only -->
				<xsl:if test="//dri:userMeta[@authenticated='yes']">
					<li><i18n:text>xmlui.static.reviewform.link</i18n:text></li>
				</xsl:if>
				<li><a href="{$context-path}/info/editors"><i18n:text>xmlui.static.editors.head</i18n:text></a></li>
				<li><a href="{$context-path}/info/divisions"><i18n:text>xmlui.static.divisions.head</i18n:text></a></li>
				<li><a href="{$context-path}/info/openaccess">Open Access</a></li>
				<li><a href="{$context-path}/info/publishing-catalog"><i18n:text>xmlui.static.publisher-catalog.link</i18n:text></a></li>
				<!-- <li><a href="{$context-path}/info/aboutus"><i18n:text>xmlui.static.aboutus.head</i18n:text></a></li> -->
			</ul>
		</div>
		<xsl:apply-templates select="dri:list[@n='context']"/>
		<xsl:apply-templates select="dri:list[@n='account']"/>
		<xsl:apply-templates select="dri:list[@n='discovery']"/>
		<xsl:apply-templates select="dri:list[@n='administrative']"/>
		<xsl:apply-templates select="dri:list[@n='statistics']"/>
                <!-- Once the search box is built, the other parts of the options are added -->

            </div>
        </div>
    </xsl:template>

    <!-- Add each RSS feed from meta to a list -->
    <xsl:template name="addRSSLinks">
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <li>
                <a>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>

                    <xsl:attribute name="style">
                        <xsl:text>background: url(</xsl:text>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/static/icons/feed.png) no-repeat</xsl:text>
                    </xsl:attribute>

                    <xsl:choose>
                        <xsl:when test="contains(., 'rss_1.0')">
                            <xsl:text>RSS 1.0</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(., 'rss_2.0')">
                            <xsl:text>RSS 2.0</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains(., 'atom_1.0')">
                            <xsl:text>Atom</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@qualifier"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </a>
            </li>
        </xsl:for-each>
    </xsl:template>

    <!--give nested navigation list the class sublist-->
    <xsl:template match="dri:options/dri:list/dri:list" priority="3" mode="nested">
        <li>
            <xsl:apply-templates select="dri:head" mode="nested"/>
            <ul class="ds-simple-list sublist">
                <xsl:apply-templates select="dri:item" mode="nested"/>
            </ul>
        </li>
    </xsl:template>

    <!-- Quick patch to remove empty lists from options -->
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5" mode="nested">
    </xsl:template>
    <xsl:template match="dri:options//dri:list[count(child::*)=0]" priority="5">
    </xsl:template>

    <!-- translate language iso code and division in facet side bar -->
    <xsl:template match="dri:item[@rend='selected']" mode="nested" priority="3">
		<xsl:choose> 
                <xsl:when test="(@rend='selected') and (../@n='language' or ../@n='division' or ../@n='type') ">
                        <li><i18n:text><xsl:value-of select="substring-before(., ' ')" /></i18n:text><xsl:value-of select="concat(' ', substring-after(., ' '))" /></li>
                </xsl:when>
		<xsl:otherwise>
		<li>
			<xsl:apply-templates />
		</li>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template> 

</xsl:stylesheet>
