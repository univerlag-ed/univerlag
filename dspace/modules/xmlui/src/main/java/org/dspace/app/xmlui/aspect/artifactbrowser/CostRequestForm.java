/**
 * CostRequestForm.java
 * Version 1.0
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
import java.io.Serializable;
import java.sql.SQLException;
import java.util.Locale;

import org.apache.cocoon.caching.CacheableProcessingComponent;
import org.apache.cocoon.util.HashUtil;
import org.apache.excalibur.source.SourceValidity;
import org.apache.excalibur.source.impl.validity.NOPValidity;
import org.dspace.app.xmlui.cocoon.AbstractDSpaceTransformer;
import org.dspace.app.xmlui.utils.UIException;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.*;
import org.dspace.content.DCDate;
import org.dspace.core.ConfigurationManager;
import org.dspace.authorize.AuthorizeException;
import org.xml.sax.SAXException;

/**
 * Display to the user a form asking for costs of publication.
 *
 * @author Muehlhoelzer Marianna
 * based on Feedbackform
 */
public class CostRequestForm extends AbstractDSpaceTransformer implements CacheableProcessingComponent
{
    private static final Message T_submit =
            message("xmlui.ArtifactBrowser.CostRequestForm.submit");

    /** Global language Strings */
    private static final Message T_title =
            message("xmlui.ArtifactBrowser.CostRequestForm.title");

    private static final Message T_dspace_home =
            message("xmlui.general.dspace_home");

    private static final Message T_dspace_publishing =
            message("xmlui.static.publishing.trail");

    private static final Message T_trail =
            message("xmlui.ArtifactBrowser.CostRequestForm.trail");

    /**
     * Generate the unique caching key.
     * This key must be unique inside the space of this component.
     */
    public Serializable getKey() {

        String customer_email = parameters.getParameter("customer_email","");
        String creator_lastname = parameters.getParameter("creator_lastname","");
        String creator_firstname = parameters.getParameter("creator_firstname","");
        String publ_title = parameters.getParameter("publ_title","");
        String page = parameters.getParameter("page","unknown");

        return HashUtil.hash(customer_email + "-" + creator_lastname + "-" + creator_firstname  + "-" + publ_title + "-" + page);
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
        pageMeta.addTrailLink(contextPath + "/info/publishing",T_dspace_publishing);
        pageMeta.addTrail().addContent(T_trail);
    }

