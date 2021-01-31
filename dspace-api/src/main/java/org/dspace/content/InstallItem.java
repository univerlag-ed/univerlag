/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content;

import java.io.IOException;
import java.sql.SQLException;

import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.embargo.EmbargoManager;
import org.dspace.event.Event;
import org.dspace.identifier.IdentifierException;
import org.dspace.identifier.IdentifierService;
import org.dspace.utils.DSpace;

import org.dspace.handle.HandleManager;
import org.dspace.core.ConfigurationManager;

/**
 * Support to install an Item in the archive.
 * 
 * @author dstuve
 * @version $Revision$
 */
public class InstallItem
{
    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item,
     * creating a new Handle.
     * 
     * @param c
     *            DSpace Context
     * @param is
     *            submission to install
     * 
     * @return the fully archived Item
     */

    /*Take SUB URN prefix as default*/
    static final String DEFAULT_UURN =  "urn:nbn:de:gbv:7-";


    public static Item installItem(Context c, InProgressSubmission is)
            throws SQLException, IOException, AuthorizeException
    {
        return installItem(c, is, null);
    }

    /**
     * Take an InProgressSubmission and turn it into a fully-archived Item.
     * 
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give to the installed item
     * 
     * @return the fully archived Item
     */
    public static Item installItem(Context c, InProgressSubmission is,
            String suppliedHandle) throws SQLException,
            IOException, AuthorizeException
    {
        Item item = is.getItem();
        Collection collection = is.getCollection();
        
        IdentifierService identifierService = new DSpace().getSingletonService(IdentifierService.class);
        try {
            if(suppliedHandle == null)
            {
                identifierService.register(c, item);
            }else{
                identifierService.register(c, item, suppliedHandle);
            }
        } catch (IdentifierException e) {
            throw new RuntimeException("Can't create an Identifier!", e);
        }

        populateMetadata(c, item);

        // Finish up / archive the item
        item = finishItem(c, item, is);
        
        // As this is a BRAND NEW item, as a final step we need to remove the
        // submitter item policies created during deposit and replace them with
        // the default policies from the collection.
        item.inheritCollectionDefaultPolicies(collection);
        
        return item;
    }

    /**
     * Turn an InProgressSubmission into a fully-archived Item, for
     * a "restore" operation such as ingestion of an AIP to recreate an
     * archive.  This does NOT add any descriptive metadata (e.g. for
     * provenance) to preserve the transparency of the ingest.  The
     * ingest mechanism is assumed to have set all relevant technical
     * and administrative metadata fields.
     *
     * @param c  current context
     * @param is
     *            submission to install
     * @param suppliedHandle
     *            the existing Handle to give the installed item, or null
     *            to create a new one.
     *
     * @return the fully archived Item
     */
    public static Item restoreItem(Context c, InProgressSubmission is,
            String suppliedHandle)
        throws SQLException, IOException, AuthorizeException
    {
        Item item = is.getItem();

        IdentifierService identifierService = new DSpace().getSingletonService(IdentifierService.class);
        try {
            if(suppliedHandle == null)
            {
                identifierService.register(c, item);
            }else{
                identifierService.register(c, item, suppliedHandle);
            }
        } catch (IdentifierException e) {
            throw new RuntimeException("Can't create an Identifier!");
        }

        // Even though we are restoring an item it may not have the proper dates. So let's
        // double check its associated date(s)
        DCDate now = DCDate.getCurrent();
        
        // If the item doesn't have a date.accessioned, set it to today
        Metadatum[] dateAccessioned = item.getMetadata("dc","date", "accessioned", Item.ANY);
        if (dateAccessioned.length == 0)
        {
	        item.addMetadata("dc","date", "accessioned", null, now.toString());
        }
        
        // If issue date is set as "today" (literal string), then set it to current date
        // In the below loop, we temporarily clear all issued dates and re-add, one-by-one,
        // replacing "today" with today's date.
        // NOTE: As of DSpace 4.0, DSpace no longer sets an issue date by default
        Metadatum[] currentDateIssued = item.getMetadata("dc","date", "issued", Item.ANY);
        item.clearMetadata("dc","date", "issued", Item.ANY);
        for (Metadatum dcv : currentDateIssued)
        {
            if(dcv.value!=null && dcv.value.equalsIgnoreCase("today"))
            {
                DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
                item.addDC(dcv.element, dcv.qualifier, dcv.language, issued.toString());
            }
            else if(dcv.value!=null)
            {
                item.addDC(dcv.element, dcv.qualifier, dcv.language, dcv.value);
            }
        }
        
        // Record that the item was restored
        String provDescription = "Restored into DSpace on "+ now + " (GMT).";
        item.addMetadata("dc","description", "provenance", "en", provDescription);

        return finishItem(c, item, is);
    }


