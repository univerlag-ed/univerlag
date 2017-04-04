/**
 * SenCostRequest.java
 * Verion 1.0
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.io.IOException;
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

import javax.mail.MessagingException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.AddressException;



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
        final Request request = ObjectModelHelper.getRequest(objectModel);
        Map<String,String> map = new HashMap<String,String>();

        boolean complete = true;

        String page = request.getParameter("page");
        String name	= request.getParameter("name");
        String zip	= request.getParameter("zip");
        String city	= request.getParameter("city");
        String address	= request.getParameter("address");
        String phone	= request.getParameter("phone");
        String customer_email	= request.getParameter("customer_email");
        String sponsor	= request.getParameter("sponsor");
        String publ_type	= request.getParameter("publ_type");
        String creator_type	= request.getParameter("creator_type");
        String creator1	= request.getParameter("creator1");
        String creator2	= request.getParameter("creator2");
        String creator3	= request.getParameter("creator3");
        String creator4	= request.getParameter("creator4");
        String publ_title	= request.getParameter("publ_title");
        String subtitle	= request.getParameter("subtitle");
        String institute	= request.getParameter("institute");
        String series	= request.getParameter("seriese");
        String template	= request.getParameter("template");
        String extent	= request.getParameter("extent");
        String cover	= request.getParameter("cover");
        String colored	= request.getParameter("colored");
        String copy	= request.getParameter("copy");
        String issue_date	= request.getParameter("issue_date");
        String delivery_date	= request.getParameter("delivery_date");
        String comments	= request.getParameter("comments");

        String[] requiredParams = new String[] {"page","name","zip", "city", "address",
                "phone", "customer_email", "sponsor", "publ_type", "creator_type", "creator1",
                "publ_title", "template", "extent", "cover", "issue_date"};

        Map<String,String> allParams = new HashMap<String,String>();

            allParams.put("page", request.getParameter("page"));
            allParams.put("name", request.getParameter("name"));
            allParams.put("zip", request.getParameter("zip"));
            allParams.put("city", request.getParameter("city"));
            allParams.put("address", request.getParameter("address"));
            allParams.put("phone", request.getParameter("phone"));
            allParams.put("customer_email", request.getParameter("customer_email"));
            allParams.put("sponsor", request.getParameter("sponsor"));
            allParams.put("publ_type", request.getParameter("publ_type"));
            allParams.put("creator_type", request.getParameter("creator_type"));
            allParams.put("creator1", request.getParameter("creator1"));
            allParams.put("creator2", request.getParameter("creator2"));
            allParams.put("creator3", request.getParameter("creator3"));
            allParams.put("creator4", request.getParameter("creator4"));
            allParams.put("publ_title", request.getParameter("publ_title"));
            allParams.put("subtitle", request.getParameter("subtitle"));
            allParams.put("institute", request.getParameter("institute"));
            allParams.put("series", request.getParameter("series"));
            allParams.put("template", request.getParameter("template"));
            allParams.put("extent", request.getParameter("extent"));
            allParams.put("cover", request.getParameter("cover"));
            allParams.put("colored", request.getParameter("colored"));
            allParams.put("copy", request.getParameter("copy"));
            allParams.put("issue_date", request.getParameter("issue_date"));
            allParams.put("delivery_date", request.getParameter("delivery_date"));
            allParams.put("comments", request.getParameter("comments"));




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
        for (String field : requiredParams)
        {
            if ( allParams.get(field) == null || allParams.get(field).equals(""))
            {
                complete = false;
                break;
            }
        }

        //There are missing required fields: return existent values
        if (!complete)
        {
            for (Map.Entry<String, String> field : allParams.entrySet()) {
                if (field.getValue() != null) {
                    map.put(field.getKey(),field.getValue());
                }
            }
            return map;
        }




        // All data are there, send the email
        Email email = Email.getEmail(I18nUtil.getEmailFilename(context.getCurrentLocale(), "CostRequest"));
        email.addRecipient(ConfigurationManager
                .getProperty("costrequest.recipient"));


        String customer_data = name + "\n" + address  +
                "\n" + zip + " " + city + 
		"\nTel.: " + phone + "\nE-Mail: " + customer_email;
	
	if ((institute != null) && !institute.equals(""))
        {
            customer_data +=  "\nFakultät/Institut: " + institute;
        }
         
	customer_data += "\nKostenübernahme durch: " + sponsor;

        StringBuilder creators=  new StringBuilder();
        creators.append(creator1 + " ");

        if ((creator2 != null) && !creator2.equals("")) { creators.append(" / " + creator2 + " ");}
        if ((creator3 != null) && !creator3.equals("")) { creators.append(" / " + creator3 + " ");}
        if ((creator4 != null) && !creator4.equals("")) { creators.append(" / " + creator4 + " ");}


       if (creator_type.equals("editor")) {
            creators.append(" (Eds.)");
        }

        String publication = "(" + publ_type + ") " + creators.toString() + ": " + publ_title;
	if (subtitle != null)
	{
		publication = publication + "\n" + subtitle;
	}

        if ((series != null) && !series.equals(""))
        {
            publication = publication + "\nSerie: " + series;
        }

        String publication_data = publication_data = "Vorlage: " + template +
            "\nSeitenzahl: " + extent + "\nAusstattung: " + cover +
            "\nGewünschte Veröffentlichung: " + issue_date + " " + "\nAnzahl der Exemplare: " + copy;

        if ((colored != null) && !colored.equals("")) {
            publication_data = publication_data + "\nSeiten mit farbigen Elementen: " + colored;
        }

        if(delivery_date != null)
        {
                publication_data = publication_data +  "\nManuskriptabgabe: " + delivery_date + " ";
        }


        if (validateEmail(customer_email)) {
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
            try {
                email.send();
            }
            catch (MessagingException me)
            {
                allParams.put("error", "send");
                return map;
            }
            catch (IOException e1) {
                allParams.put("error", "send");
                return map;
            }


            // Finished, allow to pass.
            return null;
        }
        else
        {
            allParams.put("error", "invalid email");
            return map;
        }
    }

    private boolean validateEmail(String email) {
        boolean isValid = false;
        try {
            // Create InternetAddress object and validated the supplied
            // address which is this case is an email address.
            InternetAddress internetAddress = new InternetAddress(email);
            internetAddress.validate();
            isValid = true;
        } catch (AddressException e) {
            e.printStackTrace();
        }
        return isValid;
    }

}