    public void addBody(Body body) throws SAXException, WingException,
            UIException, SQLException, IOException, AuthorizeException
    {

        /** Further language Strings */
        Message T_title =
                message("xmlui.ArtifactBrowser.CostRequestForm.title");

        Message T_dspace_home =
                message("xmlui.general.dspace_home");

        Message T_trail =
                message("xmlui.ArtifactBrowser.CostRequestForm.trail");

        Message T_head =
                message("xmlui.ArtifactBrowser.CostRequestForm.head");

        Message T_para1 =
                message("xmlui.ArtifactBrowser.CostRequestForm.para1");

        Message T_customer_data =
                message("xmlui.ArtifactBrowser.CostRequestForm.customer_data");

        Message T_publication_data =
                message("xmlui.ArtifactBrowser.CostRequestForm.publication_data");

        Message T_lastname_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.lastname_help");

        Message T_firstname_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.firstname_help");

        Message T_customer_name =
                message("xmlui.ArtifactBrowser.CostRequestForm.customer_name");

	Message T_customer_orcid =
                message("xmlui.ArtifactBrowser.CostRequestForm.customer_orcid");

        Message T_address =
                message("xmlui.ArtifactBrowser.CostRequestForm.address");

        Message T_place =
                message("xmlui.ArtifactBrowser.CostRequestForm.place");

        Message T_zip_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.zip_help");

        Message T_city_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.city_help");

        Message T_street_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.street_help");

        Message T_number_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.number_help");

        Message T_phone =
                message("xmlui.ArtifactBrowser.CostRequestForm.phone");

        Message T_customer_email =
                message("xmlui.ArtifactBrowser.CostRequestForm.customer_email");

        Message T_sponsor =
                message("xmlui.ArtifactBrowser.CostRequestForm.sponsor");

        Message T_publication_type =
                message("xmlui.ArtifactBrowser.CostRequestForm.pubilcation_type");

        Message T_creator =
                message("xmlui.ArtifactBrowser.CostRequestForm.creator");

        Message T_creator_type =
                message("xmlui.ArtifactBrowser.CostRequestForm.creator_type");

        Message T_publ_title =
                message("xmlui.ArtifactBrowser.CostRequestForm.publ_title");

        Message T_subtitle =
                message("xmlui.ArtifactBrowser.CostRequestForm.subtitle");

        Message T_institute =
                message("xmlui.ArtifactBrowser.CostRequestForm.institute");

        Message T_series =
                message("xmlui.ArtifactBrowser.CostRequestForm.series");

        Message T_series_title =
                message("xmlui.ArtifactBrowser.CostRequestForm.series_title");

        Message T_series_volume =
                message("xmlui.ArtifactBrowser.CostRequestForm.series_volume");

        Message T_series_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.series_help");

        Message T_template =
                message("xmlui.ArtifactBrowser.CostRequestForm.template");

        Message T_extent =
                message("xmlui.ArtifactBrowser.CostRequestForm.extent");

        Message T_colored =
                message("xmlui.ArtifactBrowser.CostRequestForm.colored");

        Message T_cover =
                message("xmlui.ArtifactBrowser.CostRequestForm.cover");

        Message T_copy =
                message("xmlui.ArtifactBrowser.CostRequestForm.copy");

        Message T_copy_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.copy_help");

        Message T_delivery =
                message("xmlui.ArtifactBrowser.CostRequestForm.delivery");

        Message T_issue_date =
                message("xmlui.ArtifactBrowser.CostRequestForm.issue_date");

        Message T_year =
                message("xmlui.ArtifactBrowser.CostRequestForm.year");

        Message T_month =
                message("xmlui.ArtifactBrowser.CostRequestForm.month");

        Message T_day =
                message("xmlui.ArtifactBrowser.CostRequestForm.day");

        Message T_comments =
                message("xmlui.ArtifactBrowser.CostRequestForm.comments");

        Message T_comments_help =
                message("xmlui.ArtifactBrowser.CostRequestForm.comments_help");

        int start = Integer.parseInt(ConfigurationManager.getProperty("costrequest.date.startyear"));

        // Build the item viewer division.
        Division costrequest = body.addInteractiveDivision("costrequest-form",
                contextPath+"/costrequest",Division.METHOD_POST,"primary");

        costrequest.setHead(T_head);

        costrequest.addPara(T_para1);

        List form = costrequest.addList("form",List.TYPE_FORM);

        //customer data
        //form.addItem(T_customer_data);


        Composite fullName = form.addItem().addComposite("fullName", "fullName");
        Text lastName = fullName.addText("lastname");
        Text firstName = fullName.addText("firstname");
        fullName.setLabel(T_customer_name);
        lastName.setLabel(T_lastname_help);
        firstName.setLabel(T_firstname_help);
        lastName.setValue(parameters.getParameter("lastname",""));
        firstName.setValue(parameters.getParameter("firstname",""));

        Composite address = form.addItem().addComposite("address", "address");
        Text street = address.addText("street");
        Text number = address.addText("number");
        address.setLabel(T_address);
        street.setLabel(T_street_help);
        number.setLabel(T_number_help);
        street.setValue(parameters.getParameter("street",""));
        number.setValue(parameters.getParameter("number",""));

        Composite place = form.addItem().addComposite("place", "place");
        Text zip = place.addText("zip");
        Text city = place.addText("city");
        place.setLabel(T_place);
        zip.setLabel(T_zip_help);
        city.setLabel(T_city_help);
        zip.setValue(parameters.getParameter("zip",""));
        city.setValue(parameters.getParameter("city",""));

        Text institute = form.addItem().addText("institute");
        institute.setLabel(T_institute);
        institute.setValue(parameters.getParameter("institute",""));

        Text phone = form.addItem().addText("phone");
        phone.setLabel(T_phone);
        phone.setValue(parameters.getParameter("phone",""));

        Text customer_email = form.addItem().addText("customer_email");
        customer_email.setLabel(T_customer_email);
        customer_email.setValue(parameters.getParameter("customer_email",""));

	Text orcid = form.addItem().addText("orcid");
        orcid.setLabel(T_customer_orcid);
        orcid.setValue(parameters.getParameter("orcid",""));

        Select sponsor = form.addItem().addSelect("sponsor","sponsor");
        sponsor.setLabel(T_sponsor);
        sponsor.addOption("Autor", "Autor");
        sponsor.addOption("Institut der Universität", "Institut der Universität");
        sponsor.addOption("Andere Geldgeber", "Andere Geldgeber");
        sponsor.setOptionSelected(parameters.getParameter("sponsor",""));

        //publication data
        //form.addItem(T_publication_data);

        Select type = form.addItem().addSelect("type","type");
        type.setLabel(T_publication_type);
        type.addOption("Monographie", "Monographie");
        type.addOption("Tagungsband", "Tagungsband");
        type.addOption("Sammelband", "Sammelband");
        type.addOption("Lehrbuch", "Lehrbuch");
        type.addOption("Dissertation", "Dissertation");
        type.addOption("Sonstige Publikation", "Sonstige Publikation");
        type.setOptionSelected(parameters.getParameter("type",""));

        Select creator_type = form.addItem().addSelect("creator_type","creator_type");
        creator_type.setLabel(T_creator_type);
        creator_type.addOption("author", "Autor");
        creator_type.addOption("editor", "Herausgeber");
        creator_type.setOptionSelected(parameters.getParameter("creator_type",""));

        Composite creator = form.addItem().addComposite("creator", "creator");
        Text creator_lastname = creator.addText("creator_lastname");
        Text creator_firstname = creator.addText("creator_firstname");
        creator.setLabel(T_creator);
        creator_lastname.setLabel(T_lastname_help);
        creator_firstname.setLabel(T_firstname_help);
        creator_lastname.setValue(parameters.getParameter("creator_lastname",""));
        creator_firstname.setValue(parameters.getParameter("creator_firstname",""));


        Composite creator2 = form.addItem().addComposite("creator2", "creator2");
        Text creator_lastname2 = creator2.addText("creator_lastname2");
        Text creator_firstname2 = creator2.addText("creator_firstname2");
        creator_lastname2.setLabel(T_lastname_help);
        creator_firstname2.setLabel(T_firstname_help);
        creator_lastname2.setValue(parameters.getParameter("creator_lastname2",""));
        creator_firstname2.setValue(parameters.getParameter("creator_firstname2",""));

        Composite creator3 = form.addItem().addComposite("creator3", "creator3");
        Text creator_lastname3 = creator3.addText("creator_lastname3");
        Text creator_firstname3 = creator3.addText("creator_firstname3");
        creator_lastname3.setLabel(T_lastname_help);
        creator_firstname3.setLabel(T_firstname_help);
        creator_lastname3.setValue(parameters.getParameter("creator_lastname3",""));
        creator_firstname3.setValue(parameters.getParameter("creator_firstname3",""));

        Composite creator4 = form.addItem().addComposite("creator4", "creator4");
        Text creator_lastname4 = creator4.addText("creator_lastname4");
        Text creator_firstname4 = creator4.addText("creator_firstname4");
        creator_lastname4.setLabel(T_lastname_help);
        creator_firstname4.setLabel(T_firstname_help);
        creator_lastname4.setValue(parameters.getParameter("creator_lastname4",""));
        creator_firstname4.setValue(parameters.getParameter("creator_firstname4",""));

        Composite creator5 = form.addItem().addComposite("creator5", "creator5");
        Text creator_lastname5 = creator5.addText("creator_lastname5");
        Text creator_firstname5 = creator5.addText("creator_firstname5");
        creator_lastname5.setLabel(T_lastname_help);
        creator_firstname5.setLabel(T_firstname_help);
        creator_lastname5.setValue(parameters.getParameter("creator_lastname5",""));
        creator_firstname5.setValue(parameters.getParameter("creator_firstname5",""));

        Text title = form.addItem().addText("publ_title");
        title.setLabel(T_publ_title);
        title.setValue(parameters.getParameter("publ_title",""));


        Text subtitle = form.addItem().addText("subtitle");
        subtitle.setLabel(T_subtitle);
        subtitle.setValue(parameters.getParameter("subtitle",""));

        Composite series = form.addItem().addComposite("series", "series");
        series.setLabel(T_series);
        series.setHelp(T_series_help);
        Text series_title = series.addText("series_title");
        Text series_volume = series.addText("series_volume");
        series_title.setLabel(T_series_title);
        series_volume.setLabel(T_series_volume);
        series_title.setValue(parameters.getParameter("series_title",""));
        series_volume.setValue(parameters.getParameter("series_volume",""));

        Select template = form.addItem().addSelect("template","template");
        template.setLabel(T_template);
        template.addOption("Word", "Word");
        template.addOption("OpenOffice", "OpenOffice");
        template.addOption("LaTeX", "LaTeX");
        template.setOptionSelected(parameters.getParameter("template",""));

        Text extent = form.addItem().addText("extent");
        extent.setLabel(T_extent);
        extent.setValue(parameters.getParameter("extent",""));


        Text colored = form.addItem().addText("colored");
        colored.setLabel(T_colored);
        colored.setValue(parameters.getParameter("colored",""));

        Select cover = form.addItem().addSelect("cover","cover");
        cover.setLabel(T_cover);
        cover.addOption("Softcover", "Softcover");
        cover.addOption("Hardcover", "Hardcover");
        cover.setOptionSelected(parameters.getParameter("cover",""));

        Text copy = form.addItem().addText("copy");
        copy.setHelp(T_copy_help);
        copy.setLabel(T_copy);
        copy.setValue(parameters.getParameter("copy",""));

        Composite delivery = form.addItem().addComposite("delivery_date", "delivery_date");
        Select delivery_year = delivery.addSelect("delivery_year");
        Select delivery_month = delivery.addSelect("delivery_month");
        Select delivery_day = delivery.addSelect("delivery_day");
        delivery.setLabel(T_delivery);
        delivery_year.setOptionSelected(parameters.getParameter("delivery_year","2015"));
        delivery_month.setOptionSelected(parameters.getParameter("delivery_month","1"));
        delivery_day.setOptionSelected(parameters.getParameter("delivery_day","1"));


        for (int i = start; i < (start + 11); i++)
        {
            delivery_year.addOption(Integer.toString(i),Integer.toString(i));
        }

        for (int i = 1; i < 13; i++)
        {
            delivery_month.addOption(org.dspace.content.DCDate.getMonthName(i,Locale.getDefault()),org.dspace.content.DCDate.getMonthName(i,Locale.getDefault()));
        }

        for (int i = 1; i < 32; i++)
        {
            delivery_day.addOption(Integer.toString(i),Integer.toString(i));
        }

        Composite issue_date = form.addItem().addComposite("issue_date", "issue_date");
        Select issue_year = issue_date.addSelect("issue_year");
        Select issue_month = issue_date.addSelect("issue_month");
        Select issue_day = issue_date.addSelect("issue_day");
        issue_date.setLabel(T_issue_date);
        issue_year.setOptionSelected(parameters.getParameter("issue_year","2015"));
        issue_month.setOptionSelected(parameters.getParameter("issue_month","1"));
        issue_day.setOptionSelected(parameters.getParameter("issue_day","1"));

        for (int i = start; i < (start + 11); i++)
        {
            issue_year.addOption(Integer.toString(i),Integer.toString(i));
        }

        for (int i = 1; i < 13; i++)
        {
            issue_month.addOption(org.dspace.content.DCDate.getMonthName(i,Locale.getDefault()),org.dspace.content.DCDate.getMonthName(i,Locale.getDefault()));
        }

        for (int i = 1; i < 32; i++)
        {
            issue_day.addOption(Integer.toString(i),Integer.toString(i));
        }


        TextArea comments = form.addItem().addTextArea("comments");
        comments.setLabel(T_comments);
        comments.setHelp(T_comments_help);
        comments.setValue(parameters.getParameter("comments",""));

        form.addItem().addButton("submit").setValue(T_submit);

        costrequest.addHidden("page").setValue(parameters.getParameter("page","unknown"));
    }
}

