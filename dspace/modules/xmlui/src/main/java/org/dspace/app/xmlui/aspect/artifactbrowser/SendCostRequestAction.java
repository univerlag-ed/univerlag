/**
 * SenCostRequest.java
 * Verion 1.0
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.net.InetAddress;
import java.util.*;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.core.Email;
import org.dspace.core.I18nUtil;


/**
 * Sends data from CostRequestForm to 
 * costrequest.recipient in dspace.cfg
 * in email.
 * 
 * @author Marianna Muehlhoelzer
 * based on SendFeedbackAction.java
 */

public class SendCostRequestAction extends AbstractAction
{

    /**
     *
     */
    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel,
                   String source, Parameters parameters) throws Exception
    {
        Request request = ObjectModelHelper.getRequest(objectModel);

        String page = request.getParameter("page");
        String lastname	= request.getParameter("lastname");
        String firstname	= request.getParameter("firstname");
        String zip	= request.getParameter("zip");
        String city	= request.getParameter("city");
        String street	= request.getParameter("street");
        String number	= request.getParameter("number");
        String phone	= request.getParameter("phone");
        String customer_email	= request.getParameter("customer_email");
        String sponsor	= request.getParameter("sponsor");
        String type	= request.getParameter("type");
        String creator_type	= request.getParameter("creator_type");
        String creator_firstname	= request.getParameter("creator_firstname");
        String creator_lastname	= request.getParameter("creator_lastname");
        String creator_firstname2	= request.getParameter("creator_firstname2");
        String creator_lastname2	= request.getParameter("creator_lastname2");
        String creator_firstname3	= request.getParameter("creator_firstname3");
        String creator_lastname3	= request.getParameter("creator_lastname3");
        String creator_firstname4	= request.getParameter("creator_firstname4");
        String creator_lastname4	= request.getParameter("creator_lastname4");
        String creator_firstname5	= request.getParameter("creator_firstname5");
        String creator_lastname5	= request.getParameter("creator_lastname5");
        String publ_title	= request.getParameter("publ_title");
        String subtitle	= request.getParameter("subtitle");
        String institute	= request.getParameter("institute");
        String series_title	= request.getParameter("series_title");
        String series_volume	= request.getParameter("series_volume");
        String template	= request.getParameter("template");
        String extent	= request.getParameter("extent");
        String cover	= request.getParameter("cover");
        String colored	= request.getParameter("colored");
        String copy	= request.getParameter("copy");
        String issue_year	= request.getParameter("issue_year");
        String issue_month	= request.getParameter("issue_month");
        String issue_day	= request.getParameter("issue_day");
        String delivery_year	= request.getParameter("delivery_year");
        String delivery_month	= request.getParameter("delivery_month");
        String delivery_day	= request.getParameter("delivery_day");
        String comments	= request.getParameter("comments");

        // Obtain information from request
        // The page where the user came from
        String fromPage = request.getHeader("Referer");
        // Prevent spammers and splogbots from poisoning the CostRequest page
        String host = ConfigurationManager.getProperty("dspace.hostname");
        String allowedReferrersString = ConfigurationManager.getProperty("mail.allowed.referrers");

        String[] allowedReferrersSplit = null;
        boolean validReferral = false;

        if((allowedReferrersString != null) && (allowedReferrersString.length() > 0))
        {
            allowedReferrersSplit = allowedReferrersString.trim().split("\\s*,\\s*");
            for(int i = 0; i < allowedReferrersSplit.length; i++)
            {
                if(fromPage.indexOf(allowedReferrersSplit[i]) != -1)
                {
                    validReferral = true;
                    break;
                }
            }
        }

        String basicHost = "";
        if ("localhost".equals(host) || "127.0.0.1".equals(host)
                || host.equals(InetAddress.getLocalHost().getHostAddress()))
        {
            basicHost = host;
        }
        else
        {
            // cut off all but the hostname, to cover cases where more than one URL
            // arrives at the installation; e.g. presence or absence of "www"
            int lastDot = host.lastIndexOf('.');
            basicHost = host.substring(host.substring(0, lastDot).lastIndexOf('.'));
        }

        if ((fromPage == null) || ((fromPage.indexOf(basicHost) == -1) && (!validReferral)))
        {
            // N.B. must use old message catalog because Cocoon i18n is only available to transformed pages.
            throw new AuthorizeException(I18nUtil.getMessage("CostRequest.error.forbidden"));
        }

        // User email from context
        Context context = ContextUtil.obtainContext(objectModel);

        if (page == null || page.equals(""))
        {
            page = fromPage;
        }

        // Check all required data is there
        if ((lastname == null) || lastname.equals("") || (firstname == null) || firstname.equals("")
                || (street == null) || street.equals("") ||  (city == null) || city.equals("")
                || (zip == null) || zip.equals("") || (number == null) || number.equals("")
                || (phone == null) || phone.equals("") || (customer_email == null) || customer_email.equals("")
                || (sponsor == null) || sponsor.equals("") || (creator_lastname == null) || creator_lastname.equals("")
                || (type == null) || type.equals("") || (creator_firstname == null) || creator_firstname.equals("")
                || (publ_title == null) || publ_title.equals("") || (issue_year == null) || issue_year.equals("")
                || (issue_day == null) || issue_day.equals("") || (issue_month == null) || issue_month.equals("")
                || (template == null) || template.equals("")
                || (cover == null) || cover.equals("")
                || (extent == null) || extent.equals(""))
        {
            // Either the user did not fill out the form or this is the
            // first time they are visiting the page.
            Map<String,String> map = new HashMap<String,String>();
            map.put("page",page);

            if (lastname != null) { map.put("lastname",lastname); }
            if (firstname != null) { map.put("firstname",firstname); }
            if (street != null) { map.put("street",street); }
            if (number != null) { map.put("number",number); }
            if (zip != null) { map.put("zip",zip); }
            if (city != null) { map.put("city",city); }
            if (phone != null) { map.put("phone",phone); }
            if (customer_email != null) { map.put("customer_email",customer_email); }
            if (sponsor != null) { map.put("sponsor",sponsor); }
            if (type != null) { map.put("type",type); }
            if (creator_firstname != null) { map.put("creator_firstname",creator_firstname); }
            if (creator_lastname != null) { map.put("creator_firstname",creator_lastname); }
            if (creator_firstname2 != null) { map.put("creator_firstname2",creator_firstname2); }
            if (creator_lastname2 != null) { map.put("creator_firstname2",creator_lastname2); }
            if (creator_firstname3 != null) { map.put("creator_firstname3",creator_firstname3); }
            if (creator_lastname3 != null) { map.put("creator_firstname3",creator_lastname3); }
            if (creator_firstname4 != null) { map.put("creator_firstname4",creator_firstname4); }
            if (creator_lastname4 != null) { map.put("creator_firstname4",creator_lastname4); }
            if (creator_firstname5 != null) { map.put("creator_firstname5",creator_firstname5); }
            if (creator_lastname5 != null) { map.put("creator_firstname5",creator_lastname5); }
            if (publ_title != null) { map.put("publ_title",publ_title); }
            if (subtitle != null) { map.put("subtitle",subtitle); }
            if (institute != null) { map.put("institute",institute); }
            if (series_title != null) { map.put("series_title",series_title); }
            if (series_volume != null) { map.put("series_volume",series_volume); }
            if (template != null) { map.put("template",template); }
            if (extent != null) { map.put("extent",extent); }
            if (cover != null) { map.put("cover",cover); }
            if (colored != null) { map.put("colored",colored); }
            if (copy != null) { map.put("copy",copy); }
            if (issue_day != null) { map.put("issue_day",issue_day); }
            if (issue_month != null) { map.put("issue_month",issue_month); }
            if (issue_year != null) { map.put("issue_year",issue_year); }
            if (delivery_day != null) { map.put("delivery_day",delivery_day); }
            if (delivery_month != null) { map.put("delivery_month",delivery_month); }
            if (delivery_year != null) { map.put("issue_year",delivery_year); }
            if (comments != null) { map.put("comments",comments); }
            return map;
        }

        // All data is there, send the email
        Email email = Email.getEmail(I18nUtil.getEmailFilename(context.getCurrentLocale(), "CostRequest"));
        email.addRecipient(ConfigurationManager
                .getProperty("costrequest.recipient"));


        String customer_data = lastname + ", " + firstname + "\n" + street + " " + number +
                "\n" + zip + " " + city + 
		"\nTel.: " + phone + "\nE-Mail: " + customer_email;
	
	if ((institute != null) && !institute.equals(""))
        {
            customer_data +=  "\nFakultät/Institut: " + institute;
        }
         
	customer_data += "\nKostenübernahme durch: " + sponsor;

        StringBuilder creators=  new StringBuilder();
        creators.append(creator_firstname + " " + creator_lastname);

        if ((creator_lastname2 != null) && !creator_lastname2.equals("") &&
                (creator_firstname2 != null) && !creator_firstname2.equals("")) { creators.append(" / " + creator_firstname2 + " " + creator_lastname2);}
        if ((creator_lastname3 != null) && !creator_lastname3.equals("") &&
                (creator_firstname3 != null) && !creator_firstname3.equals("")) { creators.append(" / " + creator_firstname3 + " " + creator_lastname3);}
        if ((creator_lastname4 != null) && !creator_lastname4.equals("") &&
                (creator_firstname4 != null) && !creator_firstname4.equals("")) { creators.append(" / " + creator_firstname4 + " " + creator_lastname4);}
        if ((creator_lastname5 != null) && !creator_lastname5.equals("") &&
            (creator_firstname5 != null) && !creator_firstname5.equals("")){ creators.append(" / " + creator_firstname5 + " " + creator_lastname5);}

       if (creator_type.equals("editor")) {
            creators.append(" (Eds.)");
        }

        String publication = "(" + type + ") " + creators.toString() + ": " + publ_title;
	if (subtitle != null)
	{
		publication = publication + "\n" + subtitle;
	}

        if ((series_title != null) && !series_title.equals(""))
        {
            publication = publication + "\nSerie: " + series_title;
        }

        if ((series_volume != null) && !series_volume.equals(""))
        {
            publication = publication + "; " + series_volume;
        }

        String publication_data = publication_data = "Vorlage: " + template +
            "\nSeitenzahl: " + extent + "\nAusstattung: " + cover +
            "\nGewünschte Veröffentlichung: " + issue_day + " " + issue_month + " " + issue_year + "\nAnzahl der Exemplare: " + copy;

        if ((colored != null) && !colored.equals("")) {
            publication_data = publication_data + "\nSeiten mit farbigen Elementen: " + colored;
        }

        if(delivery_year != null)
        {
                publication_data = publication_data +  "\nManuskriptabgabe: " + delivery_day + " " +
                     delivery_month + " " + delivery_year;
        }

        email.addArgument(new Date()); // Date
        email.addArgument(customer_email);    // Email
        email.addArgument(page);       // Referring page
        email.addArgument(customer_data);
        email.addArgument(publication);
        email.addArgument(publication_data);

        email.addArgument(comments);   // The CostRequest itself

        // Replying to CostRequest will reply to email on form
        email.setReplyTo(customer_email);

        // May generate MessageExceptions.
        email.send();

        // Finished, allow to pass.
        return null;
    }

}