    private static void populateMetadata(Context c, Item item)
        throws SQLException, IOException, AuthorizeException
    {
        // create accession date
        DCDate now = DCDate.getCurrent();
        item.addDC("date", "accessioned", null, now.toString());

        // add date available if not under embargo, otherwise it will
        // be set when the embargo is lifted.
        // this will flush out fatal embargo metadata
        // problems before we set inArchive.
        if (EmbargoManager.getEmbargoTermsAsDate(c, item) == null)
        {
             item.addDC("date", "available", null, now.toString());
        }

        // If issue date is set as "today" (literal string), then set it to current date
        // In the below loop, we temporarily clear all issued dates and re-add, one-by-one,
        // replacing "today" with today's date.
        // NOTE: As of DSpace 4.0, DSpace no longer sets an issue date by default
        Metadatum[] currentDateIssued = item.getDC("date", "issued", Item.ANY);
        item.clearDC("date", "issued", Item.ANY);
        for (Metadatum dcv : currentDateIssued)
        {
            if(dcv.value!=null && dcv.value.equalsIgnoreCase("today"))
            {
                DCDate issued = new DCDate(now.getYear(),now.getMonth(),now.getDay(),-1,-1,-1);
                item.addDC(dcv.element, dcv.qualifier, dcv.language, issued.toString());
            }
            else if(dcv.value!=null)
            {
                item.addDC(dcv.element, dcv.qualifier, dcv.language, dcv.value);
            }
        }

         String provDescription = "Made available in DSpace on " + now
                + " (GMT). " + getBitstreamProvenanceMessage(item);

        // If an issue date was passed in and it wasn't set to "today" (literal string)
        // then note this previous issue date in provenance message
        if (currentDateIssued.length != 0)
        {
            String previousDateIssued = currentDateIssued[0].value;
            if(previousDateIssued!=null && !previousDateIssued.equalsIgnoreCase("today"))
            {
                DCDate d = new DCDate(previousDateIssued);
                provDescription = provDescription + "  Previous issue date: "
                        + d.toString();
            }
        }

        // Add provenance description
        item.addDC("description", "provenance", "en", provDescription);
	if (!(item.getMetadata("dc", "type", null, Item.ANY)[0].value.equals("bookPart")))
	{
	        //Create URN and add to metadata
        	String handleKey = item.getHandle().substring(item.getHandle().indexOf('/')+1);
	        if (item.getMetadata("dc","identifier", "urn", Item.ANY).length == 0)
        	{
	            String urn = getURNPrefix() +  handleKey + '-';
        	    item.addMetadata("dc","identifier", "urn", null, urn + URNChecksum(urn));
	        }
        	//Add ISBN or ISSN if existent in handle
		if (handleKey.indexOf("isbn") > -1)
	        {
        	    String isbn = handleKey.substring(handleKey.indexOf("isbn-") + 5);
	            item.addMetadata("dc", "relation", "isbn-13", null, isbn);
		    item.addMetadata("dc", "identifier", "asin", null, generateASIN(isbn)); 
        	}
	        else if (handleKey.indexOf("issn") > -1)
        	{
	            String issn = handleKey.substring(handleKey.indexOf("issn-") + 5);
        	    item.addMetadata("dc","relation", "issn", null, issn);
	        }
	}
        else {
              //set bookpart private
              item.setDiscoverable(false);

              //register to parent
              String parentHandle = item.getMetadata("dc", "relation", "ispartof", Item.ANY)[0].value;
              String partnr = item.getMetadata("dc", "bibliographicCitation", "chapter", Item.ANY)[0].value;

              if (parentHandle != null) {
                        DSpaceObject parentdso;
                        parentdso = HandleManager.resolveToObject(c, parentHandle);
                        Item parentItem = (Item) parentdso;

                        parentdso.addMetadata("dc", "relation", "haspart", null, parentHandle + '.' + partnr);
                        parentItem.update();
              }
        }

    }

