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
        <div id="ds-options" class="word-break hidden-print">
            <!-- <xsl:if test="not(contains(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'], 'discover'))"> -->
            <!--  <div id="ds-search-option" class="ds-option-set"> -->
            <!-- The form, complete with a text box and a button, all built from attributes referenced
         from under pageMeta. -->
            <form id="ds-search-form" class="visible-xs hidden-sm hidden-md hidden-lg" method="post">
                <xsl:attribute name="action">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                    <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                </xsl:attribute>
                <fieldset>
                    <div class="input-group">
                        <input class="ds-text-field form-control" type="text" placeholder="xmlui.general.search"
                               i18n:attr="placeholder">
                            <xsl:attribute name="name">
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                            </xsl:attribute>
                        </input>
                        <span class="input-group-btn">
                            <button class="ds-button-field btn btn-primary" title="xmlui.general.go" i18n:attr="title">
                                <span class="glyphicon glyphicon-search" aria-hidden="true"/>
                                <xsl:attribute name="onclick">
                                                <xsl:text>
                                                    var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                                    if (radio != undefined &amp;&amp; radio.checked)
                                                    {
                                                    var form = document.getElementById(&quot;ds-search-form&quot;);
                                                    form.action=
                                                </xsl:text>
                                    <xsl:text>&quot;</xsl:text>
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                    <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                    <xsl:text>&quot; ; </xsl:text>
                                    <xsl:text>
                                                    }
                                                </xsl:text>
                                </xsl:attribute>
                            </button>
                        </span>
                    </div>

                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
                        <div class="radio">
                            <label>
                                <input id="ds-search-form-scope-all" type="radio" name="scope" value=""
                                       checked="checked"/>
                                <i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
                            </label>
                        </div>
                        <div class="radio">
                            <label>
                                <input id="ds-search-form-scope-container" type="radio" name="scope">
                                    <xsl:attribute name="value">
                                        <xsl:value-of
                                                select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
                                    </xsl:attribute>
                                </input>
                                <xsl:choose>
                                    <xsl:when
                                            test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </label>
                        </div>
                    </xsl:if>
                </fieldset>
            </form>
            <!-- </div> -->
            <!-- </xsl:if> -->
            <!-- <xsl:apply-templates/> -->

            <h1 class="ds-option-set-head h6"><i18n:text>xmlui.ArtifactBrowser.Navigation.home.head</i18n:text></h1>
            <div class="list-group" id="aspect_viewArtifacts_Navigation_list_browse">
                <xsl:call-template name="menu-program"/>
            </div>

            <h1 class="ds-option-set-head h6"><i18n:text>xmlui.ArtifactBrowser.Navigation.more.offers</i18n:text></h1>
            <div class="list-group" id="aspect_viewArtifacts_Navigation_list_browse">
                <xsl:call-template name="menu-other"/>
            </div>

            <h1 class="ds-option-set-head h6"><i18n:text>xmlui.static.navigation.informations</i18n:text></h1>
            <div class="list-group" id="infonav">
                <a class="list-group-item ds-option" href="{$context-path}/info/ordering"><i18n:text>xmlui.static.ordering.trail</i18n:text></a>
                <!-- show only if ordering is activ -->
                <xsl:if test="(contains(//dri:metadata[@element='request'][@qualifier='URI'], 'info/ordering'))">

                    <a class="list-group-item ds-option nested" href="{$context-path}/info/ordering-conditions"><i18n:text>xmlui.static.order-conditions.trail</i18n:text></a>
                    <a class="list-group-item ds-option nested" href="{$context-path}/info/ordering-shipping"><i18n:text>xmlui.static.shipping.costs.trail</i18n:text></a>

                </xsl:if>

                <a class="list-group-item ds-option" href="{$context-path}/info/publishing"><i18n:text>xmlui.static.publishing.trail</i18n:text></a>
                <xsl:if test="//dri:userMeta[@authenticated='yes']">
                    <button type="button" class="btn btn-warning btn-sm" data-toggle="collapse" data-target="#checklist">Checkliste</button>
                    <i18n:text>xmlui.administer.checklist</i18n:text>
                </xsl:if>
                <!-- show only if Publishing is activ -->
                <xsl:if test="(contains(//dri:metadata[@element='request'][@qualifier='URI'], 'info/publishing') or (contains(//dri:metadata[@element='request'][@qualifier='URI'], 'costrequest')) or (contains(//dri:metadata[@element='request'][@qualifier='URI'], 'simple-review')))">

                    <a class="list-group-item ds-option nested" href="{$context-path}/info/publishing-utils"><i18n:text>xmlui.static.editors-authors.navigation</i18n:text></a>
                    <a class="list-group-item ds-option nested" href="{$context-path}/costrequest"><i18n:text>xmlui.ArtifactBrowser.CostRequestForm.navigation</i18n:text></a>
                    <a class="list-group-item ds-option nested" href="{$context-path}/info/publishing-prices"><i18n:text>xmlui.static.price.navigation</i18n:text></a>
                    <a class="list-group-item ds-option nested" href="{$context-path}/info/publishing-policy"><i18n:text>xmlui.static.policy.head</i18n:text></a>
                    <a class="list-group-item ds-option nested" href="{$context-path}/info/publishing-reviewer"><i18n:text>xmlui.static.reviewer.navigation</i18n:text></a>

                </xsl:if>
                <a class="list-group-item ds-option" href="{$context-path}/info/editors"><i18n:text>xmlui.static.editors.head</i18n:text></a>
                <a class="list-group-item ds-option" href="{$context-path}/info/divisions"><i18n:text>xmlui.static.divisions.head</i18n:text></a>
                <a class="list-group-item ds-option" href="{$context-path}/info/openaccess">Open Access</a>
		<a class="list-group-item ds-option" href="{$context-path}/info/interfaces"><i18n:text>xmlui.static.interfaces.head</i18n:text></a>
		<a class="list-group-item ds-option" href="{$context-path}/info/annotationservice" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Menu', 'Annotation']);"><i18n:text>xmlui.static.annotations.link</i18n:text></a>
            </div>
            <xsl:apply-templates select="dri:list[@n='context']"/>
	    <xsl:if test="//dri:userMeta/@authenticated='yes'">
		    <h2 class="ds-option-set-head h6 page-header  h6"><i18n:text>xmlui.static.editorials.head</i18n:text></h2>
		    <div id="aspect_viewArtifacts_Navigation_list_account" class="list-group">
			<a class="list-group-item ds-option" href="{$context-path}/info/editorials"><i18n:text>xmlui.static.editorials.info</i18n:text></a>
			<xsl:variable name="date"><xsl:value-of select="document('../../vlb/current-date.xml')/date"/></xsl:variable>
		 	<a class="list-group-item ds-option">
                                        <xsl:attribute name="href"><xsl:value-of select="concat('/vlb-list/', $date)" /></xsl:attribute>
                                        VLB Export
                        </a>
		    </div>
	    </xsl:if>

            <xsl:apply-templates select="dri:list[@n='administrative']"/>
            <xsl:if test="//dri:userMeta/@authenticated='yes'">
                <xsl:apply-templates select="dri:list[@n='account']"/>
            </xsl:if>
            <xsl:apply-templates select="dri:list[@n='discovery']"/>
	    <xsl:choose>
	    <xsl:when test="//dri:userMeta/@authenticated = 'no'"> 
		<div class="hide">
	            <xsl:apply-templates select="dri:list[@n='statistics']"/> 
		</div>
	    </xsl:when>
	    <xsl:otherwise>
		<xsl:apply-templates select="dri:list[@n='statistics']"/>
	    </xsl:otherwise>
	    </xsl:choose>
            <!-- Do not show RSS Feed -->
            <!-- DS-984 Add RSS Links to Options Box -->
            <!-- <xsl:if test="count(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']) != 0">
                <div>
                    <h2 class="ds-option-set-head h6">
                        <i18n:text>xmlui.feed.header</i18n:text>
                    </h2>
                    <div id="ds-feed-option" class="ds-option-set list-group">
                        <xsl:call-template name="addRSSLinks"/>
                    </div>
                </div> -->

            <!-- </xsl:if> -->

        </div>
    </xsl:template>

    <!-- Add each RSS feed from meta to a list -->
    <xsl:template name="addRSSLinks">
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
            <a class="list-group-item">
                <xsl:attribute name="href">
                    <xsl:value-of select="."/>
                </xsl:attribute>

                <img src="{concat($context-path, '/static/icons/feed.png')}" class="btn-xs" alt="xmlui.mirage2.navigation.rss.feed" i18n:attr="alt"/>

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
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="dri:options//dri:list">
	<xsl:if test="not(@n='persons' or @n='locations' or @n='organisations')">
                <xsl:apply-templates select="dri:head"/>
                <xsl:apply-templates select="dri:item"/>
                <xsl:apply-templates select="dri:list"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="dri:options/dri:list" priority="3">
        <xsl:choose>
            <xsl:when test="count(child::*)=0" />
            <xsl:otherwise>
                <xsl:apply-templates select="dri:head"/>
                <div>
                    <xsl:call-template name="standardAttributes">
                        <xsl:with-param name="class">list-group</xsl:with-param>
                    </xsl:call-template>
                    <xsl:apply-templates select="dri:item"/>
                    <xsl:apply-templates select="dri:list"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="dri:options//dri:item">
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">list-group-item ds-option</xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <!-- translate division, type, language and subjectheading selected facet -->
                <xsl:when test="@rend='selected' and (../@n='division' or ../@n='type'  or ../@n='language' or ../@n='subjectheading')">
                    <xsl:if test="contains(., '(')">
                        <xsl:variable name="kind"><xsl:value-of select="substring-before(., ' (')" /></xsl:variable>
                        <i18n:text><xsl:value-of select="translate($kind, ' ', '+')" /></i18n:text><xsl:value-of select="concat(' (', substring-after(.,' ('))"/>
                    </xsl:if>
                </xsl:when>
		<xsl:when test="contains(., '::')">
			<xsl:value-of select="substring-before(., '::')"/>	
		</xsl:when>
                <xsl:otherwise>
			
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>



    <xsl:template match="dri:options//dri:item[dri:xref]">
        <a>
            <xsl:attribute name="href">
                <!-- global browsing by series: show static page -->
                <xsl:choose>
                    <xsl:when test="../@id='aspect.browseArtifacts.Navigation.list.global' and contains(dri:xref/@target, 'type=series')">
                        <xsl:text>/series</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="dri:xref/@target"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">list-group-item ds-option</xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
                <!-- Translate langugage iso code and division in search facet bar -->
                <xsl:when test="(contains(dri:xref/@target, 'filtertype=division') or contains(dri:xref/@target, 'filtertype=type') or contains(dri:xref/@target, 'language') or contains(dri:xref/@target, 'subjectheading'))">
                    <xsl:if test="contains(., '(')">
                        <xsl:variable name="kind"><xsl:value-of select="substring-before(dri:xref/node(), ' (')" /></xsl:variable>
                        <i18n:text><xsl:value-of select="translate($kind, ' ', '+')" /></i18n:text><xsl:value-of select="concat(' (', substring-after(dri:xref/node(), ' ('))" />
                    </xsl:if>
                </xsl:when>
		<xsl:when test="contains(., '::')">
			<xsl:variable name="tail"><xsl:value-of select="substring-after(., '(')"/></xsl:variable>
			<xsl:value-of select="concat(substring-before(., '::'), ' (', $tail) "/>
		</xsl:when>
                <xsl:when test="dri:xref/node()">
                    <xsl:apply-templates select="dri:xref/node()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="dri:xref"/>
                </xsl:otherwise>
            </xsl:choose>

        </a>
    </xsl:template>



    <xsl:template match="dri:options/dri:list/dri:head" priority="3">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-option-set-head h6</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dri:options/dri:list//dri:list/dri:head" priority="3">
        <a class="list-group-item active">
            <span>
                <xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">
                        <xsl:value-of select="@rend"/>
                        <xsl:text> list-group-item-heading</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:apply-templates/>
            </span>
        </a>
    </xsl:template>

    <xsl:template match="dri:list[count(child::*)=0]"/>


    <!-- translate language iso code and division in facet side bar -->
    <xsl:template match="dri:item[@rend='selected']" mode="nested" priority="3">
        <xsl:choose>
            <xsl:when test="(@rend='selected') and (../@n='language' or ../@n='division' or ../@n='type' or ../@n='subjectheading') ">
                HIER
                <li><i18n:text><xsl:value-of select="translate(substring-before(., ' ('), ' ', '+')" /></i18n:text><xsl:value-of select="concat(' (', substring-after(., ' ('))" /></li>
            </xsl:when>
            <xsl:otherwise>
                <li>
                    <xsl:apply-templates />
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:variable name="currentLoc"><xsl:value-of select="//dri:metadata[@qualifier='currentLocale']" /></xsl:variable>
    <xsl:template name="menu-program">

        <!-- <h2 class="ds-sublist-head"><i18n:text>xmlui.ArtifactBrowser.CollectionViewer.head_browse</i18n:text></h2> -->
        <a class="list-group-item ds-option" href="{$context-path}/{$home-collection}?locale-attribute={$currentLoc}"><i18n:text>xmlui.ArtifactBrowser.Navigation.home.collection</i18n:text></a>
        <a class="list-group-item ds-option" href="{$context-path}/{$home-collection}/browse?ort_by=3&amp;type=dateissued&amp;locale-attribute={$currentLoc}" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Menu', 'Dateissued']);"><i18n:text>xmlui.ArtifactBrowser.Navigation.browse_dateissued</i18n:text></a>
        <a class="list-group-item ds-option" href="{$context-path}/{$home-collection}/browse?type=author&amp;locale-attribute={$currentLoc}" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Menu', 'Authors']);"><i18n:text>xmlui.ArtifactBrowser.Navigation.browse_author</i18n:text></a>
        <a class="list-group-item ds-option" href="{$context-path}/{$home-collection}/browse?type=title&amp;locale-attribute={$currentLoc}" onclick="javascript:_paq.push(['trackEvent', 'Clicks', 'Menu', 'Title']);"><i18n:text>xmlui.ArtifactBrowser.Navigation.browse_title</i18n:text></a>
        <a class="list-group-item ds-option" href="{$context-path}/{$series-collection}?locale-attribute={$currentLoc}"><i18n:text>xmlui.ArtifactBrowser.Navigation.series.collection</i18n:text></a>
        <a class="list-group-item ds-option" href="{$context-path}/info/journals?locale-attribute={$currentLoc}"><i18n:text>xmlui.static.journals.title</i18n:text></a> 

    </xsl:template>
    <xsl:template  name="menu-other">


        <a class="list-group-item ds-option" href="{$context-path}/{$special-collection}?locale-attribute={$currentLoc}"><i18n:text>xmlui.ArtifactBrowser.Navigation.special.collection</i18n:text></a>


    </xsl:template>


</xsl:stylesheet>
