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
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
	xmlns:doc="http://www.lyncode.com/xoai"
	xmlns:urn="http://www.d-nb.de/standards/urn/"
	xmlns:hdl="http://www.d-nb.de/standards/hdl/"
	xmlns:doi="http://www.d-nb.de/standards/doi/"
	xmlns:epicur="urn:nbn:de:1111-2004033116"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	
	<xsl:template match="@*|node()"/>
	
	<xsl:template match="/">
	<epicur xmlns="urn:nbn:de:1111-2004033116" xmlns:epicur="urn:nbn:de:1111-2004033116" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="urn:nbn:de:1111-2004033116 http://www.persistent-identifier.de/xepicur/version1.0/xepicur.xsd">	
		<administrative_data>
			<delivery>
				<update_status type="urn_new"/>
			</delivery>
		</administrative_data>
		<record>


		<identifier scheme="urn:nbn:de">
			<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']"/>
                               
        	</identifier>

		<resource>
			<identifier scheme="url" type="frontpage" role="primary">
			<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']"/>
			</identifier>
			<format scheme="imt">text/html</format>
		</resource>
		
		</record>
	  </epicur>
	 
	</xsl:template>

</xsl:stylesheet>