    /**
     * Final housekeeping when adding a new Item into the archive.
     * This method is used by *both* installItem() and restoreItem(),
     * so all actions here will be run for a newly added item or a restored item.
     *
     * @param c DSpace Context
     * @param item Item in question
     * @param is InProgressSubmission object
     * @return final "archived" Item
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     */
    private static Item finishItem(Context c, Item item, InProgressSubmission is)
        throws SQLException, IOException, AuthorizeException
    {
        // create collection2item mapping
        is.getCollection().addItem(item);

        // set owning collection
        item.setOwningCollection(is.getCollection());

        // set in_archive=true
        item.setArchived(true);
        
        // save changes ;-)
        item.update();

        // Notify interested parties of newly archived Item
        c.addEvent(new Event(Event.INSTALL, Constants.ITEM, item.getID(),
                item.getHandle(), item.getIdentifiers(c)));

        // remove in-progress submission
        is.deleteWrapper();

        // set embargo lift date and take away read access if indicated.
        EmbargoManager.setEmbargo(c, item);

        return item;
    }

    /**
     * Generate provenance-worthy description of the bitstreams contained in an
     * item.
     * 
     * @param myitem  the item to generate description for
     * 
     * @return provenance description
     */
    public static String getBitstreamProvenanceMessage(Item myitem)
    						throws SQLException
    {
        // Get non-internal format bitstreams
        Bitstream[] bitstreams = myitem.getNonInternalBitstreams();

        // Create provenance description
        StringBuilder myMessage = new StringBuilder();
        myMessage.append("No. of bitstreams: ").append(bitstreams.length).append("\n");

        // Add sizes and checksums of bitstreams
        for (int j = 0; j < bitstreams.length; j++)
        {
            myMessage.append(bitstreams[j].getName()).append(": ")
                    .append(bitstreams[j].getSize()).append(" bytes, checksum: ")
                    .append(bitstreams[j].getChecksum()).append(" (")
                    .append(bitstreams[j].getChecksumAlgorithm()).append(")\n");
        }

        return myMessage.toString();
    }

    /**
     * Get the configured URN prefix string, or the default SUB URNprefix
     * @return configured prefix or "urn:nbn:de:gbv:7-"
     */
    public static String getURNPrefix()
    {
        String URNPrefix = ConfigurationManager.getProperty("urn.prefix");
        if (URNPrefix == null)
            URNPrefix = DEFAULT_UURN;

        return URNPrefix;
    }

    /**
     * Generate urn-checksum for the urn of an item
     *
     * @param uurn  (unchecked) urn i.e. urn without checksum
     *
     * @return urn checksum to be appended to uurn
     */
    private static String URNChecksum(String uurn)
    {
        String urn = uurn.toUpperCase();
        int[] Nums={1,2,3,4,5,6,7,8,9,41,18,14,19,15,16,21,22,23,24,25,
                42,26,27,13,28,29,31,12,32,33,11,34,35,36,37,38,39,17,47,43,45,49};

        String Zeichen="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-:._/+";
        int erg=0;
        StringBuffer sb= new StringBuffer();

        for(int i=0; i < urn.length(); i++)
            sb.append(Nums[Zeichen.indexOf(urn.charAt(i))]);

        for(int i=0;i<sb.length();i++)
            erg=erg+(i+1)*(sb.charAt(i)-48);

        erg=erg/(sb.charAt(sb.length()-1)-48);
        String serg=String.valueOf(erg);
        return serg.substring(serg.length() - 1);
    }


    /**
     * Generate 10-digit ISBN needed for ASIN (Amazon Serial Book Identifier) 
     *
     * @param 13-digit ISBN
     *
     * @return 10-digit ISBN without "-"
     */
    private static String generateASIN(String isbn)
    {
	String base = isbn.substring(0,16).substring(4).replaceAll("-","");
	int checksum=0;
        for(int i=0;i<9;i++)
            checksum += base.charAt(i) * (i+1);

	checksum = checksum % 11;
	
        return base  + checksum;
    }
}
