<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Templates to cover the common dri elements.

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

    <!--Removed the automatic font sizing for headers, because while I liked the idea,
     in practice it's too unpredictable.
     Also made all head's follow the same rule: count the number of ancestors that have
     a head, that's the number after the 'h' in the tagname-->
    <xsl:template name="renderHead">
        <xsl:param name="class"/>
        <xsl:variable name="head_count" select="count(ancestor::dri:*[dri:head])"/>
        <xsl:element name="h{$head_count}">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class" select="$class"/>
            </xsl:call-template>
            <xsl:apply-templates />
        </xsl:element>
    </xsl:template>


    <xsl:template match="dri:div/dri:head" priority="3">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-div-head</xsl:with-param>
        </xsl:call-template>
	<!-- append link to title list next to recent submissions -->
	<xsl:if test="contains(../@n, 'recent-submission')">	
		<xsl:variable name="hdl">
			<xsl:choose>	
				<xsl:when test="//dri:metadata[@element='focus'][@qualifier='container']">
					<xsl:value-of select="concat('handle/', substring-after(//dri:metadata[@element='focus'][@qualifier='container'], 'hdl:'), '/')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:text></xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<span id="allList">
			<a>
				<xsl:attribute name="href"><xsl:value-of select="concat($context-path, '/',  $hdl, 'browse?type=title')" /></xsl:attribute>
				<i18n:text>xmlui.list.all.publications</i18n:text>	
			</a>
		</span>
	</xsl:if>
    </xsl:template>

    <!-- The second case is the header on tables, which always creates an HTML h3 element -->
    <xsl:template match="dri:table/dri:head" priority="2">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-table-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- The third case is the header on lists, which creates an HTML h3 element for top level lists and
        and h4 elements for all sublists. -->
    <xsl:template match="dri:list/dri:head" priority="2" mode="nested">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-list-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dri:list/dri:list/dri:head" priority="3" mode="nested">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-sublist-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dri:referenceSet/dri:head" priority="2">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-list-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dri:options/dri:list/dri:head" priority="3">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-option-set-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="dri:head" priority="1">
        <xsl:call-template name="renderHead">
            <xsl:with-param name="class">ds-head</xsl:with-param>
        </xsl:call-template>
    </xsl:template>
    
    <!-- OVERWRITES -->
    
    <!-- Translate langugage iso code and division in search facet bar -->
    <xsl:template match="dri:xref">
        <a>
            <xsl:if test="@target">
                <xsl:choose>
                <xsl:when test="contains(@target, 'recent-submissions')">
                        <xsl:attribute name="href"><xsl:value-of select="concat(substring-before(@target, 'recent-submissions'),'browse?type=title')"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                        <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <xsl:if test="@rend">
                <xsl:attribute name="class"><xsl:value-of select="@rend"/></xsl:attribute>
            </xsl:if>

            <xsl:if test="@n">
                <xsl:attribute name="name"><xsl:value-of select="@n"/></xsl:attribute>
            </xsl:if>
	    <xsl:choose>
		<xsl:when test="contains(@target, 'filtertype') and (contains(@target, 'division') or contains(@target, 'type') or contains(@target, 'language'))">
			<i18n:text><xsl:value-of select="substring-before(.,' ')" /></i18n:text><xsl:value-of select="concat(' ', substring-after(., ' ')) "/> 
 		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates />
		</xsl:otherwise>
	   </xsl:choose>
        </a>
    </xsl:template> 


</xsl:stylesheet>
