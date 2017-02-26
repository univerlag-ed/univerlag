/**
 * CostRequestSent.java
 * Version 1.0
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;

import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.Body;
import org.dspace.app.xmlui.wing.element.Division;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.authorize.AuthorizeException;
import org.xml.sax.SAXException;

/**
 * Simple page to let the user know their cost request is sent.
 *
 * @author Marianna Muehlhoelzer
 * based on FeedbackSent
 */
public class CostRequestSent extends AbstractDSpaceTransformer implements CacheableProcessingComponent
{
    /** language strings */
    public static final Message T_title =
            message("xmlui.ArtifactBrowser.CostRequest.Sent.title");

    public static final Message T_dspace_home =
            message("xmlui.general.dspace_home");

    public static final Message T_trail =
            message("xmlui.ArtifactBrowser.CostRequest.Sent.trail");

    public static final Message T_head =
            message("xmlui.ArtifactBrowser.CostRequest.Sent.head");

    public static final Message T_para1 =
            message("xmlui.ArtifactBrowser.CostRequest.Sent.para1");


    /**
     * Generate the unique caching key.
     */
    public Serializable getKey() {
        return "1";
    }

    /**
     * Generate the cache validity object.
     */
    public SourceValidity getValidity()
    {
        return NOPValidity.SHARED_INSTANCE;
    }


    public void addPageMeta(PageMeta pageMeta) throws SAXException,
            WingException, UIException, SQLException, IOException,
            AuthorizeException
    {

        pageMeta.addMetadata("title").addContent(T_title);

        pageMeta.addTrailLink(contextPath + "/",T_dspace_home);
        pageMeta.addTrail().addContent(T_trail);
    }


    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {
        Division costrequest = body.addDivision("costrequest-sent","primary");

        costrequest.setHead(T_head);

        costrequest.addPara(T_para1);

    }
}
